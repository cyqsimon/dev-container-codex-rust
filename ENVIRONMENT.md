# Agent environment

This container is an interactive coding-agent environment running on a local GNU/Linux host.

## Primary goals

- Make code changes only in `~/project/`.
- Store non-project data in `~/`.
- Prefer deterministic, inspectable, CLI-based workflows.
- Avoid surprising the operator.

## Filesystem layout

- `~/project/`
  - Primary working tree.
  - This is a bind mount from the host.
  - All source-code edits should happen here unless explicitly instructed otherwise.
- `~/`
  - Persistent user data.
  - Use this for caches, logs, notes, plans, downloaded references, and other non-project artifacts.
- `/tmp/`
  - Ephemeral temporary data.
  - Prefer this for short-lived scratch files.

## Execution model

- You are running as an unprivileged user inside a container.
- You may run local commands needed for software development, inspection, testing, formatting, and builds.
  - Many common development tools are pre-installed in the image via `dnf`. Prefer using those.
  - Prefer commands that are reproducible and non-interactive when possible.
  - Prefer long-form CLI flags in examples if available.
- Do not start long-lived background services unless they are required for the task.

## Network

- Internet access may be available.
- Local network access may be available, but you shall not attempt to explore it.
- If proxy environment variables (those defined by libcurl) are set, you shall respect them.
- Use network access only when it materially helps the task.
- Prefer authoritative primary sources for technical facts.
- When introducing dependency or tool changes, verify names and versions carefully.

## Tool and library installation policy

- When you need a tool that is not already installed:
  - Only consider tools available through `dnf`.
    - Exception: Rust toolchain. You may and should use `rustup`.
  - Since you lack privileges to use `dnf`, inform the operator of what you need.
  - Do not install tools via ad-hoc download scripts or language-specific global package installers unless explicitly instructed.
- When you need a library that is not already installed:
  - If it is a system library:
    - Only consider the ones available through `dnf`.
    - Since you lack privileges to use `dnf`, inform the operator of what you need.
  - If it is a Rust crate:
    - Only consider the ones available on `crates.io` through `cargo`.
  - If it is a Python sdist or wheel:
    - Only consider the ones available on PyPI through `uv`.
  - Similarly for other languages, only use the defacto library source through a widely-accepted package manager.
  - If it's not packaged, look for alternatives. Then if no good alternatives exist, let the operator decide what to do.
  - Slightly prioritise options that do not need system libraries (e.g. `rustls` to `openssl` in a Rust project).

## Safety and operator expectations

- Before destructive actions, assess whether they affect:
  - user data,
  - repository history,
  - credentials,
  - external services.
- Avoid destructive operations unless they are necessary for the task.
- Prefer minimally invasive changes.
- Prefer explaining risky intended actions before taking them.

## Project workflow

- Start by reading project-local instructions if present, especially `AGENTS.md` in the project tree.
- Treat deeper-scoped project instruction files as overriding broader ones.
- Keep changes aligned with the existing codebase style unless instructed otherwise.
- Run relevant verification commands after making changes when practical.

## Secrets and credentials

- Do not assume secrets are available.
- If credentials are present in the environment or filesystem, use them only when necessary for the task.
- Do not print secrets, tokens, private keys, or credential file contents.
- Do not copy secrets into the repository.
- Do not persist secrets into logs or notes.
- Do not use secrets in ways other than the intended purpose.

## Output and artifacts

- Keep generated artifacts out of the repository unless they are intended project outputs.
- Put temporary reports, plans, and research notes under `~/notes/` in a structured manner.
- Clean up large temporary artifacts when they are no longer needed.

## Preferred behavior

- Be concise, explicit, and reversible.
- Prefer small validated iterations over large speculative changes.
- Surface uncertainty clearly.
- If environment constraints conflict with the task, say so early.
