# Concurrency 4: Locks and Thread-Safe Programming — Detailed Notes

## 1. Recap: Synchronization & Object-Level Locks

### The Problem
- Multiple threads accessing shared data → wrong/unpredictable results due to:
  - **Shared state** between threads
  - **Preemption** (CPU can switch threads at any time)
  - **Race conditions** (out-of-order execution)
  - **Lost updates** (one thread overwrites another's changes)

### Solution: `synchronized` Keyword
- Uses an **object-level lock** to protect shared resources
- **Critical section**: Only one thread can enter at a time (`++` or `--` operations)
- Lock is tied to the **object instance** — threads must share the same object
- Fixes data corruption but does **not control execution order**

---

## 2. Class-Level Locks (Static Synchronization)

### When to Use
- For **`static` variables and methods** that belong to the class, not objects
- Shared by all instances of the class — one common value for everyone

### Key Differences from Object-Level Lock

| Aspect | Object-Level Lock | Class-Level Lock |
|--------|------------------|-----------------|
| Applies to | Non-static members | Static members |
| Lock owned by | Object instance | Class (`Class` object) |
| Need an object? | Yes | No |
| Scope | Single object data | All static/class-wide data |

### How It Works
```java
static int value = 0;
synchronized static void increment() { ... }
```
- Access via `Counter.increment()` — no object creation needed
- Lock belongs to the **class itself**
- Even if multiple objects are created, they all share the same class-level lock
- Protects static data across all instances

### Analogy
- Static variables = a common notebook available to everyone
- Class-level lock = teacher managing who writes to it

### Example: Counter Class with Static Synchronized Method
```java
class Counter {
    static int count = 0;
    
    synchronized static void increment() { // class-level lock
        count++;  // atomic for all threads across all objects
    }
}
// Access: Counter.increment() — no object needed, thread-safe
```
- Ensures `count++` is **atomic** even when multiple threads call it from different objects
- Two threads cannot interfere with each other's increment operation

---

## 3. Semaphores (Semaphore)

### Overview
- **Integer-based synchronization tool** that maintains a fixed number of **permits**
- Controls **how many threads** can enter a critical section **simultaneously**
- More granular control than traditional locks

### How It Works
```java
Semaphore sem = new Semaphore(3);  // 3 permits available
```
- `sem.acquire()` — takes a permit (blocks if none available) → counter decreases
- `sem.release()` — returns a permit → counter increases

### Flow
1. 3 permits available → 3 threads can enter
2. Thread 1 acquires → 2 permits left
3. Thread 2 acquires → 1 permit left
4. Thread 3 acquires → **0 permits** → gate closed
5. Thread 4 waits until a permit is released
6. Thread 1 finishes → releases permit → 1 permit available → Thread 4 enters

### Types of Semaphores

| Type | Permits | Behavior | Like... |
|------|---------|----------|---------|
| **Binary Semaphore** | 1 | Only one thread at a time | Traditional lock |
| **Counting Semaphore** | N (any integer ≥ 0) | Multiple threads concurrently | Capacity-controlled access |

### Key Points
- `new Semaphore(0)` → no permits, all threads wait. Used for **coordination/ordering**
- `new Semaphore(1)` → acts like a binary semaphore/lock
- Permits are **integer-based** only (no floating point)
- By default, semaphore is **unfair** (non-FIFO) — create fair with `new Semaphore(N, true)`

---

## 4. Exception Handling in Concurrency

### Why Exceptions Matter
- Threads can be **interrupted** while waiting or sleeping
- Interrupts disrupt normal flow → handled via exceptions
- Compiler **forces** you to handle them — no ignoring allowed

### `try-catch` Block
```java
try {
    // Risky code that may throw exception (e.g., acquire, sleep)
    sem.acquire();
} catch (InterruptedException e) {
    System.out.println(e);  // Handle the interruption
}
```

- **`try`**: Code that might fail/throw exceptions
- **`catch`**: How to handle the exception when it occurs

### `InterruptedException`
- Occurs when a thread is **interrupted** while waiting or sleeping
- Common sources: `sem.acquire()`, `Thread.sleep()`

---

## 5. Thread Interruption & Sleep

### `Thread.sleep(ms)`
- Pauses the current thread for specified milliseconds
- Can be interrupted → throws `InterruptedException`
- Useful during coding to slow down prints and observe thread behavior

### `acquireUninterruptibly()`
```java
sem.acquireUninterruptibly();  // Acquires permit, ignores interrupts
```
- Alternative to `acquire()` when you don't want try-catch blocks
- Still waits if no permits available, but **cannot be removed from wait queue** via interrupt

---

## 6. Controlling Thread Ordering with Semaphores

### Problem: Without synchronization, thread execution order is non-deterministic
Even with locks, you can protect data but **not control which thread runs first**.

### Solution: Use `Semaphore(0)` for Ordering
```java
// Initialization
Semaphore sem = new Semaphore(0);  // Zero permits — gate closed

// Thread A (runs first, never acquires)
void printA() {
    System.out.print("A");
    sem.release();  // Opens the gate — gives permit to B
}

// Thread B (waits for A's signal)
void printB() throws InterruptedException {
    sem.acquire();  // Waits until A releases
    System.out.print("B");
}
```

### Two-Semaphore Example (ABC Order)
```java
Semaphore bSem = new Semaphore(0);
Semaphore cSem = new Semaphore(0);

// Thread A: prints A, signals B via bSem.release()
// Thread B: acquires bSem, prints B, signals C via cSem.release()
// Thread C: acquires cSem, prints C
```
- Result: **Always prints A → B → C**, regardless of thread start order
- First thread never acquires (never blocks) — it runs immediately
- Subsequent threads wait on their respective semaphores until signaled

---

## 7. Ordered Printing: First and Second Using Semaphore(0)

**Problem:** Two methods `first()` and `second()` execute on different threads that may start in any order. You must ensure "First" is always printed before "Second" using a semaphore with 0 permits.

**Rules:**
- `first()` prints "First", then releases a permit.
- `second()` blocks on acquire until the permit is released, then prints "Second".
- Even if `second()` thread starts first, it waits until `first()` calls `release()`.

```java
import java.util.concurrent.Semaphore;

class Printer {
    Semaphore sem = new Semaphore(0);

    void first() {
        System.out.println("First");
        sem.release(1);
    }

    void second() {
        sem.acquireUninterruptibly();
        System.out.println("Second");
    }
}

public class Main {
    public static void main(String[] args) throws InterruptedException {
        Printer printer = new Printer();

        Thread t2 = new Thread(() -> printer.second());
        Thread t1 = new Thread(() -> printer.first());

        // Start second() thread FIRST to demonstrate synchronization works
        t2.start();
        t1.start();
    }
}
```

**How it works:**
- `Semaphore(0)` → zero permits, gate closed immediately
- `t2` starts first → calls `acquireUninterruptibly()` → blocks (no permit available)
- `t1` runs → prints "First" → calls `sem.release(1)` → permits = 1 → unblocks `t2`
- `t2` resumes → prints "Second"
- Result: always **First → Second**, regardless of which thread starts first

---

## 8. Example Architectures Covered

### Study Room Problem (Counting Semaphore)

**Scenario:** A college has 3 study rooms. Many students want to enter, but only 3 can use them simultaneously.

**Solution:** Use a counting semaphore with 3 permits.

```java
import java.util.concurrent.Semaphore;

class StudyRoom {
    Semaphore sem = new Semaphore(3);

    void useRoom(String studentName) throws Exception {
        sem.acquire();                          // take a permit (blocks if all 3 taken)
        System.out.println(studentName + " entered the study room");
        Thread.sleep(1000);                     // simulates studying
        System.out.println(studentName + " left the study room");
        sem.release();                          // return the permit
    }
}

class Student implements Runnable {
    StudyRoom room;
    String name;

    Student(StudyRoom room, String name) {
        this.room = room;
        this.name = name;
    }

    public void run() {
        try {
            room.useRoom(name);
        } catch (Exception e) {
            System.out.println(e);
        }
    }
}

public class Main {
    public static void main(String[] args) throws InterruptedException {
        StudyRoom room = new StudyRoom();

        for (int i = 1; i <= 6; i++) {
            Student studentTask = new Student(room, "Student " + i);
            Thread t = new Thread(studentTask);
            t.start();
        }
    }
}
```

**How it works:**
- `Semaphore(3)` → initially 3 permits available
- First 3 students acquire → all 3 permits gone, study rooms full
- Students 4–6 block on `sem.acquire()` waiting for a permit
- When any student finishes and calls `sem.release()`, a permit is returned
- The next waiting student immediately acquires it and enters

### Ordered Printing Problem (First / Second)
- Uses `Semaphore(0)` for tight two-thread ordering
- First thread runs immediately and signals second; second thread blocks until signaled

### Ordered Printing Problem (Binary Semaphores — ABC)
- Enforce exact output order: A → B → C
- Two semaphores initialized to 0
- Each thread signals the next one after completing its task

---

## 8a. Ordered Printing with Three Methods Using Semaphore(0)

**Problem:** You are given three methods — `printA()`, `printB()`, and `printC()` — each called by a different thread. Threads may start in any random order (e.g., B, then C, then A). Ensure the output is always: **A B C**.

**Rules:**
- `printA()` runs first, prints "A", then signals B via `semB.release()`.
- `printB()` waits on `semB.acquire()` until A signals it, prints "B", then signals C via `semC.release()`.
- `printC()` waits on `semC.acquire()` until B signals it, prints "C".
- Thread start order does **not** matter — the semaphore chain enforces ordering.

```java
import java.util.concurrent.Semaphore;

class OrderedPrinter {

    // Semaphore for B: init to 0 — B waits until A releases
    Semaphore semB = new Semaphore(0);

    // Semaphore for C: init to 0 — C waits until B releases
    Semaphore semC = new Semaphore(0);

    void printA() {
        System.out.println("A");       // prints first, never blocks
        semB.release();                // gives permission to B
    }

    void printB() throws Exception {
        semB.acquire();                 // waits until A signals
        System.out.println("B");        // prints second
        semC.release();                 // gives permission to C
    }

    void printC() throws Exception {
        semC.acquire();                 // waits until B signals
        System.out.println("C");        // prints third
    }
}

public class Main {
    public static void main(String[] args) {
        OrderedPrinter printer = new OrderedPrinter();

        Thread t1 = new Thread(() -> printer.printA());       // thread for A
        Thread t2 = new Thread(() -> {
            try { printer.printB(); } catch (Exception e) { System.out.println(e); }
        });                                                    // thread for B
        Thread t3 = new Thread(() -> {
            try { printer.printC(); } catch (Exception e) { System.out.println(e); }
        });                                                    // thread for C

        // Start in random order to prove synchronization works
        t3.start();   // C starts first (will block on semC.acquire)
        t2.start();   // B starts second (will block on semB.acquire)
        t1.start();   // A starts last (runs immediately, then signals B)

        // Expected output: A B C (always, regardless of start order)
    }
}
```

**How it works — Step by step:**
1. `t3` starts → calls `semC.acquire()` → blocks (0 permits available).
2. `t2` starts → calls `semB.acquire()` → blocks (0 permits available).
3. `t1` starts → prints "A" → calls `semB.release()` → 1 permit for B → unblocks `t2`.
4. `t2` resumes → prints "B" → calls `semC.release()` → 1 permit for C → unblocks `t3`.
5. `t3` resumes → prints "C".
6. Result: **Always A → B → C**, regardless of thread start order.

**Key insight:** The first thread in the chain (A) never acquires — it runs immediately. Each subsequent thread blocks on its semaphore until the previous thread releases a permit, creating a signaling chain: **A → semB → B → semC → C**.

**Note on fairness:** This ordering works even with `new Semaphore(0)` (unfair, default) because the chain structure enforces order — B cannot proceed without A releasing, and C cannot proceed without B releasing. FIFO fairness is unnecessary for signaling chains where each thread both acquires and releases exactly one permit in sequence.

## 8b. Alternating Zero-Even-Odd Printing with Three Threads Using Semaphores

**Problem:** You are given an integer `n`. Create three threads — Zero, Odd, and Even — that produce the interleaved output: `01020304...0n` (if n is odd) or `010203...0n` (if n is even). The zero thread prints `0` before every number. The odd and even threads print their respective numbers in order. Output must follow the exact pattern regardless of which thread starts first.

**Expected output for n = 5:** `0102030405`

**Rules:**
- `zero()` prints `0` before each number, then releases either `oddSem` or `evenSem`.
- `odd()` waits on `oddSem`, prints the next odd number (1, 3, 5...), then releases `zeroSem`.
- `even()` waits on `evenSem`, prints the next even number (2, 4, 6...), then releases `zeroSem`.
- The semaphore chain enforces the order: Zero → Odd/Even → Zero → Odd/Even ...

```java
import java.util.concurrent.Semaphore;

class ZeroEvenOdd {
    private int n;

    // Semaphore to control zero thread (initially 1 permit — it enters first)
    private Semaphore zeroSem = new Semaphore(1);

    // Semaphore to control odd thread (initially 0 permits — waits for signal)
    private Semaphore oddSem = new Semaphore(0);

    // Semaphore to control even thread (initially 0 permits — waits for signal)
    private Semaphore evenSem = new Semaphore(0);

    public ZeroEvenOdd(int n) {
        this.n = n;
    }

    // zero method: prints 0, then signals the appropriate number thread
    public void zero() throws InterruptedException {
        // Step 1: Loop from 1 to n
        for (int i = 1; i <= n; i++) {
            // Step 2: Wait for zeroSem
            zeroSem.acquire();
            // Step 3: Print 0
            System.out.print(0);
            // Step 4: If current number is odd, release oddSem
            if (i % 2 != 0) {
                oddSem.release();
            }
            // Step 5: If current number is even, release evenSem
            else {
                evenSem.release();
            }
        }
    }

    // odd method: prints odd numbers (1, 3, 5...)
    public void odd() throws InterruptedException {
        // Step 1: Loop through odd numbers from 1 to n
        for (int i = 1; i <= n; i += 2) {
            // Step 2: Wait for oddSem
            oddSem.acquire();
            // Step 3: Print the odd number
            System.out.print(i);
            // Step 4: Release zeroSem so zero can print next 0
            zeroSem.release();
        }
    }

    // even method: prints even numbers (2, 4, 6...)
    public void even() throws InterruptedException {
        // Step 1: Loop through even numbers from 2 to n
        for (int i = 2; i <= n; i += 2) {
            // Step 2: Wait for evenSem
            evenSem.acquire();
            // Step 3: Print the even number
            System.out.print(i);
            // Step 4: Release zeroSem so zero can print next 0
            zeroSem.release();
        }
    }
}

public class Main {
    public static void main(String[] args) throws InterruptedException {
        int n = 5;
        ZeroEvenOdd zeo = new ZeroEvenOdd(n);

        Thread t1 = new Thread(() -> {
            try { zeo.zero(); } catch (InterruptedException e) {}
        }); // zero thread
        Thread t2 = new Thread(() -> {
            try { zeo.odd(); } catch (InterruptedException e) {}
        });  // odd thread
        Thread t3 = new Thread(() -> {
            try { zeo.even(); } catch (InterruptedException e) {}
        });   // even thread

        // Start threads in random order to prove synchronization works
        t2.start();   // Odd starts first (will block on oddSem)
        t3.start();   // Even starts second (will block on evenSem)
        t1.start();   // Zero starts last (acquires initial permit, then signals)

        // Expected output: 0102030405 (always, regardless of start order)
    }
}
```

**How it works — Step by step:**
1. `t2` (odd) starts → calls `oddSem.acquire()` → blocks (0 permits available).
2. `t3` (even) starts → calls `evenSem.acquire()` → blocks (0 permits available).
3. `t1` (zero) starts → acquires `zeroSem(1)` → runs immediately → prints `0`.
4. `i=1` (odd) → `oddSem.release()` → 1 permit for odd → unblocks `t2`.
5. `t2` resumes → acquires `oddSem(1)` → prints `1` → `zeroSem.release()` → permits=1 → unblocks `t1`.
6. `t1` resumes loop i=2 → acquires `zeroSem(1)` → prints `0` → `evenSem.release()` → unblocks `t3`.
7. `t3` resumes → acquires `evenSem(1)` → prints `2` → `zeroSem.release()` → unblocks `t1`.
8. Steps 4-7 repeat for i=3,4,5 until loop completes.
9. Result: **Always `0102030405`**, regardless of thread start order.

**Key insight:** This forms a **pulsing loop** pattern (unlike the linear ABC chain): Zero acquires `zeroSem(1)`, prints, and signals Odd or Even → number thread acquires, prints, returns permit to Zero → Zero loops next iteration. The initial permit on `zeroSem` lets zero enter first; thereafter every number thread returns a permit to keep the pulse going.

## 9. Key Takeaways

| Concept | Purpose | Key Detail |
|---------|---------|------------|
| Object-level `synchronized` | Protect single object's data | Lock tied to object instance |
| Class-level `synchronized` | Protect shared static data | Lock tied to class, no objects needed |
| Semaphore (counting) | Allow N threads concurrently | Configure with permit count |
| Semaphore (binary) | Like a lock (1 permit) | Create with `Semaphore(1)` |
| Semaphore(0) | Thread coordination/ordering | Forces wait until another thread signals |
| try-catch | Handle InterruptedException | Mandatory for `acquire()` and `sleep()` |
| `acquireUninterruptibly()` | Wait without exception handling | Cannot be interrupted from waiting queue |
| Mutex vs Semaphore | Ownership enforcement | Mutex enforces ownership; semaphore allows any thread to release |
| Lock Ordering | Prevent deadlock | All threads acquire locks in the same global order |
| Timed Lock Acquisition | Break Hold and Wait | Use `ReentrantLock.tryLock(timeout)` to give up if lock unavailable |

---

## 10. Key Terminology Glossary

| Term | Definition |
|------|-----------|
| **Critical Section** | A part of the program that accesses shared resources and must not be executed concurrently by more than one thread |
| **Object Lock** | A lock mechanism ensuring that only one thread can access non-static synchronized methods of an object at a time. Also known as a monitor or intrinsic lock — every Java object has one |
| **Class Lock** | A lock associated with static methods to control concurrent access at the class level, not the object level. There is exactly one class-level lock per class, regardless of how many objects are created |
| **Static Variable** | A class-level variable shared by all instances of a class. Since all objects reference the same memory location, it requires a class-level lock for thread safety |
| **Synchronized Method** | A method in which only one thread at a time can execute, ensuring exclusive access to a critical section of code. For non-static methods, locks on the object instance; for static methods, locks on the class |
| **Synchronized Block** | A block within a method where only one thread is allowed to execute at a time. More flexible than synchronized methods — you choose which object's lock to use, and it need not be `this` |
| **Semaphore** | A signaling mechanism used to control access by multiple threads to a common resource. Maintains a counter of permits; threads must acquire a permit before proceeding |
| **acquire** (Semaphore) | A method that decreases the semaphore counter. If the counter is zero, the calling thread blocks until a permit becomes available |
| **release** (Semaphore) | A method that increases the semaphore counter, signaling that a resource has been freed and allowing another thread to proceed |
| **Deadlock** | A situation in concurrent programming where two or more threads are blocked forever, each waiting for the other to release a lock. Neither can proceed, resulting in a permanent standstill |
| **Thread.sleep(ms)** | A mechanism that pauses the currently executing thread for a specified time (in milliseconds). The thread retains its locks during sleep but yields the CPU to other threads |
| **Runnable** | An interface (`java.lang.Runnable`) that signifies that an instance of a class can be executed by a thread. Defines a single method `run()` containing the code to execute in the new thread |
| **Permits** | The countable units managed by a semaphore. Each permit represents authorization for one thread to enter a critical section. Threads call `acquire()` to consume a permit and `release()` to return it |
| **Counting Semaphore** | A semaphore initialized with N permits (N > 1). Allows up to N threads to concurrently access a shared resource, such as in the Study Room or BoundedBuffer scenarios |
| **Binary Semaphore** | A semaphore initialized with exactly 1 permit. Behaves like a traditional mutex/lock — only one thread can proceed at a time. Used for signaling and ordering between threads |
| **Fair Semaphore** | A semaphore created with `new Semaphore(N, true)` that grants permits in FIFO order, ensuring the longest-waiting thread gets served first |
| **Unfair Semaphore** | A semaphore created with `new Semaphore(N)` or `new Semaphore(N, false)` (the default) that does not guarantee any particular order for granting permits |
| **ReentrantLock** | An explicit lock class (`java.util.concurrent.locks.ReentrantLock`) that supports timed acquisition via `tryLock(timeout)`, fairness control, and additional capabilities beyond native `synchronized` |
| **Circular Wait** | One of the four Coffman conditions: a closed chain of threads where each thread waits for a resource held by the next. Deadlock prevention strategies like Lock Ordering specifically target this condition |

---

## 11. The Producer-Consumer Problem

The Producer-Consumer problem represents a classic multi-threaded synchronization challenge involving two distinct categories of threads sharing a fixed-size buffer:

1. **Producers**: Generate data items and attempt to insert them into the queue buffer.
2. **Consumers**: Extract items out of the buffer queue and utilize them.

### The Core Architectural Rules
- **Buffer Overflow Protection**: If the buffer fills to maximum capacity, producers must block and wait until space is cleared.
- **Buffer Underflow Protection**: If the buffer is completely empty, consumers must block and wait until a producer adds a new item.
- **Mutual Exclusion (Mutex)**: Only one thread can modify the internal array index pointers at any single moment to prevent internal pointer corruption.

### Implementation via Semaphores
To coordinate this problem safely without CPU busy-waiting, three semaphores are configured:

- `emptySpaces`: A counting semaphore initialized to the capacity size of the buffer.
- `fullSpaces`: A counting semaphore initialized to 0.
- `mutex`: A binary semaphore initialized to 1 to guard queue insertion/removal operations.

```java
class BoundedBuffer {
    private final Queue<Object> buffer = new LinkedList<>();
    private final int capacity = 5;

    private final Semaphore emptySpaces = new Semaphore(capacity);
    private final Semaphore fullSpaces = new Semaphore(0);
    private final Semaphore mutex = new Semaphore(1);

    public void produce(Object item) throws InterruptedException {
        emptySpaces.acquire(); // Decrements empty slots; blocks if buffer is full
        
        mutex.acquire();       // Enters critical section
        buffer.add(item);
        mutex.release();       // Exits critical section
        
        fullSpaces.release();  // Increments full slots, notifying consumers
    }

    public Object consume() throws InterruptedException {
        fullSpaces.acquire();  // Decrements full slots; blocks if buffer is empty
        
        mutex.acquire();       // Enters critical section
        Object item = buffer.poll();
        mutex.release();       // Exits critical section
        
        emptySpaces.release(); // Increments empty slots, notifying producers
        return item;
    }
}
```

---

## 12. Introduction to Deadlocks

A deadlock is an error state where two or more threads are permanently blocked, each waiting for a lock resource that is currently held by another thread in the cycle. Because everyone is waiting and no one releases their resource, the application hangs indefinitely.

### The Classic Deadlock Scenario
- Thread 1 acquires Lock A and is preempted.
- Thread 2 acquires Lock B.
- Thread 2 tries to acquire Lock A but blocks because Thread 1 holds it.
- Thread 1 wakes up and tries to acquire Lock B but blocks because Thread 2 holds it.
- Both threads remain stuck in a mutual block forever.

---

## 13. The Coffman Conditions for Deadlock

A deadlock scenario can occur if and only if all four of the following conditions are simultaneously met within a system:

1. **Mutual Exclusion**: At least one resource must be held in a non-shareable mode (only one thread can use it at a time).
2. **Hold and Wait**: A thread must currently hold at least one resource lock while actively waiting to acquire additional resources held by other threads.
3. **No Preemption**: Resources cannot be forcibly taken from a thread; a lock can only be released voluntarily by the holding thread.
4. **Circular Wait**: A closed chain of threads must exist, where each thread waits for a resource held by the next thread in the circle.

---

## 14. Strategies for Preventing Deadlocks

To eliminate deadlocks, you must design your software architecture to break at least one of the Coffman conditions.

### Lock Ordering (Breaking Circular Wait)
- **Strategy**: Ensure that all threads in the application always acquire resources in the exact same order.
- **Mechanism**: If both Thread 1 and Thread 2 are forced to acquire Lock A before attempting to acquire Lock B, Thread 2 will block cleanly at Lock A if Thread 1 holds it. It will never get the chance to hold Lock B while waiting for Lock A, breaking the deadlock cycle.

### Timed Lock Acquisition (Breaking Hold and Wait)
- **Strategy**: Use explicit locking tools that allow a thread to give up if a lock cannot be acquired within a certain time window (breaking Hold and Wait).
- **Mechanism**: Instead of using the native `synchronized` keyword, utilize `java.util.concurrent.locks.ReentrantLock` with `tryLock(long timeout, TimeUnit unit)`. If the thread fails to grab the lock within the timeout period, it drops its currently held resources, avoiding a permanent lockup.

---

## 15. Mutex vs Binary Semaphore

### Key Distinction
| Aspect | Mutex | Binary Semaphore |
|--------|-------|------------------|
| Permits | 1 | 1 |
| Ownership concept | Yes — only the thread that acquired can release | No — any thread can release |
| Primary use case | Mutual exclusion (locking) | Asynchronous thread signaling and ordering |

### Why It Matters
Because a **Mutex** enforces ownership, it prevents accidental or incorrect release by unrelated threads. A **Binary Semaphore**, however, allows any thread to call `.release()` regardless of who acquired it, making semaphores more flexible for cross-thread coordination where the acquiring and releasing happen in completely different execution contexts.

---

## 16. Class Summary Quiz Key

- **Object vs. Class Lock Scope**: Object locks synchronize across operations using the same specific instance; class locks synchronize globally across all instances of that class.
- **Semaphore Permit Flow**: `.acquire()` blocks execution if permits are 0; `.release()` increments available counts and wakes up any waiting threads.
- **Producer-Consumer Controls**: Throttled using an `emptySpaces` semaphore to block producer overflow and a `fullSpaces` semaphore to block consumer underflow.
- **Deadlock Cause**: Occurs when all four Coffman conditions are present, typically manifesting as a circular dependency chain.

- **Signal Chain Pattern**: Multi-thread ordering uses `Semaphore(0)` in a chain — each thread acquires its semaphore, then releases the next one, creating A → semB → B → semC → C
