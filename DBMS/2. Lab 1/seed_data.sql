-- ============================================
-- Student Management System – Seed Data
-- Course: Data Analytics
-- ============================================

-- ---------- departments ----------
INSERT INTO departments (department_name, building) VALUES
('Computer Science',       'Block A'),
('Electronics',            'Block B'),
('Mechanical',             'Block C'),
('Civil',                  'Block D'),
('Information Technology', 'Block E');

-- ---------- instructors ----------
INSERT INTO instructors (instructor_name, email, department_id, joining_year) VALUES
('Dr. Rajesh Kumar',   'rajesh.kumar@college.edu',  1, 2015),
('Prof. Anita Sharma', 'anita.sharma@college.edu',  1, 2018),
('Dr. Meera Iyer',     'meera.iyer@college.edu',    2, 2016),
('Prof. Vikram Rao',   'vikram.rao@college.edu',    2, 2020),
('Dr. Sanjay Verma',   'sanjay.verma@college.edu',  3, 2014),
('Prof. Kavita Joshi', 'kavita.joshi@college.edu',  3, 2019),
('Dr. Arvind Menon',   'arvind.menon@college.edu',  4, 2017),
('Prof. Nisha Kapoor', 'nisha.kapoor@college.edu',  5, 2021);

-- ---------- courses ----------
INSERT INTO courses (course_code, course_name, credits, department_id, instructor_id) VALUES
('CS101', 'Database Management Systems',  4, 1, 1),
('CS102', 'Data Structures',              4, 1, 2),
('CS103', 'Operating Systems',            4, 1, 1),
('IT101', 'Web Development',              3, 5, 8),
('IT102', 'Computer Networks',            4, 5, 8),
('EC101', 'Digital Electronics',          3, 2, 3),
('EC102', 'Signals and Systems',          4, 2, 4),
('ME101', 'Thermodynamics',               4, 3, 5),
('ME102', 'Machine Design',               3, 3, 6),
('CE101', 'Structural Engineering',       4, 4, 7);

-- ---------- students ----------
INSERT INTO students (roll_number, student_name, email, phone, gender, date_of_birth, city, department_id, admission_year, cgpa) VALUES
('STU001', 'Aarav Sharma',   'aarav.sharma@gmail.com',   '9000000001', 'M', '2003-04-12', 'Delhi',       1, 2022, 8.7),
('STU002', 'Ananya Verma',   'ananya.verma@gmail.com',   '9000000002', 'F', '2003-08-21', 'Mumbai',      1, 2022, 9.1),
('STU003', 'Rohan Gupta',    'rohan.gupta@gmail.com',    '9000000003', 'M', '2002-12-05', 'Bangalore',   1, 2021, 7.8),
('STU004', 'Priya Nair',     'priya.nair@gmail.com',     '9000000004', 'F', '2003-01-18', 'Chennai',     1, 2022, 8.3),
('STU005', 'Kabir Singh',    'kabir.singh@gmail.com',    '9000000005', 'M', '2002-09-30', 'Delhi',       5, 2021, 6.9),
('STU006', 'Sneha Iyer',     'sneha.iyer@gmail.com',     '9000000006', 'F', '2003-06-15', 'Bangalore',   5, 2022, 9.4),
('STU007', 'Aditya Rao',     'aditya.rao@gmail.com',     '9000000007', 'M', '2002-11-11', 'Hyderabad',   5, 2021, 7.5),
('STU008', 'Meera Kapoor',   'meera.kapoor@gmail.com',   '9000000008', 'F', '2003-03-25', 'Pune',        5, 2022, 8.9),
('STU009', 'Rahul Jain',     'rahul.jain@gmail.com',     '9000000009', 'M', '2002-05-09', 'Jaipur',      2, 2021, 7.2),
('STU010', 'Isha Patel',     'isha.patel@gmail.com',     '9000000010', 'F', '2003-10-14', 'Ahmedabad',   2, 2022, 8.6),
('STU011', 'Vikram Das',     'vikram.das@gmail.com',     '9000000011', 'M', '2002-07-20', 'Kolkata',     2, 2021, 6.8),
('STU012', 'Simran Kaur',    'simran.kaur@gmail.com',    '9000000012', 'F', '2003-02-02', 'Chandigarh',  2, 2022, 9.0),
('STU013', 'Arjun Menon',    'arjun.menon@gmail.com',    '9000000013', 'M', '2002-04-19', 'Kochi',       3, 2021, 7.9),
('STU014', 'Neha Reddy',     'neha.reddy@gmail.com',     '9000000014', 'F', '2003-09-08', 'Hyderabad',   3, 2022, 8.1),
('STU015', 'Karan Malhotra', 'karan.malhotra@gmail.com', '9000000015', 'M', '2002-01-29', 'Delhi',       3, 2021, 6.5),
('STU016', 'Pooja Shah',     'pooja.shah@gmail.com',     '9000000016', 'F', '2003-05-17', 'Surat',       3, 2022, 8.4),
('STU017', 'Deepak Yadav',   'deepak.yadav@gmail.com',   '9000000017', 'M', '2002-08-10', 'Patna',       4, 2021, 7.1),
('STU018', 'Riya Sen',       'riya.sen@gmail.com',       '9000000018', 'F', '2003-11-23', 'Kolkata',     4, 2022, 8.8),
('STU019', 'Varun Mehta',    'varun.mehta@gmail.com',    '9000000019', 'M', '2002-06-06', 'Indore',      4, 2021, 7.6),
('STU020', 'Nikita Joshi',   'nikita.joshi@gmail.com',   '9000000020', 'F', '2003-12-12', 'Nagpur',      4, 2022, 9.2),
('STU021', 'Sahil Khan',     'sahil.khan@gmail.com',     '9000000021', 'M', '2002-03-03', 'Bhopal',      1, 2021, 6.7),
('STU022', 'Tanvi Agarwal',  'tanvi.agarwal@gmail.com',  '9000000022', 'F', '2003-07-07', 'Lucknow',     1, 2022, 8.0),
('STU023', 'Harsh Vardhan',  'harsh.vardhan@gmail.com',  '9000000023', 'M', '2002-10-22', 'Delhi',       5, 2021, 7.3),
('STU024', 'Aditi Mishra',   'aditi.mishra@gmail.com',   '9000000024', 'F', '2003-04-04', 'Mumbai',      5, 2022, 8.5),
('STU025', 'Nikhil Bansal',  'nikhil.bansal@gmail.com',  '9000000025', 'M', '2002-09-16', 'Pune',        2, 2021, 7.7),
('STU026', 'Shreya Ghosh',   'shreya.ghosh@gmail.com',   '9000000026', 'F', '2003-01-01', 'Kolkata',     2, 2022, 9.3),
('STU027', 'Manav Sinha',    'manav.sinha@gmail.com',    '9000000027', 'M', '2002-02-14', 'Ranchi',      3, 2021, 6.2),
('STU028', 'Kriti Saxena',   'kriti.saxena@gmail.com',   '9000000028', 'F', '2003-06-28', 'Noida',       3, 2022, 8.2),
('STU029', 'Yash Thakur',    'yash.thakur@gmail.com',    '9000000029', 'M', '2002-12-31', 'Shimla',      4, 2021, 7.4),
('STU030', 'Manya Choudhary','manya.choudhary@gmail.com','9000000030', 'F', '2003-08-05', 'Jaipur',      4, 2022, 8.7);

-- ---------- course_enrollments ----------
INSERT INTO course_enrollments (student_id, course_id, enrollment_date, semester, grade) VALUES
(1,  1,  '2024-01-10', 4, 'A'),
(1,  2,  '2024-01-11', 4, 'A'),
(2,  1,  '2024-01-10', 4, 'A+'),
(2,  3,  '2024-01-12', 4, 'A'),
(3,  1,  '2024-01-13', 5, 'B+'),
(3,  2,  '2024-01-14', 5, 'B'),
(4,  3,  '2024-01-15', 4, 'A'),
(4,  4,  '2024-01-16', 4, 'B+'),
(5,  4,  '2024-01-17', 5, 'C'),
(5,  5,  '2024-01-18', 5, 'B'),
(6,  4,  '2024-01-19', 4, 'A+'),
(6,  5,  '2024-01-20', 4, 'A'),
(7,  5,  '2024-01-21', 5, 'B+'),
(8,  1,  '2024-01-22', 4, 'A'),
(8,  4,  '2024-01-23', 4, 'A'),
(9,  6,  '2024-01-24', 5, 'B'),
(9,  7,  '2024-01-25', 5, 'B+'),
(10, 6,  '2024-01-26', 4, 'A'),
(10, 7,  '2024-01-27', 4, 'A'),
(11, 6,  '2024-01-28', 5, 'C'),
(12, 7,  '2024-01-29', 4, 'A+'),
(13, 8,  '2024-01-30', 5, 'B+'),
(13, 9,  '2024-02-01', 5, 'B'),
(14, 8,  '2024-02-02', 4, 'A'),
(15, 9,  '2024-02-03', 5, 'C'),
(16, 8,  '2024-02-04', 4, 'A'),
(16, 9,  '2024-02-05', 4, 'B+'),
(17, 10, '2024-02-06', 5, 'B'),
(18, 10, '2024-02-07', 4, 'A'),
(19, 10, '2024-02-08', 5, 'B+'),
(20, 10, '2024-02-09', 4, 'A+'),
(21, 1,  '2024-02-10', 5, 'C'),
(22, 2,  '2024-02-11', 4, 'B+'),
(23, 4,  '2024-02-12', 5, 'B'),
(24, 5,  '2024-02-13', 4, 'A'),
(25, 6,  '2024-02-14', 5, 'B+'),
(26, 7,  '2024-02-15', 4, 'A+'),
(27, 8,  '2024-02-16', 5, 'C'),
(28, 9,  '2024-02-17', 4, 'A'),
(29, 10, '2024-02-18', 5, 'B'),
(30, 10, '2024-02-19', 4, 'A');
