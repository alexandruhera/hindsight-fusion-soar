# 🕵️‍♂️ Hindsight Forensic Workflow

This repository delivers an automated, on-demand forensic workflow built with **CrowdStrike RTR** and Slack integration. It leverages the open-source tool **Hindsight** to extract, convert, and deliver browser artifacts from Windows endpoints in real time.

Ideal for DFIR practitioners, SOC engineers, and threat responders.

---

## ⚙️ Workflow Overview

This workflow performs the following:

1. **Platform Validation** – Confirms the target device runs Windows OS  
2. **Tool Delivery** – Deploys `hindsight.exe` to a designated working directory  
3. **Artifact Extraction** – Runs `hindsight-processing.ps1` to parse Chrome, Edge, or Brave data into `xlsx`, `jsonl`, or `sqlite`  
4. **Polling Loop** – Waits up to 15 minutes (15 attempts) for output ZIP generation with retry-on-error logic  
5. **Result Collection** – Fetches the ZIP archive and cleans the temporary directory  
6. **Slack Reporting** – Sends clear, structured notifications throughout the process  

---

## 🧠 Why This Design Works

- **Resilient Automation** – Built-in retry logic ensures delivery even with intermittent failures  
- **Operational Transparency** – Slack alerts for start, exception, and success states  
- **Variable-Driven Flexibility** – No hardcoded paths; all flow through managed variables  
- **Composable** – Easily integrates into larger workflows or used independently  

---

## ✅ Prerequisites

- Active CrowdStrike Real Time Response (RTR) access  
- Slack webhook credentials  
- Access to the `hindsight.exe` binary  

---

## 🔧 Trigger Parameters

| Parameter           | Description                                   | Required | Example         |
|--------------------|-----------------------------------------------|----------|-----------------|
| `deviceID`         | 32-character CrowdStrike Sensor ID            | ✅       | A1B2C3D4...     |
| `selected_browser` | Browser to analyze (`Chrome`, `Edge`, `Brave`) | ✅       | Google Chrome   |
| `output_format`    | Output type (`xlsx`, `jsonl`, `sqlite`)       | ✅       | xlsx            |

---

## 📬 Slack Integration

Slack notifications provide three distinct insights:
- **Trigger Summary** – Initiator and parameters used  
- **Error Reporting** – If any exceptions are thrown  
- **Completion Notice** – Includes ZIP filename and host details  

---

## ✨ Contributors

Crafted with care by [@Alexandru Hera](https://www.linkedin.com/in/alexandruhera), bringing precision, speed, and elegance to forensic automation — designed for deep CrowdStrike integration.

---

## 🛠️ Acknowledgements

- [CrowdStrike Falcon RTR](https://www.crowdstrike.com)  
- [Hindsight by obsidianforensics](https://github.com/obsidianforensics/hindsight)
