import asyncio
import random
import os
import socket

from systemd.daemon import listen_fds_with_names, listen_fds, is_socket_inet
from systemd.daemon import notify


# TODO: Close on zero connections
# TODO: Watchdog
async def handler(_reader, writer):
    writer.write(b'HTTP/1.1 200 OK\r\n')
    try:
        while True:
            # Remember this is all arbitrary attacker-fed data.
            await asyncio.sleep(5)
            header = random.randint(0, 2**32)
            value = random.randint(0, 2**32)
            writer.write(b'X-%x: %x\r\n' % (header, value))
            await writer.drain()
    except (ConnectionResetError, BrokenPipeError):
        # Disconncted :)
        pass
    finally:
        # Close stuff
        writer.close()


async def main(fd: int):
    server = await asyncio.start_server(handler, sock=fd)
    notify("READY=1")
    async with server:
        await server.serve_forever()

NAME = "endlessh-py.socket"

if __name__ == "__main__":
    print("PID:", os.getpid())
    print("PIDFD:", os.pidfd_open(os.getpid()))
    print("LISTEN_PID:", os.environ.get("LISTEN_PID"))
    print("LISTEN_PIDFD:", os.environ.get("LISTEN_PIDFDID"))
    print("LISTEN_FDS:", os.environ.get("LISTEN_FDS"))
    print("listen_fds():", listen_fds(unset_environment=False))

    fds = listen_fds_with_names(unset_environment=False)

    if NAME in fds.values():
        for input_fd, name in fds.items():
            if name == NAME:
                fd = input_fd
    else:
        raise IOError("FD not passed")

    if not is_socket_inet(fd):
        raise TypeError("Socket is not an inet socket.")

    sock = socket.fromfd(fd, socket.AF_INET, socket.SOCK_STREAM)
    sock.setblocking(False)
    asyncio.run(main(sock))
