# Storage Management — File Systems, Inodes & Links

## 1. File Structure Internals

### How Files Are Stored on Disk
- **File name, inode number, and actual data blocks** are stored separately
- A `.txt` file (or any file) is composed of three parts:
  1. **Directory entry** — stores the file name → points to the inode number
  2. **Inode (Index Node)** — stores all metadata about the file + block addresses
  3. **Data blocks** — contain the actual file content, referenced by inodes

### Flow of File Access
```
File Name → Directory Entry → Inode (metadata + block addresses) → Data Blocks (actual data)
```

- **Inode is the core link** connecting all parts of a file together
- This separation is what makes links possible

---

## 2. Why Do Links Exist?

### Common Use Cases
| Scenario | Example |
|---|---|
| Same file with multiple names | `project.txt` and `file_report.txt` refer to the same content |
| File in two folders | Access a copy from different directories |
| Shortcut/alias | Quick access to a file without duplicating it |
| Share common files | Multiple users access the same file |

---

## 3. Types of Links

### Hard Link
- Allows **same file** to be accessible by **one or more names**
- Multiple directory entries point to the **same inode number**
- All links are equal — no concept of "original" vs "copy"
- Both names share the same content
- Removing one name does not delete data if another hard link still exists
- Data is only deleted when the link count reaches zero
- Typically cannot cross file systems or link to directories

### Symbolic (Soft) Link
- A **shortcut** that points to the original file by name/path
- Creates a new inode; the symlink's data blocks contain the path to the target file
- Behaves like a Windows shortcut or macOS alias
- Has its own unique inode
- If the original target is deleted, the symbolic link becomes broken ("dangling link")
- Can cross file systems and link to directories

## 4. File Deletion Rules

### How Files Are Deleted
- Deleting a file name simply removes the directory label
- File blocks are only **freed** when two conditions are met:
  1. The link count equals zero
  2. No process has the file currently open ("open by process" = false)

---

## 5. Key Takeaways
- File system **separates names, metadata, and data** for flexibility
- **Inodes** are the backbone — they hold metadata and point to data blocks
- **Multiple links** enable sharing files without duplicating data
- Two link types: **Hard links** (direct inode sharing) and **Symbolic links** (path-based shortcuts)

---

## 6. File System Terms

### Glossary
| Term | Definition |
|------|------------|
| **Inode** | An inode stores metadata about a file, including permissions and file size. |
| **Journaling** | Journaling records planned metadata changes to maintain file system consistency after crashes. If a crash occurs, the OS reads the journal upon restart and replays unfinished updates, returning the file system to a consistent state. |
| **File Descriptor** | File descriptor is a token assigned when a file is opened and is used for file operations. |

### Quiz Key Points
- **Hard link shares inode** — hard links directly share the same inode number
- **Write() returns successfully** does not guarantee data is on disk yet — data may still be in the OS page cache
- If a process has a file open and another command deletes it, the **file may still exist** (blocks only freed when link count = 0 AND no processes have it open)

---

## 7. Crash Consistency and Journaling

### Problem
- Updating a file system requires multiple related changes (data, metadata, directory entry, free-block information)
- System crashes during partial updates can cause inconsistent or corrupted metadata

### Solution: Journaling
- A temporary log where the file system records a description of intended metadata updates **before** making permanent changes
- If a crash occurs, the OS reads the journal upon restart and replays unfinished updates
- Returns the file system to a consistent state

---

## 8. File Allocation Methods

| Method | Description | Advantages | Disadvantages |
|--------|-------------|------------|---------------|
| **Contiguous** | Blocks are stored together sequentially | Fast direct access | External fragmentation |
| **Linked** | Scattered blocks linked as a chain | Easy growth | Slow direct access, pointer overhead |
| **Indexed** | An index block stores block addresses | Supports random access | Index-block overhead |

---

## 9. Disk Scheduling

### Core Concepts
- **Disk Scheduling:** The OS decides the order in which pending disk I/O requests are served to improve efficiency
- **Seek Time:** The time taken by the disk head to move to the required track
- **Total Head Movement:** The sum of all track movements (New position - Current position) while serving requests. Less head movement = less seek time

### Algorithms

| Algorithm | Main Idea | Advantages | Disadvantages |
|-----------|-----------|------------|---------------|
| **FCFS** (First Come First Serve) | Serves requests in exact arrival order | Simple; fair based on arrival | Large head movement; poor performance |
| **SSTF** (Shortest Seek Time First) | Chooses the request closest to current head position | Reduces head movement vs FCFS; better avg seek time | May cause starvation for far-away requests |
| **SCAN** (Elevator) | Moves in one direction to physical end, then reverses | Better fairness than SSTF; good for many waiting requests | Travels to very end even if no requests there |
| **LOOK** | Like SCAN, but reverses at last pending request (not physical end) | Avoids unnecessary travel to disk ends; better than SCAN | Direction reversal can still delay some requests |
| **C-SCAN** (Circular SCAN) | Moves in one direction to end, then jumps back to beginning | Uniform waiting time; good fairness | Jump from end to beginning adds extra movement |
| **C-LOOK** (Circular LOOK) | Moves in one direction till last request, then jumps directly to first request on other side | Avoids going to physical ends; more efficient than C-SCAN | Can be less fair for requests near beginning or end |

---

## 10. Modern Storage and I/O Performance

### Storage Technologies Comparison

| Feature | HDD (Hard Disk Drive) | SSD (Solid State Drive) | NVMe SSD |
|---------|----------------------|------------------------|----------|
| **Technology** | Mechanical (spinning magnetic platters, moving read/write heads) | NAND Flash via SATA (no moving parts) | NAND Flash over PCIe (NVMe protocol) |
| **Performance** | Slower (lower IOPS and throughput) | Faster than HDD | Fastest (very high IOPS/throughput, low latency) |
| **Durability** | Vulnerable to shock and vibration | Shock resistant; more durable | Most durable and reliable |
| **Noise** | Higher (spinning and seeking noise) | Silent | Silent |

### Performance Metrics

| Metric | Description | Example |
|--------|-------------|---------|
| **Latency** | Time required to complete a single I/O request | 2 ms (lower = faster) |
| **Throughput** | Total data transferred per unit time | 500 MB/s |
| **IOPS** | Input/Output Operations Per Second — raw number of ops/sec regardless of size | 100,000 IOPS |
| **Queue Depth** | Number of outstanding I/O requests waiting/processing simultaneously | Optimizing balances throughput and latency |

### I/O Optimization Concepts

- **Page Cache:** OS mechanism that acts as a RAM buffer between applications and storage. A "cold read" goes to slower storage; subsequent "warm reads" fetch data from RAM cache rapidly
- **Buffered vs Direct I/O:**
  - *Buffered I/O* uses the OS page cache
  - *Direct I/O* bypasses the OS page cache (databases use this to maintain their own caching and avoid double caching)
- **Blocking vs Async I/O:**
  - *Blocking I/O* forces the app to wait for the I/O request to finish
  - *Async I/O* allows the app to submit a request and continue processing other tasks, waiting for a completion notification

---

# Software Engineering Concepts

## 1. Introduction to Software Engineering

**Definition:** Application of engineering principles to software development in a systematic method.

**Importance:** Provides a framework to build complex, scalable, and reliable software products efficiently.

---

## 2. Software Development Life Cycle (SDLC)

### Stages
| Stage | Description |
|-------|-------------|
| **Requirement Analysis** | Understanding what users need |
| **Design** | Planning the architecture of the software |
| **Implementation** | Writing and compiling the program code |
| **Testing** | Verifying the software against requirements |
| **Deployment** | Releasing the software to users |
| **Maintenance** | Updating/improving software based on user feedback and new requirements |

---

## 3. Programming Paradigms

### Procedural Programming
- Follows a sequence of steps or procedures to solve a problem
- Emphasizes functions

### Object-Oriented Programming (OOP)
- **Core Concepts:** Classes, objects, inheritance, polymorphism, encapsulation, abstraction
- **Analogy:** Class = blueprint (cookie cutter), Objects = instances (cookies)

### Functional Programming
- Focuses on immutable data and functions as first-class citizens

---

## 4. Design Patterns

**Definition:** Typical solutions to commonly occurring problems in software design.

| Type | Description | Example |
|------|------------|---------|
| **Creational** | Object creation mechanisms | Singleton Pattern |
| **Structural** | Object composition / building blocks for structures | Adapter Pattern |
| **Behavioral** | Object collaboration and data flow | Observer Pattern |

---

## 5. Software Testing

### Types of Testing
| Type | Description |
|------|-------------|
| **Unit Testing** | Testing individual units or components |
| **Integration Testing** | Testing combinations of units as a group |
| **System Testing** | Testing the entire system as a whole |
| **User Acceptance Testing (UAT)** | Testing with real users to validate end-to-end business flow |

### Importance
Ensures reliability, security, and high performance of the software product.

---

## 6. Version Control Systems (VCS)

**Definition:** Systems that help manage changes to source code over time.

**Popular Tools:** Git, Subversion (SVN)

**Benefits:**
- Track revision history
- Collaborate with multiple developers
- Maintain code versions and facilitate rollback

---

## 7. Agile and Scrum Methodologies

### Agile
- Iterative and incremental approach to software development

### Scrum (subset of Agile)
- Focuses on delivering the most valuable features first

**Roles:** Product Owner, Scrum Master, Development Team

**Events:** Sprints, Daily Stand-ups, Sprint Retrospective

---

## 8. Cloud Computing

**Definition:** Delivery of computing services over the Internet ("the cloud").

| Model | Description |
|-------|-------------|
| **IaaS (Infrastructure as a Service)** | Provides virtualized computing resources over the internet |
| **PaaS (Platform as a Service)** | Provides hardware and software tools (typically for development) |
| **SaaS (Software as a Service)** | Deliver software applications over the internet |

**Benefits:** Scalability, cost efficiency, accessibility

---

## 9. Additional Concepts
- Review any examples, case studies, or real-world applications discussed in class for practical understanding of how these concepts are applied.

---

*Source: Scaler Academy — Software Engineering Concepts Class*
