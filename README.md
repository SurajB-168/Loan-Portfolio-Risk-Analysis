# Loan Portfolio Risk Analysis

An end-to-end data analytics project that investigates what actually drives loan default in a retail lending portfolio — and turns the findings into concrete recommendations for a credit/risk team.

The project moves through the full pipeline: raw data cleaning → SQL analysis → Python validation → an interactive Power BI dashboard → business recommendations.

## Why this project

Loan approval decisions were being made on gut feeling and simple assumptions (e.g. "job type tells you how risky someone is") rather than on evidence. The goal was to answer one question with data:

> **What factors make a loan more likely to default, and how can that be used to make better lending decisions?**

## Dataset

The raw dataset is **AI-generated synthetic data** built to resemble a realistic Indian retail lending portfolio — Indian applicant names, branch names, states, and regions — and does not represent real people or a real institution. It is included in this repository under `data/raw/` and `data/cleaned/`.

Two raw files formed the basis of the analysis:

| File | Description |
|---|---|
| `loan_applications_raw.csv` | 5,525 rows × 24 columns — applicant details (age, income, employment type), loan details (amount, interest rate, purpose), and repayment outcomes (default flag, default date, days past due) |
| `branch_master_raw.csv` | 18 rows × 4 columns — branch name, state, and region |

The two tables are linked through `Branch_ID`.



## Project workflow

1. **Data cleaning (Excel)** — removed exact duplicates, left genuinely missing values blank instead of guessing them, traced and fixed an interest-rate formatting bug, and flagged records with inconsistent default data for the source system to correct.
2. **Validation (Python / pandas)** — an independent notebook pass confirming row/column counts, data types, summary statistics, and missing-value counts matched what was found during cleaning.
3. **Analysis (SQL / MySQL)** — queries ranging from simple aggregates to window functions (`ROW_NUMBER`, `RANK`, `LAG`/`LEAD`), CTEs, subqueries, and a reusable `branch_risk_summary` view that also powers the dashboard.
4. **Dashboard (Power BI)** — a two-page interactive report (Executive Summary + Detailed Analysis) so non-technical stakeholders can explore the numbers themselves.
5. **Recommendations** — five concrete, actionable next steps derived from the analysis.

## Key findings

- **Gold Loans lag on repayment.** Despite being the smallest loan category by volume, Gold Loans have the highest average days past due (11.7 days).
- **Risk isn't evenly spread geographically.** Default rates range from 12.12% (East region) to 15.09% (North region).
- **Employment type is a weak risk signal on its own.** Average credit scores across employment types cluster tightly (674–680), so job category alone doesn't separate low-risk from high-risk applicants.
- **Credit score and repayment history are stronger signals** than demographic factors.
- **A clear, actionable high-risk group exists.** 195 applicants both defaulted and had a credit score under 600 at the time of application.

### Portfolio snapshot

| Metric | Value |
|---|---|
| Total loan applications analyzed | 5,500 |
| Branches covered | 18 |
| Regions covered | 5 |
| Total loan value disbursed | ₹435.09 Cr |
| Average credit score | 677.32 |
| Applications approved | 68.75% |
| Applications rejected | 31.25% |
| Default rate (of approved loans) | 13.91% |
| Loan value at risk of default (approx.) | ₹57.7 Cr |

## Recommendations

1. **Review the Gold Loan approval process** — tighter collateral checks or earlier collections follow-up.
2. **Standardize underwriting rules across regions** — the 3-point default-rate gap between East and North is too large to be noise.
3. **Weigh credit score and payment history more heavily than job type** in underwriting decisions.
4. **Prioritize the 195 confirmed high-risk defaulters** for immediate recovery action.
5. **Fix the source-system bug** that lets a loan be marked "defaulted" without a default date, so future time-to-default reporting stays reliable.

## Dashboard

**Page 1 — Executive Summary:** KPI cards (total loans, disbursed value, average credit score, default rate), monthly loan trend, approval/rejection split, defaults by employment type, and a branch map — filterable by year and month.

![Executive Summary dashboard](dashboard/Page%201.jpg)

**Page 2 — Detailed Analysis:** applicants by employment type, loan amount by branch, loan amount by purpose, and average days past due by loan purpose.

![Detailed Analysis dashboard](dashboard/Page%202.jpg)

## Repository structure

```
loan-portfolio-risk-analysis/
├── README.md
├── data/
│   ├── raw/
│   │   ├── loan_applications_raw.csv       # AI-generated synthetic data (Indian names/locations)
│   │   └── branch_master_raw.csv           # AI-generated synthetic data (Indian names/locations)
│   └── cleaned/
│       ├── loan_applications_cleaned.csv
│       └── branch_master_cleaned.csv
├── loan_portfolio_risk_analysis.sql        # all SQL queries + the branch_risk_summary view
├── loan_portfolio_risk_analysis.ipynb      # pandas validation checks
├── dashboard/
│   ├── loan_portfolio_risk_analysis.pbix   # Power BI file
│   ├── executive_summary.png
│   └── detailed_analysis.png
├── presentation/
│   └── loan_portfolio_risk_analysis.pptx   # summary deck
└── docs/
    ├── problem_statement.pdf               # Phase 1: problem definition & planning
    └── final_report.pdf                    # full write-up (data, cleaning, SQL, findings)
```

## Tech stack

- **Excel** — initial data cleaning
- **MySQL** — data storage, SQL analysis, `branch_risk_summary` view
- **Python (pandas)** — independent validation, in a Jupyter Notebook
- **Power BI** — two-page interactive dashboard

## How to reproduce

1. Load `data/cleaned/loan_applications_cleaned.csv` and `data/cleaned/branch_master_cleaned.csv` into a MySQL database (schema inferred from the columns referenced in [`loan_portfolio_risk_analysis.sql`](loan_portfolio_risk_analysis.sql)).
2. Run the SQL script to reproduce the queries and create the `branch_risk_summary` view.
3. Open [`loan_portfolio_risk_analysis.ipynb`](loan_portfolio_risk_analysis.ipynb) in Jupyter and run all cells (see `requirements.txt` for dependencies).
4. Open `dashboard/loan_portfolio_risk_analysis.pbix` in Power BI Desktop, point it at the same cleaned dataset / the SQL view, and refresh.


