
$Location = 'CRF'
$User = 'ndw28'
$computers = Get-ADComputer -SearchBase "OU=$location,OU=Departments, dc=campus, dc=ncl, dc=ac, dc=uk"  -Filter {enabled -eq $true} -Properties *
#$computers = Get-ADComputer CRF111 -Properties *
foreach ($computer in $computers)
{
  try
    {
    $computer
      # Content
        #if($loggedOn =(Get-WmiObject -ComputerName $computer.Name -Class Win32_ComputerSystem).UserName = $User) {
         # $loggedOn
        #} 

    }  
  catch
  {
    "Error was $_"
    $line = $_.InvocationInfo.ScriptLineNumber
    "Error was in Line $line"
  }
}

# SIG # Begin signature block
# MIID3gYJKoZIhvcNAQcCoIIDzzCCA8sCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUKr0UVHv88Uca+tJMrUSiXqyI
# Y6SgggH9MIIB+TCCAWKgAwIBAgIQc4Nh+/GWxplDa1rmslSV8jANBgkqhkiG9w0B
# AQUFADAXMRUwEwYDVQQDDAxJYW4gQmV0dGlzb24wHhcNMTcwNDI1MDkwOTIwWhcN
# MjEwNDI1MDAwMDAwWjAXMRUwEwYDVQQDDAxJYW4gQmV0dGlzb24wgZ8wDQYJKoZI
# hvcNAQEBBQADgY0AMIGJAoGBAKpoXS51e+bK18r5PV4Mil0LZegUuqYCKCiRKsau
# o/RvRV3rtv/SLlFJ8o8NRQztjLYIvZriWn0ESBLQ7A/3eWIfY/zHY666dwWzRF9q
# VAc+2+UFxtbrpSbCG80EBVYM+xDqfDfjfX0KrvPzRbuMNd1UxU/6j0RBYIqo50bE
# vuE5AgMBAAGjRjBEMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBRK/5Nk
# 4Z1HJAN7fhlWsE6psLQPpTAOBgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQEFBQAD
# gYEAAeUBN53GZ+uKfDbpNbzvK1d9id6GFqgXvydufFOK4jUiUk0M30PCX4YtYjZQ
# AZqLQ076lcOEg4bDnsHGe/DK+5KWJWK2sFTL6Nj96pV/AU5cTx/Ja5cSvO9ZNbDu
# tvofYyabOFl+LX+Rr8mOQ5fgnkXGuwXrcSvYHrYL+NxAKb8xggFLMIIBRwIBATAr
# MBcxFTATBgNVBAMMDElhbiBCZXR0aXNvbgIQc4Nh+/GWxplDa1rmslSV8jAJBgUr
# DgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMx
# DAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkq
# hkiG9w0BCQQxFgQU+NDWkzqvlCsVSbtUFbvjiNZPWggwDQYJKoZIhvcNAQEBBQAE
# gYAsMkmwLRW2J4D5Vxm5kvt6nxdIukVchSyYOGbi4m01F+VpKIUyYvmlv9cajaWB
# mOnKw/SCfnJVhafPEClsjIsDyMgOROYuc+8XFxxzRus0vjV34uMt7TSX8fVTBsAH
# jrdwdx6rjTUMaELS5y+K6Tqaywle98QAKZRAtAe9uraIVg==
# SIG # End signature block
