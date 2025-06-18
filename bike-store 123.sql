CREATE TABLE brands (
    brand_id INTEGER PRIMARY KEY,
    brand_name VARCHAR(100)
);
					select * from brands;
CREATE TABLE categories(
category_id integer primary key,
category_name varchar(100)
);
					select * from categories;
DROP TABLE customers;

CREATE TABLE customers(
customer_id INTEGER PRIMARY KEY,
first_name VARCHAR(50),
last_name VARCHAR(50),
phone VARCHAR(20),
email VARCHAR(50),
street VARCHAR(50),
city VARCHAR(100),
state VARCHAR(100),
zip_code VARCHAR(100)
);
					SELECT * FROM customers;
DROP TABLE order_items;
CREATE TABLE order_items(
order_id INTEGER,
item_id INTEGER,
product_id INTEGER,
quantity INTEGER,
list_price NUMERIC(10,2),
discount NUMERIC(10,2)
);
					SELECT * FROM order_items;
select
sum(case when orders is null then 1 else 0 end) as null_orders from orders;
DELETE FROM orders
WHERE "shipped_date" IS NULL;
DROP TABLE orders;
CREATE TABLE orders(
order_id INTEGER PRIMARY KEY,
customer_id INTEGER,
order_status INTEGER,
order_date DATE,
required_date DATE,
shipped_date DATE,
store_id INTEGER,
staff_id INTEGER
);
					SELECT * FROM orders;
CREATE TABLE products(
product_id INTEGER PRIMARY KEY,
product_name VARCHAR(100),
brand_id INTEGER,
category_id INTEGER,
model_year VARCHAR(50),
list_price NUMERIC(10,2)
);
					SELECT * FROM products;
CREATE TABLE staffs(
staff_id INTEGER PRIMARY KEY,
first_name VARCHAR(50),
last_name VARCHAR(50),
email VARCHAR(100),
phone VARCHAR(15),
active BOOLEAN,
store_id INTEGER,
manager_id INTEGER
);
				SELECT * FROM staffs;
DROP TABLE stocks;
CREATE TABLE stocks(
store_id INTEGER,
product_id INTEGER,
quantity INTEGER
);
				SELECT * FROM stocks;
CREATE TABLE stores(
store_id INTEGER PRIMARY KEY,
store_name VARCHAR(100),
phone VARCHAR(50),
email VARCHAR(100),
street VARCHAR(50),
city VARCHAR(50),
state VARCHAR(50),
zip_code VARCHAR(15)
);
				SELECT * FROM stores;
copy brands FROM 'D:\Postgre SQL\BIKE_STORE\brands.csv' DELIMITER ',' CSV HEADER;
copy categories FROM 'D:\Postgre SQL\BIKE_STORE\categories.csv' DELIMITER ',' CSV HEADER;
copy customers FROM 'D:\Postgre SQL\BIKE_STORE\customers.csv' DELIMITER ',' CSV HEADER;
copy order_items FROM 'D:\Postgre SQL\BIKE_STORE\order_items.csv' DELIMITER ',' HEADER;
copy orders FROM 'D:\Postgre SQL\BIKE_STORE\orders.csv' DELIMITER ',' HEADER;
copy products FROM 'D:\Postgre SQL\BIKE_STORE\products.csv' DELIMITER ',' HEADER;
copy staffs FROM 'D:\Postgre SQL\BIKE_STORE\staffs.csv' DELIMITER ',' HEADER;
COPY stocks FROM 'D:\Postgre SQL\BIKE_STORE\stocks.csv' DELIMITER ',' HEADER;
copy stores FROM 'D:\Postgre SQL\BIKE_STORE\stores.csv' DELIMITER ',' HEADER;

		---Business Insights from the Database using PostgreSQL Queries---
--1. Top 5 Best-Selling Products
select p.product_name, sum(oi.quantity) as Total_sales
from order_items oi
join products p on oi.product_id = p.product_id
group by p.product_name
order by Total_sales desc
limit 10;
--2. Total Sales by Category
select c.category_name, sum(oi.quantity * oi.list_price * (1-oi.discount))as Total_sales_category
from order_items oi
join products p on oi.product_id = p.product_id
join categories c on p.category_id = c.category_id
group by c.category_name
order by Total_sales_category desc;
--3. Monthly Revenue
select date_trunc('month',o.order_date) as month,
sum(oi.quantity * oi.list_price * (1-oi.discount)) as Monthly_Revenue
from orders o
join order_items oi on o.order_id = oi.order_id
group by month
order by month;
--4. Store Performance (Revenue by Store)
select s.store_name,
sum(oi.quantity * oi.list_price * (1-oi.discount))as Store_Revenue
from stores s
join orders o on s.store_id = o.store_id
join order_items oi on o.order_id = oi.order_id
group by store_name
order by Store_Revenue;
--5. Customer Lifetime Value
select c.first_name||' '||c.last_name as customer_name, 
sum(oi.quantity * oi.list_price * (1-oi.discount)) as Customer_Spent
from customers c
join orders o on c.customer_id = o.customer_id
join order_items oi on o.order_id = oi.order_id
group by customer_name
order by Customer_Spent desc;
--6. Inventory Overview (Low Stock Products)
select p.product_name, s.quantity
from stocks s
join products p on p.product_id = s.product_id
where s.quantity <10
order by s.quantity asc;
--7. Orders by Status
select order_status,count(*)as Order_status
from orders
group by Order_Status;
--8.Top 10 Most Expensive Products
select product_name, list_price
from products
order by list_price desc
limit 10;
--9.Product Count by Brand
SELECT b.brand_name, COUNT(*) AS product_count
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
GROUP BY b.brand_name
ORDER BY product_count DESC;
--10.Average Discount by Product
SELECT p.product_name, AVG(oi.discount) AS avg_discount
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY avg_discount DESC;
--11.Customers with Most Orders
SELECT c.first_name || ' ' || c.last_name AS customer_name, COUNT(*) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY customer_name
ORDER BY total_orders DESC
LIMIT 5;
--12.Customers Who Have Not Placed Any Orders
SELECT c.first_name || ' ' || c.last_name AS customer_name, COUNT(*) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY customer_name
ORDER BY total_orders asc
LIMIT 5;
--13.Orders Handled by Each Staff Member
SELECT s.first_name || ' ' || s.last_name AS staff_name, COUNT(*) AS total_orders
FROM staffs s
JOIN orders o ON s.staff_id = o.staff_id
GROUP BY staff_name
ORDER BY total_orders DESC;
--14.Active vs Inactive Staff
SELECT active, COUNT(*) AS count
FROM staffs
GROUP BY active;
--15.Store with Most Orders
SELECT st.store_name, COUNT(*) AS total_orders
FROM stores st
JOIN orders o ON st.store_id = o.store_id
GROUP BY st.store_name
ORDER BY total_orders DESC;
--16.Revenue per Order
SELECT o.order_id, SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS order_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id
ORDER BY order_revenue DESC;
--17. Yearly Sales Summary
SELECT EXTRACT(YEAR FROM o.order_date) AS order_year,
       SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY order_year
ORDER BY order_year;
--18.Delayed Shipments (Shipped after Required Date)
SELECT o.order_id, o.order_date, o.required_date, o.shipped_date
FROM orders o
WHERE shipped_date > required_date;
--19.Current Stock by Store
SELECT st.store_name, p.product_name, s.quantity
FROM stocks s
JOIN stores st ON st.store_id = s.store_id
JOIN products p ON p.product_id = s.product_id
ORDER BY st.store_name, p.product_name;
--20.Most Stocked Product
SELECT p.product_name, SUM(s.quantity) AS total_stock
FROM stocks s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_stock DESC
LIMIT 1;








