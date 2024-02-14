Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to br using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%togo%'
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as casesPercentage
From PortfolioProject..CovidDeaths
Where location like '%togo%'
order by 1,2


--Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfectedPercentage
From PortfolioProject..CovidDeaths
--Where location like '%togo%'
Group by location, population
order by PopulationInfectedPercentage desc


--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as totalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by totalDeathCount desc


--Showing Countries with Highest death count per Population

Select Location, MAX(cast(total_deaths as int)) as totalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by totalDeathCount desc


--Showing Continents with Highest death count per Population

Select continent, MAX(cast(total_deaths as int)) as totalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by totalDeathCount desc


--GLOBAL NUMBERS 

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2



--Looking at Total Population vs Vaccinations

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

DROP Table IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualisation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
