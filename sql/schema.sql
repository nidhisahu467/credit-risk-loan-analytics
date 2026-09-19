CREATE TABLE customers (
    customer_id        VARCHAR(20) PRIMARY KEY,
    first_name         VARCHAR(50),
    last_name           VARCHAR(50),
    gender              VARCHAR(10),
    date_of_birth       DATE,
    age                 INT,
    marital_status      VARCHAR(50),
    dependents          INT,
    education           VARCHAR(50),
    employment_type     VARCHAR(50),
    occupation          VARCHAR(50),
    annual_income       NUMERIC(12,2),
    city                VARCHAR(50),
    state               VARCHAR(50),
    residence_type      VARCHAR(50),
    years_at_residence  INT,
    email               VARCHAR(100),
    phone               VARCHAR(20),
    kyc_status          VARCHAR(20),
    customer_since      DATE
);



CREATE TABLE credit_history (
    credit_id                   VARCHAR(20) PRIMARY KEY,
    customer_id                 VARCHAR(20) REFERENCES customers(customer_id),
    as_of_date                  DATE,
    credit_score                INT,
    num_open_accounts           INT,
    num_credit_inquiries_6m     INT,
    credit_utilization_ratio    NUMERIC(5,3),
    num_late_payments_30d       INT,
    num_late_payments_90d       INT,
    num_defaults_prior          INT,
    bankruptcies                INT,
    total_credit_limit          NUMERIC(12,2),
    total_outstanding_debt      NUMERIC(12,2),
    oldest_account_age_months   INT
);



CREATE TABLE loan_applications (
    application_id              VARCHAR(20) PRIMARY KEY,
    customer_id                 VARCHAR(20) REFERENCES customers(customer_id),
    application_date            DATE,
    loan_type                   VARCHAR(50),
    loan_purpose                VARCHAR(100),
    requested_amount            NUMERIC(12,2),
    loan_term_months            INT,
    interest_rate                NUMERIC(5,2),
    applicant_monthly_income    NUMERIC(12,2),
    existing_emi                 NUMERIC(12,2),
    debt_to_income_ratio        NUMERIC(5,3),
    collateral_flag              INT,
    approval_status              VARCHAR(20),
    approved_amount              NUMERIC(12,2),
    decision_date                DATE,
    disbursed_flag                INT,
    loan_default                  INT
);



CREATE TABLE transactions (
    transaction_id    VARCHAR(20) PRIMARY KEY,
    customer_id       VARCHAR(20) REFERENCES customers(customer_id),
    transaction_date  DATE,
    transaction_type  VARCHAR(20),
    category          VARCHAR(50),
    channel           VARCHAR(50),
    amount            NUMERIC(12,2),
    balance_after     NUMERIC(12,2)
);