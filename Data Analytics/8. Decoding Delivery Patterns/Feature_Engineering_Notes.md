# Feature Engineering with Real-World Logistics Data — Detailed Notes

## 1. Introduction to Feature Engineering

### What is a Feature?
- A **feature** is an attribute/column in a dataset that represents a measurable property or characteristic
- Features are the input variables used to predict a target
- Example: In a product prediction dataset, `Education`, `Gender`, `Income`, and `Fitness Level` are features

### Feature vs. Target Variable
- **Features**: Input attributes used for prediction (e.g., Education, Gender, Income, Fitness Level)
- **Target**: The column we want to predict (e.g., `"Product"` — not a feature in this context)

---

## 2. Creating New Features: "Able to Pay EMI" Example

### Step-by-Step Feature Creation

**Context:** Predicting whether a customer can pay their loan EMI based on existing data.

| Concept | Formula / Logic |
|---|---|
| **Loan Amount per Year** | `Loan Amount × 1000 / Loan Term (years)` |
| **Monthly EMI** | `Loan Amount × 1000 / (Loan Term × 12)` |
| **Able to Pay EMI** | `30% of Income ≥ EMI` → True/False → Converted to 1/0 |

### Why the 30% Rule?
- A person doesn't spend their entire income on loan repayment — they have other expenses
- Industry standard: banks typically require at least **30% of income** to remain after EMI deductions
- Without this buffer, even if `Income > EMI`, the customer may still struggle to pay

### Business Logic Over Pure Algorithmic Thinking
- Feature engineering is **not purely algorithmic** — it requires fundamental business logic
- Example: If you used `income > EMI` (without 30% buffer), a wrong signal ("able to pay") would mislead the model
- Resulting loan status analysis showed:
  - When `"Able to Pay EMI = True"` → **~70%** had Loan Status = Yes
  - When `"Able to Pay EMI = False"` → **~50/50 split** for Loan Status
- This feature effectively **segregates the two classes**, adding significant predictive value

### Garbage In, Garbage Out (GIGO) Principle
> **A model is only as good as the data you feed it.**
- Even the most advanced models (Transformers, LLMs) will produce garbage if fed poor-quality features
- Wrong logic or incorrect business rules in features leads to wrong predictions regardless of algorithm complexity

---

## 3. Exploratory Data Analysis: Feature-Target Relationships

### Cross-Tabulation Examples

#### Credit History vs. Loan Status

| Credit History | Count | Proportion with Loan Status = Yes |
|---|---|---|
| **1 (Good)** | 475 (378 + 97) | **~80%** (378/475) |
| **0 (Bad)** | 89 | **~8%** (7/89) |

- Strong relationship: Good credit history → **80% chance** of getting a loan
- Bad credit history → **8% chance** of getting a loan

#### Dependence Analysis
- Banks prefer applicants with **fewer dependents** (less financial burden)
- Categories like `"3+"` are consolidated into a single integer `3` for cleaner analysis

### Chi-Square Test
- Used to test **dependence between two categorical variables**
- Tests the **null hypothesis**: Variables are independent
- Should be used alongside observation-level probability analysis for statistical confirmation

---

## 4. Missing Value Handling

### Three Rules of Thumb

| Missing % | Strategy | Rationale |
|---|---|---|
| **< 1%** (e.g., 0.5%) | **Drop the rows** | Removing a few rows doesn't impact dataset; imputation wastes effort |
| **60-90%+** | **Drop the column** | >60% artificial values distort reality — column is unusable |
| **1–60%** | **Impute with strategy** | Significant data exists; dropping loses information |

### Imputation Strategies by Data Type

#### Numerical Columns
| Strategy | When to Use | Example |
|---|---|---|
| **Mean** | Values are close together, low variance | `[10, 20, 17, 19, 21, ?, 24]` → mean ≈ 18.5 |
| **Median** | Data has outliers that skew the mean | `[10, 20, 17, 19, 21, 190, 24]` → median ≈ 20, unaffected by outlier 190 |
| **Mode (Most Frequent)** | Values cluster around a common value | If 10 appears most frequently |
| **Constant Value** | No clear guess; signals missingness | Impute with `2` or another sentinel value to mark as "imputed" |

#### Categorical Columns
| Strategy | When to Use | Example |
|---|---|---|
| **Mode** | Majority category is clear | If most values are `"Yes"` → impute missing as `"Yes"` |
| **Constant / Custom Label** | No reliable pattern; 50/50 split | Impute with `"Other"` or `"Unknown"` to signal unknown status |

> **Key Insight:** Never impute mode blindly in a 50/50 situation — it forces an assumption that may be wrong. Use a sentinel value instead.

### Implementation: SimpleImputer (scikit-learn)

```python
from sklearn.impute import SimpleImputer

# Numerical columns → median strategy
imputer = SimpleImputer(strategy='median')
df_numeric = imputer.fit_transform(df_num)

# Categorical columns → most frequent strategy
imputer_cat = SimpleImputer(strategy='most_frequent')
```

---

## 5. Outlier Treatment

### What Are Outliers?
- Data points that **significantly deviate** from the rest of the data
- Can skew simpler models and produce biased estimates
- Often represent corner cases not applicable to the majority of the population

### Method 1: IQR (Interquartile Range) — Recommended for Non-Normal Data

| Threshold | Formula |
|---|---|
| **Lower Bound** | `Q1 - 1.5 × IQR` |
| **Upper Bound** | `Q3 + 1.5 × IQR` |
| **IQR** | `Q3 - Q1` |

- Values **below lower bound** or **above upper bound** are outliers
- `Q1 = 25th percentile`, `Q3 = 75th percentile` (quantile scale: 0–1)

```python
df_num = df[numerical_columns]
q1 = df_num.quantile(0.25)
q3 = df_num.quantile(0.75)
iqr = q3 - q1

lower_bound = q1 - 1.5 * iqr
upper_bound = q3 + 1.5 * iqr

df_clean = df[(df_num < lower_bound | df_num > upper_bound)].index
```

### Method 2: Z-Score — Best for Normally Distributed Data

- Z-score measures how many standard deviations a value is from the mean
- In a normal distribution, **99%+ of data lies between Z = ±3**
- Values beyond `Z < -3` or `Z > +3` are considered outliers

```python
from scipy.stats import zscore
import numpy as np

z_scores = zscore(df['loan_amount'])
outlier_indices = np.where((z_scores < -3) | (z_scores > 3))[0]

df_clean = df[~df.index.isin(outlier_indices)]
```

### When to Use Which Method?
| Distribution | Recommended Method |
|---|---|
| **Normal / Symmetric** | Z-Score |
| **Skewed / Non-Symmetric** | IQR |

---

## 6. Categorical Encoding

### Types of Categorical Variables

| Type | Definition | Examples | Encoding Method |
|---|---|---|---|
| **Ordinal** | Has a meaningful order/ranking | Income bins: Low < Medium < Average < High; Dependents; Education level | Label Encoding |
| **Nominal** | No natural order | Gender (Male/Female), Married (Yes/No), Property Type | One-Hot Encoding / Target Encoding |

### 1. Label Encoding (Ordinal Data)
- Assigns ordered integers: `Low → 0, Medium → 1, Average → 2, High → 3`
- Signals to model that one category is "higher" than another

```python
from sklearn.preprocessing import LabelEncoder
le = LabelEncoder()
df['education'] = le.fit_transform(df['education'])
```

### 2. One-Hot Encoding (Nominal Data)
- Creates a binary column for each category
- Example: Property Type with values `[Rural, Semi-Urban, Urban]` → 3 new columns

| Row | Rural | Semi-Urban | Urban |
|---|---|---|---|
| 1 | 0 | 1 | 0 |
| 2 | 1 | 0 | 0 |
| 3 | 0 | 0 | 1 |

- Each column = presence (1) or absence (0) of that category per row

### 3. Target Encoding (Useful for Both Types)
- Replaces categorical value with the **probability of the target** given that category

| Property Type | Probability of Loan Status = Yes |
|---|---|
| Rural | 0.63 (63%) |
| Semi-Urban | 0.7977 (~80%) |
| Urban | 0.67 (67%) |

```python
from category_encoders import TargetEncoder
te = TargetEncoder()
df['property_encoded'] = te.fit_transform(df['property'])
```

### Why Encode at All?
- **ML models cannot understand text/string values directly**
- Text must be converted to numerical representations (similar to how computers convert text to binary)
- Encoding preserves meaningful relationships between categories and the target variable

---

## 7. Glossary of Key Terms

| Term | Definition |
|---|---|
| **Feature Engineering** | Process of creating new features from existing variables to add more information for predictions. |
| **Simple Imputer** | A function in scikit-learn used to impute missing values with strategies like mean, median, or mode. |
| **Exploratory Data Analysis (EDA)** | Process of analyzing datasets to summarize their main characteristics, often using graphical methods. |
| **Binning** | Technique in feature engineering used to transform continuous variables into discrete ones. |
| **Z Score** | A statistical measurement of a value's relationship to the mean in a group of values. Used to detect outliers. |
| **Loan Term to Years** | Conversion of loan repayment period from months to years during feature engineering by dividing by 12. |
| **Outliers** | Data points significantly different from others; often detected using IQR or Z score and handled in data preprocessing. |
| **Target Variable** | The variable that a model aims to predict or estimate during a machine learning task. |
| **Mode Imputation** | Replacing missing values with the most frequent value in the dataset, used for categorical data. |
| **Credit History** | A feature used to assess someone's past behavior in repaying loans. |
| **Normalization** | Scaling data to fit within a small, specified range, usually 0 to 1. |
| **Target Encoding** | A categorical encoding method that uses the target variable to convert categories into numeric values. |

## 8. Normalization & Standardization (Preview)
- Brings features onto the **same scale**
- Covered in more detail in subsequent sessions — referenced for further study

---

## 9. Analogy: Feature Engineering = BMI Calculation

To simplify understanding, feature engineering can be compared to how Body Mass Index (BMI) works:

- **BMI** provides a straightforward fitness metric by combining two raw values (weight and height) into one meaningful number
- Similarly, **feature engineering** derives new meaningful metrics from raw data — like combining income and savings into "purchasing capacity" or creating "income brackets" from raw salary figures
- Just as BMI adds diagnostic value that raw weight alone cannot, engineered features add predictive power that raw columns alone cannot provide

---

## 10. Key Takeaways Summary

| Topic | Main Point |
|---|---|
| **Definition** | Feature engineering uses domain knowledge to extract features from raw data that make ML algorithms work better |
| **Examples** | Purchasing capacity (income + savings), BMI (weight + height), income brackets, converting durations |
| **Missing Data** | < 1% → drop rows; > 60% → drop column; in-between → impute strategically |
| **Imputation** | SimpleImputer: mean for normal data, median for data with outliers, mode for categorical |
| **Outliers** | IQR for skewed data (Q1 − 1.5×IQR to Q3 + 1.5×IQR); Z-score > 3 for normal distributions |
| **Encoding** | Label Encoding for ordinal; One-Hot / Target Encoding for nominal variables |
| **EDA First** | Understand distributions and feature-target relationships before engineering features |
