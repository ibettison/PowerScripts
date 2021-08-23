function Show-CheckList 
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

  <# This form was created using POSHGUI.com  a free online gui designer for PowerShell
      .NAME
      Create Project Folder
  #>

  Add-Type -AssemblyName System.Windows.Forms
  Add-Type -AssemblyName System.Drawing
  [System.Windows.Forms.Application]::EnableVisualStyles()

  $Form                            = New-Object -TypeName system.Windows.Forms.Form
  $Form.ClientSize                 = New-Object -TypeName System.Drawing.Point -ArgumentList (672,510)
  $Form.text                       = "Project Folder Creation"
  $Form.TopMost                    = $true
  $Form.AutoScroll                 = $true

  $folderName                      = New-Object -TypeName system.Windows.Forms.TextBox
  $folderName.multiline            = $false
  $folderName.text                 = "Enter the folder name"
  $folderName.width                = 295
  $folderName.height               = 30
  $folderName.location             = New-Object -TypeName System.Drawing.Point -ArgumentList (16,32)
  $folderName.Font                 = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',12)

  $Label1                          = New-Object -TypeName system.Windows.Forms.Label
  $Label1.text                     = "Folder Name (Project)"
  $Label1.AutoSize                 = $true
  $Label1.width                    = 25
  $Label1.height                   = 10
  $Label1.location                 = New-Object -TypeName System.Drawing.Point -ArgumentList (16,11)
  $Label1.Font                     = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',10)

  $location                        = New-Object -TypeName system.Windows.Forms.TextBox
  $location.multiline              = $false
  $location.text                   = "Location"
  $location.width                  = 295
  $location.height                 = 20
  $location.location               = New-Object -TypeName System.Drawing.Point -ArgumentList (16,84)
  $location.Font                   = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',12)

  $Label2                          = New-Object -TypeName system.Windows.Forms.Label
  $Label2.text                     = "Project Folder Location"
  $Label2.AutoSize                 = $true
  $Label2.width                    = 25
  $Label2.height                   = 10
  $Label2.location                 = New-Object -TypeName System.Drawing.Point -ArgumentList (16,62)
  $Label2.Font                     = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',10)

  $organisationUnit                = New-Object -TypeName system.Windows.Forms.TextBox
  $organisationUnit.multiline      = $false
  $organisationUnit.text           = "Organisational Unit"
  $organisationUnit.width          = 220
  $organisationUnit.height         = 20
  $organisationUnit.location       = New-Object -TypeName System.Drawing.Point -ArgumentList (16,135)
  $organisationUnit.Font           = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',12)

  $Label3                          = New-Object -TypeName system.Windows.Forms.Label
  $Label3.text                     = "Organisational unit"
  $Label3.AutoSize                 = $true
  $Label3.width                    = 25
  $Label3.height                   = 10
  $Label3.location                 = New-Object -TypeName System.Drawing.Point -ArgumentList (16,114)
  $Label3.Font                     = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',10)

  $createFolder                    = New-Object -TypeName system.Windows.Forms.CheckBox
  $createFolder.text               = "Create Folder"
  $createFolder.AutoSize           = $false
  $createFolder.width              = 135
  $createFolder.height             = 20
  $createFolder.location           = New-Object -TypeName System.Drawing.Point -ArgumentList (327,38)
  $createFolder.Font               = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',12)

  $structureLocation               = New-Object -TypeName system.Windows.Forms.TextBox
  $structureLocation.multiline     = $false
  $structureLocation.text          = "Structure Location"
  $structureLocation.width         = 295
  $structureLocation.height        = 20
  $structureLocation.location      = New-Object -TypeName System.Drawing.Point -ArgumentList (17,185)
  $structureLocation.Font          = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',12)

  $Label4                          = New-Object -TypeName system.Windows.Forms.Label
  $Label4.text                     = "Structure Location"
  $Label4.AutoSize                 = $true
  $Label4.width                    = 25
  $Label4.height                   = 10
  $Label4.location                 = New-Object -TypeName System.Drawing.Point -ArgumentList (16,165)
  $Label4.Font                     = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',10)

  $Label18                          = New-Object -TypeName system.Windows.Forms.Label
  $Label18.text                     = "Org Unit Prefix"
  $Label18.AutoSize                 = $true
  $Label18.width                    = 25
  $Label18.height                   = 10
  $Label18.location                 = New-Object -TypeName System.Drawing.Point -ArgumentList (16,215)
  $Label18.Font                     = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',10)
  
  $OrgUnitPrefix                    = New-Object -TypeName system.Windows.Forms.TextBox
  $OrgUnitPrefix.multiline          = $false
  $OrgUnitPrefix.text               = "Org Unit Prefix"
  $OrgUnitPrefix.width              = 295
  $OrgUnitPrefix.height             = 20
  $OrgUnitPrefix.location           = New-Object -TypeName System.Drawing.Point -ArgumentList (17,235)
  $OrgUnitPrefix.Font               = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',12)
  

  $Groupbox1                       = New-Object -TypeName system.Windows.Forms.Groupbox
  $Groupbox1.height                = 202
  $Groupbox1.width                 = 312
  $Groupbox1.text                  = "Security Groups"
  $Groupbox1.location              = New-Object -TypeName System.Drawing.Point -ArgumentList (7,266)

  $globalReadSecGroup              = New-Object -TypeName system.Windows.Forms.TextBox
  $globalReadSecGroup.multiline    = $false
  $globalReadSecGroup.text         = ""
  $globalReadSecGroup.width        = 220
  $globalReadSecGroup.height       = 20
  $globalReadSecGroup.location     = New-Object -TypeName System.Drawing.Point -ArgumentList (8,52)
  $globalReadSecGroup.Font         = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',12)

  $Label5                          = New-Object -TypeName system.Windows.Forms.Label
  $Label5.text                     = "Global Security Group"
  $Label5.AutoSize                 = $true
  $Label5.width                    = 25
  $Label5.height                   = 10
  $Label5.location                 = New-Object -TypeName System.Drawing.Point -ArgumentList (8,31)
  $Label5.Font                     = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',10)

  $readSecGroup                    = New-Object -TypeName system.Windows.Forms.TextBox
  $readSecGroup.multiline          = $false
  $readSecGroup.text               = ""
  $readSecGroup.width              = 220
  $readSecGroup.height             = 20
  $readSecGroup.location           = New-Object -TypeName System.Drawing.Point -ArgumentList (8,107)
  $readSecGroup.Font               = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',12)

  $Label6                          = New-Object -TypeName system.Windows.Forms.Label
  $Label6.text                     = "Read Security Group"
  $Label6.AutoSize                 = $true
  $Label6.width                    = 25
  $Label6.height                   = 10
  $Label6.location                 = New-Object -TypeName System.Drawing.Point -ArgumentList (8,86)
  $Label6.Font                     = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',10)

  $writeSecGroup                   = New-Object -TypeName system.Windows.Forms.TextBox
  $writeSecGroup.multiline         = $false
  $writeSecGroup.text              = ""
  $writeSecGroup.width             = 220
  $writeSecGroup.height            = 20
  $writeSecGroup.location          = New-Object -TypeName System.Drawing.Point -ArgumentList (9,164)
  $writeSecGroup.Font              = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',12)

  $Label7                          = New-Object -TypeName system.Windows.Forms.Label
  $Label7.text                     = "Write Security Group"
  $Label7.AutoSize                 = $true
  $Label7.width                    = 25
  $Label7.height                   = 10
  $Label7.location                 = New-Object -TypeName System.Drawing.Point -ArgumentList (9,142)
  $Label7.Font                     = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',10)

  $Groupbox2                       = New-Object -TypeName system.Windows.Forms.Groupbox
  $Groupbox2.height                = 388
  $Groupbox2.width                 = 337
  $Groupbox2.text                  = "Structure Definition Files"
  $Groupbox2.location              = New-Object -TypeName System.Drawing.Point -ArgumentList (328,80)

  $structureView                   = New-Object -TypeName System.Windows.Forms.CheckedListBox
  $structureView.text              = "listbox"
  $structureView.width             = 316
  $structureView.height            = 364
  $structureView.location          = New-Object -TypeName System.Drawing.Point -ArgumentList (11,15)

  $orgSearch                       = New-Object -TypeName system.Windows.Forms.Button
  $orgSearch.text                  = "Search"
  $orgSearch.width                 = 60
  $orgSearch.height                = 30
  $orgSearch.location              = New-Object -TypeName System.Drawing.Point -ArgumentList (249,131)
  $orgSearch.Font                  = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',10)

  $globalSecGroupSearch            = New-Object -TypeName system.Windows.Forms.Button
  $globalSecGroupSearch.text       = "Search"
  $globalSecGroupSearch.width      = 60
  $globalSecGroupSearch.height     = 30
  $globalSecGroupSearch.location   = New-Object -TypeName System.Drawing.Point -ArgumentList (242,48)
  $globalSecGroupSearch.Font       = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',10)

  $readSecGroupSearch              = New-Object -TypeName system.Windows.Forms.Button
  $readSecGroupSearch.text         = "Search"
  $readSecGroupSearch.width        = 60
  $readSecGroupSearch.height       = 30
  $readSecGroupSearch.location     = New-Object -TypeName System.Drawing.Point -ArgumentList (242,104)
  $readSecGroupSearch.Font         = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',10)

  $writeSecGroupSearch             = New-Object -TypeName system.Windows.Forms.Button
  $writeSecGroupSearch.text        = "Search"
  $writeSecGroupSearch.width       = 60
  $writeSecGroupSearch.height      = 30
  $writeSecGroupSearch.location    = New-Object -TypeName System.Drawing.Point -ArgumentList (244,159)
  $writeSecGroupSearch.Font        = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',10)

  $Form.controls.AddRange(@($folderName,$Label1,$location,$Label2,$organisationUnit,$Label3,$createFolder,$structureLocation,$Label4,$OrgUnitPrefix,$Label18,$Groupbox1,$Groupbox2,$orgSearch))
  $Groupbox1.controls.AddRange(@($globalReadSecGroup,$Label5,$readSecGroup,$Label6,$writeSecGroup,$Label7,$globalSecGroupSearch,$readSecGroupSearch,$writeSecGroupSearch))
  $Groupbox2.Controls.AddRange(@($structureView))
  $folderName.Add_Click{ $folderName.Text = "" }
  $organisationUnit.Add_Click{ $organisationUnit.Text ="" }
  $location.Add_Click{ get-Location }
  $structureLocation.Add_Click{ load-Structure }
  $globalReadSecGroup.Add_Click{ $globalReadSecGroup.Text ="" }
  $readSecGroup.Add_Click{ $readSecGroup.Text ="" }
  $writeSecGroup.Add_Click{ $writeSecGroup.Text ="" }
  $OrgUnitPrefix.Add_Click{ $OrgUnitPrefix.Text = "" }
  $orgSearch.Add_Click{ search-Organisation }
  $readSecGroupSearch.Add_Click{ search-Read }
  $globalSecGroupSearch.Add_Click{ search-Global }
  $writeSecGroupSearch.Add_Click{ search-Write }
  #check for the enter key pressed after entering the foldername
  $folderName.Add_KeyDown({
      if ($_.KeyCode -eq "Enter") {
        #if the enter key is pressed then load the other settings from the xml file.
        get-location
      }
  })
  
  $folderName.Add_Leave({
        #if leave the field then load the other settings from the xml file.
        get-location
  })
  
  $OrgUnitPrefix.Add_Leave({
        #if leave the field then load the other settings from the xml file.
        get-prefix
  })
  $contentList = New-Object System.Windows.Forms.ToolTip
  $global:showHelp = {$contentList.SetToolTip($location, $location.Text)}
  $location.add_MouseHover($global:showHelp)
  $Form.ShowDialog()| Out-Null
}

function get-prefix{
  $prefix = $OrgUnitPrefix.Text
  if(![string]::IsNullOrEmpty($prefix)){
     $fn = $folderName.Text
     create-Folder("C:\temp\Project")
    if(Test-Path C:\temp\project\$fn.xml)
    {
      #assume because it's been clicked that we need to search
      [xml]$xmlFile = Get-Content -path "C:\temp\project\$fn.xml"
      if([string]::IsNullOrEmpty($xmlFile.Project.Prefix))
      {
        $OUPrefix = $xmlFile.Project.AppendChild($xmlFile.CreateElement("Prefix"))
        $OUPrefix.AppendChild($xmlFile.CreateTextNode($Prefix))      
      }else{
        $OUPrefix = $xmlFile.SelectSingleNode("//Prefix")
        $OUPrefix.InnerText = $Prefix
      }
      $xmlFile.Save("C:\temp\project\$fn.xml")
      $OrgUnitPrefix.Text = $Prefix
    }
  }else{
    show-message("Please enter a search string for the Organisational Unit Prefix")
  }
}

function create-Folder($path){
  if(!(test-path $path))
  {
    New-Item -ItemType Directory -Force -Path $path
  }
}

function search-Organisation{
  $OU = Select-OUs -ADOU $organisationUnit.Text
  if(![string]::IsNullOrEmpty($OU)){ 
    $fn = $folderName.Text
    create-Folder("C:\temp\Project")
    if(Test-Path C:\temp\project\$fn.xml)
    {
      #assume because it's been clicked that we need to search
      [xml]$xmlFile = Get-Content -path "C:\temp\project\$fn.xml"
      if([string]::IsNullOrEmpty($xmlFile.Project.OrganisationalUnit))
      {
        $orgUnit = $xmlFile.Project.AppendChild($xmlFile.CreateElement("OrganisationalUnit"))
        $orgUnit.AppendChild($xmlFile.CreateTextNode($OU))      
      }else{
        $orgUnit = $xmlFile.SelectSingleNode("//OrganisationalUnit")
        $orgUnit.InnerText = $OU
      }
      $xmlFile.Save("C:\temp\project\$fn.xml")
      $organisationUnit.Text = $OU
    }
  }else{
    show-message("Please enter a search string for the Organisational Unit")
  }
}

function search-Global{
  $globalRead = Select-Groups -ADGroup $globalReadSecGroup.Text
  $fn = $folderName.Text
  create-Folder("C:\temp\Project")
  if(Test-Path C:\temp\project\$fn.xml)
  {
    #assume because it's been clicked that we need to search
    [xml]$xmlFile = Get-Content -path "C:\temp\project\$fn.xml"
    if([string]::IsNullOrEmpty($xmlFile.Project.GlobalRead))
    {
      $globalGroup = $xmlFile.Project.AppendChild($xmlFile.CreateElement("GlobalRead"))
      $globalGroup.AppendChild($xmlFile.CreateTextNode($globalRead))      
    }else{
      $globalGroup = $xmlFile.SelectSingleNode("//GlobalRead")
      $globalGroup.InnerText = $globalRead
    }
    $xmlFile.Save("C:\temp\project\$fn.xml")
    $globalReadSecGroup.Text = $globalRead
  }
}

function search-Read{
  $Read = Select-Groups -ADGroup $readSecGroup.Text
  $fn = $folderName.Text
  create-Folder("C:\temp\Project")
  if(Test-Path C:\temp\project\$fn.xml)
  {
    #assume because it's been clicked that we need to search
    [xml]$xmlFile = Get-Content -path "C:\temp\project\$fn.xml"
    if(!$xmlFile.SelectSingleNode("//ReadOnly"))
    {
      $readGroup = $xmlFile.Project.AppendChild($xmlFile.CreateElement("ReadOnly"))
      $readGroup.AppendChild($xmlFile.CreateTextNode($Read))     
    }else{
      $readGroup = $xmlFile.SelectSingleNode("//ReadOnly")
      $readGroup.InnerText = $Read
    }
    $xmlFile.Save("C:\temp\project\$fn.xml")
    $readSecGroup.Text = $Read
  }
}

function search-Write{
  $Write = Select-Groups -ADGroup $writeSecGroup.Text
  $fn = $folderName.Text
  create-Folder("C:\temp\Project")
  if(Test-Path C:\temp\project\$fn.xml)
  {
    #assume because it's been clicked that we need to search
    [xml]$xmlFile = Get-Content -path "C:\temp\project\$fn.xml"
    if(!$xmlFile.SelectSingleNode("//Modify"))
    {
      $writeGroup = $xmlFile.Project.AppendChild($xmlFile.CreateElement("Modify"))
      $writeGroup.AppendChild($xmlFile.CreateTextNode($Write))      
    }else{
      $writeGroup = $xmlFile.SelectSingleNode("//Modify")
      $writeGroup.InnerText = $Write
    }
    $xmlFile.Save("C:\temp\project\$fn.xml")
    $writeSecGroup.Text = $Write
  }
}

function Get-XMLFile{
  if(![string]::IsNullOrEmpty($folderName.Text)){
    $fn = $folderName.Text
    if($fn -ne "Enter the folder name"){
      return Test-Path C:\temp\project\$fn.xml
    }else{
      return 'No Folder name'
    }
  }
}
function get-location
{   
  if([string]::IsNullOrEmpty($FolderName.Text) -or $folderName.Text -eq "Enter the Folder Name") {
    show-message("Please enter a folder name.")
  }else{

    $saveName = $folderName.Text

    switch (Get-XMLFile) 
    {
      #load xml file
      true 
      {
        [xml]$xmlFile = Get-Content -path "C:\temp\project\$saveName.xml"
        $xmlPath = $xmlFile.Project.Path
        $xmlOrgUnit = $xmlFile.Project.OrganisationalUnit
        $xmlStructure = $xmlFile.Project.Structure
        $xmlPrefix = $xmlFile.Project.Prefix
        $xmlGlobal = $xmlFile.Project.GlobalRead
        $xmlRead = $xmlFile.Project.ReadOnly
        $xmlWrite = $xmlFile.Project.Modify
        $location.Text = $xmlPath.Name
        if(![string]::IsNullOrEmpty($xmlPath))
        {
          if(![string]::IsNullOrEmpty($structureView.Items)){
            #if we are coming back to this we need to be able to set up the new focussed folder
            #check if there are items in the StructureView so as not to drop in this if on first click
            $path = Get-Folder
            $xmlPath.SetAttribute("Name", $path)
            $xmlFile.save("C:\temp\project\$saveName.xml")
            $location.Text = $xmlPath.Name
          }  
          

        }
        if(![string]::IsNullOrEmpty($xmlOrgUnit))
        {
          $organisationUnit.Text = $xmlOrgUnit
        }
        if(![string]::IsNullOrEmpty($xmlStructure) -and [string]::IsNullOrEmpty($structureView.Items))
        {
          $structureLocation.Text = $xmlStructure
          #display the structure and check the xml file for what is checked and what isn't.
          $Files = Get-ChildItem -Path $structureLocation.Text
          $structureView.Items.Clear()
          $structureView.Items.AddRange($Files)
          $structureView.CheckOnClick = $true
          $anyChecked = $false
          #now need to loop through the xml file and check for the status of the checkbox
          for($item=0; $item -lt $structureView.Items.count; $item++){
            #search in xml to see if need to change the status
            $itemName = $structureView.Items[$item]
            $FindCheck = Select-Xml -Xml $xmlFile -XPath "//*[@Name='$itemName']" | Select-Object -ExpandProperty "node"
            if($FindCheck.InnerText -eq "Checked"){
              $structureView.SetItemChecked($item, $true)
              $anyChecked = $true
            }
          }
          $structureView.Add_ItemCheck({create-Project($structureView.SelectedItem) -ErrorAction Stop})
          if(!$anyChecked){
            $createFolder.Checked = $true
          }else{
            $createFolder.Checked = $false
          }
          $createFolder.Enabled = $false
        }
        if(![string]::IsNullOrEmpty($xmlPrefix))
        {
          $OrgUnitPrefix.Text = $xmlPrefix
        }
        if(![string]::IsNullOrEmpty($xmlGlobal))
        {
          $globalReadSecGroup.Text = $xmlGlobal
        }
        if(![string]::IsNullOrEmpty($xmlRead))
        {
          $readSecGroup.Text = $xmlRead
        }
        if(![string]::IsNullOrEmpty($xmlWrite))
        {
          $writeSecGroup.Text = $xmlWrite
        }
      }
      false
      {
        create-Folder("C:\temp\Project")
        $path = Get-Folder
        [xml]$doc = New-Object System.Xml.XmlDocument
        $dec = $doc.CreateXmlDeclaration("1.0", "UTF-8", $null)
        $doc.AppendChild($dec) | Out-Null
        $text = @"
Project Creation template helper
Generated on $(Get-Date)
Programmed By Ian Bettison
"@
        $doc.AppendChild($doc.CreateComment($text)) | Out-Null
        $root = $doc.CreateNode("element","Project", $null)
        $folder = $doc.CreateElement("Folder")
        $folder.SetAttribute("Name", $folderName.text)
        $projectPath = $doc.CreateElement("Path")
        $projectPath.SetAttribute("Name", $path)
        $root.AppendChild($folder)
        $root.AppendChild($projectPath)
        $doc.AppendChild($root)      
        $doc.save("C:\temp\project\$saveName.xml")
        $location.Text = $path
      }
      "No Folder Name"
      {
        show-message('Please type a Folder Name')
      }
    }
  }
}

function load-Structure {
  if([string]::IsNullOrEmpty($FolderName.Text) -or $FolderName.Text -eq "Enter the Folder Name") {
    show-message("Please enter a folder name.")
  }else{
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $listOfFiles = $structureLocation.Text = Get-Folder
    if(![string]::IsNullOrEmpty($listOfFiles)){
      $Files = Get-ChildItem -Path $listOfFiles
      if(![string]::IsNullOrEmpty($structureView.Items)) {
        $structureView.Items.Clear()
      }
      $structureView.Items.AddRange($Files)
      $structureView.CheckOnClick = $true
      $structureView.Add_ItemCheck({create-Project($structureView.SelectedItem) -ErrorAction Stop})
      $saveName = $folderName.Text
      [xml]$xmlFile = Get-Content -path "C:\temp\project\$saveName.xml"
      if([string]::IsNullOrEmpty($xmlFile.Project.Structure))
      {
        $structure = $xmlFile.Project.AppendChild($xmlFile.CreateElement("Structure"))
        $structure.AppendChild($xmlFile.CreateTextNode($listOfFiles))      
      }else{
        $structure = $xmlFile.SelectSingleNode("//Structure")
        $structure.InnerText = $listOfFiles
      }
      if([string]::IsNullOrEmpty($xmlFile.Project.StructureListing)){
        $structureListing = $xmlFile.Project.AppendChild($xmlFile.CreateElement("StructureListing"))
        foreach($file in $files){
          $structureList = $structureListing.AppendChild($xmlFile.CreateElement("StructureList"))
          $structureList.SetAttribute("Name", $file.Name)
          $structureList.AppendChild($xmlFile.CreateTextNode("UnChecked"))
        }
        # we have just created a new list so lets check and disable the create folder checkbox
        $createFolder.Checked = $true
        $createFolder.Enabled = $false
      }
      $xmlFile.Save("C:\temp\project\$saveName.xml")
    }
  }
}

function create-Project( $fileSelect ) {
  Add-Type -AssemblyName PresentationFramework
  $choice = [System.Windows.MessageBox]::Show('Confirm you want to create the project folders?', 'Confirmation', 4)
  if($choice -eq 'Yes') {
    #now need to check if all of the settings have been set before we go
    try
    {
      if([string]::IsNullOrEmpty($FolderName.Text) -or $folderName.Text -eq "Enter the Folder Name") {
          $Error_Format_Error = [String] "The Folder Name has not been entered"
          Write-Error $Error_Format_Error
          return
       } 
      if([string]::IsNullOrEmpty($Location.Text) -or $Location.Text -eq "Location") {
          $Error_Format_Error = [String] "The location has not been entered"
          Write-Error $Error_Format_Error
          return
       }
       if([string]::IsNullOrEmpty($OrganisationUnit.Text) -or $OrganisationUnit.Text -eq "Organisational Unit") {
          $Error_Format_Error = [String] "The OU has not been entered"
          Write-Error $Error_Format_Error
          return
       }
       if([string]::IsNullOrEmpty($StructureLocation.Text) -or $StructureLocation.Text -eq "Structure Location") {
          $Error_Format_Error = [String] "The Structure location has not been entered"
          Write-Error $Error_Format_Error
          return
       }
       if([string]::IsNullOrEmpty($OrgUnitPrefix.Text) -or $OrgUnitPrefix.Text -eq "Org Unit Prefix") {
          $Error_Format_Error = [String] "The OU Prefix has not been entered"
          Write-Error $Error_Format_Error
          return
       }       
    }
    catch
    {
      #There is a problem with the information passed to the function by the user
      Write-Error -Message "There has been an Error. Error was: $_" -ErrorAction Stop
    }
    $OUCreated = create-OU
    $newGroup = add-GlobalGroup
    $newFolders = Add-FolderStructure($fileSelect)
    Write-Host
    Write-Host "The process has completed."
    
    # now update the checked structure items in the xml
    $saveName = $folderName.Text
    [xml]$xmlFile = Get-Content -path "C:\temp\project\$saveName.xml"
    $FindCheck = Select-Xml -Xml $xmlFile -XPath "//*[@Name='$fileSelect']" | Select-Object -ExpandProperty "node"
    $FindCheck.InnerText = "Checked"
    $xmlFile.Save("C:\temp\project\$saveName.xml")
    #action has completed so we need to prompt for a new location to create the next folders
    $Location.Text = ""
    # we know the project folder has been created so let's uncheck the Create Folder CheckBox
    $createFolder.Checked = $false
    #show-message('Now need to select a new location for the additional project folders')
    #$path = Get-Folder
    #$location.Text = $path
    
  }
}


function create-OU {
  $OUPath = $organisationUnit.Text
  $prefix = $OrgUnitPrefix.Text
  try
  {      
    #Create a new Project List group to add Read and Execute Access
    $newFolderList = $prefix+$folderName.Text+"_Auto_ListProject"
    if($CreateFolder.Checked -eq $true)
    {
              
      #join the selected path and the entered foldername to form the working folder path
      $newFolder =join-Path -Path $location.Text -ChildPath $folderName.text
      #If required a new folder is created 
      #check if folder exists already
      if(-not (test-path -Path $newFolder -PathType Container)) {
        #creates the new folder 
        New-Item -ItemType directory -Path $newFolder -ErrorAction Stop 
      }
      if(![string]::IsNullOrEmpty($OUPath))
      {
        #create a new OU for the new project security groups 
        New-ADOrganizationalUnit -Name $folderName.Text -Path $OUPath
        New-ADGroup -Name $newFolderList -GroupCategory Security -GroupScope Global -Path ("OU={0},{1}" -f $folderName.Text, $OUPath) -Description ("\{0}" -f $folderName.Text)    
        add-AclToFolder($newFolder, $newFolderList)
      }
    }      
  }
  catch
  {
    #if the folder cannot be created the error is captured here
    Write-Error -Message "There has been an Error. Error was: $_" -ErrorAction Stop
  }

}
function add-AclToFolder( $folder, $secGroup) {
  $acl = Get-Acl $newFolder
        
  <#Parameters for SetAccessRuleProtection
      isProtected
      Boolean
      true to protect the access rules associated with this ObjectSecurity object from inheritance; false to allow inheritance.

      preserveInheritance
      Boolean
      true to preserve inherited access rules; false to remove inherited access rules. This parameter is ignored if isProtected is false.
  #>        
  #break the inheritence and copy the inherited access rules 
  $acl.SetAccessRuleProtection($true,$true)
  $ruleIdentitySId = (Get-ADGroup -Filter {Name -eq $newFolderList}).SID
  $ruleParams = $ruleIdentitySId, "ListDirectory", "Allow"
  #Create the Access rule
  $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($ruleParams)
  #Add the Access rule to the Access control List
  $acl.AddAccessRule($rule)
  #Set the Access Control List
  (Get-Item $newFolder).SetAccessControl($acl)
}

function add-GlobalGroup {
  $newFolder = $location.Text
  $prefix = $OrgUnitPrefix.Text
  $newFolderList = $prefix+$folderName.Text+"_Auto_ListProject"
  ############################################
  #get the access control list from the folder
  $acl = Get-Acl $newFolder
        
  <#Parameters for SetAccessRuleProtection
      isProtected
      Boolean
      true to protect the access rules associated with this ObjectSecurity object from inheritance; false to allow inheritance.

      preserveInheritance
      Boolean
      true to preserve inherited access rules; false to remove inherited access rules. This parameter is ignored if isProtected is false.
  #>        
  #break the inheritence and copy the inherited access rules 
  $acl.SetAccessRuleProtection($true,$true)
       
  #check if Groups have been selected
  if(![string]::IsNullOrEmpty($globalReadSecGroup.Text)) 
  {
    ###############################################################################
    #for the selected groups add Read and Execute access for them to the new folder 

    $ruleIdentity = Get-ADGroup -Filter {Name -eq $globalReadSecGroup.Text}
    $ruleParams = $ruleIdentity.SID, "ReadAndExecute", "ContainerInherit, ObjectInherit","None", "Allow"
    #Create the Access rule
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($ruleParams)
    #Add the Access rule to the Access control List
    $acl.AddAccessRule($rule)                        
   
       
  }       
  $ruleIdentitySId = (Get-ADGroup -Filter {Name -eq $newFolderList}).SID
  $ruleParams = $ruleIdentitySId, "ListDirectory", "Allow"
  #Create the Access rule
  $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($ruleParams)
  #Add the Access rule to the Access control List
  $acl.AddAccessRule($rule)
  #Set the Access Control List
  (Get-Item $newFolder).SetAccessControl($acl)
}

function Add-FolderStructure($selectedFile){
  $prefix = $OrgUnitPrefix.Text
  $newFolderList = $prefix+$folderName.Text+"_Auto_ListProject"
  #if a structure file is not chosen then the script ends
    #retrieve the contents of the file
    $fileLocation = join-Path -Path $Structurelocation.Text -ChildPath $selectedFile
    $content = Get-Content -Path $fileLocation
    #Split the file contents on a semicolon to create a folders array.
    $folders = $content -split ";"
    $folderCount = 1
    # at this point need to strip off the first item in the folders array and save the name to be used in the naming of the groups.
    $groupName = $folders[0]
    $remove=0
    $folders = $folders | Where-Object { $_ -ne $folders[$remove] }
    # lets remove all the blank values need to make sure there are no spaces after the semicolon ; on each line.
    $folders = $folders | Where-Object -FilterScript {$_ -ne ""}
    #now we need to add the groups to the read only permission group and the write security group
    if(![string]::IsNullOrEmpty($ReadSecGroup.Text)){

      $ReadOnlyGroups = (Get-ADGroup -Filter {Name -eq $ReadSecGroup.Text}).SID
    }
    if(![string]::IsNullOrEmpty($WriteSecGroup.Text)){
      $WriteGroups = (Get-ADGroup -Filter {Name -eq $WriteSecGroup.Text}).SID
    }
     
    $GroupPrefix = $prefix       
    ##############################################################################
    #Loop through the folders creating the the new folders if required from the structure file 
    #Also create a folder Access group
    foreach($folder in $folders) 
    {
      if($CreateFolder.Checked -eq $true) {
        $newSubPath = join-Path -Path $location.Text -ChildPath $folderName.Text
      }else{
        $newSubPath = $location.Text
      }
      
      #create the subfolder path
      $newSubFolder = join-Path -Path $newSubPath -ChildPath $folder
      $newFolderAccess = $GroupPrefix+$folderName.Text+"_"+$groupName+"_Auto_FolderAccess_"+$folderCount
      $newFolderAccessWrite = $GroupPrefix+$folderName.Text+"_"+$groupName+"_Auto_FolderAccess_Write_"+$folderCount
      try
      {
        #Check for the existence of the group
        $checkExists = Get-ADGroup -Identity $newFolderAccess 
      }
      catch
      {
        #if the Groups dont exist create them
        Write-Error -Message "Group Not found, creating it '$newFolderAccess'. Error was: $_" -ErrorAction SilentlyContinue
        New-ADGroup -Name $newFolderAccess -GroupCategory Security -GroupScope Global -Path ("OU={0},{1}" -f $folderName.Text, $organisationUnit.Text) -Description ("\{0}\{1}" -f $folderName.Text, $folder)
        New-ADGroup -Name $newFolderAccessWrite -GroupCategory Security -GroupScope Global -Path ("OU={0},{1}" -f $folderName.Text, $organisationUnit.Text) -Description ("\{0}\{1}" -f $folderName.Text, $folder)              
      }
                       
      #if required create the new subfolder           
      New-Item -ItemType directory -Path $newSubFolder -ErrorAction Stop
      Write-Host ("Creating Folder '{0}'" -f $folder) -ForegroundColor Cyan
           
      #Get the access control list of the new sub folder
      $aclSub = Get-Acl $newSubFolder
      #break the inheritence and copy the inherited access rules 
      $aclSub.SetAccessRuleProtection($true,$true)
           
      ##########################################################
      #for the new/existing subfolder add the selected groups with read             
      $ruleIdentity = Get-ADGroup -Filter {Name -eq $globalReadSecGroup.Text}
      $ruleParams = $ruleIdentity.SID, "ReadAndExecute", "ContainerInherit, ObjectInherit","None", "Allow"
      #Create the Access control rule for the sub folder
      $ruleSub = New-Object System.Security.AccessControl.FileSystemAccessRule($ruleParams) 
      #Add the rule to the access control list
      $aclSub.AddAccessRule($ruleSub)               
      ######################################
      #Now add the rights for the new access
      # get the SID of the group (for more consistency)
      $strSId = (Get-ADGroup -Filter {Name -eq $newFolderAccess}).SID
             
      if(![string]::IsNullOrEmpty($ReadOnlyGroups)){ 
        #now add the selected read only groups to the new group
        $strRO_SId = $ReadOnlyGroups 
      }
             
      #add the Folder Access Group
      $ruleSubParams = $strSId, "ReadAndExecute", "ContainerInherit, ObjectInherit","None", "Allow"
      #Create the Access control rule for the sub folder
      $ruleSub = New-Object System.Security.AccessControl.FileSystemAccessRule($ruleSubParams)
      #Add the rule to the access control list
      $aclSub.AddAccessRule($ruleSub)
      ######################################
      #Now add the rights for the new access
      # get the SID of the group (for more consistency)
      $strSId1 = (Get-ADGroup -Filter {Name -eq $newFolderAccessWrite}).SID
             
      if(![string]::IsNullOrEmpty($WriteGroups)){ 
        #now add the selected Write groups to the new group
        $strW_SId = $WriteGroups  
      }                    
                         
      #add the Folder Access Group
      $ruleSubParams = $strSId1, "Modify", "ContainerInherit, ObjectInherit","None", "Allow"
      #Create the Access control rule for the sub folder
      $ruleSub1 = New-Object System.Security.AccessControl.FileSystemAccessRule($ruleSubParams)
      #Add the rule to the access control list
      $aclSub.AddAccessRule($ruleSub1)
      
      $ruleIdentitySId = (Get-ADGroup -Filter {Name -eq $newFolderList}).SID       
      #add the Folder Access Group
      $ruleSubParams = $ruleIdentitySId, "ListDirectory", "Allow"
      #Create the Access control rule for the sub folder
      $ruleSub2 = New-Object System.Security.AccessControl.FileSystemAccessRule($ruleSubParams)
      #Add the rule to the access control list
      $aclSub.AddAccessRule($ruleSub2)
              
      ##################################################################
      #Add the new group for the folder access to the Folder List group.
      $sId = (Get-ADGroup "$newFolderList").SID
      Add-ADGroupMember -Identity $sId -Members $strSId
      Add-ADGroupMember -Identity $sId -Members $strSId1
      if(![string]::IsNullOrEmpty($ReadOnlyGroups)){
        Add-ADGroupMember -Identity $strSId -Members $strRO_SId
      }
      if(![string]::IsNullOrEmpty($WriteGroups)){ 
        Add-ADGroupMember -Identity $strSId1 -Members $strW_SId
      }
             
      #Set the access control rule to the list.
      (Get-Item $newSubFolder).SetAccessControl($aclSub)
      Write-Host ("Access created for '{0}'" -f $folder) -ForegroundColor Cyan
      Write-Host
      $folderCount++
    }
    #Lastly add the folder list group to the Project List group
    #Add-ADGroupMember -Identity "NTRF_List_Projects" -Members $sId
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
 
 function Select-OUs
 {
   <#
       .SYNOPSIS
       Allows a search for a partial text to match AD OUs and list them
       .DESCRIPTION
       Search to find the list of Active Directory OUs matching the partial string parameter -ADGroup then displays the members of that group 
       .EXAMPLE
       Select-Groups -ADOU Projects
       This will search for Active Directory Group matching the partial text passed using the -ADGroup parameter and return the members of the group and the group name
   #>
   param
   (
     [Parameter(Mandatory, Position=0)]
     [String]
     $ADOU    
   )
   
   $ErrorActionPreference = "Stop"
   [hashtable]$return = @{}
   try 
   {
     if([string]::IsNullOrEmpty($ADOU))
     {
       throw 'Cannot search on NULL data.'
     }
     # adds asterisks to the passed parameter to pass into the filter option in the scriptBlock below.		
     $ADOU = '*' + $ADOU + '*'
     write-host 'Searching for Organisational Units in Active Directory...'
     # Start a job to list all of the Active Directory Groups matching the parameter (No output)
     Start-Job -Name getList -ScriptBlock {param([Parameter(Mandatory,HelpMessage='Enter the Partial Organisational Unit')][String]$pOU) Get-ADOrganizationalUnit -Filter {Name -like $pOU} -Properties * | Select-Object -Property Name, DistinguishedName} -ArgumentList $ADOU | Out-Null
     # wait for the job to finish (No output)
     Wait-Job -Name getList | Out-Null
     # It is now safe to receive the output from the job.
     $OUList = Receive-Job -Name getList | Sort-Object
     # has the search returned any information
     if([string]::IsNullOrEmpty($OUList)) 
     {
       throw 'OU was not found.'
     }
     else
     {
       # setup a grid view to select the Group Multiple selection
       $Idx =0
       $OU = $(foreach ($item in $OUList){
           $item | Select-Object -Property @{l='IDX'
           e={$Idx}}, Name, DistinguishedName
       $Idx++	}) |
       Out-GridView -Title 'Select the AD OU' -OutputMode Single |
       ForEach-Object { $OUList[$_.IDX] }
     }
   }
   catch
   {
     Write-Host ('ERROR : {0}' -f $_) -ForegroundColor Red
   }
   return $OU.DistinguishedName
 }