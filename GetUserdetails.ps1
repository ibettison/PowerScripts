function Get-UserBySurname{
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
    [Parameter(Mandatory,HelpMessage='Enter the Surname to search for', Position=0)]
    [String]
    $Surname
		
  )
  $searchFor = $Surname + "*"
  Get-ADUser -Filter {Surname -like $searchFor} | Select-Object -Property Name,SamAccountName,GivenName,Surname

}