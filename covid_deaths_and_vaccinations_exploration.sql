-- Show data from both covid_deaths and covid_vaccinations tables

select * from `linear-ellipse-396212.1.covid_deaths`
order by 1,2;

select * from `linear-ellipse-396212.1.covid_vaccinations`
order by 1,2;

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM `linear-ellipse-396212.1.covid_deaths` 
order by 1,2;

-- Look into the death percentage of infected patients

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as death_percentage
FROM `linear-ellipse-396212.1.covid_deaths` 
order by 1,2;

-- Total number of people who have been infected
-- and who have died from covid

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from `linear-ellipse-396212.1.covid_deaths`
where continent is not null;

-- Total number of deaths per continent

select location, sum(new_deaths) as total_deaths
from `linear-ellipse-396212.1.covid_deaths`
where continent is null and location not in ('World', 'European Union', 'International')
group by location
order by total_deaths desc;

-- Total Deaths vs Total Deaths in Kazakhstan
-- What percentage of patients with Covid-19 has died

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as death_percentage
FROM `linear-ellipse-396212.1.covid_deaths` 
where location = "Kazakhstan"
order by 1,2;

-- Total Cases vs Population in Kazakhstan
-- What percentage of population got Covid-19

SELECT location, date, total_cases, population, (total_cases/population)*100 as percentage_population_infected
FROM `linear-ellipse-396212.1.covid_deaths` 
where location = "Kazakhstan"
order by 1,2;

-- Look at 5 countries with highest infection rates compared to population

SELECT location, MAX(total_cases) as total_cases, MAX(population) as population, MAX(total_cases/population)*100 as percentage_population_infected
FROM `linear-ellipse-396212.1.covid_deaths` 
group by location
order by percentage_population_infected desc
LIMIT 5;

-- Show countries with highest number of deaths from covid

SELECT location, MAX(total_deaths) as death_count
FROM `linear-ellipse-396212.1.covid_deaths`
where continent is not null
group by location
order by death_count desc;

-- Showing countries with highest Death Count per Population

SELECT location, MAX(total_deaths) as death_count, MAX(population) as population, MAX(total_deaths/population)*100 as death_rate
FROM `linear-ellipse-396212.1.covid_deaths` 
group by location
order by death_rate desc;

-- Showing total cases and total deaths that occured for each day
-- as well as the death percentage for that day

SELECT date, 
       sum(new_cases) as total_cases, 
       sum(new_deaths) as total_deaths, 
       sum(new_deaths)/sum(new_cases)*100 as death_percentage
FROM `linear-ellipse-396212.1.covid_deaths` 
where continent is not null
group by date
order by date;


-- Looking at number of vaccinated people vs total population

with PopulationVsVaccinations as
(
select cd.location, 
       cd.date, 
       cd.population as population, 
       vac.new_vaccinations, 
       sum(vac.new_vaccinations) OVER(PARTITION BY cd.location order by cd.location, cd.date) as total_vaccinations_current
from `linear-ellipse-396212.1.covid_deaths` cd
join `linear-ellipse-396212.1.covid_vaccinations` vac
  on cd.location = vac.location and cd.date = vac.date
where cd.continent is not null
order by 1,2
)
Select *, round((total_Vaccinations_Current/population)*100,2) as percentage_population_vaccinated 
from PopulationVsVaccinations;

-- Create a View for future reference

drop view if exists `linear-ellipse-396212.1.PercentPeopleVaccinated`;

create view `linear-ellipse-396212.1.PercentPeopleVaccinated` as
select cd.location, 
       cd.date, 
       cd.population as population, 
       vac.new_vaccinations, 
       sum(vac.new_vaccinations) OVER(PARTITION BY cd.location order by cd.location, cd.date) as total_vaccinations_current
from `linear-ellipse-396212.1.covid_deaths` cd
join `linear-ellipse-396212.1.covid_vaccinations` vac
  on cd.location = vac.location and cd.date = vac.date
where cd.continent is not null;

select * from `linear-ellipse-396212.1.PercentPeopleVaccinated`;
