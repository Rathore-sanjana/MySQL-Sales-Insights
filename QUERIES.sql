
-- Q-1: Rank Employee in terms of revenue generation. Show employee id, first name, revenue, and rank
SELECT E.EmployeeID,
E.FirstName,
E.LastName,
(OD.UnitPrice * OD.Quantity) AS Total_Revenue,
RANK() OVER(ORDER BY Total_Revenue) AS 'RANK'
FROM order_details AS OD
INNER JOIN orders AS O ON OD.OrderID = O.OrderID
INNER JOIN employees AS E ON O.EmployeeID = E.EmployeeID;

-- Q-2: Show All products cumulative sum of units sold each month.
SELECT P.ProductName,
OD.Quantity,
DATE_FORMAT(O.OrderDate , '%m') AS Month_number,SUM(OD.QUANTITY),
SUM(SUM(OD.Quantity)) OVER(PARTITION BY P.ProductName ORDER BY Month_number
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )AS Cummulative_Sum
FROM products AS P
INNER JOIN order_details AS OD ON P.ProductID = OD.ProductID
INNER JOIN orders AS O ON OD.OrderID = O.OrderID
GROUP BY ProductName,Month_number order by  ProductName,Month_number ;

-- Q-3: Show  Highest Percentage of total revenue by each suppliers
--Method 1
SELECT S.SupplierID,
ROUND(SUM((OD.UnitPrice * OD.Quantity)),2) AS Total_Revenue,
ROUND((SUM((OD.UnitPrice * OD.Quantity)) * 100) / (SELECT SUM(UnitPrice * Quantity) FROM order_details) , 2) AS Percentage_of_revenue
FROM suppliers AS S
INNER JOIN products AS P ON S.SupplierID = P.SupplierID
INNER JOIN order_details AS OD ON P.ProductID = OD.ProductID
GROUP BY SupplierID order by Percentage_of_revenue DESC LIMIT 1;

--Method 2
SELECT S.SupplierID,
ROUND(SUM((OD.UnitPrice * OD.Quantity)),2) AS Total_Revenue,
ROUND((SUM((OD.UnitPrice * OD.Quantity)) * 100) / SUM(SUM(OD.UnitPrice * OD.Quantity)) OVER(), 2) AS Percentage_of_revenue
FROM suppliers AS S
INNER JOIN products AS P ON S.SupplierID = P.SupplierID
INNER JOIN order_details AS OD ON P.ProductID = OD.ProductID
GROUP BY SupplierID order by Percentage_of_revenue DESC LIMIT 1;

-- Q-4: Show Percentage of total orders by each suppliers
SELECT P.SupplierID,
COUNT(DISTINCT(OD.OrderID)) AS Each_Supplier_Order,
ROUND((COUNT(DISTINCT(OD.OrderID)) * 100) / (SELECT COUNT(DISTINCT(OrderID))  FROM order_details) ,2) AS Percentage_of_orders
FROM productS AS P
INNER JOIN order_details AS OD ON P.ProductID = OD.ProductID
GROUP BY SupplierID
ORDER BY Percentage_of_orders DESC ;

-- Q-5:Show All Products Year Wise report of totalQuantity sold, percentage change from last year.
SELECT P.ProductName,
DATE_FORMAT(O.OrderDate , '%Y') AS `Year`,
SUM(OD.Quantity) AS Total_quantity_sold,
ROUND((SUM(OD.Quantity)-LAG(SUM(OD.Quantity)) OVER(PARTITION BY P.ProductName ORDER BY DATE_FORMAT(O.OrderDate , '%Y'))) / 
LAG(SUM(OD.Quantity)) OVER(PARTITION BY P.ProductName ORDER BY DATE_FORMAT(O.OrderDate , '%Y')) *100 ,2) AS Percentage_change
FROM products AS P
INNER JOIN order_details AS OD ON P.ProductID = OD.ProductID
INNER JOIN orders AS O ON OD.OrderID = O.OrderID
GROUP BY ProductName, `Year`;
