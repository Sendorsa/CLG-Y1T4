# Indexing Fundamentals — Structured Notes

## 1. Netflix Schema Design (Session Overview)
- Goal: Complete the schema design for Netflix.
- Previous session covered workflows that informed the schema structure.

---

## 2. Workflow #1 — Account Access

### 2.1 Core Activities
| Activity          | Description                                    |
|--------------------|------------------------------------------------|
| Account Creation   | User registers a new account                   |
| Credential Storage | Store credentials securely                     |
| Profile Management | Users create and manage profiles               |
| Authentication     | Verify user identity on login                  |

### 2.2 Shared Viewing Behavior
- **Multiple profiles** under one account.
- Each profile tracks:
  - Recommendation data (separate per profile)
  - Watch history (separate per profile)
  - Personalization settings (separate per profile)

---

## 3. Subscription Lifecycle

### 3.1 States & Transitions
| Action     | Description                                |
|------------|---------------------------------------------|
| Purchase   | User buys a subscription plan               |
| Renew      | User renews an active subscription          |
| Upgrade    | Move to a higher-tier plan                  |
| Downgrade  | Move to a lower-tier plan                   |
| Cancel     | User terminates the subscription            |
| Expire     | Subscription ends automatically (no renewal)|

---

## 4. Payment Lifecycle

### 4.1 Transaction Flow
```
Payment Attempt → Success / Failure
```

### 4.2 Key Requirements
- **Audit tracking**: All payments tracked historically.
- **Refunds**: Support for refund processing on failed or disputed payments.
- **Plan updates**: Payments must update the subscription plan accordingly.

---

## 5. Content Consumption

### 5.1 User Actions
| Action              | Description                                        |
|----------------------|----------------------------------------------------|
| Select Content       | User browses and picks content to watch            |
| Start Streaming      | Playback begins                                    |
| Track Progress       | Capture playback position for resumability         |
| Capture Duration     | Record total content duration                      |
| Capture Languages    | Track available audio/subtitle languages           |
| Track Watch Duration | Log how much the user actually watched             |
| Switch Stream Quality| Allow users to change resolution/quality mid-watch |

### 5.2 Data Model Considerations
- **Device used** must be captured per playback session.
- Progressive viewing requires snapshot-based or event-based tracking.

---

## 6. Episodic Viewing

### 6.1 Content Hierarchy
```
Title
 └─ if Series → Seasons
      └─ Episodes
```

### 6.2 Title Types
| Type    | Structure                                  |
|---------|---------------------------------------------|
| Movie   | Flat — single Title record                  |
| Series  | Hierarchical — Series → Seasons → Episodes  |

### 6.3 Design Decision
- **No separate `Series` table** is required.
- Add a **`content_type`** attribute on the `Title` entity to distinguish:
  - `content_type = 'Movie'` → standalone title
  - `content_type = 'Series'` → has associated Seasons & Episodes

### 6.4 Relational Mapping
| Table    | Relationship             |
|----------|---------------------------|
| Title    | One-to-Many with Season |
| Season   | One-to-Many with Episode|

---

## 7. Key Takeaways

1. **Profiles drive personalization** — separate recommendation, history, and settings per profile.
2. **Subscription ↔ Payment coupling** — payments update plans; all transactions are audit-tracked.
3. **Content consumption is event-rich** — progress, quality, duration, languages, and device are all tracked.
4. **Polymorphic content via `content_type`** — avoids table-per-type; a single `Title` works for both Movies and Series.
