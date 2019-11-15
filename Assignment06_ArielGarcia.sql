--*************************************************************************--
-- Title: Assignment06
-- Author: Ariel Garcia
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_ArielGarcia')
	 Begin 
	  Alter Database [Assignment06DB_ArielGarcia] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_ArielGarcia;
	 End
	Create Database Assignment06DB_ArielGarcia;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_ArielGarcia;

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
,[UnitPrice] [mOney] NOT NULL
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
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5 pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

Create View dbo.vCategories
With Schemabinding 
As 
Select CategoryID, CategoryName
From dbo.Categories
Go

Create View dbo.vProducts
With Schemabinding 
As 
Select  ProductID, ProductName, CategoryID, UnitPrice
From dbo.Products
Go

Create View dbo.vInventories
With Schemabinding 
As 
Select  InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
From dbo.Inventories
Go

Create View dbo.vEmployees
With Schemabinding 
As 
Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
From dbo.Employees
Go

-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On dbo.Categories to Public;
Grant Select On dbo.vCategories to Public;
Deny Select On dbo.Products to Public;
Grant Select On dbo.vProducts to Public;
Deny Select On dbo.Inventories to Public;
Grant Select On dbo.vInventories to Public;
Deny Select On dbo.Employees to Public;
Grant Select On dbo.vEmployees to Public;

-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Create or Alter View dbo.vProductsByCategories
With Schemabinding 
As
Select Top 100000000
CategoryName as 'Category Name', ProductName as 'Product Name', UnitPrice as 'Unit Price'
From dbo.vCategories Join dbo.vProducts
On vCategories.CategoryID = vProducts.CategoryID
Order By [Category Name], ProductName

Grant Select On dbo.vProductsByCategories to Public;


-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create or Alter View dbo.vInventoriesByProductsByDates
With Schemabinding
As
Select Top 100000000
InventoryDate as 'Inventory Date', ProductName as 'Product Name', [Count] as 'Count'
From dbo.vInventories Join dbo.vProducts
On vInventories.ProductID = vProducts.ProductID
Order By ProductName, InventoryDate, [Count] 

Grant Select On dbo.vInventoriesByProductsByDates to Public;

-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

Create or Alter View dbo.vInventoriesByEmployeesByDates
With Schemabinding
As
Select Top 100000000
InventoryDate as 'Inventory Date', [Employee Name] = vEmployees.EmployeeFirstName + ' ' + vEmployees.EmployeeLastName 
From dbo.vInventories Join dbo.vEmployees
On vInventories.EmployeeID = vEmployees.EmployeeID
Group By InventoryDate, EmployeeFirstName, EmployeeLastName
Order By InventoryDate

Grant Select On dbo.vInventoriesByEmployeesByDates to Public; 

-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Create or Alter View dbo.vInventoriesByProductsByCategories
With Schemabinding 
As
Select Top 100000000
CategoryName as 'Category Name', ProductName as 'Product Name',InventoryDate as 'Inventory Date', [Count] as 'Count'
From dbo.vCategories Join dbo.vProducts
On vCategories.CategoryID = vProducts.CategoryID
Join dbo.vInventories
On vProducts.ProductID = vInventories.ProductID
Order By CategoryName, ProductName, [Inventory Date], [Count]

Grant Select On dbo.vInventoriesByProductsByCategories to Public;

-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create or Alter View dbo.vInventoriesByProductsByEmployees
With Schemabinding 
As 
Select Top 100000000
CategoryName as 'Category Name', ProductName as 'Product Name', InventoryDate as 'Inventory Date', [Count] as 'Count', [Employee Name] = vEmployees.EmployeeFirstName + ' ' + vEmployees.EmployeeLastName
From dbo.vCategories Join dbo.vProducts
On vCategories.CategoryID = vProducts.CategoryID
Join dbo.vInventories
On vProducts.ProductID = vInventories.ProductID
Join dbo.vEmployees
On vInventories.EmployeeID = vEmployees.EmployeeID
Order By  [Inventory Date],CategoryName, [Employee Name]

Grant Select On dbo.vInventoriesByProductsByEmployees to Public;

-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create View dbo.vInventoriesForChaiAndChangByEmployees
With Schemabinding 
As 
Select Top 100000000
CategoryName as 'Category Name', ProductName as 'Product Name', InventoryDate as 'Inventory Date', [Count] as 'Count', [Employee Name] = vEmployees.EmployeeFirstName + ' ' + vEmployees.EmployeeLastName
From dbo.vCategories Join dbo.vProducts
On vCategories.CategoryID = vProducts.CategoryID
Join dbo.vInventories
On vProducts.ProductID = vInventories.ProductID
Join dbo.vEmployees
On vInventories.EmployeeID = vEmployees.EmployeeID
Where vProducts.ProductID =(Select ProductID  from dbo.vProducts where ProductName ='Chai') or vProducts.ProductID =(Select ProductID  from dbo.Products where ProductName ='Chang')
Order By  [Inventory Date],CategoryName, [Employee Name]

Grant Select On dbo.vInventoriesForChaiAndChangByEmployees to Public;

-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Create or Alter View dbo.vEmployeesByManager
With Schemabinding 
As 
Select Top 100000000 
[Employee Name] = E1.EmployeeFirstName + ' ' + E1.EmployeeLastName, E2.ManagerID
From dbo.vEmployees as E1 join dbo.vEmployees as E2
On E1.EmployeeID=E2.EmployeeID
Group By E1.EmployeeFirstName + ' ' + E1.EmployeeLastName, E2.ManagerID
Order By ManagerID, [Employee Name]

Grant Select On dbo.vEmployeesByManager to Public;

-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

Create or Alter View vInventoriesByProductsByCategoriesByEmployees
With Schemabinding
As 
Select C.CategoryID, C.CategoryName, P.ProductID, P.ProductName, P.UnitPrice, I.InventoryID, I.InventoryDate, I.[Count], E.EmployeeID, E.EmployeeFirstName, E.EmployeeLastName, E.ManagerID 

From dbo.vCategories as C join dbo.vProducts P 
on  C.CategoryID = P.CategoryID
Join dbo.vInventories as I
On P.ProductID = I.ProductID
join dbo.vEmployees as E
On I.EmployeeID = E.EmployeeID

-- References 

--https://www.sqlhammer.com/sql-server-schemabinding/										>>> this website in my opinion explains Schemabinding very well. 
--https://stackoverflow.com/questions/14834113/creating-view-from-another-view				>>> This Website help me figure out some thing like "Create or Alter View"


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/