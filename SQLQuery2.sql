use project
go
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ECommerce_Portfolio_DB')
BEGIN
    ALTER DATABASE ECommerce_Portfolio_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ECommerce_Portfolio_DB;
END
GO

CREATE DATABASE ECommerce_Portfolio_DB;
GO
USE ECommerce_Portfolio_DB;
GO

-- 2. إنشاء الجداول
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FullName NVARCHAR(100),
    City NVARCHAR(50),
    Segment NVARCHAR(50),
    JoinDate DATE
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(100),
    Category NVARCHAR(50),
    UnitCost DECIMAL(10, 2),
    UnitPrice DECIMAL(10, 2)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    OrderDate DATE,
    Quantity INT,
    Discount DECIMAL(4, 2),
    OrderStatus NVARCHAR(20)
);
GO

-- 3. إدخال 25 منتج متنوع
INSERT INTO Products VALUES
(101, 'Laptop Dell XPS 15', 'Laptops', 35000, 42000),
(102, 'MacBook Air M3', 'Laptops', 45000, 53000),
(103, 'Lenovo ThinkPad X1', 'Laptops', 38000, 45000),
(104, 'HP Spectre x360', 'Laptops', 33000, 39500),
(105, 'Asus ROG Strix G16', 'Laptops', 48000, 56000),
(106, 'iPhone 15 Pro Max', 'Smartphones', 45000, 54000),
(107, 'Samsung Galaxy S24 Ultra', 'Smartphones', 42000, 50000),
(108, 'Xiaomi 14 Pro', 'Smartphones', 25000, 31000),
(109, 'Google Pixel 8 Pro', 'Smartphones', 30000, 36000),
(110, 'iPhone 14', 'Smartphones', 28000, 34000),
(111, 'Sony WH-1000XM5', 'Audio', 9000, 12500),
(112, 'AirPods Pro 2', 'Audio', 7500, 10200),
(113, 'Bose QuietComfort Ultra', 'Audio', 11000, 14800),
(114, 'JBL Flip 6 Speaker', 'Audio', 3200, 4500),
(115, 'Samsung Galaxy Buds2 Pro', 'Audio', 4000, 5600),
(116, 'Logitech MX Master 3S', 'Accessories', 2800, 4000),
(117, 'Keychron K2 Mechanical Keyboard', 'Accessories', 2500, 3600),
(118, 'Anker 737 Power Bank', 'Accessories', 3500, 4900),
(119, 'Samsung T7 1TB SSD', 'Accessories', 3000, 4200),
(120, 'Apple Watch Series 9', 'Accessories', 13000, 16500),
(121, 'Samsung Odyssey G7 27"', 'Monitors', 14000, 18000),
(122, 'LG UltraGear 24" 144Hz', 'Monitors', 6500, 8800),
(123, 'Dell UltraSharp 27" 4K', 'Monitors', 16000, 20500),
(124, 'ASUS ProArt Display 27"', 'Monitors', 15000, 19200),
(125, 'BenQ ZOWIE XL2411K', 'Monitors', 7000, 9500);
GO

-- 4. توليد 1,200 عميل بشكل عشوائي واقعي
SET NOCOUNT ON;

DECLARE @FirstNames TABLE (ID INT IDENTITY(1,1), Name NVARCHAR(50));
INSERT INTO @FirstNames VALUES 
(N'أحمد'),(N'محمد'),(N'محمود'),(N'علي'),(N'عمر'),(N'يوسف'),(N'كريم'),(N'طارق'),(N'مصطفى'),(N'خالد'),
(N'سارة'),(N'نورهان'),(N'مريم'),(N'فاطمة'),(N'آية'),(N'هاجر'),(N'سلمى'),(N'يارا'),(N'دينا'),(N'ندى');

DECLARE @LastNames TABLE (ID INT IDENTITY(1,1), Name NVARCHAR(50));
INSERT INTO @LastNames VALUES 
(N'حسن'),(N'إبراهيم'),(N'سعيد'),(N'عادل'),(N'كمال'),(N'جمال'),(N'ناصر'),(N'فؤاد'),(N'شريف'),(N'حمدي'),
(N'عثمان'),(N'صلاح'),(N'زكي'),(N'رمضان'),(N'سليمان'),(N'عباس'),(N'رشاد'),(N'منصور'),(N'هلال'),(N'قاسم');

DECLARE @Cities TABLE (ID INT IDENTITY(1,1), City NVARCHAR(50));
INSERT INTO @Cities VALUES 
(N'القاهرة'),(N'الجيزة'),(N'الإسكندرية'),(N'سوهاج'),(N'أسيوط'),(N'المنصورة'),(N'طنطا'),(N'الزقازيق'),(N'أسوان'),(N'الأقصر');

DECLARE @Segments TABLE (ID INT IDENTITY(1,1), Segment NVARCHAR(50));
INSERT INTO @Segments VALUES ('Regular'),('Regular'),('Regular'),('VIP'),('Corporate'); -- نسبة Regular أعلى زي الواقع

DECLARE @i INT = 1;
DECLARE @FName NVARCHAR(50), @LName NVARCHAR(50), @City NVARCHAR(50), @Seg NVARCHAR(50), @JDate DATE;

WHILE @i <= 1200
BEGIN
    SELECT @FName = Name FROM @FirstNames WHERE ID = (ABS(CHECKSUM(NEWID())) % 20) + 1;
    SELECT @LName = Name FROM @LastNames WHERE ID = (ABS(CHECKSUM(NEWID())) % 20) + 1;
    SELECT @City = City FROM @Cities WHERE ID = (ABS(CHECKSUM(NEWID())) % 10) + 1;
    SELECT @Seg = Segment FROM @Segments WHERE ID = (ABS(CHECKSUM(NEWID())) % 5) + 1;
    SET @JDate = DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 700), '2026-11-01');

    INSERT INTO Customers (CustomerID, FullName, City, Segment, JoinDate)
    VALUES (@i, @FName + N' ' + @LName, @City, @Seg, @JDate);

    SET @i = @i + 1;
END
GO

-- 5. توليد 5,000 طلب (Order) بشكل عشوائي واقعي
DECLARE @Statuses TABLE (ID INT IDENTITY(1,1), Status NVARCHAR(20));
INSERT INTO @Statuses VALUES ('Completed'),('Completed'),('Completed'),('Completed'),('Returned'),('Cancelled'); -- معظم الطلبات مكتملة

DECLARE @Discounts TABLE (ID INT IDENTITY(1,1), Disc DECIMAL(4,2));
INSERT INTO @Discounts VALUES (0.00),(0.00),(0.05),(0.10),(0.15),(0.20);

DECLARE @j INT = 1001;
DECLARE @CustID INT, @ProdID INT, @ODate DATE, @Qty INT, @Disc DECIMAL(4,2), @Stat NVARCHAR(20);

WHILE @j <= 6000
BEGIN
    SET @CustID = (ABS(CHECKSUM(NEWID())) % 1200) + 1;
    SET @ProdID = (ABS(CHECKSUM(NEWID())) % 25) + 101;
    SET @ODate = DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 650), '2026-11-15');
    SET @Qty = (ABS(CHECKSUM(NEWID())) % 4) + 1; -- كمية من 1 لـ 4
    SELECT @Disc = Disc FROM @Discounts WHERE ID = (ABS(CHECKSUM(NEWID())) % 6) + 1;
    SELECT @Stat = Status FROM @Statuses WHERE ID = (ABS(CHECKSUM(NEWID())) % 6) + 1;

    INSERT INTO Orders (OrderID, CustomerID, ProductID, OrderDate, Quantity, Discount, OrderStatus)
    VALUES (@j, @CustID, @ProdID, @ODate, @Qty, @Disc, @Stat);

    SET @j = @j + 1;
END

USE ECommerce_Portfolio_DB;
GO

SELECT * FROM Products;

SELECT  * FROM Customers

SELECT * FROM Orders;

-- 1عدد اللي اتباعو 
SELECT COUNT(OrderID) AS Total_Orders
FROM Orders
WHERE OrderStatus = 'Completed';
--اجمالي هدد الكميه 2
select sum (quantity) as 'Total Quantity '
from Orders
WHERE OrderStatus = 'Completed';
--3
select sum (quantity * unitprice * (1-Discount)) as 'Net profit'
from Orders join Products on Orders.ProductID=Products.ProductID
WHERE OrderStatus = 'Completed';

--4
select city ,  
count (orderid) as 'Number Of Orders' , 
sum (Orders.Quantity  * unitprice * (1-discount)) as 'Net_Revenue '
from Orders join Customers on Orders.CustomerID=Customers.CustomerID
join Products on Orders.ProductID=Products.ProductID
where OrderStatus='completed'
group by Customers.City 


--5

select top 5  productname,category ,
sum (orders.Quantity) as 'total sold',
sum (orders.Quantity * orders.Quantity * (1-orders.Discount)) as 'Total_Sales'
from orders join products on Orders.ProductID=Products.ProductID
WHERE Orders.OrderStatus = 'Completed'
group by ProductName , Category
ORDER BY Total_Sales DESC;


CREATE VIEW vw_Sales_Dashboard AS
SELECT 
    Orders.OrderID,
    Orders.OrderDate,
    Orders.OrderStatus,
    Orders.Quantity,
    Orders.Discount,
    Customers.FullName AS CustomerName,
    Customers.City,
    Customers.Segment,
    Products.ProductName,
    Products.Category,
    Products.UnitCost,
    Products.UnitPrice,
    (Orders.Quantity * Products.UnitPrice * (1 - Orders.Discount)) AS Net_Revenue,
    (Orders.Quantity * (Products.UnitPrice * (1 - Orders.Discount) - Products.UnitCost)) AS Net_Profit
FROM Orders
JOIN Customers ON Orders.CustomerID = Customers.CustomerID
JOIN Products ON Orders.ProductID = Products.ProductID;
