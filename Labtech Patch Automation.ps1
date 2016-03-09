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
            Write-log "[*ERROR*] : $Output"
	}
}

Function Write-Log
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
		PS C:\> Write-Log -StrMessage 'This is the message being written out to the log.' 
	
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

function Get-LabTechConnection
{
	param 
    (
	    [Parameter(Mandatory = $true, Position = 0)]
	    [string]$Phrase
	)
	
	$connectionObject = New-Object PSObject -Property @{
		host = "localhost"
		User = "root"
		pass = ""
		ltversion = 0
	}
	
	$Version = (Get-ItemProperty "HKLM:\Software\Wow6432Node\LabTech\Agent" -Name Version -ea SilentlyContinue).Version;
	
	#Looks like in 10.5 they decided to remove the version key ...
	$LTAgentVersion = Get-ItemProperty "C:\Program Files\LabTech\ltagent.exe"
	
	if ($LTAgentVersion)
	{
		$Version = $LTAgentVersion.VersionInfo.FileVersion.Substring(0, 7);
	}
	
	if (-not $Version)
	{
		#Try 10.5+ path
		$Version = (Get-ItemProperty "HKLM:\Software\LabTech\Agent" -Name Version -ea SilentlyContinue).Version;
		
		if (-not $Version)
		{
			write-error "Failed to retrieve version."
			return $null;
		}
	}
	
	$LTVersion = [double]$Version
	$connectionObject.ltversion = $LTVersion;
	
	# Check version
	if ($LTVersion -lt [double]105.210)
	{
		Log-Message "Version is pre 10.5";
		$DatabaseHost = (Get-ItemProperty "HKLM:\Software\Wow6432Node\LabTech\Agent" -Name SQLServer).SQLServer;
		
		if ($DatabaseHost)
		{
			$connectionObject.host = $DatabaseHost;
		}
		
		$connectionObject.pass = (Get-ItemProperty "HKLM:\Software\Wow6432Node\LabTech\Setup" -Name RootPassword -ea SilentlyContinue).RootPassword;
		return $connectionObject;
	}
	else
	{
		Log-Message "Version is 105 or greater";
		
		$DatabaseUser = (Get-ItemProperty "HKLM:\Software\LabTech\Agent" -Name User -ea SilentlyContinue).User;
		$DatabaseHost = (Get-ItemProperty "HKLM:\Software\LabTech\Agent" -Name SQLServer -ea SilentlyContinue).SQLServer;
		
		if ($DatabaseUser)
		{
			$connectionObject.user = $DatabaseUser;
		}
		
		if ($DatabaseHost)
		{
			$connectionObject.host = $DatabaseHost;
		}
	}
	
	#############################################
	###  Only for 10.5                         ##
	#############################################
	
	# Start with 64-bit location
	
	$CommonPath = "$env:ProgramFiles\LabTech\LabTechCommon.dll";
	
	if (-NOT (Test-Path $CommonPath))
	{
		# try 32-bit location next.
		$CommonPath = "${env:ProgramFiles(x86)}\LabTech Client\LabTechCommon.dll";
		$exists = Test-Path $CommonPath;
	}
	
	# Check to see if we found DLL
	if ($exists -eq $false)
	{
		write-error "Failed to find LabTechCommon library."
		return $null;
	}
	
	try
	{
		[Reflection.Assembly]::LoadFile($CommonPath) | out-null
		Log-Message "Successfully loaded commonpath";
	}
	catch
	{
		# probably can't find file
		Write-Error -Message "Failed to load LabTechCommon" -Exception System.IO.FileNotFoundException;
		return $null;
	}
	
	# Get txt to decrypt
	if (Test-Path "HKLM:\Software\LabTech\Agent")
	{
		$txtToDecrypt = Get-ItemProperty HKLM:\Software\LabTech\Agent -Name MysqlPass | select -expand MySQLPass;
	}
	else
	{
		$txtToDecrypt = Get-ItemProperty HKLM:\Software\WOW6432Node\LabTech\Agent -Name MysqlPass | select -expand MySQLPass;
	}
	
	Log-Message "Text to decrypt: $txtToDecrypt"
	
	if (-not $txtToDecrypt)
	{
		Write-Error "Failed to locate mysqlPass key"
		return $null;
	}
	
	[array]$byteArray = @([byte]240, [byte]3, [byte]45, [byte]29, [byte]0, [byte]76, [byte]173, [byte]59);
	
	$lbtVector = [byte[]]$byteArray;
	$cryptoSvcProvider = New-Object System.Security.Cryptography.TripleDESCryptoServiceProvider;
	
	[byte[]]$InputBuffer = [System.Convert]::FromBase64String($txtToDecrypt);
	
	if ($InputBuffer.Length -lt 1)
	{
		write-error "Empty buffer. Cannot decrypt";
		return $null;
	}
	
	$hash = new-object LabTechCommon.clsLabTechHash;
	$hash.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($Phrase));
	$cryptoSvcProvider.Key = $hash.GetDigestBytes();
	$cryptoSvcProvider.IV = $lbtVector;
	
	$access = [System.Text.Encoding]::ASCII.GetString($cryptoSvcProvider.CreateDecryptor().TransformFinalBlock($InputBuffer, 0, $InputBuffer.Length));
	
	if ($access)
	{
		$connectionObject.pass = $access;
		return $connectionObject;
	}
	else
	{
		return $null;
	}
	
}

function Get-SQLResult
{
    param 
    (
	    [Parameter(Mandatory = $true, Position = 0)]
	    [string]$Query
	)

	$result = .\mysql.exe --host="$DBHost" --user="$DBUser" --password="$DBPass" --database="LabTech" -e "$query" --batch --raw -N;
	return $result;
}

Function CheckRegKeyExists ($Dir,$KeyName) 
{

	try
    	{
        $CheckIfExists = Get-ItemProperty $Dir $KeyName -ErrorAction SilentlyContinue
        if ((!$CheckIfExists) -or ($CheckIfExists.Length -eq 0))
        {
            return $false
        }
        else
        {
            return $true
        }
    }
    catch
    {
    return $false
    }
	
}

function Download-MySQLExe
{
	
	try
	{
		$DownloadObj = new-object System.Net.WebClient;
		$DownloadObj.DownloadFile($DownloadURL, $MySQLZipPath);
	}
	catch
	{
		$Caughtexception = $_.Exception.Message;
	}
	
	if (!(Test-Path $MySQLZipPath))
	{
		Log-Message "[DOWNLOAD FAILED] :: Failed to download MySQL ZIP archive! If any exceptions, here they are: $Caughtexception";
		return $false;
	}
	
	# ok, the file exists. Let's ensure that it matches up with our hash.
	# mysql.zip hash
	$ExpectedHash = "40-FD-7B-E8-19-22-99-31-C6-64-D3-0C-46-C1-BF-F2";
	$fileMd5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
	$zipHash = [System.BitConverter]::ToString($fileMd5.ComputeHash([System.IO.File]::ReadAllBytes($MySQLZipPath)))
	
	if ($zipHash -ne $ExpectedHash)
	{
		# Integrity issue. Could be content filtering...
		Log-Message "[HASH MISMATCH] :: The mysql.zip file's md5 hash does not match the original."
		return $false;
	}
	else
	{
		return $true;
	}
	
	
}

Function Zip-Actions
{
       <#
       .SYNOPSIS
              A function to zip or unzip files.
       
       .DESCRIPTION
              This function has 3 possible uses.
              1) Zip a folder or files and save the zip to specified location.
              2) Unzip a zip file to a specified folder.
              3) Unzip a zip file and delete the original zip when complete.       
      
 
       .PARAMETER ZipPath
              The full path of the file to unzip or the full path of the zip file to be created.
       
       .PARAMETER FolderPath
              The path to the files to zip or the path to the directory to unzip the files to.
       
       .PARAMETER Unzip
              If $true the function will perform an unzip instead of a zip
       
       .PARAMETER DeleteZip
              If set to $True the zip file will be removed at then end of the unzip operation.
       
       .EXAMPLE
              PS C:\> Zip-Actions -ZipPath 'C:\Windows\Temp\ziptest.zip' -FolderPath 
              PS C:\> Zip-Actions -ZipPath 'C:\Windows\Temp\ziptest.zip' -FolderPath 'C:\Windows\Temp\ZipTest' -Unzip $true
              PS C:\> Zip-Actions -ZipPath 'C:\Windows\Temp\ziptest.zip' -FolderPath 'C:\Windows\Temp\ZipTest' -Unzip $true -DeleteZip $True
       
       .NOTES
              Additional information about the function.
#>
       
       [CmdletBinding(DefaultParameterSetName = 'Zip')]
       param
       (
              [Parameter(ParameterSetName = 'Unzip')]
              [Parameter(ParameterSetName = 'Zip',
                              Mandatory = $true,
                              Position = 0)]
              [ValidateNotNull()]
              [string]$ZipPath,
              [Parameter(ParameterSetName = 'Unzip')]
              [Parameter(ParameterSetName = 'Zip',
                              Mandatory = $true,
                              Position = 1)]
              [ValidateNotNull()]
              [string]$FolderPath,
              [Parameter(ParameterSetName = 'Unzip',
                              Mandatory = $false,
                              Position = 2)]
              [ValidateNotNull()]
              [bool]$Unzip,
              [Parameter(ParameterSetName = 'Unzip',
                              Mandatory = $false,
                              Position = 3)]
              [ValidateNotNull()]
              [bool]$DeleteZip
       )
       
       Log-Message "Entering Zip-Actions Function."
       
       switch ($PsCmdlet.ParameterSetName)
       {
              'Zip' {
                     
                     If ([int]$psversiontable.psversion.Major -lt 3)
                     {
                           Log-Message "Step 1"
                           New-Item $ZipPath -ItemType file
                           $shellApplication = new-object -com shell.application
                           $zipPackage = $shellApplication.NameSpace($ZipPath)
                           $files = Get-ChildItem -Path $FolderPath -Recurse
                           Log-Message "Step 2"
                           foreach ($file in $files)
                           {
                                  $zipPackage.CopyHere($file.FullName)
                                  Start-sleep -milliseconds 500
                           }
                           
                           Log-Message "Exiting Zip-Actions Function."
                           break           
                     }
                     
                     Else
                     {
                           Log-Message "Step 3"
                           Add-Type -assembly "system.io.compression.filesystem"
                           $Compression = [System.IO.Compression.CompressionLevel]::Optimal
                           [io.compression.zipfile]::CreateFromDirectory($FolderPath, $ZipPath, $Compression, $True)
                           Log-Message "Exiting Zip-Actions Function."
                           break
                     }
              }
              
              'Unzip' {

			    $shellApplication = new-object -com shell.application
			    $zipPackage = $shellApplication.NameSpace($ZipPath)
			    $destinationFolder = $shellApplication.NameSpace($FolderPath)
			    $destinationFolder.CopyHere($zipPackage.Items(), 20)
                Log-Message "Exiting Unzip Section"
				
                        }
       }
       
}

#Variable Declarations
######################
$ErrorActionPreference = 'SilentlyContinue'
[STRING]$KeyPhrase = 'Thank you for using LabTech.'
[String]$LogFilePath = "$Env:windir\Temp\PSUpdateLog.txt"
[String]$PatchSavePath = "$Env:windir\Temp\CurrentPatch.exe"
[String]$PatchResultsPath = "$Env:windir\Temp\LTPatchLog.txt"
[String]$CustomTableName = "lt_patchinformation"
[String]$PatchDownloadLink = "http://labtech-msp.com/release/LabTechPatch_10.5.2.247.exe"
[BOOL]$ExistCheckSQLDir = CheckRegKeyExists HKLM:\Software\Wow6432Node\Labtech\Setup MySQLDir;
[BOOL]$DownloadNeeded = $True;

#Get connected to the Labtech database
######################################
if ($ExistCheckSQLDir -eq $true)
{
	# Likely to be LT 10
	$SQLDir = (Get-ItemProperty HKLM:\Software\Wow6432Node\LabTech\Setup -name MySQLDir).MySQLDir;
	
	if (Test-Path $SQLDir\mysql.exe)
	{
		Log-Message "Found mysql.exe in MySQL directory..";
		$DownloadNeeded = $false;
	}
}

If ($DownloadNeeded)
{
	
	$DownloadURL = "https://ltpremium.s3.amazonaws.com/third_party_apps/mysql_x64/mysql.zip"
	$MySQLExePath = "$env:windir\temp\mysql.exe"
	$MySQLZipPath = "$env:windir\temp\mysql.zip"
	
	# download mysql.zip and verify md5
	$DownloadResult = Download-MySQLExe;
	
	Log-Message $DownloadResult;
	
	if ($DownloadResult -ne $true)
	{
		Log-Message "Failed to download Mysql.exe, which is required to interface with MySQL. Could not complete server validation."
		exit;
	}
	
	# Unzip mysql.exe to temp
	New-item "$env:windir\ServerMonitor\Packages\MySQL" –ItemType Directory –FORCE | out-null;
	
	Zip-Actions -ZipPath $MySQLZipPath -FolderPath "$env:windir\temp\" -Unzip $true -DeleteZip $true | Out-Null;
	
	if (-not (Test-Path $MySQLExePath))
	{
		Log-Message "[EXTRACTION FAILED] :: Failed to extract MySQL.exe from the zip archive. Script is exiting! Here are the Powershell errors: $($Error)";
		return;
	}

	else
	{
		$SuccessfulDownload = $true;
		Log-Message "[SUCCESS] :: MySQL.exe was successfully extracted from the downloaded zip archive.";
		$SQLDir = "$env:windir\ServerMonitor\Packages\MySQL";
	}
}

[psobject]$ConnectionDetails = Get-LabTechConnection $KeyPhrase;

if ($ConnectionDetails -eq $null)
{
	$errorMessage = "Failed to determine MySQL connection details from this server.`n`n";
	
	Log-Message $errorMessage
	return;
}

else
{
	Log-Message "Successfully retrieved connection details."
}

$DBUser = $ConnectionDetails.user;
$DBHost = $ConnectionDetails.host;
$DBPass = $ConnectionDetails.pass;
$LTVersion = $ConnectionDetails.LTVersion;

#Run the Patch
######################################
$AllArgs = "/t 360 /p 360"
Start-Process -FilePath "$PatchSavePath" -ArgumentList $AllArgs -PassThru -RedirectStandardOutput $PatchResultsPath -Wait -WindowStyle Hidden
$LogFileResults = Get-content -Path $PatchResultsPath

#Check For the new Table
######################################
set-location "$env:windir\temp\";

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

If($LogFileResults -contains "LabTech Server has been successfully updated" -and $TableResult -eq $True)
{
    Write-Log "Patch was Successful"
    Return "Success"
}

Else
{
    Write-Log "Patch Failed"
    Return "Failure"
}