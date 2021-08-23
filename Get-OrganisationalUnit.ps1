function Select-OUs
 {
   <#
       .SYNOPSIS
       Allows a search for a partial text to match AD OUs and list them
       .DESCRIPTION
       Search to find the list of Active Directory OUs matching the partial string parameter -ADGroup then displays the members of that group 
       .EXAMPLE
       Select-Groups -ADOU Projects
       This will search for Active Directory Group matching the partial text passed using the -ADGroup parameter and return the members of the group and the group name
   #>
   param
   (
     [Parameter(Mandatory, Position=0)]
     [String]
     $ADOU    
   )
   
   $ErrorActionPreference = "Stop"
   [hashtable]$return = @{}
   try 
   {
     if([string]::IsNullOrEmpty($ADOU))
     {
       throw 'Cannot search on NULL data.'
     }
     # adds asterisks to the passed parameter to pass into the filter option in the scriptBlock below.		
     $ADGOU = '*' + $ADOU + '*'
     # Start a job to list all of the Active Directory Groups matching the parameter (No output)
     Start-Job -Name getList -ScriptBlock {param([Parameter(Mandatory,HelpMessage='Enter the Partial Organisational Unit')][String]$pOU) Get-ADOrganizationalUnit -Filter {Name -like $pOU} -Properties * | Select-Object -Property Name, DistinguishedName} -ArgumentList $ADOU | Out-Null
     # wait for the job to finish (No output)
     Wait-Job -Name getList | Out-Null
     # It is now safe to receive the output from the job.
     $OUList = Receive-Job -Name getList | Sort-Object
     # has the search returned any information
     if([string]::IsNullOrEmpty($OUList)) 
     {
       throw 'OU was not found.'
     }
     else
     {
       # setup a grid view to select the Group Multiple selection
       $Idx =0
       $OU = $(foreach ($item in $OUList){
           $item | Select-Object -Property @{l='IDX'
           e={$Idx}}, Name, DistinguishedName
       $Idx++	}) |
       Out-GridView -Title 'Select the AD OU' -OutputMode Single |
       ForEach-Object { $OUList[$_.IDX] }
     }
   }
   catch
   {
     Write-Host ('ERROR : {0}' -f $_) -ForegroundColor Red
   }
   return $OU
 }