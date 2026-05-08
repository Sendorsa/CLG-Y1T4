# Lecture 2: Process Management and Context Switch

> **Topic:** Process States, PCB, Context Switching, Process Creation (fork)
> **Key Terms:** Process, PCB, Running State, Ready State, Waiting State, Context Switch, fork(), Time Slicing, Process Scheduling

---

## 0. What is an Operating System?

An **Operating System (OS)** is system software that acts as an **interface between the user and the computer hardware**, managing all system resources. It acts as the **"boss"** of the computer, ensuring smooth execution of programs, memory allocation, and hardware interaction.

- Without an OS, your code is just text; programs cannot execute, allocate memory, or access files.
- Users do not interact with hardware directly; instead, they interact with the OS (via UI or programs), which then translates requests to the hardware.

---

## 0.1 Core Functions of an OS

| Function | What it Does |
|------|------|
| **Memory Management** | Allocates, tracks, and manages RAM. Decides which program gets memory, how much, and when to free it. Ensures each program receives its own isolated memory space. |
| **Process Management** | Creates, schedules, executes, and terminates processes. Controls which program runs on the CPU, for how long, and ensures fair allocation across multiple programs. |
| **Device Management** | Acts as a middle layer between software and complex hardware using **Device Drivers**, which translate instructions for specific devices like printers or monitors. |
| **File Management** | Organizes data into directories, tracks file storage locations, and handles read/write permissions. |
| **Protection & Security** | **Protection** controls internal interactions, ensuring one program's memory or processes do not interfere with another's. **Security** acts as an external defense, protecting the entire system from unauthorized users, hackers, and malware via authentication and encryption. |
| **User Interface (UI)** | Provides interaction methods: **Command Line Interface (CLI)**, **Graphical User Interface (GUI)**, and **Batch processing**. |

---

## 0.2 System Calls

Programs cannot access hardware directly due to **security and stability risks**. **System Calls** act as the bridge or interface through which a user-level program requests specific services from the OS.

- **Execution flow:** User program → System Call → OS kernel → Hardware
- **Examples:**
  - `new int[100]` requests memory allocation from the OS
  - `System.out.println()` requests output handling via the OS

Without system calls, programs would have no way to request resources or services from the operating system.

---

## 0.3 Process Memory Layout

A process is made up of several components in memory:

| Component | Description |
|-----------|-------------|
| **Text Section** | The executable code (machine instructions) |
| **Data Section** | Global and static variables |
| **Heap** | Dynamically allocated memory (allocated at runtime) |
| **Stack** | Function calls, local variables, and return addresses |

---

## 0.4 Key Concepts

### Multitasking

**Multitasking** is the ability of an OS to handle multiple applications running simultaneously by rapidly switching the CPU between processes, creating the illusion that they are all running at the same time.

---

## 0.1 Memory Basics: Stack vs. Heap

These two terms describe **how memory is allocated** — a key concept before diving into process management.

| Aspect | **Stack** | **Heap** |
|--------|-----------|----------|
| **What it stores** | Local variables, function parameters, return addresses | Dynamically allocated memory (e.g., via `malloc()`, `new`) |
| **Allocation** | Automatic — managed by the compiler | Manual — programmer allocates/deallocates |
| **Size** | Fixed, small (e.g., 8MB default) | Large, limited by available RAM |
| **Speed** | Very fast (LIFO, hardware-supported) | Slower (requires OS lookup) |
| **Example** | `int x = 5;` inside a function | `int *x = malloc(sizeof(int));` |

**Analogy:**
- **Stack** — like a stack of plates at a restaurant: you add/remove from the top, automatic and fast.
- **Heap** — like a storage locker: you explicitly request space, use it, then return it.

---

## 1. Process States

When a program is loaded into memory and begins execution, it transitions through different **states** depending on what the CPU and OS are doing with it.

### The Three Core States

| State | What it Means |
|-------|--------------|
| **Running** | The process is currently being executed by the CPU. |
| **Ready** | The process is loaded in memory and waiting for its turn on the CPU. It has everything it needs — just waiting for the CPU to be available. |
| **Waiting (Blocked)** | The process cannot continue because it is waiting for an event (e.g., I/O completion, a file to load, user input). It is not waiting for the CPU specifically. |

### Additional Lifecycle States

The full **5-state process lifecycle** also includes two boundary states:

| State | Description |
|------|------|
| **New** | A new process arrives, and the OS creates its PCB. The process is being created but not yet ready to execute. |
| **Terminated** | Execution finishes (or is aborted), and the OS removes the PCB. All resources are freed. |

**Full lifecycle:** `New → Ready → Running → (Waiting → Ready) → Terminated`

#### State Transitions

```
          +--------+     I/O req.     +----------+
          | Ready  | ----------------> | Waiting  |
          +--------+                   +----------+
               ^                              |
               |      I/O complete            | event done
               | <----------------------------+
               |
        CPU free (time slice expired)
               |
               v
          +--------+
          | Running|
          +--------+
               |
        time slice expires
               |
               v
          +--------+
          | Ready  |  (back in queue)
          +--------+
```

**Key point:** A process goes from **Running** back to **Ready** (not directly to Waiting) when its time slice expires. This ensures fairness — no process can hog the CPU.

### Ready Queue

The **ready queue** is the set of all processes in main memory that are ready to execute and are waiting for the CPU. The scheduler selects the next process from this queue when the CPU becomes free.

---

## 2. Process Control Block (PCB)

### What is a PCB?

Every process has a **PCB** — a data structure maintained by the OS that stores all the information needed to manage that process.

### What does a PCB contain?

| PCB Field | Purpose |
|-----------|---------|
| **Process State** | Current state: Running, Ready, or Waiting |
| **Program Counter** | Address of the next instruction to execute |
| **CPU Registers** | Values of all registers when the process was last running |
| **CPU Scheduling Info** | Priority, scheduling queue pointers |
| **Memory Management Info** | Base/limit registers, page tables |
| **Accounting Info** | CPU time used, time limits, process ID |
| **Process ID (PID)** | Unique identifier assigned to every process when created. Used by the OS to distinguish and manage all processes. |
| **I/O Status Info** | List of open files, allocated devices |

### Why is the PCB Important?

The PCB is the **bridge** between the OS's view of a process and the actual hardware state. When a context switch happens:

1. The OS **saves** the current process's register values into its PCB.
2. The OS **loads** the next process's saved values from its PCB into the CPU registers.

**Without the PCB, the OS could not resume a process where it left off.**

---

## 3. Context Switching

### What is a Context Switch?

A **context switch** is the mechanism by which the OS saves the state of the currently running process and restores the state of another process, allowing the CPU to switch between processes.

### Steps in a Context Switch

1. An **interrupt** (a signal to the processor emitted by hardware or software indicating an event needing immediate attention) is triggered — in this case, a **timer interrupt** when a process's time slice expires.
2. The OS **saves** the current process's context (registers, program counter, state) into its PCB.
3. The OS **selects** the next process from the ready queue (via the scheduler).
4. The OS **loads** the selected process's context from its PCB into the CPU.
5. Execution resumes in the new process.

### The Analogy from the Lecture

**Cooking analogy:**
- Imagine you are cooking dal (a dish). You put it on the stove.
- Before it is done, someone calls you on the phone. You step away, but you **remember** exactly where you were — which spice you added, how long it has been cooking.
- When you return, you **pick up exactly where you left off**.

This is a context switch — you save your "state" (where you are in the recipe), switch to another task (phone call), and resume the cooking later.

### Overhead of Context Switching

- A context switch is **pure overhead** — the CPU does no useful work during it.
- The OS only performs a context switch because it needs to share the CPU among multiple processes.
- The speed of context switching depends on:
  - How much data needs to be saved/restored in the PCB
  - Hardware support (some CPUs have specialized instructions)
  - Memory speed

### Context Switch in a Fork Scenario

When a process calls `fork()`:
1. A **new process** is created (child process).
2. The child gets its **own PCB** and its own copy of the parent's memory.
3. Both the parent and child continue execution — but from the **same point** (the line after `fork()`).
4. Each has its **own program counter**, **own registers**, and **own context**.
5. They run **independently** of each other.

---

## 4. Process Creation: `fork()`

### How Processes Are Created

Processes are created using the **`fork()`** system call. When a process (the **parent**) calls `fork()`:

| Aspect | Detail |
|--------|--------|
| **What happens** | A new process (the **child**) is created |
| **Memory** | The child gets a copy of the parent's memory |
| **PCB** | The child gets its own PCB |
| **Registers** | The child's registers are initialized with the parent's register values |
| **Execution** | Both parent and child continue from the same point (line after `fork()`) |
| **Independence** | They run independently; changes in one do not affect the other |

### The Demo from the Lecture

The lecturer wrote a C program with `fork()` and `printf()`:

```c
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>

int main() {
    printf("Before fork\n");

    pid_t pid = fork();

    if (pid == 0) {
        printf("Child process\n");
    } else if (pid > 0) {
        printf("Parent process\n");
    }

    return 0;
}
```

### Key Observations from the Demo

- **Both parent and child print output** — `fork()` creates a new process, and both continue executing.
- **Each has its own PCB** — they are completely independent processes.
- **The child inherits the parent's memory** — it starts with a copy of the parent's variables and state.
- **`fork()` returns different values** in each process:
  - **0** in the child (so the child knows it's the child)
  - **Child's PID** in the parent (so the parent knows the child's ID)
  - **-1** if fork failed

### Why `fork()` is Important

- It is the **foundation of process creation** on Unix-like systems.
- It enables the OS to **run multiple processes** from a single program.
- It is used extensively in shells (e.g., Bash) to run commands.

---

## 4.5 Stack vs Heap Memory

Memory is divided into two main regions:

| Region | Allocation Type | Used For |
|--------|----------------|----------|
| **Stack** | Static allocation | Variable declarations, function calls. Memory is managed automatically. |
| **Heap** | Dynamic allocation | Pointers, objects. Requires OS interaction for memory management. |

**Key difference:** The stack is managed automatically and handles function call frames and local variables. The heap is used for dynamic data that needs to outlive a function call and requires explicit OS-level allocation.

---

## 5. CPU Scheduling Basics

### Why Scheduling is Needed

- The number of processes **exceeds** the number of CPU cores.
- Not all processes can run simultaneously (even with multiple cores).
- The OS must decide **which process runs when**.

### The Scheduler

The **scheduler** is a core OS component responsible for deciding which process gets the CPU and when. It uses scheduling algorithms to make these decisions.

### Scheduling Algorithms

| Algorithm | How It Works | Pros | Cons |
|-----------|-------------|------|------|
| **FCFS** (First Come First Serve) | Processes are executed in the order they arrive | Simple, no starvation | Can cause long wait times (convoy effect) |
| **SJF** (Shortest Job First) | The process with the shortest estimated runtime is scheduled next | Minimizes average wait time | Hard to predict burst time; long jobs may starve |
| **Priority Scheduling** | Each process is assigned a priority; highest priority runs first | Critical tasks get CPU when needed | Low-priority processes may starve |
| **Round Robin** | Each process gets a fixed time quantum in circular order | Fair allocation; good for time-sharing | Overhead if quantum is too small; poor if too large |

### Preemption Model

Scheduling is categorized by how a process can be removed from the CPU:

| Model | Description | Example Algorithms |
|-------|-------------|-------------------|
| **Non-preemptive** | Once the CPU is allocated to a process, it cannot be taken away until the process releases it voluntarily (finishes or blocks) | FCFS, SJF (non-preemptive) |
| **Preemptive** | The OS can forcibly take the CPU away from a process, even if it hasn't finished, to allocate it to a higher-priority process | Round Robin, Priority (preemptive), SJF (shortest remaining time first) |

This distinction determines **how much control the OS has** over CPU allocation and directly affects fairness, responsiveness, and system throughput.

---

### Scheduling Concepts from the Lecture

| Concept | Description |
|---------|-------------|
| **Time Slicing** | Each process gets a fixed amount of CPU time (a "slice") before being preempted |
| **Round-Robin** | Processes are scheduled in a circular queue, each getting equal time slices |
| **Fairness** | No process can monopolize the CPU; all get a fair share |
| **Preemption** | The OS forcibly takes the CPU away when a time slice expires |

### The Worker Analogy

- **4 CPU cores = 4 workers**
- **10 processes = 10 tasks**
- Workers handle 4 tasks simultaneously.
- The OS manages the remaining 6 tasks in a queue.
- When a worker finishes, the OS assigns the next task.
- This prevents any one task from monopolizing the workers.

### CPU Core

A **core** is an individual processing unit within a CPU capable of executing tasks. Modern CPUs may have multiple cores, each able to independently process instructions. More cores = more processes can run truly simultaneously.

### Time Quantum

- The **time quantum** (or time slice) is the fixed amount of CPU time allocated to each process in Round Robin scheduling.
- The scheduler determines the quantum size.
- **If too small:** Excessive context switching overhead — the CPU spends more time switching than doing useful work.
- **If too large:** The system behaves like FCFS, losing the benefits of time-sharing and responsiveness.
- Choosing an optimal quantum is critical for **efficient CPU utilization**.

### Starvation

- **Starvation** occurs when a low-priority process never gets CPU time because higher-priority processes keep getting scheduled instead.
- This can happen in **Priority Scheduling** when new high-priority processes continuously arrive.
- **Solution:** **Aging** — gradually increase the priority of processes that wait in the ready queue over time.

### Importance of Scheduling

Effective CPU scheduling aims to:

- **Enhance CPU utilization** — keep the CPU busy, never idle.
- **Maximize throughput** — complete as many processes per unit time as possible (e.g., a 100-core server runs thousands of tasks per minute).
- **Reduce wait times** — minimize the time processes spend in the ready queue.
- **Prevent starvation** — ensure all processes eventually get a turn.
- **Support multitasking** — allow the OS to handle many processes concurrently on a single CPU or multiple cores.

---

## 6. Process Priority

Each process is assigned a **priority** value. The scheduler uses this to decide which process gets the CPU next.

### How Priority Works

- **Higher priority** processes get CPU time **before** lower priority ones.
- **Lower priority** processes still get CPU time, but **after** higher-priority processes.
- **Why?** Some tasks are more urgent (e.g., a process handling user input vs. a background backup).

### Why Does This Matter?

- Without priorities, all processes would be treated equally — which may not be efficient or appropriate for all workloads.
- Priorities ensure that **critical tasks** get the CPU when needed.

---

## 7. OS Types (Mentioned in Lecture)

The lecturer briefly mentioned that the class will cover **different types of OS**, noting that this topic is largely theoretical. Detailed notes on OS types will be provided separately.

Types typically covered include:
- **Batch OS**
- **Time-Sharing OS**
- **Distributed OS**
- **Network OS**
- **Real-Time OS**

These will be covered in detail when the topic is formally addressed.

---

## 8. Summary Table: Process Management Concepts

| Concept | What it Does | Why it Matters |
|---------|-------------|----------------|
| **Process States** | Tracks what a process is doing (Running, Ready, Waiting) | Helps the OS make scheduling decisions |
| **PCB** | Stores process metadata and state | Enables context switches to work correctly |
| **Context Switch** | Saves current process state, loads next process state | Allows multiple processes to share the CPU |
| **fork()** | Creates a new process from an existing one | Foundation of Unix process creation |
| **Time Slicing** | Gives each process a fixed CPU time slot | Ensures fairness and responsiveness |
| **Preemption** | Forcibly takes the CPU from a process | Prevents CPU hogging |
| **Priority** | Assigns importance to processes | Ensures critical tasks run first |

---

## 9. Course Information (from Class 1)

### Project
- **Build your own OS Shell** (like Bash or Command Prompt) — **10% of total grade**

### Exam Pattern
- **MCQs**
- **Numericals** (memory calculation, CPU scheduling, disk access)
- **Coding** (simple programs in Java, C++, or Python)

### Recommended Resources
- **Book:** "Three Pieces of OS" — focuses on concurrency
- **Course:** Udemy course on OS fundamentals (link shared by lecturer)
- **Demo tool:** `fs_usage` on macOS — observe system calls in real-time

---

## 10. Glossary of Key Terms

| Term | Definition |
|------|------|
| **Process** | A program actively executing on the CPU |
| **Process ID (PID)** | Unique identifier assigned to every process upon creation. Allows the OS to distinguish and manage all processes. |
| **Process Control Block (PCB)** | Data structure storing all process metadata: state, registers, program counter, scheduling info |
| **Running State** | The process is currently executing on the CPU |
| **Ready State** | The process is in memory and waiting for the CPU |
| **Waiting State** | The process is blocked, waiting for an event (I/O, etc.) |
| **Context Switch** | Saving the current process's state and restoring another's |
| **Time Slice** | The fixed amount of CPU time given to each process |
| **Preemption** | Forcibly taking the CPU away from a process after its time slice |
| **fork()** | System call that creates a new process (child) from an existing one (parent) |
| **Program Counter** | Register that holds the address of the next instruction to execute |
| **CPU Scheduling** | The OS's method of deciding which process runs on the CPU and when |
| **Round-Robin** | Scheduling algorithm where each process gets equal time slices in a circular queue |
| **FCFS** (First Come First Serve) | Scheduling algorithm that executes processes in the order they arrive |
| **SJF** (Shortest Job First) | Scheduling algorithm that executes the process with the shortest estimated runtime first |
| **Priority Scheduling** | Scheduling algorithm where each process is assigned a priority and highest priority runs first |
| **Time Quantum** | Fixed CPU time allocated to each process in Round Robin scheduling |
| **Starvation** | When a low-priority process never gets CPU time because higher-priority processes keep running |
| **Scheduler** | Core OS component that decides which process runs on the CPU and when |
| **Stack** | Memory region for static allocation — handles variable declarations and function calls |
| **Heap** | Memory region for dynamic allocation — used for pointers and objects requiring OS interaction |
| **Fairness** | Ensuring no process monopolizes the CPU |
| **Process Priority** | A value assigned to a process that determines its importance in scheduling |
| **Timer Interrupt** | Hardware interrupt that fires when a time slice expires, triggering a context switch |

---

---

## 11. Process Example

A real-world example of processes:

- **Chrome browser** is not a single program — it is a collection of **multiple processes** (one per tab, one for the main process, etc.).
- The OS manages all these processes independently, allocating CPU time and memory to each.

---

## 12. Future Learning Topics

The next class will likely cover:
- **CPU scheduling algorithms** in detail (FCFS, SJF, Priority Scheduling, etc.)
- **Process synchronization** (semaphores, mutexes, critical sections)
- **Deadlock** (conditions, prevention, detection)
- **Shared memory** and inter-process communication (IPC)
- **Virtual memory** in depth
- **Types of OS** (theoretical overview)
