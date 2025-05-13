**`stealth/docs/api_reference.md`**
# Stealth API Reference

Version: 0.1.0 (as per Python API)
Base URL for Python API: `http://<host>:<port>/api/v1` (Default: `http://localhost:8080/api/v1`)

## Authentication

All API endpoints (unless otherwise specified) require an API key for authentication. The API key must be passed in the `X-Stealth-Key` HTTP header.

* **Header:** `X-Stealth-Key: <your_api_key>`

Failure to provide a valid API key will result in a `403 Forbidden` error. The API key is typically set using the `STEALTH_API_KEY` environment variable when launching the API server.

## Endpoints

---

### 1. Status Endpoints

#### `GET /status`

Retrieves the current operational status of the Stealth engine.

* **Method:** `GET`
* **Path:** `/api/v1/status`
* **Authentication:** Required.
* **Responses:**
    * `200 OK`: Successful retrieval.
        * **Body (`application/json`):** `StatusResponse`
            ```json
            {
              "current_ip": "192.168.1.150",
              "next_rotation_in_seconds": 45,
              "mode": "default", // "default" or "ghost"
              "api_status": "active",
              "version": "0.1.0",
              "message": "Status retrieved successfully."
            }
            ```
    * `403 Forbidden`: Authentication failed.

---

### 2. Control Endpoints

#### `POST /start`

Attempts to start or ensure the Stealth engine is running. Can accept configuration parameters to apply on start.

* **Method:** `POST`
* **Path:** `/api/v1/start`
* **Authentication:** Required.
* **Request Body (`application/json`, optional):** `ConfigUpdateRequest`
    ```json
    {
      "interval_seconds": 60, // optional
      "proxy_host": "127.0.0.1", // optional
      "proxy_port": 9050, // optional, requires proxy_host
      "ghost_mode": false // optional
    }
    ```
* **Responses:**
    * `200 OK`: Command issued successfully.
        * **Body (`application/json`):** `CommandResponse`
            ```json
            {
              "success": true,
              "message": "Stealth engine start command issued. Check system logs/status for confirmation.",
              "details": {"args_used": ["-t", "60"]}
            }
            ```
    * `403 Forbidden`: Authentication failed.
    * `422 Unprocessable Entity`: Invalid request body.

#### `POST /stop`

Attempts to stop the Stealth engine.

* **Method:** `POST`
* **Path:** `/api/v1/stop`
* **Authentication:** Required.
* **Responses:**
    * `200 OK`: Command issued successfully.
        * **Body (`application/json`):** `CommandResponse`
            ```json
            {
              "success": true,
              "message": "Stealth engine stop command issued."
            }
            ```
    * `403 Forbidden`: Authentication failed.

#### `POST /rotate_ip_now`

Triggers an immediate IP rotation in the running Stealth engine.

* **Method:** `POST`
* **Path:** `/api/v1/rotate_ip_now`
* **Authentication:** Required.
* **Responses:**
    * `200 OK`: Command issued successfully.
        * **Body (`application/json`):** `CommandResponse`
            ```json
            {
              "success": true,
              "message": "IP rotation command issued (simulated)." // Message may vary
            }
            ```
    * `403 Forbidden`: Authentication failed.

---

### 3. Configuration Endpoints

#### `GET /config`

Retrieves the current configuration of the Stealth engine.

* **Method:** `GET`
* **Path:** `/api/v1/config`
* **Authentication:** Required.
* **Responses:**
    * `200 OK`: Successful retrieval.
        * **Body (`application/json`):** `ConfigResponse`
            ```json
            {
              "interval_seconds": 60,
              "proxy_host": "127.0.0.1", // null if not set
              "proxy_port": 9050,       // null if not set
              "ghost_mode": false,
              "log_level": "INFO"
            }
            ```
    * `403 Forbidden`: Authentication failed.

#### `POST /config`

Updates the Stealth engine's configuration dynamically. The extent of dynamic reconfiguration depends on the core engine's capabilities.

* **Method:** `POST`
* **Path:** `/api/v1/config`
* **Authentication:** Required.
* **Request Body (`application/json`):** `ConfigUpdateRequest`
    ```json
    {
      "interval_seconds": 120,      // optional
      "proxy_host": "proxy.example.com", // optional
      "proxy_port": 8080,          // optional, requires proxy_host
      "ghost_mode": true,          // optional
      "log_level": "DEBUG"         // optional
    }
    ```
* **Responses:**
    * `200 OK`: Configuration update accepted. Returns the new effective configuration.
        * **Body (`application/json`):** `ConfigResponse` (reflecting the applied changes)
    * `403 Forbidden`: Authentication failed.
    * `422 Unprocessable Entity`: Invalid request body or unsupported configuration change.

---

### 4. Logging Endpoints

#### `GET /logs`

Retrieves recent log entries.

* **Method:** `GET`
* **Path:** `/api/v1/logs`
* **Authentication:** Required.
* **Query Parameters:**
    * `limit` (integer, optional, default: 100): Maximum number of log entries to return. Max 1000.
    * `source` (string, optional, default: "json"): Log source, either "json" or "text".
* **Responses:**
    * `200 OK`: Successful retrieval.
        * **Body (`application/json`):** `LogsResponse`
            ```json
            // Example for source=json
            {
              "logs": [
                {
                  "timestamp": "2024-05-12T10:30:00Z",
                  "level": "IP_CHANGE",
                  "message": "IP successfully changed.",
                  "details": {"old_ip": "1.1.1.1", "new_ip": "2.2.2.2"}
                },
                // ... more log entries
              ],
              "count": 1 // Number of logs returned
            }
            ```
    * `400 Bad Request`: Invalid query parameters (e.g., invalid `source`).
    * `403 Forbidden`: Authentication failed.
    * `500 Internal Server Error`: Error reading log files.

---

## Data Models (Pydantic Schemas from `api/python/models.py`)

*(This section would typically list the detailed structure of request and response models like `StatusResponse`, `ConfigUpdateRequest`, `LogEntry`, etc. For brevity, refer to `api/python/models.py` for these definitions. The examples above illustrate their usage.)*

### `StatusResponse`
  * `current_ip: Optional[str]`
  * `next_rotation_in_seconds: Optional[int]`
  * `mode: str`
  * `api_status: str`
  * `version: str`
  * `message: Optional[str]`

### `LogEntry`
  * `timestamp: str`
  * `level: str`
  * `message: str`
  * `details: Optional[Dict[str, Any]]`

### `LogsResponse`
  * `logs: List[LogEntry]`
  * `count: int`

### `ConfigUpdateRequest`
  * `interval_seconds: Optional[int]`
  * `proxy_host: Optional[str]`
  * `proxy_port: Optional[int]`
  * `ghost_mode: Optional[bool]`
  * `log_level: Optional[str]`

### `ConfigResponse`
  * `interval_seconds: int`
  * `proxy_host: Optional[str]`
  * `proxy_port: Optional[int]`
  * `ghost_mode: bool`
  * `log_level: str`

### `CommandResponse`
  * `success: bool`
  * `message: str`
  * `details: Optional[Dict[str, Any]]`

---

## Notes for Go and Node.js API Implementations

The Go (`api/go/server.go`) and Node.js (`api/js/index.js`) API servers are provided as placeholders. They implement a subset of the functionality (e.g., a basic `/status` endpoint) and may use different default ports or API key environment variables (e.g., `STEALTH_GO_API_KEY`, `STEALTH_JS_API_KEY`).

If these alternative APIs are fully developed, their specific endpoints, authentication mechanisms, and data models should be documented here separately or in their respective subdirectories. The primary API reference above pertains to the Python/FastAPI implementation.
