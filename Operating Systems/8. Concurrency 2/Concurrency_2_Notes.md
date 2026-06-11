# Concurrency - Part 2: Thread Management using Executor Framework

## Table of Contents

1. [Revision from Concurrency Part 1](#1-revision-from-concurrency-part-1)
2. [Manual Thread Creation in Java](#2-manual-thread-creation-in-java)
3. [Runnable Interface vs Callable Interface](#3-runnable-interface-vs-callable-interface)
4. [Live Demonstration: Single vs Multi-threaded Execution](#4-live-demonstration-single-versus-multi-threaded-execution)
5. [Problems with Manual Thread Creation](#5-problems-with-manual-thread-creation)
6. [Core Architecture of a Thread Pool](#6-core-architecture-of-a-thread-pool)
7. [The Java Executor Framework](#7-the-java-executor-framework)
8. [Submitting Tasks & Pool Control](#8-submitting-tasks--pool-control)
9. [Asynchronous Tracking with Future Tokens](#9-asynchronous-tracking-with-future-tokens)
10. [Multiple Callable Tasks Example](#10-multiple-callable-tasks-example)
11. [Practical Case Study: Multithreaded Merge Sort](#11-practical-case-study-multithreaded-merge-sort)
12. [Multithreaded Merge Sort — Complete Implementation Guide](#12-multithreaded-merge-sort--complete-implementation-guide)
13. [Conceptual Mini-Future Mock Implementation](#13-conceptual-mini-future-mock-implementation)
14. [Summary Notes](#14-summary-notes)
15. [Exam & Project Info](#15-exam--project-info)
16. [Quiz 29-Question-answers-and-explanations](#16-concurrency-2-quiz-questions-answers--explanations)

---

## 1. Revision from Concurrency Part 1

### Process vs Thread Basics

- **Process**: A dynamic program that gets submitted to the CPU for execution by the scheduler/overscheduler
- **Thread**: The smallest unit of execution inside a process
  - Process is just a *container* — it holds resources, code, memory, but does not perform work itself
  - Threads are what actually perform the tasks within a process
- A process can have **single thread** or **multiple threads**
- By default (before creating new threads), only the **main thread** exists and performs work

---

## 2. Manual Thread Creation in Java

### Working Model

Think of three components:

| Component | Role |
|-----------|------|
| `Runnable` | Represents a **task** |
| `Thread` | The **worker** that executes the task |
| `start()` | Begins execution of a new thread |

The keyword `new Thread(...)` only *creates* a thread object — it does **not** start it. Only calling `.start()` actually creates and begins the new thread.

### Creating a Thread Manually

```java
class MyTask implements Runnable {    // Implement Runnable interface -> overrides run() method
    public void run() {                // Task logic here (e.g., printing "Hello World")
        System.out.println("Hello World");
    }
}

public class Main {
    public static void main(String[] args) {
        MyTask task = new MyTask();           // Create the task object
        Thread T1 = new Thread(task);         // Create thread object, attach task -- does NOT start
        T1.start();                            // Starts a NEW thread; JVM calls run() on that new thread
    }
}
```

### Key Points

- `Runnable` interface provides the `run()` method — implement it to define what the task does
- In `main`, instantiate your task and create a `Thread` object with it as an argument
- Call `.start()` on the Thread — only then does the JVM start a **new thread** and invoke `run()` on it
- Without `.start()`, the thread is never created; without `new Thread(...)` there's no worker

### Identifying Which Thread is Running

Use `Thread.currentThread().getName()` to check which thread executes a task.

---

## 3. Task Definitions: Runnable vs Callable

Both are interfaces with key differences:

| Feature | `Runnable` | `Callable` |
|---------|-----------|------------|
| Method name | `run()` | `call()` |
| Execution method signature | `public void run()` | `public V call() throws Exception` |
| Returns result | No (Fire-and-forget) | **Yes** — has a generic return type `V` |
| Checked exceptions | Cannot throw checked exceptions; must be handled internally | Natively allowed to bubble checked exceptions directly up to the executing engine thread |
| When to use | Task that does not need to return anything | Task that needs to return a result and/or handle checked exceptions |

> Whenever you want something returned from the task, use `Callable`. Use `Runnable` when there is no return needed.

---

## 4. Live Demonstration: Single vs Multi-threaded Execution

**In `main` (single-threaded)** — prints in the main thread.

**With multi-threading (`T1.start()`)** — adds a second path of execution running in a separate thread.

> Note: The order of output between the main thread and the new thread is **non-deterministic** (scheduler-dependent).

---

## 5. Problems with Manual Thread Creation

While manual thread creation (`new Thread(runnable).start()`) works for basic examples, it introduces severe bottlenecks in production applications:

| Problem | Detail |
|---------|--------|
| **High Creation Cost** | Allocating a new thread requires the OS to provision a dedicated runtime object, reserve significant private stack memory, and register scheduling metadata. Creating a thread per task is highly resource-expensive. |
| **Excessive Context Switching** | Having too many active threads forces the OS CPU scheduler to spend massive overhead constantly swapping thread execution contexts. This rapid interleaving wastes valuable CPU processing cycles on overhead instead of executing tasks. |
| **Memory Exhaustion** | Each thread maintains its own isolated runtime stack space. As thread count climbs linearly, the total application memory footprint increases drastically, risking system memory overload. |
| **Lack of Concurrency Control** | When a system experiences an incoming burst of traffic (e.g., 1,000 requests spawning 1,000 independent threads), it provides zero bounds over resource consumption. This uncapped execution frequently causes severe performance degradation or total platform collapse. |

---

## 6. Core Architecture of a Thread Pool

To eliminate the overhead of manual multi-threading, modern systems utilize a **Thread Pool**.

### The Concept

Instead of instantiating a brand-new worker thread for every individual assignment, a set number of threads are pre-allocated and kept alive inside a managed pool container.

### How it Handles Tasks

Incoming requests are safely placed into an internal **Task Queue**. Available worker threads continuously poll this queue, extract a task, execute its runtime path, and immediately return to the pool upon completion to be reused for the next queued item.

### Advantages over Manual Multi-Threading

| Advantage | Detail |
|-----------|--------|
| **Reduced Resource Overhead** | Eliminates the cycle cost of repeatedly creating and destroying native threads. |
| **System Stability & Throttling** | Caps the maximum number of simultaneous execution threads, protecting system memory from unexpected surges. |
| **Centralized Management** | Outsources tracking, thread scheduling, and cleanup lifecycles to an internal controller manager rather than manual application logic. |

### How a Thread Pool Works (Real-World Analogy)

```
Customer orders -> [Task Queue] -> Manager (Executor Service) <-> Available waiters (threads)
                                         |
                                   Process order -> Release waiter back -> Pick next order
```

| Element | Real World | In Java |
|---------|-----------|---------|
| Customer orders | Tasks to process | Incoming tasks/requests |
| Order queue | Task queue | `BlockingQueue` of tasks |
| Manager | Executor Service | Manages thread pool |
| Waiters | Threads | Reusable worker threads |

Thread pool has a defined **capacity** (set by developer). Incomplete tasks wait in the queue.

### Why Thread Pool is Better

- **Saves time**: No repeated thread creation/destruction overhead (~1 second per thread saved)
- **Saves memory**: Reuses existing threads instead of allocating new ones each time
- **Controlled concurrency**: Fixed capacity limits how many threads exist simultaneously (e.g., 3 threads handling 1000 tasks)

---

## 7. The Java Executor Framework

The Java standard library natively packages this thread-pooling architecture inside the `java.util.concurrent` package via the **Executor Framework**.

### Core Components Matrix

The framework splits responsibilities across a few crucial interfaces and factory helpers:

| API Component | Structure Type | Core Functional Meaning |
|--------------|----------------|------------------------|
| `ExecutorService` | Interface | The primary interface that manages task execution lifecycles and controls internal thread pools. |
| `Executors` | Factory Class | A helper factory class used to spin up configured implementations of thread pools. |
| `Runnable` | Interface | Represents an asynchronous task that does not return an execution result. |
| `Callable<V>` | Interface | Represents an advanced task that returns a generic result and can throw checked exceptions. |
| `Future<V>` | Interface | Acts as a placeholder token representing the pending result of an asynchronous computation. |

---

## 8. Submitting Tasks & Pool Control

To manage fixed allocations, you initialize a pool via the factory helper:

```java
ExecutorService executor = Executors.newFixedThreadPool(3);
```

This builds a bounded thread pool containing exactly **3** active worker threads.

### Key Workflow Commands

- **`executor.submit(task)`** — Hands an asynchronous task over to the ExecutorService. If a worker thread is free, it processes it immediately; otherwise, the task waits inside the internal queue.
- **`executor.shutdown()`** — Initiates a safe, graceful termination sequence. The executor immediately stops accepting any brand-new incoming submissions but promises to finish processing all active and currently queued tasks before tearing down worker threads.

---

## 9. Asynchronous Tracking with Future Tokens

When you submit a `Callable` task to an ExecutorService, the main thread cannot wait around synchronously for the result. Instead, the executor immediately returns a **`Future<V>`** object.

### The Token Analogy

A Future acts exactly like a **restaurant claim ticket**. You submit an order (the Callable task) to the kitchen (the Thread Pool), and they hand you a token number (Future). You can continue doing other work while the kitchen prepares your meal in the background.

### Retrieving Data via `.get()`
Calling `Integer result = future.get();` pulls the final value out of the token.

- **Blocking Behavior**: If the worker thread has not finished executing the Callable task, `.get()` will block the calling thread, forcing it to wait until the result is completely computed and ready.

---

## 10. Multiple Callable Tasks Example

Below is a complete example showing how multiple `Callable` tasks can be submitted to a fixed thread pool using `ExecutorService`, with results tracked via `Future`.

### Problem Statement

- Create a `SquareTask` class that implements `Callable<Integer>`.
- Each task stores one number, prints which thread calculates the square, and returns the square.
- In `main()`, create a fixed thread pool of size 3, submit tasks for numbers 5, 6, and 7, retrieve results via `Future.get()`, then shut down the executor.

### Expected Output Format

```
Calculating square of 5 using pool-1-thread-1
Calculating square of 6 using pool-1-thread-2
Calculating square of 7 using pool-1-thread-3
Square of 5: 25
Square of 6: 36
Square of 7: 49
```

> **Note**: Thread names and execution order may vary because the thread scheduler determines which thread picks up which task.

### Implementation

```java
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

class SquareTask implements Callable<Integer> {

    int number;

    SquareTask(int number) {
        this.number = number;
    }

    public Integer call() {
        System.out.println("Calculating square of " + number + " using " + Thread.currentThread().getName());
        return number * number;
    }
}

public class Main {
    public static void main(String[] args) throws Exception {
        ExecutorService executor = Executors.newFixedThreadPool(3);

        Future<Integer> f1 = executor.submit(new SquareTask(5));
        Future<Integer> f2 = executor.submit(new SquareTask(6));
        Future<Integer> f3 = executor.submit(new SquareTask(7));

        System.out.println("Square of 5: " + f1.get());
        System.out.println("Square of 6: " + f2.get());
        System.out.println("Square of 7: " + f3.get());

        executor.shutdown();
    }
}
```

### Key Points

- **`Callable<V>`** is used because we need each task to return a result (`Integer`)
- **`ExecutorService`** with `newFixedThreadPool(3)` creates exactly 3 reusable worker threads
- **`executor.submit()`** returns a **`Future<Integer>`** — a token representing the pending result
- **`future.get()`** blocks until the corresponding task completes and returns its value
- **`executor.shutdown()`** gracefully stops the pool after all tasks are submitted and results collected; it does not accept new tasks but finishes queued ones first

---

## 11. Practical Case Study: Multithreaded Merge Sort

Merge sort is an ideal real-world algorithm for multi-threading due to its natural divide-and-conquer strategy.

### Why it fits

When a large array is split down the middle, the sorting operations for the left half and the right half are **completely independent** of one another.

### The Multithreaded Flow

1. The main array task splits the data array in half.
2. It wraps the **left half** into a distinct `Callable` sub-task and submits it to the ExecutorService, receiving a `Future` token back.
3. It wraps the **right half** into a parallel `Callable` sub-task running on an independent worker thread.
4. The parent execution context invokes `.get()` on both child `Future` tokens, safely blocking until both paths sort independently.
5. Once both paths return their results, a final sequential merge joins the sorted halves back together.

---

---

## 12. Multithreaded Merge Sort — Complete Implementation Guide

### Problem Statement

You are given an integer array. Your task is to sort it using multithreading. The logic of merge sort is already known. Your focus should be on using: **ExecutorService**, **Callable**, and **Future**.

### Requirements

Create a class `MergeSortTask` that implements `Callable<int[]>`. Your program should:

1. Create a thread pool using `ExecutorService`.
2. Create a task to sort the array.
3. Inside the task, divide the array into left and right halves.
4. Submit the left and right sorting tasks to the executor.
5. Use `Future<int[]>` to collect the sorted results.
6. Merge the two sorted halves.
7. Print the final sorted array.
8. Shut down the executor.

### Input / Output

- **Input**: `arr = {8, 3, 5, 1, 9, 2, 7, 4}`
- **Expected Output**: `[1, 2, 3, 4, 5, 7, 8, 9]`

### Important Points

- Use `Callable<int[]>` because the task must return a sorted array.
- Use `Future<int[]>` because the sorted result may not be ready immediately.
- Use `future.get()` to wait for and collect the result.
- For very small arrays, sort directly to avoid creating too many threads.

---

### Starter Code

```java
import java.util.Arrays;
import java.util.concurrent.*;

class MergeSortTask implements Callable<int[]> {

    int[] arr;
    ExecutorService executor;

    MergeSortTask(int[] arr, ExecutorService executor) {
        // initialize variables
    }

    public int[] call() throws Exception {
        // implement multithreaded sorting logic here

        // hint:
        // create leftTask and rightTask
        // submit both tasks
        // get results using Future
        // merge and return
        return null;
    }

    static int[] merge(int[] left, int[] right) {
        // assume students already know merge logic
        return null;
    }
}

public class Main {
    public static void main(String[] args) throws Exception {

        int[] arr = {8, 3, 5, 1, 9, 2, 7, 4};

        ExecutorService executor = Executors.newFixedThreadPool(4);

        // create main MergeSortTask

        // submit task to executor

        // get final sorted array

        // print sorted array

        executor.shutdown();
    }
}
```

---

### Template (with TODOs)

```java
import java.util.Arrays;
import java.util.concurrent.*;

class MergeSortTask implements Callable<int[]> {

    int[] arr;
    ExecutorService executor;

    MergeSortTask(int[] arr, ExecutorService executor) {
        // TODO: initialize arr
        // TODO: initialize executor
    }

    public int[] call() throws Exception {

        // TODO: base case
        // If array size is very small, sort directly and return

        // TODO: find middle index

        // TODO: create left half using Arrays.copyOfRange()

        // TODO: create right half using Arrays.copyOfRange()

        // TODO: create MergeSortTask for left half

        // TODO: create MergeSortTask for right half

        // TODO: submit left task to executor
        Future<int[]> leftFuture = null;

        // TODO: submit right task to executor
        Future<int[]> rightFuture = null;

        // TODO: get sorted left half using leftFuture.get()
        int[] sortedLeft = null;

        // TODO: get sorted right half using rightFuture.get()
        int[] sortedRight = null;

        // TODO: merge sortedLeft and sortedRight and return final sorted array
        return null;
    }

    static int[] merge(int[] left, int[] right) {

        // TODO: create result array of size left.length + right.length

        // TODO: use three pointers:
        // i for left array
        // j for right array
        // k for result array

        // TODO: compare elements from left and right
        // and place smaller element in result

        // TODO: copy remaining elements from left array

        // TODO: copy remaining elements from right array

        // TODO: return merged result
        return null;
    }
}

public class Main {

    public static void main(String[] args) throws Exception {

        int[] arr = {8, 3, 5, 1, 9, 2, 7, 4};

        // TODO: create a fixed thread pool of size 4
        ExecutorService executor = null;

        // TODO: create main MergeSortTask for the full array
        MergeSortTask mainTask = null;

        // TODO: submit mainTask to executor
        Future<int[]> finalFuture = null;

        // TODO: get final sorted array using finalFuture.get()
        int[] sortedArray = null;

        // TODO: print sorted array using Arrays.toString()

        // TODO: shut down executor
    }
}
```

---

### Completed Implementation

```java
import java.util.Arrays;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

class MergeSortTask implements Callable<int[]> {

    int[] arr;
    ExecutorService executor;

    MergeSortTask(int[] arr, ExecutorService executor) {
        this.arr = arr;
        this.executor = executor;
    }

    public int[] call() throws Exception {

        if (arr.length <= 1) {
            return arr;
        }

        if (arr.length <= 2) {
            int[] copy = Arrays.copyOf(arr, arr.length);
            Arrays.sort(copy);
            return copy;
        }

        int mid = arr.length / 2;

        int[] left = Arrays.copyOfRange(arr, 0, mid);
        int[] right = Arrays.copyOfRange(arr, mid, arr.length);

        MergeSortTask leftTask = new MergeSortTask(left, executor);
        MergeSortTask rightTask = new MergeSortTask(right, executor);

        Future<int[]> leftFuture = executor.submit(leftTask);
        Future<int[]> rightFuture = executor.submit(rightTask);

        int[] sortedLeft = leftFuture.get();
        int[] sortedRight = rightFuture.get();

        return merge(sortedLeft, sortedRight);
    }

    static int[] merge(int[] left, int[] right) {

        int i = 0;
        int j = 0;
        int k = 0;

        int[] result = new int[left.length + right.length];

        while (i < left.length && j < right.length) {

            if (left[i] <= right[j]) {
                result[k] = left[i];
                i++;
            } else {
                result[k] = right[j];
                j++;
            }

            k++;
        }

        while (i < left.length) {
            result[k] = left[i];
            i++;
            k++;
        }

        while (j < right.length) {
            result[k] = right[j];
            j++;
            k++;
        }

        return result;
    }
}

public class Main {

    public static void main(String[] args) throws Exception {

        int[] arr = {8, 3, 5, 1, 9, 2, 7, 4};

        ExecutorService executor = Executors.newFixedThreadPool(4);

        MergeSortTask task = new MergeSortTask(arr, executor);

        Future<int[]> future = executor.submit(task);

        int[] sortedArray = future.get();

        System.out.println(Arrays.toString(sortedArray));

        executor.shutdown();
    }
}
```

---

## 13. Conceptual Mini-Future Mock Implementation

To demystify how a Future works under the hood, a simplified synchronized tracking object operates on wait-and-notify patterns:

```java
class MyFuture<V> {
    private V result;
    private boolean isDone = false;

    // Invoked by the main thread wanting the result
    public synchronized V get() throws InterruptedException {
        while (!isDone) {
            wait(); // Blocks caller thread if async worker isn't finished
        }
        return result; // Returns the completed result
    }

    // Invoked by the thread pool worker upon task completion
    public synchronized void setResult(V result) {
        this.result = result; // Store final result
        this.isDone = true;   // Mark task as done
        notifyAll();          // Wake up threads waiting in get()
    }
}
```

---

## 14. Summary Notes

| Concept | Key Takeaway |
|---------|-------------|
| `Runnable` | Interface to define a task; provides `public void run()` method; no return value; cannot throw checked exceptions |
| `Callable<V>` | Interface like Runnable but with `public V call() throws Exception` that can **return a result** and bubble checked exceptions |
| `Thread` class | Pre-defined Java class used to create workers |
| `start()` | Initiates a new thread; JVM then calls `run()` on the new thread |
| Main thread | Default thread running the program before any new threads are created |
| Thread creation timing | Only begins when `.start()` is called, not at `new Thread(...)` |
| High creation cost | OS must provision runtime object, reserve stack memory, register scheduling metadata per thread |
| Context switching overhead | Too many threads wastes CPU cycles swapping contexts instead of executing tasks |
| Memory exhaustion | Each thread has its own stack; linear thread growth causes massive memory footprint increase |
| Lack of concurrency control | Uncapped thread creation (e.g., 1000 requests = 1000 threads) causes performance collapse |
| Thread pool solution | Reuses pre-created threads with defined capacity; tasks queued for processing |
| Executor Framework | Java standard library's `java.util.concurrent` package packages this architecture |
| Core components | `ExecutorService` (interface), `Executors` (factory), `Runnable`, `Callable<V>`, `Future<V>` |
| `ExecutorService` | Interface that manages thread pools automatically — you don't manually manage threads |
| FixedThreadPool | `Executors.newFixedThreadPool(n)` creates a pool of exactly n threads |
| submit() | Hands a task to the ExecutorService; free worker processes it immediately or task waits in queue |
| `shutdown()` | Stops accepting new requests; existing queued tasks still complete normally (graceful termination) |
| Future token analogy | Like a restaurant claim ticket — you get a token for an async result while doing other work |
| Future `.get()` | Blocks the calling thread until the async task finishes and returns its result |
| Multithreaded merge sort | Divide-and-conquer algorithm where left/right halves sort independently via parallel Callable tasks |
| Multiple Callable tasks | Submit multiple tasks to a single executor; each `submit()` returns an individual `Future` token to track that specific task's result |
| `Future` | Represents result of asynchronous computation; `get()` blocks until result is available |

---

## 15. Exam & Project Info

- **Questions will be easy** — focus on understanding how to write programs correctly
- **Project**: "Build your own shelf" due June 12–21
- **Important**: No external AI tools (ChatGPT, Repeat, etc.) allowed — there will be a project-based exam on the same day as the regular exam

---

## 16. Concurrency 2 Quiz — Questions, Answers & Explanations

### Q1: What does Runnable represent?
**Answer**: A task that can be executed by a thread

---

### Q2: Which method starts a new thread?
**Answer**: `start()`

---

### Q3: Which resource does each thread usually need separately?
**Answer**: Stack memory

---

### Q4: What is the biggest issue with creating too many threads manually?
**Answer**: It increases memory usage and scheduling overhead

---

### Q5: If 1000 requests create 1000 separate threads, what is the most likely problem?
**Answer**: The system may become overloaded due to too many active threads

---

### Q6: Why does too many threads increase CPU overhead?
**Answer**: Because the OS spends extra time switching between threads

---

### Q7: A thread pool contains:
**Answer**: Reusable threads

---

### Q8: Who decides when a thread gets CPU time?
**Answer**: OS Scheduler

---

### Q9: Why is creating one thread per task not always a good design?
**Answer**: It gives poor control over system resources

---

### Q10: In a thread pool, if all threads are busy, new tasks usually:
**Answer**: Wait in a queue

---

### Q11: What does `Executors.newFixedThreadPool(3)` create?
**Answer**: A pool with 3 reusable threads

---

### Q12: What does `executor.submit(task)` do?
**Answer**: Submits task to thread pool

---

### Q13: What does `shutdown()` mean?
**Answer**: Stop accepting new tasks and finish submitted tasks

---

### Q14: Does `shutdown()` immediately stop all running tasks?
**Answer**: No

---

### Q15: Which class is commonly used to create a fixed thread pool?
**Answer**: `Executors`

---

### Q16: What does ExecutorService do?
**Answer**: Manages task execution using threads

---

### Q17: Why should we call `executor.shutdown()`?
**Answer**: To properly close the thread pool

---

### Q18: Which interface is used when a task does not return a result?
**Answer**: Runnable

---

### Q19: In a thread pool, which component manages thread pooling architecture?
**Answer**: ExecutorFramework

---

### Q20: What is the problem with creating too many threads manually?
**Answer**: All of the above (high memory usage, context switching overhead, system overhead)

---

### Q21: A thread pool is used to:
**Answer**: All of the above (reduce creation overhead, control max threads, reuse threads for tasks)

---

### Q22: Which interface is used when a task returns a result?
**Answer**: Callable

---

### Q23: What does `future.get()` do?
**Answer**: Waits for result and returns it

---

### Q24: What does `executor.shutdown()` do?
**Answer**: Stops accepting new tasks and finishes submitted tasks

---

### Q25: What are the two interfaces representing task definitions?
**Answer**: Runnable, Callable

---

### Q26: Which interface is used when a task needs to return a result?
**Answer**: Callable

---

### Q27: Why is merge sort suitable for multithreading?
**Answer**: Left and right halves can be sorted independently

---

### Q28: What does Future mean in Java concurrency context?
**Answer**: The result will be an Integer (or specific type based on generics)

---

### Q29: What does `future.get()` do?
**Answer**: Waits for result and returns it
