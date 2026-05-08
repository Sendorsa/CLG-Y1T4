# SQL Lab 1 — Comprehensive Notes

---

## 1. Introduction to Databases & DBMS

### What is a Database?
- A **structured collection of data** stored electronically, typically on a computer system.
- Designed for efficient **insertion, retrieval, and management** of data.
- Examples: student records, bank transactions, inventory systems.

### What is a DBMS (Database Management System)?
- Software that **interacts with users, applications, and the database** to capture and analyze data.
- Provides an interface between the database and the end-user or programs.
- Ensures data **integrity, security, and consistency**.

### Common DBMS Examples
- **MySQL** — open-source, widely used for web applications.
- **PostgreSQL** — open-source, advanced features (JSON, full-text search).
- **SQLite** — lightweight, file-based, no server required.
- **Oracle / SQL Server** — enterprise-grade commercial systems.

### Relational Model
- Data is organized into **tables (relations)** with rows (tuples) and columns (attributes).
- Tables are **linked via keys** (primary and foreign keys).
- Operations on data are performed using **SQL (Structured Query Language)**.

---

## 2. Data Types

Data types define what kind of values a column can store. Choosing the right type matters for **storage efficiency, accuracy, and performance**.

### 2.1 String Types

| Type | Description | When to Use |
|------|-------------|---------|
| `CHAR(n)` | Fixed-length string. Pads with spaces if shorter than `n`. | Values with consistent length (e.g., country code `"US"`, phone prefix `"415"`). |
| `VARCHAR(n)` | Variable-length string. Only stores the actual characters + 1–2 bytes overhead. | Text with varying length (e.g., names, emails, descriptions). |
| `TEXT` | Very long strings (up to 65,535 characters). | Blog posts, comments, articles. |

**Key Difference:** `CHAR(10)` always takes 10 bytes. `VARCHAR(10)` storing `"Hi"` takes 3 bytes (2 for text + 1 for length). Use `VARCHAR` unless length is always the same.

### 2.2 ENUM

- `ENUM('value1', 'value2', ...)` — the column can only hold **one value** from the predefined list.
- Internally stored as integers: `'small'` = 1, `'medium'` = 2, etc.
- Efficient for fixed categories.

```sql
gender ENUM('Male', 'Female', 'Other')
```

### 2.3 Numeric Types

| Type | Size | Range | Use Case |
|------|------|-------|----------|
| `TINYINT` | 1 byte | -128 to 127 | Status flags, small counters |
| `SMALLINT` | 2 bytes | -32,768 to 32,767 | |
| `INT` / `INTEGER` | 4 bytes | ~±2 billion | Most common ID columns |
| `BIGINT` | 8 bytes | ~±9 quintillion | Large-scale IDs, analytics |
| `DECIMAL(p, s)` | Variable | Up to 38 digits | **Money, exact values** (no rounding errors) |
| `FLOAT` / `DOUBLE` | 4/8 bytes | Approximate | Scientific calculations (has floating-point errors) |

**DECIMAL explained:**
- `DECIMAL(5, 2)` means 5 total digits, 2 after the decimal point → range `-999.99` to `999.99`.
- Always use `DECIMAL` for **currency**. `FLOAT` can cause precision errors (e.g., `0.1 + 0.2 != 0.3`).

### 2.4 Date & Time Types

| Type | Format | Use Case |
|------|--------|----------|
| `DATE` | `YYYY-MM-DD` | Birthdays, enrollment dates |
| `TIME` | `HH:MM:SS` | Start/end times of events |
| `DATETIME` | `YYYY-MM-DD HH:MM:SS` | Timestamps without timezone |
| `TIMESTAMP` | `YYYY-MM-DD HH:MM:SS` | Same as DATETIME but stores UTC and converts to timezone |
| `YEAR` | `YYYY` or `YY` | Graduation year, fiscal year |

---

## 3. Keys & Constraints

### 3.1 Keys (Identifiers)

| Concept | Definition | Example |
|---------|------------|---------|
| **Superkey** | Any set of columns that uniquely identifies a row | `{stud_id}`, `{stud_id, name}`, `{stud_id, name, email}` |
| **Candidate Key** | A **minimal** superkey — no column can be removed without losing uniqueness | `{stud_id}`, `{email}` |
| **Primary Key** | The candidate key **chosen** as the main identifier | `stud_id` |
| **Foreign Key** | A column that references the primary key of **another** table | `student.major_id → department.dept_id` |

**Key properties:**
- Primary Key = **NOT NULL** + **UNIQUE**
- A table can have only **one** primary key but **multiple** candidate keys.
- Foreign keys enforce **referential integrity** — you can't reference a non-existent row.

### 3.2 Constraints (Column Rules)

| Constraint | Purpose | Example |
|------|--------|---------|
| `PRIMARY KEY` | Uniquely identifies each row | `dept_id INT PRIMARY KEY` |
| `NOT NULL` | Column cannot be empty | `name VARCHAR(100) NOT NULL` |
| `UNIQUE` | No duplicate values allowed | `email VARCHAR(150) UNIQUE` |
| `AUTO_INCREMENT` | Auto-generates next number (MySQL) | `id INT PRIMARY KEY AUTO_INCREMENT` |
| `DEFAULT value` | Fallback value if none provided | `status VARCHAR(20) DEFAULT 'active'` |
| `CHECK (condition)` | Enforces a custom condition | `age INT CHECK (age >= 18)` |
| `REFERENCES` | Foreign key definition | `FOREIGN KEY (major_id) REFERENCES department(dept_id)` |

---

## 3.3 Foreign Key Declarative Integrity

Foreign keys enforce **referential integrity** — they protect data consistency by ensuring relationships between tables remain valid.

- You **cannot insert** a foreign key value that doesn't exist as a primary key in the parent table.
- Depending on the `ON DELETE` / `ON UPDATE` rules, deleting or updating a parent row can:
  - **CASCADE** — propagate the change to child rows.
  - **SET NULL** — set the foreign key to NULL.
  - **RESTRICT / NO ACTION** — throw an error and block the operation.
- Violations of referential integrity throw errors during INSERT, UPDATE, or DELETE operations, preventing **orphaned records** (rows that reference non-existent parents).

### Primary Key vs Foreign Key

| Aspect | Primary Key | Foreign Key |
|--|--|--|
| **Purpose** | Uniquely identifies a row in its own table | Links to the primary key of another table |
| **Null allowed?** | No | Yes (unless also declared NOT NULL) |
| **Duplicates?** | No — must be unique | Yes — multiple rows can reference the same parent |
| **Per table?** | Only one | Multiple foreign keys allowed |
| **Role** | Parent identifier | Child reference (creates parent-child relationship) |

---

## 3.4 Joins

JOIN operations merge rows from two or more tables based on a related column (usually a primary key ↔ foreign key pair).

### Types of Joins

| Join Type | What it Returns |
|-----------|------|
| **INNER JOIN** | Only rows with matching values in **both** tables |
| **LEFT (LEFT OUTER) JOIN** | All rows from the left table + matching rows from right (NULL if no match) |
| **RIGHT (RIGHT OUTER) JOIN** | All rows from the right table + matching rows from left (NULL if no match) |
| **FULL (FULL OUTER) JOIN** | All rows from both tables (NULL where no match on the opposite side) |

### Syntax

```sql
-- INNER JOIN
SELECT columns
FROM table1
INNER JOIN table2 ON table1.key = table2.foreign_key;

-- LEFT JOIN
SELECT columns
FROM table1
LEFT JOIN table2 ON table1.key = table2.foreign_key;
```

### Example

```sql
-- Get student name and the courses they are enrolled in
SELECT s.student_name, c.course_name
FROM students s
INNER JOIN course_enrollments e ON s.student_id = e.student_id
INNER JOIN courses c ON e.course_id = c.course_id;

-- Get all students, even those not enrolled in any course
SELECT s.student_name, c.course_name
FROM students s
LEFT JOIN course_enrollments e ON s.student_id = e.student_id
LEFT JOIN courses c ON e.course_id = c.course_id;
```

### When to Use Which

| Scenario | Join Type |
|--|--|
| Only want records that exist in **both** tables | `INNER JOIN` |
| Want **all** from left, plus matches from right | `LEFT JOIN` |
| Want **all** from right, plus matches from left | `RIGHT JOIN` |
| Want **everything** from both, with NULLs for non-matches | `FULL JOIN` |

---

## 4. Creating Tables

### 4.1 CREATE TABLE Syntax

```sql
CREATE TABLE table_name (
    column1 datatype [constraint],
    column2 datatype [constraint],
    ...
    [table-level constraints]
);
```

### 4.2 Example: Department Table

```sql
CREATE TABLE department (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(100) NOT NULL UNIQUE,
    budget DECIMAL(12, 2) CHECK (budget >= 0),
    location VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**Explanation:**
- `dept_id`: Auto-generated integer, serves as the unique identifier.
- `dept_name`: Must be provided (`NOT NULL`) and must be unique across all rows.
- `budget`: Stores money precisely (up to 999,999,999,999.99). Must be non-negative.
- `location`: Optional string (can be NULL since no `NOT NULL` constraint).
- `created_at`: Automatically set to the current timestamp when the row is inserted.

### 4.3 Example: Student Table

```sql
CREATE TABLE student (
    stud_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    phone VARCHAR(20),
    major_id INT,
    enroll_date DATE,
    gpa DECIMAL(3, 2) CHECK (gpa >= 0.0 AND gpa <= 4.0),
    status ENUM('Active', 'Graduated', 'Withdrawn') DEFAULT 'Active',
    FOREIGN KEY (major_id) REFERENCES department(dept_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
```

**Explanation:**
- `name`: Required.
- `email`: Must be unique across all students.
- `major_id`: Links to a department. If the department is **updated**, the value propagates (`CASCADE`). If the department is **deleted**, `major_id` becomes `NULL` (`SET NULL`).
- `gpa`: Between 0.0 and 4.0.
- `status`: Defaults to `'Active'` if not specified.

### 4.4 Example: Course Table

```sql
CREATE TABLE course (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(10) NOT NULL UNIQUE,
    course_name VARCHAR(100) NOT NULL,
    credits TINYINT NOT NULL CHECK (credits > 0 AND credits <= 6),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
        ON DELETE RESTRICT
);
```

**Explanation:**
- `course_code`: e.g., `"CS101"`, must be unique.
- `credits`: Between 1 and 6.
- `ON DELETE RESTRICT`: Prevents deleting a department if courses are assigned to it (protects data integrity).

### 4.5 Example: Instructor Table

```sql
CREATE TABLE instructor (
    inst_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    dept_id INT NOT NULL,
    hire_date DATE,
    salary DECIMAL(8, 2) CHECK (salary > 0),
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
        ON DELETE CASCADE
);
```

### 4.6 Example: Enrollment (Junction / Bridge Table)

```sql
CREATE TABLE enrollment (
    stud_id INT,
    course_id INT,
    enroll_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    grade VARCHAR(2) CHECK (grade IN ('A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D', 'F', 'W')),
    PRIMARY KEY (stud_id, course_id),
    FOREIGN KEY (stud_id) REFERENCES student(stud_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE
);
```

**Explanation:**
- This is a **many-to-many** relationship table (a student takes many courses; a course has many students).
- The **composite primary key** `(stud_id, course_id)` prevents duplicate enrollments.
- `W` = withdrawn.

---

## 5. Inserting Data

### 5.1 INSERT INTO Syntax

```sql
-- Insert all columns (must match table order)
INSERT INTO table_name VALUES (val1, val2, val3, ...);

-- Insert specific columns (recommended practice)
INSERT INTO table_name (col1, col2, col3) VALUES (val1, val2, val3);
```

### 5.2 Insert into Department First

```sql
INSERT INTO department (dept_name, budget, location) VALUES ('Computer Science', 500000, 'Building A');
INSERT INTO department (dept_name, budget, location) VALUES ('Mathematics', 300000, 'Building B');
INSERT INTO department (dept_name, budget, location) VALUES ('Physics', 450000, 'Building C');
```

### 5.3 Insert into Student (with Foreign Key)

```sql
INSERT INTO student (name, email, major_id, enroll_date, gpa)
VALUES ('Alice Johnson', 'alice@uni.edu', 1, '2025-09-01', 3.85);

INSERT INTO student (name, email, major_id, enroll_date, gpa)
VALUES ('Bob Smith', 'bob@uni.edu', 1, '2025-09-01', 3.20);

INSERT INTO student (name, email, major_id, enroll_date, gpa)
VALUES ('Carol Davis', 'carol@uni.edu', 2, '2025-09-01', 3.90);
```

**Important:** `major_id = 1` references `dept_id = 1` (Computer Science), which must already exist.

### 5.4 Insert with DEFAULT Values

```sql
-- status defaults to 'Active', created_at defaults to CURRENT_TIMESTAMP
INSERT INTO student (name, email, gpa) VALUES ('Dan Lee', 'dan@uni.edu', 3.50);
```

### 5.5 Bulk Insert

```sql
INSERT INTO course (course_code, course_name, credits, dept_id) VALUES
    ('CS101', 'Intro to Programming', 3, 1),
    ('CS201', 'Data Structures', 4, 1),
    ('MATH101', 'Calculus I', 4, 2),
    ('PHYS101', 'Mechanics', 4, 3);
```

### 5.6 Insert into Enrollment

```sql
INSERT INTO enrollment (stud_id, course_id, grade) VALUES
    (1, 1, 'A'),   -- Alice takes CS101
    (1, 3, 'B+'),  -- Alice takes Calculus I
    (2, 1, 'A-'),  -- Bob takes CS101
    (3, 2, 'A');   -- Carol takes Data Structures
```

---

## 6. Retrieving Data — SELECT Queries

### 6.1 Basic Retrieval

```sql
-- Select ALL columns and ALL rows
SELECT * FROM student;

-- Select specific columns
SELECT name, email, gpa FROM student;

-- Select from a different table
SELECT course_code, course_name, credits FROM course;
```

### 6.2 LIMIT — Restrict Rows

```sql
-- Get only the first 5 rows
SELECT * FROM student LIMIT 5;

-- Get the top 3 students by GPA
SELECT name, gpa FROM student ORDER BY gpa DESC LIMIT 3;
```

### 6.3 DISTINCT — Remove Duplicates

```sql
-- Find all unique majors
SELECT DISTINCT major_id FROM student;

-- Before DISTINCT:    1, 1, 2
-- After DISTINCT:     1, 2
```

### 6.4 WHERE — Filtering Rows

#### Comparison Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `=` | Equal | `major_id = 1` |
| `!=` or `<>` | Not equal | `gpa != 4.0` |
| `>` | Greater than | `gpa > 3.5` |
| `<` | Less than | `gpa < 3.0` |
| `>=` | Greater or equal | `credits >= 3` |
| `<=` | Less or equal | `credits <= 4` |

#### Logical Operators

```sql
-- AND: both conditions must be true
SELECT * FROM student WHERE major_id = 1 AND gpa > 3.5;

-- OR: at least one condition must be true
SELECT * FROM student WHERE major_id = 1 OR major_id = 2;

-- NOT: negates a condition
SELECT * FROM student WHERE NOT status = 'Graduated';

-- Combined
SELECT * FROM student WHERE major_id = 1 AND gpa > 3.0 AND status = 'Active';
```

#### BETWEEN — Range Filter

```sql
-- Get students enrolled between two dates
SELECT * FROM student WHERE enroll_date BETWEEN '2024-01-01' AND '2025-12-31';

-- Equivalent to: enroll_date >= '2024-01-01' AND enroll_date <= '2025-12-31'

-- Get courses with credits between 3 and 4
SELECT * FROM course WHERE credits BETWEEN 3 AND 4;
```

#### LIKE — Pattern Matching

| Pattern | Meaning | Example |
|---------|---------|---------|
| `%` | Zero or more characters | `'A%'` = starts with A |
| `_` | Exactly one character | `'A__e'` = 4-char string, starts A, ends e |

```sql
-- Names starting with 'A'
SELECT * FROM student WHERE name LIKE 'A%';

-- Names ending with 's'
SELECT * FROM student WHERE name LIKE '%s';

-- Names containing 'li'
SELECT * FROM student WHERE name LIKE '%li%';

-- 5-character names starting with 'J'
SELECT * FROM student WHERE name LIKE 'J____';
```

#### IN — Multiple Values

```sql
-- Get students in specific departments
SELECT * FROM student WHERE major_id IN (1, 2);

-- Equivalent to: major_id = 1 OR major_id = 2

-- Get students NOT in those departments
SELECT * FROM student WHERE major_id NOT IN (1, 2);
```

#### IS NULL — Check for Missing Values

```sql
-- Students without a phone number
SELECT * FROM student WHERE phone IS NULL;

-- Students with a phone number
SELECT * FROM student WHERE phone IS NOT NULL;

-- Note: Use IS NULL, NOT = NULL. In SQL, NULL is unknown, so 'x = NULL' is always UNKNOWN.
```

### 6.5 ORDER BY — Sorting Results

```sql
-- Default: ascending (A → Z, 0 → 9)
SELECT * FROM student ORDER BY name;

-- Descending (Z → A, 9 → 0)
SELECT * FROM student ORDER BY gpa DESC;

-- Multiple columns: sort by major first, then by GPA within each major
SELECT name, major_id, gpa
FROM student
ORDER BY major_id ASC, gpa DESC;

-- Combine with LIMIT for top/bottom N
SELECT name, gpa FROM student ORDER BY gpa ASC LIMIT 1;  -- lowest GPA
```

### 6.6 Putting It All Together

```sql
SELECT name, gpa, major_id
FROM student
WHERE gpa > 3.0 AND major_id IS NOT NULL
  AND enroll_date BETWEEN '2024-01-01' AND '2025-12-31'
ORDER BY gpa DESC
LIMIT 10;
```

**This query:**
1. Finds students with GPA > 3.0
2. Who have a declared major
3. Who enrolled between 2024 and 2025
4. Sorted by GPA (highest first)
5. Returns only the top 10

---


## 7. Lab Schema — Student Management System

### departments

| Column | Type | Constraints |
|--------|------|-------------|
| `department_id` | INT | PRIMARY KEY AUTO_INCREMENT |
| `department_name` | VARCHAR(100) | NOT NULL UNIQUE |
| `building` | VARCHAR(50) | NOT NULL |

### students

| Column | Type | Constraints |
|--------|------|-------------|
| `student_id` | INT | PRIMARY KEY AUTO_INCREMENT |
| `roll_number` | VARCHAR(20) | NOT NULL UNIQUE |
| `student_name` | VARCHAR(100) | NOT NULL |
| `email` | VARCHAR(100) | NOT NULL UNIQUE |
| `phone` | VARCHAR(15) | UNIQUE |
| `gender` | VARCHAR(10) | NOT NULL |
| `date_of_birth` | DATE | NOT NULL |
| `city` | VARCHAR(50) | |
| `department_id` | INT | FK → departments.department_id |
| `admission_year` | INT | NOT NULL |
| `cgpa` | DECIMAL(3,2) | CHECK (cgpa BETWEEN 0 AND 10) |

### instructors

| Column | Type | Constraints |
|--------|------|-------------|
| `instructor_id` | INT | PRIMARY KEY AUTO_INCREMENT |
| `instructor_name` | VARCHAR(100) | NOT NULL |
| `email` | VARCHAR(100) | NOT NULL UNIQUE |
| `department_id` | INT | NOT NULL, FK → departments.department_id |
| `joining_year` | INT | NOT NULL |

### courses

| Column | Type | Constraints |
|--------|------|-------------|
| `course_id` | INT | PRIMARY KEY AUTO_INCREMENT |
| `course_code` | VARCHAR(20) | NOT NULL UNIQUE |
| `course_name` | VARCHAR(100) | NOT NULL |
| `credits` | INT | NOT NULL, CHECK (credits BETWEEN 1 AND 5) |
| `department_id` | INT | NOT NULL, FK → departments.department_id |
| `instructor_id` | INT | FK → instructors.instructor_id |

### course_enrollments

| Column | Type | Constraints |
|--------|------|-------------|
| `enrollment_id` | INT | PRIMARY KEY AUTO_INCREMENT |
| `student_id` | INT | NOT NULL, FK → students.student_id |
| `course_id` | INT | NOT NULL, FK → courses.course_id |
| `enrollment_date` | DATE | NOT NULL |
| `semester` | INT | NOT NULL, CHECK (semester BETWEEN 1 AND 8) |
| `grade` | VARCHAR(2) | |
| **Unique constraint** | — | UNIQUE(student_id, course_id) |
---

## 8. Lab Questions — Run These Queries on the Database

**Q1.** Show all student records.

```sql
SELECT * FROM students;
```

**Q2.** Show only student names, cities, and CGPA.

```sql
SELECT student_name, city, cgpa FROM students;
```

**Q3.** Show all unique cities students belong to.

```sql
SELECT DISTINCT city FROM students;
```

**Q4.** Find students whose CGPA is greater than 8.5.

```sql
SELECT * FROM students WHERE cgpa > 8.5;
```

**Q5.** Find students from Delhi.

```sql
SELECT * FROM students WHERE city = 'Delhi';
```

**Q6.** Find female students from Bangalore.

```sql
SELECT * FROM students WHERE gender = 'Female' AND city = 'Bangalore';
```

**Q7.** Display students sorted by CGPA from highest to lowest.

```sql
SELECT * FROM students ORDER BY cgpa DESC;
```

**Q8.** Show the top 5 students according to CGPA.

```sql
SELECT * FROM students ORDER BY cgpa DESC LIMIT 5;
```

**Q9.** Display students sorted by admission year first, then CGPA highest to lowest.

```sql
SELECT * FROM students ORDER BY admission_year ASC, cgpa DESC;
```
---
---
## 9. Quick Reference — Query Execution Order

When SQL runs a query, it processes it in this order (not the order you write it):

```
FROM          →  Which tables?
JOIN          →  Combine tables (if applicable)
WHERE         →  Filter rows
GROUP BY      →  Group rows (covered later)
HAVING        →  Filter groups (covered later)
SELECT        →  Choose columns
ORDER BY      →  Sort results
LIMIT         →  Restrict row count
```

Understanding this order helps explain why `WHERE` cannot use aliases defined in `SELECT`.

---


## 10. Glossary

| Term | Definition |
|------|------------|
| **Table** | A collection of related data in rows and columns |
| **Row (Tuple)** | A single record in a table |
| **Column (Attribute)** | A field in a table that defines a property of the entity |
| **Primary Key** | Unique identifier for a row |
| **Foreign Key** | Reference to a primary key in another table |
| **Constraint** | A rule on column data |
| **Schema** | The overall structure/design of the database |
| **DDL** | Data Definition Language (CREATE, ALTER, DROP) |
| **DML** | Data Manipulation Language (SELECT, INSERT, UPDATE, DELETE) |
| **Referential Integrity** | Ensuring foreign keys always point to valid primary keys |