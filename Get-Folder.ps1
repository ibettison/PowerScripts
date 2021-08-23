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

