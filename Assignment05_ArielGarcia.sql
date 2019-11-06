--*************************************************************************--
-- Title: Assignment05
-- Author: Ariel Garcia
-- Desc: This file demonstrates how to use Joins and Subqueiers
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--**************************************************************************--
Use Master;
go

If Exists(Select Name From SysDatabases Where Name = 'Assignment05DB_ArielGarcia')
 Begin 
  Alter Database [Assignment05DB_ArielGarcia] set Single_user With Rollback Immediate;
  Drop Database Assignment05DB_ArielGarcia;
 End
go

Create Database Assignment05DB_ArielGarcia;
go

Use Assignment05DB_ArielGarcia;
go

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
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
UNIOn
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
-- Question 1 (10 pts): How can you show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Select CategoryName as 'Category Name', ProductName as 'Product Name', UnitPrice as 'Unit Price'
From Categories Join Products
On Categories.CategoryID = Products.CategoryID
Order By [Category Name], ProductName

-- Question 2 (10 pts): How can you show a list of Product name 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Select InventoryDate as 'Inventory Date', ProductName as 'Product Name', [Count] as 'Count'
From Inventories Join Products
On Inventories.ProductID = Products.ProductID
Order By ProductName, InventoryDate, [Count] 

-- Question 3 (10 pts): How can you show a list of Inventory Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

Select InventoryDate as 'Inventory Date', [Employee Name] = Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName 
From Inventories Join Employees
On Inventories.EmployeeID = Employees.EmployeeID
Group By InventoryDate, EmployeeFirstName, EmployeeLastName
Order By InventoryDate


-- Question 4 (10 pts): How can you show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Select CategoryName as 'Category Name', ProductName as 'Product Name',InventoryDate as 'Inventory Date', [Count] as 'Count'
From Categories Join Products
On Categories.CategoryID = Products.CategoryID
Join Inventories
On Products.ProductID = Inventories.ProductID
Order By CategoryName, ProductName, [Inventory Date], [Count]

-- Question 5 (20 pts): How can you show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Select CategoryName as 'Category Name', ProductName as 'Product Name', InventoryDate as 'Inventory Date', [Count] as 'Count', [Employee Name] = Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName
From Categories Join Products
On Categories.CategoryID = Products.CategoryID
Join Inventories
On Products.ProductID = Inventories.ProductID
Join Employees
On Inventories.EmployeeID = Employees.EmployeeID
Order By  [Inventory Date],CategoryName, [Employee Name]

-- Question 6 (20 pts): How can you show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
-- For Practice; Use a Subquery to get the ProductID based on the Product Names 
-- and order the results by the Inventory Date, Category, and Product!

Select CategoryName as 'Category Name', ProductName as 'Product Name', InventoryDate as 'Inventory Date', [Count] as 'Count', [Employee Name] = Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName
From Categories Join Products
On Categories.CategoryID = Products.CategoryID
Join Inventories
On Products.ProductID = Inventories.ProductID
Join Employees
On Inventories.EmployeeID = Employees.EmployeeID
Where Products.ProductID =(Select ProductID  from Products where ProductName ='Chai') or Products.ProductID =(Select ProductID  from Products where ProductName ='Chang')
Order By  [Inventory Date],CategoryName, [Employee Name]

-- Question 7 (20 pts): How can you show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- After a long search and overcoming the common layers of bureaucracy of this business I managed 
-- to find the names of the managers of these Employees on Employees Table ;-P
-- The solution to this question has made me realize that it's a good idea to have a Managers Table so here we go.

Create Table Managers --First we create the table
([ManagerID] [int] NOT NULL 
,[ManagerFirstName] [nvarchar](100) NOT NULL
,[ManagerLastName] [nvarchar](100) NOT NULL 
);
go
Begin -- Second we Add necessary constraints for making the table usable by users 
	Alter Table Managers
	 Add Constraint pkManagers 
	  Primary Key (ManagerID);	
End
go

Insert Into Managers -- Insert data into Table 
(ManagerID, ManagerFirstName, ManagerLastName)
Values	(2, 'Joseph', 'Smith'),
		(5, 'Michael', 'Overton');

Select * From Managers -- check check!
go

--now we can solve the Question 7

Select [Employee Name] = Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName, [Manager Name] =Managers.ManagerFirstName+' '+Managers.ManagerLastName
from Employees Join Managers
On Employees.ManagerID = Managers.ManagerID
Order by [Manager Name]



/***************************************************************************************/