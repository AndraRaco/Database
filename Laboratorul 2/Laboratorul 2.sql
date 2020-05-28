--Laboratorul 2
--Functii de siruri de caractere
--1
SELECT last_name || ' ' || first_name || ' ' || 'castiga ' || salary || ' ' || 'lunar dar doreste ' || 3*salary AS salariu_ideal
FROM employees;

--2
--Var 1
SELECT INITCAP(first_name), UPPER(last_name), LENGTH(last_name)
FROM employees
WHERE last_name LIKE ('J%') or last_name LIKE ('M%') or last_name LIKE ('__a%');

---Var 2
--SUBSTR(last_name,1,1)='L'

--3
SELECT first_name, employee_id, last_name, department_id
FROM employees
WHERE TRIM(LOWER(first_name)) = 'steven';

--4
SELECT first_name, employee_id, last_name, LENGTH(last_name) as LENGTH , INSTR (LOWER(first_name), 'a') AS INSTR
FROM employees
WHERE first_name LIKE('%e');

--Functii aritmetice
--5
SELECT last_name, trunc(trunc(sysdate-hire_date)/7)
FROM employees
WHERE trunc(trunc(sysdate-hire_date)/7)=trunc(sysdate-hire_date)/7;

--6
SELECT employee_id, last_name, salary, TO_CHAR(salary*1.15,'99999.99'), trunc(MOD(salary*1.15,1000)/100)
FROM employees;

--7
SELECT last_name AS "Nume", hire_date as "Data"
FROM employees
WHERE commission_pct>0;

--Functii si operatii cu date calendaristice
--8
SELECT TO_CHAR(SYSDATE+30,'MONTH dd yyyy hh24:mi:ss')
FROM DUAL;

--9
SELECT TRUNC(TO_DATE('31-12-2020 23:59','dd-mm-yyyy hh24:mi')-SYSDATE)
FROM DUAL;

--10
--a
SELECT TO_CHAR(SYSDATE+0.5,'MONTH dd yyyy hh24:mi:ss')
FROM DUAL;

--b
SELECT TO_CHAR(SYSDATE+1/24/60*5,'MONTH dd yyyy hh24:mi:ss')
FROM DUAL;

--11
SELECT first_name, last_name, hire_date, NEXT_DAY(ADD_MONTHS(hire_date,6),'Monday')
FROM employees;

--12
SELECT first_name, TRUNC(MONTHS_BETWEEN(SYSDATE,hire_date)) as LUNI_LUCRATE
FROM employees
ORDER BY 2;--TRUNC(MONTHS_BETWEEN(SYSDATE,hire_date))

--13
SELECT first_name, last_name, hire_date, TO_CHAR(hire_date,'day')
FROM employees
ORDER BY TO_CHAR(hire_date,'d');

--Functii diverse
--14
SELECT first_name, NVL(TO_CHAR(commission_pct), 'Fara comision' ) as Comision
FROM employees;

--15
SELECT first_name, salary, commission_pct
FROM employees
WHERE salary*(1+NVL(commission_pct, 0))>=10000;

--Insstructiune CASE
--16
SELECT first_name, job_id, salary, DECODE(job_id,'IT_PROG', salary+salary*20/100, DECODE(job_id, 'SA_REP', salary+salary*25/100, DECODE(job_id, 'SA_MAN', salary+salary*35/100, salary))) as "Salariu negociat"
FROM employees;

--sau
SELECT first_name, job_id, salary, 
       salary * (1 + DECODE(job_id,
                    'IT_PROG', 0.2,
                    'SA_REP', 0.25,
                    'SA_MAN', 0.35,
                    0)) AS "Salariu renegociat"
FROM employees;

--Join
--17
SELECT employees.first_name, employees.employee_id, employees.department_id
FROM employees
LEFT JOIN departments ON employees.department_id=departments.department_id;

--18
SELECT employees.job_id
FROM employees
INNER JOIN departments ON departments.department_id=employees.department_id
WHERE employees.department_id=30;

--19
SELECT employees.employee_id, departments.department_name, departments.location_id
FROM employees
INNER JOIN departments ON departments.department_id=employees.department_id
WHERE employees.commission_pct > 0;

--20
SELECT employees.first_name, departments.department_name
FROM employees
INNER JOIN departments ON departments.department_id=employees.department_id
WHERE employees.first_name LIKE ('%a%') or 
      employees.first_name LIKE ('A%') ;

--21
SELECT employees.first_name, employees.job_id, employees.employee_id, departments.department_name
FROM departments
INNER JOIN employees ON departments.department_id=employees.department_id
INNER JOIN locations ON departments.location_id=locations.location_id
WHERE locations.city='Oxford' ;

--22
SELECT t1.employee_id as "Ang#", t1.first_name as "Angajat", t1.manager_id as "Mgr#", t2.employee_id as "Mgr"
FROM employees t1
JOIN employees t2 ON t1.manager_id=t2.employee_id;

--23
SELECT t1.employee_id as "Ang#", t1.first_name as "Angajat", t1.manager_id as "Mgr#", t2.employee_id as "Mgr"
FROM employees t1
LEFT OUTER JOIN employees t2 ON t1.manager_id=t2.employee_id;

--24
SELECT t1.employee_id as "ID", t1.first_name as "Nume", t2.first_name As "Coleg" 
FROM employees t1
INNER JOIN employees t2 ON t1.department_id=t2.department_id;

--25
SELECT employee.first_name, jobs.job_id, jobs.job_title, employees.department_name, employees.salary
FROM employees 
INNER JOIN jobs 
ON employees.job_id = jobs.job_id;

--26
SELECT first_name, hire_date
FROM employees
WHERE hire_date >(
      SELECT hire_date
      FROM employees
      WHERE last_name='Gates'
      );

--27
SELECT t1.first_name, t2.last_name AS Angajat, t1.hire_date AS Data_ang, t2.first_name AS Manager, t2.hire_date AS Data_mgr
FROM employees t1
INNER JOIN employees t2 ON t1.manager_id=t2.employee_id
WHERE t1.hire_date<t2.hire_date;







