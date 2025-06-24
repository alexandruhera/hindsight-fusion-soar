

# 🕵️‍♂️ Hindsight Forensic Workflow

This repository provides a modular, fully automated forensic analysis pipeline designed for use with **CrowdStrike Falcon Real Time Response (RTR)**. It leverages **Hindsight**, an open-source browser artifact parser, to extract, convert, and collect browser history from remote Windows endpoints — with real-time visibility via **Slack alerts**.

Ideal for:
- Digital forensic analysts conducting targeted history captures
- SOC engineers building adaptive incident response playbooks
- Threat hunters pivoting off browser-based behavior

---

## ⚙️ Workflow Overview

This workflow is composed of six tightly integrated phases:

1. **Platform Validation**  
   - Automatically validates that the targeted device is online and running **Windows OS**
   - Gathers hostname, platform type, and available tags from Falcon API

2. **Tool Deployment**  
   - Dynamically sets a custom working directory on the remote device (e.g., `C:\hindsight`)  
   - Securely uploads `hindsight.exe` to that folder via RTR's **Put File**  
   - Prepares any supporting environment variables or folders

3. **Browser Artifact Extraction**  
   - Executes a custom PowerShell script (`hindsight-processing.ps1`) on the endpoint  
   - Extracts browser artifacts (Chrome, Edge, Brave) and converts to the chosen format:  
     - `.xlsx` for easy analysis  
     - `.jsonl` for structured parsing  
     - `.sqlite` for raw queryability  
   - Captures the browser profile names in use (for context)

4. **Resilient Polling & Collection Loop**  
   - Starts a **15-minute polling loop** (15 total attempts, 1 min max intervals)  
   - If extraction succeeds: retrieves a ZIP archive of results  
   - If a script exception occurs: Slack is notified, and retry logic is activated  
   - Gracefully exits the loop once data is collected or time runs out

5. **Artifact Retrieval & Cleanup**  
   - Uses RTR’s **Get File** to fetch the packaged ZIP archive from the remote device  
   - Deletes the temporary working directory and files used during execution  

6. **Slack Notification System**  
   - Sends Slack alerts at key stages:
     - **Run Initiation** – who ran the workflow and what inputs were selected  
     - **Exception Alerts** – if Hindsight or the preparation step fails  
     - **Completion Report** – device name, user email, ZIP filename, and success flag

---

## 🧠 Why This Design Works

- **Self-healing reliability** – Built-in conditional checks and looping ensure success even on first-time setup or slow endpoints  
- **Zero hardcoding** – Paths, formats, and browsers are fully parameterized using workflow variables  
- **Plug-and-play** – Can be invoked manually or embedded as a module within broader DFIR playbooks  
- **Operator-aware** – All Slack messages include runner identity and device metadata  

---

## ✅ Prerequisites

Make sure the following are set up prior to execution:

- CrowdStrike Falcon RTR access (with file upload & script execution permissions)  
- A Slack App with a webhook URL and appropriate channel permissions  
- Local copy of `hindsight.exe` (from [obsidianforensics](https://github.com/obsidianforensics/hindsight/releases))  

---

## 🔧 Trigger Parameters

These inputs define the scope and output of each run:

| Parameter           | Description                                       | Required | Example         |
|--------------------|---------------------------------------------------|----------|-----------------|
| `deviceID`         | 32-character CrowdStrike Sensor ID                | ✅       | A1B2C3D4E5F6... |
| `selected_browser` | Target browser (`Google Chrome`, `Microsoft Edge`, `Brave`) | ✅ | Google Chrome   |
| `output_format`    | Output format (`xlsx`, `jsonl`, `sqlite`)         | ✅       | xlsx            |

---

## 📬 Slack Integration

Slack updates are sent via webhook and include:

- 📥 **Trigger Summary** – Who initiated the workflow and selected parameters  
- ⚠️ **Error Notices** – Clearly formatted exception output from PowerShell scripts  
- ✅ **Completion Report** – Includes device hostname, ZIP filename, and sensor tags  

---

## ✨ Contributors

Crafted by [@Alexandru Hera](https://www.linkedin.com/in/alexandruhera), with a passion for delivering fast, auditable forensic tooling that integrates tightly with the CrowdStrike ecosystem.

---

## 🛠️ Acknowledgements

- [CrowdStrike Falcon RTR](https://www.crowdstrike.com)  
- [Hindsight by obsidianforensics](https://github.com/obsidianforensics/hindsight)

---

Example:

![hind11](https://github.com/user-attachments/assets/ec2452e9-c503-460a-a0e4-4777755b65d4)

![hind12](https://github.com/user-attachments/assets/385575a4-0480-46f0-ba74-76ba2ec5f374)

