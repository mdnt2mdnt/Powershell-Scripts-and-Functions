$FilePath = "C:\Users\pmarshall\Dropbox\ford.xlsx"
$SheetName = "Sheet1"
$objExcel = New-Object -ComObject Excel.Application
$WorkBook = $objExcel.Workbooks.Open($FilePath)
$WorkSheet = $WorkBook.sheets.item($sheetname)
$intRowMax =  ($worksheet.UsedRange.Rows).count
[Int]$Client = '1'
[Int]$Dealer = '3'
[Int]$Address = '4'
[Int]$City = '5'
[Int]$ZipCode = '6'
[Int]$Phone = '7'





for([INT]$intRow = 2 ; $intRow -le $intRowMax ; $intRow++)
{
    IF ($worksheet.cells.item($intRow,$Client).value2 -eq 'Alberta'){$ClientID = 2}
    IF ($worksheet.cells.item($intRow,$Client).value2 -eq 'British Columbia'){$ClientID = 3}
    IF ($worksheet.cells.item($intRow,$Client).value2 -eq 'Manitoba'){$ClientID = 4}
    IF ($worksheet.cells.item($intRow,$Client).value2 -eq 'New Brunswick'){$ClientID = 5}
    IF ($worksheet.cells.item($intRow,$Client).value2 -eq 'Newfoundland'){$ClientID = 6}
    IF ($worksheet.cells.item($intRow,$Client).value2 -eq 'Northwest Territories'){$ClientID = 7}
    IF ($worksheet.cells.item($intRow,$Client).value2 -eq 'Nova Scotia'){$ClientID = 8}
    IF ($worksheet.cells.item($intRow,$Client).value2 -eq 'Ontario'){$ClientID = 9}
    IF ($worksheet.cells.item($intRow,$Client).value2 -eq 'Prince Edward Island'){$ClientID = 10}
    IF ($worksheet.cells.item($intRow,$Client).value2 -eq 'Province'){$ClientID = 11}
    IF ($worksheet.cells.item($intRow,$Client).value2 -eq 'Quebec'){$ClientID = 12}
    IF ($worksheet.cells.item($intRow,$Client).value2 -eq 'Saskatchewan'){$ClientID = 13}
    IF ($worksheet.cells.item($intRow,$Client).value2 -eq 'Yukon'){$ClientID = 14}


        $TempDealer = $worksheet.cells.item($intRow,$Dealer).value2
        $TempAddress = $worksheet.cells.item($intRow,$Address).value2
        $TempCity = $worksheet.cells.item($intRow,$City).value2,
        $TempZipCodes = $worksheet.cells.item($intRow,$ZipCode).value2
        $TempPhone = $worksheet.cells.item($intRow,$Phone).value2

        $Insert =  "('$ClientID','$TempDealer','$TempAddress','$TempCity','$TempZipcode','$TempPhone'),"
    
        Add-Content c:\windows\Temp\test.txt "`n$Insert"
        Write-Host $intRow

}