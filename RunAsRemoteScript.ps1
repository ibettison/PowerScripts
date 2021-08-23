function Select-RemoteScript
{
  <#
      .SYNOPSIS
      Script that runs Remote Scripts on a Server that then runs on remote computers
      .DESCRIPTION
      Script that runs a remote script on  filtered computers. The script finds filtered PCs and after setting the security
      to remotely run, the script calls a remote script to run the script; any output is saved into a Eventlog file for later perusal.
      The parameters of the script as as follows:
      Server - the server where to remote script and the authentication Password and AESKey files are stored
      Scripts - the folder name of the remote scripts location
      UserName - the domain and username of the Administrator
      ComputerFilter - the PC or PC name filter of the PC's to run the script on eg. CRF*
      ScriptName - the name of the script to run which is located in the Scripts folder.

      .EXAMPLE
      Run the script from the Powershell ISE with Administrator priviledges
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$false, Position=0)]
    [System.String]
    $Server = 'crf-psrv2',
    
    [Parameter(Mandatory=$false, Position=1)]
    [System.String]
    $Scripts = 'Scripts',
    
    [Parameter(Mandatory=$false, Position=2)]
    [System.String]
    $UserName = 'CAMPUS\sib8',
    
    [Parameter(Mandatory=$false, Position=3)]
    [System.String]
    $ComputerFilter = "CRF*",
    
    [Parameter(Mandatory=$false, Position=4)]
    [System.String]
    $ScriptName = "ShowMacAddress.ps1",
    
    [Parameter(Mandatory=$false, Position=5)]
    [Object]
    $RemoteProtected = "\\$Server\Protected\",
    
    [Parameter(Mandatory=$false, Position=6)]
    [Object]
    $RemoteFiles = "\\$Server\EventLog\",
    
    [Parameter(Mandatory=$false, Position=7)]
    [Object]
    $RemoteScripts = "\\$Server\$Scripts\"
  )
   
  #Set the filter here to capture the computers to test from Active Directory
  $computers = Get-ADComputer -Filter {(name -Like $ComputerFilter)}
  #$computers = Get-ADComputer -Filter {(name -Like 'NMRC*')}
  
  #Set the path to the security key to use in the elevation of priviledges
  $AESKeyFilePath = ('{0}AESKey.txt' -F $RemoteProtected)
  #Set the path to the encrypted password
  $FilePath = ('{0}Password.txt' -F $RemoteProtected)
  #Get the key
  $AESKey = Get-Content -Path $AESKeyFilePath
  #Get the password
  $EncryptedPW = Get-Content -Path $FilePath
  #Convert it to the readable password using the Key
  $securePwd = $EncryptedPW | ConvertTo-SecureString -Key $AESKey
  #Set the credentials for running the remote processes
  $credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName, $securePwd
  # create an EventLog to record the Script actions
  $fileContent = 'Script Event Log'
  $DateStamp = Get-Date -Format dd-MMM-yyyy-HHmm
  $fileContent | Set-Content -Path (('{1}{0}-ScriptEventLog.txt' -f $DateStamp, $RemoteFiles))
  #Loop through the filtered computers
  foreach ($Computer in $Computers | Select-Object -Property name)
  {
    try
    {
      $Ping = New-Object System.Net.NetworkInformation.Ping
      $response = $Ping.Send($Computer.Name, 100)
      ("Computer {0} responded with {1}" -F $Computer.Name, $response.Status) 
      #test if the computer is reachable
      if( $response.Status -eq  "Success") {
        <#
            Enable the Credential Security Support Provider (CredSSP)
            Explanation : Credential Security Support Provider (CredSSP) allows you to delegate user credentials across multiple remote computers
        #>
        Enable-WSManCredSSP -role Client -DelegateComputer $Computer.name -force | Out-Null
          #set the session up to accept the credentials and the authentication
          $session = New-PSSession -Credential $credentials  -ComputerName $Computer.name -Authentication Credssp -ErrorAction SilentlyContinue -ErrorVariable Err
        
        if( -not [string]::IsNullOrEmpty($session)){

          #Run the command on the remote computer
          Invoke-Command  -session $session -FilePath ("{0}$ScriptName" -f $RemoteScripts) -ArgumentList $DateStamp, $RemoteFiles, $Computer
          #Report within the DiscoveryTool EventLog if the command ran successfully
          ('Computer {0} -seems to have completed successfully.' -F $Computer.name) | Add-Content -Path (('{1}{0}-ScriptEventLog.txt' -f $DateStamp, $RemoteFiles)) 
          Disconnect-PSSession -Session $session
          Remove-PSSession -Session $session
        }else{
          throw "The computer could not connect to the remote computer so no session variable was created." 
        }
      }else{
        throw ("The computer {0} did not respond to PING!!!" -F $Computer.Name)
      }
    }
    catch
    {
      #Capture the error if the process fails and report it in the Discovery EventLog.
      (("{0} `n ---------for Computer {1}" -f $_, $Computer.name)) | Add-Content -Path (('{1}{0}-ScriptEventLog.txt' -f $DateStamp, $RemoteFiles))
    }
  }
}

