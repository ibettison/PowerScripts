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
function Add-UserToGroup
{
  Clear-Host
  $partialGroup = Read-Host -Prompt "Type the group to add the user to (partial search)"

  try 
  {
    if([string]::IsNullOrEmpty($partialgroup))
    {
      throw "Cannot search on NULL data."
    }
    $partialGroup = "*" + $partialGroup + "*"
    $groupList    = Get-ADGroup -Filter {Name -like $partialGroup} | Select-Object -Property Name
    
    if([string]::IsNullOrEmpty($groupList)) 
    {
      throw "Group was not found."
    }
    else
    {
      # setup a grid view to select the Group Single selection
      $Idx   = 0
      $group = $(foreach ($item in $groupList){
          $item | Select-Object -Property @{l = 'IDX'
          e = {$Idx}}, Name
      $Idx++	}) |
      Out-GridView -Title 'Select one of the AD Groups to use' -OutputMode Single |
      ForEach-Object { $groupList[$_.IDX] }
    }
  }
  catch
  {
    Write-Host "ERROR :" $_.Exception
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
        $memberList += Get-ADUser -Identity $member.SamAccountName | select name, GivenName, Surname 
      }
      $memberList | Format-Table
      $continue   = "Y"
      while($continue -eq "Y")
      {
        $userEntered          = Read-Host -Prompt "`nType the First and Last name of the user to add/remove from the group <Leave Blank to Cancel>"
        $FirstName, $LastName = $userEntered.Split()
        try{
          $userNames = Get-ADUser -Filter {GivenName -eq $FirstName -and Surname -eq $LastName} -Properties * | Select-Object -Property Name, GivenName, Surname, Description
          if([string]::IsNullOrEmpty($userNames)) {
            throw "The user was not found"
          }
          # setup a grid view to select the Group Single selection
          $Idx       = 0
          $UserID    = $(foreach ($item in $userNames){
              $item | Select-Object -Property @{l = 'IDX'
              e = {$Idx}}, Name, GivenName, Surname, Description
          $Idx++	}) |
          Out-GridView -Title 'Select one of the AD Groups to use' -OutputMode Single |
          ForEach-Object { $userNames[$_.IDX] }
        }catch {
              
          Write-Host "`nThe name you typed was not found" -ForegroundColor Red

        }
        if(-not [string]::IsNullOrEmpty($UserID)) 
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
              
              $creds = Get-SavedCredentials -UserId sib8
              
            } 
            switch ($addOrRemove)
            {
              "A" {Add-ADGroupMember -Identity $group.Name -Members $userID.Name -Credential $Creds -Confirm}
              "R" {Remove-ADGroupMember -Identity $group.Name -Members $UserID.Name -Credential $Creds -Confirm}
            }
                    
          }
          catch [System.Exception]
          {
            write-host "`nThe user was not added to the group `n ERROR :" $_.Exception
          }
          $continue = Read-Host "`nDo you want to add\remove another user to\from the group? (Y/N)"

        }else{
          $continue = "N"
        }
      }
    }
  }
}