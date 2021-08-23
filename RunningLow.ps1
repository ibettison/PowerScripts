# Drives to check: set to $null or empty to check all local (non-network) drives
# $drives = @("C","D");
$drives = $null
 
# The minimum disk size to check for raising the warning
$minSize = 20GB
# In order to get the secure password below - run the following at the PowerShell command prompt
# $pass = (Get-Credential).Password | ConvertFrom-SecureString
# Type $pass and press enter to display the value then copy it below into the $secureString value between the quotations.
 
$secureString = "01000000d08c9ddf0115d1118c7a00c04fc297eb01000000c5728067ab70164d8afb501c17895be10000000002000000000003660000c000000010000000b04ed4d65ed0dfa0e64f4a2ef0e38a5c0000000004800000a000000010000000d72829d2b026ec47e5760702e2531007200000009a
5d70572373c19091a1297d2c711853a96ca574b1db902e232af220f8d8037e1400000074e282bc09c6101cd8e87980fa3bf9c1dc52fff6" 
# SMTP configuration: username, password & so on
$email_username = "nib8@newcastle.ac.uk"
$email_password = ConvertTo-SecureString -String $secureString -AsPlainText -Force
$email_smtp_host = "smtp.ncl.ac.uk"
$email_smtp_port = 25
$email_smtp_SSL = 0
$email_from_address = "ian.bettison@ncl.ac.uk"
$email_to_addressArray = @("ian.bettison@ncl.ac.uk", "ian@bettison.me.uk")
 
 
if ($drives -eq $null -Or $drives -lt 1) {
    $localVolumes = Get-WMIObject win32_volume;
    $drives = @()
    foreach ($vol in $localVolumes) {
        if ($vol.DriveType -eq 3 -And $vol.DriveLetter -ne $null ) {
            $drives += $vol.DriveLetter[0]
        }
    }
}
foreach ($d in $drives) {
    Write-Host ("`r`n")
    Write-Host ("Checking drive " + $d + " ...")
    $disk = Get-PSDrive $d
    if ($disk.Free -lt $minSize) {
        Write-Host ("Drive " + $d + " has less than " + $minSize `
            + " bytes free (" + $disk.free + "): sending e-mail...")
        
        $message = new-object Net.Mail.MailMessage
        $message.From = $email_from_address
        foreach ($to in $email_to_addressArray) {
            $message.To.Add($to)
        }
        $message.Subject =  ("[RunningLow] WARNING: " + $env:computername + " drive " + $d)
        $message.Subject += (" has less than " + $minSize + " bytes free ")
        $message.Subject += ("(" + $disk.Free + ")")
        $message.Body =     "Hello there, `r`n`r`n"
        $message.Body +=    "this is an automatic e-mail message "
        $message.Body +=    "sent by RunningLow Powershell script "
        $message.Body +=    ("to inform you that " + $env:computername + " drive " + $d + " ")
        $message.Body +=    "is running low on free space. `r`n`r`n"
        $message.Body +=    "--------------------------------------------------------------"
        $message.Body +=    "`r`n"
        $message.Body +=    ("Machine HostName: " + $env:computername + " `r`n")
        $message.Body +=    "Machine IP Address(es): "
        $ipAddresses = Get-NetIPAddress -AddressFamily IPv4
        foreach ($ip in $ipAddresses) {
            if ($ip.IPAddress -like "127.0.0.1") {
                continue
            }
            $message.Body += ($ip.IPAddress + " ")
        }
        $message.Body +=    "`r`n"
        $message.Body +=    ("Used space on drive " + $d + ": " + $disk.Used + " bytes. `r`n")
        $message.Body +=    ("Free space on drive " + $d + ": " + $disk.Free + " bytes. `r`n")
        $message.Body +=    "--------------------------------------------------------------"
        $message.Body +=    "`r`n`r`n"
        $message.Body +=    "This warning will fire when the free space is lower "
        $message.Body +=    ("than " + $minSize + " bytes `r`n`r`n")
        $message.Body +=    "Sincerely, `r`n`r`n"
        $message.Body +=    "-- `r`n"
        $message.Body +=    "RunningLow`r`n"
 
        $smtp = new-object Net.Mail.SmtpClient($email_smtp_host, $email_smtp_port)
        $smtp.EnableSSL = $email_smtp_SSL
        $smtp.Credentials = New-Object System.Net.NetworkCredential($email_username, $email_password)
        $smtp.send($message) | Out-Null
        $message.Dispose()
        write-host "... E-Mail sent!" 
    }
    else {
        Write-Host ("Drive " + $d + " has more than " + $minSize + " bytes free: nothing to do.")
    }
}