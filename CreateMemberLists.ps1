$path = '\\campus\dept\ihs\programmes\ctu\Shared Docs'
$AccessListPath = '\\campus\dept\ihs\programmes\ctu\Access List\Shared Docs'
$Folders = Get-ChildItem -Path $path -Directory -Force -ErrorAction SilentlyContinue | Select-Object * | Sort-Object Name
forEach ($Folder in $Folders){
  Write-Host ("`nFolder : {0}`n" -F $Folder.BaseName)
  $FileLocation = Join-Path $AccessListPath -ChildPath $Folder.BaseName
  Set-Location -Path $FileLocation
  Get-GroupMemberList -folder $Path -saveOutput $true
}