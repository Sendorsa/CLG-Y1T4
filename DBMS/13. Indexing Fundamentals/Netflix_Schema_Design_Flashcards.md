# Netflix Schema Design — Flashcard Terms

## Database Fundamentals

| Term | Definition |
|------|------------|
| **Primary Key** | A unique identifier for each record in a database table |
| **Foreign Key** | A field in a table that links to the primary key in another table, establishing a relationship |
| **Composite Key** | A primary key that consists of two or more attributes |

## Normalization

| Term | Definition |
|------|------------|
| **Normalization** | Database design technique that reduces data redundancy and dependency |
| **1NF** | First Normal Form — ensures that the values in a table are atomic |
| **2NF** | Second Normal Form — a table is in 2NF if it is in 1NF and all non-prime attributes are fully functionally dependent on primary key |
| **3NF** | Third Normal Form — a table is in 3NF if it is in 2NF and all its attributes are functionally dependent only on the primary key |
| **BCNF** | Boyce-Codd Normal Form — a stringent version of 3NF with no type of redundancy |

## Content & User Tracking

| Term | Definition |
|------|------------|
| **Watch Session** | Captures user behavior data like start time, end time, and completion percentage for video content |
| **Device Usage** | Tracks the type of device used to access content, such as mobile or laptop |
| **Feedback Mechanism** | System for users to provide feedback on content watched |

## Subscription Model

| Term | Definition |
|------|------------|
| **Subscription Plan** | Defines the attributes and constraints related to content access and usage rights |
