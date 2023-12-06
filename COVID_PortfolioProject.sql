--/*
--Covid 19 Data Exploration 

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

--*/


Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4


--- Select Data that we are going to be starting with

Select Location, date new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
--Where continent is not null 
order by 1,2


---- New Cases vs population
--total deaths vs new cases
---- Shows likelihood of dying if you contract covid in your country



Select Location, date, new_cases, new_deaths, (new_deaths/ population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2

Select Location, date, new_cases,total_deaths, (total_deaths/ nullif(new_cases,0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


--4.New Cases vs Population Shows what percentage of population infected with Covid

Select Location, date, Population, new_cases,  (new_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2





--5. Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases_per_million) as HighestInfectionCount,  Max((total_cases_per_million/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc




--6. Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where location like '%states%'
--Where continent is not null 
Group by Location
order by TotalDeathCount desc



--7. BREAKING THINGS DOWN BY CONTINENT

---- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



---- 8.GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



---- 9.Total Population vs Vaccinations
---- Shows Percentage of Population that has recieved at least one Covid Vaccine

select de.continent, de.location, de.date, de.population, va.new_vaccinations,
SUM(convert(bigint,va.new_vaccinations )) OVER (Partition by de.location order by  de.location, 
de.date) as Rollingtotalvaccine
--, (RollingPeopleVaccinated/population)*100
from
PortfolioProject..CovidDeaths de
join PortfolioProject..covidvaccination va
 on de.location = va.location
and de.date = va.date
where de.continent is not null
order by 2,3




----10. Using CTE to perform Calculation on Partition By in previous query


With PopvsVac (Continent, Location, Date, Population, new_Vaccinations, Rollingtotalvaccine)
as
(
Select de.continent, de.location, de.date, de.population, va.new_vaccinations
, SUM(CONVERT(bigint,va.new_vaccinations)) OVER (Partition by de.Location Order by de.location, de.Date) as Rollingtotalvaccine
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths de
join PortfolioProject..covidvaccination va
	On de.location = va.location
	and de.date = va.date
where de.continent is not null 
--order by 2,3
)
Select *, (Rollingtotalvaccine/Population)*100 as PerDayvaccine
From PopvsVac



----11. Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
----12.Insert into #PercentPopulationVaccinated
Select de.continent, de.location, de.date, de.population, va.new_vaccinations
, SUM(CONVERT(bigint,va.new_vaccinations)) OVER (Partition by de.Location Order by de.location, de.Date) as RollingPeopleVaccinated
------, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths de
Join PortfolioProject..covidVaccination va
	On de.location = va.location
	and de.date = va.date
where de.continent is not null 
------order by 2,3
--13.complete PercentPopulationVaccinated table
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



----14. Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select de.continent, de.location, de.date, de.population, va.new_vaccinations
, SUM(CONVERT(bigint,va.new_vaccinations)) OVER (Partition by de.Location Order by de.location, de.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths de
Join PortfolioProject..covidVaccination va
	On de.location = va.location
	and de.date = va.date
where de.continent is not null 



