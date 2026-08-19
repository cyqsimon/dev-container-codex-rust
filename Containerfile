FROM registry.fedoraproject.org/fedora:latest

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Install development tools & libraries
RUN dnf update -y && \
    dnf group install -y development-tools c-development && \
    dnf install -y --setopt=install_weak_deps=False \
    hyperfine jq 'pkgconfig(openssl)' python3 ripgrep rustup uv which && \
    dnf clean all

# Set up unprivileged user
RUN groupadd --gid=1000 codex && useradd --uid=1000 --gid=1000 codex
USER codex
WORKDIR /home/codex
VOLUME ["/home/codex"]

# Install codex
RUN curl -fsSL https://chatgpt.com/codex/install.sh | sh
RUN /home/codex/.local/bin/codex --version > /home/codex/codex-version

# Configure codex
ADD config.toml ENVIRONMENT.md /home/codex/.codex/
WORKDIR /home/codex/project
ENTRYPOINT ["/home/codex/.local/bin/codex", "--cd=/home/codex/project", "--dangerously-bypass-approvals-and-sandbox"]
