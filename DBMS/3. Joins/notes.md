# SQL Updates & Joins - Complete Reference

## 1. SQL UPDATE Operations (U in CRUD)

### Purpose
Modify existing data in one or more rows of a table.

### Basic Syntax
```sql
UPDATE table_name
SET column1 = value1, column2 = value2
WHERE condition;
```

### Key Rules
- **Always use a `WHERE` clause** — omitting it updates **every row** in the table (mass update).
- **Preview first** — run `SELECT * FROM table WHERE condition` before UPDATE to verify affected rows.
- **Precise** — exact condition to target only intended rows
- **Validation** — verify affected rows before committing
- **Safe** — preview with SELECT before running UPDATE
- **Consistent** — maintain data integrity (check constraints, foreign keys)
- **Arithmetic updates** — e.g., `SET credits = credits - 1`.
- **Update to NULL** — e.g., `SET grade = NULL`.
- **Update to current date** — e.g., `SET enrollment_date = CURRENT_DATE() WHERE student_id = 1`.

### Example
```sql
-- Safe update: only change grade for a specific course
UPDATE course_enrollment
SET grade = 'A'
WHERE course_id = 101 AND student_id = 5001;
```

### Common Pitfalls
| Mistake | Result |
|---|---|
| Missing `WHERE` | Every row gets updated |
| Wrong condition | Wrong rows get changed |
| No SELECT preview | Can't verify before committing |

---

### Real-World Business Domains

| Domain | Key Tables | Common Operations |
|---|---|---|
| **E-commerce** | Order, Status, Ratings, DeliveryDate, Inventory | UPDATE order status; JOIN orders ↔ inventory |
| **Banking System** | Transaction, Account Balance, Update personal details, Passport | UPDATE account balance; JOIN users ↔ passports |

---

## 2. SQL JOINs

### What is a JOIN?
A JOIN combines rows from two or more tables based on a related column (usually a **Foreign Key**).

### How JOINs Work
1. Database forms a **Cartesian product** (all possible row combinations).
2. Filters rows using the **join condition** (e.g., `ON table1.id = table2.foreign_id`).

### Types of JOINs

#### INNER JOIN
Returns rows with **matches in both** tables.

```sql
SELECT *
FROM courses c
INNER JOIN instructors i ON c.instructor_id = i.instructor_id;
```

| courses | | |
|---|---|---|
| course_id | course_name | instructor_id |
| 1 | DBMS | 10 |
| 2 | OS | 20 |
| 3 | Networks | NULL |

| instructors | |
|---|---|
| instructor_id | instructor_name |
| 10 | Dr. Gupta |
| 20 | Dr. Sharma |

**Result (INNER JOIN):**

| course_id | course_name | instructor_id | instructor_name |
|---|---|---|---|
| 1 | DBMS | 10 | Dr. Gupta |
| 2 | OS | 20 | Dr. Sharma |

> `Networks` is excluded because it has no matching instructor.

> **Venn diagram:** Two overlapping circles — only the **overlapping region** is returned.

---

#### LEFT JOIN
Returns **all rows** from the left table + matched rows from the right.
Unmatched right-side columns become **NULL**.

```sql
SELECT *
FROM courses c
LEFT JOIN instructors i ON c.instructor_id = i.instructor_id;
```

**Result (LEFT JOIN):**

| course_id | course_name | instructor_id | instructor_name |
|---|---|---|---|
| 1 | DBMS | 10 | Dr. Gupta |
| 2 | OS | 20 | Dr. Sharma |
| 3 | Networks | NULL | NULL |

> `Networks` is included with NULL values for instructor columns.

> **Venn diagram:** Two overlapping circles — the **full left circle** is returned, plus only the overlap from the right.

---

#### RIGHT JOIN
Returns **all rows** from the right table + matched rows from the left.
Unmatched left-side columns become **NULL**.

```sql
SELECT *
FROM courses c
RIGHT JOIN instructors i ON c.instructor_id = i.instructor_id;
```

**Result (RIGHT JOIN):**

| course_id | course_name | instructor_id | instructor_name |
|---|---|---|---|
| 1 | DBMS | 10 | Dr. Gupta |
| 2 | OS | 20 | Dr. Sharma |
| NULL | NULL | 30 | Dr. Patel |

> `Dr. Patel` (instructor_id = 30) has no course — course columns are NULL.

> **Venn diagram:** Two overlapping circles — the **full right circle** is returned, plus only the overlap from the left.

---

#### FULL OUTER JOIN
Returns **all rows** from both tables.
Unmatched rows on either side get **NULL** values.

```sql
SELECT *
FROM courses c
FULL OUTER JOIN instructors i ON c.instructor_id = i.instructor_id;
```

> **Note:** MySQL does **not** support FULL OUTER JOIN natively.

> **Venn diagram:** Two overlapping circles — **both entire circles** are returned, including non-overlapping parts.

### Quick Comparison

| JOIN Type | Left Rows | Right Rows | Matched Only |
|---|---|---|---|
| INNER | Only if match | Only if match | Yes |
| LEFT | All | Only if match | Yes |
| RIGHT | Only if match | All | Yes |
| FULL OUTER | All | All | Yes |

---

## 3. Table Aliases

### Purpose
- Shorten column references.
- Avoid ambiguity in multi-table queries.

### Syntax
```sql
SELECT c.course_name, i.instructor_name
FROM courses c
JOIN instructors i ON c.instructor_id = i.instructor_id;
```

| Without Aliases | With Aliases |
|---|---|
| `SELECT courses.course_name, instructors.instructor_name FROM courses JOIN instructors ON courses.instructor_id = instructors.instructor_id` | `SELECT c.course_name, i.instructor_name FROM courses c JOIN instructors i ON c.instructor_id = i.instructor_id` |

---

## 4. Relationship Cardinality

### One-to-One (1:1)
One record in Table A relates to **exactly one** record in Table B.

| Example | Explanation |
|---|---|
| User → Passport | One user has one passport; one passport belongs to one user. |
| Student → Student_Profile | One student has one profile. |

### One-to-Many (1:N)
One record in Table A relates to **many** records in Table B.

| Example | Explanation |
|---|---|
| Department → Instructors | One department has many instructors; one instructor belongs to one department. |
| Course → Enrollments | One course has many enrollments. |

### Many-to-Many (M:N)
Records in Table A relate to **many** records in Table B and vice versa.

| Example | Explanation |
|---|---|
| Student ↔ Courses | A student takes many courses; a course has many students. |

**Solution:** Use a **Junction/Relationship Table**.

```
students ────< course_enrollment >──── courses
                  │
               instructors
```

---

## 5. Multi-Table JOINs

### Scenario
Print details for all enrollments: **Course Name, Student Name, Instructor Name, Credits, Grade**.

### Step-by-Step
1. Start with the **junction table**: `course_enrollment`
2. JOIN `students` on `student_id`
3. JOIN `courses` on `course_id`
4. JOIN `instructors` on `courses.instructor_id = instructors.instructor_id`

### Query
```sql
SELECT c.course_name, s.student_name, i.instructor_name, e.credits, e.grade
FROM course_enrollment e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id
JOIN instructors i ON c.instructor_id = i.instructor_id;
```

### Visualization

```
course_enrollment          students
┌──────────┐             ┌───────────┐
│ student_id │───┐      │ student_id │
│ course_id  │   ├─────▶│student_name│
└──────────┘   │      └───────────┘
               │
               │
         courses              instructors
        ┌───────────┐       ┌───────────┐
        │instructor_id│───▶│instructor_id│
        │course_name │      │instructor_name│
        └───────────┘       └───────────┘
```

---

## 6. Quick Reference Card

| Operation | Keyword | Key Point |
|---|---|---|
| Add rows | `INSERT` | Use `VALUES` clause |
| Read rows | `SELECT` | Use `FROM`, `WHERE`, `JOIN` |
| Update rows | `UPDATE` | **Always use `WHERE`** |
| Delete rows | `DELETE` | **Always use `WHERE`** |
| Inner join | `INNER JOIN` | Only matching rows |
| Left join | `LEFT JOIN` | All left + matched right |
| Right join | `RIGHT JOIN` | All right + matched left |
| Full outer | `FULL OUTER` | All rows from both (no MySQL) |
| Table alias | `AS alias` or `table alias` | Shorten references |

---

## 7. Practice Questions

### Q1: UPDATE
Update the `credits` of course_id = 102 to 4.

### Q2: LEFT JOIN
List all courses along with their instructors. Include courses without instructors.

### Q3: INNER JOIN
List only courses that have assigned instructors.

### Q4: Multi-JOIN
Find all students enrolled in courses taught by Dr. Gupta.

### Q5: RIGHT JOIN
List all instructors and their courses. Include instructors with no courses.