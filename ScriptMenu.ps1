function Check-WhatClicked( $selection ) {
  Add-Type -AssemblyName PresentationCore
  Add-Type -AssemblyName PresentationFramework
  if($selection -ne -1) {
    $fileContent = Get-Content -Path $selection.FullName
    $startCapture = $false
    foreach($content in $fileContent){
        if(Select-String -InputObject $content -Pattern "<#") {
          $startCapture = $true
        }
        if($startCapture -eq $true){
          $Desc += $Content+"`n"
        }
        if (Select-String -InputObject $content -Pattern "#>"){
          $startCapture = $false
        }      
    }
    $ScriptDescription.Content = $Desc
    
  }
}

Add-Type -AssemblyName PresentationCore
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$xamlCode = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Script Selection" Height="470" Width="950">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="200*"/>
            <ColumnDefinition Width="750*"/>
        </Grid.ColumnDefinitions>
        <Label Name="label" Content="Script Name" HorizontalAlignment="Left" Height="25" Margin="10,10,0,0" VerticalAlignment="Top" Width="159"/>
        <Label Name="label1" Content="Script Description" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.06,0.13" Width="325" Grid.Column="1" Height="26"/>
        <Label Name="ScriptDescription" Margin="10,41,33,108" Grid.Column="1"/>
        <Button Name="RunButton" Content="Open Script" Margin="10,326,33,48" Grid.Column="1" MinHeight="44" MaxHeight="44"/>
        <ListBox Name="ScriptList" HorizontalAlignment="Left" Margin="20,41,0,49" Width="149"/>

    </Grid>
</Window>
'@
$selected = $null
$reader = (New-Object System.Xml.XmlNodeReader $xamlCode)
$GUI = [Windows.Markup.XamlReader]::Load($reader)
$xamlCode.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $GUI.FindName($_.Name) }
#display the structure and check the xml file for what is checked and what isn't.
$Files = Get-ChildItem -Path "C:\PowerScripts"
$ScriptList.Items.Clear()
$ScriptList.ItemsSource   = $Files
$index                    = $scriptList.SelectedIndex
$item                     = $ScriptList.SelectedItem
$value                    = $ScriptList.SelectedValue
#Make the mouse act like something is happening
$RunButton.Add_MouseEnter{    
  $Gui.Cursor = [Windows.Input.Cursors]::Hand
}
$RunButton.IsEnabled = $false

#Switch back to regular mouse
$RunButton.Add_MouseLeave({
    $Gui.Cursor = [Windows.Input.Cursors]::Arrow
})
$RunButton.add_Click{
    if ($RunButton.Tag){
      Invoke-Command $RunButton.Tag
      #[System.Windows.MessageBox]::Show($ScriptList.SelectedItem)
      #Run the script
      #$runCommand = $ScriptList.SelectedItem
      #powershell -file $runCommand.Fullname
    }
      
}
$ScriptList.Add_SelectionChanged{
    Check-WhatClicked $ScriptList.SelectedItem
    #now lets power the run button to run the script 
    $RunButton.IsEnabled = $true 
    $selected = $ScriptList.SelectedItem   
    $RunButton.Tag = {$psISE.CurrentPowerShellTab.Files.Add("c:\PowerScripts\"+$ScriptList.SelectedItem)}
}
$GUI.ShowDialog() | Out-Null
$GUI.Close()

function Set_Button {
  #Run the script
  $runCommand = $ScriptList.SelectedItem
  powershell -file $runCommand.Fullname
}