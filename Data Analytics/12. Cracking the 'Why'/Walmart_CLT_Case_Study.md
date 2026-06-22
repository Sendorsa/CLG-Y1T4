# Walmart Case Study — Central Limit Theorem (CLT) & Confidence Intervals

## 1. Business Problem

Walmart wants to understand whether spending habits differ between male and female customers.

The goal is to estimate the average purchase amount for each gender and determine if the observed difference is statistically significant using:

- Central Limit Theorem (CLT)
- Bootstrapping
- Confidence Intervals

**Source:** Walmart purchase dataset with 550,068 transactions and 10 variables.

---

## 2. Dataset Overview

### Dataset Shape

- **Rows:** 550,068
- **Columns:** 10

### Variables

| Column | Description |
|--------|-------------|
| User_ID | Customer ID |
| Product_ID | Product ID |
| Gender | Male / Female |
| Age | Age group |
| Occupation | Occupation code |
| City_Category | A, B, C |
| Stay_In_Current_City_Years | Years in city |
| Marital_Status | 0 = Single, 1 = Married |
| Product_Category | Product category |
| Purchase | Purchase amount |

Dataset contains **550,068 observations**.

---

## 3. Data Quality Checks

### Missing Values

```
User_ID                         0
Product_ID                      0
Gender                          0
Age                             0
Occupation                      0
City_Category                   0
Stay_In_Current_City_Years      0
Marital_Status                  0
Product_Category                0
Purchase                        0
```

**Result:** No missing values found.

### Duplicate Records

```python
df[df.duplicated()].shape
```

**Output:** `(0, 10)`

**Result:** No duplicate records found.

Dataset is clean and ready for analysis.

---

## 4. Descriptive Statistics of Purchase Amount

| Metric | Value |
|--------|-------|
| Count | 550,068 |
| Mean | 9263.97 |
| Std | 5023.07 |
| Min | 12 |
| 25% | 5823 |
| 50% | 8047 |
| 75% | 12054 |
| Max | 23961 |

### Interpretation

- Average purchase amount ≈ **₹9,264**
- Purchase amounts vary widely
- Distribution is spread out with some high-value purchases

---

## 5. Gender Distribution

### Transaction Count

| Gender | Count |
|--------|-------|
| Male | 414,259 |
| Female | 135,809 |

### Unique Customers

| Group | Count |
|-------|-------|
| Male customers | 4,225 |
| Female customers | 1,666 |

### Observations

- Male customers generate significantly more transactions
- Walmart's customer base is predominantly male

---

## 6. Purchase Analysis by Gender

### Female Customers

| Metric | Value |
|--------|-------|
| Count | 135,809 |
| Mean | 8734.57 |
| Std | 4767.23 |
| Median | 7914 |

### Male Customers

| Metric | Value |
|--------|-------|
| Count | 414,259 |
| Mean | 9437.53 |
| Std | 5092.19 |
| Median | 8098 |

### Comparison

| Metric | Female | Male |
|--------|--------|------|
| Mean Purchase | 8734.57 | 9437.53 |
| Median Purchase | 7914 | 8098 |
| Std Dev | 4767.23 | 5092.19 |

### Observations

- Males spend more on average
- Difference in average spending: **₹702.96** → Male customers spend approximately **₹703 more per purchase**

---

## 7. Visual Analysis

### Boxplot Findings

The boxplot shows:

- Similar distribution shape for both genders
- Male median slightly higher
- Presence of outliers in both groups
- Male purchase distribution shifted slightly right

### Histogram Findings

Purchase amounts are:

- Not perfectly normal
- Slightly right-skewed
- Contain multiple peaks

However, because of the large sample size, **CLT can still be applied**.

---

## 8. Central Limit Theorem (CLT)

### Definition

The Central Limit Theorem states:

> For sufficiently large sample sizes, the distribution of sample means approaches a normal distribution regardless of the population distribution.

### Conditions Satisfied

- Large population
- Large sample size
- Independent observations

Therefore, **CLT can be applied to Walmart purchases**.

---

## 9. Sampling Experiment

Random samples of size **n = 300** were repeatedly drawn from both male and female populations.

### Example Sample Means

**Female:**

| Sample | Mean |
|--------|------|
| 1 | 7920.40 |
| 2 | 9032.08 |
| 3 | 9005.89 |
| 4 | 8403.31 |

**Male:**

| Sample | Mean |
|--------|------|
| 1 | 8951.70 |
| 2 | 8972.68 |
| 3 | 9691.89 |
| 4 | 9073.85 |

**Observation:** Sample means fluctuate around the population mean.

---

## 10. Bootstrapping

Bootstrapping was performed:

- **Samples:** 1000
- **Sample size:** 300
- **Replacement:** True

### Purpose

- Estimate sampling distribution
- Estimate confidence intervals
- Validate CLT assumptions

---

## 11. Male Sampling Distribution

**Generated:** 1000 bootstrap samples

| Statistic | Value |
|-----------|-------|
| Average of sample means | 9433.86 |
| Population mean | 9437.53 |
| **Difference** | **3.67** |

**Very small difference.**

### Conclusion

Bootstrap estimate closely matches actual population mean.

---

## 12. Female Sampling Distribution

**Generated:** 1000 bootstrap samples

| Statistic | Value |
|-----------|-------|
| Average sample mean | 8740.57 |
| Population mean | 8734.57 |
| **Difference** | **6** |

Again, extremely close.

### Conclusion

Bootstrap estimate is reliable.

---

## 13. 95% Confidence Interval — Male Customers

### Using Z-score method

- **Mean:** 9433.86
- **CI:** (8885.39, 9982.33)

### Using percentile method

- **CI:** (8911.18, 9970.64)

**Interpretation:** We are 95% confident that the true average purchase amount for male customers lies within this range.

---

## 14. 95% Confidence Interval — Female Customers

### Using Z-score method

- **CI:** (8190.26, 9290.87)

### Using percentile method

- **CI:** (8205.26, 9245.16)

**Interpretation:** We are 95% confident that the true average purchase amount for female customers lies within this range.

---

## 15. Confidence Interval Comparison

### Male CI
8885.39 – 9982.33

### Female CI
8190.26 – 9290.87

### Overlap Region
8885.39 – 9290.87

**Observation:** The confidence intervals overlap.

### Implication

- Difference exists in average spending
- But overlap indicates the difference may not be very strong statistically
- Additional hypothesis testing may be required

---

## 16. Key Statistical Learnings

### Why CLT Works Here

Even though purchase data is not normally distributed:

- Sample size = 300
- Repeated sampling performed
- Sampling distributions become approximately normal

Thus, CLT allows valid confidence interval estimation.

### Why Bootstrapping Works

Bootstrapping:

- Does not assume normality
- Uses resampling from observed data
- Provides robust estimates for confidence intervals

---

## 17. Business Insights

### Insight 1 — Male customers spend more on average

| Group | Mean Purchase |
|-------|---------------|
| Male | ₹9437.53 |
| Female | ₹8734.57 |

**Difference: ₹702.96**

### Insight 2 — Male customers represent most transactions

Male transactions ≈ **75%**

### Insight 3 — Purchase variability is high for both genders

Standard deviation exceeds **₹4,700** for both groups.

### Insight 4 — Sampling distributions are approximately normal due to CLT

### Insight 5 — Confidence intervals overlap, indicating that spending patterns are not drastically different

---

## 18. Recommendations

| # | Recommendation |
|---|----------------|
| 1 | Create targeted promotions for female customers to increase average basket size |
| 2 | Continue focusing on male customers since they contribute most revenue |
| 3 | Perform similar CLT and confidence interval analysis for: age groups, marital status, city categories |
| 4 | Conduct hypothesis testing (t-test) to formally determine whether the gender difference is statistically significant |
| 5 | Build personalized marketing campaigns using demographic segmentation |

---

## Final Conclusion

The Walmart dataset shows that **male customers spend approximately ₹703 more per purchase than female customers**.

Using Central Limit Theorem and Bootstrapping, sampling distributions for both genders become approximately normal. The 95% confidence intervals for male and female purchase amounts overlap, suggesting that while males spend slightly more on average, the difference is not overwhelmingly large. **Further hypothesis testing is recommended before making major business decisions.**
