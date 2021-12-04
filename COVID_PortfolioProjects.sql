/**
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
**/

use Portfolio;
drop table if exists Portfolio.CovidDeaths;

create table Portfolio.CovidDeaths(
iso_code varchar(50) DEFAULT NULL, 
continent varchar(50) DEFAULT NULL,
location varchar(50) DEFAULT NULL,
date date DEFAULT NULL,
population int DEFAULT NULL,
total_cases int DEFAULT NULL,
new_cases int DEFAULT NULL,
new_cases_smoothed DECIMAL(10,5) DEFAULT NULL,	
total_deaths int DEFAULT NULL,	
new_deaths int DEFAULT NULL,	
new_deaths_smoothed DECIMAL(10,5) DEFAULT NULL,	
total_cases_per_million DECIMAL(10,5) DEFAULT NULL,	
new_cases_per_million DECIMAL(10,5) DEFAULT NULL,	
new_cases_smoothed_per_million DECIMAL(10,5) DEFAULT NULL,	
total_deaths_per_million DECIMAL(10,5) DEFAULT NULL,	
new_deaths_per_million DECIMAL(10,5) DEFAULT NULL,	
new_deaths_smoothed_per_million DECIMAL(10,5) DEFAULT NULL,	
reproduction_rate DECIMAL(10,5) DEFAULT NULL,	
icu_patients int DEFAULT NULL,	
icu_patients_per_million DECIMAL(10,5) DEFAULT NULL,	
hosp_patients int DEFAULT NULL,	
hosp_patients_per_million DECIMAL(10,5) DEFAULT NULL,	
weekly_icu_admissions DECIMAL(10,5) DEFAULT NULL,	
weekly_icu_admissions_per_million DECIMAL(10,5) DEFAULT NULL,	
weekly_hosp_admissions DECIMAL(10,5) DEFAULT NULL,	
weekly_hosp_admissions_per_million DECIMAL(10,5) DEFAULT NULL,	
new_tests int DEFAULT NULL,	
total_tests int DEFAULT NULL,
total_tests_per_thousand DECIMAL(10,5) DEFAULT NULL);

/** SHOW GLOBAL VARIABLES LIKE 'local_infile'; 
SET GLOBAL local_infile = TRUE;

SET SESSION sql_mode = ''; **/

LOAD DATA LOCAL INFILE '/Users/bet/Documents/BET/Other/other/Courses/Programming:Software/DataAnalytics/Portfolio/CovidDeaths.csv'
INTO TABLE Portfolio.CovidDeaths
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

select * from Portfolio.CovidDeaths;
select count(*) from Portfolio.CovidDeaths;

use Portfolio;
DROP TABLE IF EXISTS Portfolio.CovidVaccinations;

create table Portfolio.CovidVaccinations(
iso_code varchar(50),	
continent varchar(50),	
location varchar(50),	
date date,
new_tests int,	
total_tests int,
total_tests_per_thousand decimal(20,6),	
new_tests_per_thousand decimal(20,6),	
new_tests_smoothed decimal(20,6),	
new_tests_smoothed_per_thousand decimal(20,6),	
positive_rate decimal(20,6),	
tests_per_case decimal(20,6),
tests_units	varchar(50),
total_vaccinations int,	
people_vaccinated int,
people_fully_vaccinated int,
total_boosters int,	
new_vaccinations int,	
new_vaccinations_smoothed int,
total_vaccinations_per_hundred decimal(20,6),	
people_vaccinated_per_hundred decimal(20,6),
people_fully_vaccinated_per_hundred decimal(20,6),	
total_boosters_per_hundred decimal(20,6),	
new_vaccinations_smoothed_per_million int,	
stringency_index decimal(20,6),	
population int,	
population_density decimal(20,6),	
median_age int,	
aged_65_older decimal(20,6),	
aged_70_older decimal(20,6),	
gdp_per_capita decimal(20,6),	
extreme_poverty decimal(20,6),	
cardiovasc_death_rate decimal(20,6),	
diabetes_prevalence decimal(20,6),	
female_smokers decimal(20,6),	
male_smokers decimal(20,6),	
handwashing_facilities decimal(20,6),	
hospital_beds_per_thousand decimal(20,6),	
life_expectancy decimal(20,6),	
human_development_index decimal(20,6),	
excess_mortality_cumulative_absolute decimal(20,6),	
excess_mortality_cumulative	decimal(20,6),
excess_mortality decimal(20,6),	
excess_mortality_cumulative_per_million decimal(20,6));

LOAD DATA LOCAL INFILE '/Users/bet/Documents/BET/Other/other/Courses/Programming:Software/DataAnalytics/Portfolio/CovidVaccinations.csv'
INTO TABLE Portfolio.CovidVaccinations
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

Select * from Portfolio.CovidVaccinations;
Select count(*) from Portfolio.CovidVaccinations;


/** USING TABELS FOR CALCULATIONS AND ANALYSIS **/

/** COVID DEATHS**/
select * from Portfolio.CovidDeaths
where continent !=''; #so that we don't look at individual countries and not entire continents

select location, date, total_cases, new_cases, total_deaths, population 
from Portfolio.CovidDeaths 
where continent !=''
order by 1,2;

/** Total Cases vs. Total Deaths **/
/** shows the likelihood of dying if you contract covid in your country **/
select location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage 
from Portfolio.CovidDeaths
where location like '%states%' #'% %' gives us results that are close to whatever we write in between. Here that is 'United States' 
and continent !=''
order by 1,2;

/** Looking at Total Cases vs. Population **/
/** shows what percentage of the population got covid**/
select location, date, population, total_cases,
(total_cases/population)*100 as CovidPercentage 
from CPortfolio.ovidDeaths
where location like '%states%' #'% %' gives us results that are close to whatever we write in between. Here that is 'United States' 
and continent !=''
order by 1,2;

/** Looking at Countries with Highest Infection Rate compared to Population**/
select location, population, max(total_cases) as HighestInfectionCount,
max((total_cases/population))*100 as PercentPopulationInfected #If data type needs to be changed, ex: sum(cast(total_cases as int)) 
from Portfolio.CovidDeaths
where continent !=''
group by location, population
order by PercentPopulationInfected desc; #dec: descending

/** Let's break things down by location**/
/** Looking at Countries' Death Counts per Population**/
select location, max(total_deaths) as TCount
from Portfolio.CovidDeaths
where continent = '' and location != 'Upper middle income' and location != 'High income'  and location != 'Lower middle income' and location != 'Low income' 
group by location
order by TCount desc; 

select sum(total_deaths) from Portfolio.CovidDeaths where location = 'United States';

/** Let's break things down by continent**/
/** Showing continents with the highest death count per population**/
select continent, max(total_deaths) as TotalDeathCount
from Portfolio.CovidDeaths
where continent !=''
group by continent
order by TotalDeathCount desc; 

/** Global numbers **/
select date, sum(new_cases) as total__cases, sum(new_deaths) as total_deaths,
(sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from Portfolio.CovidDeaths
where continent !=''
group by date
order by 1,2;

/** COMBINING COVIDDEATHS AND COVIDVACCINATIONS **/

/** Join them on location and date **/ 
select * 
from Portfolio.CovidDeaths dea
join Portfolio.CovidVaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date;
    
/** Looking at Total Population vs. Vaccinations (1) **/ 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Portfolio.CovidDeaths dea
join Portfolio.CovidVaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent != ''    
order by 2,3;

/** Looking at Total Population vs. Vaccinations (2) **/ 
/** Rolling Count: As we go down the list of new vaccinations, we want a new column to add them up (2)**/ 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio.CovidDeaths dea 
join Portfolio.CovidVaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent != ''    
order by 2,3;

/** Looking at Total Population vs. Vaccinations (3) **/ 
/** Using CTE (a) **/ 
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio.CovidDeaths dea 
join Portfolio.CovidVaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent != '')
#order by 2,3)
select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated 
from PopvsVac; #To check how much of the current population is vaccinated, look at the last row of the country in the 'ercentageVaccinated ' column

/** Temp Table (b) **/ 
drop table if exists Portfolio.PercentPopulationVaccinated;
create table Portfolio.PercentPopulationVaccinated(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);

insert into Portfolio.PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio.CovidDeaths dea 
join Portfolio.CovidVaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent != '';
#order by 2,3)

select *, (RollingPeopleVaccinated/population)*100 as PercentagePopVaccinated 
from Portfolio.PercentPopulationVaccinated;

/** Creating View to store data for later visualization **/
create view Portfolio.PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio.CovidDeaths dea 
join Portfolio.CovidVaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent != '';
#order by 2,3);

select *
from Portfolio.PercentPopulationVaccinated;
