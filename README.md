##  Task 1: Download Sample Data

 1. Navigate to: [Sample Data](https://github.com/matthewrodin/AzureAnalysisServices-SlidingWindowPartitioning/tree/master/Sample%20Data)
 
 2. Download “SampleCustomerData.csv” and “SampleSalesData.csv” to a local machine


##  Task 2: Create Azure SQL Database

 1. Navigate to: [Azure Portal](https://portal.azure.com/)
 
 2. In the search bar, type “sql” and select “SQL data warehouses”
 <img src="./Pictures/aas1.png" width="400">

 3. On the top left, click “+ Add”
 <img src="./Pictures/aas2.png" width="400">
 
 		a. Under “Subscription” -> Select existing Azure subscription

 		b. Under “Resource group” -> Click “Create New” -> Enter a name for the resource group

 		c. Under "Data Warehouse name" -> Enter a name for the data warehouse

 		d. Under “Server" -> Click "Create New"

 			i. Under “Server Name” -> Enter a unique name for the server

 			ii. Under “Server Admin Login” -> Create a username for the server

 			iii. Under “Password” -> Create a password for the server

 			iv. Under “Location” -> Select “Canada Central”

 			v. Tick “Allow Azure services to access server”

 			vi. Click “OK”

 		e. Under “Performance Level”, select “Select performance level”

 			i. Click “Gen2”

 			ii. Scale the data warehouse. For reference, the service levels range from DW100c to DW30000c. 

 			iii. Click “Apply”
 		f. On the bottom left, click the blue “Review + Create” button
 		g. On the bottom left, click the blue “Create” button


