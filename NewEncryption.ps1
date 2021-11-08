function New-Encryption
{
  <#
    .SYNOPSIS
    Create an encrypted file containing the UAC credentials to run on a remote computer
    .DESCRIPTION
    Create an encrypted file containing the UAC credentials to run on a remote computer these credentials require manually transferring to the client to enable running the powershell file requiring elivated priviledges
    .EXAMPLE
    New-Encryption
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$false, Position=0)]
    [System.String]
    $AESKeyFilePath = 'C:\temp\Protected\AESKey.txt',
    
    [Parameter(Mandatory=$false, Position=1)]
    [System.String]
    $FilePath = 'C:\temp\Protected\password.txt'
  )
  
  $secureCredentials = Get-Credential
  $AESKey = New-Object Byte[] 32
  [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)
  
  # Store the AESKey into a file. This file should be protected!  (e.g. ACL on the file to allow only select people to read)
  Set-Content $AESKeyFilePath $AESKey   # Any existing AES Key file will be overwritten	
  ($secureCredentials).Password | ConvertFrom-SecureString -Key $AESKey | Out-File $FilePath
}
