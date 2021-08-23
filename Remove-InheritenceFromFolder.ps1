#remove inheritence from trials folder.
$folder = Get-Folder
$acl = Get-Item $folder | Get-Acl
$acl.SetAccessRuleProtection($true,$true)
$acl | Set-Acl $folder
