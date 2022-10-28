create database PortfolioProject;
use PortfolioProject;

drop table if exists CovidDeaths
create table CovidDeaths (
iso_code varchar (60) NOT NULL,
continent varchar (60) NOT NULL,
location varchar (60) NOT NULL,
population integer NOT NULL,
date_ varchar (60) NOT NULL,
total_cases integer NOT NULL ,
new_cases varchar (60) NOT NULL ,
new_cases_smoothed varchar (60)  ,
total_deaths integer NOT NULL,
new_deaths integer NOT NULL,
new_deaths_smoothed FLOAT NOT NULL,
total_cases_per_million FLOAT NOT NULL,
new_cases_per_million FLOAT NOT NULL,
new_cases_smoothed_per_million FLOAT NOT NULL,
total_deaths_per_million FLOAT NOT NULL,
new_deaths_per_million FLOAT NOT NULL,
new_deaths_smoothed_per_million FLOAT NOT NULL,
reproduction_rate FLOAT NOT NULL,
icu_patients FLOAT NOT NULL,
icu_patients_per_million FLOAT NOT NULL,
hosp_patients integer NOT NULL,
hosp_patients_per_million FLOAT NOT NULL,
weekly_icu_admissions FLOAT NOT NULL,
weekly_icu_admissions_per_million FLOAT NOT NULL,
weekly_hosp_admissions FLOAT NOT NULL,
weekly_hosp_admissions_per_million FLOAT NOT NULL,
total_tests integer NOT NULL )

SELECT COUNT(*) FROM CovidDeaths;
SET sql_mode = "";
LOAD DATA INFILE "R:/INEURON/PROJECT FROM YOUTUBE/COVID/Covid_Deaths.CSV"
INTO TABLE CovidDeaths
COLUMNS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;

SELECT *FROM CovidDeaths WHERE location LIKE '%WOR%';
SELECT *FROM CovidVacination;
SELECT COUNT(*) FROM CovidVacination
;

create table CovidVacination (
iso_code varchar(60) not null,
continent varchar(60) not null,
location varchar(60) not null,
date_ varchar(60) not null,
new_tests integer NOT NULL,
total_tests_per_thousand FLOAT NOT NULL ,
new_tests_per_thousand FLOAT NOT NULL,
new_tests_smoothed FLOAT NOT NULL,
new_tests_smoothed_per_thousand FLOAT NOT NULL,
positive_rate FLOAT NOT NULL,
tests_per_case FLOAT NOT NULL,
tests_units FLOAT NOT NUll,
total_vaccinations integer NOT NULl, 
people_vaccinated integer NOT NULl,
people_fully_vaccinated integer NOT NULl,
total_boosters integer NOT NULl,
new_vaccinations integer NOT NULl,
new_vaccinations_smoothed integer NOT NULl,
total_vaccinations_per_hundred FLOAT NOT NUll,
people_vaccinated_per_hundred FLOAT NOT NUll,
people_fully_vaccinated_per_hundred FLOAT NOT NUll,
total_boosters_per_hundred FLOAT NOT NUll,
new_vaccinations_smoothed_per_million FLOAT NOT NUll,
new_people_vaccinated_smoothed FLOAT NOT NUll,
new_people_vaccinated_smoothed_per_hundred FLOAT NOT NUll,
stringency_index FLOAT NOT NUll,
population_density FLOAT NOT NUll,
median_age FLOAT NOT NUll,
aged_65_older FLOAT NOT NUll,
aged_70_older FLOAT NOT NUll,
gdp_per_capita FLOAT NOT NUll,
extreme_poverty FLOAT NOT NUll,
cardiovasc_death_rate FLOAT NOT NUll,
diabetes_prevalence FLOAT NOT NUll,
female_smokers FLOAT NOT NUll,
male_smokers FLOAT NOT NUll,
handwashing_facilities FLOAT NOT NUll,
hospital_beds_per_thousand FLOAT NOT NUll,
life_expectancy FLOAT NOT NUll,
human_development_index FLOAT NOT NUll,
excess_mortality_cumulative_absolute FLOAT NOT NUll,
excess_mortality_cumulative FLOAT NOT NUll,
excess_mortality FLOAT NOT NUll,
excess_mortality_cumulative_per_million FLOAT NOT NUll)


SET sql_mode = "";
LOAD DATA INFILE "R:/INEURON/PROJECT FROM YOUTUBE/COVID/Covid_Vacination.CSV"
INTO TABLE CovidVacination
COLUMNS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT * FROM CovidDeaths ORDER BY 3,4;
SELECT * FROM CovidVacination ORDER BY 3,4;


--DATA_WANT_TO_USE


SELECT location,date_,total_cases,new_cases,total_deaths,population FROM CovidDeaths ORDER BY 1,2;

--TOTAL_CASES_VS_tOTAL_DEATHS--
shows_the_likelyhood of daying if you have covid in ur country

SELECT location,date_,total_cases,total_deaths,population ,((total_deaths/total_cases)*100) AS DEATH_PERCENTAGE 
FROM CovidDeaths WHERE location like '%ind%' ORDER BY 1,2;

--looking at total cases vs population 
--percentage of population got covid

SELECT location,date_,total_cases,population ,((total_cases/population)*100) AS Covid_latency
FROM CovidDeaths WHERE location like '%ind%' ORDER BY 5  desc ;


--LOOKING FOR COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULTION

SELECT location,MAX(total_cases) AS Highest_infection_count,max(total_cases/population)*100 as max_covid_latency,population
FROM CovidDeaths 
GROUP BY 1,4
ORDER BY 3 DESC ;


--LOOKING AT COUNTIRES WITH HEIGHTEST DEATHCOUNT --
SELECT location,population, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths 
WHERE continent <>''
GROUP BY 1
ORDER BY 3 DESC ;


--break_down-as per continent
SELECT continent,population, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths 
GROUP BY continent
ORDER BY 3 DESC ;


--Global _numbers
SELECT date_,continent,population, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths 
WHERE continent <>''
GROUP BY date_
ORDER BY 3 DESC ;

,sum(CV.new_vaccinations) over (partition by CD.location )  
--lets work_on vacinations ;

looking_at_total population vs vacination 


SELECT CD.continent,CD.location,CD.date_,CD.population,CV.new_vaccinations
,sum(CV.new_vaccinations) over (partition by CD.location order by CD.location ,CD.date_ ) as rolling_vacination_count ,
FROM CovidVacination  CV
join CovidDeaths CD
	On CV.location = CD.location
	and CV.date_ = CD.date_
WHERE CV.continent <> ''
order by 2,3 ;
    
    --use_CTE;
    
with popvsvac (continent,location,date_ ,population,new_vaccinations,rolling_vacination_count) as 
(
SELECT CD.continent,CD.location,CD.date_,CD.population,CV.new_vaccinations
,sum(CV.new_vaccinations) over (partition by CD.location order by CD.location ,CD.date_ ) as rolling_vacination_count 
FROM CovidVacination CV
join CovidDeaths CD
	On CV.location = CD.location
	and CV.date_ = CD.date_
WHERE CV.continent <> ''
)select *,(rolling_vacination_count/population)*100 
from popvsvac ;


--creating views for further visulization 

create view percentpopulationvaccinated as
SELECT CD.continent,CD.location,CD.date_,CD.population,CV.new_vaccinations
,sum(CV.new_vaccinations) over (partition by CD.location order by CD.location ,CD.date_ ) as rolling_vacination_count 
FROM CovidVacination CV
join CovidDeaths CD
	On CV.location = CD.location
	and CV.date_ = CD.date_
WHERE CV.continent <> '';

