#$computers = Get-ADComputer -Filter {(name -Like "CRF*") -or (name -Like "CARU*")}
$computers = Get-Content C:\temp\spurious.txt
$userName = "CAMPUS\sib8"
$AESKeyFilePath = '\\crf-psrv2\Protected\AESKey.txt'
$FilePath ='\\crf-psrv2\Protected\Password.txt'
$AESKey = Get-Content $AESKeyFilePath
$EncryptedPW = Get-Content $FilePath
$securePwd = $EncryptedPW | ConvertTo-SecureString -Key $AESKey
$credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd
# create a file to record if the DiscoveryTool fails
$fileContent = "Discovery tool Failures"
$DateStamp = Get-Date -Format dd-MMM-yyyy-HHmm
$fileContent | Set-Content -Path "\\crf-psrv2\DiscoveryFiles\$DateStamp-RecoveryTool.txt"
foreach ($Computer in $Computers)
  {
    try
    {
      Enable-WSManCredSSP -role Client -DelegateComputer $Computer -force | Out-Null
      $session = New-PSSession -Credential $credentials  -ComputerName $Computer -Authentication Credssp
      #Enter-PSSession $session
      Invoke-Command  -session $session -FilePath '\\crf-psrv2\DiscoveryScript\RunDiscoveryToolExe.ps1'
      #Remove-PSSession -Session $session
      ("Computer {0} -seems to have completed successfully." -F $Computer) | Add-Content "\\crf-psrv2\DiscoveryFiles\$DateStamp-RecoveryTool.txt"    
    }
    catch
    {
      ("Error was $_ `n ---------for Computer {0}" -F $Computer) | Add-Content "\\crf-psrv2\DiscoveryFiles\$DateStamp-RecoveryTool.txt"
      #$line = $_.InvocationInfo.ScriptLineNumber
      #"Error was in Line $line"
    }
    
  }
