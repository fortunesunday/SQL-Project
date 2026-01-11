
USE company_data

CREATE TABLE employees(
emp_id INT PRIMARY KEY,
name VARCHAR(50),
department VARCHAR(50),
hire_date DATE,
salary INT 
);

INSERT INTO employees()
VALUES
(101, 'Jane Doe', 'IT', '2021-06-15', 75000),
(102, 'Michael Smith', 'Finance', '2020-03-10', 82000),
(103, 'Aisha Bello', 'HR', '2022-01-25', 64000),
(104, 'David Johnson', 'Marketing', '2019-11-05', 90000),
(105, 'Grace Udo', 'Engineering', '2023-05-14', 78000),
(106, 'Tunde Olayemi', 'Logistics', '2018-09-19', 72000),
(107, 'Caroline Peters', 'Procurement', '2022-07-28', 69000),
(108, 'Samuel Eze', 'IT', '2021-02-01', 80000),
(109, 'Fatima Yusuf', 'Finance', '2020-12-22', 85000),
(110, 'Emmanuel Okon', 'Engineering', '2019-08-30', 91000);


CREATE TABLE projects(
project_id INT PRIMARY KEY,
emp_id INT,
project_name VARCHAR(50),
hours_worked INT,
FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

INSERT INTO projects()
VALUES
(201, 101, 'Website Redesign', 120),
(202, 102, 'Budget Forecast 2024', 95),
(203, 103, 'Employee Wellness Program', 80),
(204, 104, 'Product Launch Campaign', 150),
(205, 105, 'Bridge Construction Plan', 170),
(206, 106, 'Supply Chain Optimization', 110),
(207, 107, 'Vendor Evaluation System', 130),
(208, 108, 'Cybersecurity Upgrade', 100),
(209, 109, 'Tax Compliance Review', 90),
(210, 110, 'Machine Design Project', 140);

select * from employees;
select * from projects;

-- ------------------------SECTION A-----------------------
/*
Question 1
Create a CTE that shows the total hours worked by each
employee across all projects.
*/

WITH work_hours AS(
SELECT e.emp_id, e.name, p.project_name, SUM(p.hours_worked) AS total_hours
FROM employees e
JOIN projects p
ON e.emp_id = p.emp_id
GROUP BY e.emp_id, e.name, p.project_name
)
SELECT *
FROM work_hours;

/*
Question 2
Using another CTE, display only those employees 
whose total hours exceed the company average.
*/

WITH large_work_hours AS(
SELECT e.emp_id, e.name, p.hours_worked
FROM employees e
JOIN projects p
ON e.emp_id = p.emp_id
WHERE p.hours_worked > (SELECT AVG(hours_worked) FROM projects)
)
SELECT * FROM large_work_hours;

-- ------------------------SECTION B-----------------------
/*
Question 3
Write a query to calculate the total hours worked per
department and overall total (ROLLUP simulation).
*/

SELECT e.department, SUM(p.hours_worked) AS total_hours
FROM employees e
JOIN projects p
ON e.emp_id = p.emp_id
GROUP BY ROLLUP(e.department)

/*
Question 4
Write a query to calculate total project hours
by department and project (CUBE simulation).
*/

SELECT e.department, p.project_name, SUM(p.hours_worked) AS total_hours
FROM employees e
JOIN projects p
ON e.emp_id = p.emp_id
GROUP BY ROLLUP(e.department, p.project_name);

-- ------------------------SECTION C-----------------------
/*
Question 5
Use ROW_NUMBER() to assign a sequential number to
employees ordered by salary (highest to lowest).
*/

SELECT emp_id, name, salary, ROW_NUMBER() OVER (ORDER BY salary DESC) AS salary_rank
FROM employees

/* Question 6
Use RANK() to display employee rankings based on salary
(handling ties).
*/
SELECT emp_id, name, salary, RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM employees

/* 
Question 7
 Use LEAD() and LAG() to show each employee’s previous and next employee’s salary
 in the list.
*/

SELECT emp_id, name, salary, 
	LAG(salary) OVER(ORDER BY salary) AS previous_salary,
	LEAD(salary) OVER(ORDER BY salary) AS next_salary
FROM employees;

-- ------------------------SECTION D-----------------------
/* 
Question 8
Display the number of years each employee has worked in the
company (based on the current date).
*/

SELECT emp_id, name, TIMESTAMPDIFF(YEAR, hire_date, NOW()) AS number_of_work_years
FROM employees

/* 
Question 9
List employees hired in the last 2 years.
*/

SELECT emp_id, name, TIMESTAMPDIFF(YEAR, hire_date, NOW()) AS number_of_work_years
FROM employees
WHERE TIMESTAMPDIFF(YEAR, hire_date, NOW()) <= 2

/* 
Question 10
Extract the month name from each employee’s hire_date.
*/

SELECT emp_id, name, hire_date, DATE_FORMAT(hire_date, '%M') AS hire_month
FROM employees

-- ------------------------BONUS-----------------------
/*
Use a CTE combined with a window function to calculate each employee’s:
 • Total project hours
 • Rank of employees by total hours worked
*/

WITH total_project_hours_per_employee AS(
SELECT e.emp_id, e.name, SUM(p.hours_worked) AS total_work_hours
FROM employees e
JOIN projects p
ON e.emp_id = p.emp_id
GROUP BY ROLLUP(e.emp_id, e.name)
)
SELECT * FROM total_project_hours_per_employee;


WITH work_hours_ranking AS(
SELECT e.emp_id, e.name, SUM(p.hours_worked) AS total_work_hours,
RANK() OVER(ORDER BY SUM(p.hours_worked) DESC) AS ranking
FROM employees e
JOIN projects p
ON e.emp_id = p.emp_id
GROUP BY e.emp_id, e.name
)
SELECT * FROM work_hours_ranking;


