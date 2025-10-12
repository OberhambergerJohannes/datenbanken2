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
