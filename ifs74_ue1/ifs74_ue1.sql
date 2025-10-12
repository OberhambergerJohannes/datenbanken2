--1a
CREATE OR REPLACE PROCEDURE createJob (
new_job_id NUMBER,
new_job_title VARCHAR,
new_min_salary NUMBER, 
new_max_salary NUMBER)
AS
jobnameException EXCEPTION;
salaryException EXCEPTION;
jobIdException EXCEPTION;
jobs_titles VARCHAR;

BEGIN
IF NOT REGEXP_LIKE(new_job_id,'^[[:alnum:]]{2}_[[:alnum:]]{1,7}$') THEN
RAISE jobIdException;
END IF;
BEGIN 
SELECT job_title INTO jobs_titles FROM jobs WHERE job_title = new_job_title;
RAISE jobnameException;
EXCEPTION 
WHEN NO_DATA_FOUND THEN
NULL;
WHEN TOO_MANY_ROWS THEN
RAISE jobnameException;
END;
IF new_max_salary < new_min_salary THEN
RAISE salaryException;
ELSE INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES (UPPER(new_job_id), new_job_title, new_min_salary, new_max_salary);
END IF;

EXCEPTION
WHEN jobnameException THEN
DBMS_OUTPUT.PUT_LINE('Jobname already in database');
WHEN salaryException THEN
DBMS_OUTPUT.PUT_LINE('Max salary is lower than min salary');
WHEN jobIdException THEN
DBMS_OUTPUT.PUT_LINE('JobId does not match the requested format');
END createJob;

SELECT 'ok' FROM dual
WHERE REGEXP_LIKE ('AD_PRES',
 '^[[:alnum:]]{2}_[[:alnum:]]{1,7}$');
SELECT 'ok' FROM dual
WHERE REGEXP_LIKE ('ADD_PRES',
 '^[[:alnum:]]{2}_[[:alnum:]]{1,7}$');
-- anonymer PL/SQL-Block
BEGIN
IF REGEXP_LIKE ('ADD_PRES',
 '^[[:alnum:]]{2}_[[:alnum:]]{1,7}$') THEN
 DBMS_OUTPUT.PUT_LINE('ok');
 ELSE
 DBMS_OUTPUT.PUT_LINE('Nicht ok');
 END IF;
END;


--b
CREATE OR REPLACE PROCEDURE createJobHistory (
new_employee_id NUMBER,
new_start_date DATE,
new_end_date DATE,
new_job_id  NUMBER,
new_department_id NUMBER)
AS
employeeIdMissingException EXCEPTION;
jobIdMissingException EXCEPTION;
departmentIdMissingException EXCEPTION;
employeesV NUMBER;
jobsV NUMBER;
departmentsV NUMBER;

BEGIN
SELECT employee_id INTO employeesV FROM employees WHERE new_employee_id = employee_id;
RAISE employeeIdMissingException;
EXCEPTION 
WHEN NO_DATA_FOUND THEN
NULL;
WHEN TOO_MANY_ROWS THEN
RAISE employeeIdMissingException;
END;

BEGIN
SELECT job_id INTO jobsV FROM jobs WHERE new_job_id = job_id;
RAISE jobIdMissingException;
EXCEPTION 
WHEN NO_DATA_FOUND THEN
NULL;
WHEN TOO_MANY_ROWS THEN
RAISE jobIdMissingException;
END;

IF new_department_id IS NOT NULL THEN
BEGIN
SELECT department_id INTO departmentsV FROM departments WHERE new_department_id = department_id;
RAISE departmentIdMissingException;
EXCEPTION 
WHEN NO_DATA_FOUND THEN
NULL;
WHEN TOO_MANY_ROWS THEN
RAISE departmentIdMissingException;
END IF;
END;

EXCEPTION
WHEN employeeIdMissingException THEN
DBMS_OUTPUT.PUT_LINE('Employee is not in database');
WHEN jobIdMissingException THEN
DBMS_OUTPUT.PUT_LINE('Job is not in database');
WHEN departmentIdMissingException THEN
DBMS_OUTPUT.PUT_LINE('Department is not in database');
END;
END createJobHistory;

--TODO: tests

--2a
CREATE OR REPLACE PROCEDURE checkSalary (
    child_employee_id NUMBER
)
AS
child_employee_salary NUMBER;
parent_manager_id NUMBER;
parent_manager_salary NUMBER;
BEGIN SELECT salary, manager_id INT child_emp_salary, parent_manager_id FROM employees 
WHERE employee_id = child_employee_id;
IF parent_manager_id IS NOT NULL THEN
    SELECT salary INTO parent_manager_salary FROM employees
    WHERE employee_id = parent_manager_id;
    
    IF child_employee_salary >= parent_manager_salary THEN
        UPDATE employee SET salary = child_employee_salary * 1.1
        WHERE employee_id = parent_manager_id;
    END IF;
END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('The employee with the given id does not exist');
END;
END checkSalary;

--TODO tests

--2b
CREATE OR REPLACE PROCEDURE check_all_salaries
AS
    CURSOR c1 IS SELECT employee_id FROM employees FOR UPDATE;
    c1_rec_employee_id NUMBER;
BEGIN
    OPEN c1;
    LOOP
        FETCH c1 INTO c1_rec_employee_id;
        EXIT WHEN c1%NOTFOUND;
        checkSalary(c1_rec_employee_id);
    END LOOP;
    CLOSE c1;
END;

--Tests







