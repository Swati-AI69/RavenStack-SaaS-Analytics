-- ============================================================
-- 1. Create clean tables
-- Accounts
CREATE TABLE accounts_clean AS SELECT DISTINCT *
FROM accounts WHERE account_id IS NOT NULL;


-- Subscriptions
CREATE TABLE subscriptions_clean AS SELECT DISTINCT *
FROM subscriptions WHERE subscription_id IS NOT NULL
  AND account_id IS NOT NULL
  AND (seats > 0 OR seats IS NULL)
  AND (mrr_amount >= 0 OR mrr_amount IS NULL)
  AND (arr_amount >= 0 OR arr_amount IS NULL)
  AND (end_date >= start_date OR end_date IS NULL);
  

-- Churn Events
CREATE TABLE churn_events_clean AS SELECT DISTINCT *
FROM churn_events WHERE churn_event_id IS NOT NULL
  AND account_id IS NOT NULL
  AND (refund_amount_usd >= 0 OR refund_amount_usd IS NULL);
  

-- Feature Usage
CREATE TABLE feature_usage_clean AS SELECT DISTINCT *
FROM feature_usage WHERE usage_id IS NOT NULL
  AND subscription_id IS NOT NULL
  AND (usage_count >= 0 OR usage_count IS NULL)
  AND (usage_duration_secs >= 0 OR usage_duration_secs IS NULL)
  AND (error_count >= 0 OR error_count IS NULL);
  

-- Support Tickets
CREATE TABLE support_tickets_clean AS SELECT DISTINCT *
FROM support_tickets WHERE ticket_id IS NOT NULL
  AND account_id IS NOT NULL
  AND (resolution_time_hours >= 0 OR resolution_time_hours IS NULL)
  AND (first_response_time_minutes >= 0 OR first_response_time_minutes IS NULL)
  AND (satisfaction_score BETWEEN 0 AND 5 OR satisfaction_score IS NULL)
  AND (closed_at >= submitted_at OR closed_at IS NULL);
  
  
  
-- ============================================================
-- 2. Check whether the clean tables exist
-- ============================================================
SHOW TABLES;


-- ============================================================
-- 3. Check row counts
-- ============================================================
SELECT 'accounts_clean' AS table_name, COUNT(*) AS total_rows FROM accounts_clean
UNION ALL
SELECT 'subscriptions_clean', COUNT(*) FROM subscriptions_clean
UNION ALL
SELECT 'churn_events_clean', COUNT(*) FROM churn_events_clean
UNION ALL
SELECT 'feature_usage_clean', COUNT(*) FROM feature_usage_clean
UNION ALL
SELECT 'support_tickets_clean', COUNT(*) FROM support_tickets_clean;

-- ============================================================
-- 4. Check duplicates again
-- ============================================================
-- Accounts
SELECT account_id, COUNT(*) AS cnt FROM accounts_clean
GROUP BY account_id HAVING COUNT(*) > 1;

-- Subscriptions
SELECT subscription_id, COUNT(*) AS cnt
FROM subscriptions_clean
GROUP BY subscription_id
HAVING COUNT(*) > 1;

-- Churn
SELECT churn_event_id, COUNT(*) AS cnt
FROM churn_events_clean
GROUP BY churn_event_id
HAVING COUNT(*) > 1;

-- Feature usage
SELECT usage_id, COUNT(*) AS cnt
FROM feature_usage_clean
GROUP BY usage_id
HAVING COUNT(*) > 1;

-- Tickets
SELECT ticket_id, COUNT(*) AS cnt
FROM support_tickets_clean
GROUP BY ticket_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 5. Check relationships
-- ============================================================
-- Check subscriptions:

SELECT COUNT(*) AS orphan_subscriptions
FROM subscriptions_clean s
LEFT JOIN accounts_clean a
    ON s.account_id = a.account_id
WHERE a.account_id IS NULL;

-- Check churn:

SELECT COUNT(*) AS orphan_churn_events
FROM churn_events_clean c
LEFT JOIN accounts_clean a
    ON c.account_id = a.account_id
WHERE a.account_id IS NULL;

-- Check feature usage:

SELECT COUNT(*) AS orphan_usage
FROM feature_usage_clean f
LEFT JOIN subscriptions_clean s
    ON f.subscription_id = s.subscription_id
WHERE s.subscription_id IS NULL;

-- Check tickets:

SELECT COUNT(*) AS orphan_tickets
FROM support_tickets_clean t
LEFT JOIN accounts_clean a
    ON t.account_id = a.account_id
WHERE a.account_id IS NULL;



-- ============================================================
-- 6. Now save the clean tables as CSV
-- ============================================================
-- Accounts
SELECT * FROM accounts_clean
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/accounts_clean.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- Subscriptions
SELECT * FROM subscriptions_clean
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/subscriptions_clean.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- Churn Events
SELECT * FROM churn_events_clean
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/churn_events_clean.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- Feature Usage
SELECT * FROM feature_usage_clean
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/feature_usage_clean.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- Support Tickets
SELECT *
FROM support_tickets_clean
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/support_tickets_clean.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';