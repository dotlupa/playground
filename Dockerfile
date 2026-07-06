FROM ubuntu:24.04

# ==========================================
# 1. Global environment and build arguments
# ==========================================
ARG DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
WORKDIR /workspace

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# ==========================================
# 2. System base utilities
# ==========================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    htop \
    wget \
    && rm -rf /var/lib/apt/lists/*

# ==========================================
# 3. Development runtimes (Rust, Python uv, Node.js)
# ==========================================
ARG NVM_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh" \
    NVM_DIR="$HOME/.nvm" \
    RUST_URL="https://sh.rustup.rs" \
    UV_URL="https://astral.sh/uv/install.sh"
    
RUN set -eux; \
    curl --proto '=https' --tlsv1.2 -sSf "$RUST_URL" | sh -s -- -y; \
    . "$HOME/.cargo/env"; \
    \
    curl -LsSf "$UV_URL" | sh; \
    . "$HOME/.local/bin/env"; \
    \
    curl -o- "$NVM_URL" | bash; \
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; \
    \
    uv python install 3.10; \
    uv python install 3.12; \
    uv python pin --global 3.12; \
    nvm install 18; \
    nvm install 22; \
    nvm alias default 22; \
    nvm use default

# ==========================================
# 4. AI agent tools
# ==========================================
ARG HERMES_DIR="$HOME/.hermes/hermes-agent" \
    HERMES_URL="https://hermes-agent.nousresearch.com/install.sh"

RUN set -eux; \
    . "$NVM_DIR/nvm.sh"; \
    npm install --global opencode-ai; \
    curl -fsSL "$HERMES_URL" | bash -s -- \
        --dir "$HERMES_DIR" \
        --skip-setup \
        --non-interactive

# ==========================================
# 5. AI agent configuration files
# ==========================================
# opencode: project root opencode.json is reflected via volume mount.
# Global config is included in the image to provide defaults.
COPY config/opencode.json $HOME/.config/opencode/opencode.json
COPY config/hermes.yml $HOME/.hermes/config.yaml

CMD ["/bin/bash"]
