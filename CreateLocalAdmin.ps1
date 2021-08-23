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

# SIG # Begin signature block
# MIID3gYJKoZIhvcNAQcCoIIDzzCCA8sCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUGKaQLP7ul3rfkA21LhHljN/e
# W8+gggH9MIIB+TCCAWKgAwIBAgIQUihwo69eK71MIhSzQy3PIzANBgkqhkiG9w0B
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
# hkiG9w0BCQQxFgQUxK4fuxcQD9WoLIpfuA4kwr9YXXgwDQYJKoZIhvcNAQEBBQAE
# gYCOzCkTnsqWShEcFaqX5UquWKY9Ggsg43pJvzfDlIfKu5445yTZRi/fAm4q7/Lo
# RqlxwAkvahIkq4Ob9izGIwyP5iSOdFL65a3wJ1dtWtcqxe6YqCjOEyCk5SUpX1Se
# drwWQJhk4/keKZov4CJHNwKA68zolV+bZH3q8wg82EqMRA==
# SIG # End signature block
