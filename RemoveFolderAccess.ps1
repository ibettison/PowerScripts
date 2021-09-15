function Remove-FolderAccess 
{
  <#
      .SYNOPSIS
      A script to Select a folder and remove some of the group access on that folder but also if required
      recurse down the folder list and remove the groups from the lower levels too
      .DESCRIPTION
      Shows a selection window from the computer running the script and allows a choice of folder to return and a recurse checkbox
      .EXAMPLE
      Remove-FolderAccess
      .RETURNS
      Confirmation message
  #>

  <# This form was created using POSHGUI.com  a free online gui designer for PowerShell
      .NAME
      Create Project Folder
  #>

  Add-Type -AssemblyName System.Windows.Forms
  Add-Type -AssemblyName System.Drawing
  [System.Windows.Forms.Application]::EnableVisualStyles()

  $Form                            = New-Object -TypeName system.Windows.Forms.Form
  $Form.ClientSize                 = New-Object -TypeName System.Drawing.Point -ArgumentList (610,200)
  $Form.text                       = "Select the Project Folder"
  $Form.TopMost                    = $true
  $Form.AutoScroll                 = $true

  $location                        = New-Object -TypeName system.Windows.Forms.TextBox
  $location.multiline              = $false
  $location.text                   = "Location"
  $location.width                  = 495
  $location.height                 = 20
  $location.location               = New-Object -TypeName System.Drawing.Point -ArgumentList (15,34)
  $location.Font                   = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',12)

  $Label2                          = New-Object -TypeName system.Windows.Forms.Label
  $Label2.text                     = "Project Folder Location"
  $Label2.AutoSize                 = $true
  $Label2.width                    = 25
  $Label2.height                   = 10
  $Label2.location                 = New-Object -TypeName System.Drawing.Point -ArgumentList (15,12)
  $Label2.Font                     = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',10)

  $recurse                         = New-Object -TypeName System.Windows.Forms.CheckBox
  $recurse.text                    = "Recurse"
  $recurse.location                = New-Object -TypeName System.Drawing.Point -ArgumentList (15,64)
  $recurse.Font                    = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',10)
  
  $Form.controls.AddRange(@($location,$Label2,$recurse))
   $location.Add_Click{ get-Location }
 
  #check for the enter key pressed after entering the Project folder
  $location.Add_KeyDown({
      if ($_.KeyCode -eq "Enter") {
        #if the enter key is pressed then load the other settings from the xml file.
        get-location
      }
  })
  
  #$location.Add_Leave({
        #if leave the field then load the other settings from the xml file.
  #      get-location
  #})
  
  $contentList = New-Object System.Windows.Forms.ToolTip
  $global:showHelp = {$contentList.SetToolTip($location, $location.Text)}
  $location.add_MouseHover($global:showHelp)
  $Form.ShowDialog()| Out-Null
}

function get-location
{   
  $path = Get-Folder 
  if(![string]::IsNullOrEmpty($path)){
    Write-Host ("Please wait - retrieving a list of all AD security Groups from the Folder structure.") -ForegroundColor Cyan
    $location.Text = $path
    $folderAcl = get-Groups
    # setup a grid view to select the Group Multiple selection
    $Idx =0
    $group = $(ForEach ($item in $folderAcl){
        $item  | Select-Object -Property @{l='IDX'
        e={$Idx}}, Value
    $Idx++	}) |
    Out-GridView -Title 'Select All of the AD Groups to remove from this folder' -OutputMode Multiple |
    ForEach-Object { $folderAcl[$_.IDX] }
    if(![string]::IsNullOrEmpty($group)){
        get-AllFolders($group)
    }else{
      Write-Host "Operation Cancelled" -ForegroundColor Red
    }
  }else{
    Write-Host "Operation Cancelled" -ForegroundColor Red
  }
  Write-Host "Operation has completed, choose another folder" -ForegroundColor Cyan 
}

function get-Groups {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $allACL = @()
    if($recurse.Checked){
      #need to get all of the folders and add the groups to remove
      $listOfFolders = Get-ChildItem -Path $location.Text -Recurse -Directory -ErrorAction SilentlyContinue | %{$_.FullName}
      foreach($folder in $listOfFolders){
        $getACL = Get-Acl -Path $folder
        foreach($aclList in $getACL.Access){
          if($allACL -notcontains $aclList.IdentityReference){
            $allACL += $aclList.IdentityReference
          }
        }
      }
    }else{
      $getACL = Get-Acl -Path $location.Text
      foreach($aclList in $getACL.Access){
        if($allACL -notcontains $aclList.IdentityReference){
          $allACL += $aclList.IdentityReference
        }
      }
    }
    return $allACL
}

function get-AllFolders {

  param(
    [parameter(Mandatory=$true)]
        [Object[]]
        $GroupList
  )
  # setup a grid view to select the Group Multiple selection
  $Idx =0
  $groups = $(ForEach ($item in $GroupList){
      $item  | Select-Object -Property @{l='IDX'
      e={$Idx}}, Value
  $Idx++	}) |
  Out-GridView -Title 'Confirm all of the Items to Delete' -OutputMode Multiple |
  ForEach-Object { $GroupList[$_.IDX] }
  if(![string]::IsNullOrEmpty($groups)){
    if($recurse.Checked) {
      $listOfFolders = Get-ChildItem -Path $location.Text -Recurse -Directory -ErrorAction SilentlyContinue | %{$_.FullName}
      $listOfFolders = ,$location.Text + $listOfFolders
    }else{
      $listOfFolders = $location.Text
    }
    $listOfGroups = $groups

    #now call a method that deals with the removal of groups from the list of folders
    remove-GroupsFromFolder $listOfFolders $listOfGroups
  }else{
    Write-Host "Operation Cancelled" -ForegroundColor Red
  }
  
}

function remove-GroupsFromFolder{
  param(
    [parameter(Mandatory=$true)]
        [Object[]]
        $FolderList,
    [parameter(Mandatory=$true)]
        [String[]]
        $GroupList
  )
 
    foreach($list in $FolderList){
      $acl      = [string]::Empty
      $rule     = [string]::Empty      
      foreach($group in $GroupList){
        $acl = Get-ACL $list
        $rule = $acl.access | Where-Object {
          $_.IdentityReference -eq $group
        }
        if(![string]::IsNullOrEmpty($rule)){
          $acl.RemoveAccessRule($rule)
          #Set the Access Control List
          (Get-Item $list).SetAccessControl($acl)
          Write-Host ("Removed access from {0} from folder {1}" -f $group, $list) -ForegroundColor Cyan
        }
      }
    }
}

function show-message ( $message ) {
  Add-Type -AssemblyName PresentationFramework
  $choice = [System.Windows.MessageBox]::Show($message)
  
}

function Get-Folder
{
  <#
      .SYNOPSIS
      A script to display a popup folder selection window.
      .DESCRIPTION
      Shows a selection window from the computer running the script and allows a choice of folder to return
      .EXAMPLE
      Get-Folder
      .RETURNS
      The chosen folder as unc ie. \\campus\dept\crf
  #>
  
  [Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
  
  $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
  $foldername.Description = "Select a folder"
  $foldername.RootFolder = "MyComputer"
  $OnTop = New-Object System.Windows.Forms.Form
  $OnTop.TopMost = $true
  $OnTop.MinimizeBox = $true
  
  if($foldername.ShowDialog($OnTop) -eq "OK")
  {
    try{

      $folder += $foldername.SelectedPath
      $drive = (Split-Path $folder -Qualifier).Replace(':','')
      $path = Split-Path $folder -NoQualifier
      $unc = Join-Path (Get-PSDrive $drive).DisplayRoot -ChildPath $path
    }
    catch{
      Write-Host ('ERROR : {0}' -f $_)
    }
  }
  return $unc
}

function Select-Groups
 {
   <#
       .SYNOPSIS
       Allows a search for a partial text to match AD Group and list members in the group
       .DESCRIPTION
       Search to find the list of Active Directory Groups matching the partial string parameter -ADGroup then displays the members of that group 
       .EXAMPLE
       Select-Groups -ADGroup CRF
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
     write-host 'Searching Active Directory...'
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
       # setup a grid view to select the Group Multiple selection
       $Idx =0
       $group = $(foreach ($item in $groupList){
           $item | Select-Object -Property @{l='IDX'
           e={$Idx}}, Name, Description
       $Idx++	}) |
       Out-GridView -Title 'Select All of the AD Groups to Grant Access' -OutputMode Multiple |
       ForEach-Object { $groupList[$_.IDX] }
     }
   }
   catch
   {
     Write-Host ('ERROR : {0}' -f $_) -ForegroundColor Red
   }
   return $group.Name
 }
 
  