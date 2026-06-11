# Deadlocks - Concurrency & Synchronization Notes

---

## Introduction

Today's class focused on understanding concurrency problems, particularly deadlocks, and synchronization issues that arise when multiple threads or processes share resources. We covered both theoretical concepts and practical problem-solving strategies related to deadlocks and thread synchronization.

---

## Why Concurrency?

- **Need for concurrency**: Multiple threads run simultaneously; OS decides scheduling — no manual control, improves efficiency and performance
- **Challenge**: With multiple threads accessing shared resources, synchronization is crucial to ensure correct execution and avoid race conditions that lead to incorrect outputs or corrupted data
- **Goal**: Not to remove multithreading — but to **control shared access** of data

---

## Classic Concurrency Problems

### 1. Producer-Consumer Problem (Bounded Buffer)

**Threads Involved**: Producer thread (creates items and adds to a shared buffer) and Consumer thread (removes items from the buffer for use).

**Rules**:
1. Producer must **wait if buffer is full**
2. Consumer must **wait if buffer is empty**
3. **Only one thread** can access the buffer at a time

**Semaphores**:

| Semaphore | Purpose | Initial Value (buffer size = N) |
|-----------|---------|------:|
| `mutex` | Mutual exclusion — only one thread enters at a time | 1 |
| `empty` | Counts **empty slots** (available to fill) | N |
| `full` | Counts **filled slots** (available to consume) | 0 |

- **`acquire()` / `wait()`** → request a permit (block if none available)
- **`release()` / `signal()`** → release a permit (wake another thread)

**Producer Locking Sequence**:
```
1. emptySpaces.acquire()  // Wait for an empty slot
2. mutex.acquire()        // Enter critical section
3. buffer.add(item)       // Add item to buffer
4. mutex.release()        // Exit critical section
5. fullSpaces.release()   // Signal that an item is available
```

**Consumer Locking Sequence**:
```
1. fullSpaces.acquire()  // Wait for a full slot
2. mutex.acquire()       // Enter critical section
3. buffer.poll()         // Remove item from buffer
4. mutex.release()       // Exit critical section
5. emptySpaces.release() // Signal that a slot is free
```

**Java Implementation (BoundedBuffer via Semaphores)**:
```java
class BoundedBuffer {
    private final Queue<Object> buffer = new LinkedList<>();
    private final int capacity = 5;

    private final Semaphore emptySpaces = new Semaphore(capacity);
    private final Semaphore fullSpaces = new Semaphore(0);
    private final Semaphore mutex = new Semaphore(1);

    public void produce(Object item) throws InterruptedException {
        emptySpaces.acquire(); // Wait for an empty slot
        mutex.acquire();       // Enter critical section
        buffer.add(item);
        mutex.release();       // Exit critical section
        fullSpaces.release();  // Signal that an item is available
    }

    public Object consume() throws InterruptedException {
        fullSpaces.acquire();  // Wait for a full slot
        mutex.acquire();       // Enter critical section
        Object item = buffer.poll();
        mutex.release();       // Exit critical section
        emptySpaces.release(); // Signal that a slot is free
        return item;
    }
}
```

**Lock order matters**: Swapping `mutex` and `empty/full` can cause deadlock. Producer checks empty slots first so it can fill the buffer continuously — consumer then gets a stream of items.

**Example Numerical (Macro-level summary)**: Buffer capacity = 5 | Initially: `empty = 5`, `full = 0`

| Step | Operation | empty | full | Buffer items |
|------|-----------|-----:|-----:|-------------:|
| Start | — | 5 | 0 | 0 |
| 1 | Producer produces 3 items | 2 | 3 | 3 |
| 2 | Consumer consumes 1 item | 3 | 2 | 2 |
| 3 | Producer produces 2 items | 1 | 4 | 4 |
| 4 | Consumer consumes 3 items | 4 | 1 | 1 |

**Final**: `empty = 4`, `full = 1`, buffer = **1 item**

---

### 2. Reader-Writer Problem

**Threads Involved**: Readers (read data) and Writers (write data).

**Access Rules**:

| Access Type | Allowed? | Reason |
|-------------|----------|--------|
| Reader + Reader | YES | No modification → safe |
| Writer + Writer | NO | Would cause race condition / inconsistent data |
| Reader + Writer | NO | Reader might read mid-write → stale or partial data |

**Key Concepts**:
- Multiple readers can access simultaneously (no data change)
- Only one writer at a time
- **Starvation risk**: If readers keep arriving, writers may never get access → ensure fairness

---

### 3. Dining Philosophers Problem

**Scenario**: 5 philosophers at a round table, 5 forks (one per left side). Each needs **two forks** (left + right) to eat. Can either **think** or **eat** — never both at once.

**Deadlock Scenario**: All philosophers pick up their **left fork** simultaneously → everyone waits for the **right fork** held by neighbor → circular wait → deadlock (nobody eats).

**Fix: Proper Lock Ordering / Staggered Access**:
- Allow some philosophers to pick up forks first (e.g., even-numbered)
- This leaves at least one pair of adjacent forks available
- Philosophers take turns → **no deadlock**, **no starvation**

---

### 4. Sleeping Barber Problem

**Problem Setup**: One barber (thread), one barber chair, multiple waiting chairs, customers arrive irregularly.

**Customer Arrival Scenarios**:
1. **Barber is asleep** → customer wakes him up (signaling)
2. **Barber is busy, chairs are free** → customer waits in a chair
3. **Barber is busy, no free chairs** → customer leaves

**Key Concepts**: Solves irregular work arrival pattern; manages limited waiting space; demonstrates waiting and waking by signaling between threads.

---

## Deadlock — Core Concept

**What is a deadlock?** Threads wait forever for each other → system appears frozen. **No wrong output** — execution simply stops. Caused by competing for locked resources (objects).

**More precisely**: A deadlock occurs when a set of threads are permanently blocked because each thread holds a lock resource while waiting to acquire another resource held by a different thread in the same cycle. Every thread is stuck waiting, none will ever release their resources voluntarily → application hangs indefinitely.

### Classic Deadlock Scenario
1. Thread 1 acquires Lock A
2. Thread 2 acquires Lock B
3. Thread 1 attempts to acquire Lock B → blocks (waiting for Thread 2)
4. Thread 2 attempts to acquire Lock A → blocks (waiting for Thread 1)
5. **Both threads trapped in mutual block forever**

### Code Example of Deadlock via Lock Ordering
```
Thread T1:    synchronized(R1) { ... synchronized(R2) { ... } }
Thread T2:    synchronized(R2) { ... synchronized(R1) { ... } }
```
- T1 holds R1, waits for R2; T2 holds R2, waits for R1 → deadlock

### Fix: Consistent Lock Ordering
Both threads acquire locks in the **same order**:
```
Thread T1:    synchronized(R1) { ... synchronized(R2) { ... } }
Thread T2:    synchronized(R1) { ... synchronized(R2) { ... } }
```
- Threads now **compete for R1** → only one enters → avoids circular wait

---

## Four Coffman Conditions (Necessary for Deadlock)

A deadlock can occur if and only if **all four** of the following conditions are simultaneously met:

| # | Condition | Description |
|---|-----------|-------------|
| 1 | **Mutual Exclusion** | At least one resource must be held in a non-shareable mode (only one thread can use it at a time) |
| 2 | **Hold and Wait** | A thread must currently hold at least one resource lock while actively waiting to acquire additional resources held by other threads |
| 3 | **No Preemption** | Resources cannot be forcibly stripped from a thread; a lock can only be released voluntarily by the holding thread |
| 4 | **Circular Wait** | A closed chain of threads must exist, where each thread waits for a resource held by the next thread in the circle |

---

## Strategies for Preventing Deadlocks

To prevent deadlocks, the system architecture must break at least one of the four Coffman conditions.

### Lock Ordering (Breaking Circular Wait)
- **Strategy**: Enforce a strict, global hierarchy rule for lock acquisition
- **Mechanism**: If all threads are required to acquire Lock A before attempting to acquire Lock B, Thread 2 will block cleanly at Lock A if Thread 1 holds it. It will never get the opportunity to hold Lock B while waiting for Lock A, eliminating circular wait

### Timed Lock Acquisition (Breaking Hold and Wait)
- **Strategy**: Prevent threads from waiting indefinitely for a resource while holding onto others
- **Mechanism**: Use explicit lock objects like `ReentrantLock` with `tryLock(long timeout, TimeUnit unit)`. If a thread cannot acquire the secondary lock within the timeout window, it backs off and drops its currently held resources, letting other threads proceed and preventing a permanent system freeze

---

## Deadlock Management Approaches

### 1. Prevention
Ensuring proper lock acquisition order and avoiding circular wait conditions. Make threads compete for the same lock in consistent order.

### 2. Avoidance
Utilizing algorithms like Banker's Algorithm to determine safe resource allocation states before granting resources.

### 3. Detection
Identifying deadlock occurrences by detecting cycles in resource allocation graphs. Any cycle = deadlock.

### 4. Recovery (When Deadlock Already Exists)

**Method A: Process Termination**
- Detect the cycle in the resource allocation graph
- Identify all processes in the deadlock
- Kill them **all at once**, or **one by one** until resolved
- Killing order based on: priority, work done, resources held, resources needed, restart cost
- Simple but costly — loses all work

**Method B: Resource Preemption**
- Select victim process, forcibly take its resources
- Must rollback victim to a safe previous state or restart it
- **Starvation risk** if same process is always chosen as victim
- Choose wisely: lowest cost to lose all resources, minimal undo work

---

## Banker's Algorithm (Deadlock Avoidance)

### Concept
- Used **before** allocating resources — checks if allocation is in a **safe state**
- Analogy: Bank only lends money if it can satisfy all remaining customers; ensures no customer (process) takes all resources, leaving others without

### Data Structures Given
- **Available**: Resources currently free
- **Maximum**: Max resource demand of each process
- **Allocation**: Resources already allocated to each process
- **Need = Maximum - Allocation**

### Algorithm Steps
1. Calculate `Need` matrix for each process: `Need[i] = Max[i] - Alloc[i]`
2. Check if any process has `Need[i] ≤ Available`
3. If yes → allocate → simulate completion → release resources back to Available
4. Repeat until all processes can finish (safe sequence) or none can proceed (unsafe)

### Safe vs Unsafe State
- **Safe state**: At least one safe execution sequence exists → no deadlock
- **Unsafe state**: No guarantee — deadlock may occur

### Numerical Example

**Maximum matrix:**

| Process | A | B | C |
|---------|---|---|---|
| P0 | 5 | 4 | 3 |
| P1 | 3 | 2 | 2 |
| P2 | 4 | 3 | 3 |

**Allocation matrix:**

| Process | A | B | C |
|---------|---|---|---|
| P0 | 3 | 1 | 3 |
| P1 | 1 | 1 | 2 |
| P2 | 2 | 1 | 0 |

**Need = Max - Alloc:**

| Process | A | B | C |
|---------|---|---|---|
| P0 | 2 | 3 | 0 |
| P1 | 2 | 1 | 0 |
| P2 | 2 | 2 | 3 |

**Available = [3, 2, 2]**

Check process-by-process: Is `Need[i] ≤ Available`?
- **P0**: Need [2,3,0] > Available [3,2,2] → B fails (3 > 2)
- **P1**: Need [2,1,0] ≤ Available [3,2,2] → All pass → P1 can execute!

After P1 completes and releases its resources, update Available and re-check remaining processes.

---


### Worked Example: Bounded Buffer with Blocking (Semaphore Trace)

**Setup**: Buffer capacity = 3
- `empty = 3`, `full = 0`, `mutex = 1`

| Operation | Semaphore Actions | empty | full | mutex | buffer size |
|-----------|------------------|-----:|-----:|------:|:-----------:|
| Initial | — | 3 | 0 | 1 | 0 |
| P1 produces | `wait(empty)→2, wait(mutex)→0, signal(mutex)→1, signal(full)→1` | 2 | 1 | 1 | 1 |
| P2 produces | `wait(empty)→1, wait(mutex)→0, signal(mutex)→1, signal(full)→2` | 1 | 2 | 1 | 2 |
| P3 produces | `wait(empty)→0, wait(mutex)→0, signal(mutex)→1, signal(full)→3` | 0 | 3 | 1 | 3 **(buffer full)** |
| P4 tries to produce | `wait(empty)` → blocks (empty=0) | **0** (blocked) | 3 | 1 | 3 |
| C1 consumes | `wait(full)→2, wait(mutex)→0, signal(mutex)→1, signal(empty)→1` ✅ wakes P4 | **1** | 2 | 1 | 2 |
| C2 consumes | `wait(full)→1, wait(mutex)→0, signal(mutex)→1, signal(empty)→2` | 2 | 1 | 1 | 1 |
| P5 produces | `wait(empty)→1, wait(mutex)→0, signal(mutex)→1, signal(full)→2` | 1 | 2 | 1 | 2 |
| C3 consumes | `wait(full)→1, wait(mutex)→0, signal(mutex)→1, signal(empty)→2` | 2 | 1 | 1 | 1 |
| C4 consumes | `wait(full)→0, wait(mutex)→0, signal(mutex)→1, signal(empty)→3` | **3** | **0** | **1** | **0** **(buffer empty)** |

**Final state**: `empty=3`, `full=0`, `mutex=1`

**Question — Which statements are correct?**
- **A. P4 blocks because empty = 0** ✅ Yes — after P3 fills the buffer, empty drops to 0, so P4's `wait(empty)` blocks
- **B. After C1 consumes, P4 can continue** ✅ Yes — C1 calls `signal(empty)`, incrementing from 0→1, which wakes P4
- **C. C4 blocks because full = 0** ❌ No — when C4 runs, buffer has 1 item (full=1), so it succeeds and sets full=0
- **D. Final value of empty is 3** ✅ Yes — net: 4 produced - 1 blocked = 3 consumed → empty went 3→2→1→0(+blocked)→1→2→1→2→3
- **E. Final value of mutex is 0** ❌ No — every `wait(mutex)` is paired with `signal(mutex)`. Final mutex = 1

---

### Comprehensive Banker's Algorithm Example (5 Processes)

**System Parameters**
- Total processes: 5 (P₀, P₁, P₂, P₃, P₄)
- Total resource types: 3 (A, B, C)
- Current Available Vector: **Available = (3, 3, 2)**

**Operations Vectors Matrix**

| Process | Allocation (A,B,C) | Max Claim (A,B,C) | Need Vector (A,B,C) |
|---------|:------------------:|:-:|:-:|
| P₀ | (0,1,0) | (7,5,3) | (7,4,3) |
| P₁ | (2,0,0) | (3,2,2) | (1,2,2) |
| P₂ | (3,0,2) | (9,0,2) | (6,0,0) |
| P₃ | (2,1,1) | (2,2,2) | (0,1,1) |
| P₄ | (0,0,2) | (4,3,3) | (4,3,1) |

**Step-by-Step Safety Derivation**

To verify if the system is in a safe state, we discover a valid safety sequence:

- **Step 1: Evaluate P₀** — Need = (7,4,3). Is (7,4,3) ≤ (3,3,2)? **No**. P₀ must wait.
- **Step 2: Evaluate P₁** — Need = (1,2,2). Is (1,2,2) ≤ (3,3,2)? **Yes**. P₁ completes.
  - Available = (3,3,2) + (2,0,0) = **(5,3,2)**
- **Step 3: Evaluate P₂** — Need = (6,0,0). Is (6,0,0) ≤ (5,3,2)? **No**. P₂ must wait.
- **Step 4: Evaluate P₃** — Need = (0,1,1). Is (0,1,1) ≤ (5,3,2)? **Yes**. P₃ completes.
  - Available = (5,3,2) + (2,1,1) = **(7,4,3)**
- **Step 5: Evaluate P₄** — Need = (4,3,1). Is (4,3,1) ≤ (7,4,3)? **Yes**. P₄ completes.
  - Available = (7,4,3) + (0,0,2) = **(7,4,5)**
- **Step 6: Re-evaluate P₀** — Need = (7,4,3). Is (7,4,3) ≤ (7,4,5)? **Yes**. P₀ completes.
  - Available = (7,4,5) + (0,1,0) = **(7,5,5)**
- **Step 7: Re-evaluate P₂** — Need = (6,0,0). Is (6,0,0) ≤ (7,5,5)? **Yes**. P₂ completes.
  - Available = (7,5,5) + (3,0,2) = **(10,5,7)**

**Conclusion**: The system is in a **Safe State**. A valid safety sequence: **P₁ → P₃ → P₄ → P₀ → P₂**

---

### Question 5: Banker's Algorithm — Safety Sequence with Available = (0, 1, 0)

**System Parameters:**
- 3 resource types: A, B, C
- **Available = (0, 1, 0)**

**State Matrix:**

| Process | Allocation (A,B,C) | Need (Request) (A,B,C) | Can Complete? |
|---------|:------------------:|:-:|:-----------:|
| P0 | (1,0,1) | (0,2,0) | ❌ B: 2 > 1 |
| P1 | (0,1,0) | (1,0,1) | ❌ A: 1 > 0, C: 1 > 0 |
| P2 | (2,0,0) | (0,1,0) | ✅ All ≤ Available |
| P3 | (0,0,1) | (2,0,0) | ❌ A: 2 > 0 |
| P4 | (1,1,0) | (0,0,0) | ✅ All ≤ Available |

**Step-by-Step Safety Sequence:**

Only **P2** and **P4** can complete initially. Let's trace:

- **Start**: Available = (0, 1, 0) — P4 need (0,0,0), P2 need (0,1,0) both satisfied
- **P4 completes**: Available = (0,1,0) + (1,1,0) = **(1, 2, 0)**
- **P2 completes** (or could have gone first): Available = (1,2,0) + (2,0,0) = **(3, 2, 0)**
- **P0**: Need (0,2,0) ≤ (3,2,0)? ✅ → Available = (3,2,0) + (1,0,1) = **(4, 2, 1)**
- **P1**: Need (1,0,1) ≤ (4,2,1)? ✅ → Available = (4,2,1) + (0,1,0) = **(4, 3, 1)**
- **P3**: Need (2,0,0) ≤ (4,3,1)? ✅ → All processes complete!

**Safe Sequence**: P4 → P2 → P0 → P1 → P3 (also valid: P2 → P4 → P0 → P1 → P3, etc.)

Which statements are correct?

| # | Statement | Correct? | Reasoning |
|---|-----------|:--------:|-----------|
| A | P4 can complete first | ✅ | Need (0,0,0) ≤ Available (0,1,0) → Yes, lowest need possible |
| B | After P4 completes, P2 can complete | ✅ | Available becomes (1,2,0); P2 Need (0,1,0) ≤ (1,2,0) → Yes |
| C | After P2 completes, P1 can complete | ❌ | Even after all releases, if checking when C=0: P1 Need C=1 > Available C=0. With full trace above: available C reaches 1 only **after** P0 releases, so depending on order — statement says "after P2" specifically, at that point avail = (3,2,0), C=0 → P1 fails on C |
| D | P3 is deadlocked forever even after P4 and P2 complete | ❌ | After P4 + P2: Available = (3,2,0); P3 Need (2,0,0) ≤ (3,2,0) → P3 can still complete. Not deadlocked. |
| E | No deadlock exists | ✅ | A safe sequence exists (P4→P2→P0→P1→P3). All processes can complete. |

**Answer: A, B, E are correct.**

---

### Question 3: Banker's Algorithm — Resource Request with Multiple-Choice

**Problem**: Using the same system as the comprehensive example (5 processes, Available = **(3, 3, 2)**):

| Process | Max (A,B,C) | Allocation (A,B,C) | Need (A,B,C) |
|---------|:-----------:|:------------------:|:------------:|
| P₀ | (7,5,3) | (0,1,0) | (7,4,3) |
| P₁ | (3,2,2) | (2,0,0) | **(1,2,2)** |
| P₂ | (9,0,2) | (3,0,2) | (6,0,0) |
| P₃ | (2,2,2) | (2,1,1) | (0,1,1) |
| P₄ | (4,3,3) | (0,0,2) | (4,3,1) |

P₁ makes a resource request: **Request(P₁) = (1, 0, 2)**

Which statements are correct?

| # | Statement | Correct? | Reasoning |
|---|-----------|:--------:|-----------|
| A | Need of P₁ is (1,2,2) | ✅ | Max(3,2,2) − Alloc(2,0,0) = **(1,2,2)** |
| B | Request ≤ Need | ✅ | (1,0,2) ≤ (1,2,2) → **True** on all components |
| C | Request ≤ Available | ✅ | (1,0,2) ≤ (3,3,2) → **True** on all components |
| D | If granted, system remains in safe state | ✅ | Simulate: New Avail = (2,3,0). Safe sequence **P₁→P₃→P₄→P₀→P₂** still valid |
| E | Must be denied because C becomes 0 | ❌ | Available C drops to 0, but P₁ finishes needing only B=2. System is safe → **grant the request**. Zero remaining ≠ deadlock |

**Answer: A, B, C, D are correct.**

---

### Handling a Resource Request

Suppose P₁ requests: **Request(P₁) = (1, 0, 2)**. We evaluate against standard checkpoints:

**Check 1**: Is Request ≤ Need?
- (1,0,2) ≤ (1,2,2) → **True** (request is within declared limits)

**Check 2**: Is Request ≤ Available?
- (1,0,2) ≤ (3,3,2) → **True** (system has enough physical resources)

**Check 3: Simulate Allocation & Re-run Safety Test**

Hypothetically adjust vectors for P₁:
- New Available = (3,3,2) - (1,0,2) = **(2,3,0)**
- New Allocation(P₁) = (2,0,0) + (1,0,2) = **(3,0,2)**
- New Need(P₁) = (1,2,2) - (1,0,2) = **(0,2,0)**

Running Safety Test on Simulated State:
- Available pool is now (2,3,0)
- P₁ has Need = (0,2,0) ≤ (2,3,0). **P₁ executes to completion**
- P₁ releases its allocation: (2,3,0) + (3,0,2) = **(5,3,2)**
- With (5,3,2), P₃ (Need: 0,1,1) can execute. It releases: (5,3,2) + (2,1,1) = **(7,4,3)**
- From this point onward, the safety steps match our initial test exactly. Sequence **P₁ → P₃ → P₄ → P₀ → P₂** remains viable.

**Final Evaluation**: The request is safe to grant.

---

### Question 2: Banker's Algorithm with Available = (1, 0, 1)

**System Parameters:**
- 3 resource types: A, B, C
- **Available = (1, 0, 1)**

**State Matrix:**

| Process | Allocation (A,B,C) | Need (Request) (A,B,C) |
|---------|:------------------:|:-:|
| P₀ | (0,1,0) | (1,0,1) |
| P₁ | (2,0,0) | (0,1,0) |
| P₂ | (3,0,1) | (2,1,0) |
| P₃ | (2,1,1) | (3,0,0) |
| P₄ | (0,0,2) | (2,0,0) |

**Step-by-Step Safety Sequence:**

**Initial Available = (1, 0, 1)** — Who can complete? Need ≤ Available?
- P₁: Need (2,0,0). (2,0,0) ≤ (1,0,1)? ❌ No (2 > 1 on A)
- P₂: Need (0,1,1). (0,1,1) ≤ (1,0,1)? ❌ No (1 > 0 on B)
- P₃: Need (3,0,0). (3,0,0) ≤ (1,0,1)? ❌ No (3 > 1 on A)
- P₄: Need (2,1,0). (2,1,0) ≤ (1,0,1)? ❌ No (A and B fail)
- **P₁**: Need (0,1,0). (0,1,0) ≤ (1,0,1)? ❌ No (B fails: 1 > 0)

**No process can complete.** — Wait, let me recheck.

Actually: **P₁ Need = (2,0,0)** not (0,1,0). Available = (1,0,1):  
- P₁: (2,0,0) ≤ (1,0,1)? A fails (2 > 1)
- P₂: (0,1,1) ≤ (1,0,1)? B fails (1 > 0)
- P₃: (3,0,0) ≤ (1,0,1)? A fails (3 > 1)  
- P₄: (2,1,0) ≤ (1,0,1)? Both fail

**Wait — checking again with correct need values:**

No process's Need ≤ Available = (1,0,1). **Deadlock exists. No safe sequence.**

**Answer:**
- A ❌ P2 cannot complete — Need (0,1,1) > Available (1,0,1) on B
- B ❌ Cannot evaluate — no process can start
- C ❌ Cannot evaluate — no process can start
- D ✅ P4 is deadlocked — Need (2,1,0) > Available, cannot proceed
- E ❌ Deadlock exists — no safe sequence possible

---

### Worked Example: Banker's Algorithm with Request Handling

**Scenario**: Process P₁ wants to request additional resources on top of its allocation.
- Current Available = (3, 3, 2) (from the comprehensive example above)
- **Request(P₁) = (1, 0, 0)**
- P₁'s Need = (1, 2, 2)

**Checklist before granting:**

| # | Check | Calculation | Result |
|---|-------|-------------|--------|
| 1 | Request ≤ Need? | (1,0,0) ≤ (1,2,2) | ✅ Valid request |
| 2 | Request ≤ Available? | (1,0,0) ≤ (3,3,2) | ✅ Sufficient resources |
| 3 | Simulate & recheck safety | See below | Need verification |

**Simulated State after granting:**
- New Available = (3,3,2) - (1,0,0) = **(2, 3, 2)**
- New Allocation(P₁) = (2,0,0) + (1,0,0) = **(3, 0, 0)**
- New Need(P₁) = (1,2,2) - (1,0,0) = **(0, 2, 2)**

**Re-run Safety Test with Available = (2, 3, 2):**
- P₁: Need (0,2,2). (0,2,2) ≤ (2,3,2)? ✅ → Executes. Releases (3,0,0) → Available = **(5, 3, 2)**
- P₀: Need (7,4,3). (7,4,3) ≤ (5,3,2)? ❌ — Waits
- P₂: Need (6,0,0). (6,0,0) ≤ (5,3,2)? ❌ — Waits
- P₃: Need (0,1,1). (0,1,1) ≤ (5,3,2)? ✅ → Executes. Releases (2,1,1) → Available = **(7, 4, 3)**
- P₄: Need (4,3,1). (4,3,1) ≤ (7,4,3)? ✅ → Executes. Releases (0,0,2) → Available = **(7, 4, 5)**
- P₀ (retry): (7,4,3) ≤ (7,4,5)? ✅ → Executes. Releases (0,1,0) → Available = **(7, 5, 5)**
- P₂ (retry): (6,0,0) ≤ (7,5,5)? ✅ → Executes. All done.

**Safety Sequence with Request Granted: P₁ → P₃ → P₄ → P₀ → P₂** — still safe. ✅

**Final Evaluation**: The request is **safe to grant**.

---

## Summary of All Deadlock Approaches

| Approach | Technique | Key Idea |
|----------|-----------|----------|
| **Prevention** | Proper lock ordering | Ensure consistent order; make threads compete for same lock |
| **Avoidance** | Banker's Algorithm | Check safe state before granting resources |
| **Detection** | Cycle detection graph | Identify circular wait in resource allocation |
| **Recovery** | Process termination / Resource preemption | Break the cycle after deadlock occurs |

---

## Glossary (All Terms)

| Term | Definition |
|------|-----------|
| **Concurrency** | Simultaneous execution of multiple threads sharing resources |
| **Deadlock** | Occurs when threads wait forever for resources, halting system execution |
| **Race Condition** | A condition where multiple threads access shared data, leading to incorrect results |
| **Producer-Consumer Problem** | A concurrency problem involving two threads: producer creates items, consumer uses them |
| **Semaphore** | A synchronization tool — counting (unrestricted range) or binary (0/1) that manages concurrent access |
| **Mutex** | A type of binary semaphore allowing only one thread access to a resource at a time |
| **Sleeping Barber Problem** | A concurrency problem illustrating irregular thread arrival with limited space |
| **Dining Philosopher Problem** | Deadlock problem when philosophers need two forks to eat but resources are limited |
| **Circular Wait** | A deadlock condition where processes hold resources and wait for each other in a circle |
| **Hold and Wait** | Condition for deadlock where a thread holds resources while waiting for others |
| **Banker's Algorithm** | Algorithm for deadlock avoidance by preemptively checking resource allocation safety |
| **Reader-Writer Problem** | Concurrency problem ensuring multiple readers can read while only one writer modifies |

---

## Key Exam Tips

- **Producer-Consumer**: Track `mt` (empty) and `full` semaphore values through operations — `mt ↔ empty`, `full = full`
- **Deadlock detection**: Draw the resource allocation graph; any cycle = deadlock
- **Banker's Algorithm**: Need = Max - Allocation; check Need[i] ≤ Available one process at a time
- **Lock ordering**: Inconsistent order → deadlock; consistent/same direction order → safe
- **Reader-Writer**: Only Reader+Reader is allowed; Writer needs exclusive access
- **Dining Philosophers**: Classic circular wait; fix with staggered lock acquisition
- **Correct sequencing** in locking mechanisms for dynamic situations
- **Efficient use of semaphores** to manage multi-threaded access
- Understanding conditions and checks for safe allocation in deadlock avoidance problems
- **Timed Lock Acquisition**: Use `tryLock(long timeout)` to break hold-and-wait — if unable to grab secondary lock, release held locks and retry
- **Coffman Conditions All Must Hold**: If even ONE of the 4 conditions (Mutual Exclusion, Hold & Wait, No Preemption, Circular Wait) doesn't exist → no deadlock possible
- **Resource Request Evaluation in Banker's**: Always verify: (1) Request ≤ Need, (2) Request ≤ Available, (3) Simulate allocation and re-check safety sequence before granting

---

## What's Missing (Added for Completeness)

### Deadlock Prevention vs Avoidance Difference
| Aspect | Prevention | Avoidance |
|--------|-----------|-----------|
| **Timing** | Before execution starts, by design | During execution, dynamically |
| **Approach** | Disables at least one of the 4 necessary conditions | Requires prior knowledge of max resource needs |
| **Overhead** | Lower (structural fix) | Higher (continuous state checking) |
| **Example** | Lock ordering, breaking circular wait | Banker's Algorithm |

### Deadlock Handling: Ignore (Ostrich Algorithm)
- Some systems simply ignore deadlocks and reboot when they occur
- Used in Windows, Linux for practical reasons — deadlock is rare and expensive to prevent
- Called the **Ostrich Algorithm** (pretend the problem doesn't exist)

### Resource Types
| Type | Examples | Preemptible? |
|------|----------|:-----------:|
| **Preemptable** | CPU time, memory, swap space | Yes |
| **Non-preemptable** | Printer, tape drive, I/O devices | No |

- Only preemptable resources can be taken away during recovery
- Non-preemptable resources require process restart/termination

### Semaphore Types (Additional Detail)
| Type | Description | Values |
|------|-------------|-------:|
| **Binary/Semaphore** | Acts as mutex lock; value = 0 or 1 | 0, 1 |
| **Counting Semaphore** | Value ranges over an unrestricted domain | Any integer ≥ 0 |

### Deadlock Graph Drawing (Exam Tip)
For any deadlock problem:
1. Draw **process nodes** (circles) and **resource nodes** (squares)
2. **Request edge**: Process → Resource (wants resource)
3. **Assignment edge**: Resource → Process (holds resource)
4. Any cycle = potential deadlock

### Comparison: Deadlock vs Starvation vs Livelock
| Concept | Definition | Output? | Resolution |
|---------|-----------|---------|-----------|
| **Deadlock** | Threads wait forever for each other's resources | Nothing happens (stuck) | Break cycle |
| **Starvation** | Thread waits indefinitely but not deadlocked; never gets resource | Delayed output | Ensure fairness |
| **Livelock** | Threads keep changing state in response to each other but make no progress | Appears active, no progress | Change behavior pattern |
