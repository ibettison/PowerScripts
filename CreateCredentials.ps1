function Get-Credentials
{
  <#
      .SYNOPSIS
      function to allow remote running of scripts
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
    $RemoteProtected = "$env:SystemDrive\Temp\Protected\",
    
    [Parameter(Position=1)]
    [string]
    $UserName = 'CAMPUS\\sib8'
  )
  
  
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
  
  return $credentials}
  
function Add-NewLocalAdmin {
  <#
      .SYNOPSIS
      Create a local administrator

      .DESCRIPTION
      This function creates a local administrator on the local computer

      .PARAMETER NewLocalAdmin
      The name of the local Administrator

      .PARAMETER Password
      The password of the local Administrator

      .EXAMPLE
      Add-NewLocalAdmin -NewLocalAdmin Value -Password Value
      Pass the new local admin users name and password to create the local administrator.
  #>


    param (
        [Parameter(Mandatory)][string] $NewLocalAdmin,
        [Parameter(Mandatory)][securestring] $Password
    )    
    begin {
    }    
    process {
        New-LocalUser -Name ('{0}' -f $NewLocalAdmin) -Password $Password -FullName ('{0}' -f $NewLocalAdmin) -Description 'Temporary local admin'
        Write-Verbose -Message ('{0} local user crated' -f $NewLocalAdmin)
        Add-LocalGroupMember -Group 'Administrators' -Member ('{0}' -f $NewLocalAdmin)
        Write-Verbose -Message ('{0} added to the local administrator group' -f $NewLocalAdmin)
    }    
    end {
    }
}  
  #$credentials = Get-Credentials -RemoteProtected "$env:SystemDrive\Temp\Protected\" -UserName '\\campus\sib8'
  $NewLocalAdmin = Read-Host -Prompt 'New local admin username:'
  $Password = Read-Host -AsSecureString -Prompt ('Create a password for {0}' -f $NewLocalAdmin)  
  Add-NewLocalAdmin -NewLocalAdmin $NewLocalAdmin -Password $Password


# SIG # Begin signature block
# MIID3gYJKoZIhvcNAQcCoIIDzzCCA8sCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUQF79NMTZjw2wDHwlKFP3t+Eg
# IligggH9MIIB+TCCAWKgAwIBAgIQUihwo69eK71MIhSzQy3PIzANBgkqhkiG9w0B
# AQUFADAXMRUwEwYDVQQDDAxJYW4gQmV0dGlzb24wHhcNMTkwNTE2MTA0NjM4WhcN
# MjMwNTE2MDAwMDAwWjAXMRUwEwYDVQQDDAxJYW4gQmV0dGlzb24wgZ8wDQYJKoZI
# hvcNAQEBBQADgY0AMIGJAoGBAJKiZlHCjeMlpIpso6hrzip8oajgpZHn+5D2hv78
# EUIQ+TaqQl6L0CNTQ82GhBRPqBsSs8jMCiVOnkENtxuh7by+hNcYgBdqAQBD/hRu
# CGEnNoak2UZYjjYTIGiK6XXkRsEZHmJilya/tPylor743gq8c9WSrZKSbOlfkITK
# O4GnAgMBAAGjRjBEMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBQIMb1W
# XTKIUKYZkU/xBLckP8t7/jAOBgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQEFBQAD
# gYEAi2kgC1PJedWFkne/VquYoQB+z904EPJndQ2HTv3uigBPPkrIATZ4e3XCgovW
# rs/57xEM4L7678M3/s56f5UoOj35HqboJ8rQdhqL8TfL01xiwOBydBkG3IRAcKoa
# RGl6gffahltDcVki7z8ZllIOat/qSda1HfMVIE3cWcpcctwxggFLMIIBRwIBATAr
# MBcxFTATBgNVBAMMDElhbiBCZXR0aXNvbgIQUihwo69eK71MIhSzQy3PIzAJBgUr
# DgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMx
# DAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkq
# hkiG9w0BCQQxFgQUUMqYKf213ET2+hpTsP5W7ty57+gwDQYJKoZIhvcNAQEBBQAE
# gYAvcwSJaBZrcZWKcODiBnkYluMCDprlbWkJCOjyQxwLAJ5XC1P2yhXEIZ7n+qio
# ttumKFPny80RLZI3E5Qk+A3Wp4dS/h17alet+UOW1ixrXV73XrJ5dcyu94IPrRKf
# yHWlkd1y+5Y78/62ZiTFp7bubpBKdu+PvVOQ43/GmIncEw==
# SIG # End signature block
