Use Northwind
go

Select * From Northwind.Sys.Tables Where type = 'u' Order By Name;

if exists (Select Name from sysdatabases where Name = 'Mod06LabsArielGarcia')
	Begin
		Alter Database [Mod06LabsArielGarcia] set Single_user with Rollback immediate;
		Drop Database [Mod06LabsArielGarcia]
	End
go

Create Database Mod06LabsArielGarcia; 
go
Use Mod06LabsArielGarcia;
go

-- Question 1 Create a view to show a list of customers names and their locations. Use the IsNull() function to display null regions names as the name of the customers country? Call the view vCustomersByLocation.
Drop View vCustomersByLocation
Create View vCustomersByLocation
As 
	Select  ContactName as CustomerName, ISNULL (Region,'NULL') as CustomerCountry
	From Northwind.dbo.Customers
go

Select * From vCustomersByLocation Order By CustomerName
go

--Question 2: How can you create a view to show a list of customers names, their locations, and the number of orders they have placed (hint: use the count() function)? Call the view vNumberOfCustomerOrdersByLocation.

Create View vNumberOfCustomerOrdersByLocation
As 
	Select  TOP 100000000 ContactName as CustomerName, ISNULL (Region,'NULL') as CustomersCountry, COUNT(OrderID) as Orders
	From Northwind.dbo.Customers as C Join Northwind.dbo.Orders as O 
	On C.CustomerID = O.CustomerID
	Group By ContactName, Region
	Order By ContactName
go

Select * From vNumberOfCustomerOrdersByLocation Order By CustomerName;