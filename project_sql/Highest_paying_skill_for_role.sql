/*
Question: What is the highest-paying skill for each job title?
- Find the average yearly salary for each skill within each job title (job_title_short).
- Identify the single skill that commands the highest average salary for every job title.
- Why? It helps professionals see which specific technology or skill correlates 
  dengan the highest paychecks for their specific career path.
*/
WITH job_skills_count AS (
    SELECT 
        DISTINCT(job_title_short) AS role,
        skills_dim.skills AS skill_name,
        COUNT(skills_job_dim.skill_id) AS skill_count,
        ROUND(AVG(salary_year_avg), 0) as avg_salary
    FROM
        job_postings_fact
    INNER JOIN skills_job_dim ON 
        job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON 
        skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        salary_year_avg IS NOT NULL
    GROUP BY
        role, 
        skill_name
    ORDER BY
        role,
        skill_count
),
ranked_skills AS (
    SELECT 
        role,
        skill_name,
        skill_count,
        avg_salary,
        ROW_NUMBER() OVER (PARTITION BY role ORDER BY avg_salary DESC) as rn
    FROM 
        job_skills_count
)

SELECT 
    role,
    skill_name,
    skill_count,
    avg_salary
FROM 
    ranked_skills
WHERE 
    rn = 1;