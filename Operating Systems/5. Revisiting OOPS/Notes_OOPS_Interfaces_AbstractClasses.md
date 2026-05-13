# OOPS: Interfaces and Abstract Classes - Detailed Notes

## 1. Introduction to OOPS (Object-Oriented Programming)

### Why OOPS?
- Mimics real-world entities in programming
- Alternatives: Procedural Programming, Functional Programming
- OOPS is important because objects represent real-world concepts

### Core Concepts Covered
1. Classes & Objects
2. Constructors
3. Inheritance
4. Method Overriding
5. Polymorphism
6. Abstract Classes
7. Interfaces
8. Runnable Interface (for threads)

### Real-World Object Examples
| Real-life Object | Properties (Variables) | Actions (Methods) |
|---|------|------|
| **Student** | name, roll number, batch | `study()`, `attendClass()` |
| **Phone** | brand, battery, price | `call()`, `charge()` |
| **Car** | color, speed, model | `start()`, `stop()` |
| **Process** | process ID, state, burst time | `run()`, `wait()`, `terminate()` |

---

---

## 2. Classes and Objects

| Concept | Description |
|---------|-------------|
| **Class** | A blueprint that defines variables (attributes) and methods |
| **Object** | A real-world instance of a class containing actual data. Created using the `new` keyword and inherently **occupies space in memory**. Note: A class itself **does not occupy memory**. |

### Example - Process Class
```java
class Process {
    int PID;
    String processName;
    String state;
    
    void displayInfo() {
        System.out.println("Process: " + processName + ", PID: " + PID + ", State: " + state);
    }
}
```

---

## 3. Constructors

### What is a Constructor?
- A special method that **runs automatically** when an object is created
- Placed values into the object at creation time

### Rules of a Constructor
| Rule | Detail |
|------|--------|
| Name | Must be **same** as the class name |
| Return Type | **None** (not even `void`) |
| Purpose | Assign default/initial values to object attributes |

### Constructor Example
```java
class Process {
    int PID;
    String processName;
    String state;
    
    // Constructor
    Process(int PID, String processName, String state) {
        this.PID = PID;
        this.processName = processName;
        this.state = state;
    }
}

// Using the constructor
Process p1 = new Process(1, "Chrome", "Running");
Process p2 = new Process(2, "Firefox", "Ready");
```

### Key Points
- If **no constructor** is written, Java provides a **default (no-arg) constructor**
- Once you define your own constructor, Java no longer provides the default
- `this.` keyword distinguishes between class attributes and constructor parameters

---

## 4. Inheritance

### Why Inheritance?
- Prevents **code repetition**
- Child classes inherit **common properties and methods** from a parent class
- Key principle: **DRY (Don't Repeat Yourself)**

### Example - With Code Repetition (No Inheritance)
```java
// Without inheritance: repeating name and ID in every class
class Student { String name; int ID; }
class Teacher { String name; int ID; }
class Staff { String name; int ID; }
// Every class repeats the same attributes → code repetition
```

### Example - With Inheritance (No Repetition)
```java
// Parent class
class User {
    String name;
    int ID;
    void login() { System.out.println(name + " is logged in"); }
}

// Child classes inherit from User
class Student extends User {
    String course;
    void attendClass() { System.out.println(name + " is attending " + course); }
}

class Teacher extends User {
    void teach() { System.out.println(name + " is teaching"); }
}

// Usage
Student s1 = new Student();
s1.name = "John";  // inherited from User
s1.course = "Java";
s1.login();       // inherited method
s1.attendClass(); // class-specific method
```

### Key Points
| Keyword | Purpose |
|---------|---------|
| `extends` | To inherit from a parent **class** |
| `implements` | To implement an **interface** |
| `Access Modifiers` | Child can access `public` and `protected` members of parent, **not** `private` |

---

## 5. Method Overriding

### What is Method Overriding?
- When a child class provides its **own implementation** of a method already defined in the parent class
- Method name and parameters must be the **same**

### Why is it Important?
- **Procedural programming**: Parent controls everything in child (real-world doesn't work this way)
- **OOP**: Child has its own "will" — gives its own version of a method
- Example: `animal.sound()` — Dog barks, Cat meows (different behaviors)

### Example
```java
class User {
    void showRole() { System.out.println("I am a user"); }
}

class Student extends User {
    @Override
    void showRole() { System.out.println("I am a student"); }  // overrides parent
}

class Teacher extends User {
    @Override
    void showRole() { System.out.println("I am a teacher"); }  // overrides parent
}

// Usage
Student s1 = new Student();
s1.showRole();  // Output: "I am a student" (child's method runs)

Teacher t1 = new Teacher();
t1.showRole();  // Output: "I am a teacher" (child's method runs)
```

### Key Points
- Child's method **always** overrides parent's method
- Same method name → child's version takes precedence
- Real-world analogy: Children don't blindly follow parents; they have their own actions

---

## 6. Polymorphism

### What is Polymorphism?
- **"Poly" = Many, "Morph" = Forms**
- One **interface** used for **different data types**
- One thing taking **multiple forms**
- Parent class reference holding child class objects
- Key point: OOPS promotes **code reusability, flexibility, and maintainability**
- Same call → different output depending on actual object

### Example
```java
Animal a1 = new Dog();   // Reference type: Animal, Actual object: Dog
Animal a2 = new Cat();   // Reference type: Animal, Actual object: Cat

a1.sound();  // Dog barks
a2.sound();  // Cat meows
```

### Polymorphism in Arrays
```java
// Storing 100 users with different roles in a single array
User[] users = new User[100];
users[0] = new Student();
users[1] = new Teacher();
users[2] = new Admin();

// Iterate and call — polymorphism handles different forms
for (User user : users) {
    user.showRole();  // Each user displays its own role
}
```

### How It Works
| Left Side (Reference Type) | Right Side (Actual Object) |
|---------------------------|---------------------------|
| `Animal a1` | `new Dog()` → actual object is Dog |
| `Playable p` | `new Song()` → actual object is Song |

### Key Points
- Left side = gives you the **reference type**
- Right side = creates the **actual object**
- Enables **extensibility** — add new child classes without modifying existing code
- Works with both **inheritance** and **interfaces**

---

## 7. Abstract Classes

### What is an Abstract Class?
- A **general idea** that is **incomplete**
- Combines **normal methods** (with body) + **abstract methods** (no body)
- Analogy: Abstract painting → general idea, how to interpret depends on viewer

### Example
```java
abstract class Vehicle {
    // Normal method (complete implementation)
    void start() { System.out.println("Vehicle is starting"); }
    
    // Abstract method (no body — child must implement)
    abstract void move();
}

class Car extends Vehicle {
    @Override
    void move() { System.out.println("Car moves on the road"); }
}

class Boat extends Vehicle {
    @Override
    void move() { System.out.println("Boat moves on water"); }
}

// Usage
Car c = new Car();
c.start();  // "Vehicle is starting" (from abstract parent)
c.move();   // "Car moves on the road" (from child)
```

### Why Can't You Create an Object of an Abstract Class?
- Abstract methods have **no body** → no implementation
- If you create an object and call `move()`, Java wouldn't know what to do
- Real-world analogy: A vehicle that doesn't know how to stop shouldn't run on roads
- Children inherit the abstract class and provide the missing implementation

### Real-World Analogy: The Bird Example
Imagine **Bird** as an abstract class:
- Common attributes: `breed`, `eat()`
- Abstract method: `fly()`

But wait! **Not only birds fly**:
- Sparrow → flies with wings
- Penguin → swims (doesn't fly)
- Chicken → flaps (limited flying)
- Insect → flies with wings
- Fish → doesn't fly (swims)
- Bat → flies with wings
- Airplane → flies with engines
- Superman → flies with superpower

**Problem**: If `fly()` is in `Bird` abstract class, only Bird subclasses can use it.
**Solution**: Use an **Interface** called `Flyable` for this capability.

---

## 8. Interfaces

### What is an Interface?
- A **contract** or **rule book** — defines **what** to do, not **how**
- Used when a **capability** needs to be shared across unrelated classes
- Analogy: "Flying" is not specific to birds; insects, planes, bats can all fly

### Example - The Bird Problem
```java
// If fly is in Bird abstract class, only subclasses of Bird can use it
// But insects, planes, superheroes also fly!

// Solution: Use an interface for the fly capability
interface Flyable {
    void fly();  // Everyone who implements this must define fly()
}
```

### Example - Playable Interface
```java
interface Playable {
    void play();  // Rule: Anything playable must have a play() method
}

class Song implements Playable {
    public void play() { System.out.println("Playing song"); }
}

class Video implements Playable {
    public void play() { System.out.println("Playing video"); }
}

class Game implements Playable {
    public void play() { System.out.println("Starting game"); }
}

// Polymorphism with interfaces
Playable p1 = new Song();
Playable p2 = new Video();
p1.play();  // "Playing song"
p2.play();  // "Playing video"
```

### Rules of Interfaces
| Rule | Detail |
|------|--------|
| Keyword | `interface` |
| Methods | By default `public` + `abstract` (no body) |
| Attributes | Must be `final` and `static` (constants) — not commonly used |
| Access | Cannot be `private` (everyone must be able to use it) |
| Class implementation | Use `implements` keyword |
| Object creation | Cannot create interface object directly (`Playable p = new Playable()` → Error) |
| Must implement | Any class implementing interface **must** provide body for all methods |

---

## 9. Runnable Interface (Java Built-in)

### Creating Your Own Runnable
```java
interface MyRunnable {
    void run();
}

class PrintTask implements MyRunnable {
    public void run() { System.out.println("Printing file"); }
}

class DownloadTask implements MyRunnable {
    public void run() { System.out.println("Downloading file"); }
}

class EmailTask implements MyRunnable {
    public void run() { System.out.println("Sending email"); }
}

// Using polymorphism
MyRunnable[] tasks = new MyRunnable[3];
tasks[0] = new PrintTask();
tasks[1] = new DownloadTask();
tasks[2] = new EmailTask();

for (MyRunnable task : tasks) {
    task.run();  // Each task runs its own implementation
}
```

### Using Java's Built-in Runnable
```java
import java.lang.Runnable;

class PrintTask implements Runnable {
    public void run() { System.out.println("Printing file"); }
}

class DownloadTask implements Runnable {
    public void run() { System.out.println("Downloading file"); }
}

// Same pattern — replace MyRunnable with Runnable
Runnable[] tasks = new Runnable[3];
tasks[0] = new PrintTask();
// ... same as above
```

### Key Insight
- **`Runnable` is Java's built-in interface** — already exists in `java.lang`
- Only has one method: `run()`
- Essential for **threading** (next class topic)

---

## 10. Abstract Class vs Interface - Comparison

| Basis | Abstract Class | Interface |
|-------|---------------|-----------|
| **Purpose** | Defines **what something IS** (identity) | Defines **what something CAN DO** (capability) |
| **Methods** | Normal + abstract methods | Only abstract methods (by default) |
| **Attributes** | Can have normal attributes | Must be `final` |
| **Inheritance** | `extends` (single inheritance) | `implements` (multiple allowed) |
| **Object Creation** | Cannot create object | Cannot create object |
| **Use When** | Classes are closely related | Classes are unrelated but share a capability |
| **Example** | `Vehicle → Car, Boat` | `Playable → Song, Video` |

---

## 11. Types of Inheritance

| Type | Description | Supported in Java? |
|------|-------------|-------------------|
| **Single** | One parent, one child | Yes |
| **Multilevel** | Grandparent → Parent → Child | Yes |
| **Multiple** | Two parents, one child | **No** (Diamond Problem) |
| **Multiple via Interfaces** | Two or more interfaces implemented by one class | **Yes** (workaround for multiple inheritance) |

### The Diamond Problem (Why Multiple Inheritance is Forbidden)
```
   Parent A      Parent B
       \          /
        \        /
       (Same method name?)
             |
         Child Class
```
- If both parents have a method with the same name, **Java doesn't know which one to use**
- **Solution**: Use interfaces (methods are abstract → no conflict)

---

## 12. Summary Cheat Sheet

| Concept | Keyword | Can Create Object? | Summary |
|---------|---------|-------------------|---------|
| Class | `class` | Yes | Blueprint with attributes + methods |
| Constructor | Same as class name | — | Initializes object |
| Inheritance | `extends` | — | Child inherits parent properties |
| Method Overriding | `@Override` | — | Child gives own method implementation |
| Polymorphism | — | — | One reference, multiple forms |
| Abstract Class | `abstract class` | No | Incomplete parent; normal + abstract methods |
| Abstract Method | `abstract` (no body) | — | Child must implement |
| Interface | `interface` | No | Rule book; classes must implement |
| Implement Interface | `implements` | — | A class implements, doesn't extend, an interface |

---

## 13. Real-World Takeaways

1. **Use abstract classes** when defining common identity/attributes for closely related classes
2. **Use interfaces** when adding a shared capability across unrelated classes
3. **Polymorphism** enables writing flexible, extensible code (add new types without breaking old code)
4. **Method overriding** gives each subclass its own behavior
5. **`Runnable` interface** is the foundation of Java threading — you'll use it extensively for concurrency
6. **Constructors** make object creation cleaner by bundling initialization

---

## 14. Practice Problem (From PDF)

Create an **interface `Executable`**:
```java
interface Executable {
    void execute();
}
```

Create classes that implement it:
- `PrintJob` — prints "Printing document..."
- `DownloadJob` — prints "Downloading file..."
- `EmailJob` — prints "Sending email..."

Store in array and loop:
```java
Executable[] jobs = {
    new PrintJob(),
    new DownloadJob(),
    new EmailJob()
};

for (Executable job : jobs) {
    job.execute();
}
```

**Main concept**: One interface, many objects, same method call, different behavior.

---

## 15. Homework Assignment

Create an **abstract class `Task`** with:
- Attribute: `taskName`
- Abstract method: `void execute()`

Then create **child classes** that extend `Task`:
- `PrintTask` — prints a file
- `DownloadTask` — downloads a file
- `CalculateTask` — performs calculations
- `DetectTask` — performs detection
- `EmailTask` — sends an email

Use the interface/polymorphism pattern to run all tasks together.

---

## 15. Quiz Answers (In-Class Review)

### On Constructors
- **Q1:** Constructor will never have a return type.
  - **A:** True. `void` is also a return type — constructors have **no** return type at all.
- **Q2:** The job of a constructor is to assign values.
  - **A:** True. Until an object is created, a class has no values to assign. The constructor runs the moment the object is created.

### On Inheritance
- **Q1:** Which keyword is used to inherit properties of a class?
  - **A:** `extends` (not `implements` — that is for interfaces).
- **Q2:** The child class can access which members of the parent?
  - **A:** `public` and `protected` members. `private` members are **not** accessible.

### On Method Overriding
- **Q1:** Method overriding is not just having the same name.
  - **A:** True. The child class must provide its **own implementation** (body) of the method.
- **Q2:** If child and parent have a method with the same name, whose method runs?
  - **A:** The **child's** method runs. This is the entire point of overriding.

### On Polymorphism
- **Q1:** What does the left side of `Animal a1 = new Dog()` give you?
  - **A:** The **reference type** (`Animal`). You can only call methods available on the reference type.
- **Q2:** What is on the right side of the assignment?
  - **A:** The **actual object** (`Dog`). The runtime behavior (which method body runs) depends on the actual object.

### On Abstract Classes
- **Q1:** Can you create an object of an abstract class?
  - **A:** **No.** `new Vehicle()` where `Vehicle` is abstract → compilation error: *"abstract class cannot be instantiated."*
- **Q2:** Why can't an abstract class have an object?
  - **A:** Because it contains abstract methods with **no body**. No implementation → no sensible behavior → no object.
- **Q3:** What is the return type of an abstract method?
  - **A:** `void` (or another type), but `void` is still a return type. The key is the method has **no body**.

### On Interfaces
- **Q1:** Can you create an object of an interface directly?
  - **A:** **No.** `new Playable()` → compilation error. Interfaces have no implementation.
- **Q2:** What is possible for interfaces?
  - **A:** `Playable p = new Song()` — reference type is interface, actual object is the implementing class.
- **Q3:** How is a class linked to an interface?
  - **A:** Using the keyword **`implements`**.
- **Q4:** How is a class linked to an abstract class?
  - **A:** Using the keyword **`extends`**.

### On Abstract Class vs Interface
- **Q1:** Use abstract class when?
  - **A:** When defining **what something IS** (identity) — for closely related classes.
- **Q2:** Use interface when?
  - **A:** When defining **what something CAN DO** (capability) — for unrelated classes sharing a behavior.
- **Q3:** Interface methods are by default?
  - **A:** `public` and `abstract`.
- **Q4:** Interface attributes must be?
  - **A:** `final` and `static` (constants whose value cannot be changed).

### On Inheritance Types
- **Q1:** Java supports which types of inheritance?
  - **A:** **Single** and **multilevel** inheritance.
- **Q2:** Does Java support multiple inheritance with classes?
  - **A:** **No** — causes the Diamond Problem.
- **Q3:** How to achieve multiple inheritance in Java?
  - **A:** Use **interfaces** (a class can `implements` multiple interfaces since they have no conflicting implementation).

### On Runnable Interface
- **Q1:** What is `Runnable`?
  - **A:** A **built-in Java interface** (`java.lang.Runnable`) with a single method: `void run()`.
- **Q2:** Output when replacing a custom `MyRunnable` with Java's `Runnable`?
  - **A:** **Exactly the same output.** The pattern (polymorphism with an interface) works identically with any interface.

---

## 16. Upcoming Topics (Next Class)
## 18. Connection to Operating Systems

The last page explains **why OOPS revision matters** for OS concepts.

### Why OOPS matters for OS:
- **Processes** — modeled as objects with state (running, waiting, terminated)
- **Threads** — use `Runnable` interface for task execution
- **Synchronization** — OOPS helps manage shared resources
- **Semaphores** — OOPS objects that control access
- **Concurrency** — polymorphism enables different task behaviors

### OOPS concepts you'll heavily use:
- **Interfaces** → `Runnable`, thread definitions
- **Abstract Classes** → base classes for process/thread models
- **Polymorphism** → same interface, different thread implementations
- **Inheritance** → extending base Process/Thread classes

### Main takeaway:
**Understanding OOPS helps you understand Java threads, OS concepts, and concurrency.**
- **Process Sync** — Synchronization between processes
- **Mutex/Multicore Processing** — Resource management in OS
- **Runnable in detail** — Real threading implementation

---

## 19. Additional Quiz Questions

### Constructor
- **Q1:** When does a constructor run?
  - **A:** When an object is created

### Class & Object
- **Q2:** What is a class?
  - **A:** A blueprint or design for objects
- **Q3:** What is an object?
  - **A:** A real instance created from a class

### Constructor Syntax
- **Q4:** Which of these is a constructor for class Process?
  - **A:** `Process()`

### Inheritance
- **Q5:** Which keyword is used for inheritance in Java?
  - **A:** `extends`
- **Q6:** In inheritance, the child class can use:
  - **A:** Accessible members of parent class

### Method Overriding
- **Q7:** What is method overriding?
  - **A:** Child class giving its own version of parent class method

### Polymorphism
- **Q8:** In this code, what is the actual object type?
  ```java
  User u = new Student();
  ```
  - **A:** `Student`

### Abstract Class
- **Q9:** Can we create an object of an abstract class directly?
  - **A:** No
- **Q10:** An abstract method has:
  - **A:** No body

### Interface
- **Q11:** Which keyword is used by a class to use an interface?
  - **A:** `implements`
- **Q12:** If a class implements an interface, what does it promise to do?
  - **A:** It promises to provide implementation of the interface methods

---

*Notes compiled from the class: "Revisiting OOPS, Interfaces and Abstract Classes" by Class Scaler Academy*
