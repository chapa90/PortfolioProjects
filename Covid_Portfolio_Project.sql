SELECT * 
FROM DBO.CovidDeaths
ORDER BY 3,4

--SELECT * 
--FROM DBO.CovidVaccinations
--ORDER BY 3,4

-- Select the data we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
WHERE continent is not NULL
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM dbo.CovidDeaths
WHERE Location like '%states%'
ORDER BY 1, 2


--  Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as Total_Case_Percentage
FROM dbo.CovidDeaths
WHERE Location like '%states%'
ORDER BY 1, 2


-- Top Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Top Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Top Continents with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Showing the continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers
SELECT SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths ,SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1

-- Looking at total Population vs Vaccination with CTE

WITH PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER  BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER  BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 AS Percentage
FROM #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER  BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL


