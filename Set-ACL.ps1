function add-AclToFolder {
   param
   (
     [Parameter(Mandatory=$true, Position=0)]
     [String]
     $folderParam,
     [Parameter(Mandatory=$true, Position=1)]
     [String]
     $secGroupParam,
     [Parameter(Mandatory=$true, Position=3)]
     [String] $setAccessTypeParam
         
   )
  $acl = Get-Acl $folderParam
        
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
  #need a pause here for things to catch up
  Start-Sleep -Seconds 2
  $ruleIdentitySId = (Get-ADGroup -Filter {Name -eq $secGroupParam}).SID
  Switch($setAccessTypeParam)
  {
    "List" 
    {
      $ruleParams = $ruleIdentitySId, "ListDirectory", "Allow"
    }
    "Read"
    {
      $ruleParams = $ruleIdentitySId, "ReadAndExecute", "ContainerInherit, ObjectInherit","None", "Allow"
    }
    "Write"
    {
      $ruleParams = $ruleIdentitySId, "Modify", "ContainerInherit, ObjectInherit","None", "Allow"
    }
  }
  
  #Create the Access rule
  $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($ruleParams)
  #Add the Access rule to the Access control List
  $acl.SetAccessRule($rule)
  #Set the Access Control List
  (Get-Item $folderParam).SetAccessControl($acl)
  Get-Acl $folderParam | ForEach-Object Access
  
}
add-AclToFolder "\\campus\dept\crf\IT\Projects\OACS-2\TMF\14. Randomisation" "CTU_TRIAL_OACS-2_Modify_Auto" "read"