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

### Symbolic (Soft) Link
- A **shortcut** that points to the original file by name/path
- Creates a new inode; the symlink's data blocks contain the path to the target file
- Behaves like a Windows shortcut or macOS alias

---

## 4. Key Takeaways
- File system **separates names, metadata, and data** for flexibility
- **Inodes** are the backbone — they hold metadata and point to data blocks
- **Multiple links** enable sharing files without duplicating data
- Two link types: **Hard links** (direct inode sharing) and **Symbolic links** (path-based shortcuts)

---

## 5. File System Terms

### Glossary
| Term | Definition |
|------|------------|
| **Inode** | An inode stores metadata about a file, including permissions and file size. |
| **Journaling** | Journaling records planned metadata changes to maintain file system consistency after crashes. |
| **File Descriptor** | File descriptor is a token assigned when a file is opened and is used for file operations. |

## 6. Disk Scheduling Algorithms

| Algorithm | Description |
|-----------|-------------|
| **LOOK Scheduling** | LOOK serves requests only up to the last pending one in one direction, then reverses. |
| **SCAN Scheduling** | SCAN moves to the end of the disk before reversing direction, like an elevator. |
| **C-LOOK Scheduling** | C-LOOK is a circular version of LOOK, jumping to the start after serving the last request. |
| **C-SCAN Scheduling** | C-SCAN is a circular version of SCAN, returning to start after reaching the disk end. |

## 7. Storage Devices & I/O Operations

| Term | Definition |
|------|------------|
| **NVMe** | NVMe is a high-speed storage protocol designed for flash storage, allowing parallel access. |
| **SSD** | Solid State Drive (SSD) is a storage device using flash memory, having no moving parts. |
| **Write and Fsync** | Write places data in OS cache first, while fsync forces data write to disk for durability. |

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
