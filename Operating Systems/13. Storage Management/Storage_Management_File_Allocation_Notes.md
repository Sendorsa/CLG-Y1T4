# Storage Management - File Allocation Methods

> Based on lecture from Class Scaler Academy

---

## Table of Contents

1. [Disk Block Basics](#disk-block-basics)
2. [File Allocation Methods](#file-allocation-methods)
   - [Contiguous Allocation](#contiguous-allocation)
   - [Linked File Allocation](#linked-file-allocation)
   - [FAT (File Allocation Table)](#fat-file-allocation-table)
   - [Indexed Allocation](#indexed-allocation)
3. [File System Metadata](#file-system-metadata)
    - [Directory Entry](#directory-entry)
    - [I-Node](#i-node)
4. [Accessing Files](#accessing-files)
   - [Current File Offset](#current-file-offset)
   - [Sequential vs Direct Access](#sequential-vs-direct-access)
5. [Page Cache & Buffer Cache](#page-cache--buffer-cache)
6. [Buffered Write & Fsync](#buffered-write--fsync)
7. [Comparison Summary](#comparison-summary)

---

## Disk Block Basics

### What is a Disk Block?
A **disk block** is a small, fixed-size storage unit on the disk where data gets stored. Similar to frames in RAM.

### How Files Are Stored
- The OS does **NOT** store files as one big object
- A file is divided into small fixed-size blocks that match the disk block size
- Number of blocks required = `ceil(file size / block size)`

### Example
| File Size | Block Size | Blocks Needed | Internal Fragmentation |
|-----------|-----------|---------------|----------------------|
| 20 KB     | 4 KB      | 5 blocks      | None (perfect fit)   |
| 18 KB     | 4 KB      | 5 blocks      | 2 KB wasted in last block |

**Internal Fragmentation:** Because blocks are fixed in size, the final block allocated to a file may not be fully occupied, leaving unused leftover space. This is caused by the ceiling function in block allocation.

### Numerical Example: Block Requirement & Unused Space

```
File Size:    18 KB
Block Size:   4 KB
Blocks:       ceil(18 / 4) = ceil(4.5) = 5 blocks
Allocated:    5 × 4 KB = 20 KB
Unused Space: 20 KB - 18 KB = 2 KB (internal fragmentation)
```

### Indexed File Capacity Example

```
Block Size:      4 KB
Address Size:    4 bytes
Addresses/Block: 4096 / 4 = 1024 entries
Max File Size:   1024 × 4 KB = 4096 KB = 4 MB
```

### Linked Pointer Overhead Example

```
Blocks:   100
Pointer:  4 bytes per block
Overhead:  100 × 4 bytes = 400 bytes (reduces storage for actual data)
```

---

## File Allocation

**File Allocation** is the process of assigning disk blocks to a file in either a contiguous or scattered manner. The allocation method determines how blocks are distributed across the disk and how they are tracked by the OS.

---

## File Allocation Methods

### Contiguous Allocation

Each file occupies a **continuous set of blocks** on the disk.

- Directory stores: `file name`, `starting block`, `length (number of blocks)`
- To access any block, OS calculates: `start_block + offset`
- All blocks are physically adjacent

**Pros:**
- Simple to implement
- Fastest sequential and direct access (single calculation)
- No extra overhead (only data stored in blocks)

**Cons:**
- **External fragmentation** — free space scattered between files
- File size must be known in advance — cannot grow/shrink dynamically
- Finding contiguous free space is difficult as disk fills up

---

### Linked File Allocation

Each file's blocks are stored in **scattered locations** across the disk and linked together via pointers.

**Structure (each block's layout):**
Each block contains:
1. **Data** — the actual file content
2. **Pointer** — address of the next block in the file

The directory stores: `file name` + `starting block address`

**Flow:**
```
Directory → Block 7 → Block 18 → Block 3 → EOF (null)
```

**Pros:**
- No external fragmentation (blocks can be placed anywhere)
- Dynamic file growth is easy — just append a new free block as the last pointer target

**Cons:**
- **No direct/random access** — must traverse from start to reach any block (sequential access only)
- **Pointer overhead** — each block reserves space for the next-block address. For N blocks with 4-byte pointers, total pointer overhead = `N × 4 bytes`
- Reliability concern: if a pointer is lost/corrupted, all subsequent blocks become unreachable

---

### FAT (File Allocation Table)

An improvement over linked allocation. Instead of storing pointers inside every data block, a separate **FAT table** stores all the links in one place (typically in RAM).

**Structure:**
```
Disk Blocks:    Block 7 (data only) → Block 18 (data only) → ...
FAT Table:      [7→18] [18→3] [3→null]
```

- FAT maps each block to its next block
- FAT is stored on disk (may be cached in memory during active file use)

**Pros:**
- Eliminates pointer overhead in data blocks (blocks store only data)
- Better than plain linked allocation for space efficiency
- Still no external fragmentation

**Cons:**
- FAT table itself requires memory/storage
- Direct access still **not possible** — must follow chain in the FAT table
- Still cannot fully eliminate chaining overhead (the chain must still be followed for traversal)

**Key Interview Answer:** To improve pointer overhead of linked allocation, maintain a separate File Allocation Table storing all pointers in one location. This is better but does **not** fully eliminate the problem.

---

### Indexed Allocation

Each file has an **index block** that stores the **actual addresses** (not pointers) of all its data blocks.

**Structure:**
```
Directory → Index Block Address
Index Block:     [Block 142] [Block 89] [Block 215] [Block 40]
```

- Directory stores only the **index block address** (not starting data block)
- Index block contains direct block addresses for every data block
- No concepts of chaining or pointers between blocks

**How it works:**
1. OS accesses index block via directory
2. Index block provides direct addresses of all data blocks
3. OS jumps to any block address directly — **random/direct access possible**

**Dynamic Growth:** Adding new blocks is easy — just append a new block address to the index block table.

**Pros:**
- Direct/random access to any block
- No external fragmentation
- **No pointer-link overhead** — no chaining between blocks (only index block itself consumes extra space)

**Cons:**
- Index block consumes extra memory
- **Inefficient for very small files** — e.g., a 2-block file needs 1 index block extra overhead
- For very large files, a single index block may not be enough (requires indirect/block pointer approaches)

---

## File System Metadata

### Directory Entry
A directory entry maps the **file name** to an **I-Node number**.

| Component | Description |
|-----------|------------|
| File Name | `"notes.txt"` (stored as a string) |
| I-Node | A number (e.g., `45`) that uniquely identifies the file |

### I-Node (Index Node)
Stores **all metadata** of a file:

- File size
- Owner information
- Permissions (read/write/execute for user/group/others)
- Time stamps (created, modified, accessed)
- **Data block addresses** (block number entries for locating data blocks on disk)

**Two-step file opening process:**
1. Look up file name in directory → get I-Node number
2. Access I-Node → get metadata + data block addresses → fetch data from disk

### Open File Lifecycle: The `open()` Call

Opening a file is not instantaneous; the OS performs sequential validations and bookkeeping steps:

1. **Parse the Path Name:** The OS evaluates the filepath string, breaking it into components starting from the root or current working directory.
2. **Look up Directory Entry:** The OS scans target directories to isolate the final component string and retrieve its directory entry.
3. **Locate the Inode:** The OS extracts the inode number from the directory entry and loads that inode metadata into system memory.
4. **Verify Permissions:** The process's security credentials are checked against the file's permission bits inside the inode to ensure the operation is allowed.
5. **Create an Open-File Table Entry:** The OS registers an entry in a global kernel table tracking active file states, capturing current offset pointer, open flags (e.g., `O_RDONLY`), reference counters, and an inode pointer.
6. **Return a File Descriptor:** The OS assigns a small, non-negative integer—the File Descriptor (fd)—back to the process. Future calls (`read()`, `write()`, `lseek()`) bypass filenames entirely and use this token handle.

**Resolution Flow: from Name to Data Content**

1. Directory Lookup → matches file name string to get Inode Number
2. Inode Load → OS reads the specific inode entry (memory or disk)
3. Address Fetch → inode reveals raw disk block addresses
4. Data Retrieval → OS fetches/modifies data blocks with actual content

### Standard File Descriptors

Every process initializes with three implicit descriptors plus dynamically assigned ones:

| FD | Descriptor |
|----|-----------|
| 0  | Standard Input (stdin) |
| 1  | Standard Output (stdout) |
| 2  | Standard Error (stderr) |
| 3+ | First dynamically opened file descriptor |

---

## Accessing Files

### Current File Offset
- Initially set to **0** (first byte) when a file is opened
- Increments after each read/write operation
- Tracks where the next read/write should begin

### Sequential vs Direct Access

| Operation | Description | Use Case |
|-----------|------------|----------|
| `read()` / `write()` | Performs **sequential access** — offset advances automatically | Playing videos, audio playback, scrolling documents |
| `lseek()` | Jumps to any offset for **direct/random access** | Changing video timestamp, editing specific file locations |

- When you drag a video timeline to a different time stamp → **direct access via offset change**
- Normal video/audio playback → **sequential access**

---

## Page Cache & Buffer Cache

### What is Page Cache?
A special area inside RAM where recently used file data is stored for faster future access.

### Cold Read vs Warm Read
| Type | Description |
|------|------------|
| **Cold Read** | First time reading a file — data not in cache, must fetch from disk (slower) |
| **Warm Read** | Subsequent reads — data found in page cache, served from RAM (very fast) |

### Why Page Cache?
- Disk access is slow (mechanical/hardware latency)
- RAM/Cache access is exponentially faster
- Frequently used files benefit significantly

---

## Buffered Write & Fsync

### The Problem with Direct Disk Writes
Every write to disk takes ~3 seconds. Writing each character directly would make the system extremely slow and data would be lost on power failure.

### Buffered Write (Write-Back Caching)
1. Write operations go to **OS buffer (cache)** instead of directly to disk
2. Buffer returns success immediately to the process
3. OS flushes collected writes to disk in the **background** (delayed write)

**Benefits:**
- **Performance** — RAM is much faster than disk; batches small writes together

### Fsync Command
- Forces immediate flush of all cache data to disk
- Guarantees durability but is **expensive** (disk I/O per call)

| Method | Performance | Durability |
|--------|------------|------------|
| write() call | Immediate return (data in RAM only) | Data may be lost on power failure/disk crash |
| `fsync()` / `File.sync()` in Java | Slow (expensive disk I/O) | Guaranteed |

**Language equivalents:**
- C/C++: `fsync()`
- Linux: `fsync` command
- Java: `FileOutputStream.sync()`

---

## Comparison Summary

| Attribute | Contiguous | Linked | FAT | Indexed |
|-----------|-----------|--------|-----|---------|
| **Storage Style** | Continuous blocks | Scattered, linked by pointers | Scattered, links in table | Scattered, indexed by block address |
| **Directory stores** | Start block + length | Start block | Start block (or none) | Index block address |
| **Sequential Access** | Very Good | Fairly Good | Fairly Good | Very Good |
| **Direct Access** | Fastest | Slow (chain traversal) | Slow (follow in FAT) | Good (direct address lookup) |
| **External Fragmentation** | ❌ Present | ✅ No | ✅ No | ✅ No |
| **File Expansion** | ❌ Not possible | ✅ Possible | ✅ Possible | ✅ Possible |
| **Overhead** | None | Pointer overhead | FAT table maintenance | Index block overhead |
| **Best for** | Small, fixed-size files | General linked storage | Improved linked allocation | Random access needs |

> **Modern systems** use a **combination of FAT + I-Node**:
> - I-Node stores direct data block addresses for small/medium files
> - For very large files, indirect/block pointers + FAT handle the overflow efficiently

---

## Key Takeaways

1. Files are stored in **fixed-size disk blocks**, not as single objects
2. **Four main allocation methods**: Contiguous, Linked, FAT, Indexed
3. **Linked** solves external fragmentation but introduces pointer overhead and no direct access
4. **FAT** moves pointers to a separate table (reduces block-level overhead)
5. **Indexed** provides true direct access by storing actual block addresses
6. **I-Node** stores file metadata; **Directory** maps names to I-Nodes
7. **File Descriptors** are integer handles used by processes for efficient file access
8. **Page Cache** speeds up repeated reads; serves warm reads from RAM
9. **Buffered Write** improves performance and causes **delayed write** — data sits in cache until OS flushes it
10. **Fsync** ensures durability by forcing immediate flush to disk

---

## Journaling (Data Integrity)

The lecture mentioned **journaling** as a technique for ensuring file system reliability and data integrity during crashes or power failures. A journal records planned changes before they are applied, so if a crash occurs, the file system can **replay the journal** to recover to a consistent state rather than risking corruption.

> Note: The instructor stated this topic would not be covered completely in today's class. Full coverage of journaling mechanisms (commit logs, transaction groups, metadata vs full journaling) is planned for a future session.

---

## Referenced Quiz Questions

| # | Question(s) | Answer |
|---|-------------|--------|
| 1 | Why is file allocation needed? | To assign disk blocks to a file |
| 2 | Why is contiguous allocation fast for direct access? | Blocks are continuous |
| 3 | A file size is 22 KB and block size is 6 KB. How many blocks are needed and how much space is wasted? | **4 blocks, 2 KB wasted** — `ceil(22/6) = 4; 4×6 = 24 kB allocated; 24−22 = 2 kB` internal fragmentation |
| 4 | In linked file allocation, file blocks are | Scattered |
| 5 | In linked allocation, each block mainly stores | Data + pointer |
| 6 | Why is direct access slow in linked allocation? | Chain must be followed (sequential traversal only) |
| 7 | In FAT, the next-block information is stored | In a table (File Allocation Table) |
| 8 | Why is indexed allocation better for direct access? | It stores all block addresses together (in the index block) |
| 9 | Which allocation method has external fragmentation? | Contiguous allocation |
| 10 | In Unix-like systems, what does a directory entry mainly store? | File name to inode number |
| 11 | Which statement is correct about a file descriptor? | It is a small handle (integer token) |
| 12 | Why can reading the same file second time be faster? | Data may be in cache (warm read from page cache) |
| 13 | After write() returns successfully, which statement is correct? | Data may be in OS cache — not necessarily on disk yet |

---

*Notes generated from Class Scaler Academy lecture on Storage Management.*
