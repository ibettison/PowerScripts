function Get-InactiveADComputers
{
  <#
    .SYNOPSIS
    Check an AD Branch for inactive computers
    .DESCRIPTION
    Check an AD branch for inactive computers. Enter the OU starting point and the number of days inactive to check for.
    .EXAMPLE
    Get-InactiveADComputers -SearchAD CRF -DaysInactive 365
    Use the parameters of SearchAD to specify theOU to search and -DaysInactive to enter the number of days to class as inactive.
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory, Position=0)]
    [System.String]
    $SearchAD,
    
    [Parameter(Mandatory=$false, Position=1)]
    [System.Int32]
    $DaysInactive = 365
  )
  
  $time = (Get-Date).Adddays(-($DaysInactive))
  Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -ResultPageSize 2000 -resultSetSize $null -Properties Name, OperatingSystem `
  -SearchScope Subtree -SearchBase "OU=$SearchAD,OU=Departments,DC=campus,DC=ncl,DC=ac,DC=uk"
}

