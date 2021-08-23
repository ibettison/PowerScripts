function Get-FolderAccess
{
  <#
      .SYNOPSIS
      Returns the access groups and users of the folders inside a passed parameter (folder)
      .DESCRIPTION
      Receives a folder parameter and determines the access of each folder in the passed folder
      .EXAMPLE
      Get-FolderAccess -path "\\campus\dept\crf"
      .RETURNS
      The selected groups with access to a manually selected choice of folders.
      Folder Name              Group/User                                Permissions Inherited
      -----------              ----------                                ----------- ---------
      \\campus\dept\crf\IT\SRN CAMPUS\CRF_Administrators                 FullControl      True
      \\campus\dept\crf\IT\SRN CAMPUS\CRF - Information Technology       FullControl      True
      \\campus\dept\crf\IT\SRN CAMPUS\Campus Webfolder Servers     Read, Synchronize      True
      \\campus\dept\crf\IT\SRN CAMPUS\CRF Admin Group                    FullControl      True
      \\campus\dept\crf\IT\SRN BUILTIN\Administrators                    FullControl      True 
  #>
  param
  (
    [Parameter(Mandatory,HelpMessage='Please enter a path', Position=0)]
    [Object]$path
  )
  $FolderPath = (Get-ChildItem -Directory -Path ('{0}' -f $path) -Force)
  
  $Output = @()
  $GroupsId = @()
  ForEach ($Folder in $FolderPath) 
  {
    $Acl = Get-Acl -Path $Folder.FullName
    ForEach ($Access in $Acl.Access) 
    {
      $Properties = [ordered]@{'Folder Name'=$Folder.FullName;'Group/User'=$Access.IdentityReference;'Permissions'=$Access.FileSystemRights;'Inherited'=$Access.IsInherited}
      $Output += New-Object -TypeName PSObject -Property $Properties            
    }
  }
  
  $Idx=0
  $item=""
  # Pipe the groups into a GridView
  $Groups = $(foreach ($item in $Output ){
              $item | Select-Object -Property @{l='IDX'
                    e={$Idx}}, *
                $Idx++	}) |	Out-GridView -Title 'Select the Groups to identify members' -OutputMode Multiple |
          ForEach-Object { $Output[$_.IDX] }	
  return $Groups
}
# SIG # Begin signature block
# MIID3gYJKoZIhvcNAQcCoIIDzzCCA8sCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUV5WKpshI2ajuald1HO0bVtrw
# Yr+gggH9MIIB+TCCAWKgAwIBAgIQGSRf+W35IotAImM/6TUuxzANBgkqhkiG9w0B
# AQUFADAXMRUwEwYDVQQDDAxJYW4gQmV0dGlzb24wHhcNMTcwNDI4MDgzMDM3WhcN
# MjEwNDI4MDAwMDAwWjAXMRUwEwYDVQQDDAxJYW4gQmV0dGlzb24wgZ8wDQYJKoZI
# hvcNAQEBBQADgY0AMIGJAoGBAKuEcX8bvzsWz94mWGsHr1CHHvqg9YyWv4/wRAki
# KDvuMsOQJHPaiRRcKnwZN8NsA6ZST3LKH3hEycMBTK7N6aHPvz0gj1oOJkEE6UYv
# iO+nGYOPBgsmr/Jca0lUQJ5WUZywgYygrQJC48YgXwmWevqruKUmEpBR+O1i+DbP
# l8ERAgMBAAGjRjBEMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBQ3UR9H
# xueybrz56h+0tmfMxWHgYDAOBgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQEFBQAD
# gYEAWLHmiaG9mMtr2z4e8q+ftK2yMh+5rR7n77rF/KPbWHV37FmB5S5o4IjdsTnE
# BPv1wUFFDyfac+rudVt4Cy5uyPVcO3FWQ34tuQgrZMid6v9OcAFAUWX1UvHOlI5M
# nVu10Y5SIsCtKThTWW5UWm0yCuIe+FsmnlvMWwFdANen3NoxggFLMIIBRwIBATAr
# MBcxFTATBgNVBAMMDElhbiBCZXR0aXNvbgIQGSRf+W35IotAImM/6TUuxzAJBgUr
# DgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMx
# DAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkq
# hkiG9w0BCQQxFgQU/iKL3QKmGUfqaOErBCQxdAL7FfIwDQYJKoZIhvcNAQEBBQAE
# gYAaHRZOQBeR4dgG1TK36WhOXQwRgJ5w/1M5RRZ1nQ98xAYjX5eM1uYNU9vX1CAc
# ZJdE34vs3yz+28+RR2BWNNkT14IJ9/n9KrM6r+ZUywfTYN3se1yAvdPo2oysnWPk
# dB4jWtsDtKzietftanw8AAV6Ej4qqvB6HQ/U7x98qJA6pw==
# SIG # End signature block
