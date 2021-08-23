function Set-ProjectFolder
{
  <#
      .SYNOPSIS
      Creates a project folder structure
      .DESCRIPTION
      Selects a folder which is the starting point for creating or changing the access on a project folder, if required it creates a new project folder 
      and then removes inheritence and adds user selected read only group access. After reading a semicolon delimited text file
      it loops through the items in the file creating folders of the same name. It allows the selection of permission groups to add to the folders
      and allows selection of further groups to add read only or write permissions. 
      .PARAMETERS
      $Path         - The location where the folder structure will be created
      $CreateFolder - A boolean option to create the initial top level project folder
      $ProjectOU    - The search criteria to find the correct OU to add the project permission groups to - this is a part search variable eg. Typing Projects
        will find all OU structures containing the word Projects
      $Folder       - This parameter is the folder name of the Top Level folder and will be the name of the folder created when $CreateFolder is set to true
        it also forms part of the naming convention for the project permission groups
      .EXAMPLE
      Example 1: Set-ProjectFolder -path \\campus\dept\CRF\IT -CreateFolder $true (This will create a folder under the path specified and subfolders under that 
        - you will be prompted for the search criteria for which OU to use and the project folder name)
      Example 2: Set-ProjectFolder -CreateFolder $true (This will allow a search for the path and create the new project folder and subfolders 
        - you will be prompted for the search criteria for which OU to use and the project folder name)
      Example 3: Set-ProjectFolder (This will allow a search for the path and will add the selected security groups to the project folder and the subfolders too
        - you will be prompted for the search criteria for which OU to use and the project folder name)
      Example 4: Set-ProjectFolder -ProjectOU 'Projects' -Folder 'NewProjectName' (This will allow a search for the path, not create a new project folder 
        and auto search for the OU where the permission groups will be created

      .RETURNS
      Confirmation of the creation of the folders
  #>
  param
  (
    [Parameter(Position=0)]
    [string]
    $Path,
    [Parameter(Position=0)]
    [bool]
    $CreateFolder = $false,
    [Parameter(Position=0)]
    [string]
    $ProjectOU,
    [Parameter(Position=0)]
    [string]
    $Folder,
    [Parameter(Position=0)]
    [string]
    $GroupPrefix = 'NTRF_'
  )
  Add-Type -AssemblyName System.Windows.Forms
  Add-Type -AssemblyName PresentationFramework
  
  $continue="y"
  $OUPath = ""
  while($continue -eq "y"){

    if([string]::IsNullOrEmpty($Path)) 
    {
      $Path = Get-Folder
    }
  
    $ReadOnlyGroups = ""
    $WriteGroups = ""
    if(![string]::IsNullOrEmpty($Path)) 
    {
      #Enter the new folder or the existing folder you want to change the access on
      if([string]::IsNullOrEmpty($Folder)) 
      {
          $folderName = Read-Host -Prompt 'Please enter the New Project Folder Name'
      }
      else
      {
          $folderName = $Folder
      }
      if([string]::IsNullOrEmpty($ProjectOU)){

          $OUPathSelector = Read-Host -Prompt 'Please enter an OU to Search for: (Partial Search allowed) eg. Projects'
      }
      else
      {
          $OUPathSelector = $ProjectOU
      }
      #if no OU selected the function exits
       if(![string]::IsNullOrEmpty($OUPathSelector)){
         #if no folder entered the function exits
         if(![string]::IsNullOrEmpty($folderName)) 
         {
           try
           {
              if([string]::IsNullOrEmpty($OUPath)) { 
                 #need to select where the security groups are to be saved to.
                 $OUPath =Select-OUs -ADOU $OUPathSelector
              }
              if([string]::IsNullOrEmpty($OUPath)) {
                Write-Error "The OU Path cannot be empty" -ErrorAction Stop
              }           
              $newFolder = $Path
              #Create a new Project List group to add Read and Execute Access
              $newFolderList = $GroupPrefix+$folderName+"_Auto_ListProject"
              if($CreateFolder -eq $true)
              {
              
                #join the selected path and the entered foldername to form the working folder path
                $newFolder =join-Path -Path $Path -ChildPath $folderName
                #If required a new folder is created 
                #check if folder exists already
                if(-not (test-path -Path $newFolder -PathType Container)) {
                  #creates the new folder 
                  New-Item -ItemType directory -Path $newFolder -ErrorAction Stop 
                }
                if(![string]::IsNullOrEmpty($OUPath))
                {
                  #create a new OU for the new project security groups 
                  New-ADOrganizationalUnit -Name $folderName -Path $OUPath
                  New-ADGroup -Name $newFolderList -GroupCategory Security -GroupScope Global -Path ("OU={0},{1}" -f $folderName, $OUPath) -Description ("\{0}" -f $folderName)    
                }
              }      
           }
           catch
           {
             #if the folder cannot be created the error is captured here
             Write-Error -Message "There has been an Error. Error was: $_" -ErrorAction Stop
           }
       
           #Enter a search variable to find the security groups to add to the folders.
           $search = Read-Host 'Now select the security groups to have access to this new folder - Partial Search is available eg. CTU_'
           if(![string]::IsNullOrEmpty($search)){
               #module to select and return the groups from the search variable
               $groups = Select-Groups -ADGroup $search
            }
       
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
           if(![string]::IsNullOrEmpty($groups)) {
              ###############################################################################
             #for the selected groups add Read and Execute access for them to the new folder 
             foreach($group in $groups)
             {
                  $ruleIdentity = Get-ADGroup -Filter {Name -eq $group}
                  $ruleParams = $ruleIdentity.SID, "ReadAndExecute", "ContainerInherit, ObjectInherit","None", "Allow"
                  #Create the Access rule
                  $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($ruleParams)
                  #Add the Access rule to the Access control List
                  $acl.AddAccessRule($rule)                        
             }
       
           }      
       
           $ruleIdentitySId = (Get-ADGroup -Filter {Name -eq $newFolderList}).SID
           $ruleParams = $ruleIdentitySId, "ListDirectory", "Allow"
           #Create the Access rule
           $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($ruleParams)
           #Add the Access rule to the Access control List
           $acl.AddAccessRule($rule)
           #Set the Access Control List
           (Get-Item $newFolder).SetAccessControl($acl)
           read-host "Now the next prompt is for the file containing the folder structure (Press enter to continue)"
           #############################################################################################
           #Use module Get-File to select the file containing the folder structure required to replicate.
           $StructureFile = Get-File
       
           #if a structure file is not chosen then the script ends
           if(![string]::IsNullOrEmpty($StructureFile)) 
           {
             #retrieve the contents of the file
             $content = Get-Content -Path $StructureFile
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
             #Enter a search variable to find the security groups to add to the folders.
             $search = Read-Host 'Now select the security groups to have READ ONLY Access - Partial Search is available eg. CTU_'
             if(![string]::IsNullOrEmpty($search)){
                 #module to select and return the groups from the search variable
                 $ReadOnlyGroups = Select-Groups -ADGroup $search
             }
             $search = Read-Host 'Now select the security groups to have WRITE Access - Partial Search is available eg. CTU_'
             if(![string]::IsNullOrEmpty($search)){
                 #module to select and return the groups from the search variable
                 $WriteGroups = Select-Groups -ADGroup $search
             }
           
             ##############################################################################
             #Loop through the folders creating the the new folders if required from the structure file 
             #Also create a folder Access group
             foreach($folder in $folders) 
             {
               #create the subfolder path
               $newSubFolder = join-Path -Path $newfolder -ChildPath $folder
               $newFolderAccess = $GroupPrefix+$folderName+"_"+$groupName+"_Auto_FolderAccess_"+$folderCount
               $newFolderAccessWrite = $GroupPrefix+$folderName+"_"+$groupName+"_Auto_FolderAccess_Write_"+$folderCount
               try
               {
                 #Check for the existence of the group
                 $checkExists = Get-ADGroup -Identity $newFolderAccess 
               }
               catch
               {
                  #if the Groups dont exist create them
                  Write-Error -Message "Group Not found, creating it '$newFolder'. Error was: $_" -ErrorAction SilentlyContinue
                  New-ADGroup -Name $newFolderAccess -GroupCategory Security -GroupScope Global -Path ("OU={0},{1}" -f $folderName, $OUPath.DistinguishedName) -Description ("\{0}\{1}" -f $folderName, $folder)
                  New-ADGroup -Name $newFolderAccessWrite -GroupCategory Security -GroupScope Global -Path ("OU={0},{1}" -f $folderName, $OUPath.DistinguishedName) -Description ("\{0}\{1}" -f $folderName, $folder)              
               }
                       
               #if required create the new subfolder           
               New-Item -ItemType directory -Path $newSubFolder -ErrorAction Stop
           
               #Get the access control list of the new sub folder
               $aclSub = Get-Acl $newSubFolder
               #break the inheritence and copy the inherited access rules 
               $aclSub.SetAccessRuleProtection($true,$true)
           
               ##########################################################
               #for the new/existing subfolder add the selected groups with read
               foreach($group in $groups)
               {             
                 $ruleSubIdentity = $group.SamAccountName
                 $ruleSubParams = $ruleSubIdentity, "ReadAndExecute", "ContainerInherit, ObjectInherit","None", "Allow"
                 #Create the Access control rule for the sub folder
                 $ruleSub = New-Object System.Security.AccessControl.FileSystemAccessRule($ruleSubParams) 
                 #Add the rule to the access control list
                 $aclSub.AddAccessRule($ruleSub)             
               }  
               ######################################
               #Now add the rights for the new access
               # get the SID of the group (for more consistency)
               $strSId = (Get-ADGroup "$newFolderAccess").SID
             
               if(![string]::IsNullOrEmpty($ReadOnlyGroups)){ 
                 #now add the selected read only groups to the new group
                 foreach($ReadOnlyGroup in $ReadOnlyGroups){
                    $strRO_SId = (Get-ADGroup $ReadOnlyGroup.SamAccountName).SID 
                 }
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
               $strSId1 = (Get-ADGroup "$newFolderAccessWrite").SID
             
               if(![string]::IsNullOrEmpty($ReadOnlyGroups)){ 
                 #now add the selected Write groups to the new group
                 foreach($WriteGroup in $WriteGroups){
                     $strW_SId = (Get-ADGroup $WriteGroup.SamAccountName).SID 
                 }  
               }                    
                         
               #add the Folder Access Group
               $ruleSubParams = $strSId1, "Modify", "ContainerInherit, ObjectInherit","None", "Allow"
               #Create the Access control rule for the sub folder
               $ruleSub1 = New-Object System.Security.AccessControl.FileSystemAccessRule($ruleSubParams)
               #Add the rule to the access control list
               $aclSub.AddAccessRule($ruleSub1)
             
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
               Add-ADGroupMember -Identity $strSId -Members $strRO_SId
               Add-ADGroupMember -Identity $strSId1 -Members $strW_SId
             
               #Set the access control rule to the list.
               (Get-Item $newSubFolder).SetAccessControl($aclSub)
               $folderCount++
             }
             #Lastly add the folder list group to the Project List group
             #Add-ADGroupMember -Identity "NTRF_List_Projects" -Members $sId
           
           }
         }
      }
    }
    # need to negate $createFolder as this should only happen once.
    $CreateFolder = $false 
    $continue = Read-Host 'Anymore folders to create? Y/N'
  }
}

