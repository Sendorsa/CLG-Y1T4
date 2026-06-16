# Detailed Notes: Data-Driven Retail & Fitness — Applying Descriptive Statistics

## Session Overview
- **Topic:** Descriptive and Inferential Statistics (Case Studies)
- **Context:** Class session with quiz preparation
- **Duration Target:** Sessions wrap at 1150; students keep only laptops in quiz zone

---

## Topic 1: Mean vs. Median for Skewed Distributions

### Scenario: Revenue Distribution
- When dealing with a **skewed distribution** of revenue data, the key question is: *Which measure of central tendency is more representative?*

### Answer: **Median** is better than Mean

#### Why?
- **Outliers in revenue** typically consist of large values that are low in frequency (e.g., a few very high-revenue customers/outliers)
- These outliers **pull/skew the mean toward themselves**, making it unrepresentative of the typical value
- The **median** is **robust to outliers** — it only depends on the middle position of sorted data, not the magnitude of extreme values

#### Key Takeaway:
> For skewed distributions (especially with high-end outliers like revenue), **median** should be the go-to metric for representation. Mean is appropriate when the distribution is symmetric/normal.

---

## Topic 2: P-Value Explained

### What is a P-Value? (Plain Language)
- A p-value helps you **judge whether to reject or fail to reject the null hypothesis (H₀)**
- It quantifies **how surprising your data** would be if the null hypothesis were truly true
- *Lower intuition:* "If there were no real effect (null is true), how surprising would these results be?"

### How is P-Value Used?
1. Compare the p-value against a **significance threshold (α)**:
   - Common significance levels: **0.05** or **0.01**
2. Decision Rule:
     | P-value | Comparison to α | Decision          |
     |---------|-----------------|-------------------|
     | p ≤ α   | Below/equal     | **Reject H₀**     |
     | p > α   | Above           | **Fail to reject H₀** |

### Industry Considerations:
- Choice of significance level (0.05 vs 0.01) depends on the industry/context
- 0.01 is more stringent (requires stronger evidence to reject H₀)
- 0.05 is standard for many social/business sciences

---

## Key Concepts Summary Table

| Concept | Description | Key Point |
|---------|-------------|-----------|
| **Skewed Distribution** | Asymmetric data with outliers on one tail | Common in revenue, income data |
| **Mean** | Arithmetic average | Sensitive to outliers |
| **Median** | Middle value when sorted | Robust to outliers — use for skewed data |
| **P-value** | Probability of observing data (or more extreme) if H₀ is true | Used to decide on H₀ rejection |
| **Significance Level (α)** | Threshold for p-value decision | Commonly 0.05 or 0.01 |
| **Null Hypothesis (H₀)** | Assumption of "no effect" | What we test against |

---

## Topic 3: Data Normalization & Standardization

### Data Normalization
- Scales data to a particular range; important for ML models to reduce bias from different scales.

#### Min-Max Normalization
- **Range:** Scales features to 0–1.
- **Formula:** 
  x′ = (x − min(x)) / (max(x) − min(x))

### Data Standardization
- Transforms data to have a mean of 0 and standard deviation of 1.
- **Z-score transformation:** z = (x − μ) / σ
- Crucial for algorithms like SVM and K-Means that assume centered data.

---

## Topic 4: Outlier Detection & Treatment

### Detection Techniques
| Method | Rule |
|--------|------|
| **IQR** | Below Q1 − 1.5×IQR or above Q3 + 1.5×IQR |
| **Z-score** | |Z| > 3 |

### Outlier Treatment
- **Clipping:** Limit data to a given range, e.g., the 5th to 95th percentile.

---

## Topic 5: Probability Distributions

### Key Ideas
- **Conditional Probability:** Likelihood of an event given specific constraints/conditions.
- **Marginal Probability:** Overall probability of a single event irrespective of other variables.
- Important for interpreting and analyzing data across segments (e.g., customer segmentation).

---

## Topic 6: Case Study — Treadmill Customer Profiles

### Approach
1. Analyze customer data to identify factors influencing treadmill-purchase decisions (gender, age, income, usage metrics).
2. Create **customer profiles** based on probability distributions.
3. Recommend treadmill models using thresholds derived from statistical analysis:
   - **Income threshold**
   - **Usage level**

### Key Takeaway
- Probability-based profiling enables personalized, data-driven product recommendations rather than one-size-fits-all suggestions.

---

## Topic 7: Additional Statistical Concepts

### Vocabulary

| Term | Description |
|------|-------------|
| **Pre-processing** | Preparation phase in machine learning involving encoding, scaling, etc. |
| **Cross Tabulation** | A method to quantitatively analyze the relation between multiple variables. |
| **Margin Parameter** | Inclusion of total counts in cross-tabulation for comprehensive analysis. |
| **Vectorization** | Optimization method applying functions across entire arrays without explicit loops. |
| **Bootstrapping** | A statistical method involving resampling with replacement to estimate sample variance. |
| **Central Limit Theorem** | Theorem stating the distribution of sample means approximates a normal distribution as sample size increases. |
| **Index Normalization** | Normalizing data row-wise to create proportions. |

---

## Action Items / Reminders
- Review for the quiz on descriptive & inferential statistics
- Quiz policy: Keep bags outside, only laptops allowed
- Session duration target: wrap at 1150
