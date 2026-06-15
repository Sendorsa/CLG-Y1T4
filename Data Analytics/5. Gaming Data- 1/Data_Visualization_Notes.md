# Data Visualization using Gaming Data — Class Notes

## Overview
**Topic:** Analytics case studies through data visualization  
**Tools:** Matplotlib (`matplotlib.pyplot` as `plt`) and Seaborn (`sns`)  
**Dataset:** Video Games dataset (columns: `rank`, `name`, `platform`, `year`, `genre`, `publisher`, `na_sales`, `eu_sales`, `jp_sales`, `other_sales`, `global_sales`)

---

## 1. Types of Variables

### Numerical / Continuous Data
- Values without breaks; can go to any precision
- Example: height (150cm, 150.1cm, 160cm...), sales figures
- Can always be treated as continuous regardless of numeric type

### Categorical Data
- Fixed set of values/discrete bins
- **Nominal:** No inherent order — e.g., branches (CS, AI, Business), genre, platform, publisher
- **Ordinal:** Has a natural order — e.g., class 1 to 5, school standards

### Year Column: Gray Area
- Can be treated as categorical (if few/discrete values) or continuous (if wide range like 1800–2026)
- Decision depends on the number of distinct categories

---

## 2. Plot Selection Framework

**Step 1:** How many variables? → Univariate / Bivariate / Multivariate  
**Step 2:** What types? → Continuous vs Categorical  
**Combinations:**
| Variable Types | Chart Examples |
|---|---|
| Continuous + Continuous | Scatter plot, line chart |
| Categorical + Categorical | Pie chart |
| Continuous + Categorical | Bar chart, box plot, histogram |

> **Note:** Humans can only visualize up to 3 dimensions. Beyond that, use multiple charts or ML approaches.

**Key Principle:** *Correlation does NOT imply causation.* Multiple factors may contribute to an observed relationship.

---

## 3. Univariate Visualization (Single Variable)

### 3.1 Bar Chart / Count Plot (Categorical Data)
- Shows the **frequency/count of each category**
- `plt.bar()` or `sns.countplot(x='genre', data=df, palette='viridis')`
- X-axis: categories (e.g., `df['genre'].index`)
- Y-axis: counts (e.g., `df['genre'].value_counts()`)

**Styling:**
- `plt.figure(figsize=(12, 8))` — increase figure size to avoid label overlap
- `rotation=90` in `plt.xticks()` — rotate labels vertically
- `width=0.2` — adjust bar width
- `plt.title()`, `plt.xlabel()`, `plt.ylabel()`, `plt.xticks(fontsize=...)`

**Inference from dataset:** Action and Sports are the top two genres by frequency. "Miscellaneous" groups low-count categories — ignore for primary analysis.

### 3.2 Pie Chart (Categorical / Proportional Data)
- Represents **percentage/proportion** of each category
- `plt.pie()` with parameters:
  - `labels` — category names
  - `autopct='%.2f%%'` — show percentages rounded to 2 decimal places
  - `startangle=90` — start the first slice at top
  - `explode=[0.2, 0, 0, 0]` — pull a slice outward by given fraction
- **Univariate:** Only one variable represented (percentage is a derived metric, not a separate variable)

**Inference from regional sales pie chart:**
- ~85% of sales come from just 3 regions: North America (~32%), Europe (~23%), Japan (~30%)
- Strategic implication depends on business goal:
  - *Increase sales:* Focus on top 3 regions
  - *Expand market:* Target underrepresented regions

### 3.3 Histogram (Continuous Data — Distribution)
- Shows **distribution of a continuous variable** across bins
- `plt.hist(data['year'], bins=10)` or `sns.histplot(data=df, x='year', bins=10)`
- Y-axis: frequency/count; X-axis: value ranges (bins)
- Bins are customizable (default = 10)

**Inferences:**
- Most games were produced in a specific time period (central region of the distribution)
- Distribution is left-skewed (tail on the left)
- Lower bins → high-level summary; more bins → finer detail (but diminishing returns beyond a point)
- `plt.hist(data, bins=10, return_counts=True)` returns bin ranges and counts per bin

### 3.4 KDE Plot — Kernel Density Estimation
- Estimates the **probability density function (PDF)** of data
- Available in Seaborn: `sns.kdeplot(data=df['year'])`
- Y-axis: probability density (not frequency)
- Useful for understanding where data is most dense and planning resources
- Area under the curve between two points = probability of data falling in that range

**Use case:** Estimate peak-hour demand to plan staffing/resources accordingly.

### 3.5 Box Plot — Five Number Summary
- Displays: **minimum, Q1 (25th percentile), median/Q2, Q3 (75th percentile), maximum**
- **IQR** = Q3 − Q1 (`df['col'].quantile(0.75) - df['col'].quantile(0.25)`)
- **Outliers:** Values beyond `Q1 − 1.5×IQR` or `Q3 + 1.5×IQR`
  - The factor 1.5 derives from statistical theory (Tukey's fences); it is not arbitrary
  - Alternative outlier detection: values beyond ±3 standard deviations (for normal distributions)
- `sns.boxplot(y='global_sales', data=df, figsize=(15, 8))`

**Inference:** The global sales box plot shows right-skewed distribution (most values on the left, few extreme high outliers).

### 3.6 Line Chart (Time Series / Trend)
- Shows **trends over a continuous axis** (usually time)
- `sns.lineplot(x='year', y='na_sales', data=df_filtered)`
- Default connects points with lines
- For multiple series, use `label` parameter + `plt.legend()` for identification

---

## 4. Bivariate Visualization (Two Variables)

### 4.1 Continuous vs Continuous — Scatter Plot & Line Chart
- **Scatter plot:** `sns.scatterplot(x='rank', y='global_sales', data=df)`
  - Shows individual data points; better for spotting patterns in large datasets
  - Reveals correlation direction (positive/negative) and clusters
- **Line chart:** Connects data points; best when order/magnitude of points matters (e.g., time series)

### Inference: Rank vs Global Sales
- **Negatively correlated** — as rank increases, global sales tend to decrease
- However, not every point follows this trend → rank is not the only factor determining sales

### Example: Sales Trend for Longest-Running Game
1. Group by game name, compute `max_year - min_year` = duration
2. Sort descending, find top 5 longest-running games (result: ISEKKI)
3. Filter data for ISEKKI and plot NA sales over years
4. **Inference:** Sales grew from ~1990 to 2005, then declined

### Multi-Line Chart
- Plot multiple lines on the same chart to compare trends (e.g., ISEKKI vs Baseball)
- Always use `label` parameters and `plt.legend(loc='best')` for clarity
- Legend positioning: `'upper right'`, `'lower left'`, etc.

---

## 5. Class Quiz — Plot Selection Summary

| Scenario | Best Chart | Reason |
|---|---|---|
| Range for which most students scored (continuous marks) | **Histogram** | Shows distribution across ranges |
| Count of customers by payment mode (categorical count) | **Count/Bar Plot** | Question asks for count, not proportion |
| Proportion of people who smoke (categorical percentage) | **Pie Chart** | Displays proportions/percentages |

---

## 5.5 Practical Application: Video Games Market Case Study
- **Business Problem:** Deciding which game genres to focus on for future development/investment based on sales data.
- **Approach:** Use bar plots (counts) and box plots/revenue breakdowns across genres to identify top performers and outliers.
- **Insight:** Visualizations guide strategy — e.g., if certain categories dominate by count but not revenue, shift focus accordingly.

---

## 6. Matplotlib/Seaborn Anatomy of a Chart

| Element | Purpose |
|---|---|
| `figure` | Complete entirety of the visualization; can contain multiple subplots |
| `axis` (x, y) | Number and position on respective axes |
| `xlabel / ylabel` | Labels for x and y axes |
| `title` | Title of the specific subplot |
| `suptitle` | Broad description covering the entire figure |
| `legend` | Identifies multiple plotted series |

---

## 7. Code Reference Summary

```python
# Imports
import matplotlib.pyplot as plt
import seaborn as sns

# Bar / Count Plot
plt.figure(figsize=(12, 8))
sns.countplot(x='genre', data=df, palette='viridis')
plt.xticks(rotation=0)
plt.title('Games per Genre')
plt.xlabel('Genre')
plt.ylabel('Count')

# Pie Chart
plt.pie(df['region'].value_counts(), labels=df['region'].unique(),
        autopct='%.2f%%', startangle=90, explode=[0.2] + [0]*(len(df.columns)-1))

# Histogram
plt.hist(df['year'], bins=10)
n, bins, patches = plt.hist(df['year'], bins=10, return_counts=True)

# KDE Plot
sns.kdeplot(data=df['year'])

# Box Plot
sns.boxplot(y='global_sales', data=df)

# Scatter Plot
sns.scatterplot(x='rank', y='global_sales', data=df)

# Line Chart
sns.lineplot(x='year', y='global_sales', data=df_filtered, label='ISEKKI')
plt.legend(loc='best')
plt.title('Global Sales Trend')
plt.xlabel('Year'); plt.ylabel('Global Sales')
```

---

## 8. Key Takeaways

1. Always start by classifying your variables: **number** and **type** (continuous vs categorical)
2. **Histograms** → distribution & skewness; **Box plots** → five-number summary & outliers; **Scatter plots** → correlation between two continuous variables; **Bar/Count plots** → category frequencies; **Pie charts** → proportions; **Line charts** → trends over time
3. Always relate visualizations to **business goals** — e.g., resource planning, market focus, product recommendations
4. Correlation ≠ Causation — always consider confounding factors (e.g., time as a third variable)
5. Customize charts (`figsize`, `rotation`, `palette`) to improve readability and clarity
6. When analyzing distributions, the choice of **number of bins** matters — fewer bins give high-level views; more bins add detail but with diminishing returns

---

## 9. Definitions

| Term | Definition |
|---|---|
| Univariate Analysis | Analysis involving a single variable to understand its distribution. |
| Bivariate Analysis | Analysis involving two variables to understand the relationship between them. |
| Multivariate Analysis | Analysis of more than two variables to understand relationships and interactions. |
| Categorical Data | Data divided into specific categories without intrinsic order. |
| Continuous Data | Data that can take any value within a range and is not discrete. |
| Histogram | A plot used for displaying the distribution of continuous data. |
| Bar Chart | A plot used for categorical data to show counts or frequencies. |
| Scatter Plot | A plot for analyzing relationships between two continuous variables. |
| Box Plot | A graphical representation of data that shows the distribution through five-number summary. |
| Pie Chart | A circular graph used to display proportions and percentages of categories. |
| Kernel Density Estimation (KDE) | A method to estimate the probability density function of a variable. |
| Line Chart | A type of chart used to display information as a series of data points connected by straight line segments. |
