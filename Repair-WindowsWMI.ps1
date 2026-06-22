<#
.SYNOPSIS
Checks WMI health and restores stopped WMI service operation.
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param([switch]$Repair,[string]$LogRoot="$env:ProgramData\WindowsWMIRepair\Logs")

Set-StrictMode -Version 2.0
$ErrorActionPreference='Stop'
$runPath=Join-Path $LogRoot (Get-Date -Format 'yyyyMMdd_HHmmss')

try{
    if($env:OS -ne 'Windows_NT'){throw 'Windows is required.'}
    New-Item $runPath -ItemType Directory -Force|Out-Null

    Get-Service Winmgmt|Select-Object Name,Status,StartType|
        Export-Csv (Join-Path $runPath 'WmiService-Before.csv') -NoTypeInformation
    winmgmt.exe /verifyrepository 2>&1|Out-File (Join-Path $runPath 'RepositoryVerification.txt')
    Get-CimInstance Win32_OperatingSystem|Select-Object Caption,Version,BuildNumber|
        Export-Csv (Join-Path $runPath 'CimTest.csv') -NoTypeInformation

    if($Repair -and $PSCmdlet.ShouldProcess('Windows Management Instrumentation','Start service and resynchronise performance classes')){
        Start-Service Winmgmt -ErrorAction SilentlyContinue
        winmgmt.exe /resyncperf 2>&1|Out-File (Join-Path $runPath 'ResyncPerformance.txt')
    }

    Get-Service Winmgmt|Select-Object Name,Status,StartType|
        Export-Csv (Join-Path $runPath 'WmiService-After.csv') -NoTypeInformation
    Write-Host "[OK] Completed. Logs: $runPath" -ForegroundColor Green
    exit 0
}catch{Write-Error $_.Exception.Message;exit 1}
