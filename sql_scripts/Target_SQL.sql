#Q1. Import the dataset and do usual exploratory analysis steps like checking the structure & characteristics of the      dataset:
# 1. Data type of all columns in the "customers" table.
select column_name, data_type 
from `first-scaler-415017.business.INFORMATION_SCHEMA.COLUMNS` 
where table_name = 'customers'

# 2. Get the time range between which the orders were placed.
select min(order_purchase_timestamp) as min, 
max(order_purchase_timestamp) as max 
from `business.orders`

# 3. Count the Cities & States of customers who ordered during the given period.
select count(distinct customer_city) as city_count, 
count(distinct customer_state) as state_count 
from `business.customers`
#---------------------------------------------------------------------------

#Q2. In-depth Exploration: 
# 1. Is there a growing trend in the no. of orders placed over the past years?
select year, 
count(*) as order_count_per_year 
from (
  select * , extract(year from order_purchase_timestamp) as year 
  from `business.orders`
  ) 
group by year order by year

# 2. Can we see some kind of monthly seasonality in terms of the no. of orders being placed?
select month, 
count(order_id) as no_of_orders 
from (select *,format_date('%B', order_purchase_timestamp) month from `business.orders`) 
group by month 
order by no_of_orders desc

# 3. During what time of the day, do the Brazilian customers mostly place their orders?
select different_times, 
count(different_times) as count_different_times 
from (
  select order_id,order_time,order_purchase_timestamp, case when order_time between '00:00:00' and '06:59:59' then 'Dawn' when order_time between '07:00:00' and '12:59:59' then 'Mornings' when order_time between '13:00:00' and '18:59:59' then 'Afternoon' else 'Night' end as different_times 
  from(select extract(time from order_purchase_timestamp) as order_time,* from `business.orders`) tbl1
  )tbl2 
  group by different_times

# Q3. Evolution of E-commerce orders in the Brazil region: 
# 1. Get the month-on-month no. of orders placed in each state.
select customer_state, month, 
count(order_id) as no_of_orders 
from (select order_id, customer_state,format_date('%B %Y',order_purchase_timestamp) as month 
from `business.customers` c join `business.orders` o on c.customer_id = o.customer_id) tbl
group by customer_state,month 
order by no_of_orders desc

# 2. How are the customers distributed across all the states?
select customer_state, 
count(customer_unique_id) as number_of_customers 
from `business.customers` 
group by customer_state 
order by number_of_customers desc

# Q4. Impact on Economy: Analyse the money movement by e-commerce by looking at order prices, freight and others. 
# 1. Get the % increase in the cost of orders from year 2017 to 2018 (include months between Jan to Aug only).
select *, round(100 *((tbl2.cost_of_orders - lag(tbl2.cost_of_orders) over(order by tbl2.cost_of_orders ) ) /lag(tbl2.cost_of_orders) over(order by tbl2.cost_of_orders )),2) || ' %' as percentage_increase 
from(
  select order_year,sum(payment_value) as cost_of_orders from (select *, extract(month from t2.order_purchase_timestamp) as order_month, extract(year from t2.order_purchase_timestamp) as order_year from `business.payments` t1 join `business.orders` t2 on t1.order_id = t2.order_id) tbl1 where order_month between 1 and 8 and order_year between 2017 and 2018 group by order_year) tbl2

# 2. Calculate the Total & Average value of order price for each state.
select c.customer_state, 
round(sum(payment_value),2) as total_value_of_order_price, 
round(avg(payment_value),2) as average_value_of_order_price 
from `business.payments` p join `business.orders` o 
on p.order_id = o.order_id join `business.customers` c 
on o.customer_id = c.customer_id 
group by c.customer_state 
order by total_value_of_order_price desc, average_value_of_order_price desc;

# 3. Calculate the Total & Average value of order freight for each state.
select t2.seller_state, 
round(sum(t1.freight_value),2) as total_freight_value, 
round(avg(t1.freight_value),2) as average_freight_value 
from `business.order_items` t1 join `business.sellers` t2 
on t1.seller_id = t2.seller_id 
group by t2.seller_state 
order by total_freight_value desc, average_freight_value desc

# Q5: Analysis based on sales, freight and delivery time.
# 1. Find the no. of days taken to deliver each order from the order’s purchase date as delivery time. Also, calculate the difference (in days) between the estimated & actual delivery date of an order. Do this in a single query.
select date_diff(order_delivered_customer_date, order_purchase_timestamp, day) as Delivery_time, 
date_diff(order_delivered_customer_date, order_estimated_delivery_date, day) as Diff_in_delivery_and_estimated_delivery, order_id,order_purchase_timestamp, order_delivered_customer_date,order_estimated_delivery_date 
from `business.orders` 
where order_delivered_customer_date is not null 
order by Delivery_time , Diff_in_delivery_and_estimated_delivery


# 2. Find out the top 5 states with the highest & lowest average freight value.
select highest_freight_value_state,highest_average_freight_value,lowest_freight_value_state,lowest_average_freight_value from 
(
  select *, row_number() over(order by highest_average_freight_value desc) as average_highest_freight_value 
  from (
    select seller_state as highest_freight_value_state,round(avg(freight_value),2) as highest_average_freight_value from `business.order_items` t1 join `business.sellers` t2 on t1.seller_id = t2.seller_id group by seller_state
    ) tbl)tbl1_1 join (
      select *, row_number() over(order by lowest_average_freight_value) as average_lowest_freight_value 
      from (select seller_state as lowest_freight_value_state,round(avg(freight_value),2) as lowest_average_freight_value from `business.order_items` t1 join `business.sellers` t2 on t1.seller_id = t2.seller_id 
      group by seller_state) tbl)tbl2_2 on tbl1_1.average_highest_freight_value = tbl2_2.average_lowest_freight_value limit 5

# 3. Find out the top 5 states with the highest & lowest average delivery time.
select tbl1_1.highest_average_Delivery_time_state, tbl1_1.highest_average_Delivery_time, tbl2_2.lowest_average_Delivery_time_state, tbl2_2.lowest_average_Delivery_time 
from (
  select *,row_number() over(order by tbl1.highest_average_Delivery_time desc) as row_num1 
  from (
    select c.customer_state as highest_average_Delivery_time_state, round(avg(date_diff(order_delivered_customer_date, order_purchase_timestamp, day)),2) as highest_average_Delivery_time 
    from `business.orders` o join `business.customers` c on o.customer_id = c.customer_id 
    group by c.customer_state) tbl1) tbl1_1 
    join (select *,row_number() over(order by tbl2.lowest_average_Delivery_time) as row_num2 from (select c.customer_state as lowest_average_Delivery_time_state, round(avg(date_diff(order_delivered_customer_date, order_purchase_timestamp, day)),2) as lowest_average_Delivery_time 
    from `business.orders` o join `business.customers` c on o.customer_id = c.customer_id 
    group by c.customer_state) tbl2) tbl2_2 on tbl1_1.row_num1 = tbl2_2.row_num2 
    limit 5

# 4. Find out the top 5 states where the order delivery is really fast as compared to the estimated date of delivery.
select customer_state, 
avg(tbl.fastest_delivery) as time_taken_to_deliver 
from (select *, date_diff(o.order_delivered_customer_date,o.order_estimated_delivery_date, day) as fastest_delivery 
from `business.orders` o join `business.customers` c on o.customer_id = c.customer_id 
where o.order_status = 'delivered' 
order by fastest_delivery) tbl 
group by customer_state 
order by time_taken_to_deliver limit 5

# Q6. Analysis based on the payments: 1. Find the month_on_month no. of orders placed using different payment types.
select tbl.order_month, 
count(order_id) as num_of_orders,payment_type 
from (
  select o.*, FORMAT_DATETIME('%B %Y', o.order_purchase_timestamp) as order_month,p.payment_type 
  from `business.orders` o join `business.payments` p 
  on o.order_id = p.order_id
  ) tbl 
group by tbl.order_month,payment_type 
order by num_of_orders desc

# 2. Find the no. of orders placed on the basis of the payment instalments that have been paid. 
select payment_installments, 
count(order_id) as no_of_orders 
from `business.payments` 
group by payment_installments 
order by no_of_orders desc




























