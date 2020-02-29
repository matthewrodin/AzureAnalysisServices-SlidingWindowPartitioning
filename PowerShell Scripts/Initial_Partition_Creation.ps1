## Create initial Partitions ##
$aasserver = 'Azure Analysis Services Server Name'
$sqldwserver = 'Azure Synapse Analytics Server Name'
$sqldw = 'Azure Synapse Analytics Name'
$model = 'Azure Analysis Services Model Name'
$NumMonths = 'Number of Months'
$_Credential = Get-AutomationPSCredential -Name "ServicePrincipal"
$datasource = "AzureSqlDW " + $sqldwserver + " " + $sqldw 
$ProcessDate= (Get-Date)

$i=0
$j=1
$PartitionToBeChecked =""

while($PartitionToBeChecked  -ne "$NumMonths months ago") {
	
    $PartitionToBeChecked = "$j"+ " months ago"
    if ($pnames -contains $PartitionToBeChecked -eq $False) {
	
		$LastMonth=$ProcessDate.AddMonths($i-1).Year.ToString() + $ProcessDate.AddMonths($i-1).Month.ToString("00")+"01"
		$ThisMonth=$ProcessDate.AddMonths($i).Year.ToString() + $ProcessDate.AddMonths($i).Month.ToString("00")+"01"
		   
		$CreatePartitions = 
@" 
		{
			"create": {
				"parentObject": {
				"database": "$model",
				"table": "FactSales"
				},
				"partition": {
					"name": "$j Months Old",
					"source": {
						"query": [
							"SELECT [dbo].[FactSales].* FROM [dbo].[FactSales] ",
							"WHERE [dbo].[FactSales].[OrderDateKey] >= '$LastMonth' AND [dbo].[FactSales].[OrderDateKey] < '$ThisMonth'"
						],
						"dataSource": "$datasource"
					}
				}
			}
		} 
"@	
		Invoke-ASCmd -Server $aasserver -Database:$model -Query:$CreatePartitions -ServicePrincipal -Credential $_credential
    }
$i--
$j++
}

$LastMonth_2 = $ProcessDate.AddMonths(-$NumMonths).Year.ToString() + $ProcessDate.AddMonths(-$NumMonths).Month.ToString("00")+"01"
$CreatePartitions_2 = 
@" 
	{
		"create": {
			"parentObject": {
			"database": "$model",
			"table": "FactSales"
			},
			"partition": {
				"name": "More than $NumMonths Months Old",
				"source": {
					"query": [
						"SELECT [dbo].[FactSales].* FROM [dbo].[FactSales] ",
						"WHERE [dbo].[FactSales].[OrderDateKey]  < '$LastMonth_2'"
					],
					"dataSource": "$datasource"
				}
			}
		}
	} 
"@	 
Invoke-ASCmd -Server $aasserver -Database:$model -Query:$CreatePartitions_2 -ServicePrincipal -Credential $_credential

## Delete Large/Initial Partition ##
$deletePartition = 
@" 
	{   
		"delete": {   
			"object": {   
				"database": "$model",   
				"table": "FactSales",   
				"partition": "FactSales"   
			}   
		}   
	}  
"@	

Invoke-ASCmd -Server $aasserver -Database:$model -Query:$deletePartition -ServicePrincipal -Credential $_credential

## Process Partitions ##
$k = 1
$PartitionToBeChecked = ""

while($PartitionToBeChecked  -ne "$NumMonths Months Old") {
	
    $PartitionToBeChecked = "$k"+ " Months Old"	
	$RefreshPartitions = 
@" 
	{
	  "refresh": {
		"type": "full",
		"objects": [
		  {
			"database": "$model",
			"table": "FactSales",
			"partition": "$k Months Old"
		  }
		]
	  }
	}
"@	

	Invoke-ASCmd -Server $aasserver -Database:$model -Query:$RefreshPartitions -ServicePrincipal -Credential $_credential	
	$k++
}

$RefreshPartitions_2 = 
@" 
	{
	  "refresh": {
		"type": "full",
		"objects": [
		  {
			"database": "$model",
			"table": "FactSales",
			"partition": "More than $NumMonths Months Old"
		  }
		]
	  }
	}
"@	

Invoke-ASCmd -Server $aasserver -Database:$model -Query:$RefreshPartitions_2 -ServicePrincipal -Credential $_credential