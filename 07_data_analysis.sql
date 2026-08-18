SELECT 'Top 10 Demanded Skills for Data Engineers' AS info;

WITH data_engineering_jobs AS (
    SELECT
        job_id,
        company_name,
        job_title_short,
        job_posted_date,
        salary_year_avg,
        UNNEST(skills_and_types) AS skills_info
    FROM flat_mart.job_postings
    WHERE job_title_short LIKE '%Data Engineer%'
)
SELECT
    UPPER(skills_info.name) AS skill,
    COUNT(*) AS postings_count,
    ROUND(AVG(salary_year_avg), 2) AS avg_salary
FROM data_engineering_jobs
WHERE skills_info.name IS NOT NULL
GROUP BY ALL
ORDER BY postings_count DESC
LIMIT 10;



SELECT 'Top 10 Companies Hiring Most Data Engineers' AS info;

WITH data_engineering_jobs AS (
    SELECT
        company_name,
        salary_year_avg
    FROM flat_mart.job_postings
    WHERE job_title_short LIKE '%Data Engineer%'
)
SELECT
    UPPER(company_name) AS company,
    COUNT(*) AS postings_count,
    ROUND(AVG(salary_year_avg), 2) AS avg_salary
FROM data_engineering_jobs
WHERE company_name IS NOT NULL
GROUP BY ALL
ORDER BY postings_count DESC
LIMIT 10;




SELECT 'Salary Distribution for Data Engineers' AS info;

WITH salary_brackets AS (
    SELECT
        job_id,
        company_name,
        job_title_short,
        job_posted_date,
        salary_year_avg,
        CASE
            WHEN salary_year_avg < 80000 THEN 'Below $80k'
            WHEN salary_year_avg BETWEEN 80000 AND 120000 THEN '$80k - $120k'
            WHEN salary_year_avg BETWEEN 120000 AND 160000 THEN '$120k - $160k'
            WHEN salary_year_avg BETWEEN 160000 AND 200000 THEN '$160k - $200k'
            WHEN salary_year_avg > 200000 THEN 'Above $200k'
        END AS salary_bracket
    FROM flat_mart.job_postings
    WHERE job_title_short LIKE '%Data Engineer%' AND salary_year_avg IS NOT NULL
)
SELECT
    salary_bracket,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_year_avg), 2) AS avg_salary_in_bracket,
    ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM salary_brackets), 2) || '%' AS percentage
FROM salary_brackets
GROUP BY salary_bracket
ORDER BY
    CASE salary_bracket
        WHEN 'Below $80k' THEN 1
        WHEN '$80k - $120k' THEN 2
        WHEN '$120k - $160k' THEN 3
        WHEN '$160k - $200k' THEN 4
        WHEN 'Above $200k' THEN 5
        ELSE 6
    END;    



SELECT 'Highest Paying Roles in the Industry' AS info;

SELECT
    job_title_short,
    ROUND(AVG(salary_year_avg)) AS avg_salary
FROM flat_mart.job_postings
GROUP BY job_title_short
ORDER BY avg_salary DESC
LIMIT 10;



SELECT 'Home Office VS Office in Salaries and Job Count' AS info;

WITH salary_brackets AS (
    SELECT
        job_id,
        company_name,
        job_title_short,
        job_posted_date,
        salary_year_avg,
        CASE
            WHEN job_work_from_home = true THEN 'Home Office Salary'
            WHEN job_work_from_home = false THEN 'Office Salary'
        END AS salary_type
    FROM flat_mart.job_postings
    WHERE salary_year_avg IS NOT NULL
)
SELECT
    salary_type,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_year_avg), 2) AS avg_salary_in_bracket,
    ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM salary_brackets), 2) || '%' AS percentage
FROM salary_brackets
GROUP BY salary_type
ORDER BY
    CASE salary_type
        WHEN 'Home Office Salary' THEN 1
        WHEN 'Office Salary' THEN 2  
    END;    


SELECT 'Top Paying Companies for Each Priority Role' AS info;

WITH company_avg_salaries AS (
    SELECT
        company_name,
        job_title_short,
        priority_lvl,
        ROUND(AVG(salary_year_avg), 2) AS avg_salary
    FROM priority_mart.priority_jobs_snapshot
    WHERE salary_year_avg IS NOT NULL
    GROUP BY ALL
),
ranked_companies AS (
    SELECT
        company_name,
        job_title_short,
        priority_lvl,
        avg_salary,
        DENSE_RANK() OVER (PARTITION BY job_title_short ORDER BY avg_salary DESC) AS rank
    FROM company_avg_salaries
)
SELECT * 
FROM ranked_companies 
WHERE rank <= 3
ORDER BY job_title_short, rank;



SELECT 'Quarterly Demand for Tech Skills' AS info;

WITH quarterly_skills_totals AS (
    SELECT 
        d.year_quarter,
        UPPER(s.skills) AS skill_name,
        SUM(f.postings_count) AS total_postings
    FROM skills_mart.fact_skill_demand_monthly f
    JOIN skills_mart.dim_skills s
        ON f.skill_id = s.skill_id
    JOIN skills_mart.dim_date_month d
        ON f.month_start_date = d.month_start_date
    GROUP BY ALL
),
ranked_quarterly_skills AS (
    SELECT
        year_quarter,
        skill_name,
        total_postings,
        DENSE_RANK() OVER (PARTITION BY year_quarter ORDER BY total_postings DESC) AS rank
    FROM quarterly_skills_totals
)
SELECT
    CASE WHEN rank = 1 THEN year_quarter ELSE '' END AS quarter,
    rank AS position,
    skill_name,
    total_postings
FROM ranked_quarterly_skills
WHERE rank <= 5
ORDER BY year_quarter, rank;