# Netflix Schema Design — Revision Notes

## 1. Account Management

### 1.1 Account Entity
| Attribute | Description |
|-----------|-------------|
| `account_id` | Primary key — unique identifier |
| `account_name` | User's account name |
| `email` | Email address |
| `phone_number` | Contact phone |
| `hashed_password` | Securely stored password |
| `country_region` | Geographic region |
| `created_at` | Account creation timestamp |

### 1.2 Profile Entity
| Attribute | Description |
|-----------|-------------|
| `profile_id` | Primary key — unique identifier |
| `user_id` | Foreign key → Account |
| `profile_name` | Display name for the profile |
| `age_group` | Age category |
| `preferred_language` | Language preference |

---

## 2. Subscription Management

### 2.1 Subscription Plans
| Attribute | Description |
|-----------|-------------|
| `plan_id` | Primary key |
| `plan_name` | Plan display name (e.g., Basic, Standard, Premium) |
| `duration` | Plan length |
| `price` | Cost per billing cycle |
| `num_devices` | Max simultaneous streams/devices |
| `viewing_quality` | Resolution tier (SD/HD/FHD/4K) |
| `max_streams` | Concurrent stream limit |
| `regional_availability` | Regions where plan is offered |

### 2.2 User Subscriptions
| Attribute | Description |
|-----------|-------------|
| `subscription_id` | Primary key |
| `account_id` | Foreign key → Account |
| `plan_id` | Foreign key → Subscription Plans |
| `start_date` | Subscription start |
| `end_date` | Subscription expiry |
| `status` | Enum: `active` / `inactive` |

---

## 3. Content Hierarchy and Management

### 3.1 Title Entity (Movies + Series)
| Attribute | Description |
|-----------|-------------|
| `title_id` | Primary key — unique identifier |
| `title_name` | Name of the content |
| `type` | Enum: `movie` / `series` |
| `regional_availability` | Regions where title is available |

### 3.2 Series, Seasons, Episodes

**Series Table:**
| Attribute | Description |
|-----------|-------------|
| `series_id` | Primary key |
| `title_id` | Foreign key → Title |
| `status` | Series status (e.g., ongoing, completed) |

**Episodes Table:**
| Attribute | Description |
|-----------|-------------|
| `episode_id` | Primary key |
| `season_id` | Foreign key → Season |
| `title` | Episode title |
| `duration` | Episode runtime |
| `release_date` | When the episode was released |

---

## 4. Content Consumption and Analytics

### 4.1 Watch History (Session-Specific Data)
| Attribute | Description |
|-----------|-------------|
| Start time | Playback start timestamp |
| End time | Playback end timestamp |
| Watched duration | Total time watched |
| Completion % | Percentage of content consumed |
| Selected languages | Audio/subtitle language chosen |

### 4.2 Search History
| Attribute | Description |
|-----------|-------------|
| `search_term` | What the user searched for |
| `timestamp` | When the search was performed |

---

## 5. Devices and Viewing

### 5.1 Device Table
| Attribute | Description |
|-----------|-------------|
| `device_id` | Primary key |
| `account_id` | Foreign key → Account (where user is logged in) |
| `device_type` | Type (e.g., Mobile, TV, Tablet, Desktop) |

---

## 6. Content Recommendations and Feedback

### 6.1 Recommendation Algorithms
Driven by:
- **User preferences** — explicit input from users
- **Viewing history** — past watch behavior
- **Search history** — past search queries

### 6.2 Feedback and Ratings
- Captured **per-title** to enhance recommendations and analytics.

---

## 7. Key Design Decisions

| Principle | Detail |
|-----------|--------|
| **Normalization** | Tables designed to meet 1NF, 2NF, 3NF, BCNF — avoids redundancy, maintains integrity |
| **Atomicity** | Multi-valued attributes separated into separate tables |
| **Enum Usage** | Fields like `action_type`, `status` use enums for consistency and easier maintenance |

---

## 8. Design Choices Discussed
- **Single table vs. multiple tables** — extensively debated per functionality.
- Decision criteria:
  - System design requirements
  - Query optimization needs
  - Scalability considerations