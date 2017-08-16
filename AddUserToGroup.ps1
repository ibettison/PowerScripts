<#
.SYNOPSIS 
This script adds a user to a group but first searches for the group and lists the membership 

.DESCRIPTION
This script adds a user to a group, it prompts for a group name which can be a partial group name
displays the groups it finds and asks for confirmation of the full group name. It then asks for the user to add
to the group. If the name is left empty no attempt to add the user takes place otherwise the user is added to the group.

Credentials are prompter for the first time an addition to the group is requested but should not ask for them again.

-- Ian Bettison Sept 2015	

.INPUTS
Partial Group Name
Full group Name
User Id.

.OUTPUTS
List of groups matching the group name
List of User and username for confirmation.
Confirmation of user added to the group

.EXAMPLE

AddUserToGroup.ps1
#>
Clear-Host
$partialGroup = Read-Host -Prompt "Type the group to add the user to (partial search)"

try 
{
    if([string]::IsNullOrEmpty($partialgroup))
    {
        throw "Cannot search on NULL data."
    }
    $partialGroup = "*" + $partialGroup + "*"
    $groupList = Get-ADGroup -Filter {Name -like $partialGroup} | Select-Object -Property Name
    
    if([string]::IsNullOrEmpty($groupList)) 
    {
        throw "Group was not found."
    }
    else
    {
        foreach($groupItem in $groupList)
        {
            write-host $groupItem.Name
        }
    }
}
catch [system.exception]
{
    Write-Host "ERROR :" $_.Exception
    Exit
}
$group = Read-Host -Prompt "Type the FULL group name of the required AD Group <Leave Blank to Cancel>"
if($group -ne "") 
{
    try
    {
        $members = Get-ADGroupMember -identity $group -Recursive
    }
    catch [system.exception]
    {        
        Write-Host "`nThe group name may have contained a typo as I did not find it. `n`nERROR - " $_.Exception
        Exit
    }

    if($members -ne "")
    {
        Write-Host "`nDisplaying the members of this group: " $group                
        foreach( $member in $members )
        {
            Get-ADUser -Identity $member.SamAccountName | select name, GivenName, Surname | Format-Table -autosize
        }
        $continue = "Y"
        while($continue -eq "Y")
        {
            $userId = Read-Host -Prompt "`nType the user ID to add to or remove from the Group <Leave Blank to Cancel>"
            if($userId -ne "") 
            {
                try
                {
                    $addOrRemove = Read-Host -Prompt "`nAdd or Remove User Id ? (A/R) <Leave Blank to Cancel>"
                    if([string]::IsNullOrEmpty($addOrRemove))
                    {
                        Exit
                    }
                    if([string]::IsNullOrEmpty($Creds))
                    {
                        $Creds = Get-Credential
                    } 
                    switch ($addOrRemove)
                    {
                        "A" {Add-ADGroupMember -Identity $group -Members $userId -Credential $Creds -Confirm}
                        "R" {Remove-ADGroupMember -Identity $group -Members $userId -Credential $Creds -Confirm}
                    }
                    
                }
                catch [System.Exception]
                {
                    write-host "`nThe user was not added to the group `n ERROR :" $_.Exception
                }
                $continue = Read-Host "`nDo you want to add\remove another user to\from the group? (Y/N)"

            }else
            {
                $continue = "N"
            }
        }
    }
}