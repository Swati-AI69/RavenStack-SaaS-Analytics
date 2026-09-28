# RavenStack SaaS Analytics 

## About the Project

RavenStack SaaS Analytics is a data analytics project where I used **MySQL and SQL** to understand how a SaaS business is performing.

The project focuses on different areas of a SaaS business such as:

* Customers and their industries
* Subscription plans
* Revenue
* Customer churn
* Product/feature usage
* Customer support

The main goal was to take raw data, clean and validate it, and then use SQL to find useful patterns that could help a SaaS business better understand its customers and operations.

---

## What I Wanted to Understand

While working on this project, I focused on questions such as:

* Which industries and subscription plans have the most customers?
* How much revenue comes from each subscription plan?
* What does customer churn look like across different plans and industries?
* Is there any relationship between product usage and churn?
* Which features are used the most?
* Which features have the most errors?
* Do churned customers have different support activity compared with active customers?
* How does customer satisfaction vary across different plans?
* What subscription changes, such as upgrades or downgrades, appear before churn?

These questions helped me move beyond simple SQL queries and use the data to answer actual business questions.

---

# Database Structure

The project contains **five related tables**.

| Table             | What it contains                                                                                  |
| ----------------- | ------------------------------------------------------------------------------------------------- |
| `accounts`        | Customer information such as industry, country, plan, seats and churn status                      |
| `subscriptions`   | Subscription details such as plan, MRR, ARR, billing frequency, upgrades and downgrades           |
| `churn_events`    | Information about when and why customers churned                                                  |
| `feature_usage`   | Information about how customers use product features and the errors they encounter                |
| `support_tickets` | Customer support information such as response time, resolution time, satisfaction and escalations |

### How the tables are connected

```text
                    ┌───────────────┐
                    │   accounts    │
                    └───────┬───────┘
                            │
             ┌──────────────┼──────────────┐
             │              │              │
             ▼              ▼              ▼
     subscriptions    churn_events    support_tickets
             │
             ▼
      feature_usage
```

This structure allowed me to combine information from different tables and perform deeper analysis using SQL joins.

---

# What I Did in This Project

I followed a complete data analysis workflow:

```text
Raw CSV Data
     ↓
Create Database & Tables
     ↓
Import Data into MySQL
     ↓
Check Data Quality
     ↓
Clean the Data
     ↓
Validate Relationships
     ↓
Perform SQL EDA
     ↓
Answer Business Questions
```

---

# Data Cleaning

Before starting the analysis, I first checked whether the data was reliable enough to use.

I created cleaned versions of all five tables:

* `accounts_clean`
* `subscriptions_clean`
* `churn_events_clean`
* `feature_usage_clean`
* `support_tickets_clean`

During the cleaning process, I worked on things such as:

* Removing duplicate records
* Checking for missing IDs
* Checking invalid subscription values
* Checking negative revenue values
* Checking invalid dates
* Checking invalid usage and error values
* Checking support response and resolution times
* Checking customer satisfaction scores
* Checking whether records were connected to valid parent records

I also checked for **orphan records**, meaning records that refer to another record that does not actually exist.

After cleaning, I performed the checks again to make sure the cleaned tables were consistent.

---

# Exploratory Data Analysis

After cleaning the data, I started exploring the database using SQL.

## 1. Customer Analysis

I looked at:

* Number of customers
* Customers by industry
* Customers by subscription plan
* Customer churn patterns

This helped me understand the overall customer base.

---

## 2. Subscription Analysis

I analyzed:

* Different subscription plans
* Monthly Recurring Revenue (MRR)
* Annual Recurring Revenue (ARR)
* Trial subscriptions
* Billing frequency
* Upgrades
* Downgrades
* Auto-renewal
* Subscription churn

This helped me understand the relationship between customers and their subscriptions.

---

## 3. Churn Analysis

Customer churn was one of the important parts of this project.

I analyzed:

* Churn by subscription plan
* Churn by industry
* Churn reasons
* Product usage versus churn
* Upgrades before churn
* Downgrades before churn
* Reactivation information

The purpose was to understand **where churn is happening and what patterns appear around churn events**.

---

## 4. Feature Usage Analysis

I also looked at how customers were using the product.

I analyzed:

* Most-used features
* Features with the most errors
* Feature usage by subscription plan
* Average usage by plan
* Errors by plan
* Beta-feature usage

This gives a better understanding of which parts of the product customers are actually using.

---

## 5. Customer Support Analysis

I used the support ticket data to analyze:

* Number of support tickets
* Tickets by industry
* Tickets by subscription plan
* Support escalations
* Support activity for churned and active customers
* Customer satisfaction
* Satisfaction by subscription plan

This helped connect customer support activity with other customer information.

---

# Business Analysis

The final part of the project combines information from multiple tables using SQL joins.

For example, I connected:

* Subscriptions + feature usage
* Feature usage + churn
* Accounts + churn events
* Accounts + support tickets
* Plans + revenue
* Churn reasons + subscription changes

This allowed me to look at the business from different angles instead of analyzing each table separately.

The analysis can help a SaaS business better understand areas such as **customer retention, product usage, revenue, and customer support**.

> The analysis shows patterns and relationships in the available data. These patterns should not be treated as proof that one factor directly causes another.

---

# Tools I Used

### Database & Analysis

* **MySQL 8.0**
* **SQL**
* **CSV**

### SQL Skills Used

* `SELECT`
* `WHERE`
* `GROUP BY`
* `ORDER BY`
* `COUNT()`
* `SUM()`
* `AVG()`
* `DISTINCT`
* `JOIN`
* `LEFT JOIN`
* `CASE`
* `UNION ALL`
* Primary Keys
* Foreign Keys
* Data Cleaning
* Data Validation
* Exploratory Data Analysis

### Version Control

* **Git**
* **GitHub**

---

# Project Files

Here is what each file in this repository is used for:

### `Tables & Importing.txt`

This file contains the SQL used to:

* Create the `ravenstack_db` database
* Create the five tables
* Set up primary and foreign keys
* Import the original CSV files into MySQL

### `saas_project.sql`

This file contains the data cleaning work.

It creates the cleaned tables and performs checks for:

* Duplicates
* Invalid values
* Missing relationships
* Orphan records

It also contains the queries used to export the cleaned data.

### `ravenstack_eda_queries.sql`

This is the main EDA file.

It contains the SQL queries I used to explore the data and perform the final business analysis.

### `.gitignore`

This file tells Git which unnecessary or temporary files should not be uploaded to GitHub.

---

# How to Run This Project

If you want to reproduce the project, follow these steps.

### Step 1 — Create the database and tables

Open:

```text
Tables & Importing.txt
```

Run the SQL queries in MySQL.

This creates the:

```text
ravenstack_db
```

database and the five main tables.

---

### Step 2 — Import the data

The import queries load these CSV files:

```text
ravenstack_accounts.csv
ravenstack_subscriptions.csv
ravenstack_churn_events.csv
ravenstack_feature_usage.csv
ravenstack_support_tickets.csv
```

---

### Step 3 — Clean the data

Run:

```text
saas_project.sql
```

This creates the cleaned tables and performs the data quality checks.

---

### Step 4 — Perform the analysis

Finally, run:

```text
ravenstack_eda_queries.sql
```

This contains the complete exploratory data analysis and business-focused SQL queries.

---

# What This Project Demonstrates

Through this project, I practiced taking a dataset from **raw data to business analysis**.

The project demonstrates my ability to:

* Work with multiple related SQL tables
* Import data into MySQL
* Understand database relationships
* Clean and validate data
* Identify duplicate and orphan records
* Use SQL joins to combine information
* Perform exploratory data analysis
* Analyze customer churn
* Analyze subscription revenue
* Analyze product usage
* Analyze customer support activity
* Translate data into business questions

---

# About Me

**Swati Bhardwaj**

Aspiring Data Analyst interested in working with data to find meaningful patterns and turn them into useful business insights.

**Skills:** SQL | MySQL | Python | Data Analysis | Data Visualization | Excel | Power BI

---

## Project Note

This project is an exploratory SaaS analytics case study. The analysis focuses on identifying patterns and relationships in the available data rather than proving direct cause-and-effect relationships.


