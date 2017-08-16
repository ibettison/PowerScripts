Clear-Host
$groupName = "1" #needs to be set to something to enter the loop
do{
  $groupName = Read-Host -prompt "`nType the partial Group Name <leave blank to cancel>"
  if(-not [string]::IsNullOrEmpty($groupName))
   {
    $location = "OU=Security Groups,OU=CTU,OU=Departments,DC=campus,DC=ncl,DC=ac,DC=uk"
    $namePrefix = "CTU-Trials_"
    $fullGrp = $namePrefix + $groupName
    New-ADGroup -name $fullGrp -GroupScope Global -Path $location
    Write-Host "$fullGrp was created."
  }
}
until([string]::IsNullOrEmpty($groupName))