
# Target SQL Business Case Study

## Overview
This project analyzes Target’s e-commerce operations in Brazil from 2016 to 2018 using SQL in BigQuery.  
The dataset contains 100,000 orders across multiple dimensions: orders, customers, payments, products, sellers, geolocation, and reviews.

The goal is to extract business insights and recommend strategies for operational improvement, pricing, shipping efficiency, and customer satisfaction.

## Dataset
The dataset contains the following CSV files (uploaded as tables into BigQuery dataset `target` under project `Ecommerce`):

1. `customers.csv`
2. `geolocation.csv`
3. `order_items.csv`
4. `payments.csv`
5. `reviews.csv`
6. `orders.csv`
7. `products.csv`
8. `sellers.csv`

## Steps to Run
1. **Setup BigQuery Project**
   - Create project: `Ecommerce`
   - Create dataset: `target`

2. **Upload CSV Files**
   - Upload each CSV as a separate table with the same name (without `.csv`).
   - Convert date/time columns to TIMESTAMP using `PARSE_TIMESTAMP` if necessary.

3. **Run SQL Queries**
   - Use queries from `project_report.pdf` to answer the case study questions.
   - Capture first 10 rows of each query output for submission.

## Analysis Sections
1. **Exploratory Analysis**
   - Data types, order time range, unique cities/states.

2. **In-depth Exploration**
   - Order growth trends, monthly seasonality, time-of-day ordering patterns.

3. **Evolution of Orders**
   - Month-on-month orders by state, customer distribution.

4. **Economic Impact**
   - Payment value growth, total & average order price, freight cost analysis.

5. **Sales, Freight & Delivery**
   - Delivery times, freight rankings, fastest vs estimated delivery.

6. **Payments Analysis**
   - Payment type trends, installment-based orders.

## Key Insights
- Orders increased steadily from 2016–2018, peaking in November.
- Afternoon and Night are the most active ordering times.
- São Paulo dominates volume; distant states have higher freight costs.
- Credit card is the most common payment method.

## Recommendations
- Optimize freight in high-cost regions.
- Target marketing during peak months/times.
- Improve delivery in slower states.
- Encourage installment payments to boost sales.

## Files
- `target_sql_case_study_report.pdf` – Detailed project report with SQL queries, insights, and recommendations.
- `README.md` – This file.
