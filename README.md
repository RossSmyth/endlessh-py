# endlessh

Based off some blog article, but refined into a systemd socket activated service with lots of hardening.

Mainly to play with.

To test run `nom build -f test.nix`
To use import the module file.

Currently doesn't work as the service does not receive the FD. One is marked in the environment, but calling `sd_listen_fds()` via systemd-python doesn't output them. My guess is something with PrivatePIDs? 

```
endlessh-py[610]: PID: 1
endlessh-py[610]: LISTEN_PID: 1
endlessh-py[610]: LISTEN_PIDFD: 601
endlessh-py[610]: LISTEN_FDS: 1
endlessh-py[610]: listen_fds(): []
endlessh-py[610]: {}
endlessh-py[610]: Traceback (most recent call last):
endlessh-py[610]:   File "/nix/store/3l0mw0319ir55bnwbcsjhgczfw4xg087-endlessh-py/bin/endlessh-py", line 44, in <module>
endlessh-py[610]:     socket = fds["endlessh-py.socket"]
endlessh-py[610]:              ~~~^^^^^^^^^^^^^^^^^^^^^^
endlessh-py[610]: KeyError: 'endlessh-py.socket'
```
It should be named after the socket, but instead nothing is returned.
