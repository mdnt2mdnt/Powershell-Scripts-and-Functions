Function Excel2PDF{

Param (
        <#
        .PARAMETER NewName = DIRECTORY that houses the excel files. This also is the output directory of the pdf files.
        #>
                [Parameter(Mandatory=$True,Position=0)]
                [String]$path
      )
			  
			  

$xlFixedFormat = "Microsoft.Office.Interop.Excel.xlFixedFormatType" -as [type] 
$excelFiles = Get-ChildItem -Path $path -include *.xls, *.xlsx -recurse 
$objExcel = New-Object -ComObject excel.application 
$objExcel.visible = $false 
foreach($wb in $excelFiles) 
{ 
 $filepath = Join-Path -Path $path -ChildPath ($wb.BaseName + ".pdf") 
 $workbook = $objExcel.workbooks.open($wb.fullname, 3) 
 $workbook.Saved = $true 
"saving $filepath" 
 $workbook.ExportAsFixedFormat($xlFixedFormat::xlTypePDF, $filepath) 
 $objExcel.Workbooks.close() 
} 
Function Execute-CleanUp 
    {
        $Workbook.Close($false) | Out-Null;
        $x1.Quit() | Out-Null;
        (Get-Process -Name Excel) | Where-Object { $_.MainWindowHandle -eq $X1.HWND } | Stop-Process | Out-Null;
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($X1) | Out-Null;
    }
}