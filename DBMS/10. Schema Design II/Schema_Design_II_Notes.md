# Schema Design II — Notes

## Agenda
Building on Schema Design I: **relationships**, **ER diagrams**, **functional dependency**, **attribute closure**, and **normalization** (1NF, 2NF) — all illustrated through a food-delivery platform example. Next session covers 3NF/BCNF with a hospital management system case study.

---

## 0. What is a Schema?

> **Schema**: The blueprint of a database that dictates how data is organized, how relationships between data are handled, and how integration across various functionalities is achieved.

A well-designed schema ensures:
- **Data consistency** — no contradictions in stored data
- **Reduced redundancy** — avoid duplicating the same fact across rows
- **Better query performance** — structured for efficient access patterns

---

## 1. Schema Design Process (Recap from Session I)

1. **List all activities/actions** on the platform → what happens
2. **Determine data needs per activity** → what info to store
3. **Identify business objects** → important real-world concepts (Customer, Order, Restaurant, MenuItem, etc.)
4. **Segregate attributes by ownership & responsibility** → group attributes based on which business object owns them

---

## 2. Keys (Recap from Session I)

| Key Type | Description |
|----------|-------------|
| **Super key** | Set of one or more attributes that uniquely identifies a record |
| **Candidate key** | A *minimal* super key — no redundant attributes |
| **Primary key** | The candidate key chosen as the main identifier |
| **Foreign key** | An attribute in one table that refers to the primary key of another table |

---

## 3. Relationships Between Entities

Entities do **not** act independently — they are connected through relationships.

> **Relationship**: Association between two or more entities; describes how business objects are connected.

### Types of Relationships (Cardinality)

| Type | Description | Food-Delivery Example |
|------|-------------|-----------------------|
| **1:1** | One entity instance ↔ exactly one instance of another | Order ↔ Payment |
| **1:N** | One entity instance ↔ multiple instances of another | Customer → Orders, Restaurant → MenuItems |
| **M:N** | Multiple instances ↔ multiple instances | Orders ↔ MenuItems |

### Storing Relationships in Databases

- **1:1**: Add foreign key from one table to the other (e.g., `payment_id` in orders table)
- **1:N**: Add foreign key in the *many* side referencing the *one* side's primary key (e.g., `customer_id` in orders table, `restaurant_id` in menu_items table)
- **M:N**: Create a **junction table** (also called bridge/link table) containing foreign keys from both sides; the combination forms the primary key (e.g., `order_items` with `order_id` + `menu_item_id`)

### Participation Constraints

Defines **whether participation is mandatory or optional**.

| Type | Description | Example |
|------|-------------|---------|
| **Total participation** | Every entity *must* participate in the relationship | Order ↔ Payment (every order must have a payment; every payment belongs to an order) |
| **Partial (voluntary) participation** | Entity *may or may not* participate | DeliveryPartner → Orders (a delivery partner might never have delivered an order) |

---

## 4. ER Diagrams (Entity-Relationship Diagrams)

A visual representation of the database schema — entities, attributes, and relationships shown diagrammatically.

| Element | Symbol |
|---------|--------|
| **Entity** | Rectangle |
| **Attribute** | Oval(s) connected to entity; alternatively listed inside rectangle for cleaner look |
| **Primary key attribute** | Underlined within attribute list |
| **Relationship** | Diamond / connector **line** between entities (shows how entities relate to one another) |

### Cardinality Notation in ER Diagrams
- `1 — 1` : Both sides have single-line markers (one-to-one)
- `1 — N` : One side has a dash, other has crow's foot (one-to-many)

**Example**: `Customer --(places)--> Order` with cardinality 1:N, where customer participation is total and order participates fully.

---

## 5. Why Normalization? — Problems with Bad Schema Design

### Example of a bad table: one giant `order_details` table
Columns: `order_id, order_date, customer_id, customer_name, customer_phone, customer_city, restaurant_id, restaurant_name, restaurant_phone, restaurant_city, delivery_partner_id, delivery_name, delivery_phone, menu_item_id, item_name, price, quantity, payment_id, payment_method, payment_status, coupon_code, coupon_discount`

### Issues this causes:

| Issue | Description |
|-------|-------------|
| **Data redundancy** | Customer name/phone repeated across 50+ orders; restaurant details repeated 10 lakh times |
| **Update anomaly** | Changing a restaurant's phone number requires updating all its order rows |
| **Insertion anomaly** | Can't insert a new customer without also inserting an order |
| **Deletion anomaly** | Deleting all orders from a restaurant accidentally removes the restaurant itself from the system |

---

## 6. Normalization

> **Normalization**: The process of organizing data to reduce redundancy and eliminate anomalies. It breaks large tables into smaller, well-structured tables using functional dependencies. It does *not* change *what* is stored — only *how* it's arranged.

**Trade-off**: Complete normalization = more joins = slower queries. The degree of normalization applied is a **business decision**.

---

## 7. Functional Dependency (FD)

> **Functional dependency X → Y** exists if the value of X uniquely determines the value of Y.
- **X** = determinant (determines the value)
- **Y** = dependent attribute (is determined by X)

**Core Value**: Functional dependencies reveal how information naturally groups together.

### Examples from food-delivery platform
| FD | Meaning |
|----|---------|
| `customer_id → customer_name, phone, city` | Customer ID determines all customer details |
| `restaurant_id → restaurant_name, phone, city` | Restaurant ID determines all restaurant details |
| `menu_item_id → item_name, price` | (Note: `item_name → price` does NOT hold — same dish name at different restaurants has different prices) |
| `delivery_partner_id → partner_name, phone` | DP ID determines all DP details |
| `payment_id → payment_method, payment_status` | Payment ID determines all payment details |
| `coupon_code → coupon_discount_percentage` | Coupon code determines its discount |
| `order_id → order_date, customer_id, restaurant_id` | Order ID determines order metadata |

### Types of Functional Dependencies

| Type | Description | Example |
|------|-------------|---------|
| **Trivial** | Dependent attribute is already part of the determinant | `customer_id, customer_name → customer_name` (not useful) |
| **Non-trivial** | Dependent attribute is NOT part of the determinant | `customer_id → customer_phone` (useful) |
| **Composite** | Multiple attributes together form the determinant | `order_id, menu_item_id → quantity` (neither alone suffices for quantity) |

---

## 8. Attribute Closure

> The **closure of X** (denoted **X⁺**) = the set of all attributes that can be functionally determined from X using the given functional dependencies.

### Finding candidate keys using closure
1. Write down all FDs.
2. For a guessed key, compute its closure.
3. If closure includes *all* attributes in the table → it's a super key.
4. Check minimality: remove each attribute one at a time; if closure still covers everything, it's not minimal → not a candidate key.

### Example
Given FDs:
- `order_id, menu_item_id → quantity`
- `restaurant_id → restaurant_name`
- `menu_item_id → menu_item_name, price`
- `customer_id → customer_name`

Closure of `{order_id, menu_item_id}` includes all attributes → **super key**. Checking minimality (remove either attribute → closure is incomplete) → both are **candidate keys**.

#### Attribute closure computation (step-by-step)
1. Start: closure = **X** (initial set)
2. Find FDs where determinant ⊆ closure, add dependent attributes to closure
3. Repeat until no new attributes can be added

### Simple chain example
If `A → B`, `B → C`, and `C → D`, then `A⁺ = {A, B, C, D}`.

### Important notes:
- Don't assume primary keys — *verify* them using FDs and closure.
- When computing closure, include **transitive dependencies** (A→B, B→C means A→C transitively).
- Compute closure completely until no new attributes can be added.

---

## 9. Normal Forms

Normalization is applied in **stages**: 1NF → 2NF → 3NF → BCNF. Each stage must satisfy all prior stages.

### First Normal Form (1NF)

A relation is in 1NF if:
- Every attribute contains **atomic (indivisible) values** only.
- **No repeating groups** (no multi-valued stored as a single string/array).

#### Non-compliant with 1NF (examples):
| Bad Design | Why? |
|-----------|------|
| `cuisines = "Italian, Mexican, Chinese"` (comma-separated) | Unsearchable; no optimization possible; can't maintain integrity |
| `ordered_items = "burger,pizza,fries"` (in order details) | Hard to query/update/scaling breaks; duplicates not detectable |

#### Fix for 1NF:
- Extract multi-valued/categorical data into its own table with a foreign key.
  - e.g., separate `restaurant_cuisines(restaurant_id, cuisine_name)`
  - Already handled via `order_items(order_id, menu_item_id, quantity)`

### Second Normal Form (2NF)

A relation is in 2NF if:
1. It is already in **1NF**, AND
2. **No non-prime attribute** depends on only **part of a composite candidate key** (no partial dependencies).

#### Example — violation of 2NF

Suppose we have FDs for an `order_details` table with candidate key `(order_id, menu_item_id)`:
- `order_id → order_date, customer_id, restaurant_id` (depends on only part of the key)
- `menu_item_id → item_name, price` (depends on only part of the key)
- `order_id, menu_item_id → quantity` (depends on full key ✓)

**Fix**: Decompose into:
- `orders(order_id, order_date, customer_id, restaurant_id)`
- `menu_items(item_id, item_name, price)`
- `order_items(order_id, menu_item_id, quantity)` — only this has the partial dep. (full key for quantity)

---

### Preview: 3NF and BCNF (Next Session)

> These are formal stages covered in the next class with a hospital management case study — definitions below for reference.

#### Key terminology you need to understand 3NF/BCNF

| Term | Definition | Example |
|------|------------|---------|
| **Prime attribute** | An attribute that is part of *any* candidate key | In `(order_id, menu_item_id)` as the key → both `order_id` and `menu_item_id` are prime |
| **Non-prime attribute** | Any attribute that is NOT part of any candidate key | `order_date`, `customer_name`, etc. in the orders table |
| **Transitive dependency** | When A determines B, and B determines C → A transitively determines C (written: A → B → C) | `restaurant_id → restaurant_city → city_timezone` — you don't need `city_timezone` in the restaurants table; it's determined through `restaurant_city` |

#### Third Normal Form (3NF)

> **Rule**: No *transitive dependency* among non-prime attributes. Every non-prime attribute must depend directly on the key, not on another non-prime attribute.

| Normal Form | Rule | What it eliminates |
|-------------|------|---------------------|
| **Third Normal Form (3NF)** | Every non-prime attribute depends *directly* on the primary key — no transitive dependencies through other non-prime attributes. | Transitive dependencies |
| **Boyce-Codd Normal Form (BCNF)** | A stronger version of 3NF — *every determinant must be a candidate key*. Addresses edge cases where 3NF still allows anomalies (e.g., when there are overlapping candidate keys or multiple composite keys). | Remaining anomaly edge cases |

#### Example — violation of 3NF

Suppose `restaurants` table has columns: `restaurant_id, restaurant_name, city, city_timezone`
FDs: `restaurant_id → restaurant_name, city` and `city → city_timezone`

Here, `restaurant_id → city → city_timezone` is a transitive dependency — `city_timezone` depends on a non-prime attribute (`city`), not directly on the key.

**Fix**: Split into:
- `restaurants(restaurant_id, restaurant_name, city)`
- `cities(city, city_timezone)`

#### Example — BCNF (conceptual)

BCNF becomes relevant when you have *multiple candidate keys* and overlapping determinants. E.g., if `(A, B)` and `(B, C)` are both candidate keys, and you have FD `A → D` where `A` is not itself a candidate key on its own — 3NF may still allow this anomaly; BCNF eliminates it by requiring *every* determinant to be a full candidate key.

**Key idea**: Over-normalization reduces redundancy but requires complex joins → degrades performance. The degree of normalization is always a **trade-off between data integrity and query performance**.

---

## Key Takeaways

1. Schema design starts with **activities → data needs → business objects → attributes by ownership**.
2. All entities are connected through **relationships** — modeled as 1:1, 1:N, or M:N cardinality with participation constraints.
3. **Junction tables** resolve M:N relationships using composite foreign keys.
4. **ER diagrams** visually represent the schema (rectangles=entities, ovals/inside=attributes, lines=diamonds=relationships).
5. **Functional dependencies** show which attributes determine others — they are core to understanding schema issues and applying normalization.
6. **Attribute closure (X⁺)** mathematically validates candidate keys by determining all attributable attributes from a set.
7. **Normalization** removes redundancy & anomalies; applied in stages (1NF → 2NF → ...). Each normal form has formal rules — not intuition-based.
8. There is **no universally "best" design** — normalization level is a trade-off between data integrity and query performance.
