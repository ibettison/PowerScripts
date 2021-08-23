function Select-Groups
 {
   <#
       .SYNOPSIS
       Allows a search for a partial text to match AD Group and list members in the group
       .DESCRIPTION
       Search to find the list of Active Directory Groups matching the partial string parameter -ADGroup then displays the members of that group 
       .EXAMPLE
       Select-Groups -ADGroup CRF
       This will search for Active Directory Group matching the partial text passed using the -ADGroup parameter and return the members of the group and the group name
   #>
   param
   (
     [Parameter(Mandatory, Position=0)]
     [String]
     $ADGroup    
   )
   
   $ErrorActionPreference = "Stop"
   [hashtable]$return = @{}
   try 
   {
     if([string]::IsNullOrEmpty($ADGroup))
     {
       throw 'Cannot search on NULL data.'
     }
     # adds asterisks to the passed parameter to pass into the filter option in the scriptBlock below.		
     $ADGroup = '*' + $ADGroup + '*'
     # Start a job to list all of the Active Directory Groups matching the parameter (No output)
     Start-Job -Name getList -ScriptBlock {param([Parameter(Mandatory,HelpMessage='Enter the Partial Group')][String]$pGroup) Get-ADGroup -Filter {Name -like $pGroup} -Properties * | Select-Object -Property Name, Description} -ArgumentList $ADGroup | Out-Null
     # wait for the job to finish (No output)
     Wait-Job -Name getList | Out-Null
     # It is now safe to receive the output from the job.
     $groupList = Receive-Job -Name getList | Sort-Object
     # has the search returned any information
     if([string]::IsNullOrEmpty($groupList)) 
     {
       throw 'Group was not found.'
     }
     else
     {
       # setup a grid view to select the Group Multiple selection
       $Idx =0
       $group = $(foreach ($item in $groupList){
           $item | Select-Object -Property @{l='IDX'
           e={$Idx}}, Name, Description
       $Idx++	}) |
       Out-GridView -Title 'Select All of the AD Groups to Grant Access' -OutputMode Multiple |
       ForEach-Object { $groupList[$_.IDX] }
     }
   }
   catch
   {
     Write-Host ('ERROR : {0}' -f $_) -ForegroundColor Red
   }
   return $group
 }