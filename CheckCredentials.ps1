function Get-SavedCredentials {
    <#
      .SYNOPSIS
      Checks for the existence of UAC credentials to run on a task without having to type them.
      .DESCRIPTION
      Allows the running of a powershell command requiring elivated priviledges without typing them if the encrypted
      files exist on the current machine. The files are contained in a protected folder inside C:\Temp
      .EXAMPLE
      Check-Credentials -UserId sib8 -AESKeyFilePath C:\temp\Protected\AESKey.txt -FilePath C:\temp\Protected\password.txt
      The parameters are defaulted so not required
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true, Position=0)]
    [System.String]
    $UserId,
    [Parameter(Mandatory=$false, Position=1)]
    [System.String]
    $AESKeyFilePath = 'C:\temp\Protected\AESKey.txt',
    
    [Parameter(Mandatory=$false, Position=2)]
    [System.String]
    $FilePath = 'C:\temp\Protected\password.txt'
  )
  
  if(test-path -Path $FilePath -PathType Leaf) {
    $key = Get-Content $AESKeyFilePath
    $Credentials=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserId, (Get-Content $FilePath | ConvertTo-SecureString -Key $Key)
  }else{
    $Credentials = Get-Credential
  }

  return $Credentials
}