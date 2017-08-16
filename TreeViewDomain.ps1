﻿<#
.Synopsis
   Provides a fast treeview selection of domain OUs, and optionally containers
.DESCRIPTION
   This function provides fast navigation and selection of one or more Active Directory Organizational Units.
You can specify the form title, instructions and button text.  It can navigate all domains in the forest,
or be limited to a single domain.  You can choose to display textboxes, and see containers in the treeview.
This does not require the PowerShell AD module.

.PARAMETER TitleText
Specify the title text
.PARAMETER BtnText
Specify the button text
.PARAMETER InstructionText
Specify the instructions text
.PARAMETER ShowCheckBoxes
Show CheckBoxes, which permits multiple selections
.PARAMETER InitialDomain
Specify the intial domain
.PARAMETER SingleDomain
Do not allow navigation to other domains
.PARAMETER ShowContainers
Show AD containers with OUs

.EXAMPLE
$ADObject = Select-ADOU
Get a treeview of current domain.  
Selected item returns object with domain, OUName, and OUDN
.EXAMPLE
$ADObject = Select-ADOU -ShowCheckBoxes -ShowContainers
.EXAMPLE
#Load script suppressing load messages.  Run function, limiting to Contosco.com, showing containers
. $env:userprofile\documents\PSScripts\Select-ADOU.ps1 | Out-Null
Select-ADOU -SingleDomain -InitialDomain Contoso.com -showContainers|
foreach {$_}
.EXAMPLE
Select-ADOU -showContainers -ShowCheckboxes
Get a treeview of current domain OUs and Containers, with option of multiple choice selection
Selected item returns object with domain, OUName, and OUDN
.NOTES
Alan dot Kaplan at VA dot Gov

Original form code generated by SAPIEN Technologies PrimalForms (Community Edition) v1.0.10.0
Function Get-CheckedNodes from
https://www.sapien.com/blog/2011/11/23/primalforms-2011-spotlight-on-the-treeview-control-part-2/

The dot source reminder code may be deleted.

Revision History
04-28-2016  v. 1.0  Select-ADOU.PS1
05-04-2016  v. 1.1  added Instruction Text box and Title as parameters
00-00-0000  v. 1.2  added button text (no revision date)
04-05-2017  v. 2.0  Added CheckBoxes, SingleDomain, Initial domain, Containers, renamed function
04-12-2017  v. 2.01 fixed help issues, button text for check box, back to original function name, 
            renamed some parameters, added new dot source reminder
#>
Function Select-ADOU {
    [CmdletBinding()]
    Param
    (
        # Title text
        [Parameter(Position=0)]
        $Title,

        # Instruction text is below title, and above domain box
        [Parameter(Position=1)]
        [string]$InstructionText,

        # Select Button Text
        [Parameter(Position=3)]
        [string]$BtnText,

        # Show Containers.  Default is only OUs
        [Parameter(Mandatory=$False)]
        [Switch]$ShowContainers =  $False,

        # Force Single Domain.  No navigation within forest
        [Parameter(Mandatory=$False)]
        [Switch]$SingleDomain =  $False,

        #Set the initial domain.  This must be a FQDN, example Contoso.com
        [Parameter(Mandatory=$False)]
        [string]$InitialDomain,

        #Use Checkboxes
        [Parameter(Mandatory=$False)]
        [switch]$ShowCheckBoxes=$False 

    )
  ### Helper functions ###
    Function Show-NoCheck{
        #Show the Form without CheckBoxes
        $dialogResult = $Form.ShowDialog()
        if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK)
         {
            $RetVal = [PSCustomObject]@{
            Domain = [string]$DomainBox.SelectedItem
            OUName= [string]$treeViewNav.SelectedNode.Text
            OUDN = [string]$treeViewNav.SelectedNode.Tag
            }
            $RetVal
            $Form.Close()
         }
    }

    #Sapien.com, see notes
    Function Get-CheckedNodes 
    {
        param(
        [ValidateNotNull()]
        [System.Windows.Forms.TreeNodeCollection] $NodeCollection,
        [ValidateNotNull()]
        [System.Collections.ArrayList]$CheckedNodes)
    
        foreach($Node in $NodeCollection)
        {
            if($Node.Checked)
            {
                [void]$CheckedNodes.Add($Node)
            }
            Get-CheckedNodes $Node.Nodes $CheckedNodes
        }
    }

    Function Show-CheckBoxes{
    #Show the Form
        $dialogResult = $Form.ShowDialog()
        if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK){

        $CheckedNodes = New-Object System.Collections.ArrayList
        Get-CheckedNodes $treeViewNav.Nodes $CheckedNodes
    
        $RetVal =  foreach($node in $CheckedNodes) {    
               [PSCustomObject]@{
                Domain = [string]$DomainBox.SelectedItem
                OUName= $node.Text
                OUDN = [string]$Node.Tag
                }
            }
            $RetVal
            $Form.Close()
      }
    }
    
    Function Check-Domain ($dom){ 
        Try{
            [adsi]::Exists("LDAP://$dom")
        }Catch{
            $False
        }
    }
    ### End helper functions###

    #Default display text if not set by argument

    if ($TitleText.length -eq 0) {
        if ($ShowCheckBoxes){
            $TitleText  = "Select OU(s)"
        }ELSE{
            $TitleText  = "Select an OU"
        }
    }

    if ($BtnText.length -eq 0) {
        if ($ShowCheckBoxes){
            $BtnText  =  "Accept Selected OU(s)"
        }ELSE{
            $BtnText  =  "Accept Selected OU"
        }
    }

    if ($InstructionText.length -eq 0) {
        if ($SingleDomain){
            $InstructionText  = "Double click on a node to expand."
        }ELSE{
            $InstructionText  =  "Click on domain box after a domain change to show tree.  Double click on a node to expand."
        }
    }

    if ($ShowContainers -eq $True){
        $LDAPFilter = '(|(objectClass=container)(ObjectCategory=OrganizationalUnit))'
    }ELSE{
        $LDAPFilter = '(ObjectCategory=OrganizationalUnit)'    
    }

    if ($InitialDomain.Length -eq 0){
        $InitialDomain  =  ([System.DirectoryServices.ActiveDirectory.domain]::GetCurrentDomain()).Name
    }

    If ($SingleDomain){
        $DomainList = $InitialDomain
    }ELSE{
        $Forest = ([System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest())
        $DomainList = ($Forest.Domains).name | sort   -CaseSensitive
    }

    $startNum= $DomainList.IndexOf($InitialDomain)

    # Import the Assemblies
    Add-Type -assemblyname System.Windows.Forms
    Add-Type -assemblyname System.Drawing
    Add-Type -assemblyname Microsoft.VisualBasic

    # Form Objects
    $Form = New-Object System.Windows.Forms.Form
    $DomainBox = New-Object System.Windows.Forms.ListBox
    $DomainLbl = New-Object System.Windows.Forms.Label
    $AcceptBtn = New-Object System.Windows.Forms.Button
    $treeViewNav = New-Object System.Windows.Forms.TreeView
    $InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
    $StatusBar = New-Object System.Windows.Forms.StatusBar
    $InstructionsLabel = New-Object System.Windows.Forms.Label

#Event Script Blocks
    $DomainBox_SelectedIndexChanged={
            $CurrentDomain= $DomainBox.SelectedItem

            #check communication with selected domain
            if ((Check-Domain $CurrentDomain) -eq $False){
                Write-Warning "$CurrentDomain does not exist or cannot be contacted."
                Exit
            }

            if ($Script:LoadCount -gt 0){
                #initial domain is current
                $domain = [adsi]"LDAP://$CurrentDomain"
            }ELSE{
                $domain=[adsi]''
            }
            #Clear old results
            $TreeviewNav.Nodes.Clear()
		    $newnode=New-Object System.Windows.Forms.TreeNode 
	        $newnode.Name=$domain.Name
	 	    $newnode.Text=$domain.distinguishedName
		    $newnode.Tag=$domain.distinguishedName
		    $treeviewNav.Nodes.Add($newnode)
            $Script:LoadCount=$LoadCount+1
            #Expand the initial tree
            Invoke-command $treeviewNav_DoubleClick
    }
	
	$treeviewNav_DoubleClick={
        [System.Windows.Forms.Application]::UseWaitCursor = $true
        $StatusBar.Text = "Getting list, please wait..."
        if ($treeviewNav.SelectedNode -eq $null){
            #For first listing in treeview, select root
            $node =$treeviewNav.Nodes[0]
        }Else{
            $node=$treeviewNav.SelectedNode
        }
		    if($node.Nodes.Count -eq 0){
			    $SearchRoot="LDAP://$($node.Tag)"
                $ADSearcher = [adsisearcher] ''
                $ADSearcher.SearchRoot = $SearchRoot
                $ADSearcher.PageSize = 500
                $ADSearcher.SearchScope = "OneLevel"
                $ADSearcher.CacheResults = $false
                $ADSearcher.Filter = $LDAPFilter
                $List = ($ADSearcher.FindAll()).getEnumerator().properties
                foreach ($OU in $List){
                    $OUName = $OU.Item("Name")
                    $OUDN = $OU.Item("DistinguishedName")
        	        $newnode=New-Object System.Windows.Forms.TreeNode 
			        $newnode.Name=$OUName
			        $newnode.Text=$OUName
			        $newnode.Tag=$OUDN
			        $node.Nodes.Add($newnode)			
                    }
                }
			        $node.Expand()
                    [System.Windows.Forms.Application]::UseWaitCursor = $False
                    $statusbar.text = ""
	    }

    $OnLoadForm_StateCorrection=
    {#Correct the initial state of the form to prevent the .Net maximized form issue
	    $Form.WindowState = $InitialFormWindowState
    }

    $form.ClientSize =  New-Object System.Drawing.Size(445,595)
    $Form.Name = "Form"
    $Form.Text = $TitleText

    $InstructionsLabel.Location =  New-Object System.Drawing.Point(10,15)
    $InstructionsLabel.Name = "InstructionsLabel"
    $InstructionsLabel.Size = New-Object System.Drawing.Size(420,35)
    $InstructionsLabel.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",8.25,2,3,0)
    $InstructionsLabel.Text = $InstructionText
    $Form.Controls.Add($InstructionsLabel)

    $DomainBox.Name = "DomainBox"
    $DomainBox.FormattingEnabled = $True
    $DomainBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9.75,0,3,0)
    $DomainBox.Location = New-Object System.Drawing.Point(185,50)
    $DomainBox.Size = New-Object System.Drawing.Size(160,30)
    $DomainBox.add_SelectedIndexChanged($DomainBox_SelectedIndexChanged)


    foreach ($Domain in $domainlist){
        [void] $DomainBox.Items.Add($domain)
    }
    $DomainBox.setSelected($startNum,$true)
    $Form.Controls.Add($DomainBox)

    $DomainLbl.Name = "DomainLbl"
    $DomainLbl.Location = New-Object System.Drawing.Point(20,50)
    $DomainLbl.Size = New-Object System.Drawing.Size(160,25)
    $DomainLbl.Text = "Selected Domain"
    $DomainLbl.TextAlign = "Middleright"
    $Form.Controls.Add($DomainLbl)

    $AcceptBtn.Name = "AcceptBtn"
    $AcceptBtn.Location = New-Object System.Drawing.Point(125,535)
    $AcceptBtn.Size =New-Object System.Drawing.Size(170,25)
    $AcceptBtn.Text = $BtnText
    $AcceptBtn.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $Form.Controls.Add($AcceptBtn)
    $form.AcceptButton = $AcceptBtn

    $treeViewNav.Name = "treeViewNav"
    $treeViewNav.CheckBoxes = $ShowCheckBoxes
    $treeViewNav.Location =New-Object System.Drawing.Point(45,80)
    $treeViewNav.Size =New-Object System.Drawing.Size(325,450)
    $treeViewNav.add_DoubleClick($treeViewNav_DoubleClick)
    $treeViewNav.add_AfterSelect($treeViewNav_AfterSelect)
    $Form.Controls.Add($treeViewNav)
    $form.StartPosition = "CenterParent"

    $form.Controls.Add($StatusBar)

    #Save the initial state of the form
    $InitialFormWindowState = $Form.WindowState
    #Init the OnLoad event to correct the initial state of the form
    $Form.add_Load($OnLoadForm_StateCorrection)

    if ($ShowCheckBoxes) {Show-CheckBoxes }ELSE{ Show-NoCheck }
} #End Function


#region Dot Source Reminder
$ScriptPath= $MyInvocation.MyCommand.Definition.ToString()
## Presume function name is same as script name, or hard code name of function as $fn
$fn =  $MyInvocation.MyCommand.Name.Replace(".ps1","")
$DSRanVarName = "$fn`_Ran"
$DSContinue = Try{Get-Variable $DSRanVarName -ValueOnly -ErrorAction Stop}Catch{$false}
if ($DSContinue -eq $false) {$ScriptText = Get-Content $ScriptPath
$MoreText = [regex]::Split($ScriptText,'Source Reminder ###')[2]
if ($MoreText.Length -ge $fn.Length){break}
$_z = [bool](Get-Command -Name $fn -ErrorAction SilentlyContinue)
Set-Variable -Name $DSRanVarName -Value $_z
if (($host.Name).Contains("ISE")){"`nYou have loaded the advanced function `"$fn`""
"`tUse `"Get-Help`" for information and usage, Ex:`n`tPS C:\> Get-Help $fn -detailed`n"
}ELSE{if ($MyInvocation.InvocationName -ne '.') {
"`nThis advanced function must be dot sourced to run.`n"
"Load example:`nPS C:\> . `"$ScriptPath`"`n
After loading, use `"Get-Help`" for information and usage, Ex:
PS C:\> Get-Help $fn -detailed`n"
Pause}}}
#endregion Dot Source Reminder ###