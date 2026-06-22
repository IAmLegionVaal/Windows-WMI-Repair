# Windows WMI Repair

> **Testing note:** This was tested by me to be working. User experience may vary.

Included: `Repair-WindowsWMI.ps1`

```powershell
.\Repair-WindowsWMI.ps1
.\Repair-WindowsWMI.ps1 -Repair
```

The default mode verifies the WMI repository and performs a CIM query test. Repair mode starts WMI when needed and resynchronises WMI performance classes. Changes support `-WhatIf`.

Logs: `C:\ProgramData\WindowsWMIRepair\Logs`

Exit codes: `0` success, `1` fatal error.

Use at your own risk. The script does not reset or delete the WMI repository.

MIT License.
