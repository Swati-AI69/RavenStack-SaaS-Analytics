-- ============================================================
-- RAVENSTACK DATABASE — COMPLETE STEP-BY-STEP EDA QUERIES
-- ============================================================

USE ravenstack_db;

-- ============================================================
-- SECTION 1: BASIC DATA UNDERSTANDING
-- ============================================================

-- Step 1.1 — Show all tables
SHOW TABLES;

-- Step 1.2 — Row counts in every table
-- Why: confirms the load worked and gives a baseline size for every table.
SELECT 'accounts' AS table_name, COUNT(*) AS total_rows FROM accounts
UNION ALL SELECT 'subscriptions', COUNT(*) FROM subscriptions
UNION ALL SELECT 'churn_events', COUNT(*) FROM churn_events
UNION ALL SELECT 'feature_usage', COUNT(*) FROM feature_usage
UNION ALL SELECT 'support_tickets', COUNT(*) FROM support_tickets;

-- Step 1.3 — First records of every table
-- Why: eyeball actual values, not just column names.
SELECT * FROM accounts LIMIT 5;
SELECT * FROM subscriptions LIMIT 5;
SELECT * FROM churn_events LIMIT 5;
SELECT * FROM feature_usage LIMIT 5;
SELECT * FROM support_tickets LIMIT 5;

-- Step 1.4 — Columns of each table (structure)
-- Why: confirms column names/types before writing further queries.
DESCRIBE accounts;
DESCRIBE subscriptions;
DESCRIBE churn_events;
DESCRIBE feature_usage;
DESCRIBE support_tickets;

-- Step 1.5 — Primary keys
-- Why: confirms each table has a unique identifier column.
SHOW KEYS FROM accounts WHERE Key_name = 'PRIMARY';
SHOW KEYS FROM subscriptions WHERE Key_name = 'PRIMARY';
SHOW KEYS FROM churn_events WHERE Key_name = 'PRIMARY';
SHOW KEYS FROM feature_usage WHERE Key_name = 'PRIMARY';
SHOW KEYS FROM support_tickets WHERE Key_name = 'PRIMARY';

-- Step 1.6 — Unique ID counts (compare against row counts from 1.2)
SELECT COUNT(DISTINCT account_id) AS unique_account_ids FROM accounts;
SELECT COUNT(DISTINCT subscription_id) AS unique_subscription_ids FROM subscriptions;
SELECT COUNT(DISTINCT churn_event_id) AS unique_churn_event_ids FROM churn_events;
SELECT COUNT(DISTINCT usage_id) AS unique_usage_ids FROM feature_usage;
SELECT COUNT(DISTINCT ticket_id) AS unique_ticket_ids FROM support_tickets;

-- Step 1.7 — Foreign key checks: rows pointing to a parent that doesn't exist
-- Why: every subscription/churn event/ticket should belong to a real account,
-- and every feature usage row should belong to a real subscription.
SELECT s.subscription_id, s.account_id
FROM subscriptions s LEFT JOIN accounts a ON s.account_id = a.account_id
WHERE a.account_id IS NULL;

SELECT c.churn_event_id, c.account_id
FROM churn_events c LEFT JOIN accounts a ON c.account_id = a.account_id
WHERE a.account_id IS NULL;

SELECT t.ticket_id, t.account_id
FROM support_tickets t LEFT JOIN accounts a ON t.account_id = a.account_id
WHERE a.account_id IS NULL;

SELECT f.usage_id, f.subscription_id
FROM feature_usage f LEFT JOIN subscriptions s ON f.subscription_id = s.subscription_id
WHERE s.subscription_id IS NULL;


-- ============================================================
-- SECTION 2: DATA QUALITY CHECK
-- ============================================================

-- Step 2.1 — Duplicate primary keys
-- Why: a PK must be unique, or every join built on it is unreliable.
SELECT account_id, COUNT(*) AS cnt FROM accounts GROUP BY account_id HAVING COUNT(*) > 1;
SELECT subscription_id, COUNT(*) AS cnt FROM subscriptions GROUP BY subscription_id HAVING COUNT(*) > 1;
SELECT churn_event_id, COUNT(*) AS cnt FROM churn_events GROUP BY churn_event_id HAVING COUNT(*) > 1;
SELECT usage_id, COUNT(*) AS cnt FROM feature_usage GROUP BY usage_id HAVING COUNT(*) > 1;
SELECT ticket_id, COUNT(*) AS cnt FROM support_tickets GROUP BY ticket_id HAVING COUNT(*) > 1;

-- Step 2.2 — NULL / blank checks in key columns
-- Why: nulls in important business columns can silently break aggregations.
SELECT
  SUM(account_name IS NULL) AS null_account_name,
  SUM(industry IS NULL OR industry = '') AS missing_industry,
  SUM(country IS NULL OR country = '') AS missing_country,
  SUM(signup_date IS NULL) AS null_signup_date,
  SUM(plan_tier IS NULL) AS null_plan_tier,
  SUM(seats IS NULL) AS null_seats
FROM accounts;

SELECT
  SUM(mrr_amount IS NULL) AS null_mrr,
  SUM(arr_amount IS NULL) AS null_arr,
  SUM(end_date IS NULL) AS null_end_date,
  SUM(billing_frequency IS NULL) AS null_billing_frequency
FROM subscriptions;

SELECT
  SUM(feedback_text IS NULL) AS null_feedback,
  SUM(refund_amount_usd IS NULL) AS null_refund,
  SUM(reason_code IS NULL) AS null_reason_code
FROM churn_events;

SELECT
  SUM(usage_count IS NULL) AS null_usage_count,
  SUM(error_count IS NULL) AS null_error_count
FROM feature_usage;

SELECT
  SUM(satisfaction_score IS NULL) AS null_satisfaction,
  SUM(resolution_time_hours IS NULL) AS null_resolution,
  SUM(closed_at IS NULL) AS null_closed_at
FROM support_tickets;

-- Step 2.3 — Distinct values in categorical columns
-- Why: know what categories exist before grouping by them later.
SELECT industry, COUNT(*) AS cnt FROM accounts GROUP BY industry ORDER BY cnt DESC;
SELECT country, COUNT(*) AS cnt FROM accounts GROUP BY country ORDER BY cnt DESC;
SELECT plan_tier, COUNT(*) AS cnt FROM accounts GROUP BY plan_tier ORDER BY cnt DESC;
SELECT referral_source, COUNT(*) AS cnt FROM accounts GROUP BY referral_source ORDER BY cnt DESC;
SELECT billing_frequency, COUNT(*) AS cnt FROM subscriptions GROUP BY billing_frequency ORDER BY cnt DESC;
SELECT reason_code, COUNT(*) AS cnt FROM churn_events GROUP BY reason_code ORDER BY cnt DESC;
SELECT feature_name, COUNT(*) AS cnt FROM feature_usage GROUP BY feature_name ORDER BY cnt DESC;
SELECT priority, COUNT(*) AS cnt FROM support_tickets GROUP BY priority ORDER BY cnt DESC;

-- Step 2.4 — Min/Max of important numeric columns
-- Why: catches impossible values (negative seats, out-of-range scores).
SELECT MIN(seats) AS min_seats, MAX(seats) AS max_seats, AVG(seats) AS avg_seats FROM accounts;

SELECT MIN(mrr_amount) AS min_mrr, MAX(mrr_amount) AS max_mrr,
       MIN(arr_amount) AS min_arr, MAX(arr_amount) AS max_arr
FROM subscriptions;

SELECT MIN(refund_amount_usd) AS min_refund, MAX(refund_amount_usd) AS max_refund FROM churn_events;

SELECT MIN(usage_count) AS min_usage, MAX(usage_count) AS max_usage,
       MIN(error_count) AS min_errors, MAX(error_count) AS max_errors
FROM feature_usage;

SELECT MIN(resolution_time_hours) AS min_res, MAX(resolution_time_hours) AS max_res,
       MIN(satisfaction_score) AS min_sat, MAX(satisfaction_score) AS max_sat
FROM support_tickets;

-- Step 2.5 — Suspicious values
-- Why: zero/negative seats, revenue, or refunds would indicate bad records.
SELECT COUNT(*) AS zero_or_negative_seats FROM accounts WHERE seats <= 0;
SELECT COUNT(*) AS negative_mrr FROM subscriptions WHERE mrr_amount < 0;
SELECT COUNT(*) AS negative_refund FROM churn_events WHERE refund_amount_usd < 0;
SELECT COUNT(*) AS negative_satisfaction FROM support_tickets WHERE satisfaction_score < 0;

-- Step 2.6 — Date validity
-- Why: a subscription ending before it starts, or a ticket closing before it opened, signals bad data.
SELECT COUNT(*) AS bad_subscription_dates FROM subscriptions WHERE end_date < start_date;
SELECT COUNT(*) AS bad_ticket_dates FROM support_tickets WHERE closed_at < submitted_at;

-- Step 2.7 — Min/Max dates (what time period the data covers)
SELECT MIN(signup_date) AS earliest_signup, MAX(signup_date) AS latest_signup FROM accounts;
SELECT MIN(start_date) AS earliest_sub, MAX(start_date) AS latest_sub FROM subscriptions;
SELECT MIN(churn_date) AS earliest_churn, MAX(churn_date) AS latest_churn FROM churn_events;
SELECT MIN(usage_date) AS earliest_usage, MAX(usage_date) AS latest_usage FROM feature_usage;
SELECT MIN(submitted_at) AS earliest_ticket, MAX(submitted_at) AS latest_ticket FROM support_tickets;


-- ============================================================
-- SECTION 3: ACCOUNTS ANALYSIS
-- ============================================================

SELECT COUNT(*) AS total_accounts FROM accounts;

SELECT industry, COUNT(*) AS num_accounts FROM accounts GROUP BY industry ORDER BY num_accounts DESC;

SELECT country, COUNT(*) AS num_accounts FROM accounts GROUP BY country ORDER BY num_accounts DESC;

SELECT plan_tier, COUNT(*) AS num_accounts FROM accounts GROUP BY plan_tier ORDER BY num_accounts DESC;

SELECT referral_source, COUNT(*) AS num_accounts FROM accounts GROUP BY referral_source ORDER BY num_accounts DESC;

SELECT is_trial, COUNT(*) AS num_accounts FROM accounts GROUP BY is_trial;

SELECT AVG(seats) AS avg_seats, MIN(seats) AS min_seats, MAX(seats) AS max_seats FROM accounts;

SELECT churn_flag, COUNT(*) AS num_accounts FROM accounts GROUP BY churn_flag;

-- Signup trend by year/month
SELECT YEAR(signup_date) AS signup_year, MONTH(signup_date) AS signup_month, COUNT(*) AS num_signups
FROM accounts
GROUP BY YEAR(signup_date), MONTH(signup_date)
ORDER BY signup_year, signup_month;


-- ============================================================
-- SECTION 4: SUBSCRIPTION ANALYSIS
-- ============================================================

SELECT COUNT(*) AS total_subscriptions FROM subscriptions;

SELECT plan_tier, COUNT(*) AS num_subs FROM subscriptions GROUP BY plan_tier ORDER BY num_subs DESC;

SELECT is_trial, COUNT(*) AS num_subs FROM subscriptions GROUP BY is_trial;

SELECT billing_frequency, COUNT(*) AS num_subs FROM subscriptions GROUP BY billing_frequency;

SELECT auto_renew_flag, COUNT(*) AS num_subs FROM subscriptions GROUP BY auto_renew_flag;

SELECT upgrade_flag, COUNT(*) AS num_subs FROM subscriptions GROUP BY upgrade_flag;

SELECT downgrade_flag, COUNT(*) AS num_subs FROM subscriptions GROUP BY downgrade_flag;

SELECT churn_flag, COUNT(*) AS num_subs FROM subscriptions GROUP BY churn_flag;

SELECT AVG(mrr_amount) AS avg_mrr, SUM(mrr_amount) AS total_mrr FROM subscriptions;

SELECT AVG(arr_amount) AS avg_arr, SUM(arr_amount) AS total_arr FROM subscriptions;

SELECT AVG(seats) AS avg_seats FROM subscriptions;

-- Subscription trend over time
SELECT YEAR(start_date) AS sub_year, MONTH(start_date) AS sub_month, COUNT(*) AS num_new_subs
FROM subscriptions
GROUP BY YEAR(start_date), MONTH(start_date)
ORDER BY sub_year, sub_month;

-- Revenue by plan
SELECT plan_tier, SUM(mrr_amount) AS total_mrr, SUM(arr_amount) AS total_arr
FROM subscriptions
GROUP BY plan_tier
ORDER BY total_mrr DESC;

-- Upgrades / downgrades by plan
SELECT plan_tier, SUM(upgrade_flag) AS total_upgrades FROM subscriptions GROUP BY plan_tier ORDER BY total_upgrades DESC;
SELECT plan_tier, SUM(downgrade_flag) AS total_downgrades FROM subscriptions GROUP BY plan_tier ORDER BY total_downgrades DESC;


-- ============================================================
-- SECTION 5: CHURN ANALYSIS
-- ============================================================

SELECT COUNT(*) AS total_churn_events FROM churn_events;

SELECT reason_code, COUNT(*) AS num_churns FROM churn_events GROUP BY reason_code ORDER BY num_churns DESC;

SELECT a.plan_tier, COUNT(*) AS num_churns
FROM churn_events c JOIN accounts a ON c.account_id = a.account_id
GROUP BY a.plan_tier ORDER BY num_churns DESC;

SELECT a.industry, COUNT(*) AS num_churns
FROM churn_events c JOIN accounts a ON c.account_id = a.account_id
GROUP BY a.industry ORDER BY num_churns DESC;

SELECT a.country, COUNT(*) AS num_churns
FROM churn_events c JOIN accounts a ON c.account_id = a.account_id
GROUP BY a.country ORDER BY num_churns DESC;

-- Churn trend by month
SELECT YEAR(churn_date) AS churn_year, MONTH(churn_date) AS churn_month, COUNT(*) AS num_churns
FROM churn_events
GROUP BY YEAR(churn_date), MONTH(churn_date)
ORDER BY churn_year, churn_month;

SELECT is_reactivation, COUNT(*) AS num_events FROM churn_events GROUP BY is_reactivation;

SELECT preceding_upgrade_flag, COUNT(*) AS num_events FROM churn_events GROUP BY preceding_upgrade_flag;
SELECT preceding_downgrade_flag, COUNT(*) AS num_events FROM churn_events GROUP BY preceding_downgrade_flag;

SELECT SUM(refund_amount_usd) AS total_refunds, AVG(refund_amount_usd) AS avg_refund FROM churn_events;


-- ============================================================
-- SECTION 6: FEATURE USAGE ANALYSIS
-- ============================================================

SELECT COUNT(*) AS total_usage_records FROM feature_usage;

SELECT feature_name, SUM(usage_count) AS total_usage FROM feature_usage GROUP BY feature_name ORDER BY total_usage DESC;

SELECT feature_name, AVG(usage_count) AS avg_usage FROM feature_usage GROUP BY feature_name ORDER BY avg_usage DESC;

SELECT feature_name, SUM(usage_duration_secs) AS total_duration FROM feature_usage GROUP BY feature_name ORDER BY total_duration DESC;

SELECT feature_name, SUM(error_count) AS total_errors FROM feature_usage GROUP BY feature_name ORDER BY total_errors DESC;

SELECT is_beta_feature, COUNT(*) AS num_records FROM feature_usage GROUP BY is_beta_feature;

-- Feature usage over time
SELECT YEAR(usage_date) AS usage_year, MONTH(usage_date) AS usage_month, COUNT(*) AS num_records
FROM feature_usage
GROUP BY YEAR(usage_date), MONTH(usage_date)
ORDER BY usage_year, usage_month;


-- ============================================================
-- SECTION 7: SUPPORT TICKET ANALYSIS
-- ============================================================

SELECT COUNT(*) AS total_tickets FROM support_tickets;

SELECT priority, COUNT(*) AS num_tickets FROM support_tickets GROUP BY priority ORDER BY num_tickets DESC;

SELECT account_id, COUNT(*) AS num_tickets FROM support_tickets GROUP BY account_id ORDER BY num_tickets DESC LIMIT 10;

SELECT AVG(resolution_time_hours) AS avg_resolution,
       MIN(resolution_time_hours) AS min_resolution,
       MAX(resolution_time_hours) AS max_resolution
FROM support_tickets;

SELECT AVG(first_response_time_minutes) AS avg_first_response FROM support_tickets;

SELECT AVG(satisfaction_score) AS avg_satisfaction FROM support_tickets;

SELECT escalation_flag, COUNT(*) AS num_tickets FROM support_tickets GROUP BY escalation_flag;

-- Tickets by month
SELECT YEAR(submitted_at) AS ticket_year, MONTH(submitted_at) AS ticket_month, COUNT(*) AS num_tickets
FROM support_tickets
GROUP BY YEAR(submitted_at), MONTH(submitted_at)
ORDER BY ticket_year, ticket_month;

-- Resolution time and satisfaction by priority
SELECT priority, AVG(resolution_time_hours) AS avg_resolution FROM support_tickets GROUP BY priority ORDER BY avg_resolution DESC;
SELECT priority, AVG(satisfaction_score) AS avg_satisfaction FROM support_tickets GROUP BY priority ORDER BY avg_satisfaction;


-- ============================================================
-- SECTION 8: ACCOUNT + SUBSCRIPTION ANALYSIS (JOINS)
-- ============================================================

SELECT a.account_id, a.account_name, s.subscription_id, s.plan_tier, s.mrr_amount, s.arr_amount
FROM accounts a JOIN subscriptions s ON a.account_id = s.account_id
LIMIT 20;

-- Subscriptions per account
SELECT a.account_id, a.account_name, COUNT(s.subscription_id) AS num_subscriptions
FROM accounts a JOIN subscriptions s ON a.account_id = s.account_id
GROUP BY a.account_id, a.account_name
ORDER BY num_subscriptions DESC;

-- MRR / ARR by account
SELECT a.account_id, a.account_name, SUM(s.mrr_amount) AS total_mrr, SUM(s.arr_amount) AS total_arr
FROM accounts a JOIN subscriptions s ON a.account_id = s.account_id
GROUP BY a.account_id, a.account_name
ORDER BY total_mrr DESC;

-- Churn status with subscription details
SELECT a.account_id, a.account_name, s.plan_tier, s.churn_flag
FROM accounts a JOIN subscriptions s ON a.account_id = s.account_id
WHERE s.churn_flag = 1;


-- ============================================================
-- SECTION 9: ACCOUNT + CHURN ANALYSIS (JOINS)
-- ============================================================

SELECT a.industry, COUNT(*) AS num_churns
FROM accounts a JOIN churn_events c ON a.account_id = c.account_id
GROUP BY a.industry ORDER BY num_churns DESC;

SELECT a.country, COUNT(*) AS num_churns
FROM accounts a JOIN churn_events c ON a.account_id = c.account_id
GROUP BY a.country ORDER BY num_churns DESC;

SELECT a.plan_tier, COUNT(*) AS num_churns
FROM accounts a JOIN churn_events c ON a.account_id = c.account_id
GROUP BY a.plan_tier ORDER BY num_churns DESC;

SELECT a.referral_source, COUNT(*) AS num_churns
FROM accounts a JOIN churn_events c ON a.account_id = c.account_id
GROUP BY a.referral_source ORDER BY num_churns DESC;

-- Churned accounts and their reasons
SELECT a.account_id, a.account_name, c.reason_code, c.churn_date
FROM accounts a JOIN churn_events c ON a.account_id = c.account_id;

-- Churned accounts and refund amount
SELECT a.account_id, a.account_name, c.refund_amount_usd
FROM accounts a JOIN churn_events c ON a.account_id = c.account_id
ORDER BY c.refund_amount_usd DESC;


-- ============================================================
-- SECTION 10: ACCOUNT + SUPPORT ANALYSIS (JOINS)
-- ============================================================

-- Tickets per account
SELECT a.account_id, a.account_name, COUNT(t.ticket_id) AS num_tickets
FROM accounts a JOIN support_tickets t ON a.account_id = t.account_id
GROUP BY a.account_id, a.account_name
ORDER BY num_tickets DESC;

-- Average satisfaction by account
SELECT a.account_id, a.account_name, AVG(t.satisfaction_score) AS avg_satisfaction
FROM accounts a JOIN support_tickets t ON a.account_id = t.account_id
GROUP BY a.account_id, a.account_name
ORDER BY avg_satisfaction ASC;

-- Average resolution time by account
SELECT a.account_id, a.account_name, AVG(t.resolution_time_hours) AS avg_resolution
FROM accounts a JOIN support_tickets t ON a.account_id = t.account_id
GROUP BY a.account_id, a.account_name
ORDER BY avg_resolution DESC;

-- Escalations by account
SELECT a.account_id, a.account_name, SUM(t.escalation_flag) AS num_escalations
FROM accounts a JOIN support_tickets t ON a.account_id = t.account_id
GROUP BY a.account_id, a.account_name
ORDER BY num_escalations DESC;

-- Tickets by industry / plan tier
SELECT a.industry, COUNT(t.ticket_id) AS num_tickets
FROM accounts a JOIN support_tickets t ON a.account_id = t.account_id
GROUP BY a.industry ORDER BY num_tickets DESC;

SELECT a.plan_tier, COUNT(t.ticket_id) AS num_tickets
FROM accounts a JOIN support_tickets t ON a.account_id = t.account_id
GROUP BY a.plan_tier ORDER BY num_tickets DESC;


-- ============================================================
-- SECTION 11: SUBSCRIPTION + FEATURE USAGE (JOINS)
-- ============================================================

SELECT s.subscription_id, s.plan_tier, f.feature_name, SUM(f.usage_count) AS total_usage
FROM subscriptions s JOIN feature_usage f ON s.subscription_id = f.subscription_id
GROUP BY s.subscription_id, s.plan_tier, f.feature_name
ORDER BY total_usage DESC
LIMIT 20;

-- Feature usage by plan tier
SELECT s.plan_tier, f.feature_name, SUM(f.usage_count) AS total_usage
FROM subscriptions s JOIN feature_usage f ON s.subscription_id = f.subscription_id
GROUP BY s.plan_tier, f.feature_name
ORDER BY s.plan_tier, total_usage DESC;

-- Average usage by plan
SELECT s.plan_tier, AVG(f.usage_count) AS avg_usage
FROM subscriptions s JOIN feature_usage f ON s.subscription_id = f.subscription_id
GROUP BY s.plan_tier;

-- Errors by plan
SELECT s.plan_tier, SUM(f.error_count) AS total_errors
FROM subscriptions s JOIN feature_usage f ON s.subscription_id = f.subscription_id
GROUP BY s.plan_tier ORDER BY total_errors DESC;

-- Beta feature usage by plan
SELECT s.plan_tier, SUM(f.is_beta_feature) AS beta_usage_count
FROM subscriptions s JOIN feature_usage f ON s.subscription_id = f.subscription_id
GROUP BY s.plan_tier ORDER BY beta_usage_count DESC;


-- ============================================================
-- SECTION 12: COMBINED BUSINESS ANALYSIS
-- Note: these show patterns/correlations only, not proven causes.
-- ============================================================

-- Usage and error rate by plan
SELECT s.plan_tier, AVG(f.usage_count) AS avg_usage, AVG(f.error_count) AS avg_errors
FROM subscriptions s JOIN feature_usage f ON s.subscription_id = f.subscription_id
GROUP BY s.plan_tier;

-- Usage level vs churn flag
SELECT s.churn_flag, AVG(f.usage_count) AS avg_usage
FROM subscriptions s JOIN feature_usage f ON s.subscription_id = f.subscription_id
GROUP BY s.churn_flag;

-- MRR by plan
SELECT plan_tier, SUM(mrr_amount) AS total_mrr FROM subscriptions GROUP BY plan_tier ORDER BY total_mrr DESC;

-- Churn by plan
SELECT a.plan_tier, COUNT(*) AS num_churns
FROM accounts a JOIN churn_events c ON a.account_id = c.account_id
GROUP BY a.plan_tier ORDER BY num_churns DESC;

-- Customers by industry
SELECT industry, COUNT(*) AS num_accounts FROM accounts GROUP BY industry ORDER BY num_accounts DESC;

-- Churn by industry
SELECT a.industry, COUNT(*) AS num_churns
FROM accounts a JOIN churn_events c ON a.account_id = c.account_id
GROUP BY a.industry ORDER BY num_churns DESC;

-- Support load and satisfaction, churned vs active accounts
SELECT a.churn_flag, COUNT(t.ticket_id) AS num_tickets, AVG(t.satisfaction_score) AS avg_satisfaction
FROM accounts a JOIN support_tickets t ON a.account_id = t.account_id
GROUP BY a.churn_flag;

-- Satisfaction by plan
SELECT a.plan_tier, AVG(t.satisfaction_score) AS avg_satisfaction
FROM accounts a JOIN support_tickets t ON a.account_id = t.account_id
GROUP BY a.plan_tier;

-- Upgrades/downgrades preceding churn, by reason
SELECT reason_code, SUM(preceding_upgrade_flag) AS after_upgrade, SUM(preceding_downgrade_flag) AS after_downgrade
FROM churn_events GROUP BY reason_code;

-- Most-used and most error-prone features overall
SELECT feature_name, SUM(usage_count) AS total_usage FROM feature_usage GROUP BY feature_name ORDER BY total_usage DESC;
SELECT feature_name, SUM(error_count) AS total_errors FROM feature_usage GROUP BY feature_name ORDER BY total_errors DESC;

-- ============================================================
-- END OF SCRIPT
-- ============================================================
