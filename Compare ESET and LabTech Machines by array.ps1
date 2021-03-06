# The Run-MySQLQuery function sets up the connection so that we can reach out to both MySQL databases.
Function Run-MySQLQuery {
    Param(
        [Parameter(
            Mandatory = $true,
            ParameterSetName = '',
            ValueFromPipeline = $true)]
            [string]$query,   
        [Parameter(
            Mandatory = $true,
            ParameterSetName = '',
            ValueFromPipeline = $true)]
            [string]$connectionString
        )
    Begin {
        Write-Verbose "Starting Begin Section"        
    }
    Process {
        Write-Verbose "Starting Process Section"
        try {
            # load MySQL driver and create connection
            Write-Verbose "Create Database Connection"
            # You could also could use a direct Link to the DLL File
            # $mySQLDataDLL = "C:\scripts\mysql\MySQL.Data.dll"
            # [void][system.reflection.Assembly]::LoadFrom($mySQLDataDLL)
            [void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
            $connection = New-Object MySql.Data.MySqlClient.MySqlConnection
            $connection.ConnectionString = $ConnectionString
            Write-Verbose "Open Database Connection"
            $connection.Open()
            
            # Run MySQL Querys
            Write-Verbose "Run MySQL Querys"
            $command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $connection)
            $dataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($command)
            $dataSet = New-Object System.Data.DataSet
            $recordCount = $dataAdapter.Fill($dataSet, "data")
            $dataSet.Tables["data"]
        }        
        catch {
            Write-Host "Could not run MySQL Query" $Error[0]    
        }    
        Finally {
            Write-Verbose "Close Connection"
            $connection.Close()
        }
    }
    End {
        Write-Verbose "Starting End Section"
    }
}

#The Two Lines Below establish the connections, get the results from the query, and assign them to the two variables.
$EsetComputers = run-MySQLQuery -ConnectionString "Server=localhost;Uid=root;Pwd=mekukiggellitoka;database=ESETRADB;Allow Zero Datetime=true;" "SELECT ComputerName as Name,macaddress AS Mac,clientdomain AS Domain FROM CLIENT"
$LabTechComputers = run-MySQLQuery -ConnectionString "Server=localhost;Uid=root;Pwd=mekukiggellitoka;database=LABTECH;Allow Zero Datetime=true;" "SELECT name,REPLACE(mac,'-','') AS Mac,REPLACE(Domain,'DC:','') AS Domain FROM computers"

#Below the variables are set for all of the arrays and the computations done around the arrays.
$MaxArrCount = ($EsetComputers | Measure-Object).Count-1;
$MissingEntries=@();
$EsetArray = @()
$LabTechArray = @()
$LTUBOUND = $LabTechComputers.GetUpperBound(0);

#Below is the looping functionality to do the array comparison.
[int]$i = 0;

while($i -lt $MaxArrCount)
{
	[int]$t = 0;
	$found = $false;
	$curName = $EsetComputers[$i][0].ToUpper();
	$curMac = $EsetComputers[$i][1].ToUpper();
	$curDomain = $EsetComputers[$i][2].ToUpper();
		
	while($t -lt $LTUbound) 
	{
		$LTCurName 	= $LabTechComputers[$t][0].ToUpper();
		$LTCurMac	= $LabTechComputers[$t][1].ToUpper();
		$LTCurDomain = $LabTechComputers[$t][2].ToUpper();
		
		
		if($curName -eq $LTCurName <#-and $curMac -eq $LTCurMac#> -and $curDomain -eq $LTCurDomain)
		{
			#Matches!
			$found = $true;
			break;
		}
		
		$t+=1;
	}
	
	if($found -ne $true)
	{
		$MissingEntries+=@(($curName,$curDomain))
		
	}
	
	$i+=1;
}

Out-File -InputObject $MissingEntries -FilePath 'D:\LTShare\Transfer\Scripts\ESET\missingagents.txt'