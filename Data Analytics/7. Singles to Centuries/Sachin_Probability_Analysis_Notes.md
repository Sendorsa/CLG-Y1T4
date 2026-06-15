# Scaler Companion (beta) — Revision Notes: ODI Cricket Performance Analysis and Probability Applications

# Sachin's Scoring Patterns with Probability Distributions — Detailed Notes

## Session Overview

**Topic:** Application of probability and probability distributions in solving real-world data analytics business case studies.

**Case Study:** Analysis of Sachin Tendulkar's ODI cricket career using a dataset covering **360 matches**.

**Source Data File:** `Sachin_ODI.csv`

**Key Metrics in Dataset:** Runs, Not Out, Balls Faced, fours, sixes, Strike Rate, Opposition, Innings (1st or 2nd), Ground, Date, Consequence, Win (India's result).

---

## Part 1: Basic Probability Concepts

### Key Terminology

| Term | Definition | Example (Sachin Context) |
|------|-----------|------------------------|
| **Experiment** | Any action or process that generates outcomes | Tossing a coin, rolling a die, Sachin batting in a match |
| **Outcome** | A single result of an experiment | Sachin scoring 100 runs in a specific match |
| **Sample Space** | The set of all possible outcomes | All possible scores Sachin could achieve (1 to 200+) |
| **Event** | A subset of the sample space (one or more outcomes) | Sachin scoring >50, Sachin scoring a century |

### Practical Example — Finding Sample Space

```python
sample_space = df['Runs'].unique()    # All unique scores
len(sample_space)                      # Count = 122 distinct scores
```

In Sachin's ODI career, there were **122 different scores** he made (the sample space).

---

## Part 2: Business Context — Why Analyze Cricket Data?

### Use Cases

- **Sports Analytics Companies:** Inform commentary, performance predictions, fan engagement strategies.
- **IPL / BCCI / ICC Teams:** Analyze player performance patterns to pick the best possible XI for auctions and matches.
- **NBA & Other Sports:** Similar analytics used for team composition and drafting.
- **Betting Organizations:** Model win probabilities, player milestones.

### Business Objectives (from the session)

1. **Understanding Performance Patterns:** How Sachin's performance influences match outcomes.
2. **Performance Insights:** Individual contribution analysis of Sachin.
3. **Probability Analysis:**
   - How often does Sachin score a century or an age?
   - How often when Sachin scores massively, does India win?
4. **Scenario Analysis:** What is the probability that Sachin scores >50 runs AND India wins?

---

## Part 3: Types of Events in Probability

### 1. Mutually Exclusive Events
- **Definition:** Two events that **cannot** occur simultaneously.
- **Example:** Event A = Sachin scoring a century (100) vs. Event B = Sachin getting out for a duck (0). These cannot happen at the same time.

### 2. Joint Events
- **Definition:** Events that **can** happen simultaneously.
- **Example:** Event A = Sachin scores >50 runs AND Event B = India wins the match. Both can happen together.

### 3. Independent Events
- **Definition:** The occurrence of one event does **not** affect the occurrence of another.
- **Example:** Sachin's performance vs. weather conditions. Whether it was cloudy or sunny doesn't fundamentally change his ability to score.

### 4. Exhaustive Events
- **Definition:** A set of events that **collectively cover all possible outcomes** in the sample space.
- **Example:** Event A = Sachin scores <50 runs + Event B = Sachin scores ≥50 runs = Covers every scenario. Together they are exhaustive.

---

## Part 4: Set Operations on Events (Pandas Implementation)

### Intersection (AND) — $P(A \cap B)$
Both events happen simultaneously.

**Example:** Sachin scored >50 runs AND India won.

```python
event_a = df[df['Runs'] > 50]           # Sachin scored >50
event_b = df[df['Win'] == True]          # India won
intersection = pd.merge(event_a, event_b) # Inner join → both conditions true
probability = len(intersection) / len(df) # → ~20% of cases
```

**Key Insight:** 20% of the cases where Sachin scored >50 AND India won. This means his higher scores contribute to wins but are not the sole determinant.

### Union (OR) — $P(A \cup B)$
Either event A or event B occurs.

**Example:** Sachin scored >50 runs OR India won.

```python
union = pd.concat([event_a, event_b]).drop_duplicates()
probability = len(union) / len(df)
```

- `pd.concat` stacks dataframes on top of each other (considers all rows from both).
- `drop_duplicates()` removes overlap between events.

### Complement — $P(A^c)$
The opposite of event A happens.

**Example:** Sachin did NOT score a century.

```python
event_a = df[df['Runs'] >= 100]          # Century
complement_a = df[df['Runs'] < 100]      # Not a century (opposite condition)
# OR
complement_a = df[df['Century'] == False]  # Alternative using 'Century' column
```

---

## Part 5: Probability Rules

### Addition Rule — For Union $P(A \cup B)$

$$P(A \cup B) = P(A) + P(B) - P(A \cap B)$$

**Example:** Probability that Sachin scored >50 runs OR India won.

- $P(A)$ = P(Sachin scores >50) = len(event_a) / total_matches
- $P(B)$ = P(India won) = len(event_b) / total_matches
- $P(A \cap B)$ = P(both happen) = len(intersection) / total_matches

**Formula applied:** $P(A \cup B) = P(A) + P(B) - P(A \cap B)$

---

### Multiplication Rule — For Independent Events $P(A \cap B)$

$$P(A \cap B) = P(A) \times P(B)$$

When events A and B are independent, the intersection probability is simply the product.

**Derivation:**
- For independent events: $P(B|A) = P(B)$ (occurrence of A doesn't affect B).
- Since $P(B|A) = \frac{P(A \cap B)}{P(B)}$, multiplying both sides by $P(B)$ gives $P(A \cap B) = P(A) \times P(B)$.

---

### Multiplication Rule — For Dependent Events (Conditional Probability)

$$P(A \cap B) = P(A) \times P(B|A)$$

When events are **dependent**, you need the conditional probability.

**Example:** Probability Sachin scored >50 AND India won (treating as dependent):

```python
# Step 1: Find P(A) — Sachin scores >50
event_a = df[df['Runs'] > 50]
P_A = len(event_a) / total_matches

# Step 2: Find P(B|A) — India won GIVEN Sachin scored >50
P_B_given_A = len(event_a[event_a['Win'] == True]) / len(event_a)

# Step 3: Multiply
P(A ∩ B) = P_A * P_B_given_A  # Result ≈ 20%
```

**Why this matters:** In reality, India's win probability likely **depends** on whether Sachin scores >50. This conditional approach is more accurate for dependent events.

---

## Part 6: Bayes' Theorem

For dependent events where we need to reverse the conditional probability:

$$P(B|A) = \frac{P(A \cap B)}{P(B)}$$

Or equivalently: $P(A \cap B) = P(B) \times P(A|B)$

**Use Case:** Understanding how Sachin's performance impacts match outcomes and reversing the analysis (how likely is it that Sachin scored >50 given India won?).

---

## Part 7: Practical Applications & Key Takeaways

### Summary of Findings
- **122 distinct scores** in Sachin's ODI career (sample space).
- **20%** of matches where both Sachin >50 runs AND India won.
- Union probability considers either condition being true.
- Complement gives the opposite scenario probabilities.

### Business Value
- Helps teams make data-driven player selection decisions.
- Informs pre-match and post-match commentary with statistical backing.
- Enables performance prediction models.
- Fan engagement through interactive stats during live matches.
- Risk Factor Modeling: Assessing likelihood of big scores or match outcomes to guide batting order, substitutions, and tactical decisions.

### Code Flow Summary

```
1. Import dataset (Sachin_ODI.csv) → pd.DataFrame
2. Explore data → df.head(), df.info()  (no null values)
3. Find sample space → df['Runs'].unique() → 122 scores
4. Define events (A, B) using boolean conditions
5. Apply set operations: intersect, union, complement
6. Compute basic probabilities → len(event) / total_matches
7. Apply addition/multiplication rules as appropriate
8. Use conditional probability for dependent events
```

---

## Part 8: Quiz-Style Concepts

1. **What is $P(A \cap B)$?** — Intersection (both A and B happen).
2. **$P(A \cap B) = P(A) \times P(B)$ is valid when?** — Events are independent.
3. **$P(A \cap B) = P(A) \times P(B|A)$ is valid when?** — Events are dependent (conditional approach).
4. **What does $P(B|A)$ mean?** — Probability of B occurring given that A has already occurred.
5. **Union is implemented using which Pandas function?** — `pd.concat()` + `drop_duplicates()`.
6. **Intersection is implemented using which Pandas function?** — `pd.merge()` (inner join).
7. **What does a complement represent?** — The opposite of an event occurring.

---

## Glossary

| Term | Meaning |
|------|---------|
| Probability | The chance of occurrence of a particular event, ranging from 0 to 1. |
| Experiment | Any action or process that generates outcomes |
| Outcome | A single result of an experiment |
| Sample Space | Set of all possible outcomes (122 unique scores for Sachin) |
| Mutually Exclusive | Events that cannot happen together |
| Joint Event | Events that can happen simultaneously |
| Independent Event | One event's occurrence doesn't affect the other |
| Exhaustive Events | Events covering all scenarios |
| Intersection ($\cap$ | Both events happening (AND) |
| Union ($\cup$) | At least one event happening (OR) |
| Complement ($^c$) | Opposite of an event |
| Conditional Prob. | Probability of B given A occurred: $P(B|A)$ |
| Bayes' Theorem | Method to find reverse conditional probability |

---

## Appendix A: Topics from the Break (Mentioned but Not Covered In-Class)

### Marginal Probability
- Probability of a **single event** regardless of other events.
- E.g., $P(\text{India won}) = \frac{\text{number of India wins}}{360}$ — ignores Sachin's score entirely.
- Derived by "marginalizing" (summing over) all other variables in a joint distribution.

### Joint Probability
- Probability of two **specific values** occurring together across two random variables.
- In this context: the full probability table of every (runs, win) pair across 360 matches.
- Marginal probability is derived by collapsing (summing) the joint probability table along a dimension.

### Discrete Probability Distributions Relevant to This Case Study

| Distribution | When It Applies | Formula / Key Concept | Cricket Example |
|---|---|---|---|
| **Bernoulli** | Binary outcome (success/failure) | $P(X=1) = p$ | Did Sachin score a century? Yes/No → $p =$ fraction of 100s |
| **Binomial** | Number of successes in $n$ independent trials | $P(X=k) = \binom{n}{k}p^k(1-p)^{n-k}$ | Matches where Sachin gets a century out of his last $n$ innings |
| **Discrete Uniform** | All outcomes equally likely | $P(X=x) = \frac{1}{N}$ | Each of 360 matches has $\frac{1}{360}$ chance (naive baseline) |
| **Poisson** | Count of events in a fixed interval | $P(X=k) = \frac{\lambda^k e^{-\lambda}}{k!}$ | Expected number of centuries Sachin scores per tournament |

---

## Appendix B: Key Assumptions & Limitations

### Assumptions Made in This Analysis
1. **Independence assumption** for the independent multiplication rule — in reality, player performance and match outcomes are correlated (Sachin scoring >50 likely increases India's odds of winning).
2. **Historical data as proxy:** Past 360 matches used to model future performance; conditions, pitch types, opponents differ.
3. **No normalization for era:** Early ODI matches had very different formats and scoring patterns compared to later years.

### What This Analysis Does NOT Cover (from the session)
- Actual probability distribution fitting (which distribution best fits Sachin's scores — Poisson? Negative Binomial?).
- Confidence intervals or statistical significance tests.
- Venue-wise, opponent-wise, or era-wise breakdowns.
- Predictive modeling for future matches.

---

## Appendix C: Visual Workflow of the Entire Analysis

```
┌─────────────────────┐
│  Sachin_ODI.csv     │    360 matches, no null values
│  (import via pd.read)│
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  df.head() +        │    Explore columns: Runs, Not Out,
│  df.info()           │    BF, fours, sixes, SR, Opposition,
└─────────┬───────────┘    Ground, Date, Consequence, Win
          │
          ▼
┌─────────────────────┐
│  Sample Space       │    df['Runs'].unique() → 122 scores
│  (all possible      │
│   outcomes)         │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  Define Events      │
│                     │    Event A: Runs > 50
│   A = {scores>50}   │    Event B: Win == True
│   B = {India wins}  │
└─────────┬───────────┘
          │
    ┌─────┴──────┐
    ▼            ▼
┌─────────┐  ┌────────────┐
│Intersect│  │   Union    │
│A ∩ B    │  │ A ∪ B      │
│(AND)     │  │ (OR)       │
│P(A∩B)=? │  │ P(A∪B)=?  │
└─────────┘  └────────────┘
    │            │
    ▼            ▼
┌──────────────────────────┐
│   Probability Rules      │
│                          │
│  Add. Rule:              │
│  P(A∪B) = P(A)+P(B)-... │
│                          │
│  Mult. (Independent):    │
│  P(A∩B) = P(A)×P(B)     │
│                          │
│  Mult. (Dependent):      │
│  P(A∩B) = P(A)×P(B|A)   │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│  Bayes' Theorem          │
│  (reverse conditional)   │
│                          │
│  P(B|A) = P(A∩B)/P(B)   │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│  Business Insights       │
│  • Win probability       │
│  • Player selection      │
│  • Commentary stats      │
│  • Fan engagement        │
└──────────────────────────┘
```

---

## Appendix D: Key Numeric Results from the Session

| Metric | Value | Interpretation |
|--------|-------|----------------|
| Total matches analyzed | 360 | Full dataset size |
| Distinct scores (sample space) | 122 | Frequency of score diversity |
| $P(\text{Sachin >50}) \cap P(\text{India wins})$ | ~20% | Joint probability — roughly 1 in 5 matches |
| Not Out column | Binary (Yes/No) | Indicates innings was incomplete |
| Data completeness | 0 null values | Clean dataset, no preprocessing needed |
