drop table if exists zepto;

create table zepto(
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2) ,-- UPTO Numbers = 8 and decimal = 2
discount NUMERIC (8,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weeightInGms INTEGER,
outOfStock BOOLEAN,
quantity INTEGER
);  

alter table zepto 
rename column weeightInGms to weightInGms 



ALTER TABLE zepto
ALTER COLUMN outOfStock DROP NOT NULL;

UPDATE zepto
SET outOfStock = TRUE
WHERE outOfStock::text = '1';

-- coutnt of rows 
select count(*)from zepto

-- sample data 
select * from zepto
limit 30

--null values 
select * from zepto
where name is null
or
mrp is null
or
discount is null
or
availableQuantity is null
or
discountedSellingPrice is null
or
weightInGms is null
or
quantity is null

alter table  zepto
drop  column  outOfStock 


--*****different product categories****

SELECT distinct category from zepto
order by category
--doing order by will order the category alphabetically


--*** products names which are present more than ones ****
select name ,count(sku_id) as number_sku
from zepto
group by name
having count(sku_id)>=5
order by count(sku_id) desc

-- SQL first reads all rows from the zepto table
-- GROUP BY name groups together all rows that have the same product name
-- COUNT(sku_id) counts how many rows are there in each group (how many times each product appears)
-- HAVING COUNT(sku_id) > 1 filters the result and keeps only the product names that appear more than once (duplicates)


-- data cleaning-------

-- products  were price is zero
select * from zepto
where mrp = 0 or discountedSellingPrice = 0

delete from zepto 
where mrp = 0


-- the mrp is in the wrong  format (ex - mrp = 2000 but it should be 20.00) , 
update zepto
set mrp = mrp /100,
discountedSellingPrice =discountedSellingPrice / 100


-- discount calculate
select distinct  mrp - discountedSellingPrice as most_discounted  , name , mrp ,discountedSellingPrice,
round(((mrp - discountedSellingPrice) / mrp) * 100, 2)as discount_percent
from zepto
order by discount_percent desc

-- we calculated the most discount given on a product 


--***NOTE 
--WE  have most_discounted, name, mrp, discountedSellingPrice, discount_percent rows 
--So DISTINCT will only remove a row if all 5 values match exactly with another row.





-- 1) top 10 best- value products based on the discounted percentage

-- SELECT   
--     name,
--     COUNT(*) as count,
--     SUM(mrp - discountedSellingPrice) AS total_discounted,
-- 	round((SUM(mrp - discountedSellingPrice) / count(*)),2) as product_price
-- FROM zepto
-- GROUP BY name
-- ORDER BY total_discounted DESC
-- LIMIT 10;

select distinct name , mrp ,
ROUND(((mrp - discountedSellingPrice) / mrp) * 100, 2) AS discount_percent
from zepto
order by discount_percent desc
limit 10


--2)calculate the estimate revenue for each category
select  category , sum(discountedSellingPrice * availableQuantity) as total_revenue , count(*) as no_of_items
from zepto
group by category
order by  total_revenue  desc


--3) find all products where mrp is greater than 500 and discount is less than 10%
select distinct
	name,
	ROUND(((mrp - discountedSellingPrice) / mrp) * 100, 2) AS discount_percent
from zepto
where discountedSellingPrice > 500 and 
((mrp - discountedSellingPrice) / mrp) * 100 < 10
order by discount_percent desc


--4) indentify the top 5 category offering the highest average discount percentage 
select category ,
ROUND(avg(((mrp - discountedSellingPrice) / mrp) * 100.0 ),2) AS avg_discount_percent
from zepto
group by category
order by avg_discount_percent desc
limit 5

-- 5) find the price per gram for products above 100g and sort by best value 

select  distinct name , weightInGms  , discountedSellingPrice, 
 round((discountedSellingPrice / weightInGms),2) as price_per_gram
from zepto
where weightInGms > 100
order by price_per_gram 


-- **************practice**********
-- select 
-- 	name , 
-- 	weightInGms , 
-- 	discountedSellingPrice,
--  	round((discountedSellingPrice / weightInGms),2) as price_per_gram,
-- 	count(*)
-- from zepto
-- where weightInGms > 100
-- group by
-- 	name,
-- 	weightInGms,
-- 	discountedSellingPrice
-- order by  count(*) desc




6)----group the products into categories like low , medium and bulk

select distinct 
	name,
	weightInGms <= 200 as low,
	weightInGms > 200 and weightInGms<=1000 as medium,
	weightInGms > 1000 as high,
	weightInGms
from zepto


select  distinct name , weightInGms,
	case when weightInGms <= 500 then 'low'
	when weightInGms < 2500 then 'medium'
	else 'high'
	end as weight_category
from zepto


--7)what is the total inventory weight per category
select  category , 
		sum(weightInGms *availableQuantity ) / 100 as category_weight
from zepto
group by category 
order by category_weight desc
