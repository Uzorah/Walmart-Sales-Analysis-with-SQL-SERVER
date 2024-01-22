-- Feature Engineering
-- adding a new column 'time_of_day' to table

USE salesdatawalmart
GO

ALTER TABLE sales_data
ADD time_of_day nvarchar(10)
GO

UPDATE sales_data
SET time_of_day = (CASE
		WHEN Time BETWEEN '00:00:00' and '11:59:59' then 'Morning'
		WHEN Time BETWEEN '12:00:00' and '15:59:59' then 'Afternoon'
		ELSE 'Evening'
	END)
GO

-- Feature Engineering
-- adding a new column 'day_name' to table

ALTER TABLE sales_data
ADD day_name nvarchar(10)
GO

UPDATE sales_data
SET day_name = (select DATEname(dw, date))
GO

-- Feature Engineering
-- adding a new column 'month_name' to table

ALTER TABLE sales_data
ADD month_name nvarchar(10)
GO

UPDATE sales_data
SET month_name = (select DATEname(MONTH, date))
GO

-- 1. How many unique product lines does the data have?
select distinct product_line
from [salesdatawalmart].[dbo].[sales_data]
GO

-- 2. What is the most common payment method?
select
	payment,
	COUNT(payment) as no_of_users
from sales_data
group by payment
GO

-- 3. What is the most selling product line?
select
	product_line,
	count(Product_line) as no_of_products
from sales_data
group by product_line
order by no_of_products desc
GO

-- 4. What is the total revenue by month?
select
	month_name,
	sum(total) as total_revenue
from sales_data
group by month_name
order by CHARINDEX(month_name, 'January,February,March,April,May,June,July,August,September,October,November,December')
GO

-- 5. What month had the largest COGS?
select
	month_name,
	sum(cogs) as cogs
from sales_data
group by month_name
order by cogs desc
GO

-- 6. What product line had the largest revenue?
select
	product_line,
	sum(total) as total_revenue
from sales_data
group by Product_line
order by total_revenue desc
GO

-- 7. What product line had the largest VAT?
select
	Product_line,
	AVG(tax_5pct) as avg_vat
from sales_data
group by Product_line
order by avg_vat desc
GO

-- 8. Which branch sold more products than average product sold?
select
	Branch,
	sum(quantity) as qty
from sales_data
group by branch
having sum(quantity) > (select avg(Quantity) from sales_data)
GO

-- 9. What is the most common product line by gender?
select
	Gender,
	Product_line,
	COUNT(gender) as total_cnt
from sales_data
group by Gender, Product_line
order by total_cnt desc
GO

-- 10. What is the average rating of each product line?
select
	Product_line,
	cast(round(AVG(rating),2) as float) as avg_rating
from sales_data
group by Product_line
GO

-- 11. Which gender buys the most product line
select
	Product_line,
	DENSE_RANK() over (partition by product_line order by COUNT(gender) desc) rank,
	Gender,
	COUNT(gender) as total_cnt
from sales_data
group by Product_line, Gender
GO