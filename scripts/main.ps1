﻿[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $Message
)
$Task = ($MyInvocation.MyCommand.Name).split('.')[0]

Write-Verbose "$Task`: Starting..."

Write-Verbose "$Task`: Message: $Message"
Write-Verbose "$Task`: Re modules"
Resolve-Depenencies -Path "src/$ModuleName/$ModuleName.psd1" -Verbos

Write-Verbose "$Task`: Combine files to build module"
Write-Verbose "$Task`: Generate module manifest"
$manifestPath = '.\outputs\test.psd1'
$params = @{
    Path          = $manifestPath
    Guid          = $(New-Guid).Guid
    Author        = 'Marius Storhaug'
    ModuleVersion = '0.0.1'
    Description   = 'Test module'
}
New-Item -Path $manifestPath -Force -ItemType File
New-ModuleManifest @params -Verbose


Write-Verbose "$Task`: Generate module docs"

Write-Verbose "$Task`: Stopping..."


<#
.SYNOPSIS
Resolve dependencies for a module based on the manifest file

.DESCRIPTION
Resolve dependencies for a module based on the manifest file.

.PARAMETER Path
The path to the manifest file.

.EXAMPLE
An example

.NOTES
General notes
#>
function Resolve-Depenencies {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Path
    )

    $Manifest = Invoke-Expression (Get-Content -Path $Path -Raw)
    foreach ($Module in $Manifest.RequiredModules) {
        $InstallParams = @{}

        if ($Module -is [string]) {
            $InstallParams.Name = $Module
        } else {
            $InstallParams.Name = $Module.ModuleName
            $InstallParams.MinimumVersion = $Module.ModuleVersion
            $InstallParams.RequiredVersion = $Module.RequiredVersion
        }
        $InstallParams.Verbose = $false
        $InstallParams.Force = $true

        Write-Verbose 'Installing module:'
        $InstallParams

        Install-Module @InstallParams
    }
}
