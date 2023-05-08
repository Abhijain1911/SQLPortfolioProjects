SELECT *
FROM PortfolioProjects..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProjects..CovidVaccination
ORDER BY 3,4

--Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths,population
FROM PortfolioProjects..CovidDeaths
ORDER BY 1,2

--looking at total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location LIKE 'India'
AND continent IS NOT NULL
ORDER BY 1,2

--looking at total cases vs population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasesPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location LIKE 'India'
AND continent IS NOT NULL
ORDER BY 1,2

--finding out highest infected rate w.r.t population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
		MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

--showing highest death count w.r.t location
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathsCount DESC

--let's break it down to continents
--showing continents with highest death count w.r.t population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC

--global numbers
SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths AS int)) AS Total_Deaths, 
		SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--looking at total population vs vaccinations
SELECT dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations, 
		SUM(CONVERT(int, vc.new_vaccinations)) OVER 
		(Partition by dt.location ORDER BY dt.location,dt.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dt
JOIN PortfolioProjects..CovidVaccination vc
ON dt.location=vc.location
AND dt.date=vc.date
WHERE dt.continent IS NOT NULL
ORDER BY 2,3

--use CTE
WITH PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
(
SELECT dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations, 
		SUM(CONVERT(int, vc.new_vaccinations)) OVER 
		(Partition by dt.location ORDER BY dt.location,dt.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dt
JOIN PortfolioProjects..CovidVaccination vc
ON dt.location=vc.location
AND dt.date=vc.date
WHERE dt.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--temp table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations, 
		SUM(CONVERT(int, vc.new_vaccinations)) OVER 
		(Partition by dt.location ORDER BY dt.location,dt.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dt
JOIN PortfolioProjects..CovidVaccination vc
ON dt.location=vc.location
AND dt.date=vc.date
WHERE dt.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--creating views to store data for later data visualisations
CREATE View PercentPopulationVaccinated AS 
SELECT dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations, 
		SUM(CONVERT(int, vc.new_vaccinations)) OVER 
		(Partition by dt.location ORDER BY dt.location,dt.date) AS RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dt
JOIN PortfolioProjects..CovidVaccination vc
ON dt.location=vc.location
AND dt.date=vc.date
WHERE dt.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated