--*************************************************************************--
-- Title: Assignment04
-- Author: Ariel Garcia
-- Desc: This file demonstrates how to process data in a database
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--**************************************************************************--
Use Master;
go

If Exists(Select Name from SysDatabases Where Name = 'Assignment04DB_ArielGarcia')
 Begin 
  Alter Database [Assignment04DB_ArielGarcia] set Single_user With Rollback Immediate;
  Drop Database Assignment04DB_ArielGarcia;
 End
go

Create Database Assignment04DB_ArielGarcia;
go

Use Assignment04DB_ArielGarcia;
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


-- Show the Current data in the Categories, Products, and Inventories Tables
Select * from Categories;
go
Select * from Products;
go
Select * from Inventories;
go

/********************************* Questions and Answers *********************************/

-- Notes: 
-- Use the follow data to this add data to this database.
-- All answers must include the Begin Tran, Commit Tran, and Rollback Tran transaction statements. 
-- All answers must include the Try/Catch blocks around your transaction processing code.
-- Display the Error message it the catch block is envoked.

/* Add the following data to this database:
Beverages	Chai	18.00	2017-01-01	61
Beverages	Chang	19.00	2017-01-01	87
Condiments	Aniseed Syrup	10.00	2017-01-01	19
Condiments	Chef Anton's Cajun Seasoning	22.00	2017-01-01	81

Beverages	Chai	18.00	2017-02-01	13
Beverages	Chang	19.00	2017-02-01	2
Condiments	Aniseed Syrup	10.00	2017-02-01	1
Condiments	Chef Anton's Cajun Seasoning	22.00	2017-02-01	79

Beverages	Chai	18.00	2017-03-02	18
Beverages	Chang	19.00	2017-03-02	12
Condiments	Aniseed Syrup	10.00	2017-03-02	84
Condiments	Chef Anton's Cajun Seasoning	22.00	2017-03-02	72
*/

Select * from Categories;
go
Select * from Products;
go
Select * from Inventories;
go

-- Question 1 (20 pts): Add data to the Categories table
Begin Try
	Begin Tran
		Insert Into Categories (CategoryName) Values
		 ('Beverages'),('Condiments');	
	Commit Tran 
End Try
Begin Catch
	Rollback Tran
	Print 'There was an error. Please double check your input data'
	Print Error_Message() 
End Catch
go

Select @@TRANCOUNT as 'Pending Trans'; --checking code
go

-- Question 2 (20 pts): Add data to the Products table
Begin Try
	Begin Tran
		Insert Into Products(ProductName,CategoryID,UnitPrice) Values 
		('Chai', (Select CategoryID From Categories Where CategoryName='Beverages'), 18.00),
		('Chang', (Select CategoryID From Categories Where CategoryName='Beverages'), 19.00),
		('Aniseed Syrup', (Select CategoryID From Categories Where CategoryName='Condiments'), 10.00),
		('Chef Anton''s Cajun Seasoning', (Select CategoryID From Categories Where CategoryName='Condiments'), 22.00);
	Commit tran
End Try
Begin Catch
	Rollback Tran
	Print 'There was an error. Please double check your input data'
	Print Error_Message()
End Catch
go

-- Question 3 (20 pts): Add data to the Inventories table
Begin Try
	Begin Tran
		Insert Into Inventories(InventoryDate, ProductID,[Count]) Values
		('2017-01-01',(Select ProductID From Products Where ProductName='Chai'),61),
		('2017-01-01',(Select ProductID From Products Where ProductName='Chang'),87),
		('2017-01-01',(Select ProductID From Products Where ProductName='Aniseed Syrup'),19),
		('2017-01-01',(Select ProductID From Products Where ProductName='Chef Anton''s Cajun Seasoning'),81),
		('2017-02-01',(Select ProductID From Products Where ProductName='Chai'),13),
		('2017-02-01',(Select ProductID From Products Where ProductName='Chang'),2),
		('2017-02-01',(Select ProductID From Products Where ProductName='Aniseed Syrup'),1),
		('2017-02-01',(Select ProductID From Products Where ProductName='Chef Anton''s Cajun Seasoning'),79),
		('2017-03-01',(Select ProductID From Products Where ProductName='Chai'),18),
		('2017-03-01',(Select ProductID From Products Where ProductName='Chang'),12),
		('2017-03-01',(Select ProductID From Products Where ProductName='Aniseed Syrup'),84),
		('2017-03-01',(Select ProductID From Products Where ProductName='Chef Anton''s Cajun Seasoning'),72);
	Commit Tran
End Try
Begin Catch
	Rollback Tran
	Print 'There was an error. Please double check your input data'
	Print Error_Message()
End Catch
go 

Select @@TRANCOUNT as 'Pending Trans'; --checking code... However Try/catch would have caught errors and rolled back transactions 
go
-- Question 4 (10 pts): Write code to update the Category "Beverages" to "Drinks"
Begin Try
	Begin Tran
		Update Categories Set CategoryName = 'Drinks' Where CategoryID = 1;
	Commit Tran
End Try
Begin Catch
	Rollback Tran
	Print 'There was an error. Please double check your input data'
	Print Error_Message()
End Catch

/*Select * from Categories Order by CategoryID ;
go
Select * from Products Order by ProductID ;
go
Select * from Inventories Order by ProductID ;
go*/

Select @@TRANCOUNT as 'Pending Trans'; --checking code... However Try/catch would have caught errors and rolled back transactions 
go
-- Question 5 (30 pts): Write code to delete all Condiments data from the database (in all three tables!) 

Begin Try -- Inventories Has FK that links to Product wich has FK that links to Categories so Data from Inventories has to be deleted first 
	Begin Tran
		Delete from Inventories Where ProductID =3 or ProductID=4;
	Commit Tran
End Try
Begin Catch 
	Rollback Tran
		Print 'There was an error. Please double check your input data'
		Print Error_Message()
End Catch
go

Begin Try --Product has FK that links to Categories so Data from Products has to be deleted second 
	Begin Tran		
		Delete from Products Where CategoryID = (Select CategoryID From Categories Where CategoryName='Condiments');
	Commit Tran
End Try
Begin Catch 
	Rollback Tran
		Print 'There was an error. Please double check your input data'
	Print Error_Message()
End Catch
go

Begin Try -- and third you can delete data from Categories table 
	Begin Tran
		Delete from Categories Where CategoryName = 'Condiments';
	Commit Tran
End Try
Begin Catch 
	Rollback Tran
		Print 'There was an error. Please double check your input data'
		Print Error_Message()
End Catch
go	

Select @@TRANCOUNT as 'Pending Trans'; --checking code... However Try/catch would have caught errors and rolled back transactions 
go
 
	

/***************************************************************************************/

