use hr_project;
select * from hr_dataset;

alter table hr_dataset
change column id emp_id varchar(20) null;

describe hr_dataset;

select birthdate from hr_dataset;
set sql_safe_updates=0;


-- Update the dataset for birthdate columns with appropiate str_to_date  

update hr_dataset
set birthdate = case
when birthdate like '%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y'), '%Y-%m-%d')
when birthdate like '%-%' then date_format(str_to_date(birthdate,'%m-%d-%Y'), '%Y-%m-%d')
else null
end;

-- change the datatype of birthdate columns
alter table hr_dataset
modify column birthdate date;

-- Update the dataset for hire_date columns with appropiate str_to_date  
update hr_dataset
set hire_date = case
when hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'), '%Y-%m-%d')
when hire_date like '%-%' then date_format(str_to_date(hire_date,'%m-%d-%Y'), '%Y-%m-%d')
else null
end;

-- Update the dataset for termdate columns with appropiate str_to_date  

-- update hr_dataset
-- set termdate = case
-- when termdate like '%/%' then date_format(str_to_date(termdate,'%m/%d/%Y'), '%Y-%m-%d')
-- when termdate like '%-%' then date_format(str_to_date(termdate,'%m-%d-%Y'), '%Y-%m-%d')
-- else null
-- end;

update hr_dataset 
set termdate=date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate != ' ';
 
 select termdate from hr_dataset;

-- change the datatype of hire_date columns
alter table hr_dataset
modify column hire_date date;


-- change the datatype of Hire_date and Term_date columns
alter table hr_dataset
modify column termdate date;

describe hr_dataset;

select * from hr_dataset;

-- Adding the columns for date difference 
alter table hr_dataset
add column age int;

-- Updating the columns for age difference using timestampdiff
update hr_dataset
set age=timestampdiff(year,birthdate,curdate());

select birthdate,age from hr_dataset;

select
min(age) as youngest,
max(age) as oldest
from hr_dataset;

select count(*) from hr_dataset where age < 18;

-- 1. What is the gender breakdown of employees in the company?
select gender, count(*) as count from hr_dataset
where age >=18 and termdate = '0000-00-00'
group by gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
select race, count(*) as count
from hr_dataset
where age >=18 and termdate = '0000-00-00'
group by race
order by count(*) desc;

-- 3. What is the age distribution of employees in the company?
select 
min(age) as youngest,
max(age) as oldest
 from hr_dataset
 where age >=18 and termdate='0000-00-00';
 
 select case 
 when age>= 18 and age<=24 then '18-24'
 when age>= 25 and age<=34 then '25-34'
 when age>= 35 and age<=44 then '35-44'
 when age>= 45 and age<=54 then '45-54'
 when age>= 55 and age<=64 then '55-64'
 else '65+'
 end as age_group,gender,
 count(*) as count from hr_dataset
where age >=18 and termdate='0000-00-00'
group by age_group,gender
order by age_group,gender;
 
 -- 4. How many employees work at headquater versus remote location?
 select location, count(*) as count
 from hr_dataset
 where age >=18 and termdate='0000-00-00'
 group by location;
 
 -- 5. What is the average lenght of employment for employees who have terminated?
 select round(avg(datediff(termdate,hire_date))/365,0) as avg_lenght_employment
 from hr_dataset
 where termdate<=curdate() and termdate<>'0000-00-00' and age>=18;
 
 -- 6. How does the gender distribution vary across departments and job titles?
 select department, gender, count(*) as count
 from hr_dataset
 where age >=18 and termdate='0000-00-00'
 group by department,gender
 order by department ;
 
 -- 7. What is the distribution of job titles across the company?
 select jobtitle, count(*) as count
 from hr_dataset
  where age >=18 and termdate='0000-00-00'
  group by jobtitle
  order by jobtitle desc;
  
  -- 8. Which department has the highest turnover rate?
  select department,
  total_count,
  terminated_count,
  terminated_count/total_count as termination_rate
  from(
  select department , count(*) as total_count,
  sum(case when termdate<>'0000-00-00' and termdate<= curdate() then 1 else 0 end) as terminated_count
  from hr_dataset
  where age>=8
  group by department) as subquery
  order by termination_rate desc;
  
  -- 9. What is the distribution of employees across loaction by city and state?
  select location_state, count(*) as count
  from hr_dataset
  where age>=18 and termdate='0000-00-00'
  group by location_state
  order by count desc;
  
  -- 10. How has the company employee count changed over time based on hire and term dates?
  select year,hires,terminations,hires-terminations as net_change,
  round((hires-terminations)/hires*100,2) as net_change_percent
  from (select year(hire_date) as year, count(*) as hires,
  sum(case when termdate<>'0000-00-00' and termdate<=curdate() then 1 else 0 end) as terminations
  from hr_dataset
  where age>=18
  group by year(hire_date)
  ) as subquery
order by year asc;

-- 11. What is the tenure distribution for each department?
select department, round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure
from hr_dataset
where termdate<= curdate() and termdate<> '0000-00-00' and age>=18
group by department;
