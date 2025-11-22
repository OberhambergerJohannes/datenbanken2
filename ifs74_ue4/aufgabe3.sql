SELECT d.DEPARTMENT_ID,
       XMLELEMENT("department",
                  XMLATTRIBUTES(d.DEPARTMENT_ID "department_id", d.DEPARTMENT_NAME "department_name"),
                  (SELECT XMLAGG(
                                  XMLELEMENT(location,
                                             XMLFOREST(l.LOCATION_ID, l.STREET_ADDRESS, l.POSTAL_CODE, l.CITY,
                                                       l.COUNTRY_ID)))
                   FROM LOCATIONS l
                   WHERE l.LOCATION_ID = d.LOCATION_ID)
       )
FROM DEPARTMENTS d
WHERE d.LOCATION_ID IN (SELECT l.LOCATION_ID FROM locations l WHERE l.COUNTRY_ID = 'UK');
/

SELECT XMLELEMENT("job",
                  XMLELEMENT(jobdata,
                             XMLATTRIBUTES(j.JOB_ID AS "job_id"),
                             XMLFOREST(
                                     j.JOB_TITLE, j.MIN_SALARY, j.MAX_SALARY
                             )
                  ),
                  (SELECT XMLELEMENT("employee_data",
                                     XMLFOREST(count(e.EMPLOYEE_ID) AS "emp_count",
                                               MIN(e.SALARY) AS "min_sal",
                                               MAX(e.SALARY) AS "max_sal",
                                               AVG(e.SALARY) AS "avg_sal"
                                     )
                          )
                   FROM EMPLOYEES e
                   WHERE e.JOB_ID = j.JOB_ID))
FROM JOBS j
WHERE JOB_TITLE IN ('Sales Manager', 'Stock Manager', 'Marketing Manager');
/

SELECT XMLELEMENT("job",
                  XMLATTRIBUTES(j.JOB_ID AS "job_id", j.JOB_TITLE AS "job_title"),
                  (SELECT XMLAGG(
                                  XMLELEMENT("sales_manager",
                                             XMLATTRIBUTES(m.EMPLOYEE_ID,
                                             m.LAST_NAME AS "last_name"
                                      ),
                                             (SELECT XMLAGG(
                                                             XMLELEMENT("sub_emp",
                                                                        XMLATTRIBUTES(e.EMPLOYEE_ID,
                                                                        e.LAST_NAME,
                                                                        e.JOB_ID
                                                                 )
                                                             )
                                                     )
                                              FROM EMPLOYEES e
                                              WHERE m.EMPLOYEE_ID = e.MANAGER_ID)
                                  )
                          )
                   FROM EMPLOYEES m
                   WHERE m.JOB_ID = j.JOB_ID)
       )
FROM JOBS j
WHERE j.JOB_TITLE IN ('Sales Manager');
