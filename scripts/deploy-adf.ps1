<#
.SYNOPSIS
    Deploys an Azure Data Factory ARM template to a target environment.

.DESCRIPTION
    This script deploys the ADF ARM template to the specified Azure resource group
    and Data Factory instance. It is intended to be called from GitHub Actions
    workflows but can also be run locally for testing.

.PARAMETER SubscriptionId
    Azure Subscription ID.

.PARAMETER ResourceGroupName
    Target Azure Resource Group name.

.PARAMETER DataFactoryName
    Target Azure Data Factory name.

.PARAMETER Environment
    Deployment environment: dev | qa | prod.

.PARAMETER TemplateFile
    Path to the ARM template JSON file.

.PARAMETER TemplateParametersFile
    Path to the base ARM template parameters JSON file.

.PARAMETER EnvironmentParametersFile
    Path to the environment-specific parameter override file.

.EXAMPLE
    .\deploy-adf.ps1 `
        -SubscriptionId    "00000000-0000-0000-0000-000000000000" `
        -ResourceGroupName "rg-adf-dev" `
        -DataFactoryName   "adf-dev-yourproject" `
        -Environment       "dev" `
        -TemplateFile      "./factory/ARMTemplateForFactory.json" `
        -TemplateParametersFile      "./factory/ARMTemplateParametersForFactory.json" `
        -EnvironmentParametersFile   "./environments/dev-parameters.json"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string] $SubscriptionId,

    [Parameter(Mandatory = $true)]
    [string] $ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string] $DataFactoryName,

    [Parameter(Mandatory = $true)]
    [ValidateSet("dev", "qa", "prod")]
    [string] $Environment,

    [Parameter(Mandatory = $false)]
    [string] $TemplateFile = "./factory/ARMTemplateForFactory.json",

    [Parameter(Mandatory = $false)]
    [string] $TemplateParametersFile = "./factory/ARMTemplateParametersForFactory.json",

    [Parameter(Mandatory = $false)]
    [string] $EnvironmentParametersFile = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ─── Resolve environment parameters file if not provided ─────────────────────
if ([string]::IsNullOrEmpty($EnvironmentParametersFile)) {
    $EnvironmentParametersFile = "./environments/$Environment-parameters.json"
}

Write-Host "=========================================================="
Write-Host "  ADF Deployment"
Write-Host "  Environment : $Environment"
Write-Host "  Factory     : $DataFactoryName"
Write-Host "  Resource Grp: $ResourceGroupName"
Write-Host "=========================================================="

# ─── Set subscription context ────────────────────────────────────────────────
Write-Host "`n[1/4] Setting Azure subscription context..."
Set-AzContext -SubscriptionId $SubscriptionId | Out-Null

# ─── Validate template files exist ───────────────────────────────────────────
Write-Host "[2/4] Validating template files..."
foreach ($file in @($TemplateFile, $TemplateParametersFile, $EnvironmentParametersFile)) {
    if (-not (Test-Path $file)) {
        throw "Required file not found: $file"
    }
}

# ─── Merge parameters ────────────────────────────────────────────────────────
# Load base parameters and overlay environment-specific values
$baseParams = (Get-Content $TemplateParametersFile | ConvertFrom-Json).parameters
$envParams  = (Get-Content $EnvironmentParametersFile | ConvertFrom-Json).parameters

$mergedParams = @{}
foreach ($key in $baseParams.PSObject.Properties.Name) {
    $mergedParams[$key] = $baseParams.$key.value
}
foreach ($key in $envParams.PSObject.Properties.Name) {
    $mergedParams[$key] = $envParams.$key.value
}
# Always inject the factory name from the env-specific file
$mergedParams["factoryName"] = $DataFactoryName

# ─── Deploy ──────────────────────────────────────────────────────────────────
$deploymentName = "adf-$Environment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Write-Host "[3/4] Deploying ARM template (deployment: $deploymentName)..."

$result = New-AzResourceGroupDeployment `
    -Name                  $deploymentName `
    -ResourceGroupName     $ResourceGroupName `
    -TemplateFile          (Resolve-Path $TemplateFile) `
    -TemplateParameterObject $mergedParams `
    -Mode                  Incremental `
    -Verbose

if ($result.ProvisioningState -ne "Succeeded") {
    throw "Deployment failed with state: $($result.ProvisioningState)"
}

Write-Host "[4/4] ✅ Deployment succeeded: $deploymentName"
Write-Host "=========================================================="
