
#+++++++++++++++DISCLAIMER+++++++++++++++++++++++++++++
#--------------------------------------------------------------------------------- 
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty  
#of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for 
#a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall 
#Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use 
#of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 
#---------------------------------------------------------------------------------

# Get the remote server names

# $computers = Get-Content "C:\Users\administrator\Desktop\remotecomputers.txt"
$computers = "ntrf-web1"

#Running the invoke-command on remote machine to run the iisreset


foreach ($computer in $computers) 
{
       Write-Host "Details from server $computer..."

       Invoke-command  -ComputerName $computer  -ScriptBlock{

       # Ensure to import the WebAdministration module

            Import-Module WebAdministration
            set-Location IIS:\AppPools
            
            #Get the Application Pools of the server

            $appPoolCollections = dir
            foreach ($pool in $appPoolCollections)
            {
                # Loop through the collection and find the status of the appPool 
                $appPoolName = $pool.Name
                $appPoolState = $pool.state
                $appPoolVersion= $pool.managedRuntimeVersion
                Write-Host "$appPoolName with version $appPoolVersion is $appPoolState"

            }
        } 

        Write-Host "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}
