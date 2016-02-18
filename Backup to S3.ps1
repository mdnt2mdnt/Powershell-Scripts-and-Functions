####################################################################
#Variable Declarations

[String]$ScriptLog = "$Env:windir\temp\templog.txt"
[String]$S3CopyLink = "http://s3.amazonaws.com/ltpremium/tools/s3copy/s3copy.exe"
[String]$S3DownloadPath = "$Env:windir\temp\S3copy.exe"
#[String]$LTBackupBaseLocation = "@LTPath@\Backup\LabTech.1.zip"
[String]$LTBackupBaseLocation = "C:\Users\PMarshall\Downloads\installation_assemblies.zip"
#[String]$LTBackupTempLocation = "%windir%\temp\%clientname%-%computerid%-@cdkey@.zip"
[String]$LTBackupTempLocation = "C:\Users\PMarshall\Documents\"
[String]$LTBackupFileName = "testfile.zip"
#[String]$AccessKey = "@AccessKey@"
[String]$AccessKey = "AKIAJ3KEOK4L3FAN6NBQ"
#[String]$SecretKey = "@SecretKey@"
[String]$SecretKey = "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"
[String]$Bucketname = 'partner_backups'

####################################################################
#Download S3Copy.exe

Write-Output "Starting Download Job for S3Copy.exe"

#Declare the Job
$S3CopyDownloadJob = Start-BitsTransfer `
    -Source $S3CopyLink `
    -Destination $S3DownloadPath `
    -Asynchronous

#Make sure the transfer has completed. 
while (($S3CopyDownloadJob.JobState -eq "Transferring") -or ($S3CopyDownloadJob.JobState -eq "Connecting"))
{ 
    sleep 3;
}

Write-Output "Download Job finished. Checking status."

#Check the staus of the jobs completion. 
Switch($S3CopyDownloadJob.JobState)
{
       "Transferred" {Complete-BitsTransfer -BitsJob $S3CopyDownloadJob; Write-Output "S3Copy.exe has successfully downloaded.";}
       "Error"       {Write-Output "Failed to download S3Copy.exe. Error was : $($S3CopyDownloadJob.ErrorDescription)"; exit; }
       default       {Write-Output "Something went wrong with the download of S3Copy..."}
}


####################################################################
#Copy backup file to a temp directory

$copyResults = Copy-Item `
    -Path $LTBackupBaseLocation `
    -Destination "$LTBackupTempLocation$LTBackupFileName" `
    -Force

#Add a test path for Detination here

####################################################################
#Upload the Backup Using S3Copy

$AllArgs = "$LTBackupTempLocation $BucketName $LTBackupFileName $AccessKey $SecretKey"

$S3CopyUploadJob = Start-Process `
    -FilePath $S3DownloadPath `
    -ArgumentList $AllArgs `
    -RedirectStandardOutput $ScriptLog `
    -PassThru `
    -Wait
    #-WindowStyle Hidden