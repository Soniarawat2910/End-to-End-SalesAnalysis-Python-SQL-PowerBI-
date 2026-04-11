# **Project Name**    - Brazilian E-Commerce by Olist

# 🗂️ **Project Summary**

This is an **End-to-End Data Analysis Project** on the **Brazilian E-commerce (Olist) Sales Dataset**.
The project covers the complete data analysis lifecycle using **Python, Advanced SQL, and Power BI**. 

### Overview:
- **Dataset**: Brazilian E-commerce Orders (2016–2018)
- **Rows**: ~119,000 orders
- **Focus Areas**: This project analyzes the Brazilian E-commerce dataset provided by Olist to uncover key business insights related to sales, customers, delivery performance, and seller behavior.
- The analysis was performed using Python, SQL, and Power BI to extract, transform, and visualize the data.

---

## 🎯 Business Objectives

This end-to-end data analysis project on **Brazilian E-commerce Sales Dataset** aims to:

1. **Analyze overall sales performance** – Revenue trends, growth (MoM & YoY), and key metrics.
2. **Understand customer behavior** – Perform RFM segmentation and identify high-value & at-risk customers.
3. **Evaluate product performance** – Identify top categories and products using ABC analysis.
4. **Analyze geographical performance** – Find best and worst performing states & cities.
5. **Assess operational efficiency** – Delivery performance, late deliveries, and their impact.
6. **Understand payment & customer satisfaction** – Payment preferences and review score analysis.
7. **Provide actionable insights** – Support data-driven decisions for business growth.

---

### Tech Stack:
- **Python** → Data Cleaning, EDA & Visualization
- **SQL (MySQL)** → Advanced Analysis (RFM, Cohort, ABC, Window Functions)
- **Power BI** → Interactive Business Dashboard
- **Jupyter Notebook** → All Python Code In Juypter Notebook

## 📂 Dataset
Dataset: Brazilian E-commerce Public Dataset by Olist  
Source: Kaggle  

The dataset contains:
- Orders data
- Customers data
- Products data
- Sellers data
- Payments data
- Reviews data
- Order Items data
- Category Name Translation

## 🔍 Data Analysis Process

## 1. Data Cleaning (Python)
- Removed missing and duplicate values of each dataset 
- Clean all Inconsistent Data and convert them into one format 
- Converted date columns into proper format
- Merged multiple datasets into one sheet named as **master_sales_data**

### Over Final Master Sales Data Contains Columns AS : 
<img src="doc/Master%20Sales%20Data%20Info.png" width="900"/>


## 2. Basic Data Insights (Python)
-  Imported the new latest cleaned file
-  Find Out Basic but usefull data trends
-  Using different charts like **Bar Chart** , **Line Chart** , **Histplot Chart**,**Bar Chart**

### File Conclustion 
- **There Is A Huge Growth In Business Between 2027-2018 Where in Nov 2017 Gots The Highest Revenue**
<img src="doc/Monthly%20Revenue%20Trend.jpg" width="900"/>

- **Bed & Bath Table, Health & Beauty, and Computers & Accessories Are The Top 3 Revenue-Generating Categories Which Together Contribute A Significant Portion Of Total Revenue**
<img src="doc/Top%2010%20Categories%20By%20Revenue.jpg" width="900"/>

- **In Brazilian State São Paulo (SP) ,  Rio de Janeiro (RJ),Minas Gerais (MG) Contribute More Than 60% Of Total Revenue**
<img src="doc/Top%2010%20states%20by%20revenue.jpg" width="900"/>

- **More Than 95% Of Orders Are Successfully Delivered Which Is Quite Good Performance**
<img src="doc/Order%20Status.jpg" width="900"/>

- **Revenue And Order Volume Are Strongly Correlated & There Is A Good Amount Of Growth In Business After Nov2017**
<img src="doc/Monthly%20Revenue%20Trend.jpg" width="900"/>


## 3. SQL Analysis
- Created DATABASE and Table of Master Sales Table & Imported into SQL
- Aggregated sales and customer data
- Analysis the advance level of insights
- Ihis all script is in advance level by using CTE , TABLE query

### File Conclustion 

- **Identifed high-value, loyal, and at-risk customers using RFM analysis?**
- There is over all **8,800+ Most Champions** , **18500+ Loyal Customers** , **25,800+ Potential Loyalists** Customer where as only **900+ Customers are Lost Customers**

- **Analyze the year on year and month on month revenue growth?**
- As per the  analysis there is **no growth** in month on month and **very less amount of growth** in year on year so seller needs to create new strategy to resolve this issues
 
- **Which customers have not purchased for a long time and may churn?**
- As per result **93000+ customers are Hight Churn Risk** which tells that customers are only purchasing the products only one time and its happend due to because of product quality or the services

- **What percentage of orders are delivered late compared to on-time deliveries?**
- As per the data only **9000+ orders are not delivered on time** from the overall 1,19,000+ Orders which is not bad but still we need to always try to fix this issues

- **What are the most popular payment methods used by customers?**
- As per the data most of the customers used **Credit Card(76k+)** for the payment where as second highest payment method is **Boleto(19k+)**

- **What are the most popular payment methods used by customers?**
- As per the data most of the customers used **Credit Card(76k+)** for the payment where as second highest payment method is **Boleto(19k+)**

## 4. Data Visualization (Power BI)
- Built interactive dashboards
- Created KPIs and trend analysis

### Power BI DASHBOARDS 

### **Executive Summary**
<img src="doc/Executive%20Summary.png" width="900"/>

### **Sales & Product**
<img src="doc/Sales%20&%20Product.png" width="900"/>

### **Customer Analysis**
<img src="doc/Customer%20Analysis.png" width="900"/>

### **Delivery & Operations**
<img src="doc/Delivery%20&%20Operations.png" width="900"/>

### Goal:
To uncover key business insights, identify growth opportunities, and provide actionable recommendations to improve sales, customer retention, and operational efficiency.





**Key Goal**: Deliver insights using Python, Advanced SQL, and Power BI Dashboard.
