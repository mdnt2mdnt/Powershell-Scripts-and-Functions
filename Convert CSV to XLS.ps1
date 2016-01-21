
Function Convert-CSV {

Param (
        <#
        .PARAMETER NewName = The path of the CSV to convert.
        #>
                [Parameter(Mandatory=$True,Position=0)]
                [String]$CSVPath,
        <# 
        .PARAMETER CurrentName = The path to the XLS file the CSV gets converted to.
        #>
                [Parameter(Mandatory=$True,Position=1)]
                [String]$XLSPath
                
      )

$xl = new-object -comobject excel.application
$xl.visible = $true
$Workbook = $xl.workbooks.open($CSVPath)
$Worksheets = $Workbooks.worksheets
$Workbook.SaveAs($XLSPath,1)
$Workbook.Saved = $True
Function Execute-CleanUp 
    {
        $Workbook.Close($false) | Out-Null;
        $x1.Quit() | Out-Null;
        (Get-Process -Name Excel) | Where-Object { $_.MainWindowHandle -eq $X1.HWND } | Stop-Process | Out-Null;
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($X1) | Out-Null;
    }
    }