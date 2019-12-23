##  Task 1: Download Sample Data


1.  Navigate to: [Sample Data](https://github.com/matthewrodin/AzureAnalysisServices-SlidingWindowPartitioning/tree/master/Sample%20Data)

2.  Download “SampleCustomerData.csv” and “SampleSalesData.csv” to a local machine
</br>

##  Task 2: Create Azure SQL Database

1.  Navigate to: [Azure Portal](https://portal.azure.com/)

2.  In the search bar, type “sql” and select “SQL data warehouses
</br><img src="./Pictures/aas1.png" width="400">

3.  On the top left, click “+ Add”
</br><img src="./Pictures/aas2.png" width="400">

    a.  Under “Subscription” -> Select existing Azure subscription 
    
    b.  Under “Resource group” -> Click “Create New” -> Enter a name for the resource group
    
    c.  Under “Data Warehouse name” -> Enter a name for the data warehouse
    
    d.  Under “Server” -> Click “Create New” 
    
        i.   Under “Server Name” -> Enter a unique name for the server
        
        ii.  Under “Server Admin Login” -> Create a username for the server
        
        iii. Under “Password” -> Create a password for the server

		iv.  Under “Location” -> Select “Canada Central”

		v.   Tick “Allow Azure services to access server”

		vi.  Click “OK”

	e. Under “Performance Level”, select “Select performance level”

		i.   Click “Gen2”

		ii.  Scale the data warehouse. For reference, the service levels range from DW100c to DW30000c. 

		iii. Click “Apply”
        
    f. On the bottom left, click the blue “Review + Create” button
    
    g.  On the bottom left, click the blue “Create” button
    
</br>
Deployment may take up to 20 minutes.
</br>
</br>

##  Task 3: Prepare SQL Data Warehouse for Data Ingestion
1. Open command prompt


2. Run the following command:
`sqlcmd -S <servername> -d <databasename> -U <serverusername> -P <serverpassword> -I`
**Note:** You can find the <servername> in the “Overview” window of your SQL Data Warehouse resource in the Azure portal.
3. If the following error is received: *“Sqlcmd: Error: Microsoft ODBC Driver 17 for SQL Server : Cannot open server…”*
    
	a.	Copy the IP address provided in the error message

	b.	Navigate to portal.azure.com

	c.	In the search bar, type “sql server” and select “SQL servers”
    </br><img src="./Pictures/aas3.png" width="400">

	d.	Select the server created in Task 2

	e.	Select “Firewalls and virtual networks”
    </br><img src="./Pictures/aas4.png" width="150">
    
        i.   Under “Allow Azure services and resources to access this server” -> Click “On”
        
        ii.  Under Rule Name -> “Rule1”
        
        iii. Under Start IP -> Paste the copied IP Address
        
        iv.  Under End IP -> Paste the copied IP Address
    </br><img src="./Pictures/aas5.png" width="400">
    
    f.	Click “Save”

4.	“1>” should now appear.

5.	Run the following script:
    ```sql
    CREATE TABLE [dbo].[DimCustomer](
        [CustomerKey] [int] NOT NULL,
        [AddressLine1] [varchar](500) NULL,
        [CommuteDistance] [varchar](500) NULL,
        [EmailAddress] [varchar](500) NULL,
        [FirstName] [varchar](500) NULL,
        [LastName] [varchar](500) NULL,
        [Gender] [varchar](500) NULL,
        [Phone] [varchar](500) NULL,
        [YearlyIncome] [varchar](500) NULL,
        [MaritalStatus] [varchar](500) NULL,
        [GeographyKey] [int] NULL,
        [EnglishEducation] [varchar](500) NULL,
        [EnglishOccupation] [varchar](500) NULL,
        [TotalChildren] [int] NULL);
    GO

    ```

6.	Run the following script:
    
    ```sql
    CREATE TABLE [dbo].[FactSales](
        [CustomerKey] [int] NOT NULL,
        [ProductKey] [int] NOT NULL,
        [OrderDateKey] [varchar](500) NOT NULL,
        [CurrencyKey] [int] NOT NULL,
        [SalesOrderNumber] [varchar](500) NOT NULL,
        [SalesTerritoryKey] [int] NOT NULL,
        [TaxAmt] [varchar](500) NOT NULL,
        [Freight] [varchar](500) NOT NULL,
        [SalesAmount] [varchar](500) NOT NULL,
        [Year] [int] NOT NULL,
        [Month] [int] NOT NULL,
        [Day] [int] NOT NULL)
    GO

    ```

</br>

##  Task 4: Create a Storage Account

1.	Navigate to portal.azure.com

2.	In the search bar, type “storage” and select “Storage accounts”
</br><img src="./Pictures/aas6.png" width="400">

3.	Click “+ Add”
</br><img src="./Pictures/aas7.png" width="400">

    a.	Under “Subscription” -> Select existing Azure subscription
    
    b.	Under “Resource group” Select the resource group created in Task 2
    
    c.	Under “Storage account name” -> Enter a name for the storage account
    
    d.	Under “Location” -> Select “Canada Central”
    
    e.	Under “Performance” -> Select “Standard”

    f.	Under “Account kind” -> Select “StorageV2 (general purpose v2)”

    g.	Under “Replication” -> Select “Locally-redundant storage (LRS)”
    
    h.	Under “Access tier (default)” -> Select “Cool”
    
    i.	On the bottom left, click the blue “Review + Create” button
    
    j.	On the bottom left, click the blue “Create” button
    
</br>Deployment may take a minute.

4.	Click “Go to Resource”

5.	Under “Blob service” -> Click “Containers”
</br><img src="./Pictures/aas8.png" width="150">

6.	Click “+ Container”
</br><img src="./Pictures/aas9.png" width="300">

    a.	Under “Name” -> Enter a name for the container
    
    b.	Under “Public access level” -> Select “Blob (anonymous read access for blobs only)”
    
7.	Select “Storage Explorer”
</br><img src="./Pictures/aas10.png" width="150">

8.	Click on “BLOB CONTAINERS”
</br><img src="./Pictures/aas11.png" width="200">

9.	Click on the container that was just created

10.	Click “Upload”
</br><img src="./Pictures/aas12.png" width="400">

11.	Click the blue browse button and upload the local copies of “SampleCustomerData.csv” and “SampleSalesData.csv” to the container. 

12.	Leave “Overwrite if files already exist” blank
</br><img src="./Pictures/aas13.png" width="300">

</br>

##  Task 5: Create a Data Factory

1.	Navigate to portal.azure.com

2.	In the search bar, type “data factory” and select “SQL data warehouses”
</br><img src="./Pictures/aas14.png" width="200">

3.	Click “+ Add”
</br><img src="./Pictures/aas15.png" width="300">

    a.	Under “Name” -> Enter a name for the data factory
    
    b.	Under “Version” -> Select “V2”
    
    c.	Under Subscription” -> Select existing Azure subscription
    
    d.	Under “Resource Group” -> Select the resource group created in Task 2
    
    e.	Under “Location” -> Select “Canada Central”
    
    f.	Untick “Enable Git”
    
    g.	Click “Create”

</br>

##  Task 6: Create a Data Factory Pipeline

1.	Navigate to adf.azure.com

2.	Under “Azure Active Directory” -> Select existing Azure AD

3.	Under “Subscription” -> Select existing Azure subscription

4.	Under Data Factory name -> Select the Data Factory created in Task 5

5.	Click “Continue”

6.	Click the Home icon
</br><img src="./Pictures/aas16.png" width="150">

7.	Click “Copy data”
</br><img src="./Pictures/aas17.png" width="400">

8.	Under “Properties”

    a.	Under “Task Name” -> Enter a name for the task
    
    b.	Under “Task cadence or task schedule” -> Select “Run once now”
    
    c.	Click “Next”
    
9.	Under “Source”

    a.	Select “Azure”
    
    b.	Select “+ Create new connection”
    </br><img src="./Pictures/aas18.png" width="400">
    
    c.	Select “Azure Blob Storage”
    
    d.	Click “Continue
    </br><img src="./Pictures/aas19.png" width="300">
    
    e.	Under “Name” -> Enter a name for the connection
    
        i.	Under “Account selection method” -> Select “From Azure Subscription”
        
        ii.	Under “Azure subscription” -> Select existing Azure subscription
        
        iii.	Under “Storage account name” -> Select the storage account created in Task 4
        
        iv.	Note: Leave all other fields as the default
        
        v.	Click “Create”
        
    f.	Click “Next”
    
    g.	Under “File or folder” -> Click “Browse”
    
    h.	Double click the container you created in Task 4
    
    i.	Select “SampleCustomerData.csv”
    
    j.	Click “Choose”
    
    k.	Note: Keep all other fields as the default
    
    l.	Click “Next”
    
    m.	Verify the schema under “Preview” and click “Next”




    





