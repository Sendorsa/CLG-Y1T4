# SQL Window Functions - Lab III Class Notes

## Introduction to Window Functions

Window functions perform calculations across a set of table rows **related to the current row**. Unlike aggregate functions, they **preserve the original rows** and perform calculations without collapsing them into a single output row — allowing both detailed and summary data to be presented simultaneously.

### Why Window Functions?

- **Preservation of Original Rows** — Window functions preserve the original data instead of collapsing it into a single summary row (like GROUP BY does), allowing detailed and summary data to coexist.
- **Flexible Aggregations** — They enable cumulative sums, moving averages, and ranking within partitions.

### Types of Window Functions

| Category | Functions | Purpose |
|---|---|---|
| **Aggregate** | `AVG()`, `SUM()`, `MIN()`, `MAX()`, `COUNT()` | Compute a result across rows within a specified window |
| **Ranking** | `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()` | Assign ranks to rows within a partition |
| **Analytical** | Running totals, moving averages, etc. (use `ORDER BY` within the window definition) | Compute progressive/sequential values across ordered rows |

---

## Key Definitions (Flashcards)

| Front (Term) | Back (Definition) |
|-----|---|
| **Window Function** | Performs calculations across related rows while preserving original rows. |
| **GROUP BY** | Aggregates data into groups based on one or more columns. |
| **Partition BY** | Divides a result set into partitions to which the window function is applied. |
| **Order BY** | Sorts data within each partition of a window function. |
| **ROW_NUMBER()** | Assigns a unique number to each row based on the order specified. |
| **RANK()** | Ranks entries in a result set, with gaps in rank for ties. |
| **DENSE_RANK()** | Ranks entries in a result set without gaps in rank numbers. |
| **Views in SQL** | Virtual tables created from queries to simplify complex query reuse. |
| **Updatable Views** | Views that allow updates to the data source tables, subject to constraints. |
| **Running Totals** | Calculating cumulative totals using window functions. |
| **Derivation Table** | Using a subquery as a temporary table to filter and manipulate data. |
| **Aggregate Functions in Window Function** | Functions like AVG, SUM used in window functions to compute over partitions. |

---

## Database Schema Used

| Table | Columns |
|-------|-----|
| **employees** | employeeID, employeeName, departmentID, ID, city, salary, experienceYears, performanceRating, joiningDate |
| **departments** | departmentID, departmentName, location, budget |

---

## 1. Problem with GROUP BY & Correlated Subqueries

### The Problem
Query: Print employee name, salary, and **department average salary** for each employee.

**Correlated Subquery approach** (inefficient):
```sql
SELECT employeeName, salary,
    (SELECT AVG(E2.salary) FROM employees E2
     WHERE E2.departmentID = E1.departmentID) AS departmentAverageSalary
FROM employees E1;
```

**Issue**: The inner subquery executes **for every row** in the outer query → poor performance.

**Why not just use GROUP BY?**
```sql
-- INVALID - cannot do this:
SELECT employeeName, salary, AVG(salary)
FROM employees
GROUP BY departmentID;
```
- `GROUP BY` **collapses** all rows in a department into a single record
- We want to **preserve individual rows** while computing aggregated data alongside them

### Solution: Window Functions
> Window functions perform calculations across related rows **while preserving the original rows**.

---

## 2. Structure of a Window Function

```sql
SELECT functionName(column) OVER (
    PARTITION BY column1,
    ORDER BY column2
)
FROM table;
```

### Key Components

| Component | Purpose |
|-----------|---------|
| **Window Function** | `AVG()`, `MIN()`, `MAX()`, `SUM()`, `COUNT()`, `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()` |
| **OVER** | Defines the "window" (set of rows) the function operates on |
| **PARTITION BY** | Divides rows into groups (like GROUP BY but doesn't collapse rows) |
| **ORDER BY** | Sorts rows within each partition |

### Example
```sql
SELECT employeeName, departmentID, salary,
    AVG(salary) OVER (PARTITION BY departmentID) AS departmentAvgSalary
FROM employees;
```

```sql
-- ORDER BY inside OVER produces a **running** aggregate (not a flat group average)
SELECT employeeName, departmentID, salary,
    AVG(salary) OVER (PARTITION BY departmentID ORDER BY salary DESC) AS deptRunningAvgSalary
FROM employees;
```
> **Warning**: When `ORDER BY` is included inside the `OVER` clause with an aggregate function (AVG, SUM, etc.), it computes a **running/progressive** value row by row within each partition — **not** a single flat average per group. If you want a flat department average (same value for every row in the partition), **do not** include `ORDER BY` inside `OVER`. Use `ORDER BY` at the end of the query instead to sort the final output.

---

## 3. Aggregate Window Functions

**AVG, MIN, MAX, SUM, COUNT** can all be used as window functions.

### Computing aggregate over entire table
```sql
SELECT employeeName, departmentName, salary,
    AVG(salary) OVER () AS companyAvgSalary
FROM employees e
JOIN departments d ON e.departmentID = d.departmentID;
```
- **Empty `OVER ()`** → aggregate is computed over **all rows** in the result set

### Query Execution Order (important!)
```
FROM → JOIN → WHERE → GROUP BY → HAVING → SELECT (Window Functions execute here as part of SELECT evaluation)
```
- Window functions execute **as part of the SELECT clause evaluation** (before ORDER BY)
- This means you **cannot** filter by a window function column in WHERE

---

## 4. Rank Window Functions

| Function | Behavior |
|----------|----------|
| **ROW_NUMBER()** | Unique sequential number (1, 2, 3, 4...) — **no ties** |
| **RANK()** | Same rank for tied rows, **skips** next ranks (1, 2, 2, 4...) |
| **DENSE_RANK()** | Same rank for tied rows, **no gaps** (1, 2, 2, 3...) |

### When to use ROW_NUMBER instead of RANK/DENSE_RANK
For **"top N per group"** queries (e.g., top 2 highest paid per department), use **ROW_NUMBER()** because:
- RANK() or DENSE_RANK() would include **all tied rows** — if 3 employees share the highest salary, all 3 get rank 1, violating the "top 2" requirement
- ROW_NUMBER() assigns **unique** ranks regardless of ties, guaranteeing exactly N rows per group

### Example
```sql
SELECT employeeName, departmentID, performanceRating,
    ROW_NUMBER() OVER (PARTITION BY departmentID ORDER BY performanceRating DESC, salary ASC) AS empRank
FROM employees;
```
- **Multiple ORDER BY attributes**: Primary sort by `performanceRating DESC`, tiebreaker by `salary ASC`

---

## 5. Running Totals & Moving Averages (Cumulative Aggregates)

> **Key Concept**: When **any** aggregate function (AVG, SUM, MIN, MAX, COUNT) is combined with **ORDER BY** inside the `OVER` clause, it produces a **running/progressive** value that changes row by row — **not** a single aggregate for the entire group.

When an aggregate function is combined with **ORDER BY** (no PARTITION BY):
```sql
SELECT employeeName, joiningDate, salary,
    SUM(salary) OVER (ORDER BY joiningDate) AS runningSalaryTotal
FROM employees;
```
- Produces a **running/cumulative total** ordered by joining date

### Moving Averages
```sql
SELECT employeeName, joiningDate, salary,
    AVG(salary) OVER (ORDER BY joiningDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS movingAvgSalary
FROM employees;
```
- Computes an average over a **sliding window** of rows (e.g., last 3 rows + current row).

### Moving averages within partitions:
```sql
SELECT employeeName, 
    AVG(salary) OVER (PARTITION BY departmentID ORDER BY joiningDate ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS deptMovingAvg
FROM employees;
```
- Moving average **within each department group** over a sliding window of rows.

### Running totals within partitions:
```sql
SELECT ...,
    SUM(salary) OVER (PARTITION BY departmentID ORDER BY joiningDate) AS deptRunningTotal
FROM employees;
```
- Running total **within each department group**

---

## 6. Filtering on Window Function Results

You **cannot** use WHERE to filter on a window function column (executed before SELECT).

### Solution: Derived Table (Subquery)
```sql
-- Find top 2 highest paid employees in each department
SELECT * FROM (
    SELECT employeeName, departmentID, salary,
        ROW_NUMBER() OVER (PARTITION BY departmentID ORDER BY salary DESC) AS empRank
    FROM employees
) AS rankedEmployees
WHERE empRank <= 2;
```

### Practical Example: Employees earning above department average
```sql
SELECT employeeName, salary, departmentAvgSalary
FROM (
    SELECT employeeName, salary,
        AVG(salary) OVER (PARTITION BY departmentID) AS departmentAvgSalary
    FROM employees
) AS employeeData
WHERE salary > departmentAvgSalary;
```

---

## 7. Views in SQL

A **Views in SQL** is a virtual table that stores a query (no actual data).

### Creating a View
```sql
CREATE VIEW highestPerformanceDeptWise AS
SELECT employeeName, departmentID, performanceRating,
    ROW_NUMBER() OVER (PARTITION BY departmentID ORDER BY performanceRating DESC) AS empRank
FROM employees;
```
> **Note**: This view does **not** include `employeeID`, so it cannot be directly used in UPDATE queries that need to match rows. To use view-like logic in an UPDATE, you must embed the query inline (see Section 8).

### Using a View
```sql
SELECT * FROM highestPerformanceDeptWise;
-- Equivalent to running the full query that defined the view
```

### Benefits
- **Reusability** — write complex query once, use by name
- **Simplified access** — non-technical users can query a view like a table
- **Live data** — view always reflects current data in underlying tables
- **Security and column restriction** — views can restrict access to specific columns, hiding sensitive data without changing the underlying table structure

---

## 8. Updating Views

### Updateable Views
Views based on simple queries (no GROUP BY, no aggregates, no DISTINCT, no window functions) are updateable.

### Non-updateable Views
Views using **window functions**, **GROUP BY**, **DISTINCT**, or **aggregates** are **not updateable**.
> Attempting to update such a view will **not** modify the underlying table data.

### Example: Creating a non-updateable view (GROUP BY)
```sql
CREATE VIEW department_performance AS
SELECT departmentID, AVG(salary) AS avgSalary
FROM employees
GROUP BY departmentID;
```
- This view is **not updateable** because it uses `AVG()` (aggregate) and `GROUP BY`.

### Updating data using view logic (indirect method)
```sql
UPDATE employees
SET salary = salary + 50000
WHERE employeeID IN (
    SELECT employeeID FROM (
        SELECT employeeID,
            ROW_NUMBER() OVER (PARTITION BY departmentID ORDER BY performanceRating DESC) AS empRank
        FROM employees
    ) AS empRankTable
    WHERE empRank <= 2
);
```
- The **inner** subquery (`AS empRankTable`) creates the derived table boundary that allows filtering on the window function result via the **outer** wrapper (`SELECT employeeID FROM (...)`)
> **Warning**: If you forget the SELECT employeeID wrapper in the inner subquery (e.g., use `SELECT *` instead), the WHERE clause `empRank <= 2` would not filter properly — the inner `SELECT *` returns all columns (including employeeID for ALL 30 rows), so **all employees** would be updated instead of just the top 2 per department (which is only 6 rows across 3 departments).

---

## Key Takeaways

1. **Window functions** compute aggregated/ranked data **without collapsing** rows
2. **OVER** clause defines the window; **PARTITION BY** groups rows, **ORDER BY** sorts within groups
3. **ROW_NUMBER()** = unique ranks, **RANK()** = skips after ties, **DENSE_RANK()** = no gaps after ties
4. Aggregate + ORDER BY = **running/cumulative total**
5. Window functions execute **during SELECT**, so they can't be filtered in WHERE
6. Use **derived tables** to filter on window function results
7. **Views** store reusable queries as virtual tables
8. Views with window functions/aggregates are **not updateable**
