--1a
ALTER TABLE jobs
ADD CONSTRAINT jobIDFormatConstraint CHECK (REGEXP_LIKE(job_id,'^[[:alnum:]]{2}_[[:alnum:]]{1,7}$');
ADD CONSTRAINT uniqueJobTitelConstraint UNIQUE (job_title);
ADD CONSTRAINT salaryCheckConstraint CHECK (min_salary <= max_salary);
ADD CONSTRAINT jobIdIsUpperConstraint CHECK (job_id = UPPER(job_id));
/

-- tests


-- 1b  done in a very stupid way :)
CREATE OR REPLACE TRIGGER createJobHistoryTrigger
BEFORE UPDATE OF job_id, department_id, employee_id ON employees
FOR EACH ROW
WHEN (OLD.job_id != NEW.job_id OR OLD.department_id != NEW.department_id)
DECLARE
	num_of_employees NUMBER;
	new_start_date DATE;
BEGIN
	SELECT COUNT(employee_id) INTO num_of_employees
	FROM job_history
	WHERE employee_id = :OLD.employee_id;

	IF num_of_employees < 1 THEN
		new_start_date := :OLD.hire_date;
	ELSE
		SELECT MAX(end_date)
    		INTO new_start_date
    		FROM job_history
   		WHERE employee_id = :OLD.employee_id;
	END IF; INSERT INTO job_history (employee_id, start_date, end_date, job_id, department_id) VALUES (:OLD.employee_id, new_start_date, SYSDATE, :OLD.job_id, :OLD.department_id); END; END createJobHistoryTrigger; /

--2
CREATE OR REPLACE TRIGGER programmerEmployeeTrigger
BEFORE UPDATE OR INSERT OR DELET ON employees
FOR EACH ROW
WHEN (OLD.job_id = 'IT_PROG' OR NEW.job_id  != 'IT_PROG') 
DECLARE
BEGIN
    IF DELETING THEN
        RAISE raise_application_error(20999, ‘IT-Programmierer dürfen nicht entlassen werden’);
    END IF;

    IF :NEW.salary < 10000 THEN
        :NEW.salary = 10000;
    END IF;

    IF :NEW.salary < :OLD.salary THEN
        :NEW.salary = :OLD.salary;
    END IF;

    IF :NEW.job_id != 'IT_PROG' AND (:NEW.salary - :OLD.salary) < 2000 THEN
       :NEW.salary := :OLD.salary + 2000;
    END IF;
END;
END programmerEmployeeTrigger;
/

--3
ALTER TABLE departments
ADD salary_sum NUMBER;
UPDATE departments d
SET slary_sum = (
    SELECT SUM(NVL(e.salary,0))
    FROM employees e
    WHERE d.department_id = e.department_id);
/
CREATE OR REPLACE TRIGGER salarySum
BEFORE UPDATE OR INSERT OR DELET ON employees
FOR EACH ROW
WHEN (OLD.salary  != NEW.salary OR OLD.department_id  != NEW.department_id)
DECLARE
BEGIN
    IF UPDATING THEN
        IF :OLD.department_id = :NEW.department_id THEN
            UPDATE departments d
            SET slary_sum = salary_sum + (:NEW.salary - :OLD.salary); 
            WHERE d.department_id = :OLD.department_id;
        ELSE 
            UPDATE departments d
            SET slary_sum = salary_sum - :OLD.salary;
            WHERE d.department_id = :OLD.department_id;

            UPDATE departments d
            SET slary_sum = salary_sum + :NEW.salary; 
            WHERE d.department_id = :NEW.department_id;
        END IF;
    END IF;

    IF INSERTING THEN
        UPDATE departments d
        SET slary_sum = salary_sum + :NEW.salary; 
        WHERE d.department_id = :NEW.department_id;
    END IF;  done in a very stupid way :)

    IF DELETING THEN
        UPDATE departments d
        SET slary_sum = salary_sum - :OLD.salary;
        WHERE d.department_id = :OLD.department_id;
    END IF;
END;
END salarySum;
/

--tests
