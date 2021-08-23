<#
    .SYNOPSIS 
    This script removes a user from multiple groups - this is when a user leaves 

    .DESCRIPTION
    This script removes a user from multiple groups, it prompts for a group name which can be a partial group name
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
 param
  (
    [Parameter(Mandatory, Position=0)]
    [String]
    $ADUser    
  )
# Reset Groups
$groupList = ""
try {
  #load all of the Groups the user is in
  $groupList = Get-ADPrincipalGroupMembership -Identity $ADUser
  if([string]::IsNullOrEmpty($groupList)){
    Throw "User groups not found"
  }
  # setup a grid view to select the Group Multiple selection
  $Idx =0
  $groups = $(foreach ($item in $groupList){
      $item | Select-Object -Property @{l='IDX'
      e={$Idx}}, Name
  $Idx++	}) |
  Out-GridView -Title 'Select All of the AD Groups to remove the user from' -OutputMode Multiple |
  ForEach-Object { $groupList[$_.IDX] }
  if([string]::IsNullOrEmpty($Groups))
    {
        Throw "No groups selected."
    }
  if([string]::IsNullOrEmpty($Creds))
    {
        $Creds = Get-Credential
    } 
  foreach($group in $groups) {
    Remove-ADGroupMember -Identity $group.distinguishedName -Members $ADUser -Confirm -Credential $Creds
  }
}catch{
  Write-Host "`nAn error has occurred. `n`nERROR - " $_.Exception
  Exit
}