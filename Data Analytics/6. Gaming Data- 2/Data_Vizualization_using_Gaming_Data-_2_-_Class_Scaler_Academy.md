# Data Visualization Using Gaming Data — Class Notes

## Session Overview

**Previous Topic:** Univariate and Bivariate Analysis
**Current Topic:** Multivariate Analysis (>2 variables)

---

## 1. Introduction to Multivariate Analysis

### Definition
- Multivariate analysis involves **more than two variables** (three, four, or more).
- Goal: Represent multiple variables in a visualization format simultaneously.

### Challenge: Adding a 3rd Variable to a 2D Plot
- 3D charts exist but are **not intuitive** on a 2D screen.
- Solution: Encode the third variable using visual properties like **color, size, or shape**.

### Example: Ice Cream Sales Dataset
| Variable | Type | Role |
|---|---|---|
| Ice Cream Brand (Magnum, Haagen-Dazs, Baskin Robbins) | Categorical | Color |
| Temperature | Continuous | X-axis |
| Sales | Continuous | Y-axis |

**Technique:** Shade/scatter points by brand color + add legend. This introduces a 3D chart within a 2D plot using **hue/color**.

---

## 2. Types of Multivariate Analysis

Three combinations:

| Code | Variables | Meaning |
|---|---|---|
| **CCN** | Categorical, Categorical, Numerical | Two categorical + one numerical |
| **CNN** | Categorical, Numerical, Numerical | One categorical + two numerical |
| **NNN** | Numerical, Numerical, Numerical | All three numerical |

---

## 3. Dataset Used: Video Game Sales

### Columns
| Column | Description |
|---|---|
| Name | Game name |
| Platform | Gaming platform |
| Year | Release year |
| Genre | Game genre |
| Publisher | Publishing company |
| NA_Sales | North America sales |
| EU_Sales | Europe sales |
| JP_Sales | Japan sales |
| Other_Sales | Sales in other regions |
| Global_Sales | Overall global sales |

### Data Filtering (Top-3 Selection)
- Filtered to **top 3 publishers**, **top 3 genres**, and **top 3 platforms** by count.
- Used `value_counts().head(3)` to get top categories.
- Applied `.loc[]` with `~isin()` to filter rows matching all three conditions simultaneously.
- Reset index using `df.reset_index(drop=True, inplace=True)`.

---

## 4. CNN Visualization — Scatter Plot with Hue

### Use Case
Visualize the **correlation between NA_Sales and EU_Sales**, differentiated by **Genre**.

### Code Snippet
```python
plt.figure(figsize=(10, 7))
sns.scatterplot(data=df, x='NA_Sales', y='EU_Sales', hue='Genre')
plt.xlabel('NA_Sales', fontsize=15)
plt.ylabel('EU_Sales', fontsize=15)
plt.title('EU vs NA vs Genre', fontsize=15)
plt.show()
```

### Key Insights
- **Sports & Action:** Clear **positive correlation** between NA and EU sales (orange/blue points trend upward together).
- **Miscellaneous:** Positive correlation but much more scattered → **weaker magnitude**.
- Can swap `hue='Genre'` to `hue='Publisher'` for publisher-level analysis:
  - **Electronic Arts:** Higher global sales across genres.
  - **Namco Bandai:** Sales plateau at lower levels.

---

## 5. CCN Visualization — Dodged Box Plot

### Use Case
Visualize **Global_Sales** for each **Publisher**, separated by **Genre**.

### Concept
- Combines two categorical variables (Publisher, Genre) with one numerical variable (Global_Sales).
- **Dodging:** Place box plots side-by-side per publisher, colored by genre.

### Code Snippet
```python
plt.figure(figsize=(12, 8))
sns.boxplot(data=df, x='Publisher', y='Global_Sales', hue='Genre')
plt.xlabel('Publisher', fontsize=15)
plt.ylabel('Global_Sales', fontsize=15)
plt.xticks(rotation=15, fontsize=15)
plt.title('...', fontsize=15)
plt.show()
```

### Key Insights
- **Activision** has higher overall global sales across all three genres vs. Namco Bandai (boxes sit at higher values).
- Within the **Miscellaneous** genre, Activision slightly edges Electronic Arts.
- **Namco Bandai:** Almost no median sales in every genre → lowest performer.
- **Action genre:** Electronic Arts & Activision have similar medians, but EA has more spread (higher variability).

### Box Plot Measures
A box plot shows: Maximum, 75th percentile, 50th percentile (median), 25th percentile, Minimum.

---

## 6. NNN Visualization — Bubble Chart

### Use Case
Represent **NA_Sales**, **EU_Sales**, and **JP_Sales** (all three numerical) simultaneously.

### Concept
- Uses `size` parameter in `scatterplot` to encode the third variable as **bubble size**.
- Here, **Rank** controls bubble size: larger bubbles = higher rank value, smaller dots = lower rank.

### Code Snippet
```python
sns.scatterplot(data=df, x='NA_Sales', y='JP_Sales', size='Rank')
plt.show()
```

### Key Insights
- As rank **decreases** (better games), bubble size **decreases**, but sales **increase**.
- This indicates a **negative correlation** between Rank and NA_Sales.
- Pattern is more prominent for North America than Japan.

> **Rule:** Lower the rank → Higher the sales.

---

## 7. Joint Plot

### Concept
Draws **three chart types simultaneously**:
1. **Scatter plot** (center) — bivariate relationship between x and y
2. **Histogram** (top & right margins) — univariate distributions
3. **KDE** (Kernel Density Estimation) — density curve overlay

### Parameters
- `kind='scatter'` → scatter + histograms/KDE
- `kind='reg'` → adds regression line
- `hue` → third categorical variable for categorization

### Code Snippet
```python
sns.jointplot(data=top3_data, x='NA_Sales', y='EU_Sales', kind='scatter', hue='Genre')
```

### Insights
- **Sports** genre has higher sales in North America (points spread further right).
- Combines univariate analysis (histogram) with bivariate analysis (scatter + KDE).

---

## 8. Pair Plot (`pairplot`)

### Concept
Displays **pairwise relationships** between all numerical columns as a grid of scatter plots, plus histograms on the diagonal.

### Code Snippet
```python
sns.pairplot(top3_data, hue='Genre')
plt.show()
```

- **Diagonal:** Histograms (univariate) for each individual column.
- **Off-diagonal:** Scatter plots of every pair of variables.

### Subsets
Can plot only specific columns:
```python
sns.pairplot(df[['NA_Sales', 'EU_Sales', 'JP_Sales']], hue='Genre')
```

---

## 9. Correlation Matrix + Heatmap

### Computing Correlation
```python
correl = top3_data.corr()  # Correlation between every numerical pair
```

- **Diagonal values = 1** (perfect correlation of a variable with itself).
- Values range from **-1 to +1**.

### Visualizing with Heatmap
```python
sns.heatmap(correl, cmap='Blues', annot=True)
plt.show()
```

### Reading the Heatmap
| Color | Meaning |
|---|---|
| **Darker blue** | Stronger positive correlation |
| **Lighter / white** | Weaker or negative correlation |

### Key Finding
- **Rank vs. Global_Sales = -0.91**: Very strong **negative correlation**. Lower rank = higher global sales.
- Can experiment with different `cmap` values: `'coolwarm'`, `'viridis'`, etc.

---

## 10. CCN Use Case — Olympics Medals (Dodge Bar Chart)

### Problem
Count of Gold, Silver, Bronze medals by country → CCN (Country=Categorical, Medal Type=Categorical, Count=Numeric).

### Approach: Dodged Bar Plot (NOT Box Plot)
- **Box plot is wrong here** because it shows 5 statistics (min, Q1, median, Q3, max), but we only have a single count value per country/medal pair.
- **Bar plot** correctly shows the fixed count values.

### Code Snippet
```python
# Create wide-format data
df_medals = pd.DataFrame({
    'Country': ['USA', 'China', 'Japan', 'Germany'],
    'Gold': [30, 25, 20, 15],
    'Silver': [25, 20, 18, 12],
    'Bronze': [20, 18, 15, 10]
})

# Convert wide format → long format using melt
df_long = pd.melt(df_medals, id_vars=['Country'], var_name='Medal', value_name='Count')

# Plot dodged bar chart
sns.barplot(data=df_long, x='Country', y='Count', hue='Medal')
plt.show()
```

### Why `pd.melt()`?
- Converts **wide format** → **long format**.
- `seaborn.barplot` expects long-form data for the `hue` parameter.

---

## 11. Summary of Chart Choices for Multivariate Analysis

| Variables | Notation | Recommended Chart |
|---|---|---|
| 1 Categorical + 2 Numerical | **CNN** | Scatter plot with hue / size |
| 2 Categorical + 1 Numerical | **CCN** | Dodged boxplot / Dodged barplot |
| 3 Numerical | **NNN** | Bubble chart (scatter with size) |
| All pairs relationship | — | Pair plot + Correlation heatmap |
| Scatter + Distribution | — | Joint plot |

---

## 12. Key Functions Recap

| Function | Purpose |
|---|---|
| `pd.DataFrame()` | Create a DataFrame from dictionary/list |
| `df.value_counts().head(3)` | Get top 3 most frequent categories |
| `~df['col'].isin([...])` | Filter out specific values |
| `.reset_index(drop=True, inplace=True)` | Reset consecutive index |
| `pd.melt()` | Wide → Long format conversion |
| `df.corr()` | Compute pairwise correlation matrix |
| `sns.scatterplot(x, y, hue, size)` | Scatter plot with color/size encoding |
| `sns.boxplot(x, y, hue)` | Box plot with dodging support |
| `sns.barplot(x, y, hue)` | Bar plot with dodging support |
| `sns.jointplot(x, y, kind, hue)` | Scatter + histograms + KDE |
| `sns.pairplot(df, hue)` | Pairwise scatter + histogram grid |
| `sns.heatmap(data, cmap, annot)` | Correlation matrix visualization |

---

## 13. Glossary of Key Terms

| Term | Description |
|---|---|
| **Multivariate Analysis** | Involves more than two variables for analysis, visualizable in formats like 3D charts or by using color coding. |
| **CCN** | Represents data with two categorical and one numerical variable. |
| **CNN** | Represents data with one categorical and two numerical variables. |
| **NNN** | Involves the use of three numerical variables. |
| **Correlation Matrix** | A grid showing the correlation coefficients between variables. |
| **Heat Map** | Graphical representation of data where values are depicted by color. |
| **Joint Plot** | Combines scatter plots, histograms, and KDE in one figure. |
| **Hue Parameter** | Determines the color of different categories in visualization. |
| **Seaborn** | A Python visualization library based on matplotlib, used for creating plots. |

---

## 14. Assignment & Challenge Topics
- Multivariate visualization using gaming datasets
- Dodge bar chart implementation with `pd.melt()`
- Choosing appropriate chart types based on variable combinations (CCN/CNN/NNN)
- Interpreting correlation heatmaps and joint plots

---

## 15. Additional Concepts & Best Practices

### Visual Encoding for Multi-Dimensional Data
Beyond color and size, additional encoding channels include:
- **Shape** — useful when color is insufficient or for print (different markers like circles, squares, triangles)
- **Position** — most accurate channel; always use scatter/histogram positioning over area estimation
- **Orientation** — angle of bars/lines, rarely used as primary encoding
- **Length** — bar length, pie slice length

### Correlation Strength Guide
| | +1 to +0.7 | +0.7 to 0 | 0 to -0.7 | -0.7 to -1 |
|---|---|---|---|---|
| Strength | Strong Positive | Weak/No Positive | Weak Negative | Strong Negative |

**Important:** Correlation does **not** imply causation. A strong correlation between two game variables doesn't mean one causes the other — a third unseen variable could be driving both.

### KDE (Kernel Density Estimation)
- Estimates the probability density function of a continuous variable
- Similar to a smoothed histogram
- In joint plots, shows where data points cluster most densely
- A tighter/narrower KDE curve indicates lower variance; wider curve = higher spread

### Regression Line in Joint Plots (`kind='reg'`)
- A regression line is the **line of best fit** (least squares regression) through scatter points
- Slope direction indicates correlation direction: upward slope = positive, downward = negative
- The shaded region around it is a **confidence interval** (typically 95%)
- Closer data points to the line = stronger linear relationship

### Color Map Recommendations
| cmap | Best For | Accessible? |
|---|---|---|
| `'viridis'` | General purpose, perceptive uniformity | Yes (colorblind-friendly) |
| `'plasma'` | Emphasizing high-contrast regions | Limited |
| `'Blues'` | Professional reports, light backgrounds | No |
| `'coolwarm'` | Diverging data (negative to positive) | Sometimes |
| `'Reds'` / `'Oranges'` | Warm-toned palettes | No |

### Data Filtering Best Practices
- Use `value_counts()` to understand category distributions before filtering
- Top-N filtering should be **justified** — explain why top 3 (reduces noise, focuses on relevant data)
- After `.loc[]` filtering, always check the new index with `df.index` and reset it
- Compare filtered vs. full dataset using `len(df)` to understand data loss

### Common Pitfalls & Warnings
1. **Overloading a single chart** — avoid adding more than 3–4 variables; readability degrades after that
2. **Misleading bubble sizes** — always include a size legend with labeled values (e.g., "Rank = 5000")
3. **Ignoring outlier impact** — box plots show outliers as whisker extensions; check for extreme values in scatter plots
4. **Correlation = Causation fallacy** — never conclude causality from correlation alone
5. **Using box plots for single values** — a dodge bar chart is correct when you have fixed count values (not distributions)

### When to Use Which Chart — Decision Flow

```
How many variables?
├── 1 variable → Histogram, KDE plot, violin plot
├── 2 variables (both numerical) → Scatter plot, line plot
├── 2 variables (one categorical, one numerical) → Box plot, bar plot, violin plot
├── 3 variables (NNN - all numerical) → Bubble chart, pair plot
├── 3 variables (CNN - 1 cat, 2 num) → Scatter with hue/size, jitter plot
├── 3 variables (CCN - 2 cat, 1 num) → Dodged boxplot, dodged barplot
└── All numerical columns pairwise → Pair plot + correlation heatmap
```

### Practical Seaborn Customization Tips
- `sns.set_theme(style='whitegrid')` — clean background for presentations
- `plt.tight_layout()` — prevents label clipping in multi-panel plots
- `palette='husl'` or `palette='Set2'` — use colorblind-safe palettes explicitly
- `sns.despine()` — removes top and right spines for a cleaner look
- `fig, axes = plt.subplots(1, 2, figsize=(14, 6))` — create side-by-side comparisons

