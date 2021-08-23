<#
    .SYNOPSIS 
    This script removes multiple users from a group  but first searches for the group and lists the membership 

    .DESCRIPTION
    This script removes multiple users from a group, it prompts for a group name which can be a partial group name
    displays the groups it finds and asks for confirmation of the full group name. It then lists the users and allows the multiple selection of users to remove from the group. 
    If the name is left empty no attempt to remove users takes place otherwise the users are removed from the group.

    Credentials are prompted for the first time a removal from the group is requested but should not ask for them again.

    -- Ian Bettison Anugust 2019	

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
$partialGroup = Read-Host -Prompt "Type the group to remove user from (partial search)"

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
      # setup a grid view to select the Group Single selection
        $Idx =0
        $group = $(foreach ($item in $groupList){
            $item | Select-Object -Property @{l='IDX'
            e={$Idx}}, Name
        $Idx++	}) |
        Out-GridView -Title 'Select one of the AD Groups to use' -OutputMode Single |
        ForEach-Object { $groupList[$_.IDX] }
    }
}
catch
{
    Write-Host "ERROR :" $_.Exception
    Exit
}


if($group.Name -ne "") 
{
    try
    {
        $members = Get-ADGroupMember -identity $group.Name -Recursive
    }
    catch
    {        
        Write-Host "`nThe group name may have contained a typo as I did not find it. `n`nERROR - " $_.Exception
        Exit
    }

    if($members -ne "")
    {
        $memberList = @()
        Write-Host "`nDisplaying the members of this group: " $group.Name               
        foreach( $member in $members )
        {
            $memberList += Get-ADUser -Identity $member.SamAccountName  -Properties *| select-object name, GivenName, Surname, Description 
        }
        # setup a grid view to select the Group Single selection
        $Idx =0
        $membersSelected = $(foreach ($item in $memberList){
            $item | Select-Object -Property @{l='IDX'
            e={$Idx}}, Name, GivenName, Surname, Description
        $Idx++	}) |
        Out-GridView -Title 'Select one of the AD Groups to use' -OutputMode Multiple |
        ForEach-Object { $memberList[$_.IDX] }

        if(-not [string]::IsNullOrEmpty($membersSelected)) 
        {
            try
            {

                if([string]::IsNullOrEmpty($Creds))
                {
                    $Creds = Get-Credential
                } 
                foreach($memberItem in $membersSelected) 
                {

                    Remove-ADGroupMember -Identity $group.Name -Members $memberItem.Name -Credential $Creds -Confirm:$false
                }
                    
            }
            catch 
            {
                write-host "`nThe user was not removed from the group `n ERROR :" $_.Exception
            }

        }
    }
}