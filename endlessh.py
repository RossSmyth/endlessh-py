import asyncio
import random

from systemd.daemon import listen_fds_with_names, is_socket_inet


# TODO: Close on zero connections
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
        await asyncio.wait_for(writer.wait_closed(), timeout=1.0)


async def main(fd: int):
    server = await asyncio.start_server(handler, sock=fd)
    async with server:
        await server.serve_forever()

if __name__ == "__main__":
    fds = listen_fds_with_names()
    print(fds)

    socket = fds["endlessh-py.socket"]
    if not is_socket_inet(socket):
        raise TypeError("Socket is not an inet socket.")

    asyncio.run(main(fds["endlessh-py.socket"]))
