$folder = "\\campus\dept\crf\IT"
$Results = @()

$Groups = Get-FolderAccess -Path $folder
$Groups
ForEach ($group in $Groups) {
  $acl = $group.'Group/User'.Value
  $Name = $acl.Split("\")[1]
   If ((Get-ADObject -Filter "SamAccountName -eq '$Name'").ObjectClass -eq "group")
      {   ForEach ($User in (Get-ADGroupMember $Name -Recursive | Select-Object -ExpandProperty Name))
          {   $Results += New-Object PSObject -Property @{
                  Group = $Name
                  User = $User
              }              
          }
      }
}
$Results | Select-Object * | Format-Table