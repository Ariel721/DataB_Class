use master;
go
--drop database Ariel_Garcia_Mod2_Lab2;
go
use Northwind;
go
SELECT * From Customers;

SELECT 
CompanyName,
ContactName,
Phone, 
GETDATE() 
from Customers 
Where 
(CustomerID ='EASTC'
or
CustomerID = 'DUMON'
);
--with alias
SELECT 
CompanyName,
ContactName,
Phone, 
[Date] = GETDATE() --Alias here
from Customers 
Where 
(CustomerID ='EASTC'
or
CustomerID = 'DUMON'
);

SELECT AVG(UnitPrice) 'Average Sales Price' From [Order Details];

SELECT ProductName FROM Products;

-- Using 2 tables (The Improved ANSI way)      
SELECT ProductName, CategoryName
 FROM Products JOIN Categories
  ON Products.CategoryId = Categories.CategoryId

--(Table Aliases)--
-- Alias can be used to rename a table names in the query.
SELECT ProductName, CategoryName
 FROM Products as P JOIN Categories as C   -- *******Ask instructor*******--
  ON P.CategoryId = C.CategoryId;


-- SELECT Pub_id, Type, Title_id, Price FROM Pubs..Titles
  --ORDER BY Pub_id DESC, Type, Price;                                  *******Ask instuctor*******

SELECT * FROM [Order Details];
SELECT OrderID, ProductID, UnitPrice From [Order Details] ORDER BY OrderID ASC,ProductID;

SELECT ProductName, [Quantity Sum] = Sum(Quantity) --< Does this 3rd and 5th 
FROM[Order Details] JOIN Products --< Does this 1st  
 ON [Order Details].ProductID = Products.ProductID
Where Quantity > 10 --< Does this 2nd
Group By ProductName --< Does this 3rd
  Having Sum(Quantity) > 200 --< Does this 4th, after the aggregation
Order By ProductName;

SELECT * FROM [Order Details] Order by Quantity;

USE pubs
Select [Date] = GetDate(), [Price]=IsNull(Price, 0), Title
 From Pubs.dbo.Titles;

 Select 
  Cast(GetDate() as Date) as [TodaysDate]
, IsNull(Price, 0) as [CurrentPrice]
, IsNull(Cast(Price as varchar(50)), 'Not For Sale!') as [CurrentPriceAsTEXT]
, Title
 From Pubs.dbo.Titles
Go

SELECT Stor_id, Title_id, SUM(qty) AS 'Quantity'
  FROM Pubs.dbo.Sales
  GROUP BY Stor_id,Title_id
    WITH Cube 

