# Intro to DBMS, Relational Models & SQL Queries
## Comprehensive Lecture Notes

---

## 1. Course Context

### 1.1 Course Description
*   **Credit Value:** 4 Credits
*   **Scope:** Broad overview of Database Management Systems
*   **Content Weighting:**
    *   ~25% Theory
    *   ~75% Practical / Hands-on

### 1.2 Key Focus Areas
| Area | Details |
|------|---------|
| **SQL Databases** | MySQL and PostgreSQL (NOT NoSQL databases) |
| **Data Analysis** | Extracting insights from structured data |
| **Schema Design** | The process of planning and structuring a database schema that defines how data is stored |
| **Optimization** | Query performance tuning |
| **Availability & Security** | Data protection and fault tolerance |

### 1.3 What We Will NOT Cover
*   File-system level databases
*   In-memory databases
*   Distributed databases
*   Cloud-native database architectures
*   NoSQL databases

### 1.4 Assessment
*   **Schema Design Project** (Group of 10 students):
    *   Select an application from a given list
    *   Create its ER diagrams
    *   Build the full schema
    *   Answer related queries
    *   Includes a waiver exam for the entire group
*   **Written Exam:** Focus on isolation levels and query writing
*   **Remaining assessments:** To be shared later

---

## 2. Why Do We Need Databases?

### 2.1 The Problem with File-Based Systems (CSV)

Real-world applications cannot rely on simple file storage (e.g., CSV) for several critical reasons:

#### **Concurrency**
*   Multiple transactions occurring simultaneously on a database to ensure efficiency. A DBMS handles **locking** and **access control** to prevent data corruption.
*   **Parallel Programming:** Programming technique that involves executing multiple operations concurrently.
*   A file can only be accessed by one thread at a time, creating bottlenecks.
*   **Example scenario:** Two students (Bob and Alice) try to enroll in the same course. Bob enrolls first. Alice checks enrollment -- it shows the course is available -- and tries to enroll. If Bob's enrollment hasn't been written yet, both may enroll, resulting in **duplicate entries** for the same student-course pair.

#### **Consistency**
*   A property ensuring that database transactions must only bring the database from one valid state to another.
*   Ensures data integrity across systems. Without a central DB, merging data from 100 different users creates conflicts.
*   Data in a DBMS is always accurate and valid at any point in time.

#### **Security**
*   When storing data in a file system, implementing granular access control is very complex.
*   Need to manage:
    *   **Who** can access the data
    *   **What** actions they can perform (read, write, delete)
*   File-level permissions are too coarse-grained. RDBMS provides granular access control (roles/permissions).

#### **Scalability & Availability**
*   **Size:** If you store all student records in a single CSV and want to find one specific student, you must iterate through the file line by line. This is **O(n)** linear complexity -- extremely slow for millions of records. DBMS handles millions of entries efficiently without linear scanning.
*   **Redundancy:** Data is available even if one server copy crashes (backup/recovery).

#### **Data Integrity**
*   With file-based storage, there is no built-in mechanism to prevent:
    *   Duplicate entries (e.g., same student enrolled in the same course twice)
    *   Invalid data (e.g., negative marks, missing required fields)
*   Ensuring consistency requires manual validation code.

### 2.2 The Solution: RDBMS

**Relational Database Management Systems (RDBMS)** solve all these problems:

| Feature | CSV/File-System | RDBMS |
|---------|-----------------|-------|
| **Organization** | Flat, unstructured | Structured tables with relationships |
| **Concurrency** | Single-threaded access | Multi-threaded, concurrent access |
| **Consistency** | Manual validation | Built-in constraints and rules |
| **Availability** | No built-in backup | Automated backups |
| **Performance** | O(n) linear scan | Indexed lookups (much faster) |

---

## 3. Relational Model -- The Foundation

### 3.1 Key Terminology

| Term | Definition | Example |
|------|------------|---------|
| **Entity** | A distinct object in a database that can be physical or abstract, such as a student or course | Student, Course, Instructor |
| **Relationship** | A connection/link between entities | Enrollment (links Student and Course) |
| **Attribute** | A property/characteristic of an entity | Name, Roll Number, Date of Birth |
| **Table** | Represents an Entity type | A "Student" table stores all students |
| **Column** | Represents an Attribute | "Name" column stores student names |
| **Row** | Represents a single record/instance | One specific student's data |
| **Schema** | The definition/blueprint of the table structure | List of columns, data types, and constraints |

### 3.2 Entity-Relationship Example

```
Entity: Student [Enrollment] Entity: Course
      |                            |
      v                            v
  (Attributes)                  (Attributes)
  - Roll Number                 - Course ID
  - Name                        - Course Name
  - Email                       - Instructor Name
  - Phone                       - Credits
```

### 3.3 Why Use the Relational Model?

1.  **Logical Organization:** Data is split across multiple tables rather than stored in one huge file
2.  **Built-in Relationships:** Tables can reference each other through keys
3.  **Constraints:** Data validity is enforced at the database level
4.  **Querying Power:** SQL provides a standardized language for complex data operations

---

## 4. Keys & Constraints

### 4.1 Primary Key

A **Primary Key** is a unique identifier for a record in a database table, ensuring uniqueness and non-nullability. It uniquely identifies each row in a table.

**Rules:**
1.  **Unique:** No two rows can have the same primary key value
2.  **Not Null:** Cannot be empty for any row
3.  **Single:** Each table has exactly ONE primary key
4.  **Immutable:** Typically should not change once set

**Types:**

| Type | Description | Example |
|------|-------------|---------|
| **Single-Column Key** | One column serves as the primary key | `student_id` in a Student table |
| **Composite Key** | Two or more columns together form the primary key | `(course_id, roll_no)` in an Enrollment table |

### 4.2 Constraints

Constraints are rules applied to columns to enforce data integrity.

| Constraint | Description | Example |
|------|------|---------|
| **NOT NULL** | Value cannot be empty/NULL | `name VARCHAR(50) NOT NULL` |
| **UNIQUE** | No two rows can have the same value in this column | `email VARCHAR(100) UNIQUE` |
| **AUTO_INCREMENT** | An SQL table column feature that automatically assigns sequential values to entries | `id INT AUTO_INCREMENT` |
| **DEFAULT** | Provides a default value if none is specified | `status VARCHAR(20) DEFAULT 'active'` |

### 4.3 Keys Deep Dive

| Key Type | Description | Purpose |
|--|----|---|
| **Primary Key** | Uniquely identifies a record in its own table | Must be Unique + Not Null |
| **Foreign Key** | Links to the primary key of another table | Establishes relationships between tables |
| **Composite Key** | Two or more columns combined as the primary key | Used when no single column is unique enough |

### 4.4 Common Data Types

| Data Type | Description | Example Values |
|--|----|----|
| **INT** | Integer (whole number) | 1, -5, 1000 |
| **VARCHAR(n)** | Variable-length text string, max n characters | 'John', 'abc123' |
| **TEXT** | Longer text content | Paragraphs, descriptions |
| **DATE** | Date value | 2024-01-15 |
| **DECIMAL(p, s)** | Precise decimal numbers (for money, grades) | 95.50, 3.14 |

---

## 5. SQL Basics -- MySQL

### 5.1 Installation

1.  **MySQL Server:** Download from the official MySQL website
2.  **CLI/Command Line:** After installation, ensure MySQL is in your system PATH (Bash/Zsh)
3.  **MySQL Workbench (Optional but Recommended):** Visual GUI client for managing databases

### 5.2 Basic SQL Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `SHOW DATABASES;` | List all databases | `SHOW DATABASES;` |
| `CREATE DATABASE <name>;` | Create a new database | `CREATE DATABASE college;` |
| `USE <name>;` | Select a database to work on | `USE college;` |
| `SHOW TABLES;` | List tables in current database | `SHOW TABLES;` |
| `CREATE TABLE ...;` | Define a new table | See below |
| `DESCRIBE <table>;` | View table schema | `DESCRIBE student;` |

### 5.3 Creating a Table -- Detailed Example

```sql
CREATE TABLE Student (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    email VARCHAR(30) NOT NULL UNIQUE,
    batch VARCHAR(5),
    contact VARCHAR(15) NULL
);
```

**Schema Breakdown:**

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| `student_id` | INT | AUTO_INCREMENT, PRIMARY KEY | System-generated unique ID |
| `name` | VARCHAR(20) | NOT NULL | Student name (max 20 chars, cannot be empty) |
| `email` | VARCHAR(30) | NOT NULL, UNIQUE | Email (cannot be empty or a duplicate) |
| `batch` | VARCHAR(5) | (none) | Batch identifier (e.g., "B1", "2025") |
| `contact` | VARCHAR(15) | NULL | Phone number (optional/nullable) |

### 5.4 Understanding the Schema Output

After creating the table, use `DESCRIBE student;` to see:

| Field | Type | Null | Key | Default | Extra |
|-------|------|------|-----|---------|-------|
| student_id | int | NO | PRI | NULL | auto_increment |
| name | varchar(20) | NO | | NULL | |
| email | varchar(30) | NO | UNI | NULL | |
| batch | varchar(5) | YES | | NULL | |
| contact | varchar(15) | YES | | NULL | |

**Column Legend:**
*   **Null:** `NO` = NOT NULL constraint, `YES` = allows NULL values
*   **Key:** `PRI` = Primary Key, `UNI` = Unique constraint
*   **Extra:** `auto_increment` = auto-generates next available ID

### 5.5 CRUD Operations

| Operation | SQL Keyword | Description |
|------|----|-----------|
| **Create** | `INSERT` | Add new rows to a table |
| **Read** | `SELECT` | Query/ retrieve rows from a table |
| **Update** | `UPDATE` | Modify existing rows |
| **Delete** | `DELETE` | Remove rows from a table |

---

## 6. Course Structure Summary

```
Week 1-3:   SQL Basics
             |-- Queries: SQL Query = a statement to perform a specific operation on data in an SQL database
             |-- Joins: A SQL operation for combining data from two or more tables based on a related column
             |-- Aggregate Functions (AVG, SUM, COUNT, etc.): An Aggregate Query computes results based on aggregate functions
             |-- Subqueries / Nested Queries

Week 4-6:   Schema Design
             |-- Normalization
             |-- ER Diagrams (Entity-Relationship): A data modeling tool illustrating the database's entities and relationships
             |-- Multi-table organization

Week 7-9:   Optimization & Advanced Topics
             |-- Indexing
             |-- Transactions (ACID Properties)
             |-- Isolation Levels: Defines the degree to which data in a database operation is isolated from other operations
```

---

## 7. Key Takeaways

1.  **Databases exist to solve problems that file-based systems cannot handle:** concurrency, security, performance, and data integrity
2.  **The Relational Model** organizes data into tables (entities) with columns (attributes) and rows (records), linked by relationships
3.  **Primary Keys** uniquely identify rows; they must be unique and non-null
4.  **Constraints** (NOT NULL, UNIQUE, AUTO_INCREMENT, DEFAULT) enforce data quality at the schema level
5.  **Keys** (Primary, Foreign, Composite) establish structure and relationships between tables
6.  **MySQL/PostgreSQL** are the RDBMS tools that implement the relational model
7.  **SQL** is the standardized language for creating, querying, and manipulating data in RDBMS
8.  **The course is ~75% practical** -- focus on hands-on practice with MySQL and PostgreSQL

---

## 8. Action Items & Homework

1.  **Install MySQL:** Ensure the MySQL Server is installed and configured in your system path (Bash/Zsh).
2.  **Install MySQL Workbench:** Recommended for visualization (optional if you are comfortable with CLI).
3.  **Practice Queries:** Familiarize yourself with the syntax for:
    *   `CREATE TABLE`
    *   `INSERT INTO`
    *   `UPDATE`
    *   `DELETE FROM`

**Note on Tools:**
*   For syntax reference, you can check the [MySQL Reference Manual](https://dev.mysql.com/doc/) online.
*   AI tools can help, but focus on understanding the logic rather than just asking for the code.
