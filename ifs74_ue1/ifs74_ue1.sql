--1a
CREATE OR REPLACE PROCEDURE createJob (
new_job_id VARCHAR2,
new_job_title VARCHAR2,
new_min_salary NUMBER, 
new_max_salary NUMBER)
AS
jobnameException EXCEPTION;
salaryException EXCEPTION;
jobIdException EXCEPTION;
jobs_titles_count NUMBER;

BEGIN
IF NOT REGEXP_LIKE(new_job_id,'^[[:alnum:]]{2}_[[:alnum:]]{1,7}$') THEN
    RAISE jobIdException;
END IF;

SELECT COUNT(job_id) INTO jobs_titles_count FROM jobs WHERE UPPER(job_title) = UPPER(new_job_title);    
IF job_titles_count >= 1 THEN
    RAISE jobnameException;
END IF;

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

--Tests
SELECT 'ok' FROM dual
WHERE REGEXP_LIKE ('AD_PRES',
 '^[[:alnum:]]{2}_[[:alnum:]]{1,7}$');
SELECT 'ok' FROM dual
WHERE REGEXP_LIKE ('ADD_PRES',
 '^[[:alnum:]]{2}_[[:alnum:]]{1,7}$');

BEGIN
IF REGEXP_LIKE ('ADD_PRES',
 '^[[:alnum:]]{2}_[[:alnum:]]{1,7}$') THEN
 DBMS_OUTPUT.PUT_LINE('ok');
 ELSE
 DBMS_OUTPUT.PUT_LINE('Nicht ok');
 END IF;
END;

--correct case
createJob('FR_COOLBRO', 'Megacoolbro', 1000, 10000);
--fail with lowercase jobtitle
createJob('fr_coolbro', 'Coolbro', 1000, 10000);
--fail with duplicate
createJob('EN_COOLBRO', 'Megacoolbro', 1000, 10000);
--fail with minsalary > maxsalary
createJob('FR_COOLBRO', 'Megacoolbro', 10000, 1000);

--b
CREATE OR REPLACE PROCEDURE createJobHistory (
new_employee_id NUMBER,
new_start_date DATE,
new_end_date DATE,
new_job_id  VARCHAR2,
new_department_id NUMBER)
AS
employeeIdMissingException EXCEPTION;
jobIdMissingException EXCEPTION;
departmentIdMissingException EXCEPTION;
employees_count NUMBER;
jobs_count NUMBER;
department_count NUMBER;

BEGIN
SELECT COUNT(employee_id) INTO employees_count FROM employees WHERE new_employee_id = employee_id;
IF employees_count = 0 THEN
    RAISE employeeIdMissingException;
END IF;

BEGIN
SELECT COUNT(job_id) INTO jobs_count FROM jobs WHERE new_job_id = job_id;
IF jobs_count = 0 THEN
    RAISE jobIdMissingException;
END IF;

IF new_department_id IS NOT NULL THEN
BEGIN
SELECT COUNT(department_id) INTO department_count FROM departments WHERE new_department_id = department_id;
IF department_count = 0 THEN
    RAISE departmentIdMissingException;
END IF;

EXCEPTION
WHEN employeeIdMissingException THEN
DBMS_OUTPUT.PUT_LINE('Employee is not in database');
WHEN jobIdMissingException THEN
DBMS_OUTPUT.PUT_LINE('Job is not in database');
WHEN departmentIdMissingException THEN
DBMS_OUTPUT.PUT_LINE('Department is not in database');
END createJobHistory;

--tests
--correct case
createJobHistory (1, SYSDATE - 10, SYSDATE + 10, 'FR_COOLBRO', 1);
--fail with employeeMissing
createJobHistory (100000, SYSDATE - 10, SYSDATE + 10, 'FR_COOLBRO', 1);
--fail with jobIdMissingException
createJobHistory (1, SYSDATE - 10, SYSDATE + 10, 'BR_MYCOOL', 1);
--fail with departmentIdMissingException
createJobHistory (1, SYSDATE - 10, SYSDATE + 10, 'FR_COOLBRO', 10000);

--2a
-
CREATE OR REPLACE PROCEDURE checkSalary 
(child_employee_id NUMBER)
AS
child_employee_salary NUMBER;
parent_manager_id NUMBER;
parent_manager_salary NUMBER;
BEGIN 
    SELECT salary, manager_id INTO child_employee_salary, parent_manager_id FROM employees WHERE employee_id = child_employee_id;
    
    IF parent_manager_id IS NOT NULL THEN
        SELECT salary INTO parent_manager_salary FROM employees
        WHERE employee_id = parent_manager_id;
    
        IF child_employee_salary >= parent_manager_salary THEN
            UPDATE employees SET salary = child_employee_salary * 1.1
            WHERE employee_id = parent_manager_id;
        END IF;
    END IF;
    
EXCEPTION
WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('The employee with the given id does not exist');
END;
END checkSalary;
/
--correct case
checkSalary(1);
--NO DATA FOUND exception
checkSalary(10000000);

--2b
CREATE OR REPLACE PROCEDURE check_all_salaries
AS
    CURSOR c1 IS SELECT employee_id FROM employees FOR UPDATE;
    c1_rec_employee_id employee_id%TYPE;
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
check_all_salaries();


