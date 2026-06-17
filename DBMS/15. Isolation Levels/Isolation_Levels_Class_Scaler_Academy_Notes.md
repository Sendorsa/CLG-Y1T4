# DBMS: Transaction Management & Isolation Levels — Lecture Notes

## Agenda

1. Introduction to Transactions
2. ACID Properties
3. Commit & Rollback
4. Transaction States
5. Concurrency Problems (Anomalies)
6. Isolation Levels

---

## 1. Introduction to Transactions

### Why are Transactions Needed?

**Real-world example — Bank Transfer (Same Bank)**

**Example: Airline Booking**

1. Reserve Seat
2. Generate Ticket
3. Process Payment

If payment fails:
- Ticket should not be generated
- Seat reservation should be cancelled

All operations must succeed together.

**Real-world example — Bank Transfer (Same Bank)**

- User `Iusones` transfers ₹10,000 to `Hersheyth`
- Account balances: Iusones = ₹50,000 | Hersheyth = ₹20,000

**Without transactions**, the SQL queries are:

```sql
-- Step 1: Debit sender
UPDATE accounts SET balance = balance - 10000 
WHERE account_id = 'Iusones';

-- Step 2: Credit receiver
UPDATE accounts SET balance = balance + 10000 
WHERE account_id = 'Hersheyth';
```

**Problem:** If the system crashes after Step 1 but before Step 2:
- Iusones loses ₹10,000
- Hersheyth still has ₹20,000
- ₹10,000 disappears — money is lost!

**Other real-world examples requiring transactions:**
- Ticket booking (payment + seat blocking)
- E-commerce orders (inventory deduction + order creation)
- UPI transfers
- Any operation involving multiple SQL updates/deletes/inserts

### What is a Transaction?

A **transaction** is a **single logical unit of work** that may involve one or many SQL operations. It must:

1. **Either complete fully** — all operations succeed
2. **Or fail completely** — no partial results are allowed

> A transaction is defined by a *unit of work*, not by the number of SQL operations.

### Transaction Structure

```
START TRANSACTION;
  SQL statement 1;
  SQL statement 2;
  SQL statement 3;
  ...
COMMIT;      -- Makes all changes permanent
-- OR
ROLLBACK;    -- Undoes ALL changes made during this transaction
```

- **`COMMIT`**: Tells the database to permanently copy temporary changes to the hard disk. Changes become:
  - Permanent and cannot be undone by rollback
  - Visible to other users
  - Surviving system failures
  
- **`ROLLBACK`**: Discards ALL changes, restores database to pre-transaction state. After rollback:
  - No changes are saved
  - Database returns to original state

### Auto-Commit Setting

- By default, SQL servers have **auto-commit ON** — each query is its own transaction
- When **auto-commit OFF**: Changes are stored in a temporary file, not written to disk
- Only when **COMMIT** is issued do changes become permanent
- Changes during auto-commit OFF are **not undoable with Ctrl+Z** — only `ROLLBACK` can undo them

## 2. Commit & Rollback

### COMMIT
- Makes all changes in the transaction **permanently recorded** in the database
- Once committed, changes cannot be undone by rollback
- Changes become permanent and survive system failures

### ROLLBACK
- Used when a transaction cannot be completed (error/failure)
- Reverts the database back to its **previous state before the transaction began**
- After rollback: no changes are saved, database returns to original state

---

## 3. ACID Properties of Transactions

Every transaction must satisfy these four properties:

| Property | Description |
|----------|-------------|
| **Atomicity** | All or nothing — the entire transaction completes successfully OR none of it does |
| **Consistency** | A transaction takes the database from one valid state to another (preserves integrity constraints) |
| **Isolation** | Concurrent transactions do not interfere with each other |
| **Durability** | Once committed, changes are permanent and survive system failures |

### Atomicity
- Ensures no partial execution. If any step fails, the entire transaction is rolled back
- **Key idea: ALL OR NOTHING** — no partial execution is allowed

### Consistency
- Database constraints (primary keys, foreign keys, triggers) are maintained
- The database moves from a valid state to another valid state before AND after the transaction
- All business rules and integrity constraints are preserved

### Isolation
- Multiple concurrent transactions execute without interference
- Each transaction sees a consistent view of other transactions (committed or uncommitted depending on isolation level)
- Goal of isolation: Create the illusion that each transaction runs alone — even though thousands may execute simultaneously

### Durability
- Once a transaction is committed, its changes survive any subsequent crash/failure
- Achieved through techniques like:
  - Write-Ahead Logging (WAL)
  - Transaction Logs
  - Recovery Systems
  - Backups

---

## 4. Transaction States

A transaction passes through several states during its lifecycle:

| State | Description |
|-------|-------------|
| **Active** | The transaction is currently executing SQL statements |
| **Partially Committed** | All SQL statements have executed successfully but COMMIT has not yet occurred |
| **Committed** | COMMIT has been executed successfully. Changes become permanent and are written to the database |
| **Failed** | The transaction encounters an error that prevents continued execution. Possible causes: System crash, Power failure, Constraint violation, Deadlock, Invalid input |
| **Aborted** | ROLLBACK is performed after a failed state. All changes are undone and the database returns to its previous state before the transaction began |

---

## 5. Concurrency & Problems It Causes

### What is Concurrency?

**Multiple transactions executing simultaneously** — multiple users, ATMs, UPI apps all accessing/modifying the same data at the same time.

**Examples:**
- Book My Show: thousands of users booking tickets simultaneously
- IRCTC: thousands of users trying to book train tickets when portal opens
- ATM withdrawal + UPI transfer on the same account

---

### Concurrency Anomalies (Problems)

#### 5.1 Dirty Read

- A transaction reads data written by another transaction that has **not yet committed**
- If that other transaction rolls back, the reading transaction has used invalid (uncommitted) data

**Example scenario:**
```
T1: Transfer ₹10,000 from User1 → Harshit's account      (started, not committed)
T2: Harshit checks his balance                             (reads uncommitted data!)
T2 sees new balance but money hasn't actually arrived yet
T1 fails → rollback → User1 gets refunded
Harshit now thinks he has money he doesn't — argument begins!
```

**Dangers:**
- Incorrect reports based on invalid data
- Wrong decisions made on stale/uncommitted data
- Multiple calculations using incorrect values

---

#### 5.2 Lost Update (Most Important Anomaly)

- One transaction **overrides/overwrites** the update of another concurrent transaction
- Both transactions read the same value, independently update it, and write back — one result is lost

**Example:**
```
Initial balance = ₹10,000

T1: Withdraw ₹2,000    →  reads ₹10,000    →  writes ₹8,000
T2: UPI transfer ₹3,000 →  reads ₹10,000    →  writes ₹7,000

Result in DB = ₹7,000  but should be ₹5,000 (₹10,000 - ₹2,000 - ₹3,000)
The ₹2,000 withdrawal was LOST because T2's update overwrote it!
```

**Fix:** While one transaction is updating a value, no other transaction should be able to read/write that same value.

---

#### 5.3 Non-Repeatable Read

- The **same row** is read twice within a transaction and **different values are obtained** (because another committed transaction modified it between reads)

**Example — E-commerce checkout:**
```
1. T1 reads user wallet balance = $100
2. User selects item worth $80
3. T1 verifies: $100 ≥ $80 ✓ (valid purchase)
4. T1 generates shipping label, reduces inventory
5. Meanwhile, another transaction deducts $50 subscription fee
6. T1 re-reads balance before final order = $50 (was $100!)
7. T1 now discovers there's not enough money — must undo everything done in steps 3-4

Anomaly: The balance changed from within the same transaction!
```

---

#### 5.4 Phantom Read

- The **same query** returns a **different set of rows** during execution of a transaction (because another transaction inserted/deleted rows matching the query)

**Example — Movie ticket booking:**
```
T1: Query 1 → shows seats [1, 2, 3, 4] as available
    Friend discussion... "Let's book all four!"
    T1 clicks on the proceed button
T2 (concurrent): Books seat 3 and 4 → commits
    
T1: Query 2 → shows only seats [1, 2] available!
    Seats 3 and 4 DISAPPEARED (were "phantom-read"!)

The two queries should have returned the same set but didn't!
```

**Key difference between Phantom Read and Non-Repeatable Read:**
| **Non-repeatable read** | A specific row's data changes between reads (same row, different value) |
| **Phantom read** | Different rows are returned between two queries with same WHERE clause (different SET of rows, not different values within a row) |

> **Distinct Keys:** Non-repeatable read = same row, different data → Phantom read = different rows (rows appear or disappear entirely)

---

## 3. Isolation Levels

There are four levels of isolation in increasing strictness:

| Level | Dirty Read | Non-Repeatable Read | Phantom Read | Performance |
|-------|------------|---------------------|--------------|-------------|
| **1. Read Uncommitted** (lowest) | Yes | Yes | Yes | Fastest |
| **2. Read Committed** | No | Yes | Yes | Most commonly used |
| **3. Repeatable Read** | No | No | Yes | — |
| **4. Serializable** (highest) | No | No | No | Lowest performance — transactions behave as if executed one after another sequentially |

---

## 4. Real-World Applications

| Domain | Examples |
|--------|----------|
| **Banking Systems** | Money Transfer, Deposit, Withdrawal |
| **E-Commerce Systems** | Order Placement, Inventory Update, Payment Processing |
| **Airline Reservation** | Seat Booking, Ticket Generation, Payment Confirmation |
| **Hospital Management** | Patient Registration, Billing, Medical Record Updates |
| **University Management** | Course Registration, Fee Payments, Attendance Updates |

---

## Key Terminology Summary

| Term | Definition |
|------|-----------|
| **Transaction** | A logical unit of work — all or nothing execution |
| **COMMIT** | Makes transaction changes permanent on disk |
| **ROLLBACK** | Discards all uncommitted changes within the transaction |
| **Auto-commit** | Default SQL setting where each query is auto-committed |
| **Atomicity** | All-or-nothing property of transactions |
| **Consistency** | Transactions maintain database integrity constraints |
| **Isolation** | Concurrent transactions don't interfere with each other |
| **Durability** | Committed changes survive any system failure |
| **Dirty Read** | Reading uncommitted data from another transaction |
| **Lost Update** | One transaction's update is overwritten by another |
| **Non-repeatable Read** | Same row returns different values between reads in a transaction |
| **Phantom Read** | Same query returns different sets of rows between reads in a transaction |
| **Concurrency** | Multiple transactions executing simultaneously on the same data |
| **Isolation Level** | Defines the degree to which a transaction's changes are visible to other concurrent transactions |

---

## Quick Exam Revision

- **Transaction:** A sequence of operations treated as a single logical unit of work.
- **COMMIT:** Permanently saves changes.
- **ROLLBACK:** Undoes changes.
- **Atomicity:** All operations execute or none execute (ALL OR NOTHING).
- **Consistency:** Database moves from one valid state to another valid state (preserves constraints).
- **Isolation:** Concurrent transactions do not interfere with each other.
- **Durability:** Committed changes remain permanent, achieved via WAL/Transaction Logs/Recovery Systems/Backups.
- **Dirty Read:** Reading uncommitted data.
- **Lost Update:** One update overwrites another (MOST IMPORTANT ANOMALY).
- **Non-Repeatable Read:** Same row returns different values.
- **Phantom Read:** Same query returns different rows.
- **ACID:** Atomicity + Consistency + Isolation + Durability.

---

*Next Session: Lab simulation — creating concurrency anomalies and observing how different isolation levels prevent them using locks.*
