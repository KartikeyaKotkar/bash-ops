#!/bin/bash
# BASH-Ops Installer
#
# This script automates the installation of the BASH-Ops tool and its
# dependencies onto a Linux system using a virtual environment.
# --- Strict Mode & Configuration ---
set -euo pipefail
INSTALL_DIR="/usr/local/lib/bash-ops"
VENV_DIR="$INSTALL_DIR/venv"
BIN_DIR="/usr/local/bin"
EXE_NAME="bash-ops"
# --- Helper Functions ---
info() {
    echo -e "\e[34m[INFO]\e[0m $1"
}
error() {
    echo -e "\e[31m[ERROR]\e[0m $1" >&2
    exit 1
}
# --- Pre-flight Checks ---
main() {
    info "Starting BASH-Ops installation..."
    # 1. Check for root privileges
    if [[ "$EUID" -ne 0 ]]; then
        error "This installer must be run with sudo or as root. Please run 'sudo ./install.sh'"
    fi
    # 2. Check for dependencies
    info "Checking for dependencies..."
    command -v bash >/dev/null 2>&1 || error "BASH is not installed. This is highly unusual. Aborting."
    command -v python3 >/dev/null 2>&1 || error "Python 3 is not installed. Please install it and try again."
    command -v ssh >/dev/null 2>&1 || error "OpenSSH client is not installed. Please install it and try again."
    info "All dependencies found."
    # 3. Create installation directories
    info "Creating installation directory at $INSTALL_DIR..."
    mkdir -p "$INSTALL_DIR"
    # 4. Copy application files
    info "Copying application files..."
    cd "$(dirname "${BASH_SOURCE[0]}")"
    cp -R ./modules "$INSTALL_DIR/"
    cp -R ./utils "$INSTALL_DIR/"
    cp ./bash-ops "$INSTALL_DIR/"
    cp ./requirements.txt "$INSTALL_DIR/"
    # 5. Create virtual environment
    info "Creating Python virtual environment at $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
    # 6. Install Python dependencies in virtual environment
    info "Installing Python dependencies via pip..."
    "$VENV_DIR/bin/pip" install --upgrade pip
    "$VENV_DIR/bin/pip" install -r "$INSTALL_DIR/requirements.txt"
    # 7. Create wrapper script that activates venv before running bash-ops
    info "Creating executable wrapper..."
    cat > "$BIN_DIR/$EXE_NAME" << 'EOF'
#!/bin/bash
INSTALL_DIR="/usr/local/lib/bash-ops"
VENV_DIR="$INSTALL_DIR/venv"
source "$VENV_DIR/bin/activate"
exec python3 "$INSTALL_DIR/bash-ops" "$@"
EOF
    chmod +x "$BIN_DIR/$EXE_NAME"
    # 8. Set executable permissions on main script
    chmod +x "$INSTALL_DIR/bash-ops"
    info "Installation complete!"
    info "You can now run the application by typing 'bash-ops' in your terminal."
}
# --- Run Installer ---
main "$@"
