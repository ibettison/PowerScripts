function Get-File
{
  <#
      .SYNOPSIS
      A script to display a popup file selection window.
      .DESCRIPTION
      Shows a selection window from the computer running the script and allows a choice of file to return
      .EXAMPLE
      Get-File
      .RETURNS
      The chosen folder as unc ie. \\campus\dept\crf\IT\ProjectStructure\Structure1.txt
  #>
  [Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
  
  $filename = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('MyComputer') }
  
  $OnTop = New-Object System.Windows.Forms.Form
  $OnTop.TopMost = $true
  $OnTop.MinimizeBox = $true
  
  if($filename.ShowDialog($OnTop) -eq "OK")
  {
    try{

      $file += $filename.FileName
      $drive = (Split-Path $file -Qualifier).Replace(':','')
      $path = Split-Path $file -NoQualifier
      $unc = Join-Path (Get-PSDrive $drive).DisplayRoot -ChildPath $path
    }
    catch{
      Write-Host ('ERROR : {0}' -f $_)
    }
  }
  return $unc
}

