# Root Cause Analysis (RCA) — Structured Notes

## 1. What is Root Cause Analysis?
- Systematic process of identifying underlying problems in a product/system
- Collective term covering approaches, rules, and techniques used to uncover root causes
- Analogy: A doctor diagnoses the **root cause** of a fever → asks symptoms → deduces conclusion → recommends solution
- Role of analyst: Identify problems → find root cause → solve/mitigate them

## 2. Goals of RCA
- Discover the real root cause of a problem
- Understand how to fix/compensate for issues
- Avoid recurring similar problems in the future
- Contribute to organizational learning and system improvement

## 3. Life Cycle of RCA (5 Fundamental Questions)

### Step 1: What is the problem?
- Define the issue by its **impact** on overall growth/revenue/profit
- Example: Sales are going down → revenue drops

### Step 2: Why is it happening? (List potential causal factors)
Break the problem into smaller parts — ask questions narrowing scope
- Questions examples:
  - Are sales down across all geographies or specific stores?
  - Is there a technical glitch in the app?
  - Did a new feature launch causing user confusion?
  - Are there external competitors launching similar products?

### Step 3: Internal vs. External Factors
| **Internal Factors** (Organism can fix) | **External Factors** (Outside control) |
|------------------------------------------|----------------------------------------|
| App bugs, glitches                       | Market competition                     |
| Feature rollout                          | Pandemic/social issues                 |
| UX/UI problems                           | Macroeconomic conditions               |
| Payment gateway failures                 | Competitor campaigns                   |

### Zomato Example — Internal vs External (from class discussion)
- Zomato launched a new feature: vegetarian-only delivery guys for veg orders → caused public outrage/bad PR in society
- **Bad PR/outrage** = external factor (can't directly control public sentiment)
- **If the feature was buggy or didn't work** = internal factor (Zomato could fix it)

### Step 4: What is the best solution?
- Define fixes/preventive measures once root cause is found
- Example: If payment gateway failing → fix gateway or add alternative options

### Step 5: Capture & Report findings
- Document all findings for organizational learning
- Prevent future recurrences of same/similar problems

---

## 4. Case Study — Myntra E-commerce Sales Drop

### Problem Statement
- **Order Confirmation Rate** dropped from **5% → 3%** in the last week
- Team needs to identify why the rate fell

### Given Data (Clickstream Data)
Tracks user behavior:
- Time spent on each page
- Page navigations (home → product page → cart → checkout)
- Search queries and feature usage
- Traffic source (organic, paid ads, social media)

---

## 5. User Funnel / Journey Flow

```
Homepage → Search/Recommendation → Product Page
                                    ↓
                    ┌───────────────┼───────────────┐
                 Add to Cart     Buy Now          Leave/Back
                      ↓            ↓                    ↓
                 Checkout (Payment & Order Confirmation)
```

### Key Metrics & Definitions
| Metric | Definition |
|--------|-----------|
| **Order** | Number of orders placed per day |
| **Session** | App open → browsing → app close |
| **Order per Session** = Orders / Total Sessions |
| **Conversion Rate (OCR)** = Orders × 100 / Sessions |
| **Bounce Session** | User lands on one page → immediately leaves |

---

## 6. Baseline Conversion Funnel Calculation (Example)

Assumptions: 100 sessions, 5% original OCR

| Stage | Count | Step Conversion |
|-------|-------|-----------------|
| Sessions | 100 | — |
| Non-Bounce | 90 (Bounce = 10%) | 90% |
| Landed on Product Page | 30 (60 left here) | 30% of non-bounce |
| Added to Cart | 15 (of 50% landing) | — |
| Checkout (Add to cart → checkout) | 12 left, 3 dropped | — |
| Payment Page | 6 (of 12, 50% drop-off) | — |
| Confirmed Orders (CASH ON DELIVERY not confirmed yet) | 5 | **5% total OCR** |

---

## 7. Drop Analysis by Stage

### Initial Possible Causes of Sales Drop
1. 🚫 Drop in total users/sessions → traffic normal → **eliminated**
2. 🚫 Bounce rate increase → bounce unchanged → **eliminated**
3. 🚫 Product dislike (ratings 3.8→4.2, unchanged) → **eliminated**
4. 🚫 Delivery expectations → unchanged → **eliminated**
5. 🚫 Discounts → unchanged (20–45%) → **eliminated**

### Remaining Suspicious Areas
- **Checkout/Make Payment stage** — likely problem area
- External factors: Competitor sales (Amazon/GFlip), social media campaigns
- Demographics check: Gender, age group, region breakdowns
- Macroeconomic or supply chain issues
- Recent app changes/features in the last few days

### Investigation Deep Dive
- **Paytm/UPI gateway down?** → Checked, still showing on payment page
- **Resurge** (payment aggregator): When you make a payment, Resurge connects your bank to Myntra's infrastructure — it's the pipeline behind IGP, UPI, Google Pay transactions. If Resurge's bank partners have issues, even if buttons are visible, payments fail
- Customer sees source list + UPI/Google Pay options on Resurge page → completes adding to cart → but faces "network error" at final payment step

---

## 8. Root Cause Identified

### Investigation Steps:
1. Are there app changes? → **Yes** (last few days)
2. Is checkout button moved/changed? → **No** (same position)
3. Bug reports for new update? → **None reported**
4. Missing payment buttons? → **UPI/GPay still showing**
5. Payment processing issues via Resurge (payment aggregator)? → **YES**

### Evidence:
Check server downtime data of partner banks (color-coded timeline in class slides — purple = previous, yellow = current):
- Three out of **five partner banks** are experiencing:
  - Frequent ICA (Inter-Bank Connectivity Architecture) issues
  - SCFC issues alongside ICA
  - High server downtime during peak hours

---

## 9. Final Conclusion
> The drop in Myntra's order confirmation rate from **5% → 3%** was caused by  
> **payment gateway failures** — specifically, three out of five partner banking  
> services had frequent ICA issues and high server downtime during peak hours,  
> preventing users from successfully completing payments.

### Business Impact:
- First failed attempt → retry
- Second failed attempt → frustration
- Third failed attempt → user abandons order
- Result: Significant drop in confirmed orders

---

## 10. Key Takeaways for RCA Interviews
| Do's | Don'ts |
|------|--------|
| Break problems into smaller parts | Jump to conclusion without data |
| Ask structured narrowing questions | Ignore both internal & external factors |
| Verify hypotheses with data | Stop at surface-level symptoms |
| Document & report findings | Assume you know the answer |
| Use funnel analysis + metrics | Forget about business context |

---

## 11. Framework Summary (RCA Process for Interviews)
```
1. DEFINE PROBLEM → "Sales dropped by X%"
2. LIST CAUSES → Internal, External, Tech, Marketing, Competition
3. ELIMINATE using data/stakeholder answers
4. IDENTIFY remaining suspicious areas
5. ASK deeper narrowing questions
6. VERIFY with data (downtime logs, payment records, user feedback)
7. CONCLUDE root cause
8. RECOMMEND solutions
```

## 12. Key Additional Concepts

### Session & UX Tracking Purpose
- **Scroll depth** tracked on landing page → tells if users engaging or bouncing immediately
- **Search trends** monitored: e.g., if Raymon shoes suddenly surge in searches → Myntra can push banners, notifications, run A/B test campaigns → measure click-through and conversion to judge campaign success/failure
- **Traffic source analysis**: Organic vs paid (Google Ads, Instagram/Facebook ads, WhatsApp links) → helps understand user acquisition channels

### Interview Context
- RCA is typically a 1-hour interview round for product analyst/product manager roles
- Interviews assess ability to: break down problems, ask structured questions, drive conversations, rule out scopes, reach data-backed conclusions
- **Extra problem sheet** will be shared by teaching assistant after class for practice — contains multiple product analytics/brainstorming scenarios (e.g., off-flower question homework)

### Business Impact Breakdown of Failed Payments
1. First failed payment → user retries
2. Second failed payment → frustration sets in
3. Third failed payment → user abandons order entirely, may even say "please don't show products from this merchant" on the platform
4. Result: Significant drop in confirmed orders beyond just the immediate loss

### Key Definitions Clarified
- **Order**: 1 order can contain multiple items (e.g., 3 t-shirts = 1 order, not 3)
- **Session** (mobile app): App open → browsing → app close (login user always logged in; app users don't log out, they just close)
- **Bounce session**: User lands on one page and leaves immediately without scrolling/interaction

### Additional Terms
- **App Glitch**: An error or bug in the application causing unexpected behavior
- **Snaky Diagram**: A complex flowchart to visually map different paths in a user journey
- **Feedback Loop**: A process in which the outputs of a system are routed back as inputs as part of a chain of cause-and-effect

### More Terms
- **User Journey Flow**: The various steps a user takes from beginning to end within a product or service
- **Bounce Rate**: The percentage of visitors who enter the site and then leave without ongoing interaction
- **Baseline Method**: A standard or point of reference for testing the effectiveness of a feature or method
- **Causal Factors**: Potential factors contributing to a problem, analyzed to find the root cause
