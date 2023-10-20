/* Querying the tables */

SELECT * 
FROM CovidDeaths
ORDER BY 3,4

--SELECT * 
--FROM CovidVaccinations
--ORDER BY 3,4

SELECT location,date,total_cases, new_cases, total_deaths, population
From CovidDeaths
ORDER By 1,2

--Look at the total cases vs total deaths 
-- Show the lilklihood of dying if you contact covid in your Country

SELECT location, date,total_cases,total_deaths,
(CAST(total_deaths AS FLoat)/ CAST (total_cases AS Float))*100 AS Death_percentage
FROM CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2



--Look at total cases vs Population 
SELECT location, date,population,total_cases, 
(CAST(total_cases AS FLoat)/ population)*100 AS populationInfectedPercent
FROM CovidDeaths
WHERE location LIKE '%india%'
ORDER BY 1,2


--look at highest infection rate compared to the population 
SELECT location,population,MAX(total_cases), 
(CAST(MAX(total_cases)AS FLoat)/ population)*100 AS HighestInfectedPopulation
FROM CovidDeaths
--WHERE location LIKE '%india%'
GROUP BY location,population
ORDER BY HighestInfectedPopulation DESC;

--look at highest death rate compared to the population
SELECT location,MAX(cast(total_deaths as int)) AS highestDeaths
FROM CovidDeaths
--WHERE location LIKE '%india%'
WHERE continent is not null
GROUP BY location
ORDER BY highestDeaths DESC;

-- LET'S BREAK THINGS DOWN TO CONTINENTS 
SELECT continent,MAX(cast(total_deaths as int))AS TotalDeathCount
FROM CovidDeaths
--WHERE location LIKE '%india%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--GOLBAL NUMBERS 

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as Total_deaths, 
SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
Where continent is not null
order by 1,2


--Look at population and Total Vaccinations 
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations))OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null 
ORDER BY 2,3

--USE CTE --
With PopvsVac (continent,location,date,population, new_vaccinations,RollingPeopleVaccinated)
as

(
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations))OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null 
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100 AS Vaccinatedpercentage
From PopvsVac






-- TEMP TABLE--
DROP TABLE IF EXISTS #PercentPopulationVacc
CREATE TABLE #PercentPopulationVacc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);

INSERT INTO #PercentPopulationVacc
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations))OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--Where dea.continent is not null 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated /Population)*100
From #PercentPopulationVacc
ORDER BY 2,3



-- CREATE VIEWS ANd STORE DATA FOR VISUALIZATION 

CREATE VIEW PercentPopulationVacc as 
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations))OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--Where dea.continent is not null 
--ORDER BY 2,3

Select * 
from PercentPopulationVacc




--COVID DEATH PERCENTAGE IN INDIA-- (using partition by) and CTE
SELECT cd.location, cd.date, cd.population, cd.new_deaths, SUM(cd.new_deaths) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) as totalDeaths 
FROM CovidDeaths cd
WHERE location LIKE '%india'

--USE CTE 
WITH indiaDeathPercentage (Location, Date, Population, new_deaths, totalDeaths)
AS
(SELECT cd.location, cd.date, cd.population, cd.new_deaths, SUM(cd.new_deaths) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) as totalDeaths
FROM CovidDeaths cd
WHERE location LIKE '%india'
)

SELECT *, (totalDeaths/Population)*100 AS DeathPercentage
FROM indiaDeathPercentage



--using group by
SELECT cd.location, SUM(cd.new_deaths) as totalDeaths, (SUM(cd.new_deaths)/cd.population)*100 AS OveralDeathPercentage
FROM CovidDeaths cd
WHERE location LIKE '%india'
GROUP BY cd.location, cd.population
ORDER BY 1




