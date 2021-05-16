-- /* Create database */
-- CREATE DATABASE Music;
-- GO
-- USE Music;
-- GO

-- to change data type
-- ALTER TABLE dbo.covid_deaths ALTER COLUMN total_cases FLOAT;  
-- GO
-- cast(x as type)

/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM ProjectPortfolio..covid_deaths
Where continent is not null 
ORDER BY 3,4

-- SELECT *
-- FROM ProjectPortfolio..covid_vaccination
-- ORDER BY 3,4

SELECT [location],[date],total_cases,new_cases,total_deaths,population
FROM ProjectPortfolio..covid_deaths
Where continent is not null 
ORDER BY 1,2

-- probability of dying due to covid 19 in indonesia
SELECT [location],[date],total_cases ,total_deaths, (total_deaths/total_cases)*100 as death_perc
FROM ProjectPortfolio..covid_deaths
where location like 'indo%'
and continent is not null 
ORDER BY 1,2

-- percentage of population got covid
SELECT [location],[date],total_cases ,population, (total_cases/population)*100 as covid_perc
FROM ProjectPortfolio..covid_deaths
where location like 'indo%'
ORDER BY 1,2

-- countries with highest infection rate compared to population
SELECT [location] ,population, max(total_cases) as highest_case,max(total_cases/population)*100 as covid_perc
FROM ProjectPortfolio..covid_deaths
-- where location like 'indo%'
GROUP BY population, [location]
ORDER BY covid_perc desc

-- countries with highest death count per population
SELECT [location] , max(cast(total_deaths as int)) as death_count
FROM ProjectPortfolio..covid_deaths
where continent is not null
-- where location like 'indo%'
GROUP BY [location]
ORDER BY death_count desc

-- contintents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..covid_deaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(cast(new_cases as float))*100 as DeathPercentage
From ProjectPortfolio..covid_deaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--total population vs vaccination
WITH popvsvac(continent, [location], date, population, new_vaccinations,rolling_vaccination) 
AS(
SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as rolling_vaccination
FROM ProjectPortfolio..covid_deaths dea
JOIN ProjectPortfolio..covid_vaccination vac
    ON dea.[location] = vac.[location]
    and dea.[date] = vac.[date]
where dea.continent is not null
--order by 2,3
)
SELECT *, (cast(rolling_vaccination as float)/population)*100
FROM popvsvac

-- temp table
drop TABLE if EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
DATE datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccination numeric
)

insert into #percent_population_vaccinated
SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as rolling_vaccination
FROM ProjectPortfolio..covid_deaths dea
JOIN ProjectPortfolio..covid_vaccination vac
    ON dea.[location] = vac.[location]
    and dea.[date] = vac.[date]
-- where dea.continent is not null
--order by 2,3
SELECT *, (cast(rolling_vaccination as float)/population)*100
FROM #percent_population_vaccinated

--views
-- Create View percent_population_vaccinated as
-- SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations, 
-- SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
-- dea.date) as rolling_vaccination
-- FROM ProjectPortfolio..covid_deaths dea
-- JOIN ProjectPortfolio..covid_vaccination vac
--     ON dea.[location] = vac.[location]
--     and dea.[date] = vac.[date]
-- where dea.continent is not null
-- --order by 2,3

