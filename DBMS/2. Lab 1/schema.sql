-- ============================================
-- Student Management System – Schema
-- Course: Data Analytics
-- ============================================

DROP TABLE IF EXISTS course_enrollments CASCADE;
DROP TABLE IF EXISTS students       CASCADE;
DROP TABLE IF EXISTS courses        CASCADE;
DROP TABLE IF EXISTS instructors    CASCADE;
DROP TABLE IF EXISTS departments    CASCADE;

-- ---------- departments ----------
CREATE TABLE departments (
    department_id   SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    building        VARCHAR(20)
);

-- ---------- students ----------
CREATE TABLE students (
    student_id      SERIAL PRIMARY KEY,
    roll_number     VARCHAR(20) NOT NULL UNIQUE,
    student_name    VARCHAR(100) NOT NULL,
    email           VARCHAR(150) NOT NULL UNIQUE,
    phone           VARCHAR(15) UNIQUE,
    gender          CHAR(1) CHECK (gender IN ('M','F')),
    date_of_birth   DATE,
    city            VARCHAR(50),
    department_id   INTEGER REFERENCES departments(department_id),
    admission_year  INTEGER CHECK (admission_year BETWEEN 2020 AND 2026),
    cgpa            NUMERIC(3,2) CHECK (cgpa >= 0 AND cgpa <= 10)
);

-- ---------- instructors ----------
CREATE TABLE instructors (
    instructor_id   SERIAL PRIMARY KEY,
    instructor_name VARCHAR(100) NOT NULL,
    email           VARCHAR(150) NOT NULL UNIQUE,
    department_id   INTEGER REFERENCES departments(department_id),
    joining_year    INTEGER CHECK (joining_year BETWEEN 2010 AND 2026)
);

-- ---------- courses ----------
CREATE TABLE courses (
    course_id       SERIAL PRIMARY KEY,
    course_code     VARCHAR(20) NOT NULL UNIQUE,
    course_name     VARCHAR(150) NOT NULL,
    credits         INTEGER NOT NULL CHECK (credits IN (1,2,3,4)),
    department_id   INTEGER REFERENCES departments(department_id),
    instructor_id   INTEGER REFERENCES instructors(instructor_id)
);

-- ---------- course_enrollments ----------
CREATE TABLE course_enrollments (
    enrollment_id   SERIAL PRIMARY KEY,
    student_id      INTEGER REFERENCES students(student_id),
    course_id       INTEGER REFERENCES courses(course_id),
    enrollment_date DATE NOT NULL,
    semester        CHAR(2) CHECK (semester IN ('1','2','3','4','5','6','7','8')),
    grade           VARCHAR(3) CHECK (grade IN ('A+','A','A-','B+','B','B-','C+','C','D','F','W'))
);
