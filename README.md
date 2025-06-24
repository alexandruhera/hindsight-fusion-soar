# 🕵️‍♂️ Hindsight Forensic Workflow

This repository contains an automated, on-demand forensic workflow powered by **CrowdStrike RTR** and Slack integration. It leverages the open-source tool **Hindsight** to extract, convert, and retrieve browser artifacts from endpoints in real time.

Designed for DFIR specialists, SOC engineers, and detection responders.

+--------------------+
|  On-Demand Trigger |
| - deviceID         |
| - browser          |
| - output_format    |
+---------+----------+
          |
          v
+----------------------+
| Get Device Details   |
+----------+-----------+
           |
           v
+----------------------------+
| If Platform == Windows     |
+-------------+--------------+
              |
              v
+-------------------------------+
| Create forensic path variable |
+-------------+----------------+
              |
              v
+------------------------+
| Preparation Script     |
| - Sets path            |
| - Checks errors        |
+-------------+----------+
              |
         +----+----+
         | Success |
         v
+-------------------+      +---------------------+
| Upload hindsight  | ---> | Run Hindsight tool  |
+-------------------+      | - Check errors      |
                           +----------+----------+
                                      |
                       +--------------+--------------+
                       |          Success            |
                       v                             v
        +----------------------------+     +---------------------------+
        | Send param details to Slack|     | Trigger Result Collection |
        +----------------------------+     | in Loop (max 15 min)      |
                                           +-------------+-------------+
                                                         |
                              +--------------------------+--------------------------+
                              |  Run Collection Script   |     If Errors: Retry/Sleep|
                              +-------------+------------+--------------------------+
                                            |
                                            v
                               +-------------------------+
                               | Update zip_file_path    |
                               +-----------+-------------+
                                           |
                                           v
                               +-------------------------+
                               | Get File from endpoint  |
                               +-----------+-------------+
                                           |
                                           v
                               +-------------------------+
                               | Remove temp directory   |
                               +-----------+-------------+
                                           |
                                           v
                              +--------------------------+
                              | Send Slack Final Message |
                              +--------------------------+
---

## ⚙️ Workflow Summary

This workflow performs:

1. **Device Validation**: Ensures the target endpoint is Windows-based.
2. **Tool Deployment**: Pushes `hindsight.exe` to a secure working directory on the device.
3. **Browser Artifact Extraction**: Uses `hindsight-processing.ps1` to parse Chrome, Edge, or Brave data into your desired format: `xlsx`, `jsonl`, or `sqlite`.
4. **Resilient Polling Loop**: Waits up to 15 minutes (15 tries) for ZIP file creation, with error-triggered retry logic.
5. **Artifact Retrieval**: Grabs the final ZIP result and clears temp directories.
6. **Slack Notifications**: Provides actionable updates at every major step.

---

## 🧠 Why It’s Built This Way

- **Self-healing logic**: Polling loop with retry backoff ensures end-to-end artifact delivery.
- **External observability**: Slack alerts (trigger, exception, completion) make every run transparent.
- **Dynamic + portable**: Uses workflow variables for pathing, no hardcoded values.
- **Modular**: Designed to drop into broader playbooks, or stand alone.

---

## ✅ Requirements

- Active CrowdStrike RTR access
- Slack webhook credentials
- `hindsight.exe` binary

---

## 🔧 Trigger Parameters

| Parameter         | Description                                | Required | Example                |
|------------------|--------------------------------------------|----------|------------------------|
| `deviceID`        | 32-char Sensor ID                          | ✅        | A1B2C3D4...            |
| `selected_browser`| Browser to analyze (`Chrome`, `Edge`, `Brave`) | ✅    | `Google Chrome`        |
| `output_format`   | Export format (`xlsx`, `jsonl`, `sqlite`) | ✅        | `xlsx`                 |

---

## 📬 Slack Notifications

Three types of alerts are sent via Slack:
- **Trigger Summary**: Who ran it and with what inputs
- **Failure Warnings**: If any script raises exceptions
- **Completion Report**: Includes hostname, ZIP filename, and metadata
---

## ✨ Contributors

Brought to you by [@Alexandru](#) and built to make forensic automation beautiful, scalable, and CrowdStrike-native.

---

## 🛠️ Inspired By

- [CrowdStrike Falcon Real Time Response](https://www.crowdstrike.com)
- [Hindsight by obsidianforensics](https://github.com/obsidianforensics/hindsight)
