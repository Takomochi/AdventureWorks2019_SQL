# AdventureWorks2019_SQL
 
## Overview of the project
This project aims to demonstrate basic to advanced SQL queries.

## Resource
Microsoft Sample Database - AdventureWorks2019

## SQL Questions
Q1. 1.Total Sales Amount for each year <br>
```
SELECT 
	YEAR(OrderDate) as YearOfOrder,
	SUM(SubTotal) as Sales 
FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]
GROUP BY YEAR(OrderDate)
Order by YEAR(OrderDate); 
```
![alt text](https://github.com/Takomochi/AdventureWorks2019_SQL/blob/main/images/result_01_01.png?raw=true)

Q1. 2. If we want to see the sales growth of each year, we can use the LAG function and calculate the sales difference from the previous year.
```
WITH TOTAL_SALES_BY_YEAR AS 
(
SELECT 
	YEAR(OrderDate) as YearOfOrder,
	SUM(SubTotal) as Sales 
FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]
GROUP BY YEAR(OrderDate)
) 
SELECT  
	YearOfOrder,
    Sales, 
	LAG(Sales, 1, 0) OVER(ORDER BY YearOfOrder) as PreviousYearSales, 
	Sales - LAG(Sales, 1, 0) OVER(ORDER BY YearOfOrder) AS SALES_DIFF
FROM TOTAL_SALES_BY_YEAR
ORDER BY YearOfOrder
```
![alt text](https://github.com/Takomochi/AdventureWorks2019_SQL/blob/main/images/result_01_02.png?raw=true)

Q2. Sales Amount by Product Subcategory in 2014 <br>
```
SELECT	
	PC.Name AS ProductName, 
	PSC.Name AS ProductSubCategoryName, 
	Round(SUM(SOD.OrderQty * SOD.UnitPrice), 2) AS TotalSales
FROM [AdventureWorks2019].[Sales].[SalesOrderDetail] AS SOD
JOIN [AdventureWorks2019].[Sales].[SalesOrderHeader] AS SOH
	ON SOD.SalesOrderID = SOH.SalesOrderID
JOIN [AdventureWorks2019].[Production].[Product] AS PC
	ON SOD.ProductID = PC.ProductID 
JOIN [AdventureWorks2019].[Production].[ProductSubcategory] AS PSC
	ON PSC.ProductSubcategoryID = PC.ProductSubcategoryID
WHERE 1=1
AND SOH.OrderDate >= '2014-01-01'
GROUP BY PC.Name, PSC.Name
ORDER BY SUM(SOD.OrderQty * SOD.UnitPrice) DESC;
```
It is obvious that the category "Mountain bikes" has the top sales. 
![alt text](https://github.com/Takomochi/AdventureWorks2019_SQL/blob/main/images/result_02.png?raw=true)

Q3. Total Sales Amount By Sales Person for Each Year Also, compare the sales from the previous year. <br>
```
WITH SalesByPerson AS 
  (
  SELECT 
    YEAR(SOH.OrderDate) AS OrderYear, 
	EMP.BusinessEntityID AS SalesPersonID, 
	CONCAT(P.FirstName, ' ', P.LastName) AS PersonName,
	SUM(SOH.SubTotal) AS TotalSales
  FROM [AdventureWorks2019].[Sales].[SalesOrderHeader] AS SOH 
  JOIN [AdventureWorks2019].[HumanResources].[Employee] AS EMP
	ON SOH.SalesPersonID = EMP.BusinessEntityID
  JOIN [AdventureWorks2019].[Person].[Person] AS P 
	ON P.BusinessEntityID = EMP.BusinessEntityID
  WHERE 1=1
  GROUP BY YEAR(SOH.OrderDate), EMP.BusinessEntityID, CONCAT(P.FirstName, ' ', P.LastName)
  )
  SELECT 
	*, 
	LAG(TotalSales) OVER(PARTITION BY SalesPersonID ORDER BY OrderYear) AS PreviousYearSales, 
	TotalSales - LAG(TotalSales) OVER(PARTITION BY SalesPersonID ORDER BY OrderYear) AS FromPreviousYearSales
  FROM SalesByPerson
  ORDER BY SalesPersonID, OrderYear;
```
![alt text](https://github.com/Takomochi/AdventureWorks2019_SQL/blob/main/images/result_03.png?raw=true)

Q4. 1.Identify customers who have completed their first order and OrderDate <br>
```
WITH ORDERS AS 
(
SELECT 
	OrderDate, 
	CustomerID, 
	TotalDue, 
	ShipDate, 
	ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY OrderDate) as OrderNum
FROM [AdventureWorks2019].[Sales].[SalesOrderHeader] 
) 
SELECT 
	* 
FROM ORDERS 
WHERE 1=1
AND OrderNum = 1;
```
![alt text](https://github.com/Takomochi/AdventureWorks2019_SQL/blob/main/images/result_04_01.png?raw=true)

Q4. 2. Let's verify! CustomerID = 11001 & OrderDate: 2011-06-17
```
SELECT 
	OrderDate, 
	CustomerID, 
	TotalDue, 
	ShipDate, 
	ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY OrderDate ASC) as OrderNum
FROM [AdventureWorks2019].[Sales].[SalesOrderHeader] 
WHERE CustomerID = 11001
ORDER BY OrderDate ASC;
```
We can see that CustomerID = 11001's first order is 2011-06-17, and the total amount is $3729.364.
![alt text](https://github.com/Takomochi/AdventureWorks2019_SQL/blob/main/images/result_04_02.png?raw=true)

Q5. Employees who have been with the company more than 5 years <br>
```
SELECT 
  EMP.BusinessEntityID, 
  P.FirstName, 
  P.LastName, 
  EMP.HireDate,
  DATEDIFF(year, EMP.HireDate, GETDATE()) AS YearsWithCompany
FROM 
   [AdventureWorks2019].[HumanResources].[Employee] AS EMP
JOIN [AdventureWorks2019].[Person].[Person] AS P 
  	ON EMP.BusinessEntityID = P.BusinessEntityID
WHERE 
  DATEDIFF(year, EMP.HireDate, GETDATE()) > 5;
```
![alt text](https://github.com/Takomochi/AdventureWorks2019_SQL/blob/main/images/result_05.png?raw=true)

Q6. Is there a customer without Order? <br>
```
SELECT 
	CS.CustomerID
FROM SALES.SalesOrderHeader AS SOH
LEFT JOIN SALES.Customer AS CS 
ON CS.CustomerID = SOH.CustomerID
WHERE SOH.CustomerID IS NULL;
```
![alt text](https://github.com/Takomochi/AdventureWorks2019_SQL/blob/main/images/result_06.png?raw=true)

Nope, there is no customer without an order. 