
SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select data that we will be using

SELECT location,date,total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likehood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like'Lithuania'
AND continent is not null
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location,date,total_cases,population,(total_cases/population)* 100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
ORDER BY 1,2;

--Looking at Countries with Highest Infection Rate compare to Population

SELECT location,population,MAX(total_cases)as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
GROUP BY Location,Population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT


--Showing continents with the highest death count per population

SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


--Global numbers

SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;


-- Looking at total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER by 1, 2


-- USE CTE 

WITH PopvsVac (Continent,Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100 
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER by 2, 3
	)
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100 
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER by 2, 3

	SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated



--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100 
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER by 2, 3

	SELECT * 
	FROM PercentPopulationVaccinated