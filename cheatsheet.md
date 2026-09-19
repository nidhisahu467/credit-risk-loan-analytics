# Project Cheatsheet

## Connecting to Postgres

Basic pattern:
psql -U postgres -d credit_risk_db [flag] [value]

| Flag | Meaning | Example |
|------|---------|---------|
| -U   | User to log in as        | -U postgres |
| -d   | Database to connect to   | -d credit_risk_db |
| -f   | Run SQL from a file      | -f sql/schema.sql |
| -c   | Run one command directly | -c "\d customers" |

## Useful psql-only commands (not real SQL, only work inside psql)

\d customers     -- describe a table's columns and types
\dt              -- list all tables in the current database
\q               -- quit psql, back to normal terminal
\c dbname        -- switch to a different database

## SQL basics

CREATE TABLE tablename (
    column_name  DATA_TYPE  [PRIMARY KEY / REFERENCES other_table(col)],
    ...
);
-- Every SQL statement ends in a semicolon ;

## Common data types

| Type          | Use for                          |
|---------------|-----------------------------------|
| VARCHAR(n)    | Text, up to n characters          |
| INT           | Whole numbers                     |
| NUMERIC(p,s)  | Decimal numbers (money etc.)      |
| DATE          | Calendar dates                    |

## Loading data

\copy tablename FROM 'path/to/file.csv' WITH (FORMAT csv, HEADER true);
-- Loads a CSV into an existing table. Load order matters when foreign keys exist:
-- parent tables (referenced by others) must be loaded BEFORE child tables.

## Data quality checks performed (all passed)
- No duplicate customer_id or application_id
- Age range: 21-74 (realistic)
- Income range: ₹1.2L - ₹46.4L, no negatives (realistic)
- gender and employment_type: clean categories, no typos/casing issues
- loan_default is NULL only for undisbursed loans (logical, not an error)
  → Decision: model training will filter to disbursed_flag = 1 only

## Log
- Created customers, credit_history, loan_applications, transactions tables
- Loaded all 4 CSVs, verified row counts match source files
- Wrote 10 analytical SQL queries answering business questions
- Ran data quality checks — dataset is clean


## ML: Feature engineering & first model

pd.get_dummies(X, drop_first=True)   -- one-hot encode categorical columns
train_test_split(..., stratify=y)    -- keep class balance same in train/test
StandardScaler()                     -- scale numeric features (mean 0, std 1)
                                         REQUIRED for Logistic Regression to
                                         converge properly and perform well

## Log
- Built modeling dataset: merged loan_applications + customers + credit_history,
  filtered to disbursed_flag=1 (3403 rows)
- Debugged feature explosion: credit_id (a leftover ID column) wasn't dropped,
  caused 2425 columns instead of ~117 after one-hot encoding
- Logistic Regression baseline: ROC-AUC 0.65 (unscaled) -> 0.71 (scaled)
- Target imbalance: 23% default rate, used class_weight='balanced'


## Model comparison results
Logistic Regression (scaled): ROC-AUC 0.71  <- WINNER
Random Forest:                 ROC-AUC 0.68
XGBoost:                       ROC-AUC 0.68
Decision: LogReg selected — simpler model outperformed on this dataset size,
also gives interpretable coefficients (useful for explaining decisions to
underwriters, a real requirement in lending)

## Top model drivers (by coefficient magnitude)
1. debt_to_income_ratio (+) - strongest predictor
2. credit_score (-) - higher score = lower risk
3. age (+)
4. num_late_payments_30d (+)
5. interest_rate (-), annual_income (-)

## Risk scoring
risk_score = (1 - default_probability) * 100   -- higher score = safer (like CIBIL)
Bands: 70+ Low Risk, 40-69 Medium Risk, <40 High Risk (judgment call, documented as such)
Final distribution: 1115 Low / 1405 Medium / 883 High