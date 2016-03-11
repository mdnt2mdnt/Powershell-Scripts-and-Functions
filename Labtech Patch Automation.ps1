#Function Declarations
######################

Function Download-Patch
{
    Param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$DownloadURL,
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$SavePath 
    )
	try
	{
		$DownloadObj = new-object System.Net.WebClient;
		$DownloadObj.DownloadFile($DownloadURL, $SavePath);
	}
	catch
	{
            $Output = $_.exception | Format-List -force | Out-String
            log-message "[*ERROR*] : $Output"
	}
}

Function Log-Message
{
	<#
	.SYNOPSIS
		A function to write ouput messages to a logfile.
	
	.DESCRIPTION
		This function is designed to send timestamped messages to a logfile of your choosing.
		Use it to replace something like write-host for a more long term log.
	
	.PARAMETER StrMessage
		The message being written to the log file.
	
	.EXAMPLE
		PS C:\> log-message -StrMessage 'This is the message being written out to the log.' 
	
	.NOTES
		N/A
#>
	
	Param
	(
		[Parameter(Mandatory = $True, Position = 0)]
		[String]$Message
	)

    
	add-content -path $LogFilePath -value ($Message)
    Write-Output $Message
}

function Get-SQLResult
{
    param 
    (
	    [Parameter(Mandatory = $true, Position = 0)]
	    [string]$Query
	)

	$result = .\mysql.exe --host="localhost" --user="root" --password="$rootpass" --database="LabTech" -e "$query" --batch --raw -N;
	return $result;
}

Function Output-Exception
{
    $Output = $_.exception | Format-List -force | Out-String
    $result = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($result)
    $UsefulData = $reader.ReadToEnd();

    Write-log "[*ERROR*] : `n$Output `n$Usefuldata "  
}

#Variable Declarations
###########################
$ErrorActionPreference = 'SilentlyContinue'
[String]$LogFilePath = "$Env:windir\Temp\PSUpdateLog.txt"
[String]$PatchSavePath = "$Env:windir\Temp\CurrentPatch.exe"
[String]$PatchResultsPath = "$Env:windir\Temp\LTPatchLog.txt"
[String]$CustomTableName = "lt_patchinformation"
[String]$SQLDir = "C:\Program Files (x86)\Labtech\Mysql\bin\"
[String]$PatchDownloadLink = "http://labtech-msp.com/release/LabTechPatch_10.5.2.247.exe"

#Get Root Pass
###########################
$rootpass = (get-itemproperty "HKLM:\SOFTWARE\Wow6432Node\LabTech\Setup").rootpassword

If($rootpass -eq $Null -or $rootpass -eq "")
{
    Log-message -Message "Unable to retrieve root password"
    Return "Unable to retrieve root password"
    exit;
}

#Remove Possible Leftovers
###########################
Remove-Item -Path $LogFilePath -Force
Remove-Item -Path $PatchSavePath -Force
Remove-Item -Path $PatchResultsPath -Force

#Kill the LTClient Process
###########################
IF(Get-process -Name 'LTClient')
{
    Stop-Process -Name 'LTClient' -Force
    Log-message -Message "The LTClient process has been killed!"
}

#Download the Patch
###########################
Set-Location "$Env:Windir\"
Download-Patch -DownloadURL $PatchDownloadLink -SavePath $PatchSavePath

If(!Test-Path $PatchSavePath)
{
    Log-Message "Failed to download the patch."
    Return "Failed to download the patch."
    exit;
}

#Run the Patch
###########################
$AllArgs = "/t 360 /p 360"
Start-Process -FilePath "$PatchSavePath" -ArgumentList $AllArgs -Wait -WindowStyle Hidden
$LogFileResults = Get-content -Path $PatchResultsPath

#Check For the new Table
###########################

set-location "$sqldir";

$TableQuery = @"
SELECT * 
FROM information_schema.tables
WHERE table_schema = 'LabTech' 
    AND table_name = `'$CustomTableName`'
LIMIT 1;
"@

$TableCheck = get-sqlresult -query $TableQuery

If($TableCheck -eq $null)
{
    Log-message "Unable to find $CustomTableName in the database."
    [bool]$TableResult = $False
}

Else
{
    Log-message "Found $CustomTableName in the database."
    [bool]$TableResult = $True
}

If($LogFileResults -match "LabTech Server has been successfully updated" -and $TableResult -eq $True)
{
    log-message "Patch was Successful"
    Return "Success"
}

Else
{
    log-message "Patch Failed"
    Return "Failure"
}