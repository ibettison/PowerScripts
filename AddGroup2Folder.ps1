<#
.SYNOPSIS 
This script accepts a folder inside a predefined (within the script) folder Start position prompts for the group to add checks it exists and adds it to the folder with modify rights.

.DESCRIPTION
This script accepts a folder inside a predefined (within the script) folder Start position prompts for the group to add checks it exists and adds it to the folder with modify rights.

-- Ian Bettison March 2017	

.INPUTS
folderName
GroupName
Confirmation to continue
Confirmation to add more security

.OUTPUTS
Adds a group and creates the correct credentials to allow the group to have modify rights

.EXAMPLE
.\AddUser2Folder.ps1
#>
$AddFolder = 'y'
try{

    do{
        clear-host
        $folder = read-host -prompt 'Enter the folder name'
        if([string]::IsNullOrEmpty($folder))
        {
            throw "Folder Name is required."
        }
        $folderLoc = '\\campus\dept\IHS\programmes\CTU\Trials\'
        #get and show folder properties
        $folderToSearch = $folderLoc+$folder
        $FolderAccess=(Get-Acl $folderToSearch).Access | Select-Object -ExpandProperty IdentityReference
        write-host $FolderAccess
        $Folder = Get-ADuser -Identity $folder -Properties *

        $continue = read-host -prompt 'Do you want to continue and add a group to the folder'
        if([string]::IsNullOrEmpty($continue)) {
            throw "Selected to stop - Script terminated"
        }
        if ($continue -eq 'y') {

            #list groups to choose from
            $groupName = 'CTU-Trials'
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

        $AddFolder = read-host -Prompt "Would you like to add another group to a folder? (y/n)"
        if([string]::IsNullOrEmpty($AddFolder))
        {
            $AddFolder = 'n'
        }

    }
    until ($AddFolder -eq 'n')
    clear-host
}
catch
{
    Write-Host "ERROR :" $_.Exception
    Exit
}

