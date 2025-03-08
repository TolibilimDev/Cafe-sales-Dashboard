
SELECT * FROM new_work.dirty_cafe_sale_dirty;

-- cheking how many rows and columns in dataset
select count(*) as Total_Rows
from dirty_cafe_sale_dirty;

select count(*) as Missing_vales,
	   count(distinct`Transaction ID`) as Unique_Tansaction 
from dirty_cafe_sale_dirty;

-- Removing Errors, Unknowns, Blanks, Nulls
update dirty_cafe_sale_dirty
set  `total spent` = Quantity * `price per unit`
where `Total Spent` in ('unknown','error','');

select   `Total Spent`, count(*)
from dirty_cafe_sale_dirty
where `Total Spent` in ('unknown','error','')
group by `Total Spent`;


select  count(*)
from dirty_cafe_sale_dirty
where item  in ('unknown','error','') -- total 859 
;


select item, count(*) as totals
from dirty_cafe_sale_dirty
where Item not in ('unknown','error','')
group by Item
order by totals desc; -- Divide 3 types of missing values to the all the types of item (107 per item) equally

-- Repalacing all errors,unknowns, and blanks with compatible values.
update dirty_cafe_sale_dirty
set Item = 'Juice'
where Item in ('unknown','error','')
limit 112;

update dirty_cafe_sale_dirty
set item = 'Coffee'
where item in ('unknown','error','')
limit 110;
 
update dirty_cafe_sale_dirty
set item = 'Cake'
where Item in ('unknown','error','')
limit 109;

update dirty_cafe_sale_dirty
set Item = 'Sandwich'
where item in ('unknown','error','')
limit 107
;

update dirty_cafe_sale_dirty
set Item = 'Smoothie'
where item in ('unknown','error','')
limit 118;

update dirty_cafe_sale_dirty
set item = 'Cookie'
where Item in('unknown','error','')
limit 116;

update dirty_cafe_sale_dirty
set Item = 'Tea'
where item in ('unknown','error','')
limit 116;

select  count(*)
from dirty_cafe_sale_dirty
where `Payment Method`  in ('unknown','error','')
;  -- total 6,159 , Credit Card 33.23 - 948, cash 33.18 - 946,Digital Wallet 33.5 -953

update dirty_cafe_sale_dirty
set `Payment Method` = 'Credit Card'
where `Payment Method` in ('unknown','error','')
limit 948 ;

update dirty_cafe_sale_dirty
set `Payment Method` = 'Cash'
where `Payment Method` in ('unknown','error','')
limit 946;

update dirty_cafe_sale_dirty
set `Payment Method` = 'Digital Wallet'
where `Payment Method` in ('unknown','error','')
limit 953;

select count(*)
from dirty_cafe_sale_dirty
where Location  in ('unknown','error','')
; -- total 3564, TOTAL 5442 Takeaway 44.8 - 1687 , In-store 50.1 - 1877

update dirty_cafe_sale_dirty
set Location = 'Takeaway'
where Location in ('unknown','error','')
limit 1687;

update dirty_cafe_sale_dirty
set `transaction date` = null
where `transaction date` in ('unknown','error',''); 

update dirty_cafe_sale_dirty
set Location = 'In-store'
where Location in ('unknown','error','')
limit 1877;
 
select item,sum(`Total Spent`) as Total_spent, sum(Quantity) as Total_quantity ,avg(`Price Per Unit`) as avg_PPUz
from dirty_cafe_sale_dirty
group by item;

select 
	Item,
    `Price Per Unit`,
    `Total Spent`,
    Quantity,
    (`Price Per Unit` * Quantity) as revenue,
    (`Price Per Unit` * Quantity * 0.7) as COGS,
    (`Price Per Unit` * Quantity - `Price Per Unit` * Quantity * 0.7) as Profit,
    ((`Price Per Unit` * Quantity - `Price Per Unit` * Quantity * 0.7) / (`Price Per Unit` * Quantity)) * 100 as Profit_Margin
from dirty_cafe_sale_dirty
; -- the method of calculating revenue,COGS,profit and profit margin.

-- Dealing with nulls in transaction date coumn logically
CREATE TEMPORARY TABLE temp_previous_dates AS
SELECT
    t1.`Transaction ID`,
    (
        SELECT MAX(t2.`Transaction Date`)
        FROM dirty_cafe_sale_dirty t2
        WHERE t2.`Transaction Date` IS NOT NULL
          AND t2.`Transaction ID` < t1.`Transaction ID`
    ) AS previous_date
FROM dirty_cafe_sale_dirty t1
WHERE t1.`Transaction Date`  IS NULL; 
 
UPDATE dirty_cafe_sale_dirty t1
JOIN temp_previous_dates t2 ON t1.`Transaction ID` = t2.`Transaction ID`
SET t1.`Transaction Date` = t2.previous_date
WHERE t1.`Transaction Date` IS NULL;

-- Featuring Engeneering
select *,dayname(`transaction date`)as Day_of_week
from dirty_cafe_sale_dirty;

alter table dirty_cafe_sale_dirty
add column Day_of_week varchar(20) after `Transaction Date`; -- adding Day_of_Week coulumn

update dirty_cafe_sale_dirty
set Day_of_week = dayname(`Transaction date`)
where `Transaction Date` is not null;

alter table dirty_cafe_sale_dirty
add column Transaction_month varchar(20) after `Transaction date`; -- adding Tranasction_month coulmn 

update dirty_cafe_sale_dirty
set Transaction_month = monthname(`Transaction date`)
where `Transaction Date` is not null;
-- i've added 2 columns(Transaction_month,Day_of_week) to make better anlaysis

-- EDA(Exploratory Data Analysis) process

select `Transaction ID`, avg(Quantity)
from dirty_cafe_sale_dirty
group by `Transaction ID`; -- Identifing avrage Quantity by Transaction Id

select count(*) as total_transactions
from dirty_cafe_sale_dirty; -- total transactions are 9006

select item,Transaction_month, sum(Quantity)
from dirty_cafe_sale_dirty
group by item,Transaction_month; -- Identifing number of sold item per month

select Item, sum(Quantity) as total_in_september
from dirty_cafe_sale_dirty
where Transaction_month = 'september'
group by item
order by total_in_september desc; -- Identifing the number of sold item for only specific month 

select item, sum(`Total Spent`) as total_revenue
from dirty_cafe_sale_dirty
where Transaction_month = 'january'
group by item
order by total_revenue desc; -- Identifing total revenue of sold items for a specific month

select Transaction_month, count(`Transaction ID`) as Total_numbers_of_id
from dirty_cafe_sale_dirty
group by Transaction_month
order by Total_numbers_of_id desc; -- Identifing number of customers per month

select Transaction_month, sum(`Total Spent`) as total_spents
from dirty_cafe_sale_dirty
group by Transaction_month
order by total_spents desc; -- Identifing the Total revenue per month

select Transaction_month,Item,count(*)as Item_count
from dirty_cafe_sale_dirty
group by Transaction_month,Item 
order by Item_count desc; -- Identifing months,items by number of sold items

select Day_of_week,count(*) as transaction_count
from dirty_cafe_sale_dirty
group by Day_of_week
order by transaction_count desc; -- Identifing the number of made transaction per day in a week

select Day_of_week, sum(`Total Spent`) sum_spent
from dirty_cafe_sale_dirty
group by Day_of_week
order by sum_spent desc; -- Identifing total revenue per day in a week

-- Time-Based Analysis Tasks
select Transaction_month, count(*) as frequent_transaction
from dirty_cafe_sale_dirty
group by Transaction_month
order by frequent_transaction desc; -- Iddentifing the frequently made transactions per month

select Transaction_month, sum(`Total Spent`) as peak_offpeak_months
from dirty_cafe_sale_dirty
group by Transaction_month 
order by peak_offpeak_months desc; 

select Day_of_week, sum(`Total Spent`) as busiest_day
from dirty_cafe_sale_dirty
group by Day_of_week
order by busiest_day desc; -- Identifing dayli Revenue in a week

-- Sales Performance Analysis
select item, count(Quantity) as top_selling_items
from dirty_cafe_sale_dirty
group by Item 
order by top_selling_items desc;

select 
	(sum(`Total Spent`) / count(`Transaction ID`)) as Avg_order_value
from dirty_cafe_sale_dirty -- Identfing Avrage order by formula
;

select Location,sum(`Total Spent`) as Rank_location
from dirty_cafe_sale_dirty
group by Location -- Identifing total revenue per location 
;

-- Payment analysis
select `Payment Method`,count(*) common_payment_method
from dirty_cafe_sale_dirty
group by `Payment Method`; -- Identifing number of payment method by its type

select `Payment Method`, sum(`Total Spent`) as higher_sales_revenue
from dirty_cafe_sale_dirty
group by `Payment Method`; -- Identifing total revenue gained via payment methods

-- Advanced Insights & Patterns
select 
    case
		when month(`transaction date`) in (6,7,8) then 'Summer'
        when month(`transaction date`) in (12,1,2) then 'Winter'
    end as Season,
    sum(`Total Spent`) as total_sales
from dirty_cafe_sale_dirty
group by season
order by total_sales desc; -- Identifing which types of items are sold more in 2 seasons by total revenue

select 
	case 
		when month(`transaction date`) in (12,1,2) then 'Winter'
        when month(`transaction date`) in (6,7,8) then 'Summer'
        else 'Other season'
    end as Season,
    item,
    sum(Quantity) as Total_sold
from dirty_cafe_sale_dirty
group by season,Item
order by season, Total_sold desc;  -- Identifing which types of items are sold more in 2 seasons by number of items sold


select
	year(`Transaction date`) as Year,
	case
		when month(`Transaction Date`) in (12,1,2)  then 'Winter'
        when month(`Transaction Date`) in (6,7,8) then 'Summer'
        else 'Other season'
    end as Season,
    sum(`Total Spent`) as total_sales
from dirty_cafe_sale_dirty
group by year,season
order by year,season desc; -- Identifing which types of items are sold more in 2 seasons by total revenue

select
 Day_of_week,
 round(avg(`Total Spent`),2) as avg_spending
from dirty_cafe_sale_dirty
group by  Day_of_week
order by avg_spending desc; -- Identifing Avrage revenue per day in a week

select 
	 Day_of_week,
     count(`Transaction ID`) as Num_Transactions,
     round(sum(`total spent`) / count(`Transaction id`), 2) as Avg_Spending_Per_Transaction
from dirty_cafe_sale_dirty
group by Day_of_week
order by Avg_Spending_Per_Transaction desc; -- Identifing avrage number of transaction per day in a week

select *
from dirty_cafe_sale_dirty;