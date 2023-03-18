function NewSidebarIncludeFile() {
    <#
        .SYNOPSIS
            Generates a `.js` file holding an array with all .mdx 'ids` to be imported in Docusaurus `sidebar.js`.

        .LINK
            https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-powershell-1.0/ff730948(v=technet.10)
    #>
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "Sidebar",
        Justification = 'False positive as rule does not scan child scopes')]
    param(
        [Parameter(Mandatory = $True)][string]$TempFolder,
        [Parameter(Mandatory = $True)][string]$OutputFolder,
        [Parameter(Mandatory = $True)][string]$Sidebar,
        [Parameter(Mandatory = $True)][Object]$MarkdownFiles,
        [Parameter(Mandatory = $True)][Version]$Alt3Version
    )

    GetCallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    Write-Verbose "Generating docusaurus.sidebar.js"

    # generate a list of PowerShell commands by stripping .md from the generated PlatyPs files
    [array]$commands = $MarkdownFiles | Select-Object @{ Name = "PowerShellCommand"; Expression = { "'$Sidebar/" + [System.IO.Path]::GetFileNameWithoutExtension($_) + "'" } } | Select-Object  -Expand PowerShellCommand

    # generate content using Here-String block
    $content = @"
/**
 * Import this file in your Docusaurus ``sidebars.js`` file.
 *
 * Auto-generated by Alt3.Docusaurus.Powershell $($Alt3Version).
 *
 * Copyright (c) 2019-present, ALT3 B.V.
 *
 * Licensed under the MIT license.
 */

module.exports = [
    $($commands -Join ",`n    ")
];
"@

    # create the temp file
    $fileName = "docusaurus.sidebar.js"
    $tempFile = Join-Path -Path $tempFolder -ChildPath $fileName
    $fileEncoding = New-Object System.Text.UTF8Encoding $False
    [System.IO.File]::WriteAllLines($tempFile, $content, $fileEncoding)

    # copy to the sidebar folder, convert relative output folder to absolute if needed
    if (-Not([System.IO.Path]::IsPathRooted($OutputFolder))) {
        $outputFolder = Join-Path "$(Get-Location)" -ChildPath $OutputFolder
    }

    Copy-Item -Path $tempFile -Destination (Join-Path -Path $outputFolder -ChildPath $fileName)
}
