function New-Encryption
{
  <#
    .SYNOPSIS
    Create an encrypted file containing the UAC credentials to run on a remote computer
    .DESCRIPTION
    Create an encrypted file containing the UAC credentials to run on a remote computer these credentials require manually transferring to the client to enable running the powershell file requiring elivated priviledges
    .EXAMPLE
    New-Encryption
    explains how to use the command
    can be multiple lines
    .EXAMPLE
    New-Encryption
    another example
    can have as many examples as you like
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


# SIG # Begin signature block
# MIID3gYJKoZIhvcNAQcCoIIDzzCCA8sCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZgvC9jDEONZaNvEBQ9IM9sej
# v8OgggH9MIIB+TCCAWKgAwIBAgIQUihwo69eK71MIhSzQy3PIzANBgkqhkiG9w0B
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
# hkiG9w0BCQQxFgQUXWtWGhe6zlrmy2Zjj+VrrdtPTgwwDQYJKoZIhvcNAQEBBQAE
# gYBn+x6w0G7tpRpZvwXJ/deatA1KmUthcS8au98LNwbq31CQDyH22ivjfkDAu0yV
# BZGbn04rXzR4V4LClsELsCcJ+okXmI8hSLCWooCALds7vp8LVDs57UU7Bfi+dsc1
# Iz9P8+lQTZnhAbEigyTJDxTebexn4YeLdFa3fJ7ujJ0RZg==
# SIG # End signature block
