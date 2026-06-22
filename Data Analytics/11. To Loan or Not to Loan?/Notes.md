# Notes: To Loan or Not to Loan – Predicting Loan Repayment with Logistic Regression

---

## 1. Linear Regression Recap

### Goal of Regression
- Predict **continuous** variables (e.g., car prices)
- Model is split into **train set** and **test set**
- Train set: model learns patterns
- Test set: unseen data to evaluate performance

### Evaluation Metrics for Regression

#### Mean Squared Error (MSE)
- Measures the average squared difference between predicted and actual values
- **Higher MSE = worse model performance**

#### Mean Absolute Error (MAE)
- Average of absolute errors between predicted and actual values
- Captures the average magnitude of errors without considering direction
- Treats all errors equally (unlike MSE which squares them)
- **Use case preference**: MAE when you want to treat all errors equally; MSE when you want to accentuate larger errors due to squaring

#### R-Squared (Coefficient of Determination)
- Formula: `R² = 1 – (SS_residual / SS_total)`
  - **SS_residual**: Sum of squared errors of your model → Σ(yᵢ – ŷᵢ)²
  - **SS_total**: Sum of squared errors of the mean baseline model → Σ(yᵢ – ȳ)²
- Interpretation:
  - **R² = 1**: Perfect model (all variance explained)
  - **R² = 0**: Model as bad as baseline (always predicting mean)
  - **R² < 0**: Worse than baseline
  - **R² = 0.85**: Predictors explain 85% of variance in target variable

---

## 2. Classification Problems

### What is Classification?
- Predict **discrete/categorical** variables (e.g., yes/no, classes)
- Types:
  - **Binary classification**: Two classes (e.g., churn / no churn)
  - **Multi-class classification**: More than two classes

### Use Case: Churn Prediction
- **Churn**: Customer stops using a service (e.g., drops Netflix subscription)
- Business benefit: Identify at-risk customers → intervene with discounts, fixes, communication → retain customers → reduce revenue loss
- Target variable example: `Churn` (0 = not churned, 1 = churned)
- Features may include: account length, monthly charges, total intl. minutes, customer service calls

---

## 3. Logistic Regression

### Key Concept
- **Still uses a linear equation** → wrapped inside a function
- Linear equation: `z = w₀ + w₁x₁ + w₂x₂ + ... + b`
- Goal: Build a **line (or hyperplane) of best separation** between classes
  - Unlike linear regression (line of best fit), logistic regression finds the boundary that separates classes

### Why Restrict Output to [0, 1]?
- Raw linear output ranges from **–∞ to +∞**
- We need a **probabilistic interpretation**: e.g., "70% chance of class 1"
- This allows thresholding (e.g., if probability > 0.5 → predict class 1)

### Sigmoid Function
- Maps any real number to range [0, 1]
- Formula: `σ(z) = 1 / (1 + e^(-z))`

```python
import numpy as np

def sigmoid(z):
    return 1 / (1 + np.exp(-z))
```

- **S-curve**: As z → ∞, σ(z) → 1; as z → –∞, σ(z) → 0
- Output interpreted as: P(y = 1 | x) – probability of class 1 given input x
- Thresholding: If σ(z) ≥ 0.5 → predict class 1; else → predict class 0

### Step Function (Alternative)
- `g(z) = 1 if z ≥ 0, else 0`
- Crude approach; sigmoid preferred for probabilistic interpretation

---

## 4. Building a Logistic Regression Model

### Steps

1. **Import data** – load dataset with features and target variable
2. **Split data** into train/test (e.g., 80/20) using `train_test_split`
   - In industry: split into **train/validation/test** (e.g., 70/20/10)
     - Train: learn parameters
     - Validation: tune hyperparameters and evaluate during development
     - Test: final evaluation on completely unseen data
3. **Scale features** using `StandardScaler` or `MinMaxScaler`
    - Standardization: mean = 0, std = 1
    - Normalization (MinMax): range [0, 1]
    - Purpose: adjust feature scales for uniformity → improves model performance and interpretability
    - Reasons: better interpretability of coefficients + helps algorithm converge faster
4. **Fit the model** – `LogisticRegression()` → get coefficients (`coef_`) and intercept (`intercept_`)
5. **Predict** – returns class labels (0 or 1)

### Parameters Obtained
- **Coefficients (`w` / `coef_`)**: Weight of each feature
- **Intercept (`b` / `intercept_`)**: Bias term

---

## 5. Evaluation of Classification Models

### Accuracy
- Measures proportion of correct predictions
- Formula: `Accuracy = (number of matches) / (total samples)`
- Or using sklearn: `accuracy_score(y_true, y_pred)`

### Problem with Accuracy on Imbalanced Data
- Example prediction vs actual comparison:

| Actual  | Prediction | Match? |
|---------|------------|--------|
| Churn   | No churn   | ❌     |
| No churn | Churn    | ❌     |
| No churn | No churn | ✅     |
| No churn | No churn | ✅     |

- **Accuracy = 2/4 = 50%** in this case; could be higher with balanced data

#### The Accuracy Paradox
- If only 2 out of 10 customers churn → model that predicts "no one churms" is still **80% accurate**
- Yet completely useless — misses all actual churners
- Critical in medical diagnosis: of 100 patients, 20 have cancer → predicting "none has cancer" → 80% accuracy but dangerously wrong

### Other Classification Metrics (Not in Syllabus)
- **Precision**: Of predicted positives, how many are actually positive?
- **Recall**: Of actual positives, how many did we catch?
- **F1 Score**: Harmonic mean of precision and recall
- These are important for imbalanced datasets

---

## 6. Exam Notes & Important Points

### Topics to Focus On
- Implementing **sigmoid function** in code
- Implementing **accuracy score** calculation
- Understanding **R-squared interpretation** (e.g., R² = 0.85 means 85% variance explained)
- Difference between linear regression and logistic regression
- **Why scaling is needed**: interpretability + convergence
- **Train/validation/test split** concept
- Churn prediction use case and business value

### Expected Question Types
- Code implementation: sigmoid function, accuracy calculation
- NCQs on pandas/data manipulation concepts
- Exam will have coding questions; quiz will be NCQ only

### What to Skip
- Advanced statistical theory behind logistic regression
- Mathematical derivations from statistics
- Geometric interpretation of sigmoid
- Precision, recall, F1 (not in syllabus — covered in CML course)

---

## 7. Glossary of Key Terms

| Term | Definition |
|------|------------|
| **Logistic Regression** | A classification algorithm that predicts binary outcomes using a logistic function |
| **Test Size** | A parameter defining the proportion of data set aside for testing a model |
| **Overfitting** | A modeling error when a function fits the data too well, capturing noise along with the signal |

---

*Session notes compiled from lecture on Logistic Regression and Evaluation Metrics.*
