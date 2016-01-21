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
	
	.PARAMETER Severity
		The label assigned to that log message line. Options are "Note", "Warning", and "Problem"
	
	.EXAMPLE
		PS C:\> Write-Log -StrMessage 'This is a note message being written out to the log.' -Severity 1
		PS C:\> Write-Log -StrMessage 'This is a warning message being written out to the log.' -Severity 2
		PS C:\> Write-Log -StrMessage 'This is a error message being written out to the log.' -Severity 3
		PS C:\> Write-Log -StrMessage 'This message being written has no severity.'
	
	.NOTES
		N/A
#>
	
	Param
		(
		[Parameter(Mandatory = $True, Position = 0)]
		[String]$Message,
		[Parameter(Mandatory = $False, Position = 1)]
		[INT]$Severity
	)
	
	$Note = "[NOTE]"
	$Warning = "[WARNING]"
	$Problem = "[ERROR]"
	[string]$Date = get-date
	
	switch ($Severity)
	{
		1 { add-content -path $LogFilePath -value ($Date + "`t:`t" + $Note + $Message) }
		2 { add-content -path $LogFilePath -value ($Date + "`t:`t" + $Warning + $Message) }
		3 { add-content -path $LogFilePath -value ($Date + "`t:`t" + $Problem + $Message) }
		default { add-content -path $LogFilePath -value ($Date + "`t:`t" + $Message) }
	}
	
	
}