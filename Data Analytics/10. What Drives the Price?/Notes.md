# Notes: What Drives the Price? – Predicting Used Car Value with Linear Regression

---

## Part 1: Confidence Intervals

### Point Estimate vs. Confidence Interval
- **Point estimate**: A single value approximating a population parameter (e.g., sample mean ≈ population mean).
- Problem: A single number gives no sense of certainty or variability.
- **Confidence interval**: A range of plausible values around the point estimate, quantifying uncertainty.

### Calculating a 95% Confidence Interval (Two Methods)
1. **Percentile method**: Sort bootstrap samples → take 2.5th percentile as lower bound, 97.5th as upper bound.
   - Formula: `np.percentile(boot_dist, (100 - CI) / 2)` for lower; `100 - lower` for upper.
2. **Standard error method**:
   - `SE = std / sqrt(n)`
   - Bounds: `mean ± 1.96 × SE`

### Wal-Mart Case Study (Applied Exercise)
- Analyze sales data by gender and marital status.
- Calculate confidence intervals for spending differences (95% CI).
- Extension: Repeat for 90% confidence.
- Tools used: box plots, descriptive statistics, visualization → then CI calculation.

### Exam Tips
- You may be asked to calculate a CI in the exam using either method.
- Both are acceptable as long as the answer is correct.

---

## Part 2a: Bootstrapping

### What is Bootstrapping?
- **Resampling with replacement** from a dataset to create multiple simulated samples.
- Calculate the desired statistic (e.g., mean) across these samples.
- Use the distribution of statistics to estimate accuracy (e.g., confidence intervals).

### Example Process:
1. Draw many bootstrap samples (each same size as original, sampling with replacement).
2. Compute the mean for each sample.
3. The distribution of these means approximates a **normal distribution** due to the Central Limit Theorem.
4. Use this distribution to derive confidence intervals.

### Why It Matters:
- Provides a way to estimate uncertainty without assuming a specific underlying population distribution.
- Connects directly to CI calculation via the percentile method (see Part 1).

## Part 2: Supervised Learning – Regression vs. Classification

| Aspect | Regression | Classification |
|--------|-----------|----------------|
| **Output** | Continuous value (e.g., price) | Discrete category/classes |
| **Example** | Predict used car price at Cars24 | Decision: whether to buy a car |

### Key Concepts
- **Supervised learning**: Model has both input features *and* output labels (historical data).
- **Goal**: Build a model that **generalizes** — performs well on unseen future data, not just memorize training data.
- **Training set**: Shows the model patterns to learn.
- **Validation set**: Tuned hyperparameters.
- **Test set**: Unseen data; final evaluation proxy (like an exam tests whether a student truly learned concepts vs. rote-learned quiz answers).

---

## Part 3: Linear Regression

### Case Study: Cars24 Pricing
Predict the selling price of a used car based on features (predictors):
- Age, kilometers driven, number of scratches, engine CC, mileage, fuel type, transmission, seating capacity make, model, etc.

### Linear Equation
```
y = A1·x1 + A2·x2 + A3·x3 + … + Ak·xk + B
```
- **y** = output (selling price, continuous)
- **xi** = input features (predictors)
- **Ai** = coefficients (weights for each feature)
- **B** = intercept

### Dimensionality in Linear Regression
- 2D → line
- 3D → plane
- >3D → **hyperplane** (still linear, just not visualizable)

### Key Preprocessing Steps

#### 1. Handling Categorical Variables
- **One-hot encoding**: Creates N new columns for N unique categories. Causes the "curse of dimensionality" with high-cardinality features (e.g., 3000+ car models → 3000 extra features). Avoid here.
- **Target encoding** (preferred here): Replace each category with the average target value of that group (e.g., replace "Maruti" with average selling price of all Maruti cars).
- **Label encoding**: Assigns integer labels – not suitable here since there's no ordinal relationship between makes.

#### 2. Scaling / Normalization
- **Why?** Different feature scales make coefficient comparison meaningless and affects model convergence.
- **MinMax scaling** (used here): Squeezes values to [0, 1]. `fit_transform()` from `MinMaxScaler`.

#### 3. Missing Values
- Linear regression cannot handle nulls → impute (e.g., mean imputation via `SimpleImputer(strategy='mean')` or `fillna(method='ffill')`).

### Critical: Split Before Preprocessing!
- **Rule**: Always split data into train/test *before* any preprocessing (scaling, encoding).
- **Reason**: If you fit scaler/encoder on the full dataset, information from the test set leaks into training → **data leakage**. Test set must simulate truly unseen future data.

---

## Part 4: Building the Model

### Steps in Code
1. Split data: `train_test_split(X, y, test_size=0.3, random_state=42)` → 70% train, 30% test.
2. Encode features: Use target encoding for high-cardinality categoricals.
3. Impute missing values (mean strategy).
4. Scale features: `MinMaxScaler().fit_transform()`.
5. Train model:
   ```python
   from sklearn.linear_model import LinearRegression
   model = LinearRegression()
   model.fit(X_train, y_train)
   ```

### Inspecting Parameters
- **Coefficients**: Access via `model.coef_` — one value per feature.
- **Intercept**: Access via `model.intercept_`.
- Together, coefficients + intercept = total parameters.

### Univariate vs. Multivariate
- **Univariate**: `y = A·x + B` (one feature) → 1 coefficient + 1 intercept = 2 parameters.
- **Multivariate**: Multiple features → k coefficients + 1 intercept = k+1 parameters. Coefficients and intercept values change with the data.

### How the Model Learns
- Given features (e.g., model year) and price, the model finds optimal A and B such that `y_pred ≈ y_true` for all training samples.
- The fitted line passes as close to all data points as possible (minimizes error).
- Once trained: put in new car's features → get predicted price.

---

## Evaluating the Model

### Common Regression Metrics
- **MAE (Mean Absolute Error)**: Average of absolute differences between predicted and actual values. Easy to interpret — average error in same units as target.
- **MSE (Mean Squared Error)**: Average of squared differences. Penalizes larger errors more heavily.
- **RMSE (Root Mean Squared Error)**: Square root of MSE. Returns penalty to original units, useful for interpreting magnitude of error.
- **R² (Coefficient of Determination)**: Proportion of variance in the target explained by the model. Ranges from 0 (no explanatory power) to 1 (perfect fit).

### Goal
A good model has `y_predicted` very close to `y_actual`, which translates to low MAE/MSE/RMSE and high R².

---

## Extra Resources
- **Stanford CS229**: Machine learning course with rigorous mathematical foundations, especially on linear models and optimization. Recommended for deep understanding.

---

### Missing Term Definitions (Added from Reference)

| Term | Definition |
|------|-----------|
| **Regression Problem** | Predicting a continuous variable. |
| **Classification Problem** | Predicting discrete categories or classes. |
| **Linear Regression** | Building a linear equation to predict outputs. |
| **Hyperplane** | A geometric representation in multi-dimensional space. |
| **Curse of Dimensionality** | Problems that arise with high-dimensional data (e.g., excessive features from one-hot encoding). |
| **Train-Test Split** | Dividing data into training and testing datasets to prevent overfitting. |

---

## Key Takeaways
| Concept | Key Point |
|---------|-----------|
| Confidence Interval | Gives a range, not just a point estimate; quantifies uncertainty |
| Regression vs Classification | Predicting continuous → regression; predicting categories → classification |
| Generalization | Model must work on unseen data; don't memorize training data |
| Preprocessing order | Split first → then encode/normalize/impute (avoid data leakage) |
| Target encoding | Better than one-hot for high-cardinality features in regression |
| Min-Max Normalization | Scaling features between 0 and 1 (also called MinMax scaling). |
| Scaling | Essential for linear regression to make coefficients comparable |
| Linear regression parameters | Coefficients + intercept are learned during `fit()` |
