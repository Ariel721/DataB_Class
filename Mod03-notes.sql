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
SELECT OrderID, ProductID, UnitPrice From [Order Details] ORDER BY OrderID DESC,ProductID;


