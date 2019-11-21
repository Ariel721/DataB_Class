--*************************************************************************--
-- Title: Assignment07
-- Author: ArielGarcia
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,ArielGarcia,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_ArielGarcia')
	 Begin 
	  Alter Database [Assignment07DB_ArielGarcia] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_ArielGarcia;
	 End
	Create Database Assignment07DB_ArielGarcia;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_ArielGarcia;

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
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
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
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

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
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
------------------------------------------------------------------------------------------'
-- Question 1 (5 pts): What function can you use to show a list of Product names, 
-- and the price of each product, with the price formatted as US dollars?
-- Order the result by the Product!

Select ProductName, Format (UnitPrice, 'C')
From dbo.vProducts
Order By ProductName

-- Question 2 (10 pts): What function can you use to show a list of Category and Product names, 
-- and the price of each product, with the price formatted as US dollars?
-- Order the result by the Category and Product!

Select CategoryName, ProductName, Format (UnitPrice,'C')
From dbo.vCategories Join dbo.vProducts
On vCategories.CategoryID = vProducts.CategoryID
Order By CategoryName, ProductName

-- Question 3 (10 pts): What function can you use to show a list of Product names, 
-- each Inventory Date, and the Inventory Count, with the date formatted like January, 2017?
-- Order the results by the Product, Date, and Count!
;
Select ProductName, Datename (mm,InventoryDate)+', '+ DateName (yy,InventoryDate) as InventoryDate, [Count] as InventoryCount 
From dbo.vInventories Join dbo.vProducts
On vInventories.ProductID = vProducts.ProductID
Order By ProductName, InventoryDate, [Count]

-- Question 4 (10 pts): How can you CREATE A VIEW called vProductInventories 
-- That shows a list of Product names, each Inventory Date, and the Inventory Count, 
-- with the date FORMATTED like January, 2017?
-- Order the results by the Product, Date, and Count!

Create -- Drop
View vProductInventories
As
Select Top 100000000
ProductName, Datename (mm,InventoryDate)+', '+ DateName (yy,InventoryDate) as InventoryDate, [Count] as InventoryCount 
From dbo.vInventories Join dbo.vProducts
On vInventories.ProductID = vProducts.ProductID
Order By ProductName, cast (Datename (mm,InventoryDate)+', '+ DateName (yy,InventoryDate) as date), [Count]

-- Check that it works: Select * From vProductInventories;

-- Question 5 (15 pts): How can you CREATE A VIEW called vCategoryInventories 
-- that shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY, 
-- with the date FORMATTED like January, 2017?
Create -- Drop
View vCategoryInventories
As
Select Top 100000000
CategoryName, Datename (mm,InventoryDate)+', '+ DateName (yy,InventoryDate) as InventoryDate, Sum ([Count]) as 'Count'
From dbo.vCategories Join dbo.vProducts
On dbo.vCategories.CategoryID = dbo.vProducts.CategoryID
Join dbo.vInventories
On dbo.vProducts.ProductID = vInventories.ProductID
Group by  InventoryDate,CategoryName


-- Check that it works: Select * From vCategoryInventories;

-- Question 6 (10 pts): How can you CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts
-- to show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count?
-- Use function to set any null counts to zero. Order the results by the Product, Date, and Count
-- This new view must use your vProductInventories view!

Create -- Drop
View vProductInventoriesWithPreviousMonthCounts
As
Select  Top 100000000
ProductName, InventoryDate, InventoryCount, Isnull (Lag(InventoryCount) Over (Order by month(InventoryDate )),0) as PreviousMonthCount
From vProductInventories
Order By ProductName

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;


-- Question 7 (15 pts): How can you CREATE one more VIEW 
-- called vProductInventoriesWithPreviousMonthCountsWithKPIs
-- to show a list of Product names, Inventory Dates, Inventory Count, the Previous Month Count
-- and a KPI that displays an increased count as 1, a same count as 0, and a decreased count as -1?
-- Use a function to set any null counts to zero. Order the results by the Product, Date, and Count!
-- This new view must use your vProductInventoriesWithPreviousMonthCounts view!
Create -- Drop
View vProductInventoriesWithPreviousMonthCountsWithKPIs
AS
Select Top 100000000
ProductName, InventoryDate, InventoryCount, Isnull (Lag(InventoryCount) Over (Order by month(InventoryDate )),0) as PreviousMonthCount, 
(Select Case
        When InventoryCount > PreviousMonthCount Then '1'
		When InventoryCount = PreviousMonthCount Then '0'
		When InventoryCount < PreviousMonthCount Then '-1'
        End
 )as KPI 
from vProductInventoriesWithPreviousMonthCounts
Order By ProductName

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;


-- Question 8 (25 pts): How can you CREATE a User Defined Function (UDF) 
-- called fProductInventoriesWithPreviousMonthCountsWithKPIs
-- to show a list of Product names, Inventory Dates, Inventory Count, the Previous Month Count
-- and a KPI that displays an increased count as 1, a same count as 0, and a decreased count as -1
-- AND the result can show only KPIs with a value of either 1, 0, or -1?
-- This new function must use your vProductInventoriesWithPreviousMonthCountsWithKPIs view!

Create -- Drop
Function fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPI varchar(50))
	Returns Table
	as
	Return (Select * from vProductInventoriesWithPreviousMonthCountsWithKPIs
			Where KPI=@KPI


	)



/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1) Order By 1,2,3;
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0) Order By 1,2,3;
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1) Order By 1,2,3;
*/
/***************************************************************************************/