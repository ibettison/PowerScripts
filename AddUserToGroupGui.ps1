<#
      .SYNOPSIS 
      This script adds a user to a group providing the membership of the group 

      .DESCRIPTION
      This script adds a user to a group, the window prompts for UserId, which can be searched for by either Id - with partial entry or by name and surname with partial entry on the surname.
      Then it allows the same partial search for the Security group. A checkbox determines if the user is to be removed or added.
      Credentials are checked for and if not encrypted and present in a secure location they are created and the encrypted credentials are saved for next time.

      -- Ian Bettison NOV 2021	

      .INPUTS
      Partial security Group Name
      Full group Name
      User Id or user name (both partial searches available)

      .OUTPUTS
      List of groups matching the group name
      List of User and username for confirmation.
      Relist of the group members to confirm the membership has changed

      .EXAMPLE
      run direct from ISE
  #>
Function Get-FromList(){
  param
   (
     [Parameter(Mandatory=$true, Position=0)]
     [Array]
     $List,
     [Parameter(Mandatory=$true, Position=1)]
     [String]
     $Title
         
   )
  # setup a grid view to select the Group Single selection
      $Idx   = 0
      $group = $(foreach ($item in $List){
          $item | Select-Object -Property @{l = 'IDX'
          e = {$Idx}}, Name, GivenName, Surname, SamAccountName
      $Idx++	}) |
      Out-GridView -Title $Title -OutputMode Single |
      ForEach-Object { $List[$_.IDX] }
      return $group
}

Function Show-GroupMembers($GroupName) {
  $GrpMembers = Get-ADGroupMember -Identity $GroupName
  $membersInGroup = @()
  ForEach($person in $GrpMembers){
    if($person.ObjectClass -eq "User"){
      $userInGroup = Get-ADUser -Identity $person.SamAccountName -Properties *
      $members = $userInGroup.GivenName+" "+$userInGroup.Surname
      if($members -ne " "){
        $membersInGroup += $members
      }
    }        
  }
  $membersInGroup = $membersInGroup |Sort-Object -Unique
  $listmembers.Items.Clear()
  Foreach($item in $membersInGroup){
    $listmembers.Items.Add($item)
  }
}

Add-Type -AssemblyName PresentationCore
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$xamlCode = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="MainWindow" Height="460" Width="800">
    <Grid Margin="0,0,2,0">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="52*"/>
            <ColumnDefinition Width="141*"/>
            <ColumnDefinition Width="599*"/>
        </Grid.ColumnDefinitions>
        <Label Name="label" Content="Group Members" HorizontalAlignment="Left" Height="25" Margin="18,10,0,0" VerticalAlignment="Top" Width="159" Grid.ColumnSpan="2"/>
        <Label Name="label1" Content="" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.06,0.13" Width="325" Grid.Column="2" Height="26"/>
        <Button Name="RunButton" Content="Add/Remove user" Margin="10,326,33,48" Grid.Column="2" MinHeight="45" MaxHeight="45"/>
        <ListBox Name="listMembers" HorizontalAlignment="Left" Margin="17,41,0,49" Width="166" Grid.ColumnSpan="2"/>
        <Label Name="label2" Content="User Id" Grid.Column="2" HorizontalAlignment="Left" Height="30" Margin="10,35,0,0" VerticalAlignment="Top" Width="133"/>
        <Label Name="label2_Copy" Content="Security Group" Grid.Column="2" HorizontalAlignment="Left" Height="30" Margin="10,84,0,0" VerticalAlignment="Top" Width="133"/>
        <TextBox Name="Userid" Grid.Column="2" HorizontalAlignment="Left" Height="29" Margin="148,36,0,0" TextWrapping="Wrap" AutomationProperties.HelpText="Enter a Name or user Id (partial search)" VerticalAlignment="Top" Width="277"/>
        <TextBox Name="SecGroup" Grid.Column="2" HorizontalAlignment="Left" Height="29" Margin="148,84,0,0" TextWrapping="Wrap" AutomationProperties.HelpText="Enter a security group (partial search)" VerticalAlignment="Top" Width="277"/>
        <Button Name="SearchId" Content="Check Names" Grid.Column="2" HorizontalAlignment="Left" Height="29" Margin="442,36,0,0" VerticalAlignment="Top" Width="124"/>
        <Button Name="SearchSecGrp" Content="Check Names" Grid.Column="2" HorizontalAlignment="Left" Height="29" Margin="442,85,0,0" VerticalAlignment="Top" Width="124"/>
        <Label Name="label3" Content="Remove User" Grid.Column="2" HorizontalAlignment="Left" Height="29" Margin="10,127,0,0" VerticalAlignment="Top" Width="133"/>
        <CheckBox Name="RemoveUser" Content="Remove" Grid.Column="2" HorizontalAlignment="Left" Height="29" Margin="148,133,0,0" VerticalAlignment="Top" Width="95"/>

    </Grid>
</Window>
'@
$selected = $null
$reader = (New-Object System.Xml.XmlNodeReader $xamlCode)
$GUI = [Windows.Markup.XamlReader]::Load($reader)
$xamlCode.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $GUI.FindName($_.Name) }
#Make the mouse act like something is happening
$RunButton.Add_MouseEnter{    
  $Gui.Cursor = [Windows.Input.Cursors]::Hand
}

#Switch back to regular mouse
$RunButton.Add_MouseLeave({
    $Gui.Cursor = [Windows.Input.Cursors]::Arrow
})

$RunButton.Add_Click{
  
    if ([String]::IsNullOrEmpty($userId.Text)){
      [System.Windows.MessageBox]::Show('Please enter a UserId to add to the group.')
    }else{
      if ([String]::IsNullOrEmpty($SecGroup.Text)){
         [System.Windows.MessageBox]::Show('Please enter a Security Group to Add the User to.')
      }else{
        #everything has been entered so lets try and add the user to the group
        if([string]::IsNullOrEmpty($Creds))
        {              
          $creds = Get-SavedCredentials -UserId sib8              
        }
        if($RemoveUser.IsChecked) {
          Remove-ADGroupMember -Identity $SecGroup.Text -Members $userId.Text -Credential $Creds
        }else{ 
          Add-ADGroupMember -Identity $SecGroup.Text -Members $userId.Text -Credential $Creds
        }
        Show-GroupMembers($SecGroup.Text)
        $label.Content = "Group Members (Updated)"
      }
    }
}
  
 $SearchId.Add_Click{
   try 
   {
     if([string]::IsNullOrEmpty($UserId.Text))
     {
       throw "Cannot search on NULL data."
     }
     #check for entry of id first of all
     $Id = ("*{0}*" -f $UserId.Text)
     $List = Get-ADUser -Filter {SamAccountName -Like $Id}
     if(![string]::IsNullOrEmpty($List)) {
       $User = Get-FromList $List 'List of User Ids'
       $UserId.Text = $User.SamAccountName
     }else{
       $searchName = $UserId.Text
       $NameArray = $searchName.Split(" ")
       $FirstName = $NameArray[0]
       if($NameArray.Count -eq 1){
          $List = Get-ADUser -Filter {(GivenName -eq $FirstName) } | Select-Object -Property Name, GivenName, Surname, SamAccountName
       }else{         
         $LastName = ("*{0}*" -f $NameArray[1])
         $List = Get-ADUser -Filter {(GivenName -eq $FirstName) -and (Surname -Like $LastName) } | Select-Object -Property Name, GivenName, Surname, SamAccountName
       }
       #-and (Surname -like "*$LastName*")
       if([string]::IsNullOrEmpty($List)) 
       {
         throw "User Id was not found."
       }
       else
       {
         $User = Get-FromList $List 'List of User Ids'
         $UserId.Text = $User.SamAccountName
       }
      }
   }
   catch
   {
     Write-Host "ERROR :" $_.Exception
   }
 }
 
 $SearchSecGrp.Add_Click{
  try 
  {
    $label.Content = "Group Members"
    if([string]::IsNullOrEmpty($SecGroup.Text))
    {
      throw "Cannot search on NULL data."
    }
    $SecGroup.Text = "*" + $SecGroup.Text + "*"
    $List    = Get-ADGroup -Filter {Name -like $SecGroup.Text} | Select-Object -Property Name
    
    if([string]::IsNullOrEmpty($List)) 
    {
      throw "Group was not found."
    }
    else
    {
      $Group = Get-FromList $List 'List of Security Groups'
      $SecGroup.Text = $Group.Name
      Show-GroupMembers($Group.Name)
    }
  }
  catch
  {
    Write-Host "ERROR :" $_.Exception
  }
 }

$GUI.ShowDialog() | Out-Null
$GUI.Close()
