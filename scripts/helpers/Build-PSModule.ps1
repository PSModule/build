﻿function Build-PSModule {
    <#
        .SYNOPSIS
        Builds a module.

        .DESCRIPTION
        Builds a module.

        #DECISION: Modules are default located under the '.\src' folder which is the root of the repo.
        #DECISION: Module name = the name of the folder under src. Inherited decision from PowerShell team.
        #DECISION: The module manifest file = name of the folder.
    #>
    [CmdletBinding()]
    param(

        # Name of the module to process.
        [Parameter(Mandatory)]
        [string] $Name,

        # Path to the folder where the modules are located.
        [Parameter(Mandatory)]
        [string] $SourcePath,

        # Path to the folder where the built modules are outputted.
        [Parameter(Mandatory)]
        [string] $ModulesOutputPath,

        # Path to the folder where the documentation is outputted.
        [Parameter(Mandatory)]
        [string] $DocsOutputPath
    )
    #DECISION: The manifest file = name of the folder.
    #DECISION: The basis of the module manifest comes from the defined manifest file.
    #DECISION: Values that are not defined in the module manifest file are generated from reading the module files.
    #DECISION: If no RootModule is defined in the manifest file, we assume a .psm1 file with the same name as the module is on root.
    #DECISION: Currently only Script and Manifest modules are supported.
    #DECISION: The output folder = .\outputs on the root of the repo.
    #DECISION: The module that is build is stored under the output folder in a folder with the same name as the module.
    #DECISION: A new module manifest file is created every time to get a new GUID, so that the specific version of the module can be imported.

    Start-LogGroup "[$Name]"
    Write-Verbose "[$Name] - Source path - [$SourcePath]"
    if (-not (Test-Path -Path $SourcePath)) {
        Write-Error "Source folder not found at [$SourcePath]"
        return
    }
    $sourceFolder = Get-Item -Path $SourcePath

    $moduleOutputFolder = New-Item -Path $ModulesOutputPath -Name $Name -ItemType Directory -Force
    Write-Verbose "[$Name] - Module output folder [$($moduleOutputFolder.FullName)]"
    # Add-PSModulePath -Path $moduleOutputFolder

    Write-Verbose "[$Name] - Docs output folder [$($DocsOutputPath.FullName)]"
    $docsOutputFolder = New-Item -Path $DocsOutputPath -Name $Name -ItemType Directory -Force

    Build-PSModuleBase -SourceFolderPath $sourceFolder -OutputFolderPath $moduleOutputFolder -Name $Name
    Build-PSModuleRootModule -SourceFolderPath $sourceFolder -OutputFolderPath $moduleOutputFolder -Name $Name
    Build-PSModuleManifest -SourceFolderPath $sourceFolder -OutputFolderPath $moduleOutputFolder -Name $Name
    Build-PSModuleDocumentation -SourceFolderPath $moduleOutputFolder -OutputFolderPath $docsOutputFolder -Name $Name

    Write-Verbose "[$Name] - Done"
    Stop-LogGroup
}
