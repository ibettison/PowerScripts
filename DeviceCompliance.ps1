﻿#Newcastle University Surface Compliance
<##v1.21
+ UUID > Memory stick
[FIXED]+ Detect premature restart for Enterprise upgrade and continue with original options (PC Name, auto-login, office removal)
    Now re-prompts for sID creds if restart for enterprise upgrade is required
+ Remove additional Dell OOB app - DellCommandUpdate
[COMMENTED OUT - need a better method for this]+ Check for blank password of supplied local admin account

v1.2
+ Detect premature restart for Enterprise upgrade and continue with original options (PC Name, auto-login, office removal)
    Currently forgets sID creds if restart + domain join required, then fails domain join
+ Remove additional Dell OOB app - DellCommandUpdate
+ Check for blank password of supplied local admin account

v1.1
+ Choice of pre-installed Office removal
+ NCL Wallpapers
+ Disable 'Show suggestions occasionally in Start' for all users
- Press ENTER before Domain restart

v1.0
+ Hide search box on taskbar for Default user
+ Remove Dell OOB apps - DellSupportAssist, DellDigitalDelivery
+ Apply standard Start Menu Layout

v0.9
+ Add check for 'complete' reg key. If present then don't run.
+ Fix Bitlocker detection

v0.8
+ Test sID creds BEFORE going off to do domain join - if creds are wrong it gets stuck in a loop
#>

Param([Parameter(Mandatory=$false)][switch]$Reset)

$Global:sIDCreds = $null
$Global:sID = $null
$ProgressPreference = 'SilentlyContinue'

###############################################################
#Add Office detection and uninstall - FIX THIS
#Add checks for existence of stuff post-restart, before trying to install CCM Client/Office over the top of pre-existing stuff
###############################################################

#OK fine, we'll add logging
function WriteLog ($message){
    Write-Host $message
    Write-Host $(Get-Date)
    Write-Host "----------------------------------------------------------------------------------------------------------"
}

#Function for group add tool
function RunGroupAdd{

        Write-Host "*********************************************************************************************"
        Write-Host "We can use this tool to add a device to the following security groups:"
        Write-Host "   `'FMS-Laptops`' (Essential for BitLocker policy!)"
        Write-Host "   `'Default Domain Policy Exclusion Group`' (prevents the ProQuota application from running)"
        if(!(Get-Module -Name ActiveDirectory -ListAvailable)){
        Write-Host 
        Write-Host "     However, to do this we need RSAT tools to be installed. Please install them from:"
        Write-Host "             https://www.microsoft.com/en-gb/download/details.aspx?id=45520"
        Write-Host "     then run this script again."
        Write-Host "*********************************************************************************************"
        exit
        }else{
        Write-Host "*********************************************************************************************"
        Import-Module ActiveDirectory
        $AddToGroupUName="SCCMDJ"
        $AddToGroupPW=ConvertTo-SecureString -String "JoinTheD0ma!n" -AsPlainText -Force
        $AddToGroupCreds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AddToGroupUName,$AddToGroupPW
        $AddToGroupPCPrompt = Read-Host -Prompt "PC Name"
        $AddToGroupPCSAM=$AddToGroupPCPrompt+"$"
        if($ImportPCName -ne ""){
            try{
            Add-ADGroupMember "Default Domain Policy Exclusion Group" -Members $AddToGroupPCSAM -Credential $AddToGroupCreds -ErrorAction Stop
            Add-ADGroupMember "FMS-Laptops" -Members $AddToGroupPCSAM -Credential $AddToGroupCreds -ErrorAction Stop
            Write-Host "Group additions successful. Please confirm manually though!"
            }catch{
            Write-Host "At least one group addition failed. Check PC Name and try again."
            }

        }else{
        Write-Host "PC Name can't be blank!"
        }
        exit
        }
}

function PS-Pause([switch]$Retry,[switch]$Quit){
   Write-Host
if($Retry)
    {Write-Host 'Press ENTER to retry...'
    Read-Host}
if($Quit)
    {Write-Host 'Press ENTER to quit...'
    Read-Host}
    else{Write-Host 'Press ENTER to continue...'
    Read-Host}
    #cmd /c pause | out-null -ErrorAction Stop
    #cmd /c "cd /d c:\SurfaceCompliance && pause" | out-null -ErrorAction Stop #>
    #Start-Process $env:SystemRoot\system32\cmd.exe -ArgumentList '/c pause' -NoNewWindow -WorkingDirectory c:\SurfaceCompliance -Wait | Out-Null
}

Function Get-sIDCreds{
    $sIDPrompt = Read-Host -Prompt "sID"
        if($sIDPrompt -ne ""){
        if($sIDPrompt -like 'campus\*'){$Global:sID=$sIDPrompt}else{$Global:sID="campus\"+$sIDPrompt}
        $sIDPW = Read-Host -Prompt "sID Password" -AsSecureString
        Write-Host "Testing credentials.."
        CheckNetwork
        $Global:sIDCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:sID,$sIDPW

        #Before we test the input creds, remove drives N - P if they exist
        Remove-PSDrive -Name N -ErrorAction SilentlyContinue
        Remove-PSDrive -Name O -ErrorAction SilentlyContinue
        Remove-PSDrive -Name P -ErrorAction SilentlyContinue

    if((New-PSDrive -Name N -PSProvider FileSystem -Root \\campus\software\ConfigManager\Tools\Client -Credential $Global:sIDCreds -Scope Global -ErrorAction SilentlyContinue) -and
    (New-PSDrive -Name O -PSProvider FileSystem -Root \\campus\software\ConfigManager\Software\Microsoft-Office\2016-x86\Content_abda0855-22a9-44cd-903f-3e95057d577f -Credential $Global:sIDCreds -Scope Global -ErrorAction SilentlyContinue) -and
    (New-PSDrive -Name P -PSProvider FileSystem -Root \\campus\software\ConfigManager\Software\Microsoft-OneDrive\SystemPrep -Credential $Global:sIDCreds -Scope Global -ErrorAction SilentlyContinue)) {
        $sIDInput=$true
        #$GOClientMap=$true
        break
    }else{Write-Host 
          Write-Host "sID Credentials didn't authenticate, please try again" -BackgroundColor Red}

        }else{$sIDInput = $false}
}

Function Rename+JoinDomain{
    #Rename PC
    Write-Host "Renaming PC..."
    if($NewPCName = Get-ItemPropertyValue 'HKLM:\SOFTWARE\NUIT\DeviceCompliance' -Name NewPCName -ErrorAction SilentlyContinue){
    Rename-Computer -NewName $NewPCName}

    Write-Host "About to join domain and restart.."

    #Reg key to flag restart
    New-ItemProperty -Path "HKLM:\SOFTWARE\NUIT\DeviceCompliance" -Name JoinDomainRestart -Value "1" -PropertyType String | Out-Null

        #Join Domain
        $JoinDomain=$true
        while($JoinDomain){

        try{
            if($Global:GORenamePC -eq $true){
            Add-Computer -DomainName campus.ncl.ac.uk -Credential $Global:sIDCreds -Options JoinWithNewName -Restart -ErrorAction Stop
            }else{
            Add-Computer -DomainName campus.ncl.ac.uk -Credential $Global:sIDCreds -Restart -ErrorAction Stop
            }

            $JoinDomain=$false
            }catch{
            Write-Host "Domain Join failed, ensure the device is added to AD with the name" $NewPCName -BackgroundColor Red -ForegroundColor White
            Write-Host "and UUID" $UUID -BackgroundColor Red -ForegroundColor White
            PS-Pause -Retry
            }
        }

}

#A ridiculously long function JUST to check that the password for the provided local account isn't blank
#Modified from https://serverfault.com/questions/930582/check-whether-user-account-has-password-set
Function BlankPWcheck{
Param(
   [Parameter(Mandatory=$true)]
   [string]$inputUser
) #end param

#Write-Output "It's only possible to detect whether user accounts have blank passwords if the minimum password length is 0.";

$PasswordMinimumLength = 0;
#Write-Output "Implementing new minimum password length of $PasswordMinimumLength...";

$Secedit_CFGFile_Path = [System.IO.Path]::GetTempFileName();
$Secedit_Path = "$env:SystemRoot\system32\secedit.exe";
$Secedit_Arguments_Export = "/export /cfg $Secedit_CFGFile_Path /quiet";
$Secedit_Arguments_Import = "/configure /db $env:SystemRoot\Security\local.sdb /cfg $Secedit_CFGFile_Path /areas SecurityPolicy";

Start-Process -FilePath $Secedit_Path -ArgumentList $Secedit_Arguments_Export -Wait;

$SecurityPolicy_Old = Get-Content $Secedit_CFGFile_Path;

$SecurityPolicy_New = $SecurityPolicy_Old -Replace "MinimumPasswordLength = \d+", "MinimumPasswordLength = $PasswordMinimumLength";

Set-Content -Path $Secedit_CFGFile_Path -Value $SecurityPolicy_New;

Try {
    Start-Process -FilePath $Secedit_Path -ArgumentList $Secedit_Arguments_Import -Wait;
} Catch {
    #Write-Output "...FAILED.";
    Break;
}
If ($?){
    #Write-Output "...Success.";
}

$VBS_IdentifyBlankPasswords_Commands = @"
On Error Resume Next

Dim strComputerName
Dim strPassword

strComputerName = WScript.CreateObject("WScript.Network").ComputerName
strPassword = ""

Set objUser = GetObject("WinNT://" & strComputerName & "/$inputUser")

Dim Flag
Flag = 0 

objUser.ChangePassword strPassword, strPassword
    If Err = 0 or Err = -2147023569 Then
        Flag = 1
        Wscript.Echo "BLANKPASSWORD"
    End If
"@
# The above here-string terminator cannot be indented.;

# cscript won't accept / process a file with extension ".tmp" so ".vbs" needs to be appended.;
$VBS_IdentifyBlankPasswords_File_Path_TMP = [System.IO.Path]::GetTempFileName();
$VBS_IdentifyBlankPasswords_File_Directory = (Get-ChildItem $VBS_IdentifyBlankPasswords_File_Path_TMP).DirectoryName;
$VBS_IdentifyBlankPasswords_File_Name_TMP = (Get-ChildItem $VBS_IdentifyBlankPasswords_File_Path_TMP).Name;
$VBS_IdentifyBlankPasswords_File_Name_VBS = $VBS_IdentifyBlankPasswords_File_Name_TMP + ".vbs";
$VBS_IdentifyBlankPasswords_File_Path_VBS = "$VBS_IdentifyBlankPasswords_File_Directory\$VBS_IdentifyBlankPasswords_File_Name_VBS";

Set-Content -Path $VBS_IdentifyBlankPasswords_File_Path_VBS -Value $VBS_IdentifyBlankPasswords_Commands;

$VBS_IdentifyBlankPasswords_Output = & cscript /nologo $VBS_IdentifyBlankPasswords_File_Path_VBS;
# Write-Output $VBS_IdentifyBlankPasswords_Output;

#Write-Log "Implementing original minimum password length...";

Set-Content -Path $Secedit_CFGFile_Path -Value $SecurityPolicy_Old;

Try {
    Start-Process -FilePath $Secedit_Path -ArgumentList $Secedit_Arguments_Import -Wait;
} Catch {
    #Write-Output "...FAILED.";
    Break;
}
If ($?){
    #Write-Output "...Success.";
}

if($VBS_IdentifyBlankPasswords_Output -like "BLANKPASSWORD"){
Write-Host "The password for user $inputUser is blank!"
return $true
}

}

Function CheckNetwork{
if(!(Test-Connection campus.ncl.ac.uk -Quiet -Count 2)){
$count=1
    Write-Host "Waiting for network..."
    while(!(Test-Connection campus.ncl.ac.uk -Quiet -Count 2)){
            Write-Host $count".." -NoNewline
            Start-Sleep -Seconds 3
            $count++
    }
    
}
}

#Start main checks:
    #if admin PS session
    #if reset switch passed
    #if script already completed
    #if Dell machine

    #Make sure we're running in an admin PS session
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if(!($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))){
    Write-Host "We need admin rights to run, please run again as an administrator."
    exit
    }
    
    if($Reset){
        $ResetPrompt=Read-Host -Prompt "Reset compliance status? (y/n)"
        if($ResetPrompt -like 'y'){

        Remove-ItemProperty -Path "HKLM:\SOFTWARE\NUIT\InstallFlags" -Name "NCL Compliance Script Complete" -ErrorAction SilentlyContinue
        #REG DELETE "HKLM\SOFTWARE\NUIT\InstallFlags" /v "Surface Compliance Script Complete" /f | Out-Null

            if(Get-ItemProperty 'HKLM:\SOFTWARE\NUIT\DeviceCompliance' -Name AutoLogon -ErrorAction SilentlyContinue){
                Unregister-ScheduledTask -TaskName "Device Compliance Script Resume" -Confirm:$false

                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 0 | Out-Null
    
                Remove-Item -Path "HKLM:\SOFTWARE\NUIT\DeviceCompliance"

            }
            Write-Host "Compliance Status reset"
        }
    }

    if((Get-WmiObject -Class Win32_ComputerSystem | select -ExpandProperty Manufacturer) -like '*Dell*'){$GODellDevice=$true}

#End main checks


#If we aren't restarting from having tried a domain join.. continue as usual (else go to line ~113)
if(!(Get-ItemProperty 'HKLM:\SOFTWARE\NUIT\DeviceCompliance' -Name JoinDomainRestart -ErrorAction SilentlyContinue)){

#Copy Script to temp location and re-run from there
if($PSCommandPath -ne $env:SystemDrive+"\DeviceCompliance\DeviceCompliance.ps1"){

$modePrompt=Read-Host -Prompt "Compliance or Group-add mode? (C/G)"

    if($modePrompt -like "g"){
    RunGroupAdd
    }else{
    
    Write-Host "Writing UUID out to USB drive, just to be helpful.. (DeviceCompliance_UUID.txt)"
    (Get-WmiObject Win32_ComputerSystemProduct).UUID | Out-File $PSScriptRoot\DeviceCompliance_UUID.txt
    #$UUIDtoTxt=$true

    Write-Host "Copying script to temp location..."
    if(!(Test-Path $env:SystemDrive\DeviceCompliance)){
    New-Item $env:SystemDrive\DeviceCompliance -ItemType Directory -Force | Out-Null}
    Copy-Item $PSCommandPath $env:SystemDrive\DeviceCompliance\DeviceCompliance.ps1 -Force
    Write-Host "Running script from temp location, you can remove the USB drive"
    & $env:SystemDrive'\DeviceCompliance\DeviceCompliance.ps1'
    exit
    }
}

    if(Test-Path HKLM:\SOFTWARE\NCL\SCCM_OSD){
    #Check for NUIT Image
    Write-Host "
*********************************************************************************************
              This is an NCL image! We can't run this tool on this image
             Please download a suitable recovery image from the manufacturer

             Surface: https://support.microsoft.com/en-gb/surfacerecoveryimage
    Dell: https://www.dell.com/support/home/uk/en/ukbsdt1/drivers/osiso/recoverytool/wt64a
*********************************************************************************************"
    exit
    }

    if(Get-ItemProperty 'HKLM:\SOFTWARE\NUIT\InstallFlags' -Name 'NCL Compliance Script Complete' -ErrorAction SilentlyContinue){
    Write-Host "This script has already been run on this device and was successful." -BackgroundColor DarkGreen
    exit}

    if((Get-ItemProperty 'HKLM:\SOFTWARE\NUIT\DeviceCompliance' -Name 'OSEditionUpgradeRequired' -ErrorAction SilentlyContinue) `
     -and (Get-ItemProperty 'HKLM:\SOFTWARE\NUIT\DeviceCompliance' -Name 'GO' -ErrorAction SilentlyContinue)){

     Write-Host "A restart was caused by the OS Edition upgrade to Enterprise, continuing with domain join"
     Write-Host "As we've restarted we'll need sID credentials again to join the domain"
     Get-sIDCreds

     Rename+JoinDomain
     }

####################    Start main Input

#Create reg key to store values
    New-Item -Path "HKLM:\SOFTWARE\NUIT\DeviceCompliance" -Force | Out-Null

#Test for network, and prompt if none found
    if(!(Test-Connection campus.ncl.ac.uk -Quiet -Count 2)){
    #Add check for network connection
    $GONoNetwork=$true
    #Write-Host "Can't reach campus.ncl.ac.uk. I'll continue regardless but I need a network connection by step 3!"
    }

    #Get UUID so we can prompt for an AD entry
    $UUID=(Get-WmiObject Win32_ComputerSystemProduct).UUID
    #Check current OS Edition for action later
    if((Get-ItemPropertyValue 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name EditionID) -notlike '*Enterprise*'){
    $GOUpgradeOSEdition=$true
    New-ItemProperty -Path "HKLM:\SOFTWARE\NUIT\DeviceCompliance" -Name OSEditionUpgradeRequired -Value "1" -PropertyType String | Out-Null
    }

        Write-Host
    Write-Host "0) Prerequisites" -BackgroundColor White -ForegroundColor Black
    Write-Host "Before we get started, please make sure this machine is added to AD with the UUID:"
    Write-Host $UUID -BackgroundColor DarkRed -ForegroundColor White
    Write-Host
    PS-Pause
    Write-Host

    Write-Host "1) Naming" -BackgroundColor White -ForegroundColor Black
    Write-Host "This machine is currently called " -NoNewline;Write-Host $env:COMPUTERNAME -BackgroundColor Red -ForegroundColor White
    Write-Host 
    Write-Host "Enter the new name below, otherwise hit ENTER to leave as-is"
    $NewPCName = Read-Host -Prompt "New PC Name"
    if($NewPCName -ne ""){
    $Global:GORenamePC=$true
    Write-Host "Machine will be renamed to " -NoNewline;Write-Host $NewPCName -BackgroundColor DarkGreen -ForegroundColor White
    New-ItemProperty -Path "HKLM:\SOFTWARE\NUIT\DeviceCompliance" -Name OldPCName -Value $env:COMPUTERNAME -PropertyType String | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\NUIT\DeviceCompliance" -Name NewPCName -Value $NewPCName -PropertyType String | Out-Null
    }else{Write-Host "Machine name will stay the same"}

    Write-Host "2) Credentials" -BackgroundColor White -ForegroundColor Black
    Write-Host "We can auto-login for you after joining the domain and continue this script."
    Write-Host "If you'd prefer not to provide this and enter this manually just hit ENTER."
    Write-Host 
    $LocalAdminAcc = Read-Host -Prompt "Local Admin Account Name"
    if($LocalAdminAcc -ne ""){
    
    #if(BlankPWcheck $LocalAdminAcc){
    #$LocalAdminPWPrompt =  Read-Host -Prompt "Enter a new password for this account" -AsSecureString
    #Set-LocalUser -Name $LocalAdminAcc -Password $LocalAdminPWPrompt
    #}else{
    $LocalAdminPWPrompt = Read-Host -Prompt "Local Admin Account Password" -AsSecureString
    #}
    $LocalAdminPW = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($LocalAdminPWPrompt))
    $GOAutoLogon=$true
    New-ItemProperty -Path "HKLM:\SOFTWARE\NUIT\DeviceCompliance" -Name AutoLogon -Value "1" -PropertyType String | Out-Null
    }else{
    Write-Host
    Write-Host "No problem, but you'll have to log in yourself after the restart and re-run this script!"}
    Write-Host

    Write-Host "Now we need sID credentials so we can join to the domain/cache install files. These will NOT be stored."
    $sIDInput = $false
    while($sIDInput -eq $false){
    Get-sIDCreds
    #Test-ADAuthentication
    }

    Write-Host "3) Office Removal" -BackgroundColor White -ForegroundColor Black
    Write-Host "Do you want to remove any pre-installed Office products and install Office 2016?"
    Write-Host "If you're going to be using Office 365 then say no and ask the user to activate Office with their NCL account"
    Write-Host 
    $RemoveOffice = Read-Host -Prompt "Remove Pre-installed Office? (y/n)"
    if($RemoveOffice -like "y"){
    $GORemoveOffice=$true
    New-ItemProperty -Path "HKLM:\SOFTWARE\NUIT\DeviceCompliance" -Name RemoveOffice -Value "1" -PropertyType String | Out-Null
    Write-Host "Pre-installed Office apps will be removed, and Office 2016 installed"
    Write-Host}


    Write-Host
    Write-Host "4) Confirmation" -BackgroundColor White -ForegroundColor Black
    Write-Host "************************************************************"
    Write-Host
    Write-Host "OK, that's all we need. On hitting a key, this machine will:"
    if($GOUpgradeOSEdition -eq $true){Write-Host "Upgrade OS edition to Enterprise"
    Write-Host "       ***NOTE: If device restarts and starts script again, just enter preferences again***"}
    if($Global:GORenamePC -eq $true){Write-Host "Rename from "$env:COMPUTERNAME to $NewPCName}else{Write-Host "NOT rename - machine name will stay as"$env:COMPUTERNAME}
    Write-Host "Join the domain using account" $Global:sID
    if($GOAutoLogon -eq $true){Write-Host "Restart and automatically log back in using local account" $LocalAdminAcc}
        else{Write-Host "Restart, but require manual log-in and script restart with local admin account" -BackgroundColor DarkRed}
    Write-Host "On resume, script will:"
    Write-Host
    Write-Host "Continue at Config Manager Client installation"
    Write-Host "Add 'FMS-IT-Staff-All' to local admins group"
    if($GORemoveOffice -eq $true){Write-Host "Remove any Pre-installed Office apps, and install Office 2016"}
    if($GODellDevice -eq $true){Write-Host "Remove any included Dell modern apps, 'DellSupportAssist', 'DellDigitalDelivery' etc."}
    PS-Pause

#Begin destructive bits and pieces
New-ItemProperty -Path "HKLM:\SOFTWARE\NUIT\DeviceCompliance" -Name GO -Value "1" -PropertyType String | Out-Null
    if($GONoNetwork -eq $true){
    #We couldn't reach Campus at the start, let's test it again
    CheckNetwork
    }

    #Cache Client setup files
    Write-Host "Caching Configuration Manager Client setup files..."
    New-Item $env:SystemDrive\DeviceCompliance\Client -Force -ItemType Directory | Out-Null
    #New-PSDrive -Name S -PSProvider FileSystem -Root \\campus\software\ConfigManager\Tools\Client -Credential $Global:sIDCreds | Out-Null
    Copy-Item N:\*.* $env:SystemDrive\DeviceCompliance\Client -Force -Recurse

    if($GORemoveOffice -eq $true){
    #Cache Office 2016 Setup files
    Write-Host "Caching Office 2016 setup files..."
    New-Item $env:SystemDrive\DeviceCompliance\Office2016 -Force -ItemType Directory | Out-Null
    Copy-Item O:\*.* $env:SystemDrive\DeviceCompliance\Office2016 -Force -Recurse
    Copy-Item P:\RemoveGroove.MSP $env:SystemDrive\DeviceCompliance\Office2016 -Force
    }
    
    if($GOAutoLogon -eq $true){
    #Set script to start on logon
    Write-Host "Adding script to startup items..."
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-ExecutionPolicy Bypass -File `"C:\DeviceCompliance\DeviceCompliance.ps1`""
    $trigger = New-ScheduledTaskTrigger -AtLogOn -User $LocalAdminAcc
    $principal = New-ScheduledTaskPrincipal -RunLevel Highest -UserId $LocalAdminAcc
    $settings = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings $settings -TaskName "Device Compliance Script Resume" -ErrorAction SilentlyContinue | Out-Null

    Write-Host "Adding auto-login details..."

    #Start-Process -FilePath $env:SystemRoot\System32\reg.exe -ArgumentList '"HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultUserName" /t REG_SZ /d $LocalAdminAcc /f'
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value $LocalAdminAcc -PropertyType String -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value $LocalAdminPW -PropertyType String -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 1 | Out-Null

    }

    if($GOUpgradeOSEdition -eq $true){
    #Add Enterprise Key
    Write-Host "Upgrading to Enterprise..."
    Start-Process $env:SystemRoot\system32\changepk.exe -ArgumentList '/ProductKey NPPR9-FWDCX-D2C8J-H872K-2YT43' -Wait
    #cscript //B "%windir%\system32\slmgr.vbs" /ipk NPPR9-FWDCX-D2C8J-H872K-2YT43

    #Change 'Licensed to' details
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "RegisteredOwner" -Value "NUIT" | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "RegisteredOrganization" -Value "Newcastle University" | Out-Null
    }

    Rename+JoinDomain

    }else{
    #Resume script after Domain Join Restart
    if(!(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\History' -Name MachineDomain -ErrorAction SilentlyContinue)){
        Write-Host "Domain Join FAILED.."
        $ForceRestart=Read-Host -Prompt "Reset current script progress? (y/n)"
            if($ForceRestart -like 'y'){
            Remove-ItemProperty -Path "HKLM:\SOFTWARE\NUIT\DeviceCompliance" -Name JoinDomainRestart
            #REG DELETE "HKLM\SOFTWARE\NUIT\DeviceCompliance" /v "JoinDomainRestart" /f | Out-Null
            Write-Host "Done, restart the script"
            }
        PS-Pause
        exit
    }else{
    $currentdomain=Get-ItemPropertyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\History' -Name MachineDomain -ErrorAction SilentlyContinue
    if($currentdomain -like 'campus.ncl.ac.uk'){
        #After restart + Domain join succeeded        

        Write-Host "Domain Join Succeeded, domain is $currentdomain"

        Write-Host

        CheckNetwork

        Write-Host 'Adding FMS-IT-Staff-All to local admins group'
        #Add fms-it-staff-all to Local Administrators group
        Add-LocalGroupMember Administrators -Member campus\FMS-IT-Staff-All

        Write-Host

        #Install SCCM Client
        Write-Host "Installing Configuration Manager Client"
        Start-Process -FilePath $env:SystemDrive\DeviceCompliance\Client\ccmsetup.exe -ArgumentList '/mp:CMNCLMP.ncl.ac.uk SMSMP=CMNCLMP.ncl.ac.uk SMSSITECODE=NCU /BITSPriority:HIGH'
        $Loop = $true
 
        while($Loop){
            if(Get-Process ccmsetup -ErrorAction SilentlyContinue){
                Start-Sleep -Seconds 5
            }else{
                Write-Host "Configuration Manager Client Installed"
                $Loop = $false
            }
        }

        if(Get-ItemProperty -Path 'HKLM:\SOFTWARE\NUIT\DeviceCompliance' -Name RemoveOffice -ErrorAction SilentlyContinue){
        #REMOVE OFFICE STUFF
        if(Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like "*office*"}){
        Write-Host "Office apps found, removing.."
        Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like "*office*"} | Remove-AppxProvisionedPackage -Online | Out-Null
        }
        if(Get-AppxPackage | Where-Object {$_.Name -like "*office*"}){
        Get-AppxPackage | Where-Object {$_.Name -like "*office*"} | Remove-AppxPackage | Out-Null
        }

        #Install Office 2016
        if(Test-Path $env:SystemDrive\DeviceCompliance\Office2016){

        Write-Host "Installing Office 2016.."
        Start-Process -FilePath $env:SystemDrive\DeviceCompliance\Office2016\setup.exe -ArgumentList '/adminfile Office2016.msp' -Wait
        Start-Sleep -Seconds 15
        #Remove Groove
        If (Get-ItemProperty -Path 'HKLM:\Software\Classes\Applications\groove.exe' -ErrorAction SilentlyContinue) {
            Write-Host "Modifying Office install to Remove Groove/OneDrive for Business"
            Start-Process -FilePath msiexec.exe -ArgumentList '/quiet /update "RemoveGroove.msp"' -WorkingDirectory $env:SystemDrive\DeviceCompliance\Office2016 -Wait
        } Else {
            Write-Host "Groove/OneDrive for Business already removed, continuing"
        }

        }#End of Install Office 2016

        }#End of Office removal reg check

        #Remove Dell Utils
        if(Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like "*DellSupportAssist*" -or $_.DisplayName -like "*DellDigitalDelivery*" -or $_.DisplayName -like "*DellCommandUpdate*"}){
        Write-Host "Dell apps found, removing.."
        Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like "*DellSupportAssist*" -or $_.DisplayName -like "*DellDigitalDelivery*" -or $_.DisplayName -like "*DellCommandUpdate*"} | Remove-AppxProvisionedPackage -Online | Out-Null
        Get-AppxPackage | Where-Object {$_.Name -like "*DellSupportAssist*" -or $_.Name -like "*DellDigitalDelivery*" -or $_.Name -like "*DellCommandUpdate*"} | Remove-AppxPackage | Out-Null
        }
        
        #Show Bitlocker encryption status - this will start if the machine is in the 'FMS-Laptops' sec. group
        if((Get-BitLockerVolume | Select-Object -First 1 -Expand ProtectionStatus) -ne "On"){
        Write-Host "BITLOCKER NOT ENABLED - CHECK GROUP MEMBERSHIP AND RUN GPUPDATE /FORCE" -BackgroundColor White -ForegroundColor Red
        }elseif((Get-BitLockerVolume | Select-Object -First 1 -Expand EncryptionPercentage) -ne 100){
        $Loop = $true
 
        while($Loop){
            [int]$PercentComplete = Get-BitLockerVolume | Select-Object -First 1 -Expand EncryptionPercentage
            if($PercentComplete -ne 100){
                Write-Progress -Activity "Bitlocker Drive Encryption Status" -Status "Encrypting" -PercentComplete $PercentComplete
                Start-Sleep -Seconds 5
            }else{
                Write-Progress -Activity "Bitlocker Drive Encryption Status" -Completed
                $Loop = $false
            }
        }

        }else{
            Write-Host "Bitlocker Enabled"
            }

        Write-Host "Enabling RDP.."
        ## Enable RDP
        #WriteLog "---Enable RDP---"
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -Value 0
        ##
        ## Enable Firewall Rule
        #WriteLog "---Enable Firewall Rule---"
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
        ##
        ## Enable RDP Authentication
        #WriteLog "---Enable RDP Authentication---"
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 0

        #Create Temp Folder
        Write-Host "Create Temp folder.."
        New-Item -ItemType Directory -Path $env:SystemDrive\Temp | Out-Null

        #Registry Edits
        Write-Host "Registry Edits.."
        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name EnableAutoTray -Value 0
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name HiberbootEnabled -Value 1
        if(!(Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR)){
        New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR -Force | Out-Null
        New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR -Name AllowgameDVR -Value 0 -PropertyType "DWord"|Out-Null}else{
        Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR -Name AllowgameDVR -Value 0}
        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Value 1
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main' -Name DisableFirstRunCustomize -Value 1
        
        #Apply standard Start Menu Layout
        Write-Host "Start Menu Layout.."
        $StartMenuLayout='PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4NCjxMYXlvdXRNb2RpZmljYXRpb25UZW1wbGF0ZQ0KICAgIHhtbG5zPSJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL1N0YXJ0LzIwMTQvTGF5b3V0TW9kaWZpY2F0aW9uIg0KICAgIHhtbG5zOmRlZmF1bHRsYXlvdXQ9Imh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vU3RhcnQvMjAxNC9GdWxsRGVmYXVsdExheW91dCINCiAgICB4bWxuczpzdGFydD0iaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS9TdGFydC8yMDE0L1N0YXJ0TGF5b3V0Ig0KICAgIHhtbG5zOnRhc2tiYXI9Imh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vU3RhcnQvMjAxNC9UYXNrYmFyTGF5b3V0Ig0KICAgIFZlcnNpb249IjEiPg0KICA8TGF5b3V0T3B0aW9ucyBTdGFydFRpbGVHcm91cENlbGxXaWR0aD0iNiIgU3RhcnRUaWxlR3JvdXBzQ29sdW1uQ291bnQ9IjEiIC8+DQogIDxEZWZhdWx0TGF5b3V0T3ZlcnJpZGU+DQogICAgPFN0YXJ0TGF5b3V0Q29sbGVjdGlvbj4NCiAgICAgIDxkZWZhdWx0bGF5b3V0OlN0YXJ0TGF5b3V0IEdyb3VwQ2VsbFdpZHRoPSI2IiB4bWxuczpkZWZhdWx0bGF5b3V0PSJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL1N0YXJ0LzIwMTQvRnVsbERlZmF1bHRMYXlvdXQiPg0KICAgICAgICA8c3RhcnQ6R3JvdXAgTmFtZT0iTWljcm9zb2Z0IE9mZmljZSIgeG1sbnM6c3RhcnQ9Imh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vU3RhcnQvMjAxNC9TdGFydExheW91dCI+DQoJICA8c3RhcnQ6RGVza3RvcEFwcGxpY2F0aW9uVGlsZSBTaXplPSIyeDIiIENvbHVtbj0iMCIgUm93PSIyIiBEZXNrdG9wQXBwbGljYXRpb25MaW5rUGF0aD0iJUFMTFVTRVJTUFJPRklMRSVcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1xPbmVOb3RlIDIwMTYubG5rIiAvPg0KICAgICAgICAgIDxzdGFydDpEZXNrdG9wQXBwbGljYXRpb25UaWxlIFNpemU9IjJ4MiIgQ29sdW1uPSI0IiBSb3c9IjIiIERlc2t0b3BBcHBsaWNhdGlvbkxpbmtQYXRoPSIlQUxMVVNFUlNQUk9GSUxFJVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXE91dGxvb2sgMjAxNi5sbmsiIC8+DQogICAgICAgICAgPHN0YXJ0OkRlc2t0b3BBcHBsaWNhdGlvblRpbGUgU2l6ZT0iMngyIiBDb2x1bW49IjQiIFJvdz0iMCIgRGVza3RvcEFwcGxpY2F0aW9uTGlua1BhdGg9IiVBTExVU0VSU1BST0ZJTEUlXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcUG93ZXJQb2ludCAyMDE2LmxuayIgLz4NCiAgICAgICAgICA8c3RhcnQ6RGVza3RvcEFwcGxpY2F0aW9uVGlsZSBTaXplPSIyeDIiIENvbHVtbj0iMiIgUm93PSIyIiBEZXNrdG9wQXBwbGljYXRpb25MaW5rUGF0aD0iJUFMTFVTRVJTUFJPRklMRSVcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1xQdWJsaXNoZXIgMjAxNi5sbmsiIC8+DQogICAgICAgICAgPHN0YXJ0OkRlc2t0b3BBcHBsaWNhdGlvblRpbGUgU2l6ZT0iMngyIiBDb2x1bW49IjAiIFJvdz0iMCIgRGVza3RvcEFwcGxpY2F0aW9uTGlua1BhdGg9IiVBTExVU0VSU1BST0ZJTEUlXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcV29yZCAyMDE2LmxuayIgLz4NCiAgICAgICAgICA8c3RhcnQ6RGVza3RvcEFwcGxpY2F0aW9uVGlsZSBTaXplPSIyeDIiIENvbHVtbj0iMiIgUm93PSIwIiBEZXNrdG9wQXBwbGljYXRpb25MaW5rUGF0aD0iJUFMTFVTRVJTUFJPRklMRSVcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1xFeGNlbCAyMDE2LmxuayIgLz4NCiAgICAgICAgPC9zdGFydDpHcm91cD4gICANCiAgICAgICAgPHN0YXJ0Okdyb3VwIE5hbWU9IlNvZnR3YXJlIGFuZCBTZXR0aW5ncyIgeG1sbnM6c3RhcnQ9Imh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vU3RhcnQvMjAxNC9TdGFydExheW91dCI+DQogICAgICAgICAgPHN0YXJ0OlRpbGUgU2l6ZT0iMngyIiBDb2x1bW49IjIiIFJvdz0iMCIgQXBwVXNlck1vZGVsSUQ9IndpbmRvd3MuaW1tZXJzaXZlY29udHJvbHBhbmVsX2N3NW4xaDJ0eHlld3khbWljcm9zb2Z0LndpbmRvd3MuaW1tZXJzaXZlY29udHJvbHBhbmVsIiAvPg0KICAgICAgICAgIDxzdGFydDpEZXNrdG9wQXBwbGljYXRpb25UaWxlIFNpemU9IjJ4MiIgQ29sdW1uPSIwIiBSb3c9IjAiIERlc2t0b3BBcHBsaWNhdGlvbkxpbmtQYXRoPSIlQUxMVVNFUlNQUk9GSUxFJVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXE1pY3Jvc29mdCBTeXN0ZW0gQ2VudGVyXENvbmZpZ3VyYXRpb24gTWFuYWdlclxTb2Z0d2FyZSBDZW50ZXIubG5rIiAvPg0KICAgICAgICA8L3N0YXJ0Okdyb3VwPiAgICAgDQogICAgICA8L2RlZmF1bHRsYXlvdXQ6U3RhcnRMYXlvdXQ+DQogICAgPC9TdGFydExheW91dENvbGxlY3Rpb24+DQogIDwvRGVmYXVsdExheW91dE92ZXJyaWRlPg0KICAgIDxDdXN0b21UYXNrYmFyTGF5b3V0Q29sbGVjdGlvbj4NCiAgICAgIDxkZWZhdWx0bGF5b3V0OlRhc2tiYXJMYXlvdXQ+DQogICAgICAgIDx0YXNrYmFyOlRhc2tiYXJQaW5MaXN0Pg0KICAgICAgICAgIDx0YXNrYmFyOkRlc2t0b3BBcHAgRGVza3RvcEFwcGxpY2F0aW9uTGlua1BhdGg9IiVBUFBEQVRBJVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXEFjY2Vzc29yaWVzXEludGVybmV0IEV4cGxvcmVyLmxuayIgLz4NCiAgICAgICAgICA8dGFza2JhcjpEZXNrdG9wQXBwIERlc2t0b3BBcHBsaWNhdGlvbkxpbmtQYXRoPSIlQVBQREFUQSVcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1xTeXN0ZW0gVG9vbHNcRmlsZSBFeHBsb3Jlci5sbmsiIC8+DQogICAgICAgIDwvdGFza2JhcjpUYXNrYmFyUGluTGlzdD4NCiAgICAgIDwvZGVmYXVsdGxheW91dDpUYXNrYmFyTGF5b3V0Pg0KICAgIDwvQ3VzdG9tVGFza2JhckxheW91dENvbGxlY3Rpb24+DQo8L0xheW91dE1vZGlmaWNhdGlvblRlbXBsYXRlPg=='
        [IO.File]::WriteAllBytes("$env:SystemDrive\DeviceCompliance\StartLayout.xml", [Convert]::FromBase64String($StartMenuLayout))
        Import-StartLayout -LayoutPath "$env:SystemDrive\DeviceCompliance\StartLayout.xml" -MountPath $env:SystemDrive\

        #Apply NCL Wallpapers
        Write-Host "NCL Wallpapers.."
        [IO.File]::WriteAllBytes("$PSScriptRoot\NCLWallpaper.zip", [Convert]::FromBase64String($NCLWallpaper))
        Expand-Archive "$PSScriptRoot\NCLWallpaper.zip" -DestinationPath $PSScriptRoot
        & $PSScriptRoot\NCLWallpaper\Win10Backgrounds.ps1

        #Disable Search Box + Start Suggestions for Default user
        Write-Host "Disable Search Box + Start Suggestions for Default user.."
            # Load ntuser.dat for 'default' user
        reg load HKU\DefaultUser $env:SystemDrive\Users\Default\NTUSER.DAT | Out-Null
            # Create a new key, close the handle, and trigger garbage collection
        $regadd1 = New-ItemProperty -Path 'Registry::HKEY_USERS\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Search' -Name SearchboxTaskbar -Value 0 -PropertyType DWORD
        $regadd2 = Set-ItemProperty -Path 'Registry::HKEY_USERS\DefaultUser\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name SystemPaneSuggestionsEnabled -Value 0
        #$regadd1.Handle.Close() | Out-Null
        #$regadd2.Handle.Close() | Out-Null
        [gc]::Collect()
        Start-Sleep -Seconds 5
        #Unload ntuser.dat
        reg unload HKU\DefaultUser | Out-Null

        #Create Desktop Shortcuts (http://powershellblogger.com/2016/01/create-shortcuts-lnk-or-url-files-with-powershell)
        $Shell = New-Object -ComObject ("WScript.Shell")
        New-Item "$env:SystemDrive\Program Files\NUIT Icons\" -ItemType Directory | Out-Null
        $NUServiceIcon='AAABAA0AICAQAAEABADoAgAA1gAAABAQEAABAAQAKAEAAL4DAAAwMAAAAQAIAKgOAADmBAAAICAAAAEACACoCAAAjhMAABAQAAABAAgAaAUAADYcAAAAAAAAAQAgAG5EAACeIQAAQEAAAAEAIAAoQgAADGYAADAwAAABACAAqCUAADSoAAAoKAAAAQAgAGgaAADczQAAICAAAAEAIACoEAAAROgAABgYAAABACAAiAkAAOz4AAAUFAAAAQAgALgGAAB0AgEAEBAAAAEAIABoBAAALAkBACgAAAAgAAAAQAAAAAEABAAAAAAAgAIAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAACAAACAAAAAgIAAgAAAAIAAgACAgAAAgICAAMDAwAAAAP8AAP8AAAD//wD/AAAA/wD/AP//AAD///8Ad3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d4d3d3d3d3d3d3d3d3d3d3j3iIeIh/h3eId3d3d3d4d4+I////j/+I+Hd3d3d3ePiP//////////93d3d3d3j/////+I//iI//+Hd3d3d3eP/4d3d3iHiHj//4h3d3d3iP93d3d4iI/4j4j//4d3f/iPd3d3h/+P/3iI////h3h3f3d3ePj///+PiP////d3d3h3d4j//////4iIj//3d3d3f/+I//////+Hh4//93d3d3//iP//iIj///j///d3d3j//4j/+Ih4j//3///3d3d4//iI//h3iP//9///93d3j//4j//4iHiP//d3eId3d///h3iP//iP////d3d3d3d//3d3j/////iP/4d3d4j4j/93eP//+I////93d3d4////d3d4//j/////h3d3d3j//4d3d4////////d3d3d4+Pj4d3f///////h3d3d3/3j3d3d3f//////4d3d3d4d493d3d3f///+Hd3d3d3d3eHd3d3d3h/h4h3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3cAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA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v/nN3I+V8X/IBJAxHn7/939/89CHPnRzt7vdbfODH/xg841vfGPz1a9+tfj6wx/+cPOrX/1qc/nll8/9mGvGMgmARqFdHJ7f/va3xdd8kNKDPbrXve61OeWUUzZ/+Id/uPn1r39dWAHf+973Nl/4whc2n/vc5zZf+9rXNj/96U+LfcyYHMsjAFrlr//6rze3vvWti0NDk9Au3/3ud4s/O2D5MA0HZPunf/qnxdef//znxaeLGX+rW91q8+xnP3tzwxve8Cp/b49+9KMfbb70pS9tPvaxj20uu+yywk3IRD4plkcAtMqNbnSjzX3ve9/NMcccs/njP/7jzS9+8YtC+L/97W9v/uM//mPz+c9/fvOd73ynIIOM/viTP/mTYp3vete7bq51rWsVREtrf/KTn9z8z//8TythvcENbrD5h3/4h80tbnGL2v/vZ/zkJz/ZfOYzn9m8973vLVwElkLGJFgeAQSYlPe85z03D3vYwzZ//ud/fqVLwK/8/ve/XxzUj370o5uvf/3rBUFkdMM1rnGNzf3ud7/Nox/96IIIwPpaS+b7O97xjoJsd1kD173udTf/+I//WFgC2+DnfOtb39q85z3v2Xz84x8v3IKh8Hu/93ubP/iDPyjegzXjmXz1937vZz/72c1///d/z73kc2C5BADcgXvc4x7FIa2amDaWr4kEPvzhDxd/zq5BexCWpz71qYX2R65lWEe++xvf+MbNv//7v29d1+tf//qb5z3veY0WQBlhDXzoQx/avPOd7yysur7wzJQE5YB8bnvb225udrObFcLv3HBpgOC/7GUvK95nhVg2AQDTlJn6d3/3d4U7UMUvf/nLzRe/+MXN29/+9uJrNi/bAaFecTaKWEsdCCtL4NWvfvXmP//zPxt/zs1vfvPNc57znEIQ28KefeADH9j88z//c2cSCMG/3e1uV1iIt7/97a8U+iqReQcK4lWvelURf1ghlk8AQPAf97jHbe5zn/sUpmsVNvqb3/xmcaA+8YlPFG5CxnYQoGc+85mb613veo3fg0w/+MEPbl7/+tcXwcE6/M3f/M3maU97WmFydwFX493vfndB3G2Fk5l/m9vcpogNCRSHmd8EMaLXvva1m3/9139da/DxMAgAs9v4pz/96Zub3OQmtd9jg7kBb3nLWwofM1sCzbCeRx999ObJT37y5trXvvbW7xUYfPnL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fP3/AWDRuvAb+R+iAAAAAElFTkSuQmCCKAAAAEAAAACAAAAAAQAgAAAAAAAAQgAAAAAAAAAAAAAAAAAAAAAAAGZmZsJmZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mdnZ8FlZWXfZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVl32ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/a2tr/4SEhP90dHT/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVl32ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/cXFx/7q6uv/CwsL/cXFx/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/aWlp/7Kysv/29vb/lZWV/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/4GBgf/t7e3/+/v7/729vf97e3v/ZmZm/2dnZ/9tbW3/b29v/2pqav9mZmb/ZmZm/2ZmZv9nZ2f/fX19/35+fv9ubm7/ZmZm/2ZmZv9nZ2f/j4+P/7Gxsf+bm5v/fn5+/2tra/9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9oaGj/aGho/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVl32ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv+kpKT//f39///////+/v7/rq6u/2ZmZv+AgID/0tLS/93d3f/Ozs7/ra2t/4SEhP9ra2v/Z2dn/7S0tP/u7u7/1tbW/6Kiov9zc3P/ZmZm/4iIiP/x8fH//Pz8/+3t7f/Jycn/kpKS/21tbf9mZmb/ZmZm/2ZmZv9mZmb/Z2dn/3x8fP+rq6v/x8fH/8LCwv+MjIz/Z2dn/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9paWn/e3t7/2ZmZv9mZmb/ZmZm/2ZmZv9nZ2f/urq6/////////////////66urv9mZmb/enp6/+rq6v////////////7+/v/w8PD/xMTE/4SEhP+Wlpb/+vr6///////7+/v/1tbW/4uLi/9ubm7/1NTU//////////////////b29v/Kysr/hYWF/2hoaP9mZmb/Z2dn/5SUlP/k5OT//f39///////e3t7/gICA/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfeXl5/7Ozs/9paWn/Z2dn/2ZmZv9mZmb/Z2dn/7u7u/////////////////+zs7P/Z2dn/3Nzc//i4uL///////////////////////7+/v/r6+v/wsLC//j4+P/////////////////s7Oz/mpqa/729vf///////////////////////v7+/+vr6/+jo6P/bGxs/4WFhf/q6ur////////////9/f3/oqKi/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVl35GRkf/l5eX/i4uL/6ysrP+ZmZn/aWlp/2ZmZv+mpqb//v7+////////////4uLi/5OTk/+oqKj/9vb2//////////////////////////////////39/f/+/v7//////////////////////+7u7v/Z2dn/////////////////////////////////9/f3/7i4uP/Hx8f//v7+/////////////f39/6SkpP9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd+cnJz//Pz8/+vr6//6+vr/8fHx/5aWlv9nZ2f/hISE//Hx8f/////////////////4+Pj/+/v7/////////////////////////////////////////////////////////////////////////////v7+///////////////////////////////////////7+/v/+vr6///////////////////////a2tr/d3d3/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfjY2N//f39//////////////////r6+v/paWl/4yMjP/c3Nz//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////f39/8vLy/97e3v/Z2dn/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVl33BwcP/Pz8///v7+//////////////////z8/P/19fX/+/v7//////////////////////////////////////////////////////////////////////////////////////////////////////////////////j4+P/a2tr/y8vL/8fHx//MzMz/3Nzc//Dw8P/9/f3////////////////////////////9/f3/4ODg/5ycnP9wcHD/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9mZmb/fn5+/8/Pz//5+fn///////////////////////////////////////////////////////////////////////z8/P/09PT/7Ozs/+Xl5f/f39//3Nzc/97e3v/k5OT/7Ozs//X19f/9/f3////////////y8vL/jo6O/2pqav9ycnL/dXV1/3V1df+Dg4P/r6+v/+jo6P/+/v7////////////////////////////5+fn/19fX/6Ghof97e3v/ampq/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2ZmZv9xcXH/nJyc/83Nzf/p6en/9vb2//z8/P/////////////////////////////////9/f3/6enp/8DAwP+cnJz/hoaG/3p6ev90dHT/cHBw/29vb/9wcHD/c3Nz/3t7e/+IiIj/oKCg/8TExP/n5+f/+/v7/8jIyP9wcHD/ubm5/+Hh4f/Q0ND/p6en/3p6ev+AgID/y8vL//z8/P/////////////////////////////////7+/v/6enp/8rKyv+kpKT/hYWF/3Fxcf9oaGj/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVl32ZmZv9mZmb/ZmZm/2ZmZv9ra2v/eXl5/4mJif+ysrL/+fn5///////////////////////8/Pz/xMTE/35+fv9oaGj/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9nZ2f/g4OD/46Ojv+BgYH/f39//6Ojo//T09P/iIiI/5ubm//6+vr///////z8/P/g4OD/lJSU/3V1df/ExMT//f39/////////////////////////////////////////////f39//Pz8//d3d3/vb29/5iYmP96enr/ampq/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9mZmb/ZmZm/2ZmZv9nZ2f/aWlp/2lpaf95eXn/0NDQ//7+/v//////////////////////29vb/3R0dP9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/Z2dn/5SUlP/q6ur/7u7u/9HR0f+goKD/hISE/3t7e/95eXn/6Ojo/////////////////+/v7/+ZmZn/d3d3/9XV1f/////////////////+/v7//v7+///////////////////////////////////////6+vr/6urq/8nJyf+cnJz/eHh4/2hoaP9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2ZmZv9qamr/oaGh/8rKyv/MzMz/4eHh//39/f//////9fX1/+jo6P///////////76+vv9nZ2f/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/bW1t/2tra/9oaGj/p6en//n5+f//////+vr6/9vb2/+YmJj/cHBw/9PT0///////////////////////6urq/4eHh/+Li4v/7e3t/+jo6P/FxcX/q6ur/6SkpP+wsLD/zMzM//X19f//////////////////////////////////////+/v7/+Xl5f+3t7f/g4OD/2lpaf9mZmbeZWVl3319ff96enr/g4OD/+/v7///////////////////////7+/v/6SkpP/Hx8f///////////+9vb3/Z2dn/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/Z2dn/6enp/+dnZ3/Z2dn/29vb//Q0ND/////////////////9fX1/7i4uP/T09P////////////////////////////Q0ND/c3Nz/4+Pj/98fHz/dnZ2/4WFhf+Ghob/bGxs/4aGhv/u7u7//////////////////////////////////////////////////v7+/+7u7v++vr7/h4eH3mVlZd99fX3/zs7O/9TU1P/7+/v////////////8/Pz/29vb/4+Pj/9ubm7/1dXV////////////yMjI/2hoaP9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/3Nzc//f39//4eHh/3x8fP9mZmb/oaGh//39/f/////////////////7+/v/+fn5////////////////////////////+fn5/5ycnP9ycnL/q6ur/+Dg4P/09PT/19fX/3R0dP++vr7//v7+/////////////////////////////////////////////////////////////v7+//Hx8d5lZWXfZ2dn/5mZmf/n5+f/+vr6//f39//i4uL/ra2t/3Z2dv9mZmb/bm5u/9vb2////////////9HR0f9qamr/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv+MjIz/9vb2//7+/v/U1NT/j4+P/7i4uP/9/f3////////////////////////////////////////////////////////////d3d3/z8/P//v7+////////v7+/7W1tf94eHj/5ubm///////////////////////////////////////////////////////////////////////+/v7eZWVl32ZmZv9oaGj/e3t7/5GRkf+Li4v/dXV1/2dnZ/9mZmb/ZmZm/2lpaf+8vLz/+fn5//7+/v++vr7/aGho/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2hoaP9nZ2f/pKSk//39/f///////v7+//f39//7+/v//////////////////////////////////////////////////////////////////v7+//7+/v////////////v7+/+Wlpb/i4uL//b29v///////////////////////////////////////////////////////////////////////v7+3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/fn5+/+Xl5f/m5ub/hISE/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/Z2dn/3x8fP+pqan/dXV1/7a2tv/////////////////////////////////////////////////////////////////////////////////////////////////////////////////39/f/iYmJ/5mZmf/8/Pz///////z8/P/6+vr/+/v7//7+/v////////////////////////////////////////////7+/t5lZWXfZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/bGxs/6mpqf/BwcH/hoaG/2dnZ/9mZmb/ZmZm/2hoaP9wcHD/hoaG/7Ozs//m5ub/5+fn/3h4eP+9vb3/////////////////////////////////////////////////////////////////////////////////////////////////////////////////9/f3/4mJif+Xl5f/3t7e/7m5uf+bm5v/kJCQ/5eXl/+0tLT/4eHh//7+/v/////////////////////////////////+/v7eZWVl32ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2hoaP9wcHD/aWlp/2hoaP+Hh4f/nJyc/6qqqv/BwcH/3Nzc//Pz8//+/v7//////+rq6v95eXn/urq6/////////////////////////////////////////////////////////////Pz8//39/f////////////////////////////////////////////v7+/+Xl5f/b29v/3d3d/99fX3/kpKS/5ubm/97e3v/ampq/7a2tv/8/Pz//////////////////////////////////v7+3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9nZ2f/o6Oj//f39//+/v7////////////////////////////x8fH/gYGB/6ysrP/+/v7////////////////////////////////////////////9/f3/+/v7/8XFxf+qqqr/19fX//v7+///////////////////////////////////////urq6/4CAgP+/v7//6+vr//r6+v/y8vL/jIyM/4mJif/w8PD///////////////////////////////////////7+/t5lZWXfZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/25ubv+2trb/9fX1////////////////////////////+fn5/5GRkf+VlZX/+vr6///////////////////////////////////////x8fH/y8vL//39/f/y8vL/r6+v/3l5ef+ysrL/9/f3//////////////////////////////////Dw8P/o6Oj//v7+////////////2NjY/3Jycv/AwMD//v7+///////////////////////////////////////+/v7eZWVl32ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/a2tr/3t7e/+Li4v/m5ub/83Nzf/8/Pz///////////////////////7+/v+urq7/fX19/+zs7P//////////////////////////////////////yMjI/6SkpP/t7e3/1NTU//b29v+wsLD/cHBw/6urq//ExMT/z8/P//b29v///////////////////////////////////////////7e3t/92dnb/5OTk/////////////////////////////////////////////v7+3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9nZ2f/iIiI/8vLy//r6+v/9/f3//v7+//9/f3/////////////////////////////////1NTU/3Jycv/Jycn//////////////////////////////////v7+/6urq/+VlZX/7e3t/5SUlP/Ly8v/5OTk/35+fv9ra2v/eXl5/4eHh//AwMD//v7+//////////////////////////////////39/f+dnZ3/hoaG//T09P////////////////////////////////////////////7+/t5lZWXfZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/eXl5/+Hh4f/+/v7//////////////////////////////////////////////////////+np6f9+fn7/kZGR//X19f////////////////////////////7+/v+lpaX/gYGB/+7u7v+rq6v/c3Nz/4SEhP9/f3//vLy8/+fn5//y8vL/8fHx//7+/v/////////////////////////////////4+Pj/jo6O/5WVlf/7+/v////////////////////////////////////////////+/v7eZWVl32ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/3l5ef+pqan/t7e3/9bW1v/39/f//////////////////////////////////////+Tk5P+UlJT/dHR0/5+fn//w8PD/////////////////////////////////t7e3/25ubv+lpaX/hoaG/2dnZ/9zc3P/1dXV//7+/v//////////////////////////////////////////////////////9fX1/4aGhv+goKD//f39/////////////////////////////////////////////v7+3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/bW1t/4qKiv+xsbH/6Ojo/////////////////////////////////+Li4v+Hh4f/g4OD/8/Pz//5+fn/////////////////////////////////+Pj4/6enp/9qamr/gICA/5qamv+EhIT/eXl5/9nZ2f/p6en/5OTk//T09P////////////////////////////////////////////Ly8v+CgoL/n5+f//T09P/7+/v//v7+//////////////////////////////////7+/t5lZWXfZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9nZ2f/goKC/8vLy//09PT//v7+/////////////////////////////////+7u7v+Ojo7/goKC/+Hh4f/+/v7//////////////////////////////////////8vLy/92dnb/sLCw/+zs7P/8/Pz/09PT/25ubv91dXX/fHx8/3p6ev+Xl5f/8PDw///////////////////////////////////////z8/P/g4OD/3BwcP+Ghob/lpaW/6ioqP+9vb3/z8/P/9/f3//r6+v/9fX1//v7+//9/f3eZWVl32ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/g4OD/+Hh4f/+/v7///////////////////////////////////////v7+/+srKz/bGxs/8TExP/+/v7///////////////////////////////////////////+2trb/srKy//r6+v//////9PT0/6CgoP93d3f/rKys/8/Pz//T09P/mpqa/+bm5v//////////////////////////////////////9vb2/4mJif9qamr/c3Nz/21tbf9mZmb/Z2dn/2pqav9wcHD/enp6/4eHh/+Wlpb/pqam3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/cHBw/8/Pz//+/v7////////////////////////////////////////////X19f/c3Nz/2xsbP+vr6//urq6/8jIyP/l5eX/+/v7////////////////////////////6+vr//Hx8f///////f39/7S0tP97e3v/0dHR//z8/P///////v7+/+vr6//8/Pz///////////////////////////////////////v7+/+8vLz/ysrK/+Li4v+oqKj/Z2dn/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/3Jycv+rq6v/1dXV//n5+f/////////////////////////////////4+Pj/mJiY/2ZmZv9mZmb/Z2dn/2ZmZv9paWn/d3d3/62trf/y8vL///////////////////////////////////////n5+f+Pj4//rq6u//39/f///////////////////////Pz8/+Li4v/FxcX/zc3N//b29v///////////////////////f39///////5+fn/lJSU/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVl32ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/3BwcP+/v7///v7+////////////////////////////29vb/3Fxcf9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2lpaf+AgID/yMjI//7+/v/////////////////////////////////9/f3/yMjI/7u7u//6+vr//////////////////////8/Pz/96enr/dnZ2/319ff/Q0ND/////////////////////////////////7e3t/319ff9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9mZmb/bW1t/2hoaP9nZ2f/jY2N/5qamv9xcXH/ZmZm/2ZmZv9mZmb/oKCg//39/f///////////////////////v7+/7Kysv9nZ2f/ZmZm/2ZmZv9mZmb/ZmZm/3BwcP+zs7P/7Ozs//v7+/////////////////////////////////////////////7+/v/8/Pz////////////////////////////Jycn/u7u7/+Pj4//o6Oj/9PT0/////////////////////////////////+Tk5P90dHT/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/5SUlP+vr6//jY2N/+Dg4P/6+vr/zMzM/39/f/9paWn/dnZ2/83Nzf////////////////////////////v7+/+Wlpb/ZmZm/2ZmZv9mZmb/ZmZm/2pqav+2trb/+/v7/////////////////////////////////////////////////////////////Pz8/+rq6v/u7u7//v7+/////////////f39//7+/v/////////////////////////////////////////////////j4+P/c3Nz/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVl32ZmZv+BgYH/6+vr//X19f/8/Pz///////7+/v/o6Oj/zc3N/9/f3//8/Pz////////////////////////////6+vr/kZGR/2ZmZv9mZmb/ZmZm/2ZmZv+Hh4f/8fHx////////////////////////////////////////////////////////////+fn5/7e3t/99fX3/oKCg//f39///////////////////////////////////////////////////////////////////////7Ozs/3t7e/9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9mZmb/aWlp/6qqqv/39/f//////////////////////////////////////////////////////////////////v7+/6urq/9nZ2f/ZmZm/2ZmZv9mZmb/nZ2d/9PT0/+9vb3/tLS0/8DAwP/e3t7/+fn5/////////////////////////////////83Nzf9zc3P/qqqq/+vr6//+/v7///////////////////////////////////////////////////////////////////////r6+v+Xl5f/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2ZmZv9sbGz/pKSk/+bm5v/8/Pz////////////////////////////////////////////////////////////i4uL/fX19/2ZmZv9mZmb/ZmZm/25ubv9sbGz/Z2dn/2ZmZv9nZ2f/cnJy/6Ghof/q6ur////////////////////////////Dw8P/n5+f//b29v//////////////////////////////////////////////////////////////////////////////////////zc3N/21tbf9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVl32ZmZv9mZmb/ZmZm/2dnZ/96enr/np6e/7q6uv/FxcX/8vLy/////////////////////////////////////////////v7+/8zMzP90dHT/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9nZ2f/j4+P/+3t7f//////////////////////9/f3//Pz8/////////////////////////////////////////////////////////////////////////////////////////////b29v+Xl5f/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9nZ2f/e3t7/+rq6v////////////////////////////n5+f/g4OD/8/Pz///////8/Pz/vb29/2xsbP9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/eHh4/7CwsP/t7e3/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////0tLS/2xsbP9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/b29v/62trf/7+/v//////+jo6P/w8PD////////////39/f/l5eX/5ycnP/39/f///////b29v+Tk5P/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/b29v/83Nzf/9/f3/////////////////////////////////////////////////////////////////////////////////////////////////////////////////9fX1/9jY2P/c3Nz/2dnZ/66urv9qamr/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVl32ZmZv9mZmb/ZmZm/2ZmZv9tbW3/pKSk/9fX1//4+Pj///////v7+/+kpKT/r6+v//39/f///////////7m5uf90dHT/4uLi//39/f/+/v7/ubm5/2dnZ/9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/3R0dP/Hx8f/9fX1/////////////////////////////////////////////////////////////////////////////////////////////////////////////////+/v7/+FhYX/bm5u/25ubv9oaGj/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/goKC/+/v7//////////////////e3t7/dnZ2/4ODg//y8vL////////////MzMz/a2tr/6ampv+3t7f/6Ojo/7S0tP9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/bGxs/5eXl//o6Oj////////////////////////////////////////////////////////////////////////////////////////////////////////////5+fn/kJCQ/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2ZmZv9mZmb/ampq/4SEhP/k5OT////////////z8/P/l5eX/2dnZ/+Ghob/8/Pz////////////x8fH/2hoaP9nZ2f/cHBw/83Nzf+Kior/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9nZ2f/kJCQ/+7u7v/////////////////////////////////////////////////////////////////////////////////8/Pz/9vb2//v7+///////+Pj4/42Njf9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVl32ZmZv9mZmb/eHh4/7q6uv/p6en//f39//7+/v/v7+//paWl/2pqav9oaGj/tLS0//39/f///////v7+/6ysrP9mZmb/ZmZm/3BwcP+RkZH/aWlp/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2hoaP+srKz/+/v7/////////////////////////////////////////////v7+//7+/v/////////////////39/f/ra2t/4iIiP+goKD/6Ojo/+np6f96enr/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9mZmb/ZmZm/2hoaP+Dg4P/sLCw/8fHx/+4uLj/iIiI/2lpaf9mZmb/bW1t/9HR0f/9/f3///////Dw8P+FhYX/ZmZm/2ZmZv9nZ2f/Z2dn/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/dXV1/+Dg4P////////////f39//19fX//////////////////////+Tk5P/a2tr//v7+////////////39/f/3Fxcf9mZmb/Z2dn/5ubm/+vr6//aWlp/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2ZmZv9mZmb/ZmZm/2dnZ/9oaGj/Z2dn/2ZmZv9mZmb/ZmZm/2dnZ/+Pj4//8/Pz//z8/P+4uLj/ampq/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2dnZ/+zs7P//v7+//7+/v+6urr/m5ub//T09P////////////z8/P+srKz/gICA/9XV1f/8/Pz//////+Dg4P9ycnL/ZmZm/2ZmZv9ra2v/bGxs/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVl32ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9sbGz/tra2//Ly8v++vr7/cnJy/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/kpKS//n5+f/m5ub/goKC/25ubv/a2tr///////z8/P/MzMz/c3Nz/2ZmZv92dnb/sLCw/9/f3//k5OT/gYGB/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9nZ2f/hoaG/62trf+NjY3/bGxs/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/3Jycv+kpKT/hoaG/2dnZ/9sbGz/z8/P/+Tk5P+wsLD/dHR0/2ZmZv9mZmb/ZmZm/2dnZ/9ycnL/fn5+/25ubv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2dnZ/9nZ2f/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/aWlp/4ODg/92dnb/aGho/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVl32ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVl32ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVl32ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZcNlZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32ZmZsIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACgAAAAwAAAAYAAAAAEAIAAAAAAAgCUAAAAAAAAAAAAAAAAAAAAAAABlZWXDZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mdnZ8FmZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/bm5u/46Ojv9ycnL/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9sbGz/ubm5/7q6uv9qamr/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv+RkZH/9fX1/8HBwf90dHT/ZmZm/21tbf9wcHD/ampq/2ZmZv9mZmb/b29v/319ff9ubm7/ZmZm/2dnZ/+Kior/mZmZ/4CAgP9ra2v/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/aWlp/2pqav9nZ2f/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZ2dn/2dnZ/9mZmb/ZmZm/2dnZ/+8vLz///////z8/P+dnZ3/bm5u/8TExP/f39//zMzM/6Ghof92dnb/g4OD/+Pj4//W1tb/nZ2d/25ubv+ZmZn/9vb2/+/v7//MzMz/kpKS/2xsbP9mZmb/ZmZm/2xsbP+ZmZn/ycnJ/8rKyv+FhYX/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgh4eH/3Jycv9mZmb/ZmZm/2lpaf/Kysr///////39/f+enp7/aWlp/83Nzf////////////z8/P/g4OD/qKio/+fn5///////+fn5/8fHx/+Li4v/6urq////////////9fX1/8LCwv97e3v/ampq/7Kysv/39/f//////8zMzP9vb2//ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5oaGjgv7+//5ubm/+bm5v/eXl5/2dnZ/+9vb3////////////Hx8f/jo6O/+Li4v//////////////////////+fn5//v7+/////////////39/f/Y2Nj/7Ozs//////////////////7+/v/d3d3/p6en//Ly8v///////////7i4uP9nZ2f/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5ra2vg0tLS//Hx8f/5+fn/z8/P/3d3d/+YmJj/+fn5///////9/f3/9vb2//7+/v/////////////////////////////////////////////////+/v7//v7+////////////////////////////+fn5//7+/v///////////+Xl5f+BgYH/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5nZ2fgs7Oz//39/f///////f39/97e3v/MzMz/+Pj4//////////////////////////////////////////////////////////////////////////////////39/f/y8vL/6+vr/+zs7P/19fX//v7+//////////////////7+/v/e3t7/kZGR/2tra/9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgdnZ2/8vLy//5+fn//////////////////////////////////////////////////Pz8//T09P/r6+v/5eXl/+Hh4f/j4+P/6enp//Ly8v/7+/v///////Pz8/+YmJj/fn5+/4eHh/+Ojo7/ra2t/+Pj4//9/f3/////////////////9PT0/8fHx/+QkJD/cnJy/2dnZ/9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/29vb/+YmJj/xcXF/9/f3//x8fH///////////////////////f39//MzMz/np6e/4WFhf95eXn/dHR0/3Fxcf9ycnL/d3d3/4SEhP+bm5v/v7+//+fn5/+5ubn/ioqK/93d3f/U1NT/pKSk/4WFhf/ExMT/+/v7///////////////////////39/f/39/f/729vf+YmJj/fX19/2xsbP9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/2ZmZv9mZmb/aWlp/3Z2dv/Gxsb//v7+////////////+vr6/6mpqf9sbGz/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/4yMjP/CwsL/qqqq/5WVlf+ioqL/fX19/93d3f//////+/v7/83Nzf+Dg4P/xsbG//39/f/////////////////////////////////7+/v/7e3t/9PT0/+srKz/hYWF/21tbf9mZmb/ZmZm/2ZmZt5mZmbgZmZm/2pqav+bm5v/tLS0/8fHx//39/f//Pz8/+7u7v//////6Ojo/3d3d/9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9nZ2f/bm5u/29vb//Dw8P//Pz8/+3t7f+8vLz/fX19/7+/v/////////////7+/v/Kysr/hISE/97e3v/l5eX/x8fH/7u7u//Gxsb/5+fn///////////////////////+/v7/8vLy/9LS0v+fn5//dHR0/2dnZ95paWngioqK/5GRkf/w8PD////////////39/f/u7u7/7y8vP//////5ubm/3V1df9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv91dXX/urq6/3Jycv99fX3/6enp///////+/v7/39/f/9LS0v/////////////////6+vr/pqam/4KCgv+Ghob/lpaW/5qamv9zc3P/xsbG///////////////////////////////////////7+/v/3t7e/6ioqN5mZmbglJSU/+Li4v/8/Pz/+vr6/+Dg4P+dnZ3/bW1t/8HBwf//////7e3t/3t7e/9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv+Wlpb/9vb2/7W1tf96enr/2dnZ//////////////////39/f//////////////////////4uLi/6CgoP/e3t7/+vr6/9PT0/+JiYn/8PDw//////////////////////////////////////////////////z8/N5mZmbgaWlp/4uLi/+oqKj/l5eX/3V1df9nZ2f/ZmZm/66urv/6+vr/5+fn/3d3d/9mZmb/ZmZm/2ZmZv9mZmb/Z2dn/2hoaP+2trb///////r6+v/l5eX/+Pj4/////////////////////////////////////////////f39//n5+f///////////7Kysv+goKD//f39//////////////////////////////////////////////////7+/t5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/4aGhv/h4eH/qamp/2hoaP9mZmb/ZmZm/2dnZ/93d3f/p6en/4aGhv/Hx8f//////////////////////////////////////////////////////////////////////////////////v7+/6Kiov+xsbH/+vr6/+3t7f/n5+f/7+/v//v7+/////////////////////////////7+/t5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/Z2dn/4eHh/+JiYn/cHBw/3l5ef+CgoL/lpaW/7q6uv/k5OT/9vb2/5GRkf/Ly8v//////////////////////////////////////////////////////////////////////////////////v7+/6enp/+Ojo7/mpqa/4mJif+Ghob/gYGB/7e3t//8/Pz///////////////////////7+/t5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/fn5+/9vb2//y8vL/+/v7/////////////Pz8/5iYmP/BwcH//////////////////////////////////f39//v7+//Pz8//zc3N//X19f///////////////////////////8XFxf+Hh4f/wcHB/+Tk5P/S0tL/fX19/9LS0v/+/v7///////////////////////7+/t5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/aWlp/5+fn//t7e3//////////////////v7+/62trf+pqan//v7+///////////////////////+/v7/0NDQ/+/v7//m5ub/np6e/52dnf/s7Oz/+fn5//7+/v////////////X19f/v7+///v7+//////+8vLz/k5OT//j4+P////////////////////////////7+/t5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/3BwcP+ampr/vr6+/9DQ0P/r6+v//////////////////////87Ozv+MjIz/8/Pz///////////////////////19fX/m5ub/9vb2/+/v7//5eXl/4iIiP+Ghob/lpaW/87Ozv/+/v7///////////////////////z8/P+bm5v/tra2//////////////////////////////////7+/t5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ampq/7y8vP/5+fn//////////////////////////////////////+bm5v9/f3//zs7O///////////////////////w8PD/iIiI/9bW1v+ampr/k5OT/4iIiP+wsLD/1tbW/+Li4v/9/f3///////////////////////f39/+NjY3/zc3N//////////////////////////////////7+/t5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/a2tr/5OTk/+srKz/3d3d//7+/v//////////////////////6urq/5ubm/+Ojo7/1tbW///////////////////////19fX/iIiI/46Ojv9/f3//a2tr/8TExP/9/f3///////////////////////////////////////Ly8v+IiIj/2NjY//////////////////////////////////7+/t5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/aWlp/4+Pj//Hx8f/6enp//7+/v/////////////////v7+//lZWV/6ampv/w8PD////////////////////////////R0dH/gYGB/66urv/Pz8//i4uL/5ubm/+vr6//t7e3//Hx8f////////////////////////////Hx8f+EhIT/qamp/83Nzf/d3d3/6urq//T09P/7+/v//v7+//7+/t5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9paWn/paWl//Ly8v////////////////////////////r6+v+pqan/jIyM//Hx8f////////////////////////////7+/v+wsLD/zc3N//z8/P/p6en/ioqK/5WVlf+5ubn/p6en/9TU1P////////////////////////////T09P+FhYX/cXFx/3Nzc/9wcHD/eHh4/4WFhf+UlJT/pqam/7i4uN5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv+CgoL/6Ojo//7+/v///////////////////////////9XV1f9xcXH/goKC/6enp/+2trb/39/f//z8/P/////////////////t7e3/+/v7//v7+/+ioqL/r6+v//f39///////9/f3//j4+P/9/f3/+fn5//7+/v////////////v7+//Nzc3/3t7e/7Kysv9nZ2f/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9vb2//jo6O/9LS0v/+/v7/////////////////+fn5/5iYmP9mZmb/ZmZm/2ZmZv9nZ2f/eHh4/8rKyv/+/v7///////////////////////n5+f+lpaX/3t7e/////////////////+3t7f+np6f/k5OT/9LS0v///////////////////////Pz8/5+fn/9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgaWlp/2tra/9tbW3/j4+P/3d3d/9mZmb/ZmZm/5iYmP/7+/v/////////////////4+Pj/3R0dP9mZmb/ZmZm/2ZmZv94eHj/vr6+/+vr6//+/v7////////////////////////////09PT/9vb2/////////////////9XV1f+xsbH/zs7O/+Tk5P//////////////////////+Pj4/4uLi/9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgdnZ2/7a2tv+wsLD/8/Pz/9vb2/+QkJD/gICA/8fHx//+/v7/////////////////zs7O/2pqav9mZmb/ZmZm/29vb//MzMz//v7+///////////////////////////////////////9/f3/4uLi/9nZ2f/8/Pz///////39/f/9/f3/////////////////////////////////9/f3/4uLi/9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgampq/7u7u//7+/v////////////29vb/8PDw//39/f//////////////////////09PT/2tra/9mZmb/ZmZm/42Njf/n5+f/4+Pj/+bm5v/29vb////////////////////////////T09P/hoaG/7e3t//5+fn//////////////////////////////////////////////////Pz8/5+fn/9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/3R0dP+/v7//8vLy//7+/v//////////////////////////////////////8fHx/4uLi/9mZmb/ZmZm/3R0dP99fX3/c3Nz/3V1df+Pj4//0dHR//z8/P////////////7+/v+1tbX/wsLC//z8/P///////////////////////////////////////////////////////////8/Pz/9tbW3/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/2ZmZv9ra2v/hoaG/6Ojo/++vr7/+vr6///////////////////////+/v7//////9zc3P99fX3/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/enp6/9ra2v/////////////////19fX/+vr6//////////////////////////////////////////////////////////////////f39/+Wlpb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2hoaP+kpKT//Pz8//n5+f/7+/v///////b29v+5ubn/5+fn//7+/v/Kysr/bm5u/2ZmZv9mZmb/ZmZm/2ZmZv9zc3P/wsLC//Pz8//////////////////////////////////////////////////////////////////////////////////5+fn/8/Pz//Pz8/+zs7P/Z2dn/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/2ZmZv9mZmb/gICA/7m5uf/u7u7//v7+/8PDw//Ly8v///////z8/P+hoaH/ra2t//z8/P/y8vL/hISE/2ZmZv9mZmb/ZmZm/2ZmZv+EhIT/4+Pj//39/f/////////////////////////////////////////////////////////////////////////////////c3Nz/iIiI/4KCgv9xcXH/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/2ZmZv9nZ2f/tbW1//7+/v//////7e3t/4WFhf+cnJz//Pz8//////+zs7P/fX19/6qqqv/b29v/goKC/2ZmZv9mZmb/ZmZm/2ZmZv9oaGj/fHx8/8nJyf/9/f3////////////////////////////////////////////////////////////////////////////l5eX/dHR0/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/21tbf+UlJT/1NTU//7+/v/19fX/paWl/2lpaf+vr6///v7+//7+/v+np6f/ZmZm/3Fxcf+jo6P/a2tr/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/3Z2dv/Y2Nj///////////////////////////////////////////////////////z8/P/W1tb/ysrK//Hx8f/c3Nz/b29v/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/2xsbP+dnZ3/y8vL/8nJyf+Wlpb/ampq/25ubv/U1NT///////Ly8v+Ghob/ZmZm/2hoaP9ra2v/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv+Tk5P/9/f3///////19fX/+/v7////////////9/f3/+Dg4P/9/f3//////+fn5/95eXn/aWlp/52dnf+np6f/Z2dn/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/2ZmZv9mZmb/aWlp/2lpaf9mZmb/ZmZm/2dnZ/+rq6v/+fn5/7m5uf9qamr/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9xcXH/3d3d//v7+/+np6f/wsLC//7+/v/+/v7/0NDQ/4GBgf/Kysr/+fn5/+bm5v92dnb/ZmZm/2pqav9ra2v/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/3d3d/+/v7//q6ur/3BwcP9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9oaGj/sLCw/7+/v/9xcXH/m5ub//X19f/S0tL/gICA/2ZmZv9vb2//lpaW/7CwsP94eHj/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2xsbP9wcHD/Z2dn/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ampq/2pqav9mZmb/fn5+/5CQkP9wcHD/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbFZmZm4GZmZuBmZmbgZmZm4GZmZuBmZmbgZmZm4GZmZuBmZmbgZmZm4GZmZuBmZmbgZmZm4GZmZuBmZmbgZmZm4GZmZuBmZmbgZmZm4GZmZuBmZmbgZmZm4GZmZuBmZmbgZmZm4GZmZuBmZmbgZmZm4GZmZuBmZmbgZmZm4GZmZuBmZmbgZmZm4GZmZuBmZmbgZmZm4GZmZuBmZmbgZmZm4GZmZuBmZmbgZmZm4GZmZuBmZmbgZmZm4GVlZcMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAoAAAAKAAAAFAAAAABACAAAAAAAEAaAAAAAAAAAAAAAAAAAAAAAAAAZWVlwmZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZWVlwWVlZd9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9qamr/cXFx/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVl32ZmZv9mZmb/ZmZm/2ZmZv9tbW3/r6+v/46Ojv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/mpqa/+zs7P+Tk5P/Z2dn/21tbf9xcXH/aWlp/2ZmZv9qamr/e3t7/25ubv9mZmb/cnJy/5KSkv+BgYH/bGxs/2ZmZv9mZmb/ZmZm/2ZmZv9nZ2f/a2tr/2lpaf9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfampq/2ZmZv9mZmb/aGho/8fHx//+/v7/1dXV/29vb/+4uLj/4ODg/8nJyf+ZmZn/fHx8/9XV1f/V1dX/mZmZ/3l5ef/c3Nz/8PDw/83Nzf+RkZH/a2tr/2ZmZv9xcXH/q6ur/9PT0/+qqqr/aWlp/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbea2tr35iYmP9tbW3/ampq/2pqav/Q0ND//////93d3f9ycnL/wMDA////////////+fn5/9LS0v/l5eX///////f39/+6urr/zMzM////////////9PT0/7u7u/95eXn/vr6+//v7+//19fX/i4uL/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3nZ2dt/W1tb/x8fH/7m5uf9vb2//uLi4//7+/v/4+Pj/zs7O/+7u7v///////////////////////v7+////////////+vr6//Ly8v/////////////////8/Pz/3t7e//X19f//////+Pj4/5aWlv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5xcXHf29vb//7+/v/6+vr/w8PD/7q6uv/7+/v//////////////////////////////////////////////////////////////////v7+//n5+f/29vb/+fn5//7+/v/////////////////j4+P/jo6O/2lpaf9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZmZm35aWlv/p6en//v7+//7+/v/9/f3///////////////////////7+/v/4+Pj/7+/v/+fn5//j4+P/5eXl/+zs7P/29vb//f39//T09P+ioqL/kZGR/5qamv+wsLD/4ODg//39/f////////////Hx8f+/v7//iYmJ/29vb/9nZ2f/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9nZ2f/f39//6ysrP/Nzc3/7Ozs//////////////////Dw8P+6urr/j4+P/319ff92dnb/cnJy/3R0dP97e3v/k5OT/62trf/U1NT/ra2t/6SkpP/g4OD/v7+//5KSkv/BwcH/+/v7/////////////v7+//T09P/a2tr/t7e3/5SUlP95eXn/ampq/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2lpaf9zc3P/g4OD/9ra2v/+/v7//v7+//r6+v+hoaH/aWlp/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ampq/66urv/S0tL/sLCw/5eXl/+Li4v/8/Pz//7+/v/k5OT/lZWV/8nJyf/+/v7/+vr6//X19f/4+Pj//v7+///////6+vr/6enp/8rKyv+enp7/eXl5/2hoaP9mZmbeampq33BwcP+hoaH/4+Pj/+3t7f/7+/v/19fX/+zs7P/z8/P/goKC/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/cnJy/4ODg/96enr/4ODg//z8/P/h4eH/pqam/+rq6v///////////9zc3P+QkJD/uLi4/52dnf+VlZX/lZWV/+Li4v//////////////////////+/v7/+bm5v+1tbX/gYGB3mxsbN+srKz/5+fn//7+/v/w8PD/t7e3/4WFhf/q6ur/9vb2/4iIiP9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/5ubm//Y2Nj/fX19/7a2tv////////////f39//7+/v////////////9/f3/s7Oz/5+fn//Z2dn/zs7O/5GRkf/y8vL//////////////////////////////////v7+/+3t7d5lZWXfeHh4/6ysrP+tra3/hoaG/2lpaf91dXX/39/f//Pz8/+Ghob/ZmZm/2ZmZv9mZmb/Z2dn/2lpaf++vr7//f39/+Pj4//o6Oj///////////////////////////////////////b29v/39/f//////8DAwP+srKz//v7+///////////////////////////////////////+/v7eZWVl32ZmZv9mZmb/ZmZm/2ZmZv9mZmb/a2tr/7e3t/+5ubn/bW1t/2ZmZv9oaGj/d3d3/6Wlpf+SkpL/z8/P//////////////////////////////////////////////////////////////////////+xsbH/ubm5/+rq6v/a2tr/3Nzc//Hx8f/+/v7//////////////////v7+3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2tra/99fX3/cnJy/5SUlP+pqan/xcXF/+bm5v/6+vr/pKSk/9DQ0P/////////////////////////////////5+fn/9vb2//7+/v//////////////////////urq6/4SEhP+Xl5f/np6e/4KCgv+urq7/+/v7//////////////////7+/t5lZWXfZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2xsbP+8vLz/+fn5/////////////////7CwsP/BwcH///////////////////////39/f/t7e3/7Ozs/66urv/IyMj/+/v7/////////////////+Pj4//FxcX/8fHx/+/v7/+RkZH/3Nzc///////////////////////+/v7eZWVl32ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/3V1df+Tk5P/r6+v/+jo6P/////////////////Ly8v/pKSk//z8/P/////////////////t7e3/tbW1/9vb2//a2tr/kJCQ/6mpqf/CwsL/9PT0///////+/v7//v7+///////b29v/lpaW//f39////////////////////////v7+3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/3l5ef/W1tb/+fn5//7+/v//////////////////////5OTk/4uLi//n5+f/////////////////4uLi/5mZmf/Gxsb/l5eX/5GRkf+pqan/zMzM/+/v7///////////////////////yMjI/6enp//+/v7///////////////////////7+/t5lZWXfZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9zc3P/nZ2d/8zMzP/7+/v/////////////////7e3t/6Kiov+ioqL/7Ozs/////////////////+Xl5f+AgID/kZGR/3Jycv+0tLT/9vb2//z8/P///////////////////////////76+vv+wsLD//v7+///////////////////////+/v7eZWVl32ZmZv9mZmb/ZmZm/2ZmZv9nZ2f/hoaG/8zMzP/u7u7//f39////////////9PT0/6CgoP+4uLj/+Pj4//////////////////7+/v+3t7f/paWl/97e3v+vr6//hYWF/56env+xsbH/+Pj4//////////////////////+9vb3/gICA/6Wlpf+5ubn/zMzM/9zc3P/p6en/8vLy3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/f39//+Pj4////////////////////////v7+/7y8vP+AgID/09PT/+jo6P/6+vr////////////9/f3/z8/P//X19f/q6ur/mZmZ/8bGxv/o6Oj/0tLS//f39///////////////////////z8/P/5qamv+UlJT/aGho/2lpaf9vb2//eHh4/4KCgt5lZWXfZmZm/2ZmZv9mZmb/ZmZm/4CAgP/BwcH/9vb2/////////////////+vr6/9/f3//aWlp/29vb/94eHj/qKio//Pz8/////////////7+/v//////zs7O/7e3t//9/f3///////7+/v/g4OD/ubm5/93d3f////////////v7+//7+/v/tra2/2dnZ/9mZmb/ZmZm/2ZmZv9mZmbeZWVl32tra/9paWn/goKC/3p6ev9nZ2f/bm5u/9fX1//////////////////Dw8P/aWlp/2ZmZv9mZmb/fn5+/8HBwf/09PT///////////////////////b29v/s7Oz//v7+///////6+vr/tra2/7q6uv/Z2dn//v7+/////////////f39/52dnf9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd+Kior/urq6/+Pj4//h4eH/nJyc/52dnf/u7u7////////////+/v7/p6en/2ZmZv9mZmb/c3Nz/9XV1f/+/v7////////////////////////////+/v7/4eHh/87Ozv/7+/v//v7+//v7+/////////////////////////////z8/P+cnJz/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfc3Nz/9HR0f/9/f3///////r6+v/6+vr//////////////////////7a2tv9nZ2f/ZmZm/4WFhf/Hx8f/vr6+/87Ozv/x8fH/////////////////6urq/5SUlP/Kysr/+/v7////////////////////////////////////////////uLi4/2dnZ/9mZmb/ZmZm/2ZmZv9mZmbeZWVl32ZmZv93d3f/srKy/9nZ2f/q6ur//v7+///////////////////////r6+v/iIiI/2ZmZv9paWn/aWlp/2dnZ/9qamr/jY2N/+Tk5P///////////+/v7//X19f//v7+/////////////////////////////////////////////////+fn5/98fHz/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9mZmb/ZmZm/2dnZ/9ubm7/rq6u//39/f/8/Pz///////n5+f/Z2dn/+Pj4/93d3f95eXn/ZmZm/2ZmZv9mZmb/Z2dn/4+Pj//f39///////////////////////////////////////////////////////////////////v7+//r6+v/5+fn/pqam/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2ZmZv9zc3P/qKio/+jo6P/19fX/vb29//j4+P/6+vr/np6e/9LS0v/6+vr/paWl/2ZmZv9mZmb/ZmZm/21tbf/Gxsb/+/v7//////////////////////////////////////////////////////////////////f39/+oqKj/kpKS/3d3d/9mZmb/ZmZm/2ZmZv9mZmbeZWVl32ZmZv9mZmb/lJSU//j4+P/+/v7/yMjI/319ff/n5+f//v7+/6enp/+JiYn/vb29/6Ghof9mZmb/ZmZm/2ZmZv9mZmb/c3Nz/7a2tv/6+vr//////////////////////////////////////////////////v7+//7+/v/6+vr/k5OT/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9mZmb/iIiI/9DQ0P/29vb/1dXV/319ff+Kior/9PT0//r6+v+Wlpb/ZmZm/4ODg/90dHT/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9vb2//ysrK//7+/v///////////////////////Pz8//39/f//////9vb2/7Kysv+xsbH/5eXl/4SEhP9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/25ubv+Kior/j4+P/3Nzc/9mZmb/jIyM//Ly8v/e3t7/dnZ2/2ZmZv9nZ2f/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/42Njf/19fX/7Ozs/9XV1f/9/f3//v7+/9DQ0P/MzMz//Pz8/+Xl5f90dHT/aWlp/4qKiv9ra2v/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVl32ZmZv9mZmb/ZmZm/2ZmZv9mZmb/Z2dn/5GRkf/Pz8//i4uL/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9ycnL/1NTU/6urq/+JiYn/8vLy/97e3v+EhIT/c3Nz/6urq//Hx8f/eHh4/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2dnZ/94eHj/cXFx/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/Z2dn/3V1df9ra2v/dnZ2/52dnf94eHj/ZmZm/2ZmZv9nZ2f/a2tr/2hoaP9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVl32ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVlw2VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZmZmwgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAKAAAACAAAABAAAAAAQAgAAAAAACAEAAAAAAAAAAAAAAAAAAAAAAAAGVlZcJmZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5mZmbeZmZm3mZmZt5lZWXBZWVl32ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2ZmZv9mZmb/bm5u/5SUlP9vb2//ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9mZmb/ZmZm/2ZmZv+kpKT/zc3N/3Fxcf9tbW3/cXFx/2lpaf9nZ2f/d3d3/25ubv9nZ2f/g4OD/4GBgf9sbGz/ZmZm/2ZmZv9mZmb/aGho/21tbf9oaGj/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeaWlp32xsbP9mZmb/ampq/9HR0f/39/f/jo6O/6ioqP/g4OD/xMTE/5CQkP/ExMT/1NTU/5SUlP+vr6//8PDw/87Ozv+Pj4//aWlp/3l5ef++vr7/ysrK/3l5ef9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt6AgIDfoKCg/4aGhv9vb2//0tLS//z8/P+rq6v/wMDA////////////8vLy/+7u7v//////8/Pz/87Ozv/8/Pz///////Ly8v+zs7P/y8vL//7+/v/Q0ND/a2tr/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3oiIiN/r6+v/8PDw/6ioqP/AwMD//v7+//j4+P/6+vr//////////////////////////////////f39//7+/v/9/f3//f39//v7+//8/Pz//////+7u7v+RkZH/aGho/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbebm5u38HBwf/4+Pj/+vr6//b29v/////////////////9/f3/8/Pz/+rq6v/l5eX/5+fn/+/v7//5+fn/9fX1/7Gxsf+oqKj/uLi4/97e3v/8/Pz//////+/v7/+2trb/goKC/2xsbP9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfbm5u/5OTk/+5ubn/6urq////////////6Ojo/6enp/+EhIT/eHh4/3R0dP91dXX/h4eH/6qqqv/Dw8P/oaGh/7+/v//V1dX/qKio/8HBwf/7+/v///////7+/v/w8PD/1dXV/7Gxsf+Ojo7/dHR0/2hoaP9mZmb/ZmZm3mZmZt9ra2v/kJCQ/6mpqf/s7Oz/9PT0//z8/P+ioqL/Z2dn/2ZmZv9mZmb/ZmZm/2lpaf95eXn/zc3N/9bW1v+kpKT/sLCw//7+/v/09PT/qqqq/83Nzf/j4+P/0dHR/9vb2//6+vr//v7+//f39//j4+P/u7u7/4mJif9ra2vedHR036ioqP/w8PD/+fn5/8/Pz/+1tbX/+vr6/5iYmP9mZmb/ZmZm/2ZmZv9mZmb/l5eX/5qamv+bm5v/+vr6//b29v/g4OD//v7+///////o6Oj/lZWV/6qqqv+xsbH/mZmZ//X19f/////////////////+/v7/8/Pz/83Nzd5paWnfmpqa/8DAwP+dnZ3/cHBw/5ubm//29vb/mJiY/2ZmZv9mZmb/Z2dn/2tra//Gxsb/7e3t/9LS0v/8/Pz///////////////////////39/f/n5+f/+fn5/8/Pz/+7u7v//v7+/////////////////////////////v7+3mVlZd9mZmb/Z2dn/2ZmZv9mZmb/goKC/7m5uf92dnb/bGxs/3p6ev+jo6P/n5+f/9bW1v//////////////////////////////////////////////////////wsLC/7q6uv/S0tL/ycnJ/+Hh4f/9/f3////////////+/v7eZWVl32ZmZv9mZmb/ZmZm/2ZmZv9sbGz/bm5u/6ioqP/V1dX/6urq//v7+/+6urr/1NTU//////////////////7+/v/6+vr/4ODg/+3t7f/+/v7////////////R0dH/mZmZ/7+/v/+jo6P/r6+v//z8/P////////////7+/t5lZWXfZmZm/2ZmZv9mZmb/ZmZm/2dnZ/91dXX/oaGh/+/v7////////////8zMzP/AwMD/////////////////6enp/9nZ2f/T09P/pKSk/9DQ0P/r6+v//v7+//j4+P/09PT//Pz8/6mpqf/f39///////////////////v7+3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/kpKS/+Dg4P/z8/P//Pz8////////////4uLi/6CgoP/39/f////////////S0tL/tra2/6mpqf+ampr/qKio/9LS0v/8/Pz////////////19fX/oqKi//Ly8v/////////////////+/v7eZWVl32ZmZv9mZmb/ZmZm/2ZmZv+FhYX/vb29//X19f////////////Hx8f+srKz/vLy8//j4+P///////////83Nzf+MjIz/i4uL/6Kiov/m5ub/9/f3//////////////////Dw8P+fn5//7Ozs//r6+v/+/v7///////7+/t5lZWXfZmZm/2ZmZv9mZmb/dHR0/8XFxf/09PT//v7+///////6+vr/rKys/8LCwv/7+/v////////////8/Pz/uLi4/9vb2//Kysr/kZGR/66urv/MzMz/////////////////8fHx/4uLi/+NjY3/kpKS/6Ojo/+4uLj/ysrK3mVlZd9mZmb/ZmZm/2ZmZv+UlJT/6urq//7+/v///////////9TU1P90dHT/jY2N/6ampv/h4eH//v7+//7+/v/z8/P/9/f3/6ysrP/n5+f/+/v7//Pz8//j4+P/6+vr///////7+/v/39/f/7q6uv9paWn/ZmZm/2ZmZv9oaGjeZWVl32tra/90dHT/e3t7/2pqav+ampr/+vr6///////7+/v/nZ2d/2ZmZv9mZmb/g4OD/8/Pz//9/f3////////////8/Pz/4uLi//v7+///////5ubm/7CwsP/Q0ND//v7+////////////sbGx/2ZmZv9mZmb/ZmZm/2ZmZt5mZmbfo6Oj/9XV1f/m5ub/q6ur/8fHx//9/f3///////X19f+Ghob/ZmZm/3d3d//b29v/+/v7//7+/v/////////////////l5eX/yMjI//r6+v/8/Pz//Pz8//////////////////////+wsLD/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd+AgID/19fX//j4+P/8/Pz//v7+////////////+/v7/6Ghof9nZ2f/d3d3/5mZmf+Wlpb/u7u7//T09P///////Pz8/7i4uP/a2tr//f39/////////////////////////////////9LS0v9tbW3/ZmZm/2ZmZv9mZmbeZWVl32ZmZv9ycnL/jo6O/8vLy//+/v7//v7+//z8/P/w8PD/6Ojo/4iIiP9mZmb/ZmZm/2ZmZv9zc3P/y8vL//7+/v/+/v7/9vb2//7+/v/////////////////////////////////+/v7/9vb2/5CQkP9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2tra/+YmJj/4+Pj/+Dg4P/k5OT/+Pj4/6urq//q6ur/yMjI/2pqav9mZmb/ZmZm/5mZmf/y8vL//////////////////////////////////////////////////////9LS0v+kpKT/fHx8/2ZmZv9mZmb/ZmZm3mVlZd9nZ2f/g4OD/+vr6//19fX/mZmZ/7+/v//8/Pz/nZ2d/5WVlf+ysrL/aWlp/2ZmZv9mZmb/bW1t/6Ojo//19fX//////////////////////////////////v7+//X19f/6+vr/wcHB/2dnZ/9mZmb/ZmZm/2ZmZv9mZmbeZWVl321tbf+qqqr/1NTU/6Ojo/9ycnL/1dXV//Ly8v+Ghob/a2tr/3Nzc/9mZmb/ZmZm/2ZmZv9mZmb/ampq/76+vv/+/v7/9vb2//7+/v/+/v7/7Ozs//z8/P/u7u7/kpKS/6ampv+bm5v/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2lpaf9sbGz/Z2dn/21tbf/FxcX/tra2/2tra/9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/i4uL/+Xl5f+jo6P/6+vr/+bm5v+Ojo7/u7u7/9bW1v93d3f/aWlp/2pqav9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/bm5u/4ODg/9sbGz/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9tbW3/gICA/3BwcP+kpKT/g4OD/2dnZ/9paWn/dnZ2/2pqav9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVl32ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZt5lZWXfZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm3mVlZd9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmbeZWVlw2VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32ZmZsIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACgAAAAYAAAAMAAAAAEAIAAAAAAAYAkAAAAAAAAAAAAAAAAAAAAAAABmZmbEZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZcNmZmbgZmZm/2ZmZv9sbGz/c3Nz/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2VlZd9mZmbgZmZm/2dnZ/+np6f/mZmZ/2xsbP9xcXH/aGho/3Jycv9ubm7/cXFx/39/f/9sbGz/ZmZm/2ZmZv9ra2v/bGxs/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2VlZd9wcHDgbW1t/25ubv/Y2Nj/yMjI/5ubm//f39//urq6/729vf/T09P/pKSk/+Pj4//Ozs7/ioqK/4ODg//MzMz/nZ2d/2dnZ/9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2VlZd+amprgxcXF/5WVlf/S0tL/7Ozs/9ra2v/+/v7//v7+//n5+f//////8vLy//j4+P//////7u7u/+Pj4//8/Pz/p6en/2hoaP9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2VlZd+Hh4fg5OTk/+7u7v/v7+/////////////5+fn/7u7u/+jo6P/q6ur/8vLy//b29v/FxcX/xsbG/9/f3//7+/v/7+/v/6+vr/99fX3/a2tr/2ZmZv9mZmb/ZmZm/2VlZd9nZ2fgfn5+/6qqqv/s7Oz//////+Hh4f+Wlpb/fHx8/3Z2dv94eHj/oKCg/8DAwP+enp7/0tLS/8LCwv/Hx8f/+/v7//r6+v/q6ur/z8/P/6urq/+Hh4f/bm5u/2VlZd9xcXHgpaWl/9nZ2f/f39//6+vr/7Gxsf9mZmb/ZmZm/2ZmZv+AgID/lZWV/+bm5v/Jycn/5OTk//v7+//BwcH/t7e3/7S0tP/BwcH//f39//7+/v/z8/P/1NTU/6CgoN93d3fgurq6/7i4uP+Dg4P/0tLS/6+vr/9mZmb/ZmZm/21tbf/IyMj/ycnJ/+/v7//+/v7//f39///////y8vL/3Nzc/9PT0//IyMj//v7+//////////////////v7+99mZmbgaGho/2dnZ/9oaGj/mpqa/4mJif+CgoL/oqKi/6+vr//d3d3//////////////////f39//39/f///////////9LS0v+1tbX/wcHB/87Ozv/8/Pz///////7+/t9mZmbgZmZm/2ZmZv9mZmb/aWlp/5qamv/r6+v//Pz8/9LS0v/X19f////////////z8/P/4uLi/8jIyP/u7u7//Pz8/+rq6v/Pz8//zc3N/7y8vP/9/f3///////7+/t9mZmbgZmZm/2ZmZv9qamr/qKio/9zc3P/5+fn//////+Hh4f+8vLz//v7+///////MzMz/u7u7/6Kiov+zs7P/6+vr////////////zMzM/9vb2/////////////7+/t9mZmbgZmZm/2ZmZv9tbW3/rq6u/+/v7///////9fX1/7q6uv/U1NT//v7+//39/f+6urr/oqKi/5iYmP/V1dX/9/f3////////////wcHB/8fHx//o6Oj/8vLy//n5+d9mZmbgZmZm/2ZmZv+ampr/8vLy//7+/v/9/f3/urq6/6enp//e3t7/+/v7//v7+//d3d3/2dnZ/7e3t//W1tb/7e3t//j4+P//////0tLS/56env95eXn/goKC/46Ojt9oaGjgb29v/3l5ef98fHz/2dnZ///////u7u7/gICA/2pqav+Tk5P/6+vr////////////5+fn/+/v7//9/f3/z8/P/8/Pz//9/f3//f39/8bGxv9oaGj/ZmZm/2VlZd9wcHDgvLy8/+Xl5f/BwcH/7Ozs///////h4eH/cXFx/3d3d//R0dH/7u7u//39/f//////7+/v/8rKyv/5+fn/+vr6//39/f///////////8bGxv9oaGj/ZmZm/2VlZd9nZ2fgh4eH/8PDw//s7Oz///////7+/v/y8vL/mZmZ/2xsbP93d3f/gICA/8zMzP/+/v7/6+vr/+jo6P/+/v7//////////////////////+jo6P98fHz/ZmZm/2VlZd9mZmbgZ2dn/4qKiv/e3t7/4eHh//X19f/Gxsb/29vb/3Z2dv9mZmb/dXV1/9bW1v/+/v7/////////////////////////////////8fHx/729vf99fX3/ZmZm/2VlZd9mZmbgeHh4/9fX1//X19f/n5+f//Ly8v+Xl5f/oKCg/3V1df9mZmb/aWlp/5KSkv/t7e3////////////+/v7//v7+//v7+//j4+P/3Nzc/3R0dP9mZmb/ZmZm/2VlZd9mZmbgdnZ2/5iYmP96enr/mZmZ/9ra2v92dnb/ampq/2dnZ/9mZmb/ZmZm/2hoaP+2trb/4+Pj/+zs7P/p6en/zMzM/+Pj4/+BgYH/h4eH/2lpaf9mZmb/ZmZm/2VlZd9mZmbgZmZm/2ZmZv9mZmb/gYGB/39/f/9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv98fHz/hISE/6SkpP+Pj4//b29v/4aGhv9tbW3/ZmZm/2ZmZv9mZmb/ZmZm/2VlZd9mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2dnZ/9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2VlZd9mZmbgZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2VlZd9mZmbFZmZm4GZmZuBmZmbgZmZm4GZmZuBmZmbgZmZm4GZmZuBmZmbgZmZm4GZmZuBmZmbgZmZm4GZmZuBmZmbgZmZm4GZmZuBmZmbgZmZm4GZmZuBmZmbgZmZm4GVlZcQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAoAAAAFAAAACgAAAABACAAAAAAAJAGAAAAAAAAAAAAAAAAAAAAAAAAZmZmxGVlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZd9lZWXfZWVl32VlZcNmZmbgZmZm/2xsbP+Dg4P/aGho/2ZmZv9mZmb/ZmZm/2ZmZv9nZ2f/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZmZm/2ZmZv9mZmb/ZWVl32hoaOBnZ2f/j4+P/8nJyf+FhYX/n5+f/4WFhf+fn5//h4eH/6+vr/+RkZH/bGxs/4CAgP+Pj4//aWlp/2ZmZv9mZmb/ZmZm/2ZmZv9lZWXfk5OT4Jqamv+goKD/6+vr/8XFxf/7+/v/7e3t//b29v/m5ub/7+/v//b29v/Gxsb/4+Pj/8XFxf9paWn/ZmZm/2ZmZv9mZmb/ZmZm/2VlZd+ZmZng6enp/9/f3//7+/v//f39//f39//s7Oz/6enp/+/v7//19fX/0NDQ/9XV1f/w8PD/8vLy/6ysrP96enr/ampq/2ZmZv9mZmb/ZWVl32lpaeCPj4//zc3N//z8/P/f39//j4+P/3p6ev93d3f/kpKS/8PDw/+lpaX/19fX/8HBwf/p6en/8fHx/+Pj4//Nzc3/pqam/4GBgf9qamrff39/4MvLy//U1NT/0dHR/729vf9mZmb/ZmZm/3t7e/+dnZ3/3d3d/9/f3//19fX/7e3t/7a2tv+6urr/ycnJ///////9/f3/7+/v/8nJyd9wcHDgjIyM/3Z2dv+dnZ3/paWl/2xsbP+AgID/paWl//Dw8P/29vb////////////+/v7/9vb2/9vb2//Nzc3/5+fn//f39////////v7+32ZmZuBmZmb/ZmZm/29vb/+QkJD/0tLS/+np6f/BwcH//Pz8///////4+Pj/5OTk/+vr6//9/f3/5eXl/8DAwP+0tLT/4ODg///////+/v7fZmZm4GZmZv9mZmb/iYmJ/83Nzf/4+Pj//f39/76+vv/x8fH//////87Ozv+3t7f/qqqq/9/f3//9/f3//Pz8/8LCwv/19fX///////7+/t9mZmbgZmZm/2hoaP+hoaH/7e3t///////d3d3/xcXF//f39//8/Pz/urq6/6Ojo/+1tbX/6enp///////7+/v/s7Oz/9HR0f/i4uL/7Ozs32ZmZuBmZmb/d3d3/9nZ2f//////8vLy/5SUlP+mpqb/5eXl//z8/P/u7u7/zMzM/97e3v/m5ub/5+fn//z8/P/V1dX/i4uL/3Fxcf96enrfcnJy4KCgoP+dnZ3/vb29//7+/v/W1tb/bW1t/46Ojv/m5ub////////////p6en/8fHx/+3t7f/l5eX//v7+//f39/+JiYn/ZmZm/2VlZd9vb2/gt7e3/+Tk5P/4+Pj//////+Hh4f94eHj/hoaG/52dnf/X19f//v7+/9ra2v/u7u7//////////////////Pz8/6SkpP9mZmb/ZWVl32ZmZuBwcHD/tra2/+jo6P/x8fH/09PT/7a2tv9oaGj/bGxs/8PDw//+/v7//f39///////////////////////m5ub/paWl/2hoaP9lZWXfZ2dn4JKSkv/c3Nz/o6Oj/+Xl5f+VlZX/k5OT/2hoaP9nZ2f/ioqK/+np6f/+/v7///////v7+//5+fn/2dnZ/7a2tv9oaGj/ZmZm/2VlZd9mZmbgdnZ2/3p6ev+BgYH/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'
        $NUServiceSC='W3swMDAyMTRBMC0wMDAwLTAwMDAtQzAwMC0wMDAwMDAwMDAwNDZ9XQ0KUHJvcDM9MTksMTENCltJbnRlcm5ldFNob3J0Y3V0XQ0KSURMaXN0PQ0KVVJMPWh0dHBzOi8vbnVzZXJ2aWNlLm5jbC5hYy51ay8NCkljb25JbmRleD0wDQpIb3RLZXk9MA0KSWNvbkZpbGU9QzpcUHJvZ3JhbSBGaWxlc1xOVUlUIEljb25zXE5VU2VydmljZS5pY28NCg=='
        [IO.File]::WriteAllBytes($env:SystemDrive + "\Program Files\NUIT Icons\NUService.ico", [Convert]::FromBase64String($NUServiceIcon))
        [IO.File]::WriteAllBytes($env:SystemDrive + "\Users\Public\Desktop\NUService.url", [Convert]::FromBase64String($NUServiceSC))
        
        $SWCenterSC=$Shell.CreateShortcut($env:SystemDrive + "\Users\Public\Desktop\Software Center.lnk")
        $SWCenterSC.TargetPath = "softwarecenter:"
        $SWCenterSC.IconLocation = $env:SystemRoot + "\CCM\scclient.exe, 0";
        $SWCenterSC.Save()

        if((Get-ExecutionPolicy) -notlike 'Restricted'){
        Set-ExecutionPolicy Restricted -ErrorAction SilentlyContinue
        }

        if(!(Test-Path HKLM:\SOFTWARE\NUIT\InstallFlags)){New-Item -Path HKLM:\SOFTWARE\NUIT\InstallFlags | Out-Null}
        New-ItemProperty -Path "HKLM:\SOFTWARE\NUIT\InstallFlags" -Name "NCL Compliance Script Complete" -Value $((Get-Date).ToShortDateString()) | Out-Null
        #REG ADD "HKLM\SOFTWARE\NUIT\InstallFlags" /v "Surface Compliance Script Complete" /t REG_SZ /d "$((Get-Date).ToShortDateString())" /f | Out-Null

        #Add Cleanup stuff here
        #Remove AutoLogin if used
        #Remove Task if used
        #Remind user - Add to required collections
        Write-Host "Removing Auto Logon.."
        if(Get-ItemProperty 'HKLM:\SOFTWARE\NUIT\DeviceCompliance' -Name AutoLogon -ErrorAction SilentlyContinue){
        Unregister-ScheduledTask -TaskName "Device Compliance Script Resume" -Confirm:$false

        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 0 | Out-Null
    
        Remove-Item -Path "HKLM:\SOFTWARE\NUIT\DeviceCompliance"
        Remove-Item -Path $env:SystemDrive\DeviceCompliance -Force -Recurse
                
        #REG DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultUserName" /f | Out-Null
        #REG DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultPassword" /f | Out-Null
        #REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" /t REG_SZ /d "0" /f | Out-Null

        #REG DELETE "HKLM\SOFTWARE\NUIT\DeviceCompliance" /f | Out-Null
        }

        Write-Host
        Write-Host "All done! If not already done, remember to:"
        Write-Host "   • Add the machine to the security groups:"
        Write-Host "        `'FMS-Laptops`' (Essential for BitLocker policy!)"
        Write-Host "        `'Default Domain Policy Exclusion Group`'"
        Write-Host "     (You can add it to both groups at once by selecting the 'Groups' option on a machine with RSAT tools installed)."
        #if((Get-ExecutionPolicy) -notlike 'Restricted'){
        #Write-Host
        #Write-Host "   • Re-set the Powershell Script Execution Policy to `'Restricted`'"
        #Write-Host
        #}
        if((Get-BitLockerVolume | Select-Object -Expand ProtectionStatus) -ne "On"){
        Write-Host
        Write-Host "   • Enable Bitlocker (This will be enforced once the device is in the `'FMS-Laptops`' group)." -ForegroundColor Red
        Write-Host
        }
        Write-Host "   • Add the device to the correct Collections in SCCM"
        Write-Host
        Write-Host "The CCM Setup will continue in the background, allow 10-15 minutes for this"
        PS-Pause -Quit


        }#End bracket for sub 'else', runs if domain check is campus.ncl.ac.uk

    }#end bracket for sub 'else', runs if domain join did not fail

}#End bracket for main 'else'. Stuff to do AFTER domain join is above



#Bitlocker
#Don't think we need this, it's handled by the domain join and policy, but we'll put it at the end after the client install
#Enable-BitLocker -MountPoint C: -UsedSpaceOnly -RecoveryPasswordProtector -SkipHardwareTest



#NOT REQUIRED - Done on Domain Join
#Backup Key to AD - DOES THIS HAPPEN IF WE ADD IT TO THE FMS-LAPTOPS GROUP FIRST??
#$BLV = Get-BitLockerVolume -MountPoint "C:"
#Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId