﻿function Get-PSModuleVariablesToExport {
    <#
        .SYNOPSIS
        Gets the variables to export from the module manifest.

        .DESCRIPTION
        This function will get the variables to export from the module manifest.

        .EXAMPLE
        Get-PSModuleVariablesToExport -SourceFolderPath 'C:\MyModule\src\MyModule'
    #>
    [OutputType([Collections.Generic.List[string]])]
    [CmdletBinding()]
    param(
        # Path to the folder where the module source code is located.
        [Parameter(Mandatory)]
        [string] $SourceFolderPath
    )

    $manifestPropertyName = 'VariablesToExport'

    Write-Verbose "[$manifestPropertyName]"

    $variableFolderPath = Join-Path -Path $SourceFolderPath -ChildPath 'public'
    $scriptFilePaths = Get-ChildItem -Path $variableFolderPath -Recurse -File -Filter *.ps1 | Select-Object -ExpandProperty FullName

    $variablesToExport = [Collections.Generic.List[string]]::new()
    $scriptFilePaths | ForEach-Object {
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($_, [ref]$null, [ref]$null)
        $variables = Get-RootLevelVariable -Ast $ast
        $variablesToExport.Add($variables)
    }

    $variablesToExport | ForEach-Object {
        Write-Verbose "[$manifestPropertyName] - [$_]"
    }

    $variablesToExport
}

