$remoteProtected = '\\crf-psrv2\Protected\'
$remoteScripts = '\\crf-hub04\Scripts\'
#Use my username for the security - this must be an Administrator on the PCs the script connects to.
$userName = 'CAMPUS\sib8'

#Set the path to the security key to use in the elevation of priviledges
$AESKeyFilePath = ('{0}AESKey.txt' -F $remoteProtected)
#Set the path to the encrypted password
$FilePath = ('{0}Password.txt' -F $remoteProtected)
#Get the key
$AESKey = Get-Content -Path $AESKeyFilePath
#Get the password
$EncryptedPW = Get-Content -Path $FilePath
#Convert it to the readable password using the Key
$securePwd = $EncryptedPW | ConvertTo-SecureString -Key $AESKey
#Set the credentials for running the remote processes
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $securePwd
$computer = "CRF-HUB04"
 try
    {
      <#
          Enable the Credential Security Support Provider (CredSSP)
          Explanation : Credential Security Support Provider (CredSSP) allows you to delegate user credentials across multiple remote computers
      #>
      Enable-WSManCredSSP -role Client -DelegateComputer $Computer -force | Out-Null
     
        #set the session up to accept the credentials and the authentication
        $session = New-PSSession -Credential $credentials  -ComputerName $Computer -Authentication Credssp
        #Run the command on the remote computer
        Invoke-Command  -session $session -FilePath ('{0}DisableNetworkAdapter.ps1' -f $remoteScripts)
        #Report within the DiscoveryTool EventLog if the command ran successfully  
    }
    catch
    {
      #Capture the error if the process fails and report it in the Discovery EventLog.

    }