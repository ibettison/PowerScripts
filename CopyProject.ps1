function Copy-Project 
{
  <#
      .SYNOPSIS
      A script to use Robocopy to copy a folder and subfolders maintaining ACL.
      .DESCRIPTION
      Use robocopy to copy an existing folder to a new folder, with the option to maintain the ACL settings in the newfolder location or to bring the existing ACL with the copy
      .EXAMPLE
      Copy-Project -FromFolder folderUNCLocation to -ToNewFolder folderUNCLocation -MaintainACL $true/$false
      .RETURNS
      If the process completed
  #>
  param
  (
    [Parameter(Position=0)]
    [string]
    $FromFolder,
    [Parameter(Position=0)]
    [string]
    $ToNewFolder,
    [Parameter(Position=0)]
    [bool]
    $MaintainACL = $true
  )
  
  if([string]::IsNullOrEmpty($FromFolder)) 
  {
      $FromFolder = Get-Folder
  }
  if([string]::IsNullOrEmpty($ToNewFolder)) 
  {
      $ToNewFolder = Get-Folder
  }
  if($MaintainACL -eq $true) {
    robocopy $FromFolder $ToNewFolder /E /SEC /R:3 /W:5 /LOG:C:\temp\project\CopyLog.log /TEE
  }else{
    robocopy $FromFolder $ToNewFolder /S /COPY:DAT /R:3 /W:5 /LOG:C:\temp\project\CopyLog.log /TEE
  }
  #now lets reconcile the two locations
  Set-Location -Path C:\Temp
  ROBOCOPY $FromFolder $ToNewFolder /e /l /ns /njs /njh /ndl /fp /log:reconcile.txt
}