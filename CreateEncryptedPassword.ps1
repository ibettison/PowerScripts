function Check-ifPathExists
{
  <#
      .SYNOPSIS
      Check for the protected Remote Path
      .DESCRIPTION
      Function that helps an Administrator to create the neccessary credentials to run scripts on remote machines
      .EXAMPLE
      Get-Credentials -RemoteProtected C:\Temp\Protected -UserName CAMPUS\\sib8 
      Run the script from the Powershell ISE with Administrator priviledges
  #>
  param
  (
    [Parameter(Position=0)]
    [string]
    $Computer = 'FMS-CAV-L33'
  )
  
  <#if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process -FilePath PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`""
    exit
  }
#>
  # Your script here
  $sess = New-PSSession -ComputerName $Computer

    if(!(Test-Path -Path "$env:SystemDrive\Temp\Protected\")) {
      Invoke-Command -Session $sess -ScriptBlock { New-Item -Path "$env:SystemDrive\Temp\Protected\" -ItemType 'directory' }
    }
		$script = {
		$path = "$env:SystemDrive\Temp\Protected\"
﻿		$secureCredentials = Get-Credential
		$AESKeyFilePath = 'C:\temp\Protected\AESKey.txt'
		$FilePath = 'C:\temp\Protected\password.txt'
		$AESKey = New-Object Byte[] 32
		[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)

	
      # Store the AESKey into a file. This file should be protected!  (e.g. ACL on the file to allow only select people to read)
      Set-Content -Path $AESKeyFilePath -Value $AESKey   # Any existing AES Key file will be overwritten	
      ($secureCredentials).Password | ConvertFrom-SecureString -Key $AESKey | Out-File -FilePath $FilePath
      #now lets change the ACL to add an SId and remove all reference to users
      $acl = Get-Acl $path
      $acl.SetAccessRuleProtection($true,$false)
      $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        'sib8',
        'FullControl',
        'ObjectInherit, ContainerInherit',
        'None',
        'Allow'
      )
      $acl.AddAccessRule($rule)
      $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        'nib8',
        'Modify',
        'ObjectInherit, ContainerInherit',
        'None',
        'Allow'
      )
      $acl.AddAccessRule($rule)
      Set-Acl $path $acl
  } 
    Invoke-Command -Session $sess -ScriptBlock $script

}
  
  Check-IfPathExists
 
