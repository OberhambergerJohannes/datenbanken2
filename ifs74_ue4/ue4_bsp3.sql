SELECT d.DEPARTMENT_ID, XMLELEMENT("department",
    XMLATTRIBUTES(d.DEPARTMENT_ID AS "department_id", d.DEPARTMENT_NAME AS "department_name"),
    (SELECT XMLAGG(
	    XMLELEMENT("location",
		XMLFOREST(l.LOCATION_ID AS "location_id", 
                l.STREET_ADDRESS AS "street_address", 
                l.POSTAL_CODE AS "postal_code", 
                l.CITY AS "city",
                l.COUNTRY_ID AS "country_id"))) 
	FROM LOCATIONS l
	WHERE l.LOCATION_ID = d.LOCATION_ID)
) AS result
FROM DEPARTMENTS d
WHERE d.LOCATION_ID IN (
    SELECT l.LOCATION_ID 
    FROM locations l 
    WHERE l.COUNTRY_ID = 'UK');
/

SELECT XMLELEMENT("jobs", 
    XMLELEMENT("job_data", XMLATTRIBUTES(j.JOB_ID AS "job_id"),
	XMLFOREST(j.JOB_TITLE AS "job_title", j.MIN_SALARY AS "min_salary", j.MAX_SALARY AS "max_salary")
    ), 
    (SELECT XMLELEMENT("employee_data", 
	    XMLFOREST(count(e.JOB_ID) AS "emp_count",
		min(e.SALARY) AS "min_salary",
		max(e.SALARY) AS "max_salary",
		avg(e.SALARY) AS "avg_salary"))
	FROM employees e
	WHERE e.job_id = j.job_id))
FROM JOBS j
WHERE JOB_TITLE IN ('Sales Manager', 'Stock Manager', 'Marketing Manager');
/

SELECT XMLELEMENT("job", XMLATTRIBUTES(j.JOB_ID AS "job_id", j.JOB_TITLE AS "job_title"),
    (SELECT XMLAGG(
	    XMLELEMENT("sales_manager",
		XMLATTRIBUTES(sm.EMPLOYEE_ID AS "employee_id",
		    sm.LAST_NAME AS "last_name"
		),
		(SELECT XMLAGG(
			XMLELEMENT("sub_emp",
			    XMLATTRIBUTES(e.EMPLOYEE_ID AS "employee_id", e.LAST_NAME AS "last_name")
			))
		    FROM EMPLOYEES e
		    WHERE sm.EMPLOYEE_ID = e.MANAGER_ID)
	    )
	)
	FROM EMPLOYEES sm
	WHERE sm.JOB_ID = j.JOB_ID)
)
FROM JOBS j
WHERE JOB_TITLE = 'Sales Manager';
/