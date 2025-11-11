-- 1a
CREATE OR REPLACE PROCEDURE create_job_moritz(
    new_job_id      IN VARCHAR2,
    new_job_title   IN VARCHAR2,
    new_min_sal     IN NUMBER,
    new_max_sal     IN NUMBER
) AS
  wrong_job_id_format 			    EXCEPTION;
  existing_job_title  			    EXCEPTION;
  max_sale_smaller_than_min_sale	EXCEPTION;
  num_of_same_title			        NUMBER;
BEGIN
    IF NOT REGEXP_LIKE(new_job_id,'^[[:alnum:]]{2}_[[:alnum:]]{1,7}$') THEN
        RAISE wrong_job_id_format;
    END IF;
    
    SELECT COUNT(job_title) INTO num_of_same_title
    FROM jobs
    WHERE UPPER(new_job_title) = UPPER(job_title);
    IF num_of_same_title >= 1 THEN
        RAISE existing_job_title;
    END IF;
    
    IF new_max_sal < new_min_sal THEN
        RAISE max_sale_smaller_than_min_sale;
    END IF;
    
    INSERT INTO jobs(job_id, job_title, min_salary, max_salary)
    VALUES (UPPER(new_job_id), new_job_title, new_min_sal, new_max_sal);
    
    DBMS_OUTPUT.PUT_LINE('Job successfully inserted: ' || new_job_title);

EXCEPTION
    WHEN wrong_job_id_format THEN
        DBMS_OUTPUT.PUT_LINE('Job ID does not match the expected format!');
    WHEN existing_job_title THEN
        DBMS_OUTPUT.PUT_LINE('Job Title already exists in the table!');
    WHEN max_sale_smaller_than_min_sale THEN
        DBMS_OUTPUT.PUT_LINE('The maximum salary cannot be smaller than the minimum salary!');
END create_job_moritz;
/

-- tests
-- SET SERVEROUTPUT ON;
BEGIN
    --ok
    create_job_moritz('IT_GOAT', 'Wenninger', 3000, 6000);
    --exists
    create_job_moritz('FR_COOLBRO', 'Megacoolbro', 4000, 8000);
    --invalid id
    create_job_moritz('XXINVALID', 'Invalid', 2000, 4000);
    -- min > max
    create_job_moritz('MK_MGR', 'NeedMoreMoney', 5000, 3000);
END;
/

-- 1b what if tuple already exists in job_history
CREATE OR REPLACE PROCEDURE append_job_history (
    h_employee_id      IN NUMBER,
    h_start_date        IN DATE,
    h_end_date          IN DATE,
    h_job_id           IN VARCHAR2,
    h_department_id        IN NUMBER
) AS
  not_existing_employee 		    EXCEPTION;
  not_existing_job_id  			    EXCEPTION;
  not_existing_department_id    	EXCEPTION;
  num_of_employees                  NUMBER;
  num_of_jobs                       NUMBER;
  num_of_departments                NUMBER;
BEGIN
    SELECT COUNT(employee_id) INTO num_of_employees
    FROM employees
    WHERE h_employee_id = employee_id;
    IF num_of_employees = 0 THEN
        RAISE not_existing_employee;
    END IF;
    
    SELECT COUNT(job_id) INTO num_of_jobs
    FROM jobs
    WHERE UPPER(h_job_id) = UPPER(job_id);
    IF num_of_jobs = 0 THEN
        RAISE not_existing_job_id;
    END IF;
    
    IF h_department_id IS NOT NULL THEN
        SELECT COUNT(department_id) INTO num_of_departments
        FROM departments
        WHERE h_department_id = department_id;
        IF num_of_departments = 0 THEN
            RAISE not_existing_department_id;
        END IF;
    END IF;
    
    INSERT INTO job_history(employee_id, start_date, end_date, job_id, department_id)
    VALUES (h_employee_id, h_start_date, h_end_date, UPPER(h_job_id), h_department_id);
    
    DBMS_OUTPUT.PUT_LINE('Entry in job_history successfully inserted');
    
EXCEPTION
    WHEN not_existing_employee THEN
        DBMS_OUTPUT.PUT_LINE('Employee ID does not exist in database!');
    WHEN not_existing_job_id THEN
        DBMS_OUTPUT.PUT_LINE('Job ID does not exist in database!');
    WHEN not_existing_department_id THEN
        DBMS_OUTPUT.PUT_LINE('Department ID does not exist in database!');
END append_job_history;
/

-- tests
BEGIN
    -- ok
    append_job_history(100, DATE '2020-01-01', DATE '2021-01-01', 'IT_GOAT', 60);
    -- not existing employee
    append_job_history(900, DATE '2020-01-01', DATE '2021-01-01', 'IT_GOAT', 60);
    -- not existing job
    append_job_history(100, DATE '2020-01-01', DATE '2021-01-01', 'Invalid', 60);
    -- not existing department
    append_job_history(100, DATE '2020-01-01', DATE '2021-01-01', 'IT_GOAT', 900);
    -- append with null department
    append_job_history(103, DATE '2020-01-01', DATE '2021-01-01', 'IT_GOAT', NULL);
END;
/

-- 2a
CREATE OR REPLACE PROCEDURE check_employee_salary (
    child_employee              IN NUMBER
) AS
  not_existing_employee		EXCEPTION;
  not_existing_manager      EXCEPTION;
  
  num_of_employees          NUMBER;
  parent_manager_id              NUMBER;
  employee_salary                 NUMBER;
  manager_salary                 NUMBER;
BEGIN
    -- check existense of employee
    SELECT COUNT(child_employee) INTO num_of_employees
    FROM employees
    WHERE child_employee = employee_id;
    IF num_of_employees = 0 THEN
        RAISE not_existing_employee;
    END IF;
    
    -- get emp salary and manager_id
    SELECT salary, manager_id INTO employee_salary, parent_manager_id
    FROM employees
    WHERE child_employee = employee_id;
    
    -- has manager
    IF parent_manager_id IS NULL THEN
        RAISE not_existing_manager;
    END IF;
    
    -- get manager sal
    SELECT salary INTO manager_salary
    FROM employees
    WHERE employee_id = parent_manager_id;
    
    -- compare and update
    IF employee_salary >= manager_salary THEN
        UPDATE employees
           SET salary = employee_salary * 1.1
         WHERE employee_id = parent_manager_id;
        DBMS_OUTPUT.PUT_LINE('salary succesfully updated');
    END IF;
    
EXCEPTION
    WHEN not_existing_employee THEN
        DBMS_OUTPUT.PUT_LINE('Employee ID does not exist in database!');
    WHEN not_existing_manager THEN
        DBMS_OUTPUT.PUT_LINE('Manager ID does not exist in database!');
END;
/

-- test
BEGIN
    check_employee_salary(200);
END;
/

-- 2b
CREATE OR REPLACE PROCEDURE check_sal_of_all_emp AS
  CURSOR c1 IS
  SELECT employee_id FROM employees FOR UPDATE;
  c1_employee_id employees.employee_id%TYPE;
BEGIN
    OPEN c1;
    LOOP
        FETCH c1 into c1_employee_id;
        EXIT WHEN c1%NOTFOUND;
        check_employee_salary(c1_employee_id);
    END LOOP;
    CLOSE c1;
END;
/

-- test
BEGIN
    check_sal_of_all_emp();
END;
/
