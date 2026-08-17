-- ====================================
-- Loan Portfolio Risk Analysis
-- ====================================



-- ====================================
-- Loan volume and applicant profile by employment type
-- ====================================
SELECT 
    Employment_Type,
    COUNT(*) AS total_loans,
    SUM(Loan_Amount_INR) AS total_loan_value,
    AVG(Annual_Income_INR) AS avg_income,
    MIN(Age) AS youngest_applicant,
    MAX(Age) AS oldest_applicant
FROM loan_applications
GROUP BY Employment_Type;


-- ====================================
-- Isolate high-risk defaulted applicants: defaulted AND poor credit score
-- ====================================
SELECT Applicant_ID, Age, Credit_Score, Loan_Amount_INR, Default_Flag
FROM loan_applications
WHERE Default_Flag = 'Yes' AND Credit_Score < 600;


-- ====================================
-- Top 5 branches by total disbursed loan value
-- ====================================
SELECT 
    b.Branch_Name, 
    b.Region,
    COUNT(l.Applicant_ID) AS total_loans,
    SUM(l.Loan_Amount_INR) AS total_disbursed
FROM loan_applications l
JOIN branch_master b ON l.Branch_ID = b.Branch_ID
GROUP BY b.Branch_Name, b.Region
ORDER BY total_disbursed DESC
LIMIT 5;


-- ====================================
-- ROW_NUMBER: rank each applicant's loan size within their own branch
-- ====================================
SELECT Applicant_ID, Branch_ID, Loan_Amount_INR,
       ROW_NUMBER() OVER (PARTITION BY Branch_ID ORDER BY Loan_Amount_INR DESC) AS rn
FROM loan_applications
;


-- ====================================
-- RANK: rank employment types by average credit score
-- ====================================
SELECT Employment_Type, 
       AVG(Credit_Score) AS avg_credit_score,
       RANK() OVER (ORDER BY AVG(Credit_Score) DESC) AS credit_rank
FROM loan_applications
WHERE Credit_Score IS NOT NULL
GROUP BY Employment_Type;


-- ====================================
-- LAG / LEAD: compare each loan to the previous/next one by application date
-- ====================================
SELECT Applicant_ID, Application_Date, Loan_Amount_INR,
       LAG(Loan_Amount_INR) OVER (ORDER BY Application_Date) AS prev_loan_amount,
       LEAD(Loan_Amount_INR) OVER (ORDER BY Application_Date) AS next_loan_amount
FROM loan_applications;


-- ====================================
-- CTE: flag high-risk applicants, then summarize by employment type
-- ====================================
WITH high_risk AS (
    SELECT Applicant_ID, Employment_Type, Credit_Score, Debt_to_Income_Ratio
    FROM loan_applications
    WHERE Credit_Score < 600 OR Debt_to_Income_Ratio > 0.5
)
SELECT Employment_Type, COUNT(*) AS high_risk_count
FROM high_risk
GROUP BY Employment_Type;


-- ====================================
-- Subquery: applicants earning above the portfolio average income
-- ====================================
SELECT Applicant_ID, Annual_Income_INR
FROM loan_applications
WHERE Annual_Income_INR > (SELECT AVG(Annual_Income_INR) FROM loan_applications);


-- ====================================
-- Final view: branch-level risk summary powering the analysis output
-- ====================================
DROP VIEW IF EXISTS branch_risk_summary;
CREATE VIEW branch_risk_summary AS
SELECT 
    b.Branch_Name, 
    b.Region,
    COUNT(l.Applicant_ID) AS total_loans,
    SUM(CASE WHEN l.Default_Flag = 'Yes' THEN 1 ELSE 0 END) AS total_defaults,
    ROUND(SUM(CASE WHEN l.Default_Flag = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(l.Applicant_ID), 2) AS default_rate_pct,
    AVG(l.Credit_Score) AS avg_credit_score
FROM loan_applications l
JOIN branch_master b ON l.Branch_ID = b.Branch_ID
GROUP BY b.Branch_Name, b.Region;


-- ====================================
-- Query the view: branches sorted by highest default rate
-- ====================================
SELECT * FROM branch_risk_summary ORDER BY default_rate_pct DESC;
