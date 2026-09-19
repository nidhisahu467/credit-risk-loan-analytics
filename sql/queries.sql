SELECT
    loan_type,
    COUNT(*) AS total_loans,
    SUM(loan_default) AS total_defaults,
    ROUND(AVG(loan_default) * 100, 2) AS default_rate_pct
FROM loan_applications
WHERE disbursed_flag = 1
GROUP BY loan_type
ORDER BY default_rate_pct DESC;

-- Query 2: Approval rate by employment type
SELECT
    c.employment_type,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN la.approval_status = 'Approved' THEN 1 ELSE 0 END) AS approved,
    ROUND(100.0 * SUM(CASE WHEN la.approval_status = 'Approved' THEN 1 ELSE 0 END) / COUNT(*), 2) AS approval_rate_pct
FROM loan_applications la
JOIN customers c ON la.customer_id = c.customer_id
GROUP BY c.employment_type
ORDER BY approval_rate_pct DESC;

-- Query 3: Average credit score by approval status
SELECT
    la.approval_status,
    ROUND(AVG(ch.credit_score), 1) AS avg_credit_score
FROM loan_applications la
JOIN credit_history ch ON la.customer_id = ch.customer_id
GROUP BY la.approval_status
ORDER BY avg_credit_score DESC;

-- Query 4: Default rate by credit score band
SELECT
    CASE
        WHEN ch.credit_score < 580 THEN 'Poor (<580)'
        WHEN ch.credit_score < 670 THEN 'Fair (580-669)'
        WHEN ch.credit_score < 740 THEN 'Good (670-739)'
        ELSE 'Excellent (740+)'
    END AS score_band,
    COUNT(*) AS total_loans,
    ROUND(AVG(la.loan_default) * 100, 2) AS default_rate_pct
FROM loan_applications la
JOIN credit_history ch ON la.customer_id = ch.customer_id
WHERE la.disbursed_flag = 1
GROUP BY score_band
ORDER BY default_rate_pct DESC;

-- Query 5: Customers with dangerously high credit utilization (watchlist)
SELECT customer_id, credit_score, credit_utilization_ratio, num_late_payments_90d
FROM credit_history
WHERE credit_utilization_ratio > 0.8
ORDER BY credit_utilization_ratio DESC
LIMIT 20;

-- Query 6: Monthly loan application volume trend
SELECT
    DATE_TRUNC('month', application_date) AS month,
    COUNT(*) AS applications
FROM loan_applications
GROUP BY month
ORDER BY month;

-- Query 7: Average requested loan amount by state
SELECT
    c.state,
    ROUND(AVG(la.requested_amount), 2) AS avg_requested_amount,
    COUNT(*) AS num_applications
FROM loan_applications la
JOIN customers c ON la.customer_id = c.customer_id
GROUP BY c.state
ORDER BY avg_requested_amount DESC;

-- Query 8: Debt-to-income ratio vs default outcome
SELECT
    CASE
        WHEN debt_to_income_ratio < 0.3 THEN 'Low (<0.3)'
        WHEN debt_to_income_ratio < 0.6 THEN 'Moderate (0.3-0.6)'
        ELSE 'High (0.6+)'
    END AS dti_band,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_default) * 100, 2) AS default_rate_pct
FROM loan_applications
WHERE disbursed_flag = 1
GROUP BY dti_band
ORDER BY default_rate_pct DESC;

-- Query 9: Transaction behavior comparison - defaulters vs non-defaulters
SELECT
    la.loan_default,
    ROUND(AVG(t.amount), 2) AS avg_transaction_amount,
    COUNT(DISTINCT t.customer_id) AS num_customers
FROM transactions t
JOIN loan_applications la ON t.customer_id = la.customer_id
WHERE la.disbursed_flag = 1 AND la.loan_default IS NOT NULL
GROUP BY la.loan_default;

-- Query 10: Top 20 highest-risk disbursed customers (low score + high utilization + prior defaults)
SELECT
    c.customer_id, c.first_name, c.last_name,
    ch.credit_score, ch.credit_utilization_ratio, ch.num_defaults_prior
FROM customers c
JOIN credit_history ch ON c.customer_id = ch.customer_id
JOIN loan_applications la ON c.customer_id = la.customer_id
WHERE la.disbursed_flag = 1
ORDER BY ch.credit_score ASC, ch.credit_utilization_ratio DESC
LIMIT 20;