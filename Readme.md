##### **Revenue Growth \& Customer Churn Analysis**

**End-to-End Data Analysis Project (Python|SQL|Power BI)**

##### 

##### 

##### **Project Overview :**



This project analyzes **revenue growth, customer behavior, and churn risk** using real transactional data from an e-commerce platform.



The goal was not just to build dashboards, but to **understand how revenue grows,**

**where it is fragile, and how churn impacts long-term performance**.





The project was completed end-to-end using:



* Python for data cleaning, exploration, and cohort analysis
* SQL (SQL Server) for structured transformations and metrics
* Power BI for business-ready dashboards



##### **Business Objective**



To answer three core business questions:



1. How is revenue growing over time, and how stable is that growth?
2. Which customer segments drive revenue, and how concentrated is the business?
3. How much does churn impact revenue, and is churn structural or occasional?



##### **Dataset**



Source: Public Brazilian e-commerce dataset (Olist)

Time period: **2016 – 2018**

Data types used:

           Orders \& payments

           Customers

           Derived customer segments

Size: 50k+ rows

Nature: Historical transactional data (no forecasting assumed)

##### 

##### **Project Structure \& Workflow**



###### Day 1–2: Data Understanding \& Cleaning (Python)

* Loaded multiple CSV files
* Checked:

             Missing values

             Duplicates

             Data types

* Validated customer identifiers and order relationships
* Ensured revenue calculations were logically consistent



**Tools**: Python, Pandas, Jupyter Notebook



###### Day 3: Exploratory Data Analysis (Python)



* Revenue distribution analysis
* Monthly revenue trends
* Order frequency per customer
* Initial churn definition based on inactivity



**Key outcome:**

Revenue growth exists, but early signs of volatility were visible.





###### Day 4–5: Customer Segmentation \& RFM Logic (Python)



* Built **Recency, Frequency, Monetary (RFM) metrics**
* Segmented customers into:

                             Champions

                             At Risk

                             Churned

                             New / Others

* Analyzed revenue contribution by segment



**Key insight:**

Revenue was highly concentrated in a small group of customers.





###### Day 6: SQL Transformation \& Validation (SQL Server)

* Imported cleaned datasets into SQL Server
* Created fact-style tables for:

                                  Orders

                                  Customer revenue

* Recomputed:

               Recency

               Churn flags

* Validated Python results using SQL



**Why SQL was used:**

To show production-style data handling and cross-validation of logic.





###### Day 7–9: Revenue \& Churn Metrics (Python + SQL)





* Verified revenue using payment data (avoiding overcounting)
* Built monthly revenue tables
* Checked data completeness and boundary months
* Explicitly documented dataset limitations instead of masking them



**Design choice:**

Data realism was prioritized over cosmetic fixes.



##### Day 10 :Dashboards (Power BI)





###### Dashboard 1: Overall Revenue Performance



**Purpose:** Understand revenue growth and volatility



**Key insights:**

* Revenue grows over time but is inconsistent month to month
* Early extreme growth rates are driven by low base effect
* Peak revenue months are not sustained
* Average monthly revenue is more reliable than MoM % alone

![Revenue Overview](Revenue%20Growth%20Dashboards/Revenue_overview.png)





###### Dashboard 2: Segment-Level Revenue Analysis



**Purpose:** Understand who drives revenue



**Key insights:**

* One customer segment contributes ~75–80% of revenue
* Segment mix remains stable over time
* Smaller segments show high growth percentages but low impact
* Business performance is highly dependent on one segment



###### Dashboard 3: Churn Impact Analysis (Minimal)



**Purpose:** Measure revenue risk due to churn



**Key insights:**

* Churn accounts for a large share of revenue exposure
* Churn behavior is structural, not a one-time anomaly
* Revenue stability is repeatedly weakened by churn
* Growth without retention is not sustainable



**Design choice:**

Final months show zero churn due to dataset boundaries; this was kept intentionally and documented.





##### **Key Business Takeaways**

* Revenue growth exists, but it is fragile
* The business is over-reliant on a single customer segment
* Churn materially erodes revenue, even when top-line growth appears positive
* Retention efforts would likely produce higher ROI than pure acquisition



##### **Tools \& Skills Demonstrated**



* **Python:** Pandas, data cleaning, EDA, RFM analysis, cohort logic
* **SQL:** Aggregations, recency calculations, churn flags, validation
* **Power BI:** Data modeling, DAX measures, dashboard storytelling
* **Analytics Skills:** Business framing, metric validation, data assumptions





##### **Limitations \& Assumptions**





* Data is historical (2016–2018); no forecasting performed
* Churn defined based on inactivity thresholds
* Last dataset months may show incomplete activity
* Analysis focuses on customer behavior, not seller/product optimization



##### **What Could Be Done Next**



* Early-warning churn prediction
* Product or seller-level revenue analysis
* Retention strategy simulation
* Cohort-based lifetime value modeling



##### 

##### **Final Note :**



This project was built to reflect real analyst work, including:

* Imperfect data
* Explicit assumptions
* Trade-offs between clarity and realism



The focus was on **thinking like a business analyst, not just building charts.**


