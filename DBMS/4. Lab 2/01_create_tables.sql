-- Lab 2: Database Setup
CREATE DATABASE dbms_lab2_groupA;
USE dbms_lab2_groupA;

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL
);

CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50) NOT NULL,
    age INT,
    gender VARCHAR(10),
    dept_id INT,
    city VARCHAR(50),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

CREATE TABLE instructors (
    instructor_id INT PRIMARY KEY,
    instructor_name VARCHAR(50) NOT NULL,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(80) NOT NULL,
    dept_id INT,
    instructor_id INT,
    credits INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id),
    FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id)
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    grade VARCHAR(2),
    status VARCHAR(20),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    student_id INT,
    amount INT,
    payment_status VARCHAR(20),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);

CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    classes_attended INT,
    total_classes INT,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

CREATE TABLE exam_results (
    result_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    marks INT,
    max_marks INT,
    result_status VARCHAR(20),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- ===== INSERT DATA =====

INSERT INTO departments VALUES
(1, 'Computer Science'),
(2, 'Mathematics'),
(3, 'Electronics'),
(4, 'Mechanical'),
(5, 'Civil');

INSERT INTO students VALUES
(101, 'Aarav', 20, 'Male', 1, 'Bangalore'),
(102, 'Riya', 21, 'Female', 1, 'Delhi'),
(103, 'Karan', 22, 'Male', 2, 'Mumbai'),
(104, 'Neha', 20, 'Female', 2, 'Pune'),
(105, 'Rahul', 23, 'Male', 3, 'Bangalore'),
(106, 'Sneha', 21, 'Female', 3, 'Chennai'),
(107, 'Vikram', 24, 'Male', 4, 'Hyderabad'),
(108, 'Ananya', 22, 'Female', 1, 'Bangalore'),
(109, 'Kabir', 20, 'Male', 5, 'Jaipur'),
(110, 'Meera', 21, 'Female', NULL, 'Kolkata'),
(111, 'Ishaan', 22, 'Male', 1, 'Delhi'),
(112, 'Priya', 23, 'Female', 4, 'Mumbai'),
(113, 'Dev', 20, 'Male', 2, 'Lucknow'),
(114, 'Tanya', 21, 'Female', 5, 'Bangalore'),
(115, 'Arjun', 23, 'Male', NULL, 'Delhi');

INSERT INTO instructors VALUES
(201, 'Dr. Sharma', 1),
(202, 'Dr. Menon', 2),
(203, 'Prof. Iyer', 3),
(204, 'Prof. Rao', 1),
(205, 'Dr. Khan', 4);

INSERT INTO courses VALUES
(301, 'Database Management Systems', 1, 201, 4),
(302, 'Data Structures', 1, 204, 4),
(303, 'Discrete Mathematics', 2, 202, 3),
(304, 'Linear Algebra', 2, 202, 3),
(305, 'Digital Electronics', 3, 203, 4),
(306, 'Thermodynamics', 4, 205, 4),
(307, 'Operating Systems', 1, 201, 4),
(308, 'Structural Engineering', 5, NULL, 3),
(309, 'Probability and Statistics', 2, 202, 3),
(310, 'Engineering Drawing', 5, NULL, 2);

INSERT INTO enrollments VALUES
(401, 101, 301, 'A', 'Active'),
(402, 101, 302, 'B', 'Active'),
(403, 102, 301, 'A', 'Active'),
(404, 102, 307, 'B', 'Active'),
(405, 103, 303, 'B', 'Active'),
(406, 104, 304, 'A', 'Active'),
(407, 105, 305, 'C', 'Active'),
(408, 106, 305, 'B', 'Active'),
(409, 107, 306, 'B', 'Active'),
(410, 108, 301, 'A', 'Active'),
(411, 108, 302, 'A', 'Active'),
(412, 111, 307, 'C', 'Dropped'),
(413, 112, 306, 'A', 'Active'),
(414, 113, 309, 'B', 'Active'),
(415, 114, 310, NULL, 'Active'),
(416, 115, 301, NULL, 'Active');

INSERT INTO payments VALUES
(501, 101, 50000, 'Paid'),
(502, 102, 50000, 'Paid'),
(503, 103, 45000, 'Pending'),
(504, 104, 45000, 'Paid'),
(505, 105, 48000, 'Pending'),
(506, 106, 48000, 'Paid'),
(507, 107, 47000, 'Paid'),
(508, 108, 50000, 'Pending'),
(509, 111, 50000, 'Paid'),
(510, 113, 45000, 'Paid'),
(511, 114, 42000, 'Pending');

INSERT INTO attendance VALUES
(601, 101, 301, 18, 20),
(602, 101, 302, 15, 20),
(603, 102, 301, 19, 20),
(604, 102, 307, 13, 20),
(605, 103, 303, 14, 20),
(606, 104, 304, 17, 20),
(607, 105, 305, 10, 20),
(608, 106, 305, 16, 20),
(609, 107, 306, 12, 20),
(610, 108, 301, 20, 20),
(611, 108, 302, 19, 20),
(612, 111, 307, 8, 20),
(613, 112, 306, 18, 20),
(614, 113, 309, 16, 20),
(615, 114, 310, 11, 20),
(616, 115, 301, 9, 20);

INSERT INTO exam_results VALUES
(701, 101, 301, 88, 100, 'Pass'),
(702, 101, 302, 76, 100, 'Pass'),
(703, 102, 301, 91, 100, 'Pass'),
(704, 102, 307, 62, 100, 'Pass'),
(705, 103, 303, 58, 100, 'Pass'),
(706, 104, 304, 82, 100, 'Pass'),
(707, 105, 305, 38, 100, 'Fail'),
(708, 106, 305, 72, 100, 'Pass'),
(709, 107, 306, 45, 100, 'Pass'),
(710, 108, 301, 95, 100, 'Pass'),
(711, 108, 302, 89, 100, 'Pass'),
(712, 111, 307, 32, 100, 'Fail'),
(713, 112, 306, 84, 100, 'Pass'),
(714, 113, 309, 69, 100, 'Pass'),
(715, 114, 310, 41, 100, 'Pass'),
(716, 115, 301, 35, 100, 'Fail');
