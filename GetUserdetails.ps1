function Get-UserByName{
  <#
      .SYNOPSIS
      Describe purpose of "Get-UserBySurname" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .PARAMETER Surname
      Describe parameter -Surname.

      .EXAMPLE
      Get-UserBySurname -Surname Value
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Get-UserBySurname

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>


  param
  (
    [Parameter(Mandatory,HelpMessage='Enter the Name or Id to search for', Position=0)]
    [String]
    $Name,
    [Parameter(Mandatory,HelpMessage='Enter either First, Last, Full or Id', Position=0)]
    [String]
    $SearchType
		
  )

  $Name = "$Name*"
  switch ( $SearchType )
  {
      First {
              Get-ADUser -Filter {GivenName -like $Name}  | Select-Object -Property Name,SamAccountName,GivenName,Surname
              Write-Host "Hello" 
            }
      Last  {Get-ADUser -Filter {Surname -like $Name} | Select-Object -Property Name,SamAccountName,GivenName,Surname    }
      Full  {Get-ADUser -Filter {GivenName+" "+Surname -eq "$Name" } | Select-Object -Property Name,SamAccountName,GivenName,Surname   }
      Id    {Get-ADUser -Filter {SamAccountName -eq "$Name"} | Select-Object -Property Name,SamAccountName,GivenName,Surname }
  }
}

