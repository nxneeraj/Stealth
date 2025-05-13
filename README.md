# Stealth: Advanced Network Cloaking Engine

**Version:** 0.1.0
**Status:** Development

## 🧠 High-Level Vision

Stealth is an advanced, modular, terminal-based network-cloaking engine designed for robust privacy and dynamic network presence. It provides continuous IP address morphing, packet interception and modification capabilities, a real-time terminal dashboard, and a REST API for third-party integration.

## ✨ Key Features

* **Continuous IP Morphing:** Automatically changes the host's IP address at user-defined intervals. Integrates with proxies/VPNs.
* **Packet Interception & Modification (Core C components):** Captures outgoing packets, allowing for header rewriting and payload metadata adjustments for enhanced stealth (requires `libnetfilter_queue` on Linux).
* **Signal Shifting (Core C++ component):** Implements frequency-jitter algorithms to break predictable traffic patterns, aiming to defeat some forms of traffic analysis.
* **REST API:** Auto-generates a REST API on each run (if enabled) for controlling Stealth and retrieving status/logs. Supports API key authentication.
* **Flag-Driven CLI:** A comprehensive Bash-based CLI (`stealth.sh`) to control all aspects of the engine (interval, proxy, verbose mode, API launch, ghost mode, etc.).
* **Live Terminal Dashboard (Python + Rich):** Renders a full-screen, color-coded terminal dashboard displaying real-time events, IP changes, connection attempts (simulated/logged), errors, and system status.
* **Ghost Mode (`--ghost`):** An ultra-stealth mode that disables *all* disk-based logging (both text and JSON), leaving zero trace of Stealth's operational logs on the host system for the current session.
* **Dual Logging (Default Mode):**
    * `logs/stealth.json`: Structured JSON logs for easy parsing and potential use in web dashboards.
    * `logs/stealth.log`: Classic append-only text logs for human readability.
* **One-Step Installer (`install_stealth.sh`):** A Bash script to bootstrap dependencies, compile core C/C++ modules, set up the Python virtual environment, and optionally configure a systemd service for auto-start.
* **Multi-Language Modularity:** Core components in C/C++, API in Python (FastAPI), CLI in Bash, UI in Python (Rich). Optional API implementations in Go and Node.js are provided as placeholders.

## 🏗️ Architecture Overview

Stealth is built with a modular, multi-language architecture:

* **Core Engine (C/C++):**
    * Located in `core/`.
    * **C Modules (`core/c`):** Handles low-level network operations like IP morphing (conceptual, OS-dependent) using raw sockets/libpcap (conceptual) and packet interception using `libnetfilter_queue` (Linux-specific).
    * **C++ Modules (`core/cpp`):** Provides higher-level logic such as signal shifting algorithms and the core logging interface (`logger.cpp` providing a C-compatible interface via `logger_interface.h`).
    * Compiled using CMake (`core/cpp/CMakeLists.txt`).
* **REST API Layer (`api/`):**
    * **Python (FastAPI) (`api/python`):** Primary API implementation providing endpoints for `/start`, `/status`, `/logs`, `/config`, and `/rotate_ip_now`. Uses Uvicorn for serving.
    * **Go & Node.js (`api/go`, `api/js`):** Placeholder implementations for alternative high-performance or ecosystem-specific API servers.
* **Command-Line Interface (`cli/`):**
    * **Bash (`stealth.sh`):** The main entry point. Parses flags (using `flags.sh`) and orchestrates the core engine and API. Uses utility functions from `utils.sh`.
* **User Interface (`ui/`):**
    * **Python Terminal UI (`ui/python`):** A Rich-based, full-screen live dashboard (`terminal_ui.py`) with styling from `style_config.py`.
    * **Web Dashboard (Placeholder) (`ui/js`):** Basic structure for a future web-based dashboard.
* **Logging System (`logging/`):**
    * **Python JSON Logger (`json_logger.py`):** A script to append structured events to `logs/stealth.json`, designed for robustness with file locking.
    * **C++ Classic Log Writer (`log_writer.cpp`):** A simpler, alternative C++ text log writer. The primary C/C++ text logging is handled by `core/cpp/logger.cpp`.
    * **Schema (`logging/schemas/event_schema.json`):** Defines the structure for JSON log entries.
* **Installer (`installer/`):**
    * **Bash Script (`install_stealth.sh`):** Automates the setup process.
    * **Post-Install Guide (`post_install.md`):** Provides additional setup and troubleshooting information.

## 🚀 Getting Started

### Prerequisites

* Linux (recommended, especially for packet interception features).
* Build tools: `gcc/g++`, `cmake`, `make`, `pkg-config`.
* Network libraries: `libpcap-dev`, `libnetfilter-queue-dev` (or equivalent for your OS).
* Python 3.8+ with `pip` and `venv`.
* (Optional) Go, Node.js if you intend to use those API implementations.

### Installation

1.  **Clone the repository (if applicable):**
    ```bash
    git clone <repository_url>
    cd stealth
    ```
2.  **Run the installer script:**
    The installer will attempt to install system dependencies, build C/C++ modules, set up the Python environment, and link the CLI.
    ```bash
    cd installer
    sudo bash ./install_stealth.sh
    ```
    Refer to `installer/post_install.md` for more details and troubleshooting.

### Basic Usage

After installation, the `stealth` command should be available globally.

* **Show help:**
    ```bash
    stealth -h
    ```
* **Start Stealth with IP morphing every 60 seconds and launch the API:**
    ```bash
    sudo stealth -t 60 --api
    ```
    *(Note: `sudo` might be required for network operations, depending on system configuration and how core components are executed).*

* **Start in Ghost Mode (no logging), IP change every 30 seconds:**
    ```bash
    sudo stealth --ghost -t 30
    ```
* **Check current status (if running or to see default config):**
    ```bash
    stealth -s
    ```
* **Launch the Terminal UI (run in a separate terminal if Stealth core is running as a daemon):**
    Assuming the Python virtual environment is `stealth_env` in the project root:
    ```bash
    source stealth_env/bin/activate
    python ui/python/terminal_ui.py
    ```
    Or, if `stealth.sh` is adapted to launch it directly under certain conditions.

### API Interaction

If the API is launched (e.g., with `stealth --api`), you can interact with it (default port 8080):

* **Get status:**
    ```bash
    curl -H "X-Stealth-Key: YOUR_API_KEY" http://localhost:8080/api/v1/status
    ```
    *(Replace `YOUR_API_KEY` with the actual key, which should be set via the `STEALTH_API_KEY` environment variable for the API process).*

## 🛠️ Development

### Building Core Modules Manually

1.  Navigate to `core/cpp/`.
2.  Create a build directory: `mkdir build && cd build`.
3.  Run CMake: `cmake ..`.
4.  Compile: `make`.
    Executables (if any are defined as such beyond libraries) will typically be in `core/cpp/build/bin/` or the build root.

### Running Python Components

* **API Server (FastAPI):**
    ```bash
    # Ensure STEALTH_API_KEY is set
    # export STEALTH_API_KEY="your_dev_key"
    source stealth_env/bin/activate
    python -m stealth.api.python.app
    # or: uvicorn stealth.api.python.app:app --reload --port 8080
    ```
* **Terminal UI:**
    ```bash
    source stealth_env/bin/activate
    python ui/python/terminal_ui.py
    ```

### Logging

* **Text logs:** `logs/stealth.log`
* **JSON logs:** `logs/stealth.json`
* The `logging/json_logger.py` script can be used directly to add entries to the JSON log:
    ```bash
    python logging/json_logger.py INFO "Manual test log" component=manual_test
    ```

## 🧪 Testing

A basic test suite structure is provided in the `tests/` directory.

* **Core (C/C++):** Placeholder for CTest or GoogleTest in `tests/core/`.
* **API (Python):** Placeholder for Pytest in `tests/api/python/`.
* **CLI (Bash):** Placeholder for Bats tests in `tests/cli/`.

Run tests according to the framework used for each component.

## 🤝 Contributing

Contributions are welcome! Please follow standard fork-and-pull-request workflows. Ensure code is well-documented and includes tests for new features.

(Further details on contribution guidelines, coding standards, etc., would go here.)

## 📜 License

(Specify your chosen license, e.g., MIT, GPL, Apache 2.0)
This project is licensed under the MIT License - see the LICENSE.md file for details (if you create one).

## ⚠️ Disclaimer

This tool is intended for educational, research, and legitimate security testing purposes only. Users are responsible for complying with all applicable laws and regulations. The developers assume no liability and are not responsible for any misuse or damage caused by this program.