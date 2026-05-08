# CPU Scheduling -- Detailed Study Notes

---

## Part 1: Theory

### A. Core Concepts

| Concept | Explanation |
|---|---|
| **CPU** | Central Processing Unit -- the "brain" of the computer that executes instructions |
| **CPU Scheduling** | The process of selecting a process from the ready queue to run on the CPU |
| **Scheduler** | OS component that manages the ready queue and decides which process runs, for how long, and when to stop |
| **Job Queue** | All processes currently in the system |
| **Ready Queue** | Processes loaded into main memory, waiting for the CPU |
| **Process Table** | Data structure storing process info (state, PC, registers, memory limits, etc.) |

**Goal of CPU Scheduling:**
- Maximize CPU utilization (keep the CPU busy doing useful work)
- Ensure fairness (every process eventually gets a turn)
- Optimize overall system performance

**State Transitions that trigger scheduling:**

| Transition | Reason |
|---|---|
| Running $\rightarrow$ Waiting | Process needs I/O or user input |
| Running $\rightarrow$ Ready | Time slice expired (interrupted) |
| Waiting $\rightarrow$ Ready | I/O or event completed |
| Running $\rightarrow$ Terminate | Process finished execution |

**Context Switch:**
- When the CPU switches from one process to another, the OS saves the state of the old process and loads the state of the new one
- During this time, **no useful work is done** -- it is pure overhead
- Includes: saving/restoring registers, memory maps, page tables, process control block (PCB)

### C. Process Lifecycle

A process goes through the following states during its lifetime:

| State | Description |
|---|---|
| **New** | Process is being created |
| **Ready** | Process is loaded in memory and waiting for CPU allocation |
| **Running** | Instructions are being executed |
| **Waiting (Blocked)** | Process is waiting for some event (e.g., I/O completion) |
| **Terminated** | Process has finished execution |

**State Transitions:**

| Transition | Reason |
|---|---|
| New $\rightarrow$ Ready | Process is created and admitted to the system |
| Ready $\rightarrow$ Running | Scheduler selects process for CPU |
| Running $\rightarrow$ Waiting | Process needs I/O or waits for an event |
| Running $\rightarrow$ Ready | Time slice expired (preempted) |
| Waiting $\rightarrow$ Ready | I/O or event completed |
| Running $\rightarrow$ Terminated | Process finishes execution |

---

### B. Key Terminology (Time Metrics)

| Term | Symbol | Meaning | Formula |
|---|---|---|---|
| **Arrival Time** | $A_T$ | When the process enters the ready queue | Given |
| **Burst Time** | $B_T$ | CPU time required to complete the process | Given |
| **Completion Time** | $C_T$ | When the process finishes execution | From Gantt chart |
| **Turn Around Time** | $T_T$ | Total time from arrival to completion | $T_T = C_T - A_T$ |
| **Waiting Time** | $W_T$ | Total time spent waiting in the ready queue | $W_T = T_T - B_T$ |
| **Response Time** | $R_T$ | Time from submission until first execution | From Gantt chart |

**Worked Example:**

| Process | $A_T$ | $B_T$ | $C_T$ | $T_T$ | $W_T$ |
|---|---|---|---|---|---|
| P1 | 0 | 7 | 10 | 10 (10-0) | 3 (10-7) |
| P2 | 2 | 4 | 7 | 5 (7-2) | 1 (5-4) |
| P3 | 4 | 1 | 8 | 4 (8-4) | 3 (4-1) |
| P4 | 6 | 3 | 11 | 5 (11-6) | 2 (5-3) |

**Average Waiting Time** = $(3 + 1 + 3 + 2) / 4 = 2.25$
**Average Turn Around Time** = $(10 + 5 + 4 + 5) / 4 = 6.0$

---

### C. Preemptive vs Non-Preemptive Scheduling

| Feature | Non-Preemptive | Preemptive |
|---|---|---|
| **CPU Control** | Process keeps CPU until it finishes or voluntarily yields | OS can forcibly take the CPU away |
| **When scheduling happens** | Only when process finishes or switches to waiting | Also when time slice expires or higher-priority process arrives |
| **Interrupt handling** | Process must finish | Can be interrupted by timer or events |
| **Examples** | FCFS, SJF (non-preemptive) | Round Robin, SJF (preemptive/SRTF), Priority (preemptive) |
| **Overhead** | Lower (fewer context switches) | Higher (more context switches) |
| **Best for** | Batch processing | Interactive / time-sharing systems |

---

### D. Scheduling Criteria

| Criterion | Description | Goal |
|---|---|---|
| **CPU Utilization** | Fraction of time the CPU is busy (0 to 1 or 0% to 100%) | Maximize |
| **Throughput** | Number of processes completed per unit time | Maximize |
| **Turn Around Time** | Total time from arrival to completion | Minimize |
| **Waiting Time** | Time spent in ready queue (not executing) | Minimize |
| **Response Time** | Time from submission until first execution | Minimize |

---

### E. Scheduling Algorithms

> **Exam tip**: Q1 from revision notes — SRTF (Shortest Remaining Time First) gives the least average waiting time. It always selects the process with the shortest remaining time, minimizing wait for all processes. SJF also gives low wait time but SRTF improves on it by allowing preemption for newly arriving short processes.

#### 1. FCFS (First Come First Serve)

**How it works:**
- Processes are served in the exact order they arrive in the ready queue
- Simple queue: first in line gets served first

**Type:** Non-Preemptive

**Example (Arrival Order: P1, P2, P3, P4):**

| Process | $A_T$ | $B_T$ | Gantt Chart |
|---|---|---|---|
| P1 | 0 | 7 | [====P1====] |
| P2 | 2 | 4 |           [==P2==] |
| P3 | 4 | 1 |               [P3] |
| P4 | 6 | 3 |                  [==P4==] |

Timeline: `P1(0-7) | P2(7-11) | P3(11-12) | P4(12-15)`

**Pros:**
- Simple to understand and implement
- No starvation (every process eventually gets a turn)

**Cons:**
- **Convoy Effect:** Short processes wait behind a long process, causing high average waiting time
- Not fair to short processes arriving while a long one is running

---

#### 2. SJF (Shortest Job First)

**How it works:**
- The process with the shortest burst time is scheduled next
- Requires knowing (or estimating) the burst time in advance

**Type:**
- Non-preemptive: **SJF**
- Preemptive: **SRTF** (Shortest Remaining Time First)

**Example (P1: 7, P2: 4, P3: 1, P4: 3):**

Timeline: `P1(0-7) | P3(7-8) | P4(8-11) | P2(11-15)`

**Pros:**
- Provides the **minimum average waiting time** of all algorithms
- Increases overall system efficiency and throughput

**Cons:**
- Hard to predict burst time in advance (usually estimated)
- **Starvation:** Long processes may never get a turn if short processes keep arriving

**Solution:** Use **Aging** -- gradually increase priority of long-waiting processes

---

#### 3. Priority Scheduling

**How it works:**
- Each process is assigned a priority number
- Highest priority process gets the CPU first
- Equal priorities are served using FCFS

**Type:** Can be Preemptive or Non-Preemptive

**How to decide priorities?**

| Factor | Example |
|---|---|
| Memory available | More memory = higher priority |
| Time limit | Shorter time limit = higher priority |
| Process type | System tasks > Interactive tasks > Batch tasks |

**Hospital Analogy:**
- Emergency case (highest priority) $\rightarrow$ treated immediately
- Serious cases (medium priority) $\rightarrow$ treated next
- Minor cases (lowest priority) $\rightarrow$ treated last

**Pros:**
- Handles critical tasks appropriately
- Useful for system management

**Cons:**
- Deciding priorities is difficult
- **Starvation:** Low-priority processes may never execute

**Solution -- Aging:** Gradually increase the priority of waiting processes over time. Over time, even low-priority processes will eventually reach the top.

---

#### 4. Round Robin (RR)

> **Exam tip**: Q2 from revision notes — Round Robin is the best algorithm for interactive (time-sharing) systems because: every process gets equal CPU time via the time quantum, prevents any single process from monopolizing the CPU, and prevents starvation.

**How it works:**
- Each process gets a fixed time slice called **Time Quantum**
- When the time quantum expires, the process is preempted and sent to the back of the queue
- Continues in a circular fashion

**Type:** Preemptive

**Example (Time Quantum = 4):**

| Time | Running Process |
|---|---|
| 0-4 | P1 |
| 4-7 | P2 (4-8, but preempted at 8) |
| 7-8 | P3 |
| 8-11 | P1 (remaining) |
| 11-14 | P2 (remaining) |
| 14-17 | P4 |
| 17-20 | P2 (remaining) |

**Key Observation -- Time Quantum matters:**

| Quantum Size | Effect |
|---|---|
| Too small | Excessive context switching overhead (degrades performance) |
| Too large | Degrades to FCFS behavior |
| Just right | Best performance for interactive systems |

**Pros:**
- Very fair -- every process gets equal CPU time
- Excellent for time-sharing and interactive systems
- Prevents starvation

**Cons:**
- Performance heavily depends on time quantum size
- Too small: high context switch overhead
- Too large: becomes FCFS

---

#### 5. Multi-Level Queue

**How it works:**
- The ready queue is divided into **separate queues** for different process types
- Each queue can use a different scheduling algorithm
- Queues have fixed priority levels

**Example Setup:**

| Queue | Process Type | Scheduling Algorithm | Priority |
|---|---|---|---|
| Q1 | System processes | SJF | Highest |
| Q2 | Interactive processes | Round Robin | High |
| Q3 | Batch processes | FCFS | Low |

**Inter-Queue Scheduling:**
- Priority Queue Scheduling: Serve Q1 until empty, then Q2, then Q3
- Each queue has its own time allocation

**Pros:**
- Flexible organization for different process types
- Different algorithms for different needs

**Cons:**
- **Rigid:** Processes are stuck in their assigned queue
- Cannot move between queues
- Lower-priority queues may suffer starvation

---

#### 6. Multi-Level Feedback Queue (Improved Multi-Level Queue)

> **Exam tip**: Q3 from revision notes — MLFQ is the most complex scheduling method because: processes can move between queues based on their behavior, requires tuning multiple parameters (queue count, quantum sizes per queue, aging rate), must track each process's CPU burst history, and must decide when to promote/demote processes.

**How it works:**
- Similar to Multi-Level Queue but processes can **move between queues** based on their behavior
- Decision to move a process depends on its CPU burst history

**Queue Behavior:**

| Queue | Time Quantum | Algorithm | Process Moves to... |
|---|---|---|---|
| Q1 (highest) | Smallest | Round Robin | Q2 if it uses full quantum |
| Q2 (medium) | Medium | Round Robin | Q3 if it uses full quantum |
| Q3 (lowest) | Largest | FCFS | Stays here |

**How processes move:**

| Process Behavior | Result |
|---|---|
| I/O-bound (uses less than quantum) | Stays in / moves to higher queue |
| CPU-bound (uses full quantum) | Drops to lower queue |
| Long-waiting processes | **Aging:** priority increases over time |

**Pros:**
- Prevents starvation
- Handles dynamic process behavior (CPU-heavy vs I/O-heavy)
- Highly efficient for mixed workloads

**Cons:**
- Very complex to implement
- Requires careful tuning of parameters (queue count, quantum sizes, aging rate)

---

### F. Summary Comparison Table

| Algorithm | Preemptive? | Avg Wait Time | Starvation? | Best For |
|---|---|---|---|---|
| FCFS | No | High | No | Simplicity |
| SJF | No | Minimum | Yes | Batch processing |
| SRTF | Yes | Minimum | Yes | When bursts are known |
| Priority | Both | Varies | Yes (without aging) | Critical tasks |
| Round Robin | Yes | Low | No | Interactive systems |
| Multi-Level Queue | Both | Varies | Possible | Fixed process categories |
| Multi-Level Feedback | Yes | Low | No (with aging) | Mixed workloads |

### G. Key Takeaways

1. **No single "best" algorithm** -- choice depends on the goal
2. **Real OSs use combinations** of algorithms (e.g., Linux uses Multi-Level Feedback Queues)
3. **Trade-offs are unavoidable:**
   - Simplicity vs Efficiency
   - Fairness vs Overhead
   - Complexity vs Performance
4. **Focus areas for exams:** Gantt charts, calculating $A_T$, $B_T$, $C_T$, $T_T$, $W_T$, comparing algorithms

---

## Part 2: Numerical Problems

### A. Problem-Solving Framework

**Step-by-step approach for any CPU scheduling numerical:**

1. **Read the question carefully** -- note all process details (name, $A_T$, $B_T$)
2. **Note the algorithm** being asked
3. **Draw the Gantt chart** timeline
4. **Mark the start and end time** for each process
5. **Calculate $C_T$** for each process from the Gantt chart
6. **Calculate $T_T = C_T - A_T$** for each process
7. **Calculate $W_T = T_T - B_T$** for each process
8. **Find averages** across all processes

### B. Common Pitfalls to Avoid

| Pitfall | How to avoid it |
|---|---|
| Scheduling a process before it arrives | Always check: is $current\_time \geq A_T$? |
| Forgetting the time quantum in Round Robin | Track remaining burst time for each process |
| Confusing $T_T$ with $W_T$ | Remember: $T_T$ includes burst time, $W_T$ does not |
| Ignoring ties in SJF/Priority | Use FCFS as tiebreaker |
| Not updating remaining time in SRTF | Track remaining burst, not original burst |

### C. Practice Problem 1: FCFS

**Problem:** Four processes arrive in this order:

| Process | $A_T$ | $B_T$ |
|---|---|---|
| P1 | 0 | 7 |
| P2 | 2 | 4 |
| P3 | 4 | 1 |
| P4 | 6 | 3 |

**Solution:**

Gantt Chart: `P1(0-7) | P2(7-11) | P3(11-12) | P4(12-15)`

| Process | $A_T$ | $B_T$ | $C_T$ | $T_T$ | $W_T$ |
|---|---|---|---|---|---|
| P1 | 0 | 7 | 7 | 7 | 0 |
| P2 | 2 | 4 | 11 | 9 | 5 |
| P3 | 4 | 1 | 12 | 8 | 7 |
| P4 | 6 | 3 | 15 | 9 | 6 |

- **Average $T_T$** = $(7+9+8+9)/4 = 8.25$
- **Average $W_T$** = $(0+5+7+6)/4 = 4.5$

---

### D. Practice Problem 2: SJF (Non-Preemptive)

**Same processes:**

| Process | $A_T$ | $B_T$ |
|---|---|---|
| P1 | 0 | 7 |
| P2 | 2 | 4 |
| P3 | 4 | 1 |
| P4 | 6 | 3 |

**Solution (at time 7, pick shortest from available P2, P3, P4):**

Gantt Chart: `P1(0-7) | P3(7-8) | P4(8-11) | P2(11-15)`

| Process | $A_T$ | $B_T$ | $C_T$ | $T_T$ | $W_T$ |
|---|---|---|---|---|---|
| P1 | 0 | 7 | 7 | 7 | 0 |
| P2 | 2 | 4 | 15 | 13 | 9 |
| P3 | 4 | 1 | 8 | 4 | 3 |
| P4 | 6 | 3 | 11 | 5 | 2 |

- **Average $T_T$** = $(7+13+4+5)/4 = 7.25$
- **Average $W_T$** = $(0+9+3+2)/4 = 3.5$

**Comparison:** SJF gives lower average waiting time (3.5) than FCFS (4.5) -- confirms SJF is more efficient.

---

### E. Practice Problem 3: Round Robin (Quantum = 2)

**Same processes:**

| Process | $A_T$ | $B_T$ |
|---|---|---|
| P1 | 0 | 7 |
| P2 | 2 | 4 |
| P3 | 4 | 1 |
| P4 | 6 | 3 |

**Solution (time quantum = 2):**

Round Robin step-by-step:

| Time | Event | Remaining Burst |
|---|---|---|
| 0-2 | P1 runs | P1: 5 |
| 2 | P2 arrives, ready queue: P2, P3, P4 | |
| 2-4 | P2 runs | P2: 2 |
| 4 | P3 arrives | |
| 4-5 | P3 runs (only 1 left, finishes) | P3: done |
| 5-7 | P4 runs | P4: 1 |
| 7-9 | P1 runs | P1: 3 |
| 9-11 | P2 runs | P2: done |
| 11-13 | P4 runs | P4: done |
| 13-15 | P1 runs | P1: done |

Gantt Chart: `P1(0-2) | P2(2-4) | P3(4-5) | P4(5-7) | P1(7-9) | P2(9-11) | P4(11-13) | P1(13-15)`

| Process | $A_T$ | $B_T$ | $C_T$ | $T_T$ | $W_T$ |
|---|---|---|---|---|---|
| P1 | 0 | 7 | 15 | 15 | 8 |
| P2 | 2 | 4 | 11 | 9 | 5 |
| P3 | 4 | 1 | 5 | 1 | 0 |
| P4 | 6 | 3 | 13 | 7 | 4 |

- **Average $T_T$** = $(15+9+1+7)/4 = 8.0$
- **Average $W_T$** = $(8+5+0+4)/4 = 4.25$

---

### F. Practice Problem 4: SRTF (Preemptive SJF)

**Same processes:**

| Process | $A_T$ | $B_T$ |
|---|---|---|
| P1 | 0 | 7 |
| P2 | 2 | 4 |
| P3 | 4 | 1 |
| P4 | 6 | 3 |

**Solution (always run process with shortest remaining time):**

| Time | Running | Remaining (P1, P2, P3, P4) | Reason |
|---|---|---|---|
| 0-2 | P1 | (5, -, -, -) | Only P1 available |
| 2-3 | P2 | (4, 3, -, -) | P2 arrives, shorter than P1 |
| 3-4 | P2 | (3, 2, -, -) | P2 still shortest |
| 4-5 | P3 | (3, 1, 0, -) | P3 arrives, shortest (1) |
| 5-6 | P3 | (2, 1, done, -) | P3 finishes at 5, P2 has 1 remaining |
| 6-7 | P4 | (1, 1, done, 3) | P4 arrives, tie with P2, FCFS tiebreak to P2... actually P4 has 3, P2 has 1, so P2 runs |

Wait -- let me redo this more carefully:

At time 5: P2 remaining = 1, P1 remaining = 3. So **P2 runs 5-6**.

| Time | Running | Remaining (P1, P2, P3, P4) |
|---|---|---|
| 0-2 | P1 | (5, -, -, -) |
| 2-3 | P2 | (4, 3, -, -) |
| 3-4 | P2 | (3, 2, -, -) |
| 4-5 | P3 | (3, 1, 0, -) |
| 5-6 | P2 | (2, done, done, -) |
| 6-7 | P4 | (2, done, done, 2) |
| 7-8 | P1 | (1, done, done, 1) |
| 8-9 | P4 | (1, done, done, done) |
| 9-10 | P1 | (done, done, done, done) |

Gantt Chart: `P1(0-2) | P2(2-5) | P3(4-5 overlap) | P2(5-6) | P4(6-7) | P1(7-8) | P4(8-9) | P1(9-10)`

Simplified: `P1(0-2) | P2(2-5) | P3(5-6... no, P3 arrives at 4 with burst 1)`

Let me restart this more carefully:

At t=4, P3 arrives with remaining = 1. At t=4, P1 has remaining=3, P2 has remaining=2. **P3 is shortest (1).** So P3 runs from 4-5.

At t=6, P4 arrives with burst=3. Available: P1=2, P4=3. **P1 runs (shorter).**

| Time | Running | Remaining (P1, P2, P3, P4) |
|---|---|---|
| 0-2 | P1 | (5, -, -, -) |
| 2-4 | P2 | (4, 2, -, -) |
| 4-5 | P3 | (3, 1, done, -) |
| 5-6 | P2 | (2, done, done, -) |
| 6-8 | P1 | (0, done, done, 3) |
| 8-11 | P4 | (done, done, done, 0) |

Gantt Chart: `P1(0-2) | P2(2-4) | P3(4-5) | P2(5-6) | P1(6-8) | P4(8-11)`

| Process | $A_T$ | $B_T$ | $C_T$ | $T_T$ | $W_T$ |
|---|---|---|---|---|---|
| P1 | 0 | 7 | 8 | 8 | 1 |
| P2 | 2 | 4 | 6 | 4 | 0 |
| P3 | 4 | 1 | 5 | 1 | 0 |
| P4 | 6 | 3 | 11 | 5 | 2 |

- **Average $T_T$** = $(8+4+1+5)/4 = 4.5$
- **Average $W_T$** = $(1+0+0+2)/4 = 0.75$

**Comparison of all algorithms on same problem:**

| Algorithm | Avg $T_T$ | Avg $W_T$ |
|---|---|---|
| FCFS | 8.25 | 4.5 |
| SJF | 7.25 | 3.5 |
| SRTF | 4.5 | 0.75 |
| RR (q=2) | 8.0 | 4.25 |

SRTF gives the best average waiting time as expected.

---

## Part 3: Programming

### A. Python Implementation: FCFS Scheduling

This file already exists in the folder (`fcfs.py`). See below for additional algorithms.

### B. Round Robin Implementation

```python
def round_robin(processes, time_quantum):
    n = len(processes)
    remaining = [p['bt'] for p in processes]
    completed = 0
    current_time = 0
    gantt = []

    while completed < n:
        for i in range(n):
            if remaining[i] > 0:
                execute = min(time_quantum, remaining[i])
                gantt.append((processes[i]['name'], current_time, current_time + execute))
                remaining[i] -= execute
                current_time += execute
                if remaining[i] == 0:
                    completed += 1
                    processes[i]['ct'] = current_time

    # Calculate metrics
    for p in processes:
        p['tt'] = p['ct'] - p['at']
        p['wt'] = p['tt'] - p['bt']

    avg_tt = sum(p['tt'] for p in processes) / n
    avg_wt = sum(p['wt'] for p in processes) / n

    return processes, avg_tt, avg_wt, gantt


# Example usage
processes = [
    {'name': 'P1', 'at': 0, 'bt': 7, 'ct': 0},
    {'name': 'P2', 'at': 2, 'bt': 4, 'ct': 0},
    {'name': 'P3', 'at': 4, 'bt': 1, 'ct': 0},
    {'name': 'P4', 'at': 6, 'bt': 3, 'ct': 0},
]

result, avg_tt, avg_wt, gantt = round_robin(processes, 2)
print("Gantt Chart:", gantt)
print(f"Average Turn Around Time: {avg_tt:.2f}")
print(f"Average Waiting Time: {avg_wt:.2f}")
```

---

### C. SRTF (Preemptive SJF) Implementation

```python
def shortest_remaining_time_first(processes):
    n = len(processes)
    remaining = [p['bt'] for p in processes]
    completed = 0
    current_time = 0
    gantt = []
    last_process = None

    while completed < n:
        # Find process with shortest remaining time that has arrived
        shortest = -1
        min_remaining = float('inf')

        for i in range(n):
            if remaining[i] > 0 and processes[i]['at'] <= current_time:
                if remaining[i] < min_remaining:
                    min_remaining = remaining[i]
                    shortest = i
                elif remaining[i] == min_remaining and last_process != i:
                    # Tie-break: FCFS (earlier index)
                    shortest = i

        if shortest == -1:
            # No process available, jump to next arrival
            current_time += 1
            continue

        # Execute one unit
        gantt.append((processes[shortest]['name'], current_time, current_time + 1))
        remaining[shortest] -= 1
        current_time += 1

        if remaining[shortest] == 0:
            completed += 1
            processes[shortest]['ct'] = current_time
            last_process = None  # Reset for tie-breaking
        else:
            last_process = shortest

    # Calculate metrics
    for p in processes:
        p['tt'] = p['ct'] - p['at']
        p['wt'] = p['tt'] - p['bt']

    avg_tt = sum(p['tt'] for p in processes) / n
    avg_wt = sum(p['wt'] for p in processes) / n

    return processes, avg_tt, avg_wt, gantt
```

### D. Priority Scheduling Implementation (with Aging)

```python
def priority_scheduling(processes, preemptive=False, aging_enabled=False):
    n = len(processes)
    remaining = [p['bt'] for p in processes]
    completed = 0
    current_time = 0
    gantt = []
    last_process = None

    while completed < n:
        best = -1
        max_priority = -1

        for i in range(n):
            if remaining[i] > 0 and processes[i]['at'] <= current_time:
                # Apply aging: priority increases by 1 for each time unit waited
                priority = processes[i]['priority'] + (current_time - processes[i]['at']) if aging_enabled else processes[i]['priority']
                if priority > max_priority or (priority == max_priority and last_process != i):
                    max_priority = priority
                    best = i

        if best == -1:
            current_time += 1
            continue

        if preemptive and last_process != -1:
            # Continue with same process only if no better option
            pass

        # Execute one unit (or full burst for non-preemptive)
        execute = 1 if preemptive else remaining[best]
        gantt.append((processes[best]['name'], current_time, current_time + execute))
        remaining[best] -= execute
        current_time += execute

        if remaining[best] == 0:
            completed += 1
            processes[best]['ct'] = current_time
            last_process = -1
        else:
            last_process = best

    # Calculate metrics
    for p in processes:
        p['tt'] = p['ct'] - p['at']
        p['wt'] = p['tt'] - p['bt']

    avg_tt = sum(p['tt'] for p in processes) / n
    avg_wt = sum(p['wt'] for p in processes) / n

    return processes, avg_tt, avg_wt, gantt
```

### E. Comparison Driver

```python
def compare_scheduling(processes):
    print("=" * 60)
    print("PROCESS DATA")
    print("=" * 60)
    print(f"{'Process':<10} {'Arrival':<10} {'Burst':<10}")
    for p in processes:
        print(f"{p['name']:<10} {p['at']:<10} {p['bt']:<10}")

    # FCFS
    fcfs_processes = [dict(p) for p in processes]
    fcfs_processes, fcfs_tt, fcfs_wt, fcfs_gantt = fcfs_scheduling(fcfs_processes)
    print(f"\nFCFS - Avg Turn Around: {fcfs_tt:.2f}, Avg Wait: {fcfs_wt:.2f}")

    # SJF
    sjf_processes = [dict(p) for p in processes]
    sjf_processes, sjf_tt, sjf_wt, sjf_gantt = shortest_job_first(sjf_processes)
    print(f"SJF  - Avg Turn Around: {sjf_tt:.2f}, Avg Wait: {sjf_wt:.2f}")

    # RR
    rr_processes = [dict(p) for p in processes]
    rr_processes, rr_tt, rr_wt, rr_gantt = round_robin(rr_processes, 2)
    print(f"RR(q=2) - Avg Turn Around: {rr_tt:.2f}, Avg Wait: {rr_wt:.2f}")

    # SRTF
    srtf_processes = [dict(p) for p in processes]
    srtf_processes, srtf_tt, srtf_wt, srtf_gantt = shortest_remaining_time_first(srtf_processes)
    print(f"SRTF - Avg Turn Around: {srtf_tt:.2f}, Avg Wait: {srtf_wt:.2f}")

    print("\n" + "=" * 60)
    print("COMPARISON SUMMARY")
    print("=" * 60)
    print(f"{'Algorithm':<15} {'Avg T_T':<15} {'Avg W_T':<15}")
    print(f"{'FCFS':<15} {fcfs_tt:<15.2f} {fcfs_wt:<15.2f}")
    print(f"{'SJF':<15} {sjf_tt:<15.2f} {sjf_wt:<15.2f}")
    print(f"{'RR (q=2)':<15} {rr_tt:<15.2f} {rr_wt:<15.2f}")
    print(f"{'SRTF':<15} {srtf_tt:<15.2f} {srtf_wt:<15.2f}")


# Run comparison
processes = [
    {'name': 'P1', 'at': 0, 'bt': 7, 'ct': 0, 'priority': 3},
    {'name': 'P2', 'at': 2, 'bt': 4, 'ct': 0, 'priority': 2},
    {'name': 'P3', 'at': 4, 'bt': 1, 'ct': 0, 'priority': 1},
    {'name': 'P4', 'at': 6, 'bt': 3, 'ct': 0, 'priority': 4},
]

compare_scheduling(processes)
```

---

## Appendix: Quick Reference

### Formulas Cheat Sheet

```
Turn Around Time (T_T) = Completion Time (C_T) - Arrival Time (A_T)
Waiting Time (W_T)    = T_T - Burst Time (B_T)
Response Time (R_T)   = First execution start time - Arrival Time (A_T)
```

### When to Use Which Algorithm

| Scenario | Best Algorithm |
|---|---|
| Simple batch processing | FCFS |
| Minimum average wait time | SJF / SRTF |
| Interactive / time-sharing | Round Robin |
| Critical + normal tasks | Priority |
| Mixed workloads | Multi-Level Feedback Queue |

### Exam Tips

1. **Always draw the Gantt chart first** before calculating anything
2. **Double-check arrival times** -- never schedule before arrival
3. **For ties**, use FCFS as the tiebreaker
4. **For SRTF**, track remaining burst time, not original burst time
5. **For Round Robin**, decrement remaining time and re-queue if not finished
6. **For Priority with aging**, add (current_time - arrival_time) to each waiting process's priority
7. **Round-off carefully** -- keep 2 decimal places for averages

---

## Quiz / MCQ Practice

### General Scheduling & Logic

**Q1: When multiple processes are waiting to use the CPU, who decides which process gets the CPU next?**
- A) The Application Developer
- B) The Programmer
- **C) Operating System** ← Correct
- D) The Network Card
- **Reasoning:** CPU Scheduling is a core mechanism of the Operating System used to select processes from the ready queue and allocate CPU resources.

**Q2: CPU scheduling is needed when**
- A) A process completes
- B) A process starts waiting for I/O
- C) A process moves from a waiting state back to the ready state
- **D) All of the above** ← Correct
- **Reasoning:** Scheduling decisions are triggered when a process completes, starts waiting for I/O, or moves from a waiting state back to ready.

**Q3: If a process completes its execution, what should the CPU do next?**
- A) Shut down the system
- **B) Select another process from the ready queue for execution** ← Correct
- C) Stop until a new process is created
- D) Delete the process
- **Reasoning:** Once a process exits or completes, the CPU must be reassigned to a new process waiting in the ready queue.

### Scheduling Types

**Q4: In which type of scheduling can the Operating System stop a running process before it finishes?**
- A) Non-preemptive scheduling
- B) First-Come, First-Served scheduling
- **C) Preemptive scheduling** ← Correct
- D) Batch scheduling
- **Reasoning:** Preemptive scheduling allows the OS to interrupt a running process and reassign the CPU to another task.

**Q5: In non-preemptive scheduling**
- A) The OS can stop a process at any time
- B) The process is executed in priority order
- **C) A process keeps the CPU until it finishes or starts waiting** ← Correct
- D) The process is always executed in the shortest time first
- **Reasoning:** In non-preemptive systems, a process cannot be interrupted; it must either finish execution or move to a waiting state voluntarily.

**Q6: Which of the following best describes preemptive scheduling?**
- A) The process runs until completion
- **B) The Operating System can interrupt a running process** ← Correct
- C) The process is executed in the order it arrives
- D) The CPU is dedicated to one process at a time
- **Reasoning:** This is the defining characteristic of preemptive algorithms—they allow for interruptions to improve responsiveness.

**Q7: Round Robin scheduling is an example of:**
- A) Non-preemptive scheduling
- B) Non-preemptive priority scheduling
- **C) Preemptive scheduling** ← Correct
- D) Longest Job First scheduling
- **Reasoning:** Round Robin is preemptive because it uses a fixed time quantum to interrupt processes and ensure fairness.

### Calculations & Metrics

**Q8: If Arrival Time = 2 and Completion Time = 10, Turnaround Time is:**
- A) 12
- **B) 8** ← Correct
- C) 5
- D) 2
- **Reasoning:** Turnaround Time = Completion Time - Arrival Time = 10 - 2 = 8.

**Q9: If Turnaround Time = 9 and Burst Time = 4, Waiting Time is:**
- **A) 5** ← Correct
- B) 13
- C) 4
- D) 9
- **Reasoning:** Waiting Time = Turnaround Time - Burst Time = 9 - 4 = 5.

**Q10: If more processes are completed in less time, throughput is:**
- **A) Higher** ← Correct
- B) Lower
- C) Zero
- D) Unchanged
- **Reasoning:** Throughput is defined as the number of processes completed per unit of time.

### Algorithm Problems

**Q11: The main problem with First-Come, First-Served scheduling is:**
- A) It is too complex to implement
- B) It requires a preemption mechanism
- C) It causes context switching overhead
- **D) It may cause convoy effect** ← Correct
- **Reasoning:** FCFS allows long processes to block shorter ones, creating a "convoy" that leads to poor performance.

**Q12: A possible problem in Shortest Job First scheduling is:**
- **A) Starvation of long processes** ← Correct
- B) Convoy effect
- C) High context switching overhead
- D) Inability to handle I/O bursts
- **Reasoning:** If short jobs keep arriving, a long process may never get a chance to execute.

**Q13: If the time quantum is too small in Round Robin scheduling, what increases?**
- A) Process execution time
- B) Waiting time
- **C) Context Switching** ← Correct
- D) Turnaround time
- **Reasoning:** A very small quantum forces the CPU to switch between processes more frequently, creating significant overhead.

---

*Notes generated from CPU Scheduling Algorithms lecture (Class Scaler Academy)*
