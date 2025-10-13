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

--Tests 1a
--correct
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES ('FR_COOLBRO', 'Megacoolbro', 1000, 10000);
--fail with lowercase jobtitle
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES ('fr_coolbro', 'Coolbro', 1000, 10000);
--fail with duplicate
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES ('EN_COOLBRO', 'Megacoolbro', 1000, 10000);
--fail with minsalary > maxsalary
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES ('FR_COOLBRO', 'Megacoolbro', 10000, 1000);

--1b
CREATE OR REPLACE TRIGGER createJobHistoryTrigger
AFTER UPDATE OF job_id, department_id on employees
FOR EACH ROW
WHEN (NEW.job_id != OLD.job_id OR NEW.department_id != OLD.department_id)
DECLARE
    employee_date DATE;
BEGIN
    SELECT MAX(end_date) INTO employee_date FROM job_history WHERE employee_id = OLD.employee_id;
IF
    employee_date IS NULL THEN
    SELECT hire_date INTO employee_date FROM employees WHERE employee_id = OLD.employee_id;
END IF;
INSERT INTO job_history (employee_id, start_date, end_date, job_id, department_id)
VALUES (OLD.employee_id, employee_date, SYSDATE, OLD.job_id, OLD.department_id);
END createJobHistoryTrigger;

--2
CREATE OR REPLACE TRIGGER programmerEmployeeTrigger
BEFORE INSERT OR UPDATE OR DELETE ON employee
FOR EACH ROW
WHEN (OLD.job_id = 'IT_PROG' OR NEW.job_id = 'IT_PROG')
BEGIN
IF DELETING THEN
    raise_application_error(20099, 'IT-Programmierer darf nicht entlassen werden');
END IF;

IF NEW.salary < 10000 THEN
    NEW.salary := 10000;
END IF;

IF NEW.salary < OLD.salary THEN
    NEW.salary := OLD.salary;
END IF;

IF NEW.job_id != OLD.job_id THEN
    IF NEW.salary < (OLD.salary + 2000) THEN
    NEW.salary := OLD.salary + 2000;
    END IF;
END IF;
END programmerEmployeeTrigger;

--Tests


--3
ALTER TABLE departments ADD salary_sum NUMBER;

UPDATE departments SET salary_sum = (SELECT SUM(employees.salary) FROM employees WHERE departments.department_id = employees.department_id);

CREATE OR REPLACE TRIGGER salarySum
BEFORE INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
BEGIN
    IF DELETING THEN
        UPDATE departments SET salary_sum = salary_sum - OLD.salary
        WHERE department_id = OLD.department_id;
    END IF;
    
    IF INSERTING THEN
        UPDATE departments set salary_sum = salary_sum + NEW.salary
        WHERE department_id = NEW.department_id;
    END IF;
    
    IF UPDATING THEN
        IF OLD.department_id = NEW.department_id THEN
        update departments SET salary_sum = salary_sum - OLD.salary + NEW.salary;
        WHERE department_id = OLD.department_id;
        ELSE
        UPDATE departments SET salary_sum = salary_sum - OLD.salary
        WHERE department_id = OLD.department_id;
        UPDATE departments SET salary_sum = salary_sum + NEW.salary
        WHERE department_id = NEW.department_id;
    END IF;
END salarySum;

--Tests
--ALTER TABLE
--UPDATE TABLE
