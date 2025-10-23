--1a
ALTER TABLE jobs
ADD CONSTRAINT jobIDFormatConstraint CHECK (REGEXP_LIKE(job_id,'^[[:alnum:]]{2}_[[:alnum:]]{1,7}$');
ADD CONSTRAINT uniqueJobTitelConstraint UNIQUE (job_title);
ADD CONSTRAINT salaryCheckConstraint CHECK (min_salary <= max_salary);
ADD CONSTRAINT jobIdIsUpperConstraint CHECK (job_id = UPPER(job_id));
/

-- tests


-- 1b

