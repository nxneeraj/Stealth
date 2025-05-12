# 🛡️ Stealth - The Next-Gen Cloaking Engine

> **Stealth** is a powerful, modular, multi-language network cloaking toolkit that lets you vanish from the digital radar. From IP morphing to real-time packet interception and signal shifting, Stealth empowers hackers, privacy advocates, and red-teamers with ultimate invisibility. ✨

---

## 🔥 Features

- 🔁 **IP Morphing** — Changes your IP on a timed interval, automatically.
- 🎭 **Ghost Mode** — `--ghost` disables all logs, leaving zero digital traces.
- 🧠 **Smart Packet Rewriting** — Modify packet headers & payloads on the fly.
- 📶 **Signal Shifting** — Randomize timing, disrupt pattern recognition.
- 🌐 **Built-in API** — Control everything over HTTP with full status endpoints.
- 📊 **Real-time Terminal Dashboard** — Colorful CLI interface showing activity live.
- 📁 **Log System** — Save every movement in `.json` and `.log` formats.
- 💡 **Modular Design** — Multi-language architecture (C, C++, Python, Go, JS, Bash).
- ⚙️ **Auto Installer** — One-shot `.sh` script sets up everything in minutes.

---

## 📦 File Structure

```

stealth/
├── core/                               # Low-level network engine
│   ├── c/                              # Pure C modules
│   │   ├── ip_morphing.c               # IP change logic (libpcap, raw sockets)
│   │   └── packet_intercept.c          # Packet interception & modification
│   ├── cpp/                            # C++ wrappers & utilities
│   │   ├── signal_shifting.cpp         # Frequency/shifting algorithms
│   │   ├── logger.cpp                  # Core logging interface
│   │   └── CMakeLists.txt              # Build instructions
│   └── include/                        # Headers for C/C++
│       ├── ip_morphing.h
│       ├── packet_intercept.h
│       └── signal_shifting.h
│
├── api/                                # REST API layer
│   ├── python/                         # FastAPI (or Flask) server
│   │   ├── app.py                      # Main entrypoint
│   │   ├── endpoints.py                # /start, /status, /logs, /config
│   │   ├── models.py                   # Pydantic data models
│   │   └── requirements.txt
│   ├── go/                             # High-performance API or client
│   │   ├── server.go                   # Alternative Go HTTP server
│   │   └── go.mod
│   └── js/                             # Node.js version or API client
│       ├── index.js                    # Express server or client library
│       └── package.json
│
├── cli/                                # Bash CLI entrypoint & helpers
│   ├── stealth.sh                      # Main CLI parser, invokes core + API
│   ├── flags.sh                        # Flag definitions & parsing logic
│   └── utils.sh                        # Shared shell functions (logging switch)
│
├── ui/                                 # Terminal & future web dashboards
│   ├── python/                         # Rich-based terminal UI
│   │   ├── terminal_ui.py              # Live dashboard logic
│   │   └── style_config.py             # Color schemes & panels
│   ├── js/                             # (Optional) Web dashboard
│   │   ├── public/                     # Static assets (HTML/CSS)
│   │   └── src/                        # React/Vue/Vanilla JS UI code
│   └── html_templates/                 # Jinja2 or EJS templates for logs
│
├── logging/                            # Logging & persistence
│   ├── json_logger.py                  # Python helper to append JSON events
│   ├── log_writer.cpp                  # C++ wrapper for classic logs
│   └── schemas/                        # JSON schema definitions
│       └── event_schema.json
│
├── installer/                          # Auto-install & setup scripts
│   ├── install_stealth.sh              # One-step installer (apt, build, link)
│   └── post_install.md                 # Manual steps / troubleshooting
│
├── tests/                              # Unit & integration tests
│   ├── core/                           # C/C++ tests (using CTest or GoogleTest)
│   ├── api/                            # Pytest (for Python) & Go tests
│   └── cli/                            # Bats tests (for Bash scripts)
│
├── docs/                               # Documentation & diagrams
│   ├── architecture.md                 # Detailed blueprint & flowcharts
│   ├── usage.md                        # CLI usage, examples, flags
│   └── api_reference.md                # API endpoint specs
│
└── README.md                           # Project overview & quickstart


````

---

## 🧪 Getting Started

### 🔧 Installation

```bash
git clone https://github.com/nxneeraj/stealth
cd stealth
chmod +x installer/install_stealth.sh
sudo ./installer/install_stealth.sh
````

> 🛠 This script will compile C/C++ components, install Python deps, set permissions, and configure aliases.

---

### 🖥️ Run the Tool

```bash
stealth -t 60 --api --ghost
```

#### 🧵 Available Flags

| Flag                | Description                              |
| ------------------- | ---------------------------------------- |
| `-t`, `--interval`  | Interval in seconds to change IP         |
| `--api`             | Launch HTTP API (default port 8080)      |
| `-p <port>`         | Custom API port                          |
| `--proxy host:port` | Use proxy tunnel                         |
| `--ghost`           | Do not save any logs (no trace)          |
| `--status`          | Print current IP + time to next rotation |
| `-v`, `--verbose`   | Print detailed logs in terminal          |

---

### 🖼️ Terminal Dashboard

* Live tracking of:

  * Current IP
  * Next IP change in countdown
  * Incoming/outgoing packets
  * Color-coded events
* Keyboard input:

  * `q` = quit
  * `r` = force rotate
* Logs:

  * `.json`: structured (for HTML dashboards)
  * `.log`: raw append logs

> 🎨 Colors:
> 🔵 Blue = Incoming
> 🟢 Green = Outgoing
> 🟣 Purple = IP Change
> 🔴 Red = Errors

---

## 🌐 API Endpoints

| Endpoint  | Method | Description                   |
| --------- | ------ | ----------------------------- |
| `/start`  | POST   | Start stealth session         |
| `/status` | GET    | Current IP and mode           |
| `/logs`   | GET    | Recent logs (if not in ghost) |
| `/config` | POST   | Update runtime config         |

Header for requests:

```http
X-Stealth-Key: your-secret-key
```

---

## 🔒 Security

* 🔑 API key-based protection
* 🔄 Ghost mode disables all traces
* ✍️ Code signing planned (future)
* 🧩 Plugin system coming soon

---

## 🛠️ Built With

| Language   | Purpose                              |
| ---------- | ------------------------------------ |
| C          | Packet interception, raw IP morphing |
| C++        | Signal jitter, high-speed logging    |
| Python     | API, terminal UI, orchestration      |
| Go         | Optional API engine (speed)          |
| JavaScript | Frontend (future HTML UI)            |
| Bash       | CLI, installer, flag parsing         |

---

## 📃 License

MIT License. Use it, modify it, vanish with it. Just don’t use it for illegal activities — we don't condone that.

---

## 🤝 Contributing

Contributions are warmly welcome! Here’s how you can help:

- Report bugs or edge cases via [GitHub Issues](https://github.com/nxneeraj/Stealth/issues)
- Suggest new features or CLI improvements
- Submit PRs to enhance logic, UX, or compatibility
- Share use cases, templates, and examples

---

## 📬 Contact

- 👤 **Author**: [Neeraj Sah](https://github.com/nxneeraj)
- 📧 **Email**: neerajsahnx@gmail.com
- 🏴‍☠️ **Org**: [Team HyperGod-X](https://github.com/hypergodx)

---

## ⭐ Support This Project

If this tool helped you:

- ⭐ Star this repo
- 🚀 Share it with fellow hackers
- 🧠 Mention it in your toolkit, blog, or course
- 🔁 Fork and make it even better!

> Build faster. Test smarter. Hack ethically.  
> With 💥 from Team HyperGod-X 👾
<p align="center"><strong> Keep Moving Forward </strong></p>
