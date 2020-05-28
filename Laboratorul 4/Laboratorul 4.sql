-- Laboratorul 4
-- V. Functii grup si clauzele GROUP BY, HAVING

-- 1
-- a)  Sum, Min, Max, si Avg ignora valorile null.
-- b)  Where filtreaza liniile selectate inainte de grupare, 
--     pe cand Having filtreaza liniile de dupa grupare

-- 2
SELECT ROUND(MAX(salary)) AS MAXIM, ROUND(MIN(salary)) AS MINIM, ROUND(SUM(salary)) AS SUMA, ROUND(AVG(salary)) AS MEDIA
FROM employees;

-- 3
SELECT MIN(salary), MAX(salary), SUM(salary), AVG(salary)
FROM employees
GROUP BY (job_id);

-- 4
SELECT COUNT(employee_id) AS "Numar angajati"
FROM employees
GROUP BY (job_id);

-- 5
SELECT count(*) "Numar manageri"
FROM (
    SELECT manager_id 
    FROM employees
    WHERE manager_id IS NOT NULL
    GROUP BY (manager_id)
);

-- 6
SELECT MAX(salary)-MIN(salary) AS "Dif Max-Min"
FROM employees;

-- 7
SELECT d.department_name AS "Nume Departament", l.city AS "Locatia", COUNT(e.employee_id) AS "Nr. angajati", ROUND(AVG(e.salary)) AS "Salariu mediu"
FROM departments d
JOIN employees e ON d.department_id = e.department_id
INNER JOIN locations l USING (location_id)
GROUP BY (d.department_id, d.department_name, l.city);

-- 8
SELECT employee_id, first_name
FROM employees 
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

-- 9
SELECT manager_id, MIN(salary) 
FROM employees
GROUP BY manager_id
HAVING MIN(salary)>1000 AND manager_id IS NOT NULL -- Am pus mai mare ca 1000, fiindca la mai mic nu aparea nimic
ORDER BY 2 DESC;

-- 10
SELECT department_id, department_name, MAX(salary)
FROM departments d
INNER JOIN employees e USING (department_id)
GROUP BY department_id, department_name
HAVING MAX(salary) > 3000;

-- 11
SELECT MIN(AVG(salary))
FROM employees
GROUP BY job_id;

-- 12
SELECT department_id, department_name, SUM(salary)
FROM departments 
INNER JOIN employees USING (department_id)
GROUP BY department_id, department_name;

-- 13
SELECT MAX(AVG(salary))
FROM departments 
INNER JOIN employees USING (department_id)
GROUP BY department_id;

-- 14
SELECT job_id, job_title, AVG(salary)
FROM employees
INNER JOIN jobs USING (job_id)
GROUP BY job_id, job_title
HAVING AVG(salary)= (SELECT MIN(AVG(salary)) FROM employees GROUP BY job_id);

-- 15
SELECT AVG(salary)
FROM employees
HAVING AVG(salary) > 2500;

-- 16
SELECT department_id, job_id, AVG(salary)
FROM employees
JOIN departments USING(department_id)
JOIN jobs USING(job_id)
GROUP BY department_id, job_id
ORDER BY 1;

-- 17
SELECT department_name, AVG(salary)
FROM employees
JOIN departments USING(department_id)
GROUP BY department_name
HAVING AVG(salary) = (SELECT MAX(AVG(salary)) 
                      FROM employees
                      GROUP BY department_id);

-- 18
-- a
SELECT department_id, department_name, COUNT(employee_id)
FROM departments
INNER JOIN employees USING (department_id)
GROUP BY department_id, department_name
HAVING COUNT(employee_id)<4;

-- b
SELECT department_id, department_name, COUNT(employee_id)
FROM departments
INNER JOIN employees USING (department_id)
GROUP BY department_id, department_name
HAVING COUNT(employees.employee_id)=(
    SELECT MAX(COUNT(1))
    FROM employees
    GROUP BY department_id
);

-- 19
SELECT first_name, hire_date
FROM employees
WHERE hire_date=(
    SELECT hire_date
    FROM employees
    GROUP BY hire_date
    HAVING COUNT(1)=(
      SELECT MAX(COUNT(1))
      FROM employees
      GROUP BY hire_date
      )
);

-- 20
SELECT COUNT(1)
FROM departments
WHERE department_id IN (
    SELECT department_id
    FROM departments
     INNER JOIN employees
    USING (department_id)
    GROUP BY department_id
    HAVING COUNT(1) >= 15
);

-- 21
SELECT department_id, SUM(employee_id)
FROM departments
INNER JOIN employees USING (department_id)
GROUP BY department_id
HAVING COUNT(employee_id)>=10 AND department_id !=30
ORDER BY 2;

-- 22
SELECT *
FROM (
  SELECT department_id, department_name, COUNT(employee_id), AVG(salary)
  FROM departments
  LEFT JOIN employees USING(department_id)
  GROUP BY department_id, department_name
)
LEFT JOIN
(
    SELECT first_name, salary, job_id, department_id
    FROM employees
) USING (department_id);

-- 23
SELECT city, department_name, job_id, SUM(salary)
FROM departments
INNER JOIN employees USING (department_id)
INNER JOIN locations USING (location_id)
WHERE department_id > 80
GROUP BY city, department_name, job_id;

-- 24
SELECT last_name
FROM employees
WHERE employee_id IN(
  SELECT employee_id
  FROM employees
  INNER JOIN job_history USING(employee_id)
  GROUP BY employee_id
  HAVING COUNT(1) >= 2
);

-- 25 
SELECT AVG(NVL(commission_pct,0)) AS "Comision mediu"
FROM employees;

-- Bonus
-- 29
SELECT department_id, department_name,
    (
        SELECT COUNT(1)
        FROM employees e
        WHERE e.department_id = department_id
    ) AS "Number employees",
    (
        SELECT AVG(e.salary)
        FROM employees e
        WHERE e.department_id = department_id
    ) AS "Avg salary", last_name, salary,  job_id
FROM departments
LEFT JOIN employees USING (department_id);

-- 34
SELECT department_id, department_name, count_employees AS "Employee count", avg_salay AS "Average salary",
       first_name, last_name, salary, job_id
FROM (
    SELECT department_id, COUNT(1) AS count_employees, AVG(salary) AS avg_salay
    FROM employees
    GROUP BY department_id
)
INNER JOIN employees USING (department_id)
FULL OUTER JOIN departments USING (department_id);


