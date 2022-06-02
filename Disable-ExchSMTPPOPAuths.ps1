<#
.SYNOPSIS
Function to disable SMTP and POP client auth methods in exchange online
.DESCRIPTION
Function validates ExchangeOnlineManagement module presence and performs the action of removing smtp and pop client auth protocols.
.INPUTS


#>
Param (
    # Specify User Exchange Identity
    [Parameter(Mandatory=$true)]
    [string] $Identity
)
Process {
    #Check for ExchangeOnlineManagement module
    Clear-Variable -Name ExchModuleInstalled -Force -ErrorAction SilentlyContinue
    $ExchModuleInstalled = Get-Module -Name ExchangeOnlineManagement
    if ($null -eq $ExchModuleInstalled) {
        try {
            #Set local cipher suite from default tls 1.0 to tls 1.2. This is required to use nuget
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
            Install-Module ExchangeOnlineManagement -Force
        }
        catch {
            <#
            If error is related to nuget installation, please manually install NuGet
            https://stackoverflow.com/questions/58349992/how-do-i-install-the-nuget-provider-for-powershell-on-a-offline-machine
            #>
            throw $Error[0]
        }
        finaly {
            Import-Module ExchangeOnlineManagement
        }
    } 

    #connect to exchange online or use current connection
    $SessionExists = Get-PSSession | where {$_.ComputerName -eq "outlook.office365.com"}
    If($null -eq $SessionExists){
        try {
            Connect-ExchangeOnline
        }
        catch {
            <#
            If error occurs, please review MS documentation for further troubleshooting
            https://docs.microsoft.com/en-us/powershell/module/exchange/connect-exchangeonline?view=exchange-ps
            #>
            throw $Error[0]
        }
    }

    #Check if user has specified
    
}


