# Windows WMI Repair

> **Testing note:** This was tested by me to be working. User experience may vary.

## One-click use

1. Download and extract the repository.
2. Double-click `Run-OneClick.bat`.
3. Approve the Windows administrator prompt.
4. The launcher checks the WMI repository, restores the service, resynchronises performance classes and repeats validation. There is no menu.
5. Review the exit code and logs in `C:\ProgramData\WindowsWMIRepair\Logs`.

Included: `Repair-WindowsWMI.ps1`

## PowerShell usage

```powershell
.\Repair-WindowsWMI.ps1
.\Repair-WindowsWMI.ps1 -Repair
.\Repair-WindowsWMI.ps1 -Repair -WhatIf
```

The default mode verifies the WMI repository and performs a CIM query test. Repair mode requires administrator rights, starts WMI when needed, resynchronises WMI performance classes, and then repeats the repository and CIM checks.

Exit codes: `0` success, `1` fatal error, `2` repair or verification warnings.

Use at your own risk. The script does not reset, salvage or delete the WMI repository.

MIT License.
