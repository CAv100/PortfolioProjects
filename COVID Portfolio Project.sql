SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent LIKE '%Asia%' AND location LIKE '%korea%'


--SELECT *
--FROM dbo.CovidVaccinations
--WHERE continent IS NOT NULL
--ORDER BY 3,4


-- SELECT THE DATA THAT WE ARE GOING TO BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--THE TOTAL_CASES VS TOTAL_DEATHS


SELECT location, date, total_cases, total_deaths, CONVERT(decimal(18,2),(CONVERT(DECIMAL(18,2), total_deaths) / CONVERT(DECIMAL(18,2), total_cases)) * 100) AS DeathsOverTotal
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY 1,2

--LOOKING AT THE TOTAL CASES VS POPULATION
--shows what population got covid

SELECT location, date, population, total_cases, CONVERT(decimal(18,7),(CONVERT(DECIMAL(18,7), total_cases) / CONVERT(DECIMAL(18,7), population)) * 100) AS DeathsOverTotal
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%nigeria%' AND continent IS NOT NULL
ORDER BY 1,2

--what countries has the highest infection rates compared to population

SELECT location, population, MAX(total_cases) AS MaxTotalCases, SUM(new_cases) AS TotaCases, CONVERT(decimal(18,7), MAX((CONVERT(DECIMAL(18,7), total_cases) / CONVERT(DECIMAL(18,7), population))) * 100) AS PercentpopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentpopulationInfected DESC

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT location, population, MAX(CAST(total_deaths AS int)) AS MaxDeaths, SUM(new_deaths) AS Total
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY MaxDeaths DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION
 
SELECT location, population, MAX(CAST(total_deaths AS int)) AS MaxDeaths, SUM(new_deaths) AS Total
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY location, population
ORDER BY MaxDeaths DESC

--BREAKING GLOBAL NUMBERS

SET ARITHABORT OFF;
SET ANSI_WARNINGS OFF;
SELECT SUM(new_cases) AS SumCases, SUM(new_deaths) AS SumDeaths, SUM(new_deaths)/SUM
(new_cases)* 100  AS DeathsOverTotal
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS SumVaccinations
--,SUM(MAX(new_vaccinations))/SUM(MAX(population)) AS PopVsVac
FROM [PortfolioProject].dbo.CovidDeaths dea
JOIN [PortfolioProject].dbo.CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, SumVaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS SumVaccinations
FROM [PortfolioProject].dbo.CovidDeaths dea
JOIN [PortfolioProject].dbo.CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (SumVaccinations/population) * 100
FROM PopVsVac

--USE TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated  
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population int,
new_vaccinations numeric,
SumVaccinations float
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS SumVaccinations
FROM [PortfolioProject].dbo.CovidDeaths dea
JOIN [PortfolioProject].dbo.CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (SumVaccinations/population) * 100
FROM #PercentPopulationVaccinated  

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS SumVaccinations
FROM [PortfolioProject].dbo.CovidDeaths dea
JOIN [PortfolioProject].dbo.CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated