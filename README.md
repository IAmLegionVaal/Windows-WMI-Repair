# Windows WMI Repair

> **Testing note:** This was tested by me to be working. User experience may vary.

Included: `Repair-WindowsWMI.ps1`

```powershell
.\Repair-WindowsWMI.ps1
.\Repair-WindowsWMI.ps1 -Repair
.\Repair-WindowsWMI.ps1 -Repair -WhatIf
```

The default mode verifies the WMI repository and performs a CIM query test. Repair mode requires administrator rights, starts WMI when needed, resynchronises WMI performance classes, and then repeats the repository and CIM checks.

Logs: `C:\ProgramData\WindowsWMIRepair\Logs`

Exit codes: `0` success, `1` fatal error, `2` repair or verification warnings.

Use at your own risk. The script does not reset, salvage or delete the WMI repository.

MIT License.
