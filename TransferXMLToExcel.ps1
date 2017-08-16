<#
    .SYNOPSIS
    This script takes all of the Xml files from the Discovery Tool and adds the data to an excel spreadsheet
    .DESCRIPTION
    The Discovery tool output files in the form of Xml system summaries are transposed into an excel spreadsheet. Each item is read from the file and added 
    separately into each row cell. Depending on whether it is the firstpass a title is added above the data rows to explain the content.
    .EXAMPLE
    Run the script from the Powershell ISE.
  #>
#Get the list of xml files
$FileList = Get-ChildItem \\crf-psrv2\DiscoveryFiles\*.xml
#create the Excel file Object
$excelFile = New-Object -ComObject "Excel.Application"
#Show the new excel file
$excelFile.Visible = $true
#create a link to the workbook but this is not used
$workBook = $excelFile.Workbooks.Add()
#Make the sheet active (There is only one)
$WorkSheet = $excelFile.ActiveSheet
#Set firstPass to true
$firstPass = 1
#Where to start - Cell locations
$startCol = 1
$startRow = 2
#Use $Col to maintain the Column witin the row - reset it back to the start by assigning back to $StarRow at the end of the dataset
$Col = $startCol

#Loop through the files
foreach ($File in $FileList)
{
  #Set the content of the file to a variable for interrogation
  [xml]$xmlContent = Get-Content $File
  #Get the first part of the data as this is individual data not in sub children
  $AppName = $xmlContent.DocumentElement.Application_Name
  $AppVersion = $xmlContent.DocumentElement.Application_Version
  $ComputerName = $xmlContent.DocumentElement.Computer_Name
  $ScanDate = $xmlContent.DocumentElement.Scan_Date
  if ($firstPass)
  {
    # Create the headings as this is the first pass
    $WorkSheet.Cells.Item($startRow-1,$col)="Application Name"
    $WorkSheet.Cells.Item($startRow-1,++$col)="Application Version"
    $WorkSheet.Cells.Item($startRow-1,++$col)="Computer Name"
    $WorkSheet.Cells.Item($startRow-1,++$col)="Scan Date"
  }
  #reset the Column and add the data
  $col=$startCol
  $WorkSheet.Cells.Item($startRow,$col)=$AppName
  $WorkSheet.Cells.Item($startRow,++$col)=$AppVersion
  $WorkSheet.Cells.Item($startRow,++$col)=$ComputerName
  $WorkSheet.Cells.Item($startRow,++$col)=$ScanDate

  #Assign the HardWare_Inventory node to be able to loop through it and grab the data
  [System.Xml.XmlElement]$Hardware = $xmlContent.DocumentElement.Hardware_Inventory
  foreach ($hardwareItem in $Hardware.ChildNodes)
  {
    if($firstPass){
      #Create the heading and add the data
      $workSheet.Cells.Item($startRow-1,++$col)=$hardwareItem.Name
      $workSheet.Cells.Item($startRow,$col)=$hardwareItem.'#text'
    }else{
      # just add the data
      $workSheet.Cells.Item($startRow,++$col)=$hardwareItem.'#text'
    }
  }
  
  #Assign the ME_Firmware_Information node to be able to loop through it and grab the data
  [System.Xml.XmlElement]$Firmware = $xmlContent.DocumentElement.ME_Firmware_Information
  foreach ($firmwareItem in $Firmware.ChildNodes)
  {
    if($firstPass){
      #Create the heading and add the data
      $workSheet.Cells.Item($startRow-1,++$col)=$firmwareItem.Name
      $workSheet.Cells.Item($startRow,$col)=$firmwareItem.'#text'
    }else{
      # just add the data
      $workSheet.Cells.Item($startRow,++$col)=$firmwareItem.'#text'
    }

  }
    #Assign the System_Statusn node to be able to loop through it and grab the data
    [System.Xml.XmlElement]$status = $xmlContent.DocumentElement.System_Status
  foreach ($StatusItem in $status.ChildNodes)
  {
    if($firstPass){
      #Create the heading and add the data
      $workSheet.Cells.Item($startRow-1,++$col)=$statusItem.Name
      $workSheet.Cells.Item($startRow,$col)=$statusItem.'#text'
    }else{
        # just add the data
        $workSheet.Cells.Item($startRow,++$col)=$statusItem.'#text'
      }

  }
  #Reset variables to stop the $firstPass check, add to the rows and reset to the first column
  $firstPass = 0
  $startRow++
  $col = $startCol
}
