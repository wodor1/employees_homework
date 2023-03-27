show databases;

CREATE DATABASE IF NOT EXISTS employees;

use employees;

-- első feladat ---
SELECT
	departments.dept_no,
    departments.dept_name,
    employees.gender,
    AVG(salaries.salary) AS avg_salary
FROM
    employees
    JOIN dept_emp ON employees.emp_no = dept_emp.emp_no
    JOIN departments ON dept_emp.dept_no = departments.dept_no
    JOIN salaries ON employees.emp_no = salaries.emp_no
GROUP BY
    departments.dept_name,
    employees.gender
ORDER BY
    departments.dept_no,
    employees.gender;

-- második feladat ---
SELECT MIN(dept_no), MAX(dept_no)
FROM dept_emp
ORDER BY dept_no
LIMIT 1;

-- harmadik feladat ---
SELECT DISTINCT 
    emp_no AS `emp_no`,
    (
        SELECT dept_no 
        FROM dept_emp 
        WHERE emp_no = t.emp_no 
        ORDER BY dept_no ASC 
        LIMIT 1
    ) AS `dept_no`,
    CASE 
        WHEN emp_no <= 10020 THEN 110022 
        WHEN emp_no >= 10021 AND emp_no <= 10040 THEN 110039 
    END AS `manager`
FROM 
    dept_emp t
WHERE 
    emp_no <= 10040;

-- negyedik feladat ---
SELECT first_name, last_name, hire_date
FROM employees
WHERE YEAR(hire_date) = 2000;

-- ötödik feladat ---
SELECT employees.emp_no, employees.first_name, employees.last_name, titles.title
FROM employees
JOIN titles ON employees.emp_no = titles.emp_no
WHERE titles.title = 'Engineer' 	LIMIT 10;

SELECT employees.emp_no, employees.first_name, employees.last_name, titles.title
FROM employees
JOIN titles ON employees.emp_no = titles.emp_no
WHERE titles.title = 'Senior Engineer' 	LIMIT 10;

-- hatodik feladat ---
delimiter $$
CREATE PROCEDURE last_dept(IN emp_no_in INT, OUT dept_no_out VARCHAR(4))
BEGIN
    SELECT de.dept_no INTO dept_no_out
    FROM dept_emp de
    INNER JOIN (
        SELECT emp_no, MAX(from_date) AS max_from_date
        FROM dept_emp
        WHERE emp_no = emp_no_in
        GROUP BY emp_no
    ) AS t1
    ON de.emp_no = t1.emp_no AND de.from_date = t1.max_from_date
    ORDER BY de.from_date DESC
    LIMIT 1;
END
delimiter ;
CALL last_dept(10010, @dept_no);
SELECT @dept_no;

-- hetedik feladat ---
SELECT 
    emp_no, salary, from_date, to_date
FROM 
    salaries
WHERE 
    to_date > DATE_ADD(from_date, INTERVAL 1 YEAR) 
    AND salary > 100000
ORDER BY 
    to_date ASC;

-- nyolcadik feladat ---
DROP TRIGGER IF EXISTS check_hire_date;

delimiter $$
CREATE TRIGGER `check_hire_date` BEFORE INSERT ON `employees`
FOR EACH ROW
BEGIN
    DECLARE today DATE;
    DECLARE new_hire_date DATE;
    
    SET today = CURDATE();
    SET new_hire_date = NEW.hire_date;
    
    IF new_hire_date > today THEN
        SET NEW.hire_date = DATE_FORMAT(today, '%y-%m-%d');
    END IF;
END$$
delimiter ;

USE employees;
DELETE FROM employees WHERE emp_no = '999904';
INSERT employees VALUES('999904', '1970-01-31', 'John', 'Johnson', 'M', '2025-01-01');
SELECT * FROM employees ORDER BY emp_no DESC LIMIT 10;

-- kilencedik feladat ---
USE employees;
DROP FUNCTION IF EXISTS get_max_salary;
delimiter $$
CREATE FUNCTION get_max_salary(emp_no INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE max_salary INT;
    SELECT MAX(salary) INTO max_salary FROM salaries WHERE emp_no = emp_no;
    RETURN max_salary;
END$$
delimiter ;

SELECT get_max_salary(11356) AS `Max Salary`;

USE employees;
DROP FUNCTION IF EXISTS get_min_salary;
delimiter $$
CREATE FUNCTION get_min_salary(emp_no INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE min_salary INT;
    SELECT MIN(salary) INTO min_salary FROM salaries WHERE emp_no = emp_no;
    RETURN min_salary;
END$$
delimiter ;

SELECT get_min_salary(11356) AS `Min Salary`;

-- tizedik feladat ---
USE employees;
DROP FUNCTION IF EXISTS get_salary;
delimiter $$
CREATE FUNCTION get_salary(emp_no INT, min_or_max VARCHAR(3))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE salary_value INT;
    IF min_or_max = 'max' THEN
        SELECT MAX(salary) INTO salary_value FROM salaries WHERE emp_no = emp_no;
    ELSE
        SELECT MIN(salary) INTO salary_value FROM salaries WHERE emp_no = emp_no;
    END IF;
    RETURN salary_value;
END$$

delimiter ;

SELECT get_salary(11356, 'max') AS 'Max Salary'; -- lekéri a legnagyobb fizetést a 11356-os emp_no dolgozóhoz
SELECT get_salary(11356, 'min') AS 'Min Salary'; -- lekéri a legkisebb fizetést a 11356-os emp_no dolgozóhoz




