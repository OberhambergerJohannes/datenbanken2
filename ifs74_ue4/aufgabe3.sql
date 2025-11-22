SELECT d.DEPARTMENT_ID,
       XMLELEMENT("department",
                  XMLATTRIBUTES(d.DEPARTMENT_ID "department_id", d.DEPARTMENT_NAME "department_name"),
                  (SELECT XMLAGG(
                           XMLELEMENT(location,
                           XMLFOREST(l.LOCATION_ID, l.STREET_ADDRESS, l.POSTAL_CODE, l.CITY, l.COUNTRY_ID)))
                   FROM LOCATIONS l
                   WHERE l.LOCATION_ID = d.LOCATION_ID)
       )
FROM DEPARTMENTS d
WHERE d.LOCATION_ID IN (SELECT l.LOCATION_ID FROM locations l WHERE l.COUNTRY_ID = 'UK');