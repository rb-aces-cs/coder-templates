FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential clang clang-format clang-tidy gdb cmake ninja-build git \
    curl wget ca-certificates unzip zip pkg-config python3 python3-pip sudo tini locales \
 && sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen \
 && rm -rf /var/lib/apt/lists/*

# Create user
ARG USER=coder
RUN useradd -m -s /bin/bash $USER && echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/010-coder-nopasswd

# Install code-server (VS Code)
RUN curl -fsSL https://code-server.dev/install.sh | sh

USER $USER

# Install OpenVSX extensions (no MS marketplace dependency)
RUN code-server --install-extension llvm-vs-code-extensions.vscode-clangd && \
    code-server --install-extension webfreak.debug && \
    code-server --install-extension twxs.cmake

# Copy starter files
USER root
COPY project /usr/local/share/template
RUN chown -R $USER:$USER /usr/local/share/template
USER $USER

WORKDIR /home/$USER/project
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["bash", "-lc", "sleep infinity"]
