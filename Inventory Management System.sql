-- CREATE TABLES
-- Categories
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100)
);

-- Products
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    CategoryID INT,
    Price DECIMAL(10, 2),
    StockQuantity INT,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Customers
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(15)
);

-- Orders
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- OrderDetails
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10, 2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- ========================================
-- INSERT DATA
-- ========================================

-- Categories
INSERT INTO Categories VALUES 
(1, 'Laptops'), 
(2, 'Smartphones'), 
(3, 'Accessories');

-- Products
INSERT INTO Products VALUES
(101, 'Dell XPS 13', 1, 999.99, 10),
(102, 'iPhone 14', 2, 1099.99, 5),
(103, 'USB-C Cable', 3, 19.99, 50);

-- Customers
INSERT INTO Customers VALUES
(1, 'Bhim Debnath', 'bhim@gmail.com', '1234567890'),
(2, 'Chandan', 'chandan@gmaile.com', '9876543210');

-- Orders
INSERT INTO Orders VALUES
(1001, 1, '2025-07-30', 1119.98),
(1002, 2, '2025-07-31', 1099.99);

-- OrderDetails
INSERT INTO OrderDetails VALUES
(1, 1001, 101, 1, 999.99),
(2, 1001, 103, 6, 19.99),
(3, 1002, 102, 1, 1099.99);

--  View Products
SELECT * FROM Products;

--  View Categories
SELECT * FROM Categories;

--  View Customers
SELECT * FROM Customers;

--  View Orders
SELECT * FROM Orders;

--  View Order Details
SELECT * FROM OrderDetails;


-- USER STORY 1: Total Sales Per Product Category
-- As a Sales Manager, I want to view total sales per category
SELECT 
    c.CategoryName,
    SUM(od.Quantity * od.UnitPrice) AS TotalSales
FROM 
    OrderDetails od
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName;

-- USER STORY 2: Low Stock Products
-- As a Warehouse Supervisor, I need to check low-stock items
SELECT 
    ProductName,
    StockQuantity
FROM 
    Products
WHERE 
    StockQuantity < 10;


-- USER STORY 3: Customer Order Details
-- As a Customer Support Agent, I need to fetch order details with customer info
SELECT 
    o.OrderID,
    o.OrderDate,
    c.CustomerName,
    c.Email,
    p.ProductName,
    od.Quantity,
    od.UnitPrice
FROM 
    Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
ORDER BY o.OrderDate DESC;


--USER STORY 4: Transaction for Stock Update
-- As a DBA, I want atomic stock updates during bulk orders
BEGIN TRANSACTION;

UPDATE Products
SET StockQuantity = StockQuantity - 1
WHERE ProductID = 101;

UPDATE Products
SET StockQuantity = StockQuantity - 1
WHERE ProductID = 102;

-- COMMIT;
-- ROLLBACK;

-- USER STORY 5: Stored Procedure to Fetch Customer Orders
-- As a Support Agent, I want to see customer orders by ID

GO
-- Ensure clean re-run
IF OBJECT_ID('GetCustomerOrders', 'P') IS NOT NULL
    DROP PROCEDURE GetCustomerOrders;
GO

-- Create the procedure
CREATE PROCEDURE GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SELECT 
        o.OrderID,
        o.OrderDate,
        o.TotalAmount,
        p.ProductName,
        od.Quantity,
        od.UnitPrice
    FROM 
        Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    WHERE 
        o.CustomerID = @CustomerID;
END;
GO

-- Execute the procedure for customer 1
EXEC GetCustomerOrders @CustomerID = 1;

-- Drop if already exists
IF OBJECT_ID('GetCustomerOrderHistory', 'P') IS NOT NULL
    DROP PROCEDURE GetCustomerOrderHistory;
GO

CREATE PROCEDURE GetCustomerOrderHistory
    @CustomerID INT
AS
BEGIN
    SELECT 
        c.CustomerName,
        o.OrderID,
        o.OrderDate,
        p.ProductName,
        od.Quantity,
        od.UnitPrice,
        (od.Quantity * od.UnitPrice) AS Subtotal,
        o.TotalAmount
    FROM 
        Customers c
    JOIN Orders o ON c.CustomerID = o.CustomerID
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    WHERE 
        c.CustomerID = @CustomerID
    ORDER BY 
        o.OrderDate;
END;
GO
EXEC GetCustomerOrderHistory @CustomerID = 1;
