--*************************************************************************--
-- Title: Assignment08
-- Author: Ariel Garcia
-- Desc: This file demonstrates how to use Stored Procedures
-- Change Log: When,Who,What
-- 2017-01-01,Ariel Garcia,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment08DB_ArielGarcia')
	 Begin 
	  Alter Database [Assignment08DB_ArielGarcia] set Single_user With Rollback Immediate;
	  Drop Database Assignment08DB_ArielGarcia;
	 End
	Create Database Assignment08DB_ArielGarcia;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment08DB_ArielGarcia;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
-- NOTE: We are starting without data this time!

-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count] From dbo.Inventories;
go

-- Selecting code
/*
Select * From vCategories
order by CategoryID
go
Select * From vProducts
order by ProductID
go
Select * From vEmployees
order by EmployeeID
go
Select * From vInventories
order by InventoryID
go*/

/********************************* Questions and Answers *********************************/
/* NOTE:Use the following template to create your stored procedures and plan on this taking ~2-3 hours

Create Procedure <pTrnTableName>
 (<@P1 int = 0>)
 -- Author: <ArielGarcia>
 -- Desc: Processes <Desc text>
 -- Change Log: When,Who,What
 -- <2017-01-01>,<Ariel Garcia>,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	-- Transaction Code --
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go
*/

-- Question 1 (20 pts): How can you create Insert, Update, and Delete Transactions Stored Procedures  
-- for the Categories table?

Create Procedure pInsCategories

(@CategoryName nvarchar (100))

 -- Author: <ArielGarcia>
 -- Desc: Processes create Stored Procedure for inserting data into the Categories table
 -- Change Log: When,Who,What
 -- <2017-01-01>,<Ariel Garcia>,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Insert Into Categories (CategoryName) 
	Values (@CategoryName)
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pUpdCategories

(@CategoryID int, @CategoryName nvarchar (100))

 -- Author: <ArielGarcia>
 -- Desc: Processes create Stored Procedure for updating data in the Categories table
 -- Change Log: When,Who,What
 -- <2017-01-01>,<Ariel Garcia>,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Update Categories 
	Set CategoryName = @CategoryName
	Where CategoryID = @CategoryID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go
 
Create Procedure pDelCategories

(@CategoryID int)

 -- Author: <ArielGarcia>
 -- Desc: Processes create Stored Procedure for deleting data from the Categories table
 -- Change Log: When,Who,What
 -- <2017-01-01>,<Ariel Garcia>,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
    Delete
	From Categories 
	Where CategoryID = @CategoryID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

-- Basic Test Code -  we will get more advanced on question 5 
/*
Select * From vCategories
order by CategoryID
go

Exec pInsCategories
@CategoryName = 'Beverages';
go 
Exec pInsCategories
@CategoryName = 'Essential oil';
go
Exec pUpdCategories
@CategoryID = 2,
@CategoryName = 'Antigravity Serum';
go
Exec pDelCategories
@CategoryID = 2
go

--DBCC CHECKIDENT(Categories, RESEED, 0)
--go
*/
-- Question 2 (20 pts): How can you create Insert, Update, and Delete Transactions Store Procedures  
-- for the Products table?

Create Procedure pInsProducts

(@ProductName nvarchar (100),
 @CategoryID int,
 @UnitPrice money)

 -- Author: <ArielGarcia>
 -- Desc: Processes create Stored Procedure for inserting data into the Products table
 -- Change Log: When,Who,What
 -- <2017-01-01>,<Ariel Garcia>,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Insert Into Products(ProductName,CategoryID,UnitPrice) 
	Values (@ProductName, @CategoryID, @UnitPrice)
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pUpdProducts

(@ProductID int,
 @ProductName nvarchar (100),
 @CategoryID int,
 @UnitPrice money)

 -- Author: <ArielGarcia>
 -- Desc: Processes create Stored Procedure for updating data in the Products table
 -- Change Log: When,Who,What
 -- <2017-01-01>,<Ariel Garcia>,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Update Products
	Set ProductName = @ProductName,
	    CategoryID = @CategoryID,
		UnitPrice = @UnitPrice 
	Where ProductID = @ProductID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pDelProducts

(@ProductID int)

 -- Author: <ArielGarcia>
 -- Desc: Processes create Stored Procedure for deleting data from the Products table
 -- Change Log: When,Who,What
 -- <2017-01-01>,<Ariel Garcia>,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Delete 
	From Products 
	Where ProductID = @ProductID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

-- Basic Test Code 
/*
Select * From vProducts
order by ProductID
go

Exec pInsProducts
@ProductName = 'Redmoose',
@CategoryID = 1,
@UnitPrice = 18.99
go 
Exec pInsProducts
@ProductName = 'Oregano Oil',
@CategoryID = 2,
@UnitPrice = 16.49
go
Exec pUpdProducts
@ProductID = 1,
@ProductName = 'Yerba Mate',
@CategoryID = 1,
@UnitPrice = 3.69
go
Exec pDelProducts
@ProductID = 4
go

--DBCC CHECKIDENT(Products, RESEED, 0)
--go
*/
-- Question 3 (20 pts): How can you create Insert, Update, and Delete Transactions Store Procedures  
-- for the Employees table?

Create Procedure pInsEmployees 

(@EmployeeFirstName nvarchar (100),
 @EmployeeLastName nvarchar (100),
 @ManagerID int)

 -- Author: <ArielGarcia>
 -- Desc: Processes create Stored Procedure for inserting data into the Employees table
 -- Change Log: When,Who,What
 -- <2017-01-01>,<Ariel Garcia>,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Insert Into Employees(EmployeeFirstName,EmployeeLastName,ManagerID) 
	Values (@EmployeeFirstName, @EmployeeLastName, @ManagerID)
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pUpdEmployees

(@EmployeeID int,
 @EmployeeFirstName nvarchar (100),
 @EmployeeLastName nvarchar (100),
 @ManagerID int)
 
 -- Author: <ArielGarcia>
 -- Desc: Processes create Stored Procedure for updating data in the Employees table
 -- Change Log: When,Who,What
 -- <2017-01-01>,<Ariel Garcia>,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Update Employees
	Set EmployeeFirstName  = @EmployeeFirstName,
	    EmployeeLastName  = @EmployeeLastName,
	    ManagerID = @ManagerID
	Where EmployeeID = @EmployeeID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go
 
Create Procedure pDelEmployees

(@EmployeeID int)

 -- Author: <ArielGarcia>
 -- Desc: Processes create Stored Procedure for deleting data from the Employees table
 -- Change Log: When,Who,What
 -- <2017-01-01>,<Ariel Garcia>,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Delete 
	From Employees 
	Where EmployeeID = @EmployeeID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go
					  
--Basic Test Code
/*
Select * From vEmployees
order by EmployeeID
go

Exec pInsEmployees
@EmployeeFirstName = 'Jeffrey',
@EmployeeLastName = 'Wilcox',
@ManagerID = 1
go 
Exec pInsEmployees
@EmployeeFirstName = 'Timothy',
@EmployeeLastName = 'Jones',
@ManagerID = 2
go
Exec pInsEmployees
@EmployeeFirstName = 'Corey',
@EmployeeLastName = 'Jackson',
@ManagerID = 2
go
Exec pUpdEmployees
@EmployeeID = 1,
@EmployeeFirstName = 'James',
@EmployeeLastName = 'Martin III',
@ManagerID = 1
go
Exec pDelEmployees
@EmployeeID = 1
go

--Alter Table Employees 
--Drop Constraint fkEmployeesToEmployeesManager; -- Here we learned that delete is not a 
--go
--DBCC CHECKIDENT(Employees, RESEED, 0)
--go
*/ 
-- Question 4 (20 pts): How can you create Insert, Update, and Delete Transactions Store Procedures  
-- for the Inventories table?

Create Procedure pInsInventories

(@EmployeeID int,
@InventoryDate date,
 @ProductID int,
 @Count int)

 -- Author: <ArielGarcia>
 -- Desc: Processes create Stored Procedure for inserting data into the Inventories table
 -- Change Log: When,Who,What
 -- <2017-01-01>,<Ariel Garcia>,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Insert Into Inventories(InventoryDate , EmployeeID, ProductID, [Count]) 
	Values (@InventoryDate, @EmployeeID, @ProductID, @Count)
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go
 
Create Procedure pUpdInventories
(@InventoryID int,
 @InventoryDate date,
 @EmployeeID int,
 @ProductID int,
 @Count int)
 
 -- Author: <ArielGarcia>
 -- Desc: Processes create Stored Procedure for updating data in the Inventories table
 -- Change Log: When,Who,What
 -- <2017-01-01>,<Ariel Garcia>,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Update Inventories
	Set InventoryDate = @InventoryDate,
	    EmployeeID = @EmployeeID,
	    ProductID = @ProductID,
	    [Count] = @Count
	Where InventoryID = @InventoryID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go
 
Create Procedure pDelInventories

(@InventoryID int)

 -- Author: <ArielGarcia>
 -- Desc: Processes create Stored Procedure for deleting data from the Inventories table
 -- Change Log: When,Who,What
 -- <2017-01-01>,<Ariel Garcia>,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Delete 
	From Inventories 
	Where InventoryID = @InventoryID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

--Basic Test Code
/*
Select * From vInventories
order by InventoryID
go

Exec pInsInventories                
@EmployeeID = 1,
@InventoryDate = '2017-01-01',
@ProductID = 1,
@Count = 65
go 

Exec pUpdInventories
@InventoryID = 1,
@InventoryDate = '2017-01-01',
@EmployeeID = 1,
@ProductID = 1,
@Count = 54
go
Exec pDelInventories
@InventoryID = 1
go

DBCC CHECKIDENT(Inventories, RESEED, 0)
go

Select * From vCategories
order by CategoryID
go
Select * From vProducts
order by ProductID
go
Select * From vEmployees
order by EmployeeID
go
Select * From vInventories
order by InventoryID
go*/	
	
-- Question 5 (20 pts): How can you Execute each of your Insert, Update, and Delete stored procedures? 
-- Include custom messages to indicate the status of each sproc's execution.

-- To Help you, I am providing this template:
/*
Declare @Status int;
Exec @Status = <SprocName>
                @ParameterName = 'A'
Select Case @Status
  When +1 Then '<TableName> Insert was successful!'
  When -1 Then '<TableName> Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From <ViewName> Where ColID = 1;
go
*/


--< Test Insert Sprocs >--
-- Test [dbo].[pInsCategories]
Declare @RC int;
Exec @RC = pInsCategories
                @CategoryName = 'A'
Select Case @RC
  When +1 Then 'Categories Insert was successful!'
  When -1 Then 'Categories Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vCategories Where CategoryID = 1;
go

-- Test [dbo].[pInsProducts]
Declare @RC int;
Exec @RC = pInsProducts
                @ProductName = 'A',
				@CategoryID = 1,
				@UnitPrice = 9.99
Select Case @RC
  When +1 Then 'Products Insert was successful!'
  When -1 Then 'Products Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vProducts Where ProductID = 1;
go

-- Test [dbo].[pInsEmployees]
Declare @RC int;
Exec @RC = pInsEmployees
                @EmployeeFirstName = 'Abe',
				@EmployeeLastName = 'Archer',
				@ManagerID = 1
Select Case @RC
  When +1 Then 'Employees Insert was successful!'
  When -1 Then 'Employees Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vEmployees Where EmployeeID = 1;
go

-- Test [dbo].[pInsInventories]
Declare @RC int;
Exec @RC = pInsInventories
                @InventoryDate = '2017-01-01',
				@EmployeeID = 1,
				@ProductID = 1,
				@Count = 42
Select Case @RC
  When +1 Then 'Inventories Insert was successful!'
  When -1 Then 'Inventories Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vInventories Where InventoryID = 1;
go

--< Test Update Sprocs >--
-- Test Update [dbo].[pUpdCategories]
Declare @RC int;
Exec @RC = pUpdCategories
				@CategoryID = 1,
				@CategoryName = 'B';
Select Case @RC
  When +1 Then 'Categories Insert was successful!'
  When -1 Then 'Categories Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vCategories Where CategoryID = 1;
go

-- Test [dbo].[pUpdProducts]
Declare @RC int;
Exec @RC = pUpdProducts
                @ProductID = 1,
				@ProductName = 'B',
				@CategoryID = 1,
				@UnitPrice = 1.00
Select Case @RC
  When +1 Then 'Products Insert was successful!'
  When -1 Then 'Products Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vProducts Where ProductID = 1;
go

-- Test [dbo].[pUpdEmployees]
Declare @RC int;
Exec @RC = pUpdEmployees
                @EmployeeID = 1,
				@EmployeeFirstName = 'Abe',
				@EmployeeLastName = 'Arch',
				@ManagerID = 1
Select Case @RC
  When +1 Then 'Employees Insert was successful!'
  When -1 Then 'Employees Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vEmployees Where EmployeeID = 1;
go

-- Test [dbo].[pUpdInventories]
Declare @RC int;
Exec @RC = pUpdInventories
                @InventoryID = 1,
				@InventoryDate = '2017-01-02',
				@EmployeeID = 1,
				@ProductID = 1,
				@Count = 43
Select Case @RC
  When +1 Then 'Inventories Insert was successful!'
  When -1 Then 'Inventories Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vInventories Where InventoryID = 1;
go

--< Test Delete Sprocs >--
-- Test [dbo].[pDelInventories]
Declare @RC int;
Exec @RC = pDelInventories
				@InventoryID = 1
Select Case @RC
  When +1 Then 'Inventories Delete was successful!'
  When -1 Then 'Inventories Delete failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vInventories Where InventoryID = 1;
go

-- Test [dbo].[pDelEmployees]
Declare @RC int;
Exec @RC = pDelEmployees
				@EmployeeID = 1 
Select Case @RC
  When +1 Then 'Employees Delete was successful!'
  When -1 Then 'Employees Delete failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vEmployees Where EmployeeID = 1;
go

-- Test [dbo].[pDelProducts]
Declare @RC int;
Exec @RC = pDelProducts
				@ProductID = 1 
Select Case @RC
  When +1 Then 'Products Delete was successful!'
  When -1 Then 'Products Delete failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vProducts Where ProductID = 1;
go

-- Test [dbo].[pDelCategories]
Declare @RC int;
Exec @RC = pDelCategories
				@CategoryID = 1 
Select Case @RC
  When +1 Then 'Categories Delete was successful!'
  When -1 Then 'Categories Delete failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vCategories Where CategoryID = 1;
go

--{ IMPORTANT!!! }--
-- To get full credit, your script must run without having to highlight individual statements!!!  

/***************************************************************************************/
