import streamlit as st
import pandas as pd
import plotly.express as px

st.set_page_config(page_title="Credit Risk Dashboard", layout="wide")

@st.cache_data
def load_data():
    return pd.read_csv("data/scored_loans.csv")

data = load_data()

st.title("🏦 Credora Finance — Credit Risk Dashboard")
st.markdown("Portfolio risk overview based on disbursed loans")

# --- KPI row ---
col1, col2, col3, col4 = st.columns(4)
col1.metric("Total Disbursed Loans", f"{len(data):,}")
col2.metric("Overall Default Rate", f"{data['loan_default'].mean()*100:.1f}%")
col3.metric("High Risk Customers", f"{(data['risk_band']=='High Risk').sum():,}")
col4.metric("Avg Risk Score", f"{data['risk_score'].mean():.1f}")

st.divider()

# --- Charts row 1 ---
col_a, col_b = st.columns(2)

with col_a:
    st.subheader("Default Rate by Loan Type")
    default_by_type = data.groupby("loan_type")["loan_default"].mean().sort_values(ascending=False) * 100
    fig1 = px.bar(default_by_type, labels={"value": "Default Rate (%)", "loan_type": "Loan Type"})
    st.plotly_chart(fig1, use_container_width=True)

with col_b:
    st.subheader("Risk Band Distribution")
    fig2 = px.pie(data, names="risk_band", hole=0.4,
                  color="risk_band",
                  color_discrete_map={"Low Risk": "green", "Medium Risk": "orange", "High Risk": "red"})
    st.plotly_chart(fig2, use_container_width=True)

st.divider()

# --- Charts row 2 ---
col_c, col_d = st.columns(2)

with col_c:
    st.subheader("Monthly Application Trend")
    data["application_date"] = pd.to_datetime(data["application_date"])
    monthly = data.groupby(data["application_date"].dt.to_period("M")).size()
    monthly.index = monthly.index.astype(str)
    fig3 = px.line(monthly, labels={"value": "Applications", "application_date": "Month"})
    st.plotly_chart(fig3, use_container_width=True)

with col_d:
    st.subheader("Avg Risk Score by State")
    state_risk = data.groupby("state")["risk_score"].mean().sort_values()
    fig4 = px.bar(state_risk, orientation="h", labels={"value": "Avg Risk Score", "state": "State"})
    st.plotly_chart(fig4, use_container_width=True)

st.divider()

# --- High-risk watchlist ---
st.subheader("⚠️ High-Risk Customer Watchlist")
watchlist = data[data["risk_band"] == "High Risk"][
    ["customer_id", "first_name", "last_name", "loan_type", "requested_amount", "risk_score", "credit_score"]
].sort_values("risk_score").head(20)
st.dataframe(watchlist, use_container_width=True)