# Capstone-Project

I performed various analyzes and prepared dashboards and visuals on the northwind dataset using SQL, Python and Powerbi. The graduation project gave me the opportunity to use all the skills I acquired (SQL, Python, Powerbi) on a single project. The analysis cases and KPIs I created are as follows:

**📦 Order Analysis (Case 1):**

- Orders that need to be delivered early
- On which days of the week are most orders placed?
- Seasonal change in order numbers.
- Average quantity of items per order.
- Categorizing the delivery status of orders (delivered on time, delayed, waiting).

**👥 Customer Analysis (Case 2):**

- The top 10 customers who ordered the most.
- Number of customers by city, region and country.
- The first 10 customers with the highest order amount and their contact information.
- Number of customers by product categories.

**🛒 Product Analysis (Case 3):**

- Top 10 most ordered products.
- Number of products by category.
- Number of on-sale and discontinued products.
- Stock status of products.
- Products with increasing unit prices.
- Product price ranges.
- Stock status of regional suppliers.

**🚚 Shipper Analysis (Case 4):**

- In which countries did forwarders perform poorly in 1998?
- Total number of orders per shipper.
- Average load per carrier.
- Geographic distribution of shippers.

**🏢 Supplier Analysis (Case 5):**

- Geographic distribution of suppliers.
- Number of suppliers by product categories.
- The top 10 suppliers with the most orders.
- Suppliers with the fastest delivery time.
- Suppliers by total spending amounts.

**💼 Employee Analysis (Case 6):**

- Employees who process the most orders.
- Employees who receive the highest discount rate.
- How many zones does each employee have?
- Number of employees' customers.
- Annual changes in the number of orders by employees.
- Seniority and age ranking of employees.
- To whom each employee reports.

**📦 Stock Analysis (Case 7):**
- Categorizing the status of stocks (Critical/Inadequate/Available).


**RFM (Recency, Frequency, Monetary) analysis**

## 🔍What is RFM Analysis?

RFM analysis is a technique used to segment customers based on their purchasing behavior:

**Recency (R):** When the customer last shopped.
**Frequency (F):** How many times the customer makes purchases in a certain period of time.
**Monetary (M):** The customer's total spending amount.

**📈 RFM Analysis Steps:**

1. Data Preparation
2. Calculation of RFM Scores
3. Segmentation of RFM Scores
4. Customer Segmentation: Most Valuable Customers, Loyal Customers, Potential Customers, etc.
5. Visualization and Gaining Insights

**🔧 Analysis Results:**
- Who are our most valuable customers?
- Which customers can potentially be regained?
- Who are our loyal customers and with what strategies can we serve them better?

**DAX formulas used:**
  
    Satışı devam eden ürün sayısı = COUNTROWS(FILTER(products, products[discontinued] = 0))
    Satışı durdurulan ürün sayısı = COUNTROWS(FILTER(products, products[discontinued] = 1))
    Toplam çalışan bölge sayısı = DISTINCTCOUNT(employeeterritories[territory_id])
    Toplam müşteri sayısı = DISTINCTCOUNT(cusstomers[customer_id])
    Toplam nakliyeci firması = DISTINCTCOUNT(shippers[shipper_id])
    Toplam sipariş sayısı = DISTINCTCOUNT(orders[order_id])
    Toplam Sipariş Tutarı = 
            SUMX(order_details, order_details[quantity] * order_details[unit_price] * IF(order_details[discount] > 0, (1 - order_details[discount] / 100), 1))
    Toplam ürün sayısı = DISTINCTCOUNT(products[product_id])
                                                                                                                                                                                                                                         
- For the video explanation of the project: https://lnkd.in/dVc2SuQf
- PowerBI Dashboard link: https://app.powerbi.com/view?r=eyJrIjoiZWE4MmVmNDctMWY3OS00NjBhLTg1M2EtNzQ0Nzc1NThiZGM1IiwidCI6ImQ1MTA0OTAwLWNjOTQtNDYyNy05OTM4LWM3NTZhYzRhNGQzZCIsImMiOjl9
