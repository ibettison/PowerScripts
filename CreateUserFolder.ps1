<#
.SYNOPSIS 
This script accepts a userid and creates a folder inside a predefined (within the script) folder using the userId as the folder name.

.DESCRIPTION
This script accepts a userid and creates a folder inside a predefined (within the script) folder using the userId as the folder name 

-- Ian Bettison March 2017	

.INPUTS
UserId
Confirmation to continue
Confirmation to add another folder

.OUTPUTS
Adds a folder inside another and creates the correct credentials to allow the user to have modify rights

.EXAMPLE
.\CreateUserFolder.ps1
#>
$AddAnotherUser = 'y'
try{

    do{
        clear
        $UserDetails = "Invaid Entry"
        $user = read-host -prompt 'Enter the username'
        if([string]::IsNullOrEmpty($user))
        {
            throw "Username is required."
        }
        $UserDetails = Get-ADuser -Identity $user -Properties *
        $userDisplayName = $UserDetails.DisplayName
        $userOffice = $userDetails.Office
        Write-Host ""
        $correct = read-host -prompt "This username is $userDisplayName based in $userOffice, do you want to continue? (y/n)"
        Write-Host ""
        if([string]::IsNullOrEmpty($correct)) {
            throw "No choice selected - Script terminated"
        }
        if ($correct -eq 'y') {

            $folder = '\\campus\dept\CRF\IT\Omega_Users'
            if (-Not (Test-Path "$folder\$user")) {

                #create the folder under $folder with the name as the userId
                New-Item -ItemType directory -Path $folder\$user
                $userfolder = "$folder\$user"
                #Rights
                $readWrite = [System.Security.AccessControl.FileSystemRights]"Modify"
                $inheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
                # Propagation
                $propagationFlag = [System.Security.AccessControl.PropagationFlags]::None
                # Type
                $type = [System.Security.AccessControl.AccessControlType]::Allow
                $accessControlRW = New-Object  System.Security.AccessControl.FileSystemAccessRule @($user, $readWrite, $inheritanceFlag, $propagationFlag, $type)
                $objACL = Get-ACL $userfolder
                $objACL.AddAccessRule($accessControlRW)
                Set-Acl $userfolder $objACL
            }else{
                throw "Folder already exists"
            }
        }

        $AddAnotherUser = read-host -Prompt "Would you like to add another user? (y/n)"
        if([string]::IsNullOrEmpty($AddAnotherUser))
        {
            $AddAnotherUser = 'n'
        }

    }
    until ($AddAnotherUser -eq 'n')
    clear
}
catch [system.exception]
{
    Write-Host "ERROR :" $_.Exception
    Exit
}

