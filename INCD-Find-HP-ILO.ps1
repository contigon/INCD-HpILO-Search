<#PSScriptInfo

.VERSION 0.9
.AUTHOR Omer Friedman
.COMPANYNAME INCD
.TAGS iLO on HPE ProLiant Gen7, Gen8 or Gen9
.PROJECTURI https://github.com/contigon/...
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
.DEPENDENCIES
.RELEASENOTES
Version 1.0: Original published version.
#>

<#
.SYNOPSIS
    Example of a script to send the PingCastle report

    Copyright (c) Omer Friedman / 2022

    Permission to use, copy, modify, and distribute this software for any
    purpose with or without fee is hereby granted, provided that the above
    copyright notice and this permission notice appear in all copies.

    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
    WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
    MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
    ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
    WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
    ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
    OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
.DESCRIPTION
    This tool will help you find iLO on HPE ProLiant Gen7, Gen8 or Gen9 Servers in your network.
    Created using HPe iLO cmdlets Scripting Tools for Windows PowerShell (x64).
    
.EXAMPLE
    PS C:\> INCD-FIND-HP-ILO.ps1

    Manually runnig the cmdlets:
    #Example 1: Find-HPiLO with a single IP address:
    Find-HPiLO 192.168.1.1

    #Example 2: Find-HPiLO with a search range 
    #(if a comma is included in the range, double quotes are required)
    Find-HPiLO 192.168.1.1-11
    Find-HPiLO -Range “192.168.1.1,15"
    Find-HPiLO -Range “192.168.217,216.93,103”
    Find-HPiLO -Range “192.168.1.1,15"

    #Example 3: Piping output from Find-HPiLO to another cmdlet
    Find-HPiLO 192.168.217.97-103 -Verbose |
    % {Add-Member -PassThru -InputObject $_ Username "username"}|
    % {Add-Member -PassThru -InputObject $_ Password "password"}|
    Get-HPiLOFirmwareVersion -Verbose

#>
CLS
Start-Transcript -Path "$PSScriptRoot\INCD-Find-HPiLO.log" -NoClobber -Append
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
$downloadUri = "https://downloads.hpe.com/pub/softlib2/software1/pubsw-windows/p2102165468/v148585/HPiLOCmdlets-x64.exe"

$help = @"

  ______ _____ _   _ _____    _    _ _____    _ _      ____     _____                              
 |  ____|_   _| \ | |  __ \  | |  | |  __ \  (_) |    / __ \   / ____|                             
 | |__    | | |  \| | |  | | | |__| | |__) |  _| |   | |  | | | (___   ___ _ ____   _____ _ __ ___ 
 |  __|   | | | . `  | |  | | |  __  |  ___/  | | |   | |  | |  \___ \ / _ \ '__\ \ / / _ \ '__/ __|
 | |     _| |_| |\  | |__| | | |  | | |      | | |___| |__| |  ____) |  __/ |   \ V /  __/ |  \__ \
 |_|    |_____|_| \_|_____/  |_|  |_|_|      |_|______\____/  |_____/ \___|_|    \_/ \___|_|  |___/

This tool will help you find iLO on HPE ProLiant Gen7, Gen8 or Gen9 Servers in your network.
Created using HPe iLO cmdlets Scripting Tools for Windows PowerShell (x64).

"@

Write-Host $help -ForegroundColor Green

function DownloadHPiLOCmdlets{
    if ((Test-NetConnection support.hpe.com).pingsucceeded)
    {
        Write-Host "[OK]You are connected to the Internet, Downloading HPiLOCmdlets-x64.exe (1.1 MB)" -ForegroundColor Green
        Invoke-WebRequest -Uri $downloadUri -Out "$PSScriptRoot\HPiLOCmdlets-x64.exe"
    } 
    else
    {
        Write-Host "[Failed] You are not connected to the internet, Please download and Install HPiLOCmdlets from:" -ForegroundColor Red
        Write-Host $downloadUri -ForegroundColor Yellow
        $input = Read-Host "Press [Q] to Quit or [Enter] to continue"
        if ($input -cmatch "Q")
        {
            Write-Host "Exiting tool..."
            Stop-Transcript
            exit
        }

    }
}


if (!(Get-Module HPiLOCmdlets))
{
    DownloadHPiLOCmdlets
    Write-Host "[OK] Extracting and installing the HPiLOCmdlets-x64" -ForegroundColor Green
    Start-Process $PSScriptRoot\HPiLOCmdlets-x64.exe -ArgumentList /auto
    msiexec  /i $PSScriptRoot\HPiLOCmdlets-x64.msi
}

if (Get-Module HPiLOCmdlets) {
    Write-Host "[OK]HPiLOCmdlets was installed successfuly" -ForegroundColor Green
    $range = Read-Host "Input the nework range you want to search (eg. 10.0.0.1,99)"
    Find-HPiLO $range -Verbose
}

Stop-Transcript