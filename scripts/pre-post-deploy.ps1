<#
.SYNOPSIS
    Stops or starts all triggers in an Azure Data Factory instance.

.DESCRIPTION
    Must be called BEFORE a deployment (Action = "stop") and AFTER
    a deployment (Action = "start") to avoid trigger conflicts during
    ARM template updates.

.PARAMETER ResourceGroupName
    Azure Resource Group containing the Data Factory.

.PARAMETER DataFactoryName
    Name of the Azure Data Factory instance.

.PARAMETER Action
    "stop"  – Stops all active triggers and saves their names to a temp file.
    "start" – Reads the saved trigger list and restarts each one.

.EXAMPLE
    # Before deployment
    .\pre-post-deploy.ps1 -ResourceGroupName "rg-adf-dev" -DataFactoryName "adf-dev-project" -Action "stop"

    # After deployment
    .\pre-post-deploy.ps1 -ResourceGroupName "rg-adf-dev" -DataFactoryName "adf-dev-project" -Action "start"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string] $ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string] $DataFactoryName,

    [Parameter(Mandatory = $true)]
    [ValidateSet("stop", "start")]
    [string] $Action
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Temp file to persist trigger names between stop and start steps
$triggerListFile = [System.IO.Path]::Combine($env:TEMP ?? "/tmp", "adf_active_triggers.txt")

# ─── STOP ────────────────────────────────────────────────────────────────────
if ($Action -eq "stop") {
    Write-Host "Fetching all triggers from '$DataFactoryName'..."

    $triggers = Get-AzDataFactoryV2Trigger `
        -ResourceGroupName $ResourceGroupName `
        -DataFactoryName   $DataFactoryName

    $activeTriggers = $triggers | Where-Object { $_.RuntimeState -eq "Started" }

    if ($activeTriggers.Count -eq 0) {
        Write-Host "No active triggers found – nothing to stop."
        Set-Content -Path $triggerListFile -Value ""
        exit 0
    }

    Write-Host "Stopping $($activeTriggers.Count) trigger(s)..."
    $triggerNames = @()

    foreach ($trigger in $activeTriggers) {
        Write-Host "  Stopping trigger: $($trigger.Name)"
        Stop-AzDataFactoryV2Trigger `
            -ResourceGroupName $ResourceGroupName `
            -DataFactoryName   $DataFactoryName `
            -Name              $trigger.Name `
            -Force | Out-Null
        $triggerNames += $trigger.Name
    }

    # Persist so the "start" step knows which ones to restart
    Set-Content -Path $triggerListFile -Value ($triggerNames -join "`n")
    Write-Host "✅ All active triggers stopped. List saved to: $triggerListFile"
}

# ─── START ────────────────────────────────────────────────────────────────────
if ($Action -eq "start") {
    if (-not (Test-Path $triggerListFile)) {
        Write-Host "Trigger list file not found – skipping restart."
        exit 0
    }

    $triggerNames = Get-Content $triggerListFile | Where-Object { $_ -ne "" }

    if ($triggerNames.Count -eq 0) {
        Write-Host "No triggers to restart."
        exit 0
    }

    Write-Host "Restarting $($triggerNames.Count) trigger(s)..."

    foreach ($name in $triggerNames) {
        Write-Host "  Starting trigger: $name"
        Start-AzDataFactoryV2Trigger `
            -ResourceGroupName $ResourceGroupName `
            -DataFactoryName   $DataFactoryName `
            -Name              $name `
            -Force | Out-Null
    }

    Remove-Item -Path $triggerListFile -Force
    Write-Host "✅ All triggers restarted."
}
