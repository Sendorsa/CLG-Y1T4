# Lecture 1: Introduction to Operating Systems

> **Topic:** Intro to OS, Functions of OS, System Calls
> **Key Terms:** OS, Bridge, Resource Manager, Memory Management, Process Management, Time Slicing, System Calls, Device Drivers, File Management, Security, Accounting

---

## 1. What is an Operating System?

### Definition
An **Operating System (OS)** is system software that acts as an **intermediary** (bridge) between:
- The **user/application programs** (e.g., Chrome, Word, a Java program)
- The **computer hardware** (CPU, RAM, disk, keyboard, monitor, etc.)

Common examples: **Windows**, **Linux**, **macOS**.

Without an OS, every program would have to directly communicate with every piece of hardware — a chaotic, error-prone, and nearly impossible task.

### Key Roles of an OS
| Role | Description |
|------|------------|
| **Resource Manager** | Manages hardware and resources, providing a seamless interface for the user |
| **User Interface** | Offers interfaces: **GUI** (Graphical), **CLI** (Command Line), **TUI** (Terminal), **Batch** |

| Interface Type | Definition |
|------|------|
| **Graphical User Interface (GUI)** | A user-friendly interface using icons, windows, and graphics for user interaction (e.g., Windows desktop, macOS Finder) |
| **Command Line Interface (CLI)** | An interface where the user interacts with the OS by typing text commands (e.g., Bash, Command Prompt) |
| **Security/Protection** | Isolates processes and enforces access control |

### Definitions

#### Hardware
**Physical components** of a computer: CPUs, GPUs, Memory, Screens, Keyboards, **Microphones**, etc.

#### Software
**Programs that run on hardware** to give users the ability to perform tasks (e.g., Word, Browsers, Games).

---

### What Hardware Needs: Protocol Communication

Computers have many different parts, each needing to receive and send messages in **specific formats**:

| Device | Communication Protocol |
|--------|----|
| **Mouse** | Serial protocol |
| **Screen** | HDMI |

If you install a new screen on your laptop, you need a way to tell it how to send and receive messages — this is handled by the OS translating between devices.

---

### Core Concept: The Bridge Analogy
```
User / Program  -->  OS  -->  Hardware
```
- The user sends a request (e.g., "open this file", "play this video").
- The OS receives this request, translates it, and forwards the correct commands to the appropriate hardware.
- The hardware performs the work and sends results back through the OS to the user.

**Real-world analogy:**
- **Customer** = User/Program
- **Waiter** = Operating System
- **Kitchen** = Hardware
The customer does not walk into the kitchen; they talk to the waiter, who handles everything behind the scenes.

---

## 2. Major Functions of an Operating System

An OS manages several critical resources. Here are the six major functions covered in the lecture:

---

### 2.1 Memory Management

#### What it does
The OS manages the computer's **RAM (Random Access Memory)** — the temporary workspace where active programs run.

#### Key responsibilities:
- **Allocation:** When a program starts, the OS allocates a portion of RAM to it. The OS tracks which memory blocks belong to which program. In C, this is done via functions like `malloc()` and `calloc()` which request memory dynamically, check availability, and free it when done.
- **Isolation:** The OS marks memory regions as **"used"** for a specific program so that one program cannot accidentally or maliciously overwrite another program's memory.
- **Deallocation:** When a program closes, the OS frees that memory, marking it as "available" for future use.

#### Example
When you open Chrome, the OS finds free memory blocks, marks them as "used by Chrome," and tells Chrome to use that space. When you close Chrome, the OS reclaims that memory.

#### Concept Mentioned: Virtual Memory
- Virtual memory is a technique where the OS uses part of the hard disk as an extension of RAM.
- When RAM is full, less-used memory pages are moved to disk, freeing up physical RAM for active programs.
- This gives the illusion of having more RAM than physically exists.

---

### 2.2 Process Management

#### Program vs. Process (Important distinction!)
| Program | Process |
|---------|---------|
| A static file (e.g., `chrome.exe`) sitting on disk | A **running instance** of that program |
| No activity, no resource usage | Actively consuming CPU, memory, and I/O |
| Does not "execute" | Is being executed by the CPU |

**Key takeaway:** A program is passive; a process is active. The OS manages **processes**, not programs.

#### CPU Cores as "Workers"
- A CPU core is like a **worker** that can execute one task at a time.
- If you have 4 CPU cores, you have 4 workers who can each handle one process simultaneously.
- But what if you have more processes than cores?

#### CPU Scheduling and Context Switching
- The OS uses **CPU scheduling** to decide which process runs on which core and when.
- **Context switching** saves the current state of a process (registers, program counter, etc.) and restores the state of another, enabling seamless switching between processes.
- The OS stores this saved state in a data structure called the **Process Control Block (PCB)** for each process. The PCB holds all the information the OS needs to manage a process: its state, program counter, registers, and resource usage.
- Each process gets a small fixed amount of CPU time (**time slicing**, or **round-robin scheduling**).
- After its time is up, the OS **preempts** the process (takes the CPU away) and gives it to the next process in line via context switch.
- This cycle repeats so quickly that it creates the **illusion of parallelism** — everything appears to run simultaneously to the user.

#### Fairness (Prevention of CPU Hogging)
- Without fairness, the first process could "hog" the CPU indefinitely, starving all other processes.
- The OS enforces **fairness** by forcibly taking the CPU away from a process after its time slice expires, regardless of whether it is done.
- This ensures all processes get a fair share of CPU time.

**Lecture analogy:**
- Imagine 4 workers (CPU cores) and 10 tasks (processes).
- The workers handle 4 tasks. The OS manages the remaining 6.
- It gives worker 1: task A, worker 2: task B, etc.
- When a worker finishes early, the OS assigns the next waiting task.
- This prevents any one task from monopolizing the workers.

---

### 2.3 I/O Device Management

#### What it does
The OS manages all input and output devices (keyboard, mouse, monitor, printer, speakers, USB drives, etc.).

#### Device Drivers
- **Device drivers** are specialized software components (intermediaries) that allow the OS to communicate with specific hardware.
- Each type of hardware (printer, GPU, network card, etc.) requires its own driver.
- The OS does not need to know the exact internal workings of a printer. It just tells the **printer driver**: "print this text." The driver handles the hardware-specific details.

**Key takeaway:** Device drivers abstract hardware complexity. The OS talks to drivers; drivers talk to hardware.

---

### 2.4 File Management

#### What it does
The OS allows you to save data (documents, images, videos) on your computer's storage drive and retrieve it later.

- **The problem without an OS:** Data on a drive is just a bunch of **ones and zeros** stored on tiny **magnetic particles**. Without the OS, you cannot organize or make sense of this data.
- **The OS solution:** It groups these ones and zeros into **files** and **folders**, giving you the ability to organize, open, and edit them.

#### Key responsibilities:
- **Hierarchy:** Files are organized in a tree-like directory structure (folders within folders).
- **Default paths:** The OS knows where to look when a user says "open the file" without specifying the exact location (e.g., home directory, current working directory).
- **Retrieval & Storage:** When a program requests a file, the OS locates it on disk and provides the data. When saving, the OS finds free disk space and stores the data.

#### Example
When you type `open document.txt`, the OS:
1. Checks the current working directory (default path).
2. Searches for `document.txt`.
3. Reads the file from disk and provides its contents to the requesting program.

---

### 2.5 Security and Protection

#### What it does
The OS protects the system and its users from unauthorized access and interference.

#### Three levels of security:
1. **Access Control (Permissions):**
   - Files and programs can have permissions (e.g., read-only, read-write, execute).
   - Example: A web browser should not be able to access your personal documents. The OS enforces this.
2. **Multi-User Isolation:**
   - On multi-user systems, the OS ensures that one user cannot access or interfere with another user's files or processes.
   - Each user gets their own "space" on the machine.
   - **Multi-User Environment:** Allows multiple users to access and use a computer system simultaneously. Each user has their own account, files, and processes, isolated from others.
   - **Process Isolation:** The OS isolates each process's memory space so one application cannot access another's memory without explicit consent. If you install an app on your phone, it must **request permission** to access your files, camera, or location.

#### Example
- If you install an app on your phone, it must **request permission** to access your files, camera, or location.
- The OS decides whether to grant or deny that request based on security policies.
- If you try to open a file you don't have permission for, the OS blocks the access and may show an error.

---

### 2.6 Accounting

#### What it does
The OS tracks which program or user is using which resource, for how long, and in what quantity.

#### Key uses:
- **Resource Tracking:** How much CPU time did a process use? How much memory? How much disk I/O?
- **Billing:** In cloud computing, providers (AWS, Azure) use OS-level accounting to bill customers based on actual resource consumption.
- **Versioning:** The OS can track when a file was created, last modified, and who modified it (timestamps and metadata).

#### Example
- AWS charges you based on how much compute and storage you use. The OS on their servers tracks this for each customer.
- File properties (created: Jan 1, modified: Mar 15) are maintained by the OS's accounting layer.

---

## 3. System Calls

### What is a System Call?

A **system call** is the mechanism by which a **user program requests a service from the operating system**.

#### Key points:
- Programs **cannot** directly access hardware (for security and stability).
- Instead, programs make **system calls** — formal requests to the OS to perform hardware operations (e.g., read from disk, write to disk, allocate memory, send network data).
- The OS validates the request, checks permissions, and then performs the operation on behalf of the program.

### How System Calls Work (Step by Step)
1. A program (e.g., Java) wants to write data to a file.
2. The program makes a system call (e.g., `write()` or `open()`).
3. The OS receives the request in **kernel mode** (a privileged execution mode).
4. The OS checks if the program has permission to perform this operation.
5. The OS translates the request into hardware-specific instructions.
6. The hardware performs the operation (e.g., writes data to disk).
7. The result is returned through the OS back to the program.

### System Call Examples from the Lecture Demo

#### The Demo:
```java
// Java code
FileWriter fw = new FileWriter("demo.txt");
fw.write("hello OS");
fw.close();
```

#### What Happened Under the Hood (via `fs_usage`):
The lecturer used macOS's `fs_usage` tool (filtered with `grep demo.txt`) to observe system calls made during the file write operation:

| System Call | What it does |
|-------------|-------------|
| `getattrlist` | Gets file attributes (size, permissions, timestamps) |
| `Rd data` | Reads data from the file |
| `Wr data` | Writes data to the file |
| `get_file_path` | Retrieves the full path of the file |

**Key observations:**
- Every time a Java program writes to a file, multiple system calls happen behind the scenes.
- The Java `FileWriter` class hides all this complexity from the programmer.
- The `fs_usage` tool lets us see the raw interaction between programs and the OS.

### Why This Matters
- System calls are the **only way** programs interact with hardware.
- Understanding system calls helps understand how high-level code (Java, Python, etc.) translates to actual hardware operations.
- They form the boundary between **user space** (where programs run) and **kernel space** (where the OS runs).

---

## 4. Summary Table: OS Functions at a Glance

| Function | What it Manages | Key Concept |
|----------|----------------|-------------|
| Memory Management | RAM allocation | Isolation, Virtual Memory |
| Process Management | CPU execution | Program vs Process, Time Slicing, Fairness |
| **Device Driver** | Hardware devices | Device Drivers |
| File Management | Data storage | Hierarchy, Default Paths |
| Security/Protection | Access control | Permissions, Isolation |
| Accounting | Resource tracking | Billing, Versioning |

---

## 5. Course Information

### Structure
- **Heavy on theory** — expect detailed conceptual questions.
- **Demos included** — practical observation of OS behavior (e.g., `fs_usage` tool).

### Exam Pattern
- **MCQs** (Multiple Choice Questions)
- **Numericals** — likely related to memory calculation, CPU scheduling, disk access
- **Coding** — simple programs in Java, C++, or Python
- **Project** — Build your own OS Shell (**10% of total grade**)

### Project Details
- You will build an **Operating System Shell** (like Bash on Linux or Command Prompt on Windows).
- This will teach you how shells interact with the OS via system calls.

---

## 6. Glossary of Key Terms

| Term | Definition |
|------|------------|
| **Operating System (OS)** | System software that bridges programs and hardware, managing all system resources |
| **Bridge Analogy** | OS sits between user/program and hardware, translating requests |
| **RAM** | Temporary, fast memory where active programs run |
| **Virtual Memory** | Using disk space as an extension of RAM |
| **Program** | A passive, static set of instructions on disk |
| **Process** | A program actively executing on the CPU |
| **CPU Core** | A processing unit (worker) that executes one process at a time |
| **Time Slicing** | Giving each process a small, fixed time on the CPU before switching to the next |
| **Preemption** | Forcibly taking the CPU away from a process after its time slice expires |
| **Fairness** | Ensuring all processes get equal opportunity to use the CPU |
| **Device Driver** | Software intermediary between the OS and a specific hardware device |
| **System Call** | A program's formal request for a service from the OS |
| **Kernel Mode** | Privileged execution mode where the OS runs |
| **User Space** | Isolated memory region where user programs run |
| **Isolation** | Preventing programs from accessing each other's resources |
| **Command Line Interface (CLI)** | An interface where the user interacts with the OS by typing text commands |
| **Accounting** | Tracking resource usage for billing and monitoring |
| **Multi-User Environment** | Allows multiple users to access and use a computer system simultaneously |
| **Process Control Block (PCB)** | Data structure holding process information (state, registers, program counter, resource usage) |

---

## 7. Future Learning Topics

The next class will cover:
- **Context switching** (deep dive)
- **CPU scheduling algorithms** (FCFS, SJF, Round-Robin, etc.)
- **Shared memory and virtual memory** in detail
- **Multi-user environments** and their complexities
