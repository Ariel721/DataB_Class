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

