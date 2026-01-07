# windows-startup-audit
Captures a snapshot of common startup vectors: - Registry Run keys (HKCU, HKLM, WOW6432Node) - Startup folders (current user and ProgramData) - Scheduled tasks (basic action listing)

# Windows Startup Audit (PowerShell)

Captures a snapshot of common startup vectors:
- Registry Run keys (HKCU, HKLM, WOW6432Node)
- Startup folders (current user and ProgramData)
- Scheduled tasks (basic action listing)

Outputs JSON for diffing across boots or before/after installs.

## Requirements

- Windows
- PowerShell 5.1 or PowerShell 7+

## Usage

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\Startup-Audit.ps1
Optional:

powershell
Copy code
.\Startup-Audit.ps1 -OutDir .\snapshots
