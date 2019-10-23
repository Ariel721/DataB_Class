--*************************************************************************--
-- Title: Assignment03
-- Author: Ariel Garcia
-- Desc: This file demonstrates how to select data from a database
-- Change Log: When,Who,What
-- 2017-01-01, Ariel Garcia, Created File
--**************************************************************************--
Use Master;
go

If Exists(Select Name from SysDatabases Where Name = 'Assignment03DB_ArielGarcia')
 Begin 
  Alter Database [Assignment03DB_ArielGarcia] set Single_user With Rollback Immediate;
  Drop Database Assignment03DB_ArielGarcia;
 End
go

Create Database Assignment03DB_ArielGarcia;
go

Use Assignment03DB_ArielGarcia;
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
,[UnitPrice] [money] NOT NULL
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Alter Table Categories 
 Add Constraint pkCategories 
  Primary Key (CategoryId);
go

Alter Table Categories 
 Add Constraint ukCategories 
  Unique (CategoryName);
go

Alter Table Products 
 Add Constraint pkProducts 
  Primary Key (ProductId);
go

Alter Table Products 
 Add Constraint ukProducts 
  Unique (ProductName);
go

Alter Table Products 
 Add Constraint fkProductsToCategories 
  Foreign Key (CategoryId) References Categories(CategoryId);
go

Alter Table Products 
 Add Constraint ckProductUnitPriceZeroOrHigher 
  Check (UnitPrice >= 0);
go

Alter Table Inventories 
 Add Constraint pkInventories 
  Primary Key (InventoryId);
go

Alter Table Inventories
 Add Constraint dfInventoryDate
  Default GetDate() For InventoryDate;
go

Alter Table Inventories
 Add Constraint fkInventoriesToProducts
  Foreign Key (ProductId) References Products(ProductId);
go

Alter Table Inventories 
 Add Constraint ckInventoryCountZeroOrHigher 
  Check ([Count] >= 0);
go

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

Insert Into Inventories
(InventoryDate, ProductID, [Count])
Select '20170101' as InventoryDate, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
UNION
Select '20170201' as InventoryDate, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
UNION
Select '20170302' as InventoryDate, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show all of the data in the Categories, Products, and Inventories Tables
Select * from Categories;
go
Select * from Products;
go
Select * from Inventories;
go

/********************************* Questions and Answers *********************************/
-- Question 1 (5 pts): Select the Category Id and Category Name of the Category 'Seafood'.
Select CategoryID,CategoryName
From Categories
Where CategoryName ='Seafood';
go

-- Question 2 (5 pts):  Select the Product Id, Product Name, and Product Price 
-- of all Products with the Seafood's Category Id. Ordered By the Products Price
-- highest to the lowest 
Select ProductID, ProductName,UnitPrice
From Products
where CategoryID=(Select CategoryID From Categories Where CategoryName ='Seafood')
Order by UnitPrice Desc; 
go

-- Question 3 (5 pts):  Select the Product Id, Product Name, and Product Price 
-- Ordered By the Products Price highest to the lowest. 
-- Show only the products that have a price Greater than $100. 
Select ProductID, ProductName,UnitPrice
From Products
where UnitPrice > 100
Order by UnitPrice Desc;
go

-- Question 4 (10 pts): Select the CATEGORY NAME, product name, and Product Price 
-- from both Categories and Products. Order the results by Category Name 
-- and then Product Name, in alphabetical order
-- (Hint: Join Products to Category)
Select  CategoryName, ProductName, UnitPrice
 From Products JOIN Categories
  On Products.CategoryId = Categories.CategoryId
  Order by CategoryName,ProductName; 
go

-- Question 5 (5 pts): Select the Product Id and Number of Products in Inventory
-- for the Month of JANUARY. Order the results by the ProductIDs 
Select ProductID,[Count]
From Inventories
Where InventoryDate Like '%-01-%' -- I believe this is the best metod (for the month only) I could have use date ranges but that would constrain results to the month of january of a explicit year (per my current SQL code ability).
order by ProductID Asc;   
go

-- Question 6 (10 pts): Select the Category Name, Product Name, and Product Price 
-- from both Categories and Products. Order the results by price highest to lowest.
-- Show only the products that have a PRICE FROM $10 TO $20. 
Select CategoryName, ProductName, UnitPrice
 From Products JOIN Categories
  On Products.CategoryId = Categories.CategoryId
  where UnitPrice>=10 and UnitPrice<=20
  Order by UnitPrice Desc;  
go

-- Question 7 (10 pts) Select the Product Id and Number of Products in Inventory
-- for the Month of JANUARY. Order the results by the ProductIDs
-- and where the ProductID are only the ones in the seafood category
-- (Hint: Use a subquery to get the list of productIds with a category ID of 8)
Select ProductID,[Count]
From Inventories
Where InventoryDate Like '%-01-%' and ProductID in (Select ProductID From Products Where CategoryID=8)
order by ProductID Asc;   
go

-- Question 8 (10 pts) Select the PRODUCT NAME and Number of Products in Inventory
-- for the Month of January. Order the results by the Product Names
-- and where the ProductID as only the ones in the seafood category
-- (Hint: Use a Join between Inventories and Products to get the Name)
Select ProductName, [Count]
 From Products JOIN Inventories
  On Products.ProductID = Inventories.ProductID
  where InventoryDate Like '%-01-%' and Products.ProductID in (Select ProductID From Products Where CategoryID=8)
  Order by ProductName;  
go 


-- Question 9 (10 pts) Select the Product Name and Number of Products in Inventory
-- for both JANUARY and FEBURARY. Show what the MAXIMUM AMOUNT IN INVENTORY was 
-- and where the ProductID as only the ones in the seafood category
-- and Order the results by the Product Names. 
-- (Hint: If Jan count was 5, but Feb count was 15, show 15)
Select ProductName, Max([Count]) as MaxAmountInventory
 From Products JOIN Inventories
  On Products.ProductID = Inventories.ProductID
  where (InventoryDate Like '%-01-%' or InventoryDate Like '%-02-%') and Products.ProductID in (Select ProductID From Products Where CategoryID=8)
  Group By ProductName
  Order by ProductName;
 go 
 
 -- notes for ; very iportant learnt group by often goes together with Aggregate Functions
 -- Test code notes: add columns InventoryDate and CategoryID  for verification || Eliminate Max aggregate and Group by

-- Question 10 (10 pts) Select the Product Name and Number of Products in Inventory
-- for both JANUARY and FEBURARY. Show what the MAX AMOUNT IN INVENTORY was 
-- and where the ProductID as only the ones in the seafood category
-- and Order the results by the Product Names. 
-- Restrict the results to rows with a MAXIMUM COUNT OF 10 OR HIGHER

Select ProductName, Max([Count]) as MaxAmountInventory 
 From Products JOIN Inventories  
  On Products.ProductID = Inventories.ProductID 
  where (InventoryDate Like '%-01-%' or InventoryDate Like '%-02-%') and Products.ProductID in (Select ProductID From Products Where CategoryID=8)
  Group by ProductName
  Having Max([Count])>=10
  Order by ProductName;
 go

-- Question 11 (20 pts) Select the CATEGORY NAME, Product Name and Number of Products in Inventory
-- for both JANUARY and FEBURARY. Show what the MAX AMOUNT IN INVENTORY was 
-- and where the ProductID as only the ones in the seafood category
-- and Order the results by the Product Names. 
-- Restrict the results to rows with a maximum count of 10 or higher
Select CategoryName, ProductName, Max([Count]) as MaxAmountInventory 
 From Products JOIN Inventories  
  On Products.ProductID = Inventories.ProductID JOIN Categories 
  On Products.CategoryID = Categories.CategoryID
  where (InventoryDate Like '%-01-%' or InventoryDate Like '%-02-%') and Products.ProductID in (Select ProductID From Products Where CategoryID=8)
  Group by ProductName , CategoryName
  Having Max([Count])>=10
  Order by ProductName;
 go

/***************************************************************************************/