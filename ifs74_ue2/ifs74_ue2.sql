--1a
ALTER TABLE jobs 
ADD CONSTRAINT jobIdFormatConstraint
CHECK(REGEXP_LIKE(job_id,'^[[:alnum:]]{2}_[[:alnum:]]{1,7}$'));

ALTER TABLE jobs
ADD CONSTRAINT jobIdIsUpperConstraint
CHECK(job_id = UPPER(job_id));

ALTER TABLE jobs
ADD CONSTRAINT jobnameUniqueConstraint
UNIQUE (job_title);

ALTER TABLE jobs
ADD CONSTRAINT salaryUniqueConstraint
CHECK(min_salary < max_salary);
/

--Tests 1a
SELECT * FROM jobs;
--correct
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES ('FR_COOLBRO', 'Megacoolbro', 1000, 10000);
--fail with lowercase jobtitle
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES ('fr_coolbro', 'Coolbro', 1000, 10000);
--fail with duplicate
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES ('EN_COOLBRO', 'Megacoolbro', 1000, 10000);
--fail with minsalary > maxsalary
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES ('FR_COOLBRO', 'Megacoolbro', 10000, 1000);
--fail with wrong format
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES ('INVALID', 'Megacoolbro', 10000, 1000);

SELECT * FROM jobs;
/
-- 1b
CREATE OR REPLACE TRIGGER createJobHistoryTrigger
AFTER UPDATE OF job_id, department_id on employees
FOR EACH ROW
WHEN (NEW.job_id != OLD.job_id OR NEW.department_id != OLD.department_id)
DECLARE
    employee_date DATE;
BEGIN
    SELECT MAX(end_date) INTO employee_date FROM job_history WHERE employee_id = :OLD.employee_id;
IF
    employee_date IS NULL THEN
    employee_date := :OLD.hire_date;
END IF;
INSERT INTO job_history (employee_id, start_date, end_date, job_id, department_id)
VALUES (:OLD.employee_id, employee_date, SYSDATE, :OLD.job_id, :OLD.department_id);
END createJobHistoryTrigger;
/

--Tests 1b
SELECT * FROM job_history;
INSERT INTO employees VALUES (401, 'Cool', 'Cool', 'NICES', '515.123.4567', TO_DATE('17-06-2003', 'dd-MM-yyyy'), 'IT_PROG', 100000, NULL, NULL, 90);
--change job_id
UPDATE employees SET job_id = 'AD_PRES' WHERE employee_id = 401;
--change department_id
UPDATE employees SET department_id = 10 WHERE employee_id = 401;
SELECT * FROM job_history;
/

--2
CREATE OR REPLACE TRIGGER programmerEmployeeTrigger
BEFORE UPDATE OR INSERT OR DELETE ON employees
FOR EACH ROW
WHEN (OLD.job_id = 'IT_PROG' OR NEW.job_id  = 'IT_PROG') 
DECLARE
BEGIN
    IF DELETING THEN
        raise_application_error(-20099, 'IT-Programmierer duerfen nicht entlassen werden');
    END IF;

    IF :NEW.salary < 10000 THEN
        :NEW.salary := 10000;
    END IF;

    IF :NEW.salary < :OLD.salary THEN
        :NEW.salary := :OLD.salary;
    END IF;

    IF :NEW.job_id != 'IT_PROG' AND (:NEW.salary - :OLD.salary) < 2000 THEN
       :NEW.salary := :OLD.salary + 2000;
    END IF;
END programmerEmployeeTrigger;
/

--2 Tests
--INSERT with low salary
INSERT INTO employees VALUES (603, 'Cool', 'Cool', 'NIVLCE', '515.123.4567', TO_DATE('17-06-2003', 'dd-MM-yyyy'), 'IT_PROG', 100, NULL, NULL, 90);
--INSERT with high salary
INSERT INTO employees VALUES (604, 'Cool', 'Cool', 'VERNABICE', '515.123.4567', TO_DATE('17-06-2003', 'dd-MM-yyyy'), 'IT_PROG', 100000, NULL, NULL, 90);
----UPDATE lower salary
UPDATE employees SET salary = 100 WHERE employee_id = 603;
--check

SELECT * FROM employees
WHERE employee_id IN (603,604);

--try delete with error
DELETE FROM employees where employee_id = 603;
--change jobid default salary change;
UPDATE employees SET job_id = 'AD_PRES' WHERE employee_id = 603;
--change jobid higher change 
UPDATE employees SET job_id = 'AD_PRES', salary = 200000 WHERE employee_id = 604;

--check
SELECT * FROM employees
WHERE employee_id IN (603,604);

----UPDATE lower salary
UPDATE employees SET salary = 100 WHERE employee_id = 603;

--check
SELECT * FROM employees
WHERE employee_id IN (603,604);

INSERT INTO employees VALUES (605, 'Cool', 'Cool', 'NIABCE L', '515.123.4567', TO_DATE('17-06-2003', 'dd-MM-yyyy'), 'AD_PRES', 10, NULL, NULL, 90);
UPDATE employees SET job_id = 'IT_PROG' WHERE employee_id IN  (603,604,605);

SELECT * FROM employees
WHERE employee_id IN (603,604,605);
/

--3
ALTER TABLE departments
ADD salary_sum NUMBER;
UPDATE departments d
SET salary_sum = (
    SELECT SUM(NVL(e.salary,0))
    FROM employees e
    WHERE d.department_id = e.department_id);
/

CREATE OR REPLACE TRIGGER salarySum
BEFORE UPDATE OR INSERT OR DELETE ON employees
FOR EACH ROW
DECLARE
BEGIN
    IF UPDATING THEN
        IF :OLD.department_id = :NEW.department_id THEN
            UPDATE departments d
            SET salary_sum = NVL(salary_sum, 0) + (:NEW.salary - :OLD.salary)
            WHERE d.department_id = :OLD.department_id;
        ELSE 
            UPDATE departments d
            SET salary_sum = NVL(salary_sum,0) - :OLD.salary
            WHERE NVL(d.department_id,0) = NVL(:OLD.department_id,0);

            UPDATE departments d
            SET salary_sum = NVL(salary_sum,0) + :NEW.salary 
            WHERE d.department_id = :NEW.department_id;
        END IF;
    END IF;

    IF INSERTING THEN
        UPDATE departments d
        SET salary_sum = NVL(salary_sum,0) + :NEW.salary
        WHERE d.department_id = :NEW.department_id;
    END IF;

    IF DELETING THEN
        UPDATE departments d
        SET salary_sum = NVL(salary_sum,0) - :OLD.salary
        WHERE d.department_id = :OLD.department_id;
    END IF;
END salarySum;
/

--Tests
SELECT * FROM departments;
--INSERT
INSERT INTO employees VALUES (619, 'Cool', 'Cool', 'OVERYS', '515.123.4567', TO_DATE('17-06-2003', 'dd-MM-yyyy'), 'AD_PRES', 24000, NULL, NULL, 210);
SELECT * FROM departments;
--DELETE
DELETE FROM employees WHERE employee_id = 619;
SELECT * FROM departments;

--UPDATE TABLE
UPDATE employees SET salary = 100000 where employee_id = 418;
SELECT * FROM departments;

UPDATE employees SET department_id = 20 where department_id = 10;
SELECT * FROM departments;
