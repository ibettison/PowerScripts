<#
    .SYNOPSIS
    Script that runs the Dell Discovery tool on filtered computers
    .DESCRIPTION
    Script that runs the Dell Discovery tool on filtered computers. The script finds filtered PCs and after setting the security
    to remotely run, the script calls a remote script to run the .exe discovery tool; saving the Xml output into a folder to evaluate later.
    .EXAMPLE
    Run the script from the Powershell ISE with Administrator priviledges
  #>

# set the server folder locations
$remoteProtected = '\\crf-psrv2\Protected\'
$remoteFiles = '\\crf-psrv2\DiscoveryFiles\'
$remoteScripts = '\\crf-psrv2\DiscoveryScript\'

#Use my username for the security - this must be an Administrator on the PCs the script connects to.
$userName = 'CAMPUS\sib8'

#Set the filter here to capture the computers to test from Active Directory
$computers = Get-ADComputer -Filter {(name -Like "CRF*") -or (name -Like "CTU*") -or (name -Like "SCL*") -or (name -Like "SBRU*")}
#$computers = Get-ADComputer -Filter {(name -Like 'NMRC*')}

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
# create an EventLog to record the DiscoveryTool actions
$fileContent = 'Discovery tool Actions'
$DateStamp = Get-Date -Format dd-MMM-yyyy-HHmm
$fileContent | Set-Content -Path (('{1}{0}-DiscoveryTool.txt' -f $DateStamp, $remoteFiles))
#Loop through the filtered computers
foreach ($Computer in $Computers | Select-Object -Property name)
  {
    try
    {
      <#
          Enable the Credential Security Support Provider (CredSSP)
          Explanation : Credential Security Support Provider (CredSSP) allows you to delegate user credentials across multiple remote computers
      #>
      Enable-WSManCredSSP -role Client -DelegateComputer $Computer.name -force | Out-Null
      #check for the existence of the summary file as we don't want to have to wait for it if the machine is switched off
      $fileCheck = ('{0}{1}_System_Summary.xml' -f $remoteFiles, $Computer.name)
      $exists = Test-Path -Path $fileCheck
      if($exists -eq $False) {
        #set the session up to accept the credentials and the authentication
        $session = New-PSSession -Credential $credentials  -ComputerName $Computer.name -Authentication Credssp
        #Run the command on the remote computer
        Invoke-Command  -session $session -FilePath ('{0}RunDiscoveryToolExe.ps1' -f $remoteScripts)
        #Report within the DiscoveryTool EventLog if the command ran successfully
        ('Computer {0} -seems to have completed successfully.' -F $Computer.name) | Add-Content -Path (('{1}{0}-DiscoveryTool.txt' -f $DateStamp, $remoteFiles)) 
      }else{
        ('Computer {0} -was previously found, it has been ignored on this pass.' -F $Computer.name) | Add-Content -Path (('{1}{0}-DiscoveryTool.txt' -f $DateStamp, $remoteFiles)) 
      }
        
    }
    catch
    {
      #Capture the error if the process fails and report it in the Discovery EventLog.
      (("{0} `n ---------for Computer {1}" -f $_, $Computer.name)) | Add-Content -Path (('{1}{0}-DiscoveryTool.txt' -f $DateStamp, $remoteFiles))
    }
  }
