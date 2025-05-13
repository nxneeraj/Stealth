#!/bin/bash

# Stealth One-Step Installer Script
# This script bootstraps dependencies, compiles core modules,
# sets up Python environment, links CLI, and configures a systemd service.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
STEALTH_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" # Project root
PYTHON_VENV_NAME="stealth_env"
PYTHON_VENV_DIR="${STEALTH_ROOT_DIR}/${PYTHON_VENV_NAME}"
STEALTH_CLI_NAME="stealth" # Name for the global CLI command
STEALTH_SERVICE_NAME="stealth.service"
LOG_DIR="${STEALTH_ROOT_DIR}/logs"
BUILD_DIR="${STEALTH_ROOT_DIR}/core/build" # Build directory for C/C++

# --- Helper Functions ---
# Colors for output
if [ -t 1 ]; then
  NCOLOR='\033[0m'
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  ORANGE='\033[0;33m'
  BLUE='\033[0;34m'
else
  NCOLOR=''
  RED=''
  GREEN=''
  ORANGE=''
  BLUE=''
fi

log_info() {
  echo -e "${GREEN}[INFO] $1${NCOLOR}"
}
log_warn() {
  echo -e "${ORANGE}[WARN] $1${NCOLOR}"
}
log_error() {
  echo -e "${RED}[ERROR] $1${NCOLOR}" >&2
}
log_action() {
  echo -e "${BLUE}[ACTION] $1...${NCOLOR}"
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to request sudo access early if needed
ensure_sudo() {
  if [[ "$(id -u)" -ne 0 ]]; then
    log_info "This script will require sudo privileges for some operations."
    if ! sudo -v; then
      log_error "Sudo privileges are required. Please run with sudo or ensure your user has sudo access."
      exit 1
    fi
  fi
}


# --- Main Installation Steps ---
main() {
  log_info "Starting Stealth Installation..."
  cd "$STEALTH_ROOT_DIR" # Ensure we are in the project root

  ensure_sudo # Request sudo upfront for package installation and service setup

  # 1. Install System Dependencies
  install_system_dependencies

  # 2. Build C/C++ Core Modules
  build_core_modules

  # 3. Set up Python Virtual Environment and Install Dependencies
  setup_python_environment

  # 4. Create Log Directory
  setup_log_directory

  # 5. Link CLI Script for Global Access
  link_cli_script

  # 6. Set up systemd Service (Optional but recommended for auto-start)
  setup_systemd_service

  log_info "Stealth Installation Completed Successfully!"
  log_info "You can now use the '${STEALTH_CLI_NAME}' command."
  log_info "To start the service: sudo systemctl start ${STEALTH_SERVICE_NAME}"
  log_info "To enable on boot: sudo systemctl enable ${STEALTH_SERVICE_NAME}"
  log_info "See ${STEALTH_ROOT_DIR}/installer/post_install.md for troubleshooting and manual steps."
}

# --- Detailed Step Functions ---

install_system_dependencies() {
  log_action "Installing system dependencies"
  # Detect package manager (apt for Debian/Ubuntu, yum/dnf for Fedora/CentOS)
  # This is a common pattern; adjust for other OS if needed.
  if command_exists apt-get; then
    sudo apt-get update -y
    sudo apt-get install -y \
      build-essential \
      cmake \
      pkg-config \
      libpcap-dev \
      libnetfilter-queue-dev \
      python3 \
      python3-pip \
      python3-venv \
      curl \
      git # If fetching any deps via git
      # Add other system-level dependencies here (e.g., for Go, Node.js if building them from source)
    log_info "APT dependencies installed."
  elif command_exists dnf; then
    sudo dnf install -y \
      gcc-c++ \
      cmake \
      pkgconf-pkg-config \
      libpcap-devel \
      libnetfilter_queue-devel \
      python3 \
      python3-pip \
      python3-virtualenv \
      curl \
      git
    log_info "DNF dependencies installed."
  elif command_exists yum; then
     sudo yum install -y \
      gcc-c++ \
      cmake \
      pkgconfig \
      libpcap-devel \
      libnetfilter_queue-devel \
      python3 \
      python3-pip \
      python3-virtualenv \
      curl \
      git
     log_info "YUM dependencies installed."
  else
    log_warn "Could not detect common Linux package manager (apt, dnf, yum)."
    log_warn "Please install the following dependencies manually:"
    log_warn "  C/C++: build-essential/gcc-c++, cmake, pkg-config, libpcap-dev/devel, libnetfilter-queue-dev/devel"
    log_warn "  Python: python3, python3-pip, python3-venv/python3-virtualenv"
    log_warn "  Other: curl, git"
    read -p "Press [Enter] to continue attempt, or Ctrl+C to exit and install manually."
  fi
}

build_core_modules() {
  log_action "Building C/C++ core modules"
  if [ ! -d "$STEALTH_ROOT_DIR/core/cpp" ]; then
    log_error "Core C/C++ source directory not found at ${STEALTH_ROOT_DIR}/core/cpp"
    exit 1
  fi
  
  mkdir -p "$BUILD_DIR"
  cd "$BUILD_DIR"
  
  # Run CMake. Pass options if needed.
  # -DSTEALTH_BUILD_EXAMPLES=ON (if you want to build examples)
  # -DSTEALTH_USE_NFQUEUE=ON (default in CMakeLists.txt, ensure it's ON)
  if sudo cmake ../cpp -DSTEALTH_USE_NFQUEUE=ON; then
    log_info "CMake configuration successful."
  else
    log_error "CMake configuration failed. Check CMake output for errors."
    exit 1
  fi
  
  if sudo make -j$(nproc); then # Use all available processors for compilation
    log_info "Core modules built successfully."
  else
    log_error "Core module compilation failed. Check make output for errors."
    exit 1
  fi
  cd "$STEALTH_ROOT_DIR" # Return to project root
}

setup_python_environment() {
  log_action "Setting up Python virtual environment and installing dependencies"
  if [ ! -f "$STEALTH_ROOT_DIR/api/python/requirements.txt" ]; then
    log_error "Python requirements.txt not found."
    exit 1
  fi

  if [ -d "$PYTHON_VENV_DIR" ]; then
    log_info "Python virtual environment already exists at ${PYTHON_VENV_DIR}."
  else
    python3 -m venv "$PYTHON_VENV_DIR"
    log_info "Python virtual environment created at ${PYTHON_VENV_DIR}."
  fi

  # Activate venv and install requirements
  # shellcheck source=/dev/null
  source "${PYTHON_VENV_DIR}/bin/activate"
  pip install --upgrade pip
  pip install -r "$STEALTH_ROOT_DIR/api/python/requirements.txt" # For API
  if [ -f "$STEALTH_ROOT_DIR/ui/python/requirements.txt" ]; then # If UI has its own
    pip install -r "$STEALTH_ROOT_DIR/ui/python/requirements.txt"
  elif command_exists pip && command_exists rich; then # Install rich if not in reqs but style_config implies it
     : # Assume rich is in api/python/requirements.txt or installed globally
  else # Install rich if terminal UI is planned and not found.
     pip install rich # For Terminal UI
  fi

  deactivate # Deactivate venv
  log_info "Python dependencies installed in ${PYTHON_VENV_DIR}."
}

setup_log_directory() {
    log_action "Creating log directory"
    if sudo mkdir -p "$LOG_DIR"; then
        # Set appropriate permissions (e.g., writable by the user/group stealth runs as)
        # If systemd service runs as 'stealthuser', change owner: sudo chown -R stealthuser:stealthgroup "$LOG_DIR"
        # For now, make it generally writable, but this should be secured.
        sudo chmod -R 777 "$LOG_DIR" # Insecure for production, adjust as needed.
        log_info "Log directory created/ensured at ${LOG_DIR}."
    else
        log_error "Failed to create log directory ${LOG_DIR}."
        exit 1
    fi
    # Create empty log files if they don't exist
    sudo touch "${LOG_DIR}/stealth.log" "${LOG_DIR}/stealth.json"
    sudo chmod 666 "${LOG_DIR}/stealth.log" "${LOG_DIR}/stealth.json" # Writable by all (adjust for security)
}


link_cli_script() {
  log_action "Linking CLI script for global access"
  local cli_script_path="${STEALTH_ROOT_DIR}/cli/stealth.sh"
  local symlink_path="/usr/local/bin/${STEALTH_CLI_NAME}"

  if [ ! -f "$cli_script_path" ]; then
    log_error "Main CLI script stealth.sh not found at ${cli_script_path}."
    exit 1
  fi

  # Ensure stealth.sh is executable
  sudo chmod +x "$cli_script_path"
  # Also logging/json_logger.py
  if [ -f "${STEALTH_ROOT_DIR}/logging/json_logger.py" ]; then
    sudo chmod +x "${STEALTH_ROOT_DIR}/logging/json_logger.py"
  fi


  if [ -L "$symlink_path" ] && [ "$(readlink -f "$symlink_path")" = "$cli_script_path" ]; then
    log_info "CLI script already linked correctly at ${symlink_path}."
  else
    if [ -f "$symlink_path" ] || [ -L "$symlink_path" ]; then
      log_warn "Existing file or symlink found at ${symlink_path}. It will be overwritten."
      sudo rm -f "$symlink_path"
    fi
    sudo ln -s "$cli_script_path" "$symlink_path"
    log_info "Stealth CLI linked as '${STEALTH_CLI_NAME}' in ${symlink_path}."
  fi
}

setup_systemd_service() {
  log_action "Setting up systemd service (optional)"
  read -p "Do you want to set up a systemd service for Stealth? (y/N): " choice
  case "$choice" in
    y|Y )
      ;; # Continue
    * )
      log_info "Skipping systemd service setup."
      return
      ;;
  esac

  local service_file_path="/etc/systemd/system/${STEALTH_SERVICE_NAME}"
  # Create a user for the service to run as (more secure than root)
  # local service_user="stealthuser" # Example user
  # if ! id "$service_user" &>/dev/null; then
  #   log_info "Creating system user '${service_user}' for Stealth service..."
  #   sudo useradd --system --shell /usr/sbin/nologin --home-dir "${STEALTH_ROOT_DIR}" "$service_user" || log_warn "Could not create user ${service_user}. Service might run as root or current user."
  # fi


  log_info "Creating systemd service file at ${service_file_path}..."
  # Note: Adjust User, Group, WorkingDirectory, ExecStart as per your setup.
  # User=root is used here for simplicity for network operations, but a dedicated user is better.
  # The ExecStart should point to the *actual* stealth.sh and use flags for daemonized run.
  # It should activate the venv if Python parts are run directly by the service.
  # This example assumes stealth.sh handles venv activation or calls python from venv.
  # A wrapper script might be better for ExecStart.

  # If your stealth.sh is designed to run as a daemon (e.g. with --daemonize flag that uses C core or python background tasks)
  # Example: stealth.sh -t 60 --api --daemonize (or similar to start all components)
  # The STEALTH_PROJECT_ROOT variable needs to be available to the service, or paths made absolute.
  # Activating venv within the service ExecStart:
  # ExecStart=/bin/bash -c 'source /path/to/stealth_env/bin/activate && /path/to/stealth/cli/stealth.sh --daemon-options'
  
  # For simplicity, let's assume stealth.sh handles necessary setup for daemon mode.
  # Ensure your `stealth.sh --daemonize` or equivalent properly backgrounds the core C process and Python API.
  # A more robust ExecStart for a service that needs the Python venv:
  # ExecStart=${PYTHON_VENV_DIR}/bin/python ${STEALTH_ROOT_DIR}/api/python/app.py (if API is the main service)
  # Or if stealth.sh is the entry point:
  # ExecStart=${STEALTH_ROOT_DIR}/cli/stealth.sh -t 60 --api --some-daemon-flag

  sudo bash -c "cat > ${service_file_path}" << EOF
[Unit]
Description=Stealth Network Cloaking Engine Service
After=network.target

[Service]
Type=forking # Or 'simple' if your script daemonizes itself correctly and exits parent
User=root    # Change to a less privileged user if possible, ensure permissions for net ops and logs
WorkingDirectory=${STEALTH_ROOT_DIR}
# PIDFile=${STEALTH_ROOT_DIR}/stealth.pid # If your daemon creates a PID file

# Option 1: If stealth.sh manages daemonization and venv internally
ExecStart=/usr/local/bin/${STEALTH_CLI_NAME} -t 60 --api --port 8080 --daemonize
# Ensure --daemonize in stealth.sh forks correctly and the main process exits (for Type=forking)
# Or if --daemonize makes the script itself the long-running process, use Type=simple

# Option 2: If Python API is the main long-running service component
# ExecStart=${PYTHON_VENV_DIR}/bin/uvicorn stealth.api.python.app:app --host 0.0.0.0 --port 8080 --workers 1
# (This would also require the C core to be started, perhaps by the Python app or another service)

# Add Environment variables if needed by stealth.sh or its components
# Environment="STEALTH_GHOST_MODE=0"
# Environment="STEALTH_API_KEY=your_production_api_key" # Store securely!
# Environment="STEALTH_PROJECT_ROOT=${STEALTH_ROOT_DIR}" # Make project root available

Restart=on-failure
RestartSec=5s

StandardOutput=append:${LOG_DIR}/stealth-service.log
StandardError=append:${LOG_DIR}/stealth-service.err.log

[Install]
WantedBy=multi-user.target
EOF

  sudo chmod 644 "${service_file_path}"
  sudo systemctl daemon-reload
  log_info "Systemd service file created. Enable and start it with:"
  log_info "  sudo systemctl enable ${STEALTH_SERVICE_NAME}"
  log_info "  sudo systemctl start ${STEALTH_SERVICE_NAME}"
  log_info "  sudo systemctl status ${STEALTH_SERVICE_NAME}"
}

# --- Run Main ---
main "$@"