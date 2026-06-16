# Database Indexing - Detailed Notes

## Glossary of Key Terms

| Term | Definition |
|---|---|
| **Index** | A data structure that improves the speed of data retrieval operations on a database table. |
| **B-tree** | A balanced multi-level data structure that supports searching, insertion, deletion operations efficiently. |
| **B+ tree** | An extension of B-tree that stores all data at the leaf level and uses internal nodes as index nodes. |
| **Full Table Scan** | A search operation where the database reads every row to find matching criteria. |
| **Composite Index** | An index that covers two or more columns used for optimizing queries. |
| **Re-indexing** | The process of rebuilding indexes on a table following updates to ensure efficiency. |
| **Primary Key** | A unique token or column that uniquely identifies each row in a database table and is automatically indexed. |
| **Binary Search Tree** | A tree data structure where each node has at most two children and supports efficient search operations. |
| **Unique Index** | An index that ensures all values in the index column are distinct. |
| **Node** | A fundamental part of data structures like trees and graphs, representing each element within the structure. |
| **Clustered Index** | An index that sorts and stores table rows based on their key values, often on the primary key. |
| **Self Balancing Binary Search Tree** | A binary search tree that automatically keeps its height small in the face of arbitrary item insertions and deletions. |

---

## 1. Introduction to Indexing

### Why is Indexing Required?
- Consider Netflix: **325 million paid subscribers**, **782 million profiles**. Searching row-by-row for records in such a huge table is highly inefficient.
- If data were stored as an array or in continuous memory, **binary search** could reduce time complexity from **O(n)** to **O(log n)**.
- But database data is **not stored in continuous memory** — it is scattered across the hard disk. Moving/sorting original data on disk is prohibitively slow.

### Core Idea of Indexing
- Create a **secondary lookup table** (index) that stores:
  - The **attribute value** (e.g., account ID) in **sorted order**.
  - The **memory/disk address (pointer)** where the actual record resides.
- The original data remains untouched; only the index is modified during searches, insertions, updates, and deletions.
- This enables **binary search** on the attribute, achieving **O(log n)** lookup time.

### Real-Life Analogy
> A book's index/table of contents maps chapter names to page numbers. It doesn't store the actual content — it is just a shortcut to find where the data (content) is located.

---

## 2. Default/Automatic Indexes

When you create a table in a database, certain indexes are automatically created:

| Constraint | Automatically Indexed? | Reason |
|---|---|---|
| **Primary Key** | Yes | Always unique; enables optimal search and access. |
| **UNIQUE attribute** (e.g., email, phone) | Yes | Enforces uniqueness constraint; need fast lookup to verify. |

### Should Foreign Keys Be Indexed?
- **Yes**, for large tables where joins are frequent.
- When performing a `JOIN` on a foreign key that is **not indexed** in the child/dependent table, the database must perform a full scan — very slow.
- For small tables (e.g., reference tables with ~1000 rows), indexing is unnecessary since full scans are fast enough.

### Key Takeaway
> **Creating an index does NOT require the attribute to be unique.** You can (and should) index non-unique attributes like `order_date`, `customer_id`, etc., if they are frequently queried.

---

## 3. Drawbacks of Too Many Indexes

Indexing is a **trade-off**. While it speeds up reads, it slows down writes:

### Impact on Write Operations
For every **INSERT**, **UPDATE**, or **DELETE** on an indexed table:
1. The index data structure must also be **updated / re-indexed**.
2. This is a **heavy operation** — it must be done for all indexes on the table.

### When Does Re-indexing Happen?
- When an attribute value involved in an index is **modified** (e.g., user updates their email).
- The sorted order in the index may no longer be valid → reorganization required.
- **Re-indexing does NOT mean finding new locations**; it means maintaining the correct **sorted order** within the existing data structure.

### Myth Busting
> **Myth:** "More indexes = always faster search."
> - True only for read-heavy workloads.
> - For write-heavy tables, too many indexes can severely degrade performance.

---

## 4. What is an Index? (Summary Definition)

An **index** is a data structure that:
- Stores the **value of the indexed attribute(s)**.
- Stores the **row location / pointer** to where that record exists in the table.
- Helps the database **locate rows much faster** than a full table scan.

---

## 5. Binary Search Tree (BST) - Foundation for Indexing

### Definition of BST
A tree where for every node **x**:
- All elements in the **left subtree** are **≤ x**.
- All elements in the **right subtree** are **> x**.

### Properties of BST
| Operation | Time Complexity | Notes |
|---|---|---|
| Search | O(height) | One path from root to leaf. |
| Insert | O(height) | Find the null spot and insert. |
| Delete | O(height) | Similar traversal logic. |

### Worst Case Problem
- If nodes are inserted in sorted order, BST becomes a **skewed tree** with height = **O(n)**.
- This destroys the purpose of using BST (degrades to linear search).

### Solution: Self-Balancing BST
- Automatically adjusts structure on insertion/deletion.
- Ensures height always remains **O(log n)**.
- Search, insert, and delete all stay at **O(log n)**.

---

## 6. B-Tree

### What is a B-Tree?
A **B-Tree of order M** is an enhanced tree structure where:
- Each node can have **multiple keys** (not just one like BST).
- Each node can have up to **M children** (maximum **M-1 keys** per node).
- Keys within each node are stored in **sorted order** (enabling binary search within the node).

### How a B-Tree Node Works
If a node has keys **[35, 65]**:
| Partition | Keys fall in range |
|---|---|
| Left child | ≤ 35 |
| Middle child | > 35 AND ≤ 65 |
| Right child | > 65 |

### Why B-Tree over BST for Databases?
1. **Disk I/O efficiency**: One disk read fetches a whole chunk/page of keys (not just one key). This reduces the number of disk I/O operations needed to traverse the tree.

---

## 7. B+ Tree

### What is a B+ Tree?
A **B+ Tree** is an enhanced version of a B-Tree used by databases for indexing. It has two key differences from a standard B-Tree:

1. **Data only at leaf level**: All actual data (the row pointers) are pushed down to the leaf nodes. Internal/root nodes only contain routing keys — they do not store any data, helping distinguish between keys and data.
2. **Linked leaf nodes**: All leaf nodes are connected to each other via a linear chain of `next` pointers (similar to a linked list), enabling efficient range queries.

### Why B+ Tree over B-Tree?
| Feature | B-Tree | B+ Tree |
|---|---|---|
| Data location | Data at all levels | Data only at leaf level |
| Leaf nodes | Not connected | Linked via `next` pointers |
| Disk I/O | More I/O due to scattered data | Fewer I/O, more keys per level = flatter tree |

The B+ Tree is the standard index structure in most modern databases.

---

## 8. Composite Indexes

A composite index spans **multiple columns** within a single table.

### Leftmost Prefix Rule
A composite index can only be used if the query starts with the **leftmost column** of the index.

| Index | Query Filter | Optimized? | Reason |
|---|---|---|---|
| `(department_id, salary)` | `WHERE department_id = 2 AND salary > 50` | Yes | Starts with leftmost column |
| `(department_id, salary)` | `WHERE department_id = 7` | Yes | Leftmost column only is valid |
| `(department_id, salary)` | `WHERE salary = 60000` | No | Does not start with leftmost column |

### Key Takeaway
> A composite index is ordered **column by column**. The sorting on the second attribute (e.g., salary) is relative to a specific value of the first attribute (e.g., department_id).

---

## 9. SQL Syntax for Indexes

### Creating an Index
```sql
CREATE INDEX index_name
ON table_name (col1, col2, ...);
```

### Creating a Unique Index
```sql
CREATE UNIQUE INDEX index_name
ON table_name (col1, col2, ...);
```
- Ensures the indexed attribute(s) are **unique**. Used when needing to enforce uniqueness on a combination of attributes (single unique attributes are already automatically indexed).

### Dropping an Index
```sql
DROP INDEX index_name ON table_name;
```

### Listing Existing Indexes
```sql
SHOW INDEXES FROM table_name;           -- MySQL
SHOW INDEX FROM table_name FROM db_name; -- With database name
```

### Key Note on Syntax Differences (MySQL vs PostgreSQL)
- **MySQL**: Always includes `table_name` in the index definition.
- **PostgreSQL**: Index name must be unique across the entire system (no `ON table_name` needed).

... [294 lines truncated] ...
