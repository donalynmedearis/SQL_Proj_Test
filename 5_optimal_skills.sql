/*
Answer: What are the most optimal skills to learn (aka it's in high-demand and a high-paying skill)?
-Identify skills in high demand and associated with high average salaries for Data Analyst roles
-Concentrates on remote positions with specified salaries
-Why? Target skills that offer job security (high demand) and financial benefits (high salaries),
    offering strategic insights for career development in data analysis*/

--Build CTEs for queries 3 and 4 to combine results together

WITH skills_demand AS (--from query 3
    SELECT
        skills_dim.skill_id,
        skills_dim.skills, --(can't group by skills name and combine with another table it should be either primary or foreign key or any unique values such as: skill_id)
        COUNT(skills_job_dim.job_id) AS demand_count
    FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short = 'Data Analyst' 
        AND job_work_from_home = True
        AND salary_year_avg IS NOT NULL
    GROUP BY
        skills_dim.skill_id
    --ORDER BY (remove order by to speed the query, no need to limit results)
        --demand_count DESC
    --LIMIT 5
), average_salary AS (--from query 4
    SELECT
        skills_dim.skill_id,
        skills_dim.skills,  --(can't group by skills name and combine with another table it should be either primary or foreign key or any unique values such as: skill_id)
        ROUND(AVG(salary_year_avg),0) AS avg_salary
    FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short = 'Data Analyst' 
        AND job_work_from_home = True
        AND salary_year_avg IS NOT NULL
    GROUP BY
        skills_dim.skill_id
    --ORDER BY (remove order by to speed the query, no need to limit results)
      --avg_salary DESC
    --LIMIT 25
)

SELECT
    skills_demand.skill_id,
    skills_demand.skills,
    demand_count,
    avg_salary

--Combine both CTEs with INNER JOIN to show only what exist in both tables

FROM 
    skills_demand--(statement specifying the skills_demand temporary result set )
INNER JOIN average_salary ON skills_demand.skill_id = average_salary.skill_id
WHERE
    demand_count>10
ORDER BY
    avg_salary DESC,
    demand_count DESC
LIMIT 25;

--rewriting this same query more concisely with equal results
SELECT
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count,
    ROUND(AVG(job_postings_fact.salary_year_avg),0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst' 
    AND job_work_from_home = True
    AND salary_year_avg IS NOT NULL
GROUP BY
    skills_dim.skill_id
HAVING
    COUNT(skills_job_dim.job_id)>10 --Can't put aggregation method inside of WHERE clause
ORDER BY
     avg_salary DESC,
     demand_count DESC
     LIMIT 25;
