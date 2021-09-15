function Add-ParticipatingSites 
{
  Add-Type -AssemblyName System.Windows.Forms
  Add-Type -AssemblyName System.Drawing
  [System.Windows.Forms.Application]::EnableVisualStyles()

  $Form                            = New-Object -TypeName system.Windows.Forms.Form
  $Form.ClientSize                 = New-Object -TypeName System.Drawing.Point -ArgumentList (672,450)
  $Form.text                       = "Creation of Participating Sites"
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
  $structureLocation.location      = New-Object -TypeName System.Drawing.Point -ArgumentList (17,135)
  $structureLocation.Font          = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',12)

  $Label4                          = New-Object -TypeName system.Windows.Forms.Label
  $Label4.text                     = "Structure Location"
  $Label4.AutoSize                 = $true
  $Label4.width                    = 25
  $Label4.height                   = 10
  $Label4.location                 = New-Object -TypeName System.Drawing.Point -ArgumentList (16,115)
  $Label4.Font                     = New-Object -TypeName System.Drawing.Font -ArgumentList ('Microsoft Sans Serif',10)

  $Groupbox1                       = New-Object -TypeName system.Windows.Forms.Groupbox
  $Groupbox1.height                = 202
  $Groupbox1.width                 = 312
  $Groupbox1.text                  = "Security Groups"
  $Groupbox1.location              = New-Object -TypeName System.Drawing.Point -ArgumentList (7,196)

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
  $Groupbox2.height                = 318
  $Groupbox2.width                 = 337
  $Groupbox2.text                  = "Structure Definition Files"
  $Groupbox2.location              = New-Object -TypeName System.Drawing.Point -ArgumentList (328,80)

  $structureView                   = New-Object -TypeName System.Windows.Forms.CheckedListBox
  $structureView.text              = "listbox"
  $structureView.width             = 316
  $structureView.height            = 294
  $structureView.location          = New-Object -TypeName System.Drawing.Point -ArgumentList (11,15)

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

  $Form.controls.AddRange(@($folderName,$Label1,$location,$Label2,$createFolder,$structureLocation,$Label4,$Groupbox1,$Groupbox2))
  $Groupbox1.controls.AddRange(@($globalReadSecGroup,$Label5,$readSecGroup,$Label6,$writeSecGroup,$Label7,$globalSecGroupSearch,$readSecGroupSearch,$writeSecGroupSearch))
  $Groupbox2.Controls.AddRange(@($structureView))
  $folderName.Add_Click{ $folderName.Text = "" }
  $location.Add_Click{ get-Location }
  $structureLocation.Add_Click{ load-Structure }
  $globalReadSecGroup.Add_Click{ $globalReadSecGroup.Text ="" }
  $readSecGroup.Add_Click{ $readSecGroup.Text ="" }
  $writeSecGroup.Add_Click{ $writeSecGroup.Text ="" }
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
 
  $contentList = New-Object System.Windows.Forms.ToolTip
  $global:showHelp = {$contentList.SetToolTip($location, $location.Text)}
  $location.add_MouseHover($global:showHelp)
  $Form.ShowDialog()| Out-Null
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
        #chec if the folder exists if not create it
        create-Folder("C:\temp\Project")
        #get the project folder
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

function load-Structure 
{
  if([string]::IsNullOrEmpty($FolderName.Text) -or $FolderName.Text -eq "Enter the Folder Name") {
    show-message("Please enter a folder name.")
  }else{
    Write-Host ("Loading the Structure") -ForegroundColor Cyan
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    #get the folder that points to the structure definition file (xml)
    $listOfFiles = $structureLocation.Text = Get-Folder
    if(![string]::IsNullOrEmpty($listOfFiles)){
      #get all of the files in the folder
      $Files = Get-ChildItem -Path $listOfFiles
      if(![string]::IsNullOrEmpty($structureView.Items)) {
        #clear the list to write it again
        $structureView.Items.Clear()
      }
      #create the range in the structure list box
      $structureView.Items.AddRange($Files)
      #add a checkbox to them
      $structureView.CheckOnClick = $true
      $structureView.Add_ItemCheck({create-Project($structureView.SelectedItem) -ErrorAction Stop})
      #set the name to retrieve the xml status file
      $saveName = $folderName.Text
      [xml]$xmlFile = Get-Content -path "C:\temp\project\$saveName.xml"
      #check if the structure has bee created in the status file
      if([string]::IsNullOrEmpty($xmlFile.Project.Structure))
      {
        #create the structure
        $structure = $xmlFile.Project.AppendChild($xmlFile.CreateElement("Structure"))
        $structure.AppendChild($xmlFile.CreateTextNode($listOfFiles))      
      }else{
        #if structure exists then load it
        $structure = $xmlFile.SelectSingleNode("//Structure")
        $structure.InnerText = $listOfFiles
      }
      if([string]::IsNullOrEmpty($xmlFile.Project.StructureListing)){
        #if doesn't exist in the status xml file then create it 
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
  $choice = [System.Windows.MessageBox]::Show('Confirm you want to create the participating Sites?', 'Confirmation', 4)
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

       if([string]::IsNullOrEmpty($StructureLocation.Text) -or $StructureLocation.Text -eq "Structure Location") {
          $Error_Format_Error = [String] "The Structure location has not been entered"
          Write-Error $Error_Format_Error
          return
       }
       
    }
    catch
    {
      #There is a problem with the information passed to the function by the user
      Write-Error -Message "There has been an Error. Error was: $_" -ErrorAction Stop
    }

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
function Add-FolderStructure($selectedFile){
  
  #if a structure file is not chosen then the script ends
    #retrieve the contents of the XML file
    $fileLocation = join-Path -Path $Structurelocation.Text -ChildPath $selectedFile
    $baseFolder = $location.Text +"\"+ $folderName.Text +"\TMF"
    $baseSecFolder = $location.Text+"\" + $folderName.Text +"\TMF Secure"
    [xml]$xmlFile = Get-Content -path $fileLocation
    $folders = $xmlFile.Project.FolderList
    $HeaderDetail = $xmlFile.Project.Header
    $path = $HeaderDetail.Path.Name
    $Link = $HeaderDetail.Link.Name
    $sitesLocation = join-path -path $Structurelocation.Text -ChildPath $Link
    [xml]$xmlSiteFile = Get-Content -path $sitesLocation
    $sitesFolders = $xmlSiteFile.Project.FolderList
    $Level = $HeaderDetail.Level.Name
    foreach($sites in $sitesFolders.Folder){
      #this is the name of the Site folder and the folders 'a' to 'n' are created below this folder.
      $siteName = $sites.attributes['Name'].value
      foreach($folder in $folders.Folder) 
      {
        $folderPath = $baseFolder+$path
        #add the site name to path
        $folderpath = join-path -path $folderpath -ChildPath $siteName
        #if required create the new subfolder
        $createName = $folder.attributes['Name'].value
        $protected = $folder.attributes['Protected'].value
        $addFolder = Join-Path -Path $folderPath -ChildPath $createName        
        if(![String]::IsNullOrEmpty($protected)){
          #need to create a folder in the TMF Secure area also
          #with a link to it in the TMF structure
          Write-Host ("Protected Folder") -ForegroundColor Gray          
          $protectedPath = $baseSecFolder+$path 
          #add the sitename to the path
          $protectedPath = Join-Path -Path $protectedPath -ChildPath $siteName       
          $addProtectedFolder = Join-Path -Path $protectedPath -ChildPath $createName
          Write-Host ("Creating Folder '{0}'" -f $addProtectedFolder) -ForegroundColor Cyan
          New-Item -ItemType directory $addProtectedFolder -ErrorAction stop
          #need to create a shortcut in the none protected area to this new folder
          #need to check that the folder holding this .lnk is itself not a .lnk before we create it
          if(Test-Path -Path $folderPath -PathType Container){
            # the folder is indeed a folder so let's create a .lnk to the secure area
            $wshshell = New-Object -ComObject WScript.Shell
            $lnk = $wshshell.CreateShortcut($addFolder+".lnk") 
            $lnk.TargetPath =$addProtectedFolder
            $lnk.Save()             
          } 
        }else{
          New-Item -ItemType directory -Path $addFolder -ErrorAction Stop
          Write-Host ("Creating Folder '{0}'" -f $addFolder) -ForegroundColor Cyan
        }        
      }
    }
    #the process has completed so now need to update the form    
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
