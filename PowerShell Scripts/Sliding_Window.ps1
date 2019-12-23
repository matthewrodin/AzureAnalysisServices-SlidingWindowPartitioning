## Merge last 2 partitions ##
$aasserver = 'Azure Analysis Services Server Name'
$sqldwserver = 'Azure SQL Data Warehouse Server Name'
$sqldw = 'Azure SQL Data Warehouse Name'
$model = 'Azure Analysis Services Model Name'
$NumMonths = 'Number of Months'
$_Credential = Get-AutomationPSCredential -Name "ServicePrincipal"
$datasource = "AzureSqlDW " + $sqldwserver + " " + $sqldw 
$ProcessDate= (Get-Date)
$ProcessDate = $ProcessDate.AddMonths(1)

$MergePartitions = @"
{
  "mergePartitions": {
    "target": {
      "database": "$model",
      "table": "FactSales",
      "partition": "More than $NumMonths Months Old"
    },
    "sources": [
      "$NumMonths Months Old"
    ]
  }
}
"@
Invoke-ASCmd -Server $aasserver -Database:$model -Query:$MergePartitions -ServicePrincipal -Credential $_credential	

## Update Query on Merged Partititon ##
$LastMonth = $ProcessDate.AddMonths(-$NumMonths).Year.ToString() + $ProcessDate.AddMonths(-$NumMonths).Month.ToString("00")+"01"
$AlterPartitions = 
@" 
{   
  "alter": {   
    "object": {   
      "database": "$model",   
      "table": "FactInternetSales",   
      "partition": "More than $NumMonths Months Old"   
    },
    "partition": {   
      "name": "More than $NumMonths Months Old",   
     					"source": {
						"query": [
							"SELECT [dbo].[FactSales].* FROM [dbo].[FactSales] ",
							"WHERE [dbo].[FactSales].[OrderDateKey] < '$LastMonth'"
						],
						"dataSource": "$datasource"
					}    
    }   
  }   
}  
"@
	
		Invoke-ASCmd -Server $aasserver -Database:$model -Query:$AlterPartitions -ServicePrincipal -Credential $_credential	



## Loop through partitions and change the names ##
$i= $NumMonths - 2
$j= $NumMonths - 1
$PartitionToBeChecked =""

while($PartitionToBeChecked  -ne "1 Months Old") {
	
    $PartitionToBeChecked = "$j"+ " Months Old"
	
		$LastMonth=$ProcessDate.AddMonths(-2-$i).Year.ToString() + $ProcessDate.AddMonths(-2-$i).Month.ToString("00")+"01"
		$ThisMonth=$ProcessDate.AddMonths(-1-$i).Year.ToString() + $ProcessDate.AddMonths(-1-$i).Month.ToString("00")+"01"
		$k = $j + 1   
		$AlterPartitions_2 = 
@" 
{   
  "alter": {   
    "object": {   
      "database": "model",   
      "table": "FactSales",   
      "partition": "$j Months Old"   
    },
    "partition": {   
      "name": "$k Months Old",   
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
	
		Invoke-ASCmd -Server $aasserver -Database:$model -Query:$AlterPartitions_2 -ServicePrincipal -Credential $_credential	
$i--
$j--
}

## Create new 1 Month Old Partition ##
$LastMonth=$ProcessDate.AddMonths(-1).Year.ToString() + $ProcessDate.AddMonths(-1).Month.ToString("00")+"01"
$ThisMonth=$ProcessDate.AddMonths(0).Year.ToString() + $ProcessDate.AddMonths(0).Month.ToString("00")+"01"
$CreatePartitions = 
@" 
	{
		"create": {
			"parentObject": {
			"database": "$model",
			"table": "FactSales"
			},
			"partition": {
				"name": "1 Months Old",
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