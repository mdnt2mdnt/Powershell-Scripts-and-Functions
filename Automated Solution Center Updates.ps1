#Function Declarations
######################################
function Log-Message ($msg)
{
	write-output $msg;
	Add-Content $Logfile $msg;
}

#Prep Work 
######################################

$ScriptLog = "c:\windows\temp\script.txt"
$UpdateLog = "c:\windows\temp\marketplaceupdates.txt"
$ExistCheckSQLDir = CheckRegKeyExists HKLM:\Software\Wow6432Node\Labtech\Setup MySQLDir;
$ExistCheckRootPwd = CheckRegKeyExists HKLM:\Software\Wow6432Node\Labtech\Setup RootPassword;
$DownloadNeeded = $true;

#Get the LT Share dir and set proper permissions
################################################

$32BitRegPath = 'HKLM:\Software\wow6432node\LabTech\Setup'
$RegName = 'local ltshare'

$LTShareDir = (Get-ItemProperty -Path $RegPath -Name $RegName).'Local LTShare'
attrib -r $LTShareDir
icacls $ltsharedir\* /T /Q /C /RESET
Set-Location "C:\Program Files (x86)\LabTech Client"
attrib -R *.* /S



Set-Location "%programfiles32%\LabTech Client\"


$args = @('/update', '/fix', '/commandfile C:\commandfile.txt')

Start-Process -FilePath "%programfiles32%\LabTech Client\LTMarketplace.exe" -ArgumentList $Args