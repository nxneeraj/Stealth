# Stealth Architecture Document

## 1. Introduction

This document outlines the software architecture of the Stealth Network Cloaking Engine. It describes the major components, their responsibilities, interactions, and the technologies used.

## 2. Goals and Constraints

* **Modularity:** Components should be loosely coupled and independently maintainable/upgradable.
* **Performance:** Low-level network operations (IP morphing, packet handling) should be efficient.
* **Extensibility:** Easy to add new features, proxy types, or UI elements.
* **Portability:** While some core features are Linux-specific (e.g., `libnetfilter_queue`), the overall design aims for adaptability.
* **Security:** API authentication, careful handling of privileges.

## 3. System Overview (Logical View)

Stealth consists of the following primary logical components:

* **Core Network Engine:** Responsible for all low-level network manipulations.
* **Control & Orchestration Layer:** Manages the lifecycle and configuration of the core engine.
* **API Layer:** Exposes control and data to external applications.
* **User Interface Layer:** Provides user interaction and real-time feedback.
* **Logging & Persistence Layer:** Handles event logging and data storage.

*(A diagram here would be very useful, e.g., using PlantUML, Mermaid, or a drawing tool)*

```mermaid
graph TD
    User -->|CLI Flags| CLI[Bash CLI: stealth.sh]
    CLI -->|Orchestrates| CoreDaemon[Core C/C++ Daemon(s)]
    CLI -->|Starts/Manages| API[Python FastAPI Server]
    
    CoreDaemon -->|IP Morphing Logic| NetworkStack[Host Network Stack]
    CoreDaemon -->|Packet Interception| NetworkStack
    CoreDaemon -->|Signal Shifting Logic| NetworkStack
    CoreDaemon -->|Logs Events| LoggerCpp[C++ Logger: text/JSON]

    API -->|Controls/Queries| CoreDaemonInterface[Interface to Core (IPC/Signal/File)]
    API -->|Serves Data| ExternalApp[External Applications]
    API -->|Reads Logs| LogFiles[logs/stealth.json]
    
    TerminalUI[Python Rich UI] -->|Reads Logs/Status| API
    TerminalUI -->|Sends Commands (conceptual)| API
    
    LoggerCpp -->|Writes| TextLog[logs/stealth.log]
    PythonJsonLogger[logging/json_logger.py] -->|Writes| JsonLog[logs/stealth.json]
    CLI -->|Calls| PythonJsonLogger
    CoreDaemon -->|Can Call Wrapper for| PythonJsonLogger

    subgraph "Core Engine (C/C++)"
        direction LR
        IPMorph[IP Morphing Module (C)]
        PacketIntercept[Packet Interception (C)]
        SignalShift[Signal Shifting (C++)]
        LoggerCpp
    end

    CoreDaemon <--> IPMorph
    CoreDaemon <--> PacketIntercept
    CoreDaemon <--> SignalShift