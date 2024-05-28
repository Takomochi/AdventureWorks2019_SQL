-- Basic Aggregations

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