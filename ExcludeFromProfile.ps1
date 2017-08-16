<#
.SYNOPSIS 
This script allows the user to change the ExcludeProfileDirs key allowing manipulation
of this to add or delete folders to remove these from the folders saved to the users profile 

.DESCRIPTION
This script allows the user to change the ExcludeProfileDirs key allowing manipulation
of this to add or delete folders to remove these from the folders saved to the users profile

Adding folders to this path of exclusions reduces the Users Profile space. Use this to 
stop the window reporting the users profile is too big.

-- Ian Bettison Sept 2015	

.INPUTS
User Change of the path

.OUTPUTS
Lists the Values attached to the Registry Key

.EXAMPLE

ExcludeFromProfile.ps1

Provides a prompt containing the existing Exclusion path and allows the 
user to edit it.

#>

# set the registry key
$registryKey = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"

# get the current ExcludeProfileDirs
$path = (Get-ItemProperty -Path $registryKey -Name ExcludeProfileDirs).ExcludeProfileDirs

# Initiate Visual Basic
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

#show the input box with the ExcludeProfileDirs path, ready for editing
$enteredPath = [Microsoft.VisualBasic.Interaction]::InputBox("Edit the Excluded path", "Excluded Path", "$path")

if($enteredPath -ne "") { #if clicked OK
    #set the key value to the desired value
    Set-ItemProperty -Path $registryKey -Name ExcludeProfileDirs -value $enteredPath
}
else
{
    Write-Host "Cancelled - No changes have been saved"
}


#show the edited value.
Get-ItemProperty -Path $registryKey | Format-list

Pause

function Pause () 
{
    #Check if running PowerShell ISE
    if ($psISE)
    {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("Click OK to continue")
    }
    else
    {        
        Write-Host "Press any key to continue..." -ForegroundColor Yellow
        $x = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}
