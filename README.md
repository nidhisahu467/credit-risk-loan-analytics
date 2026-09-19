# Credora Finance — Credit Risk Analytics Platform

An end-to-end credit risk analytics system: a relational database, SQL-based business intelligence, a machine learning model that predicts loan default probability, a 0-100 risk scoring system, and an interactive dashboard.

## Problem

Credora Finance assessed loan risk manually using a single credit score and underwriter judgment — inconsistent, unauditable, and offering no early warning when portfolio risk drifts. This project replaces that with a data-driven, explainable system.

**Dataset**: 5,000 customers, 7,500 loan applications, 40,079 transactions, 5,000 credit history records.

## Tech Stack

- **Database**: PostgreSQL 18
- **Language**: Python 3.11 (pandas, scikit-learn, xgboost)
- **Dashboard**: Streamlit + Plotly
- **Environment**: Jupyter Notebook in VS Code

## Project Structure

```
credit-risk-loan-analytics/
├── data/                  # Raw CSVs + scored output
├── sql/                   # Schema, analytical queries
├── notebooks/             # EDA + model training
├── app.py                 # Streamlit dashboard
├── model.pkl              # Trained model
├── scaler.pkl             # Feature scaler
└── README.md
```

## What This Project Covers

### 1. Database Design
Four tables (customers, credit_history, loan_applications, transactions) connected via foreign keys on `customer_id`, with data types and referential integrity enforced at the schema level.

### 2. SQL Analysis
10 business-insight queries covering default rates, approval patterns, and risk segmentation.

**Key findings**:
- Default rate by loan type: Home 31.6% → Personal 20.3%
- Default rate by credit band: Poor (<580) 39.9% → Excellent (740+) 10.9%
- Default rate by debt-to-income: Low 8.9% → High 30.7%
- Unemployed applicants approved at 5.9% vs ~50% for salaried

### 3. Machine Learning Model
Trained and compared 3 models on 3,403 disbursed loans (the only population where default outcome is knowable).

| Model | Test ROC-AUC |
|---|---|
| **Logistic Regression (scaled)** | **0.71** |
| Random Forest | 0.68 |
| XGBoost (tuned via RandomizedSearchCV) | 0.69 |

Logistic Regression selected — it outperformed both tree-based models on held-out data (likely due to modest dataset size) and provides interpretable coefficients, which matters for explaining lending decisions.

**Ablation study** — validating that combining data sources mattered:

| Feature set | ROC-AUC |
|---|---|
| Credit history only (11 features) | 0.627 |
| Demographics only (74 features) | 0.588 |
| **Combined** | **0.707** |

**Top predictive features**: debt-to-income ratio, credit score, recent late payments, applicant income.

### 4. Risk Scoring
Model probabilities converted to a 0-100 risk score (higher = safer, matching CIBIL/FICO convention) with Low (70+) / Medium (40-69) / High (<40) bands.

Distribution: 1,115 Low Risk | 1,405 Medium Risk | 883 High Risk

### 5. Interactive Dashboard
Streamlit dashboard with portfolio KPIs, default rate by loan type, risk band distribution, monthly application trends, state-level risk comparison, and a high-risk customer watchlist.

## How to Run

```bash
# 1. Set up environment
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt

# 2. Create database and schema
psql -U postgres -c "CREATE DATABASE credit_risk_db;"
psql -U postgres -d credit_risk_db -f sql/schema.sql

# 3. Load data (from psql, in this order — foreign keys require customers first)
\copy customers FROM 'data/customers.csv' WITH (FORMAT csv, HEADER true);
\copy credit_history FROM 'data/credit_history.csv' WITH (FORMAT csv, HEADER true);
\copy loan_applications FROM 'data/loan_applications.csv' WITH (FORMAT csv, HEADER true);
\copy transactions FROM 'data/transactions.csv' WITH (FORMAT csv, HEADER true);

# 4. Train model (run notebooks/eda_and_model.ipynb) — generates data/scored_loans.csv

# 5. Launch dashboard
streamlit run app.py
```

## Limitations & Notes

- Modeling population limited to 3,403 disbursed loans — modest for ML, and likely why Logistic Regression outperformed tree-based models.
- Risk band cutoffs (70/40) are a design decision, not statistically derived — would be tuned to a lender's actual risk appetite in production.
- Tuned XGBoost showed CV ROC-AUC of 0.737 vs test 0.692, suggesting mild overfitting to the tuning process — a reason to prefer the more stable Logistic Regression.
- Model is trained on synthetic data and is not suitable for real lending decisions.