## Merge last 2 partitions ##
$NumMonths = 7
$server = "asazure://canadacentral.asazure.windows.net/acaasdemo"
$db = "TabularProject11"
$ProcessDate= (Get-Date)
$ProcessDate = $ProcessDate.AddMonths(1)
$_Credential = Get-AutomationPSCredential -Name "NewCredential"
$MergePartitions = @"
{
  "mergePartitions": {
    "target": {
      "database": "TabularProject11",
      "table": "FactInternetSales_",
      "partition": "More than $NumMonths Months Old"
    },
    "sources": [
      "$NumMonths Months Old"
    ]
  }
}
"@
Invoke-ASCmd -Server $server -Database:$db -Query:$MergePartitions -ServicePrincipal -Credential $_credential	

## Update Query on Merged Partititon ##
$LastMonth = $ProcessDate.AddMonths(-$NumMonths).Year.ToString() + $ProcessDate.AddMonths(-$NumMonths).Month.ToString("00")+"01"
$AlterPartitions = 
@" 
{   
  "alter": {   
    "object": {   
      "database": "TabularProject11",   
      "table": "FactInternetSales_",   
      "partition": "More than 7 Months Old"   
    },
    "partition": {   
      "name": "More than 7 Months Old",   
     					"source": {
						"query": [
							"SELECT [dbo].[FactInternetSales_].* FROM [dbo].[FactInternetSales_] ",
							"WHERE [dbo].[FactInternetSales_].[OrderDateKey] < '$LastMonth'"
						],
						"dataSource": "AzureSqlDW acaasdemo.database.windows.net ACAASDemo"
					}    
    }   
  }   
}  
"@
	
		Invoke-ASCmd -Server $server -Database:$db -Query:$AlterPartitions -ServicePrincipal -Credential $_credential	



## Loop through partitions and change the names ##
$i= $NumMonths - 2
$j= $NumMonths - 1
$PartitionToBeChecked =""

while($PartitionToBeChecked  -ne "1 Months Old") {
	
    $PartitionToBeChecked = "$j"+ " Months Old"
	
		$LastMonth=$ProcessDate.AddMonths(-2-$i).Year.ToString() + $ProcessDate.AddMonths(-2-$i).Month.ToString("00")+"01"
		$ProcessDate.AddMonths(-2-$i).Year.ToString() + $ProcessDate.AddMonths(-2-$i).Month.ToString("00")+"01"
		$ThisMonth=$ProcessDate.AddMonths(-1-$i).Year.ToString() + $ProcessDate.AddMonths(-1-$i).Month.ToString("00")+"01"
		$ProcessDate.AddMonths(-1-$i).Year.ToString() + $ProcessDate.AddMonths(-1-$i).Month.ToString("00")+"01"
		$k = $j + 1   
		$AlterPartitions_2 = 
@" 
{   
  "alter": {   
    "object": {   
      "database": "TabularProject11",   
      "table": "FactInternetSales_",   
      "partition": "$j Months Old"   
    },
    "partition": {   
      "name": "$k Months Old",   
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
	
		Invoke-ASCmd -Server $server -Database:$db -Query:$AlterPartitions_2 -ServicePrincipal -Credential $_credential	
$i--
$j--
}

## Create new 1 Month Old Partition ##
$LastMonth=$ProcessDate.AddMonths(0).Year.ToString() + $ProcessDate.AddMonths(0).Month.ToString("00")+"01"
$ThisMonth=$ProcessDate.AddMonths(1).Year.ToString() + $ProcessDate.AddMonths(1).Month.ToString("00")+"01"
$ProcessDate.AddMonths(0).Year.ToString() + $ProcessDate.AddMonths(0).Month.ToString("00")+"01"
$ProcessDate.AddMonths(1).Year.ToString() + $ProcessDate.AddMonths(1).Month.ToString("00")+"01"
$CreatePartitions = 
@" 
	{
		"create": {
			"parentObject": {
			"database": "TabularProject11",
			"table": "FactInternetSales_"
			},
			"partition": {
				"name": "1 Months Old",
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
Invoke-ASCmd -Server $server -Database:$db -Query:$CreatePartitions -ServicePrincipal -Credential $_credential	

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

	Invoke-ASCmd -Server $server -Database:$db -Query:$RefreshPartitions -ServicePrincipal -Credential $_credential		
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

Invoke-ASCmd -Server $server -Database:$db -Query:$RefreshPartitions_2 -ServicePrincipal -Credential $_credential	