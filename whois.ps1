<#
.SYNOPSIS 
This script prompts for a user name or user id and trys to find dependant on what is entered the users ID or users name

.DESCRIPTION
This script prompts for a user name or user id and returns the opposite. A user ID returns the users name and a users name returns 
the users ID.

-- Ian Bettison Sept 2015	

.INPUTS
Name or user id

.OUTPUTS
The user name or the users ID dependant on what is found.

.EXAMPLE
whois.ps1
#>

function Pause () 
{
    #Check if running PowerShell ISE
    if ($psISE)
    {
        Add-Type -AssemblyName System.Windows.Forms
        [Windows.Forms.MessageBox]::Show("Click OK to continue")
    }
    else
    {        
        Write-Host "Press any key to continue..." -ForegroundColor Yellow
        $null = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

Clear-Host
$userDetail = Read-Host -prompt "`nType a users name or ID to search for <leave blank to cancel>"
if($userDetail -ne "") 
{
    #lets try to find the user ID first
    $userId = get-aduser -filter {samAccountName -eq $userDetail} | Select-Object GivenName, Surname, SamAccountName | Format-Table -AutoSize
    if([string]::IsNullOrEmpty($userId))
    {
        #not found the User ID so lets search on the givenName and surname
        $userName = $userDetail.Split(" ")
        $first = $userName[0]
        $last = $userName[1]
        try
        {
            if([string]::IsNullOrEmpty($last))
            {
                throw "User ID not found."
            }
            $showUser = get-aduser -filter {givenName -eq $first -and surname -eq $last} | Select-Object GivenName, Surname, SamAccountName | Format-Table -AutoSize
            if([string]::IsNullOrEmpty($showUser))
            {
                throw "Could not find the user details."
            }
            else
            {
                $showUser
            }
        }
        catch 
        {
            write-host "Error: " $_.Exception
        }
    }
    else
    {
        $userId
    }
}

Pause

