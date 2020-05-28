-- Laboratorul 3
-- V. Join

-- 1
-- Varianta 1
SELECT e.last_name, to_char(e.hire_date, 'Month yyyy')
FROM employees e
       JOIN employees e1 ON (e1.department_id = e.department_id AND lower(e1.last_name) = 'gates'
              AND lower(e.last_name) LIKE '%a%' AND lower(e.last_name) != 'gates');

-- Varianta 2
SELECT e.last_name, to_char(e.hire_date, 'Month yyyy')
FROM employees e, employees e1
WHERE e1.department_id = e.department_id AND lower(e1.last_name) = 'gates'
       AND instr(lower(e.last_name), 'a') > 0
       AND lower(e.last_name) != 'gates';


-- 2
-- Varianta 1
SELECT e.employee_id, e.last_name, d.department_id, d.department_name
FROM employees e
       JOIN departments d ON (e.department_id = d.department_id)
WHERE (SELECT count(*)
FROM employees e1
WHERE lower(e1.last_name) LIKE '%t%'
       AND e1.department_id = e.department_id
       AND e1.employee_id != e.employee_id) > 0
ORDER BY 2;

-- Varianta 2 
SELECT DISTINCT e.employee_id, e.last_name, d.department_id, d.department_name
FROM employees e
       JOIN departments d ON (e.department_id = d.department_id)
       JOIN employees s ON (e.department_id = s.department_id
              AND lower(s.last_name) LIKE '%t%'
              AND s.employee_id != e.employee_id)
ORDER BY 2;

-- 3
SELECT e1.last_name, e1.salary, job_title, city, country_name
FROM employees e1
       JOIN jobs USING(job_id)
       JOIN departments USING(department_id)
       JOIN locations USING(location_id)
       JOIN countries USING(country_id)
       JOIN employees e2 ON (e1.manager_id = e2.employee_id AND e2.last_name = 'King') ;

-- 4
SELECT  department_id  , department_name, last_name, job_id, to_char(salary, '$99,999.00')
FROM departments
JOIN employees USING
(department_id)
WHERE department_name LIKE '%ti%'
ORDER BY department_name, last_name;

-- 5
SELECT last_name, d.department_id, department_name, city
FROM employees e
       JOIN departments d ON (d.department_id = e.department_id)
       JOIN locations l ON (l.location_id = d.location_id AND city = 'Oxford');

-- 6
SELECT DISTINCT e1.employee_id, e1.last_name, e1.department_id, e1.salary, (j.min_salary + j.max_salary) / 2 "avg"
FROM employees e1
       JOIN jobs j ON (j.job_id = e1.job_id AND e1.salary > (j.min_salary + j.max_salary) / 2)
       JOIN employees e3 ON (e1.department_id = e3.department_id AND lower(e3.last_name) LIKE '%t%')
ORDER BY 3;

-- 7
-- Varianta 1
SELECT last_name, department_name
FROM employees
       LEFT OUTER JOIN departments USING(department_id) ;

-- Varianta 2
SELECT last_name, department_name
FROM departments
       RIGHT OUTER JOIN employees USING(department_id) ;

-- 8
-- Varianta 1
SELECT department_name, last_name
FROM employees
       RIGHT OUTER JOIN departments USING(department_id) ;

-- Varianta 2
SELECT department_name, last_name
FROM departments
       LEFT OUTER JOIN employees USING(department_id) ;

-- 9
SELECT last_name, department_name
FROM employees
       FULL OUTER JOIN departments USING(department_id) 
ORDER BY 1;

-- VI. Operatori pe multimi

-- 10
       SELECT department_id
       FROM departments
       WHERE department_name LIKE '%re%'
UNION
       SELECT department_id
       FROM employees
       WHERE job_id = 'SA_REP';
-- rez sunt ordonate dupa department_id

-- 11
       SELECT department_id
       FROM departments
       WHERE department_name LIKE '%re%'
UNION ALL
       SELECT department_id
       FROM employees
       WHERE job_id = 'SA_REP';
-- union all pastreaza dublicatele din a 2-a cerere si rezultatele nu mai sunt in ordine

-- 12
SELECT department_id
FROM departments
MINUS
SELECT department_id
FROM employees;

-- 13
       SELECT department_id
       FROM departments
       WHERE lower(department_name) LIKE '%re%'
INTERSECT
       SELECT department_id
       FROM employees
       WHERE job_id='HR_REP';

-- 14
       SELECT employee_id, job_id, last_name
       FROM employees
       WHERE salary > 3000
UNION
       SELECT employee_id, job_id, last_name
       FROM employees
NATURAL JOIN jobs 
       WHERE salary = (min_salary + max_salary) / 2;

-- VII. Subcereri necorelate

-- 15
SELECT last_name, hire_date
FROM employees
WHERE hire_date > (SELECT hire_date
FROM employees
WHERE last_name = 'Gates');

-- 16
SELECT last_name, salary
FROM employees
WHERE department_id = (SELECT department_id
       FROM employees
       WHERE last_name = 'Gates') AND last_name != 'Gates';

-- 17
SELECT last_name, salary
FROM employees
WHERE manager_id = (SELECT employee_id
FROM employees
WHERE manager_id IS NULL);

-- 18
SELECT last_name, department_id, salary
FROM employees e1
WHERE (department_id, salary) IN (SELECT department_id, salary
FROM employees e2
WHERE commission_pct IS NOT NULL AND e1.employee_id != e2.employee_id)
ORDER BY 2, 3;

-- 19
SELECT DISTINCT e1.employee_id, e1.last_name, e1.department_id, e1.salary, round(e2."avg", 2)
FROM employees e1
       JOIN (SELECT department_id, avg(salary) "avg"
       FROM employees
       GROUP BY department_id) e2
       ON (e1.department_id = e2.department_id AND e1.salary > e2."avg")
       JOIN employees e3 ON (e1.department_id = e3.department_id AND lower(e3.last_name) LIKE '%t%')
ORDER BY 3;

-- 20
SELECT last_name
FROM employees
WHERE salary > ALL (SELECT salary
FROM employees
WHERE job_id LIKE '%CLERK%')
ORDER BY salary DESC;

-- 21
SELECT last_name, department_name, salary, e1.manager_id
FROM employees e1
       JOIN departments USING(department_id) 
WHERE commission_pct IS NULL
       AND (SELECT count(*)
       FROM employees e2
       WHERE e2.manager_id = e1.manager_id AND e2.commission_pct IS NOT NULL) > 0;

-- 22
SELECT last_name, department_name, salary, job_title, commission_pct
FROM employees e1
       JOIN departments USING(department_id)
       JOIN jobs j ON (e1.job_id = j.job_id) 
WHERE (SELECT count(*)
FROM employees e2
       JOIN departments d ON(e2.department_id = d.department_id)
       JOIN locations l ON(d.location_id = l.location_id)
WHERE city = 'Oxford' AND e1.employee_id != e2.employee_id AND e1.salary = e2.salary AND e1.commission_pct = e2.commission_pct) > 0;

-- 23
SELECT last_name, department_id, job_id
FROM employees
WHERE department_id IN (SELECT department_id
FROM departments
       JOIN locations USING(location_id) 
WHERE city = 'Toronto');

