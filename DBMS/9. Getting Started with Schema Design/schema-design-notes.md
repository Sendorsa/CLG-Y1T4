# Schema Design - Class Notes
**Based on: Getting Started with Schema Design - Scaler Academy**

---

## 1. Introduction to Schema Design

### What is Schema Design?
Schema design is the process of organizing data into structured relational models that accurately represent a business system. It involves deciding:
- What **tables** exist in the database
- What **columns** should be present in each table
- How tables **connect** to each other
- What **constraints** the system must impose

### Why Schema Design Matters
- Databases are not "magical containers" — you can't just dump data without planning
- A good schema design **survives for years**, not requiring updates every few months
- Poor design leads to **redundancy**, **update inconsistency**, **scalability problems**, and **maintenance challenges**

### The Process of Schema Design
1. Identify **business case problem**
2. List all **business operations/activities**
3. For each activity, determine what **information** must be stored
4. Categorize information based on **ownership and responsibility**
5. Translate into database concepts (entities, attributes, keys)

---

## 2. Business Case: Food Delivery Platform

### Example Scenario
Food delivery platform similar to **Swiggy**, **Zomato**, or **Uber Eats**:
- Receives **millions of orders per day**
- Multiple activities happen every second

### Major Business Activities
| # | Activity | Information Generated |
|---|----------|----------------------|
| 1 | User places order | Order details, status, payment info |
| 2 | Restaurant registers on platform | Restaurant name, location, rating |
| 3 | Restaurant uploads/updates menu | Menu items, prices, images |
| 4 | Delivery partner gets assigned | Partner details, vehicle number |
| 5 | Delivery partner completes delivery | Delivery status, time, proof |
| 6 | User signup on platform | Customer name, phone, email |
| 7 | User rates restaurant/items | Rating, review text, timestamps |
| 8 | Payment happens | Amount, method, reference ID |
| 9 | Delivery status updated | Current status, location info |

### Information Requirements by Entity

| Entity | Key Information Needed |
|--------|-----------------------|
| **Orders** | Customer name, address, restaurant name, order items, payment amount & status, delivery partner, order status |
| **Restaurants** | Name, location, ratings, phone number, menu, operational status, cuisine type, bank details |
| **Delivery Partners** | Name, vehicle number, license number, rating, availability status, joining date, total earnings |

### What NOT to Store
- **Recommendations** — skipped for this discussion (advanced concept requiring data analysis)
- **Redundant attributes** — e.g., storing customer contact in every order when you already have customer name

---

## 3. Business Objects

### Definition
Business objects are the **important things** a company cares about. They are the building blocks of the database.

### Key Business Objects for Food Delivery Platform
- **Customers**
- **Restaurants**
- **Orders**
- **Delivery Partners**
- **Payments**

> A good database engineer first identifies: What does the business do? What information matters? What are the business objects? And how do different parts interact with each other?

---

## 4. Separation of Responsibility (Data Ownership)

### Principle
Information should be categorized based on **ownership and responsibility**:
- **Who owns that information?**
- **Who is responsible for maintaining and updating it?**

### Example
- Restaurant name and phone number belong to the **restaurant** table
- An order is **not** responsible for maintaining restaurant name/phone
- If restaurant changes its name, only the restaurant table needs updating

### Why This Matters at Scale
- Millions of users, restaurants, and orders exist in real systems
- **Redundancy becomes expensive**
- **Updates become dangerous** with duplicated data
- Proper separation enables a schema that survives for years

---

## 5. Entities and Entity Sets

### Entity
An entity is an **indistinguishable real-world object** about which information is stored in the database.

> In simple words: A thing that the business cares about. Often these are **nouns** in the business context.

**Examples from Food Delivery Platform:**
- Customer (one specific person)
- Restaurant (e.g., "Pizza Hub")
- Order
- Payment (one specific transaction)
- Delivery Partner

### Entity Set
A collection of similar entities together forms an entity set. In **relational databases**, entity sets become **tables**.

| Concept | Example | Database Equivalent |
|---------|---------|---------------------|
| Entity | One customer named Rahul | One row in a table |
| Entity Set | All customers | A Customer table |

### Key Takeaway
Each table represents a **meaningful business object** — not created randomly.

---

## 6. Types of Entities

### Strong Entity
An entity that can be identified **uniquely on its own** — it does not depend on other entities.

**Examples:**
- Customer (can exist independently)
- Restaurant (can exist independently)
- Payment (can exist independently)

### Weak Entity
An entity that **cannot be uniquely identified on its own** — it depends on a strong (parent) entity for identity.

**Examples:**
- Order Items (depends on both Orders and Menu Items tables)
- Reviews (depends on Customer, Restaurant/Order)

> Weak entities often appear in **junction tables** that link two or more other entities.

---

## 7. Designing with Entities: Handling Complex Relationships

### Problem: One Order Can Have Multiple Items
You cannot store items directly in the order table because:
- Each order has an Order ID (primary key) — cannot repeat
- Dynamic columns (27 items = 28 columns for one row, 4 items = 4 columns for another) is impossible

### Solution: Separate Tables

#### Menu Items Table
| Column | Description |
|--------|-------------|
| Item ID | Unique for each item |
| Restaurant ID | Foreign key from restaurant |
| Name | Item name |
| Image URL | Optional image |
| Price | Item price |

**Primary Key:** (Restaurant ID, Item ID) or just Item ID

#### Order Items Table (Junction Table)
| Column | Description |
|--------|-------------|
| Order ID | Foreign key from orders |
| Item ID | Foreign key from menu items |
| Quantity | How many of this item |

**Primary Key:** (Order ID, Item ID) — combination must be unique

---

## 7. Designing with Entities: Handling Complex Relationships

### Problem: One Order Can Have Multiple Items
You cannot store items directly in the order table because:
- Each order has an Order ID (primary key) — cannot repeat
- Dynamic columns (27 items = 28 columns for one row, 4 items = 4 columns for another) is impossible

### Solution: Separate Tables

#### Menu Items Table
| Column | Description |
|--------|-------------|
| Item ID | Unique for each item |
| Restaurant ID | Foreign key from restaurant |
| Name | Item name |
| Image URL | Optional image |
| Price | Item price |

**Primary Key:** (Restaurant ID, Item ID) or just Item ID

#### Order Items Table (Junction Table)
| Column | Description |
|--------|-------------|
| Order ID | Foreign key from orders |
| Item ID | Foreign key from menu items |
| Quantity | How many of this item |

**Primary Key:** (Order ID, Item ID) — combination must be unique

---

## 8. Attributes and Attribute Types

### What is an Attribute?
An attribute is a **property or characteristic** that describes an entity. These become the **columns** in a table.

> Every attribute should answer: **"Why does the business need this information?"**

### Restaurant Entity — Example Attributes
| Attribute | Why Store It? |
|-----------|---------------|
| Name | Identify the restaurant |
| Phone Number | Contact the restaurant |
| Address | Location for delivery |
| Cuisine | Help users filter restaurants |
| Ratings | Inform customer decisions |
| Opening/Closing Time | Prevent orders outside operating hours |

---

### 8.1 Types of Attributes by Composition

#### Simple (Atomic) Attributes
Cannot be divided further. Examples: Rating, Email, Salary, Price

#### Composite Attributes
Can be broken down into smaller sub-parts. Examples:
- **Name** → First Name + Last Name
- **Date** → Year + Month + Day
- **Address** → Street + City + State + Pin Code

> **Benefit of composite:** Filtering, searching, analytics, and delivery management become easier. Storing address as one string makes all these inefficient.

---

### 8.2 Types of Attributes by Value Count

#### Single-Valued Attribute
Only **one value** per entity at a time. Examples:
- User name (can change but only one at a time)
- License number
- Email (in most systems, one account = one email)

#### Multi-Valued Attribute
Can contain **multiple values** for a single entity. Examples:
- A restaurant can serve multiple cuisines → {"North Indian", "South Indian", "Chinese"}

> **Important:** Never store multi-valued data as comma-separated strings! It makes filtering and searching extremely inefficient at scale. Instead, create a **separate mapping table**. Example: `restaurant_cuisines` table with columns rest_id and cuisine_name.

---

### 8.3 Derived Attributes

A derived attribute is **computed** from other stored attributes — it should not be directly stored.

**Classic Example: Age vs Date of Birth**
- Store **Date of Birth** (doesn't change)
- **Age** is derived: `current_date - date_of_birth` = years old
- Storing age would require updating **every user's record daily** — impractical

**Debatable Example: Average Ratings**

| Pros of Storing Average Rating | Cons of Storing Average Rating |
|-------------------------------|-------------------------------|
| Faster fetching of restaurant lists | Must be recomputed every time a customer rates |
| Easier filtering/sorting by rating | Synchronization issues (concurrent ratings) |
| Analytics becomes faster | Race conditions possible |

> This highlights the trade-off between **normalization**, **performance**, and **business requirements**. Different companies (Zomato vs Swiggy) may make different choices.

---

## 9. Keys

### Why Keys Matter
Without keys:
- Duplicate records are **impossible to detect**
- Updates become **dangerous**
- Relationships become **unreliable**

Keys allow the database to **distinguish one entity from another**.

### Super Key
**Any set of attributes** that uniquely identifies an entity.

**Examples for a Customer Table:**
- Customer ID alone → Super key ✓
- Email alone → Super key ✓
- Phone number alone → Super key ✓
- Customer ID + Email → Super key ✓
- Customer ID + Email + Phone → Super key ✓

> A super key **may contain unnecessary attributes**.

### Candidate Key
A **minimal super key** — a super key from which no attribute can be removed without losing the ability to uniquely identify records. The minimum set of attributes needed to uniquely identify an entity.

**Examples for a Customer Table:**
- Customer ID (sufficient on its own) → Candidate key ✓
- Email (if unique) → Candidate key ✓
- Phone number (if unique) → Candidate key ✓

> No combination is needed since each attribute alone uniquely identifies someone.

### Primary Key
One **chosen** candidate key used to identify records in a table.

**Key points:**
- There can be **only one** primary key per table
- It is **mandatory** — every table must have one
- It tells the database how to identify each row uniquely

> Super keys and candidate keys are **theoretical concepts**. In practice, you only define the **primary key**.

### Foreign Key
When the primary key of one table is used in another table to represent a relationship:
- The key in the original table = Primary Key
- The same key in the other table = Foreign Key

> Foreign keys are essential for **JOIN operations** between tables.

---

## 10. Final Entity List (Food Delivery Platform)

| Entity | Type | Reasoning |
|--------|------|-----------|
| Customer | Strong | Exists independently |
| Restaurant | Strong | Exists independently |
| Menu Item | Strong | Defined by restaurant but stored independently |
| Order | Strong | Exists independently as a business object |
| Payment | Strong | Independent transaction entity |
| Delivery Partner | Strong | Exists independently |
| Coupon | Weak/Strong | Depends on context |
| Review | Weak | Depends on customer + restaurant/order |
| Address | Separate Table | User can have multiple addresses; not stored as comma-separated string |
| Order Items | Weak (Junction) | Links orders with menu items — cannot exist without both |

---

## 10.5 Steps in Schema Design

The schema design process follows a clear sequence:

| Step | Action | Description |
|------|--------|-------------|
| 1 | **Define Business Objects** | Identify entities relevant to the business (customers, orders, restaurants, etc.) |
| 2 | **Assign Attributes** | Determine the necessary information or columns required for each entity |
| 3 | **Establish Relationships** | Define how entities interact with one another through primary and foreign keys |
| 4 | **Normalize the Data** | Remove duplicates, organize data efficiently, and impose appropriate database constraints |

---

## 10.6 Common Issues in Poor Schema Design

### Redundancy (Data Duplication)
- The same information stored in multiple places
- Wastes space; causes inconsistencies when only some copies get updated

### Update Inconsistency
- Happens when repeated data leads to failed or partial updates
- If one copy of duplicated data is updated and another is not, the database becomes inconsistent

### Scalability Problems
- As data volume grows, a poorly organized schema becomes difficult to manage
- Searching, filtering, and analytics degrade in performance with redundant or un-segregated data

### Maintenance Challenges
- Poor design creates cascading updates — change one attribute and you must hunt down every copy of it across the database
- Adds time, cost, and risk of errors to every modification

> These three issues are directly addressed by proper separation of responsibility (Sec 4), normalization, and using separate tables for multi-valued data.

---

## 11. Key Takeaways

1. **Start with the business** — identify business objects before touching SQL
2. **Separate data by ownership** — who is responsible for this information?
3. **Avoid redundancy** — store data once, reference it through relationships
4. **Use separate tables for multi-valued data** — never comma-separated strings
5. **Think about scale** — design that survives for years, not months
6. **Every attribute must have a business justification** — answer "why?"
7. **Prefer derived attributes over manual updates** — store origin data, compute what you need
8. **Primary key is mandatory** — every table needs it
9. **Strong vs Weak** — understand if an entity can exist independently
10. **Design trade-offs are real** — normalization vs performance depends on business needs

---

## Glossary

| Term | Definition |
|------|------------|
| Entity | A distinguishable real-world object the business cares about |
| Entity Set | Collection of similar entities (becomes a table) |
| Strong Entity | Can exist independently |
| Weak Entity | Depends on parent entities; cannot exist alone |
| Attribute | A property/column describing an entity |
| Simple Attribute | Atomic, cannot be divided |
| Composite Attribute | Can be broken into sub-parts |
| Single-Valued | One value per entity |
| Multi-Valued | Multiple values possible per entity |
| Derived Attribute | Computed from other attributes |
| Super Key | Any set of attributes that uniquely identifies an entity |
| Candidate Key | Minimal super key |
| Primary Key | Chosen candidate key for a table |
| Foreign Key | Primary key of one table used in another to establish relationship |
| Normalization | Process to organize a database to reduce redundancy and improve data integrity |
