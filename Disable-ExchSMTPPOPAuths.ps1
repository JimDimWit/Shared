<#
.SYNOPSIS
Function to disable SMTP and POP client auth methods in exchange online
.DESCRIPTION
Function validates ExchangeOnlineManagement module presence and performs the action of removing smtp and pop client auth protocols.
.PARAMETER Identity
Mailbox entity Exhcange identity
.EXAMPLE
Disable-ExchSMTPOPAuths -Identity dim.wit
.EXAMPLE
Import-Csv -Path .\Users.csv | ForEach-Object {
    Disable-ExchSMTPOPAuths -Identity $_
}
.NOTES
Script is designed to take into account the module requirements and connection to Exchange Online.
If you feel like these steps are unnecessary to your requirements, you should consider just using the following:

Set-CASMailbox -Identity Dim.Wit -SmtpClientAuthenticationDisabled $True -PopEnabled $False

Or to disable org wide: 

Set-TransportConfig -SmtpClientAuthenticationDisabled $true

Be advised, in current version of this function, you will need to run Disconnect-ExchangeOnline manually to remove residual EOL session.

.LINK
https://github.com/JimDimWit/Shared
.LINK
https://docs.microsoft.com/en-us/exchange/troubleshoot/user-and-shared-mailboxes/pop3-imap-owa-activesync-office-365
.LINK
https://docs.microsoft.com/en-us/powershell/exchange/connect-to-exchange-online-powershell?view=exchange-ps
.LINK
https://docs.microsoft.com/en-us/powershell/module/exchange/?view=exchange-ps

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

    Set-CASMailbox -Identity $Identity -SmtpClientAuthenticationDisabled $True -PopEnabled $False
    
}


