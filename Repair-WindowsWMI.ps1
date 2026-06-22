<#
.SYNOPSIS
Checks WMI health and restores stopped WMI service operation.
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param([switch]$Repair,[string]$LogRoot="$env:ProgramData\WindowsWMIRepair\Logs")

Set-StrictMode -Version 2.0
$ErrorActionPreference='Stop'
$runPath=Join-Path $LogRoot (Get-Date -Format 'yyyyMMdd_HHmmss')
$warnings=New-Object System.Collections.Generic.List[string]

function Test-Admin{
    $id=[Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-Winmgmt{
    param([string]$Name,[string[]]$Arguments)
    $path=Join-Path $runPath ($Name+'.txt')
    winmgmt.exe @Arguments 2>&1|Out-File $path
    $code=$LASTEXITCODE
    if($code -ne 0){$script:warnings.Add("$Name returned $code")}
    $code
}

try{
    if($env:OS -ne 'Windows_NT'){throw 'Windows is required.'}
    if($Repair -and -not(Test-Admin)){throw 'Run PowerShell as Administrator for repair mode.'}
    New-Item $runPath -ItemType Directory -Force|Out-Null

    Get-Service Winmgmt -ErrorAction Stop|Select-Object Name,Status,StartType|
        Export-Csv (Join-Path $runPath 'WmiService-Before.csv') -NoTypeInformation
    [void](Invoke-Winmgmt 'RepositoryVerification-Before' @('/verifyrepository'))

    try{
        Get-CimInstance Win32_OperatingSystem -ErrorAction Stop|Select-Object Caption,Version,BuildNumber|
            Export-Csv (Join-Path $runPath 'CimTest-Before.csv') -NoTypeInformation
    }catch{
        $warnings.Add("Initial CIM query failed: $($_.Exception.Message)")
    }

    if($Repair -and $PSCmdlet.ShouldProcess('Windows Management Instrumentation','Start service and resynchronise performance classes')){
        Set-Service Winmgmt -StartupType Automatic -ErrorAction Stop
        $service=Get-Service Winmgmt -ErrorAction Stop
        if($service.Status -ne 'Running'){Start-Service Winmgmt -ErrorAction Stop}

        [void](Invoke-Winmgmt 'ResyncPerformance' @('/resyncperf'))
    }

    $afterService=Get-Service Winmgmt -ErrorAction Stop
    $afterService|Select-Object Name,Status,StartType|
        Export-Csv (Join-Path $runPath 'WmiService-After.csv') -NoTypeInformation

    try{
        Get-CimInstance Win32_OperatingSystem -ErrorAction Stop|Select-Object Caption,Version,BuildNumber|
            Export-Csv (Join-Path $runPath 'CimTest-After.csv') -NoTypeInformation
    }catch{
        $warnings.Add("Final CIM query failed: $($_.Exception.Message)")
    }

    [void](Invoke-Winmgmt 'RepositoryVerification-After' @('/verifyrepository'))

    if($Repair -and $afterService.Status -ne 'Running'){$warnings.Add('WMI service is not running after repair.')}
    if($Repair -and $afterService.StartType -eq 'Disabled'){$warnings.Add('WMI service remains disabled after repair.')}

    $warnings|Out-File (Join-Path $runPath 'Warnings.txt') -Encoding UTF8
    if($warnings.Count -gt 0){Write-Host "[WARN] Completed with warnings. Logs: $runPath" -ForegroundColor Yellow;exit 2}
    Write-Host "[OK] Completed. Logs: $runPath" -ForegroundColor Green;exit 0
}catch{Write-Error $_.Exception.Message;exit 1}
