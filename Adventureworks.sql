#Create Database Adventureworks
create database adventureworks;
use adventureworks;

#Append Sales Table

CREATE TABLE master_sales AS
SELECT * FROM FactInternetSales
WHERE 1 = 0;

INSERT INTO master_sales
SELECT * FROM FactInternetSales;

INSERT INTO master_sales
SELECT * FROM Fact_Internet_Sales_New;

select * from master_sales;

#Merge Products Tables

CREATE TABLE master_products AS
SELECT 
    p.ProductKey,
    p.ProductAlternateKey,
    p.EnglishProductName,
    p.Color,
    p.StandardCost,
    p.ListPrice,
    p.Size,
    p.Weight,
    p.DaysToManufacture,
    p.ProductLine,
    p.DealerPrice,
    p.Class,
    p.Style,
    p.ModelName,
    p.EnglishDescription,
    p.Status,
    s.ProductSubcategoryKey,
    s.EnglishProductSubcategoryName,
    c.ProductCategoryKey,
    c.EnglishProductCategoryName
FROM DimProduct p
LEFT JOIN DimProductSubCategory s
    ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
LEFT JOIN DimProductCategory c
    ON s.ProductCategoryKey = c.ProductCategoryKey;

select * from master_products;

#Relationships between products tables

SELECT 
    p.ProductKey,
    p.EnglishProductName,
    p.ProductSubcategoryKey,
    sc.EnglishProductSubcategoryName,
    c.ProductCategoryKey,
    c.EnglishProductCategoryName
FROM DimProduct p
LEFT JOIN DimProductSubCategory sc 
    ON p.ProductSubcategoryKey = sc.ProductSubcategoryKey
LEFT JOIN DimProductCategory c 
    ON sc.ProductCategoryKey = c.ProductCategoryKey;

#Lookup Productname
SELECT 
    f.SalesOrderNumber,
    f.OrderDateKey,
    f.ProductKey,
    p.EnglishProductName,
    f.OrderQuantity,
    f.UnitPrice,
    f.ExtendedAmount
FROM master_sales f
LEFT JOIN DimProduct p
    ON f.ProductKey = p.ProductKey;

#Lookup Customername
SELECT 
    s.SalesOrderNumber,
    s.OrderDateKey,
    s.ProductKey,
    p.EnglishProductName,
    s.UnitPrice,
    s.CustomerKey,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerFullName,
    s.OrderQuantity,
    s.ExtendedAmount
FROM master_sales s
LEFT JOIN DimCustomer c 
    ON s.CustomerKey = c.CustomerKey
LEFT JOIN DimProduct p 
    ON s.ProductKey = p.ProductKey;
    
select * from master_sales;

#Create Date fields from Orderdatekey
SELECT 
    OrderDateKey,

    -- Convert OrderDateKey to a DATE type
    STR_TO_DATE(OrderDateKey, '%Y%m%d') AS OrderDate,

    -- A. Year
    YEAR(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS Year,

    -- B. Month Number
    MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS MonthNo,

    -- C. Full Month Name
    MONTHNAME(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS MonthFullName,

    -- D. Quarter (Q1, Q2, Q3, Q4)
    CONCAT('Q', QUARTER(STR_TO_DATE(OrderDateKey, '%Y%m%d'))) AS Quarter,

    -- E. YearMonth (YYYY-MMM)
    DATE_FORMAT(STR_TO_DATE(OrderDateKey, '%Y%m%d'), '%Y-%b') AS YearMonth,

    -- F. Weekday Number (1 = Sunday, 7 = Saturday)
    DAYOFWEEK(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS WeekdayNumber,

    -- G. Weekday Name
    DAYNAME(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS WeekdayName,

    -- H. Financial Month (April = 1, ..., March = 12)
    CASE 
        WHEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) >= 4 THEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) - 3
        ELSE MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) + 9
    END AS FinancialMonth,

    -- I. Financial Quarter
    CASE 
        WHEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) BETWEEN 4 AND 6 THEN 'Q1'
        WHEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) BETWEEN 7 AND 9 THEN 'Q2'
        WHEN MONTH(STR_TO_DATE(OrderDateKey, '%Y%m%d')) BETWEEN 10 AND 12 THEN 'Q3'
        ELSE 'Q4'
    END AS FinancialQuarter

FROM 
    master_sales;


#Calculate Sales Amount, Production Cost and Profit

SELECT 
    ProductKey,
    UnitPrice,
    ProductStandardCost,
    OrderQuantity,
    UnitPriceDiscountPct,
    
    -- Sales Amount
    (UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct)) AS SalesAmount,
    
    -- Production Cost
    (ProductStandardCost * OrderQuantity) AS ProductionCost,
    
    -- Profit
   ROUND(
   (UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct)) - (ProductStandardCost * OrderQuantity), 
   2) AS Profit
   
FROM 
    master_sales;
    
#Total Sales, Production Cost and Profit

SELECT 
    ROUND(SUM(UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct)), 2) AS TotalSalesAmount,
    ROUND(SUM(ProductStandardCost * OrderQuantity), 2) AS TotalProductionCost,
    ROUND(SUM((UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct)) - (ProductStandardCost * OrderQuantity)), 2) AS TotalProfit
FROM 
    master_sales;

#Year wise 

SELECT 
    YEAR(STR_TO_DATE(OrderDateKey, '%Y%m%d')) AS SalesYear,
    
    ROUND(SUM(UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct)), 2) AS TotalSalesAmount,
    ROUND(SUM(ProductStandardCost * OrderQuantity), 2) AS TotalProductionCost,
    ROUND(SUM((UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct)) - (ProductStandardCost * OrderQuantity)), 2) AS TotalProfit

FROM 
    master_sales

GROUP BY 
    YEAR(STR_TO_DATE(OrderDateKey, '%Y%m%d'))

ORDER BY 
    SalesYear;

    
select * from master_sales;


