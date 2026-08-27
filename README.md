# dev-container-codex-rust

Containerised Codex agent intended for autonomously-iterating Rust development.

## Quick start

In your project directory, run
`podman container runlabel start-here ghcr.io/cyqsimon/dev-container-codex-rust:latest`.

This is equivalent to running:

```bash
HOME_VOLUME=$(pwd | xargs basename | sed -E 's/[^a-zA-Z0-9_-]/-/g')
podman run --rm -it \
  --userns=keep-id:uid=1000,gid=1000 \
  --volume dev-container-codex-rust-${HOME_VOLUME}:/home/codex:Z \
  --volume .:/home/codex/project:Z \
  ghcr.io/cyqsimon/dev-container-codex-rust:latest
```

Why these options are recommended are explained in the following sections.

## Usage

Running `podman run --rm -it ghcr.io/cyqsimon/dev-container-codex-rust:latest`
starts the Codex agent.

By default the agent runs as an unprivileged user, and is launched with
`--dangerously-bypass-approvals-and-sandbox` (i.e. `--yolo`).
**This means it has full reign over all files in its home directory within the container.**

### Data persistence

This container expects two mounts:

- `/home/codex/`: the agent's home directory, where it will write states, caches, notes, etc.
- `/home/codex/project/`: the project directory, where it will write actual code.

It is recommended to use a volume mount for `/home/codex/`, and a bind mount for `/home/codex/project/`.

In order to avoid file owner inconsistencies between host writes and container writes,
it is also recommended to pass `--userns=keep-id:uid=1000,gid=1000` to podman;
UID 1000 and GID 1000 here being the fixed UID and GID for the `codex` user within the container.
