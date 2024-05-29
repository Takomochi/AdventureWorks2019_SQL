-- 1. Total Sales Amount for each year
SELECT 
	YEAR(OrderDate) as YearOfOrder,
	SUM(SubTotal) as Sales 
FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]
GROUP BY YEAR(OrderDate)
Order by YEAR(OrderDate); 

-- 2. Sales Amount by Product category & Product Subcategory in 2014
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

-- 3. Total Sales Amount By Sales Person for Each Year 
-- Also, compare the sales from the previous year. 
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

  -- 4. Identify customers who have completed their first order and OrderDate. 
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

-- Let's verify! CustomerID = 11001 & OrderDate: 2011-06-21 00:00:00.000
SELECT 
	OrderDate, 
	CustomerID, 
	TotalDue, 
	ShipDate, 
	ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY OrderDate ASC) as OrderNum
FROM [AdventureWorks2019].[Sales].[SalesOrderHeader] 
WHERE CustomerID = 11001
ORDER BY OrderDate ASC;


-- 5. Employees Eligible for Promotion 
-- Employees who have been with the company for more than 5 years. 
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

-- 6. Is there a customer without Order? 
SELECT 
	CS.CustomerID
FROM SALES.SalesOrderHeader AS SOH
LEFT JOIN SALES.Customer AS CS 
ON CS.CustomerID = SOH.CustomerID
WHERE SOH.CustomerID IS NULL;
