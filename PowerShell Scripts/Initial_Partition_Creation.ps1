## Create initial Partitions ##
$server = <Azure Analysis Services Server Name>
$db = <Azure Analysis Services Model Name>
$ProcessDate= (Get-Date)
$NumMonths = 7
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
				"database": "TabularProject11",
				"table": "FactInternetSales_"
				},
				"partition": {
					"name": "$j Months Old",
					"source": {
						"query": [
							"SELECT [dbo].[FactInternetSales_].* FROM [dbo].[FactInternetSales_] ",
							"WHERE [dbo].[FactInternetSales_].[OrderDateKey] >= '$LastMonth' AND [dbo].[FactInternetSales_].[OrderDateKey] < '$ThisMonth'"
						],
						"dataSource": "AzureSqlDW acaasdemo.database.windows.net ACAASDemo"
					}
				}
			}
		} 
"@	
		Invoke-ASCmd -Server $server -Database:$db -Query:$CreatePartitions
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
			"database": "TabularProject11",
			"table": "FactInternetSales_"
			},
			"partition": {
				"name": "More than 7 Months Old",
				"source": {
					"query": [
						"SELECT [dbo].[FactInternetSales_].* FROM [dbo].[FactInternetSales_] ",
						"WHERE [dbo].[FactInternetSales_].[OrderDateKey]  < '$LastMonth_2'"
					],
					"dataSource": "AzureSqlDW acaasdemo.database.windows.net ACAASDemo"
				}
			}
		}
	} 
"@	
Invoke-ASCmd -Server $server -Database:$db -Query:$CreatePartitions_2

## Delete Large/Initial Partition ##
$deletePartition = 
@" 
	{   
		"delete": {   
			"object": {   
				"database": "TabularProject11",   
				"table": "FactInternetSales_",   
				"partition": "FactInternetSales_"   
			}   
		}   
	}  
"@	

Invoke-ASCmd -Server $server -Database:$db -Query:$deletePartition

## Process Partitions ##
$k = 1
$PartitionToBeChecked = ""

while($PartitionToBeChecked  -ne "7 Months Old") {
	
    $PartitionToBeChecked = "$k"+ " Months Old"	
	$RefreshPartitions = 
@" 
	{
	  "refresh": {
		"type": "full",
		"objects": [
		  {
			"database": "TabularProject11",
			"table": "FactInternetSales_",
			"partition": "$k Months Old"
		  }
		]
	  }
	}
"@	

	Invoke-ASCmd -Server $server -Database:$db -Query:$RefreshPartitions	
	$k++
}

$RefreshPartitions_2 = 
@" 
	{
	  "refresh": {
		"type": "full",
		"objects": [
		  {
			"database": "TabularProject11",
			"table": "FactInternetSales_",
			"partition": "More than 7 Months Old"
		  }
		]
	  }
	}
"@	

Invoke-ASCmd -Server $server -Database:$db -Query:$RefreshPartitions_2