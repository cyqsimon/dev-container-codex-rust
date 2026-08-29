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
USER root
RUN /home/codex/.local/bin/codex --version > /etc/codex-version
USER codex

# Configure codex
ADD config.toml ENVIRONMENT.md /home/codex/.codex/
WORKDIR /home/codex/project
ENTRYPOINT ["/home/codex/.local/bin/codex", "--cd=/home/codex/project", "--dangerously-bypass-approvals-and-sandbox"]

# Runlabel shortcut
LABEL start-here="bash -c '\"export CONTAINER_NAME=dev-container-codex-rust-$(pwd | xargs basename | sed -E '\''s/[^a-zA-Z0-9_-]/-/g'\''); \
    podman run --rm -it --name=$(printenv CONTAINER_NAME) \
    --userns=keep-id:uid=1000,gid=1000 \
    --volume=$(printenv CONTAINER_NAME)-home:/home/codex:Z \
    --volume=.:/home/codex/project:Z \
    \${IMAGE}\"'"
