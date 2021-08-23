function Get-GroupMembers
{
  <#
      .SYNOPSIS
      Allows a search for a partial text to match AD Group and list members in the group
      .DESCRIPTION
      Search to find the list of Active Directory Groups matching the partial string parameter -ADGroup then displays the members of that group 
      .EXAMPLE
      Get-GroupMembers -ADGroup CRF
      This will search for Active Directory Group matching the partial text passed using the -ADGroup parameter and return the members of the group and the group name
  #>
  param
  (
    [Parameter(Mandatory, Position=0)]
    [String]
    $ADGroup    
  )
	
  $ErrorActionPreference = "Stop"
  [hashtable]$return = @{}
  try 
  {
    if([string]::IsNullOrEmpty($ADGroup))
    {
      throw 'Cannot search on NULL data.'
    }
    # adds asterisks to the passed parameter to pass into the filter option in the scriptBlock below.		
    $ADGroup = '*' + $ADGroup + '*'
    # Start a job to list all of the Active Directory Groups matching the parameter (No output)
    Start-Job -Name getList -ScriptBlock {param([Parameter(Mandatory,HelpMessage='Enter the Partial Group')][String]$pGroup) Get-ADGroup -Filter {Name -like $pGroup} -Properties * | Select-Object -Property Name, Description} -ArgumentList $ADGroup | Out-Null
    # wait for the job to finish (No output)
    Wait-Job -Name getList | Out-Null
    # It is now safe to receive the output from the job.
    $groupList = Receive-Job -Name getList | Sort-Object
    # has the search returned any information
    if([string]::IsNullOrEmpty($groupList)) 
    {
      throw 'Group was not found.'
    }
    else
    {
      # setup a grid view to select the Group Single selection
      $Idx =0
      $group = $(foreach ($item in $groupList){
          $item | Select-Object -Property @{l='IDX'
          e={$Idx}}, Name, GivenName, SurName
      $Idx++	}) |
      Out-GridView -Title 'Select one of the AD Groups to use' -OutputMode Single |
      ForEach-Object { $groupList[$_.IDX] }
    }
  }
  catch
  {
    Write-Host ('ERROR : {0}' -f $_) -ForegroundColor Red
  }
  # Check if the group exists and was selected
  if(-not [string]::IsNullOrEmpty($group)) 
  {
    try
    {
      # get the list of members within the group
      $members = Get-ADGroupMember -identity $group.Name -Recursive | Foreach-object {Get-ADUser $_.name -Properties SamAccountName,Name,Title,Department,Givenname,Surname}
    }
    catch 
    {        
      Write-Host -Message ("`nThe group name may have contained a typo as I did not find it. `n`nERROR - {0}" -f $_) -ForegroundColor Red
    }
    foreach($member in $members) {
      $memberDetail = $member.Givenname+" "+$member.Surname+" ("+$member.name+")"
      Write-Host $memberDetail
    }
    
  }
  $return.members
  $return.group =$group.name
  return $return
}

function Remove-SelectedGroupMembers
{
  <#
      .SYNOPSIS
      Pulls in the members from a group and allows the user to select which members to delete from the group
      .DESCRIPTION
      Uses the Get-GroupMembers method to remove members from the selected group. This function lists the members of the group and allows selection of multiple members to remove
      from the group.
      .EXAMPLE
      Remove-SelectedGroupMembers -ADGroup CRF
      The parameter -AD Group will find all groups containing the text CRF for example it will return CRF - Everyone
  #>
  param
  (
    [Parameter(Mandatory, Position=0)]
    [String]
    $ADGroup    
  )
  
    $members = Get-GroupMembers -ADGroup $ADGroup
    # Are there any members
    if(-not [string]::IsNullOrEmpty($members))
    {
      try
      {
        $listUsers = @()
        $count=0
        foreach ($member in $members.members){
          $listUsers +=  Get-ADUser -Identity $member -Properties *
        }
        $Idx =0
        $users = $(foreach ($item in $listUsers){
            $item | Select-Object -Property @{l='IDX'
            e={$Idx}}, Name, DisplayName
        $Idx++	}) |
        Out-GridView -Title 'Select the users to remove.' -OutputMode Multiple |
        ForEach-Object { $listUsers.SamAccountName[$_.IDX] }
        if(-not [string]::IsNullOrEmpty($users)){

          write-host "Removing Group Members" -ForegroundColor Green
          $users 
          write-host("From Group {0}" -f $members.group) -ForegroundColor Green
          $cred = Get-Credential
          foreach($user in $users) 
          {
            Remove-ADGroupMember -Identity $members.group -Members $user -Credential $cred
          }
        }else{
          throw 'Nothing to remove'
        } 
      }catch
      {
        write-host ("`nERROR - {0}" -f $_) -ForegroundColor Red     
      }
    }
}



