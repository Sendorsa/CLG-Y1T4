-- Lab Questions — SQL Query Answers
-- Based on the Student Management System schema (departments, students, instructors, courses, course_enrollments)

-- ============================================================
-- Q1. Show all student records
-- ============================================================
SELECT * FROM students;

-- ============================================================
-- Q2. Show only student names, cities, and CGPA
-- ============================================================
SELECT student_name, city, cgpa FROM students;

-- ============================================================
-- Q3. Show all unique cities students belong to
-- ============================================================
SELECT DISTINCT city FROM students;

-- ============================================================
-- Q4. Find students whose CGPA is greater than 8.5
-- ============================================================
SELECT * FROM students WHERE cgpa > 8.5;

-- ============================================================
-- Q5. Find students from Delhi
-- ============================================================
SELECT * FROM students WHERE city = 'Delhi';

-- ============================================================
-- Q6. Find female students from Bangalore
-- ============================================================
SELECT * FROM students WHERE gender = 'Female' AND city = 'Bangalore';

-- ============================================================
-- Q7. Display students sorted by CGPA from highest to lowest
-- ============================================================
SELECT * FROM students ORDER BY cgpa DESC;

-- ============================================================
-- Q8. Show the top 5 students according to CGPA
-- ============================================================
SELECT * FROM students ORDER BY cgpa DESC LIMIT 5;

-- ============================================================
-- Q9. Display students sorted by admission year first,
--     then CGPA highest to lowest
-- ============================================================
SELECT * FROM students ORDER BY admission_year ASC, cgpa DESC;
