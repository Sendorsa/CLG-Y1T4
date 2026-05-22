# SQL Aggregate Queries - Notes

## Overview
This session covered SQL queries focusing on aggregate functions and GROUP BY clause. SQL (Structured Query Language) is the standard language for communicating with relational databases.

**Core topics:**
- GROUP BY and HAVING clauses
- Aggregate functions: COUNT, SUM, MAX, MIN, AVG
- WHERE vs HAVING differences
- Subqueries within SQL statements
- Practical SQL problems and solutions

---

## 1. What are Aggregate Queries?
- Transform **raw data** into **meaningful insights**
- Operate on **multiple rows** and produce a **single output value**

---

## 2. Core Aggregate Functions

| Function | Purpose | Example |
|----------|---------|---------|
| `COUNT()` | Count rows/values | `COUNT(*)`, `COUNT(emp_name)` |
| `SUM()` | Sum of numeric values | `SUM(salary)` |
| `MAX()` | Highest value | `MAX(salary)` |
| `MIN()` | Lowest value | `MIN(salary)` |
| `AVG()` | Average value | `AVG(salary)` |

### Key Point About COUNT
- `COUNT(*)` → counts **all rows** (including NULLs)
- `COUNT(attribute)` → counts **non-NULL values** only

**Example:**
- `COUNT(*)` from courses table (= 10) → counts all rows
- `COUNT(instructor_id)` (= 8) → skips NULL entries

---

## 3. GROUP BY Clause
- Groups rows with the **same value** in specified column(s) into buckets
- Returns **one aggregate value per group**

### Golden Rule
Every selected **non-aggregate column** MUST appear in the `GROUP BY` clause.

```sql
SELECT department, AVG(salary)
FROM employees
GROUP BY department;
```

**Invalid Query:**
```sql
SELECT employee_name, department, salary
FROM employees
GROUP BY department;  -- ERROR: employee_name & salary not in GROUP BY or aggregate
```

> Note: Use `ORDER BY` for sorting, not `GROUP BY`.

---

## 4. Multiple Attributes in GROUP BY
- Group by **multiple columns** for granular breakdown:
```sql
SELECT city, department, COUNT(*)
FROM employees
GROUP BY city, department;
```

- Order of columns in `GROUP BY` does **not** affect grouping logic, only output ordering
- Use `ORDER BY` to control display order

---

## 5. WHERE vs HAVING

| Clause | Filters | When Applied |
|--------|---------|-------------|
| `WHERE` | Individual rows | **Before** grouping |
| `HAVING` | Groups | **After** grouping |

```sql
-- Filter rows first, then group
SELECT department, AVG(salary)
FROM employees
WHERE experience_years > 3
GROUP BY department;
```

```sql
-- Filter groups after aggregation
SELECT department, AVG(salary)
FROM employees
GROUP BY department
HAVING AVG(salary) > 70000;
```

---

## 6. Practical Query Examples

### Example 1: Highest Average Salary Per Department
```sql
SELECT department, AVG(salary) AS avg_salary
FROM employees
GROUP BY department
ORDER BY avg_salary DESC
LIMIT 1;
```

### Example 2: Departments with Count > 5 and Avg Salary Between 90,000–1,20,000
```sql
SELECT department
FROM employees
GROUP BY department
HAVING COUNT(*) > 5 AND AVG(salary) BETWEEN 90000 AND 120000;
```

### Example 3: Cities with Total Salary Expenditure > 5 Lakhs
```sql
SELECT city, SUM(salary) AS total_salary_expenditure
FROM employees
GROUP BY city
HAVING SUM(salary) > 500000;
```

### Example 4: Departments Where Salary Range > 50,000
```sql
SELECT department
FROM employees
GROUP BY department
HAVING (MAX(salary) - MIN(salary)) > 50000;
```

### Example 5: Cities with More Than 5 Engineering Employees

**Method 1: WHERE first (preferred)**
```sql
SELECT city
FROM employees
WHERE department = 'engineering'
GROUP BY city
HAVING COUNT(*) > 5;
```

**Method 2: HAVING filter after GROUP BY**
```sql
SELECT city
FROM employees
GROUP BY department, city
HAVING department = 'engineering' AND COUNT(*) > 5;
```

---

## 7. Subqueries (Nested Queries)
Used when a query depends on results from another query. Useful for complex criteria requiring aggregates not directly supported in standard SQL logic.

**Example: Find departments with the highest average salary**
```sql
SELECT department
FROM employees
GROUP BY department
HAVING AVG(salary) = (
    SELECT MAX(avg_salary)
    FROM (
        SELECT AVG(salary) AS avg_salary
        FROM employees
        GROUP BY department
    ) AS dept_avgs
);
```

- Inner query computes average salary per department
- Middle query finds the maximum of those averages
- Outer query returns departments matching that maximum

---

## 8. Key Takeaways
- `COUNT(*)` includes NULLs; `COUNT(col)` excludes them
- Non-aggregate columns in `SELECT` must be in `GROUP BY`
- `WHERE` filters rows **before** grouping; `HAVING` filters groups **after** grouping
- `ORDER BY` sorts results; `GROUP BY` creates groups
- Multiple columns in `GROUP BY` create combined category buckets
- For max/min across groups, subqueries are required
