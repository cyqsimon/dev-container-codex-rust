FROM registry.fedoraproject.org/fedora:latest as rust-build
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Install Rust
RUN dnf install -y cargo && \
    dnf clean all

# Build binaries
RUN --mount=type=cache,target=/root/.cargo/registry \
    --mount=type=cache,target=/root/.cargo/git \
    cargo install --root=/build cargo-llvm-cov

FROM registry.fedoraproject.org/fedora:latest as release
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Install stuff from dnf
RUN dnf update -y && \
    dnf group install -y development-tools c-development && \
    dnf copr enable -y cyqsimon/codex && \
    dnf install -y --setopt=install_weak_deps=False \
    codex file hyperfine jq 'pkgconfig(openssl)' python3 ripgrep rustup uv which && \
    dnf clean all

# Copy support files
ADD ENVIRONMENT.md /etc/

# Copy locally-built tools
COPY --from=rust-build /build/bin/cargo-llvm-cov /usr/local/bin/

# Set up unprivileged user
RUN groupadd --gid=1000 codex && useradd --uid=1000 --gid=1000 codex
USER codex
WORKDIR /home/codex
VOLUME ["/home/codex"]

# Configure codex
ADD config.toml /home/codex/.codex/
WORKDIR /home/codex/project
ENTRYPOINT ["/usr/bin/codex", "--cd=/home/codex/project", "--dangerously-bypass-approvals-and-sandbox"]

# Runlabel shortcut
LABEL start-here="bash -c '\"export CONTAINER_NAME=dev-container-codex-rust-$(pwd | xargs basename | sed -E '\''s/[^a-zA-Z0-9_-]/-/g'\''); \
    podman run --rm -it --name=$(printenv CONTAINER_NAME) \
    --userns=keep-id:uid=1000,gid=1000 \
    --volume=$(printenv CONTAINER_NAME)-home:/home/codex:Z \
    --volume=.:/home/codex/project:Z \
    \${IMAGE}\"'"
