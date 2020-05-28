-- Laboratorul 5
-- 2
-- a
SELECT department_name,
  job_title,
  AVG(salary)
FROM employees
INNER JOIN departments USING (department_id)
INNER JOIN jobs USING (job_id)
GROUP BY GROUPING SETS ( (department_name, job_title), (department_name), (job_title), () );
-- b
SELECT department_name,
  job_title,
  AVG(salary),
  CASE GROUPING(department_name)
    WHEN 1
    THEN 'Dep'
    ELSE ''
  END
  ||
  CASE GROUPING(job_title)
    WHEN 1
    THEN 'Job'
    ELSE ''
  END AS coloana
FROM employees
INNER JOIN departments USING (department_id)
INNER JOIN jobs USING (job_id)
GROUP BY GROUPING SETS ( (department_name, job_title), (department_name), (job_title), () );
-- 3
SELECT department_name,
  job_title,
  departments.manager_id,
  MAX(salary),
  SUM(salary)
FROM employees
INNER JOIN departments USING (department_id)
INNER JOIN jobs USING (job_id)
GROUP BY GROUPING SETS ( (department_name, job_title), (job_title, departments.manager_id), () );
-- 4
SELECT MAX(salary) FROM employees HAVING MAX(salary) >= 15000;
-- 5
-- a
SELECT *
FROM employees e
WHERE salary >=
  ( SELECT AVG(salary) FROM employees WHERE department_id = e.department_id
  );
-- b
-- Var 1
SELECT employee_id,
  last_name,
  department_id,
  department_name,
  mediasal,
  numarang
FROM employees e
JOIN departments USING (department_id)
JOIN
  (SELECT department_id,
    AVG(salary) mediasal,
    COUNT(employee_id) numarang
  FROM employees
  GROUP BY department_id
  ) USING (department_id);
-- Var 2
SELECT employee_id,
  salary,
  e.department_id,
  (SELECT AVG(salary) FROM employees o WHERE e.department_id=o.department_id
  ) MedieSal,
  (SELECT COUNT(employee_id)
  FROM employees t
  WHERE t.department_id=e.department_id
  ) NumarAng,
  department_name
FROM employees e
JOIN departments d
ON (e.department_id=d.department_id);
-- 6
-- Var 1 MAX
SELECT last_name,
  salary
FROM employees
WHERE salary >=
  ( SELECT MAX(AVG(salary)) FROM employees GROUP BY department_id
  );
-- Var 2 ALL
SELECT last_name,
  salary
FROM employees
WHERE salary >= ALL
  ( SELECT AVG(salary) FROM employees GROUP BY department_id
  );
-- 7
-- Var 1
SELECT first_name,
  salary
FROM employees e1
WHERE salary =
  (SELECT MIN(salary)
  FROM employees e2
  WHERE e1.department_id=e2.department_id
  );
-- Var 2
SELECT first_name,
  salary
FROM employees e
JOIN
  (SELECT MIN(salary) salariu,
    department_id
  FROM employees
  GROUP BY department_id
  ) s
ON (e.department_id = s.department_id)
WHERE salary        = salariu;
-- Var 3
SELECT first_name,
  salary
FROM employees
WHERE (department_id, salary) IN
  (SELECT department_id, MIN(salary) FROM employees GROUP BY department_id
  );
-- 8
SELECT last_name,
  a.department_id,
  d.department_name
FROM employees a
JOIN departments d
ON (a.department_id=d.department_id)
WHERE hire_date    =
  (SELECT MIN(hire_date)
  FROM employees b
  WHERE A.department_id=b.department_id
  )
ORDER BY d.department_name;
-- 9
SELECT last_name,
  department_id
FROM employees a
WHERE EXISTS
  (SELECT employee_id
  FROM employees b
  WHERE a.department_id=b.department_id
  AND b.salary         =
    ( SELECT MAX(salary) FROM employees WHERE department_id = 30
    )
  ) ;
-- 10
SELECT last_name,
  salary
FROM employees
WHERE salary IN
  (SELECT salary
  FROM
    (SELECT DISTINCT salary FROM employees ORDER BY salary DESC
    )
  WHERE ROWNUM < 4
  )
ORDER BY salary;
-- 11
SELECT last_name,
  first_name,
  employee_id
FROM employees a
WHERE 2 <=
  (SELECT COUNT(manager_id) FROM employees b WHERE a.employee_id=b.manager_id
  );
-- 12
SELECT location_id
FROM locations e
WHERE EXISTS
  (SELECT 1 FROM departments WHERE e.location_id=location_id
  );
-- 13
SELECT department_id
FROM departments d
WHERE NOT EXISTS
  (SELECT 1 FROM employees WHERE department_id=d.department_id
  );
-- Tema 2 (Tema lab5: 15-18, 20, 22)
-- 15
SELECT employee_id,
  last_name,
  manager_id
FROM employees
  START WITH employee_id       = 114
  CONNECT BY PRIOR employee_id = manager_id;
-- 16
SELECT employee_id,
  manager_id,
  last_name,
  LEVEL
FROM employees
WHERE LEVEL                    = 3
  START WITH last_name         = 'De Haan'
  CONNECT BY PRIOR employee_id = manager_id;
-- 17
SELECT employee_id,
  manager_id,
  LEVEL,
  last_name
FROM employees
  CONNECT BY PRIOR manager_id = employee_id;
-- 18
SELECT employee_id,
  last_name,
  salary,
  LEVEL,
  manager_id
FROM employees
WHERE salary        > 5000
  START WITH salary =
  ( SELECT MAX(salary) FROM employees
  )
  CONNECT BY PRIOR employee_id = manager_id;
-- 20
WITH tabel AS -- primul tabel selecteaza angajatii directi ai lui king
  (SELECT employee_id,
    hire_date
  FROM employees
  WHERE manager_id =
    (SELECT employee_id
    FROM employees
    WHERE last_name='King'
    AND first_name ='Steven'
    )
  ),
  tabel2 AS -- al doilea selecteaza angajatii din primul tabel cu vechimea cea mai mare
  (SELECT * FROM tabel WHERE hire_date =
    ( SELECT MIN(hire_date) FROM tabel
    )
  )
-- ultima cerere face restul
SELECT employee_id,
  last_name
  || ' '
  || first_name,
  job_id,
  hire_date,
  manager_id,
  level
FROM employees
WHERE TO_CHAR(hire_date,'yyyy') <> 1970 -- <> e diferit
  START WITH employee_id        IN
  (SELECT employee_id FROM tabel2
  )
  CONNECT BY PRIOR employee_id=manager_id;
-- 22
SELECT *
FROM
  (SELECT job_id,
    AVG(salary) AS avg_salary
  FROM employees
  GROUP BY job_id
  ORDER BY avg_salary
  )
WHERE ROWNUM <= 3;