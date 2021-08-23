function Get-QUPathMilestone
{
    <#
        .SYNOPSIS
        function to Uninstall (if required) and download and install the latest version of the QUPath Milestone
        .DESCRIPTION
        Function that allows the Uninstallation of the oldversion of QUPath if it has been installed and download and install the new version of QUPath milestone.
        .EXAMPLES
        BaseVersion is automatically set to v0.2.0 replace version m5 with m6
        Get-QupathMilestone -OldVersion m5 -NewVersion m6
         
        Install the new version with differing BaseVersion note: no -OldVersion so nothing will be Uninstalled.
        Get-QupathMilestone -BaseVersion v0.2.1 -NewVersion m1
         
        
    #>
    param
    (
      [Parameter(Position=0)]
      [string]
      $BaseVersion = "v0.2.0" ,
      [Parameter(Position=1)]
      [string]
      $OldVersion,    
      [Parameter(Position=2, Mandatory=$true)]
      [string]
      $NewVersion,
      [Parameter(Position=3)]
      [string]
      $file = 'QUPathLog'
    )
    #make sure the versions are entered in lowercase else the download fails
    $Oldversion = $OldVersion.ToLower()
    $NewVersion = $Newversion.ToLower()
    
    $uri = ("https://github.com/qupath/qupath/releases/download/{0}-{2}/QuPath-{1}-{2}-Windows.msi" -f $BaseVersion, $BaseVersion.Substring(1), $NewVersion)
    $out = "C:\Temp\QuPathInstaller.msi"
    
    try 
      {
      Set-Location -Path c:\Users
      
      #Uninstall the old version if it is found and it has been requested to do so
      if([string]::IsNullOrEmpty($OldVersion))
      {
        #delete the old downloaded file.
        if (Test-Path $out) 
        {
          Remove-Item $out
        }
      }else{
      
        Write-Host ("Uninstalling the older version of QUPath - version {0}-{1}" -f $BaseVersion, $OldVersion) -ForegroundColor Cyan
        Remove-Item H:\Desktop\QuPath*.lnk
        $package = Get-WmiObject -Class Win32_Product | Where-Object Name -eq ("QuPath-0.2.0-{0}" -f $OldVersion)
        
        if([string]::IsNullOrEmpty($package))
        {
          throw "There has been an error with the Uninstall."
        }else {
          $package.Uninstall()
        }
        #delete the old downloaded file.
        if (Test-Path $out) 
        {
          Remove-Item $out
        } 
      }
      
      #Download and Run MSI package for Automated install
      Write-Host ("Please wait downloading QuPath version {0}-{1}" -f $BaseVersion, $NewVersion) -ForegroundColor Cyan
      
      Invoke-WebRequest -uri $uri -OutFile $out
      $DateStamp = get-date -Format yyyyMMddTHHmmss
      $logFile = 'c:\Temp\{0}-{1}.log' -f $file,$DateStamp
      $MSIArguments = @(
        "/i"
        ('"{0}"' -f $out)
        #"/qn"
        "/norestart"
        "/L*v"
        $logFile
      )
      Write-Host ("Please wait! Now Installing - QuPath version {0}-{1}" -f $BaseVersion ,$NewVersion) -ForegroundColor Cyan
      Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow
      Write-Host ("Qupath version {0}-{1} has been installed." -f $BaseVersion, $NewVersion)
      
      }
      catch
      {
        Write-Host "ERROR :" $_.Exception
      }   
    
    Write-Host "The install of QUPath has completed."
 }