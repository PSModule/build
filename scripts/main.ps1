﻿#REQUIRES -Modules Utilities

[CmdletBinding()]
param()

$path = (Join-Path -Path $PSScriptRoot -ChildPath 'helpers')
LogGroup "Loading helper scripts from [$path]" {
    Get-ChildItem -Path $path -Filter '*.ps1' -Recurse | ForEach-Object {
        Write-Verbose "[$($_.FullName)]"
        . $_.FullName
    }
}

Start-LogGroup 'Loading inputs'
$moduleName = ($env:GITHUB_ACTION_INPUT_Name | IsNullOrEmpty) ? $env:GITHUB_REPOSITORY_NAME : $env:GITHUB_ACTION_INPUT_Name
Write-Verbose "Module name:         [$moduleName]"

$moduleSourceFolderPath = Join-Path -Path $env:GITHUB_WORKSPACE -ChildPath $env:GITHUB_ACTION_INPUT_Path $moduleName
if (-not (Test-Path -Path $moduleSourceFolderPath)) {
    $moduleSourceFolderPath = Join-Path -Path $env:GITHUB_WORKSPACE -ChildPath $env:GITHUB_ACTION_INPUT_Path
}
Write-Verbose "Source module path:  [$moduleSourceFolderPath]"
if (-not (Test-Path -Path $moduleSourceFolderPath)) {
    throw "Module path [$moduleSourceFolderPath] does not exist."
}

$modulesOutputFolderPath = Join-Path $env:GITHUB_WORKSPACE $env:GITHUB_ACTION_INPUT_ModulesOutputPath
Write-Verbose "Modules output path: [$modulesOutputFolderPath]"
$docsOutputFolderPath = Join-Path $env:GITHUB_WORKSPACE $env:GITHUB_ACTION_INPUT_DocsOutputPath
Write-Verbose "Docs output path:    [$docsOutputFolderPath]"
Stop-LogGroup
$params = @{
    ModuleName              = $moduleName
    ModuleSourceFolderPath  = $moduleSourceFolderPath
    ModulesOutputFolderPath = $modulesOutputFolderPath
    DocsOutputFolderPath    = $docsOutputFolderPath
}
Build-PSModule @params
