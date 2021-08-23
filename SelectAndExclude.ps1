<#
    .SYNOPSIS 
    This script allows the user to select from a drop down to add the exclusions path of the application and add it to the ExcludeProfileDirs key

    .DESCRIPTION
    This script allows the user to change the ExcludeProfileDirs key allowing manipulation
    of this to add or delete folders to remove these from the folders saved to the users profile

    Selecting from a dropdown adds folders to this path of exclusions reducing the Users Profile space. Use this to 
    stop the window reporting the users profile is too big.

    -- Ian Bettison March 2018	

    .INPUTS
    Select the paths to add

    .OUTPUTS
    Lists the Values attached to the Registry Key

    .EXAMPLE

    ExcludeFromProfile.ps1

    Provides a dropdown containing the software items to exclude and allows the 
    user to select multiple apps from the list.

#>

# set the registry key
$registryKey = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"

# get the current ExcludeProfileDirs
$path = (Get-ItemProperty -Path $registryKey -Name ExcludeProfileDirs).ExcludeProfileDirs

#Set up the array list to choose from

$apps = @("Adobe","Apple","ArcGIS","AutoDesk","BlueJeans","Cookies","DocumentBuildingBlocks"
  ,"Dropbox","Excel","filr","FirefoxProfiles","Google Drive","Java","Macromedia","Microsoft Excel","Teams","Microsoft templates"
  ,"Microsoft","Microsoft Word","Mozillla","Office2013LiveContent","PrivacIE","Purple","PyCharmEdu+Python35","Roaming","SAP","Skype","Spotify","Sun"
,"Thunderbird","Tidy","VideoScribeDesktop","VisualStudio","Windows","Xtranormal","zotero","PhpStorm", "GitHubDesktop")
$OutData = @()
foreach ($item in $apps) {
  $GridObj = New-Object PSObject
  $GridObj | Add-Member -Name "Name" -MemberType NoteProperty -Value $item
  $OutData += $GridObj
}

# setup a grid view to select the Group Single selection
$SelectToAdd = $OutData |	Out-GridView -Title 'Select one or more Apps to exclude from the profile' -OutputMode Multiple
$addStr=""
foreach ($selections in $SelectToAdd) {
  Switch ($selections.Name) 
  {
    "Adobe" {$addStr += ";AppData\Roaming\Adobe"}
    "Apple" {$addStr += ";AppData\Roaming\Apple Computer"}
    "ArcGIS" {$addStr += ";AppData\Roaming\ESRI\localcaches"}
    "AutoDesk" {$addStr += ";AppData\Roaming\Autodesk"}
    "BlueJeans" {$addStr += ";AppData\Roaming\Blue Jeans"}
    "Cookies"  {$addStr += ";AppData\Roaming\Microsoft\Windows\Cookies;AppData\Roaming\Microsoft\Windows\Cookies\Low"}
    "DocumentBuildingBlocks" {$addStr += ";AppData\Roaming\Microsoft\Document Building Blocks"}
    "Dropbox" {$addStr += ";Dropbox;AppData\Roaming\Dropbox"}
    "Excel" {$addStr += ";AppData\Roaming\Microsoft\Excel"}
    "filr" {$addStr += ";filr"}
    "FirefoxProfiles" {$addStr += ";AppData\Roaming\Mozilla"}
    "Google Drive" {$addStr += ";Google Drive"}
    "Java" {$addStr += ";AppData\Roaming\Sun"}
    "Macromedia" {$addStr += ";AppData\Roaming\Macromedia\Flash Player\www.macromedia.com\bin\connectaddin"}
    "Teams" {$addStr += ";AppData\Roaming\Microsoft\Teams"}
    "Microsoft templates" {$addStr += ";AppData\Roaming\Microsoft\Templates"}
    "Microsoft Word" {$addStr += ";AppData\Roaming\Microsoft\Word"}
    "Microsoft" {$addStr += ";AppData\Roaming\Microsoft"}
    "Mozilla" {$addStr += ";AppData\Roaming\Mozilla"}
    "Office2013LiveContent" {$addStr += ";AppData\Roaming\Microsoft\Templates\LiveContent\15"}
    "PrivacIE" {$addStr += ";AppData\Roaming\Microsoft\PrivacIE"}
    "Purple" {$addStr += ";AppData\Roaming\.purple"}
    "PyCharmEdu+Python35" {$addStr += ";.PyCharmEdu3.5;.PyCharmCE2017.1;Appdata\Roaming\Python"}
    "Roaming" {$addStr += ";AppData\Roaming"}
    "SAP" {$addStr += ";AppData\Roaming\SAP"}
    "Skype" {$addStr += ";Tracing;AppData\Roaming\Skype"}
    "Spotify" {$addStr += ";AppData\Roaming\Spotify"}
    "Sun" {$addStr += ";AppData\Roaming\Sun"}
    "Thunderbird" {$addStr += ";AppData\Roaming\Thunderbird"}
    "Tidy" {$addStr += ";Local Settings\Application Data\Microsoft\Outlook"}
    "VideoScribeDesktop" {$addStr += ";AppData\Roaming\VideoScribeDesktop"}
    "VisualStudio" {$addStr += ";AppData\Roaming\Microsoft\VisualStudio"}
    "Windows" {$addStr += ";AppData\Roaming\Microsoft"}
    "Xtranormal" {$addStr += ";AppData\Roaming\Xtranormal"}
    "zotero" {$addStr += ";AppData\Roaming\Zotero"}
    "PhpStorm" {$addStr += ";AppData\Roaming\JetBrains"}
    "GitHubDesktop" {$addStr += ";AppData\Roaming\GitHub Desktop"}
  }
}

# Initiate Visual Basic
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

$path = $path + $addStr

#show the input box with the ExcludeProfileDirs path, ready for editing
$enteredPath = [Microsoft.VisualBasic.Interaction]::InputBox("Edit the Excluded path", "Excluded Path", "$path")

if($enteredPath -ne "") { #if clicked OK
    #set the key value to the desired value
    Set-ItemProperty -Path $registryKey -Name ExcludeProfileDirs -value $enteredPath
}
else
{
    Write-Host "Cancelled - No changes have been saved"
}


#show the edited value.
Get-ItemProperty -Path $registryKey | Format-list

