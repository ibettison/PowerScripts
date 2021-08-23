$secureCredentials = Get-Credential
$AESKeyFilePath = 'C:\temp\Protected\AESKey.txt'
$FilePath = 'C:\temp\Protected\password.txt'
$AESKey = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)
	
# Store the AESKey into a file. This file should be protected!  (e.g. ACL on the file to allow only select people to read)
Set-Content $AESKeyFilePath $AESKey   # Any existing AES Key file will be overwritten	
($secureCredentials).Password | ConvertFrom-SecureString -Key $AESKey | Out-File $FilePath