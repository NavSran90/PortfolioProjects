Select * from PortfolioProject.dbo.CovidDeaths$
order by 3,4

--Select * from PortfolioProject.dbo.CovidVaccinations$
--order by 3,4

--Select data that we are going to be using

Select location, date,total_cases,new_cases,total_deaths,population
From PortfolioProject.dbo.CovidDeaths$
order by 1,2

--Looking at the totalcases versus total dealths
--Shows liklihood of dying if you contrcat covid
Select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
where location in ('Australia')
order by 1,2

--Looking at totalcases versus population (shows percentage of population that contracted covid in Australia)
Select location, date,population,total_cases,(total_cases/population)*100 as InfectedPopulation
From PortfolioProject.dbo.CovidDeaths$
--where location in ('Australia')
order by 1,2

--looking at countries with highest infection rate compared to population

Select location,population, Max(total_cases) as HighestInfecCount,MAX((total_cases/population))*100 as PercentOfPopulInfected From PortfolioProject.dbo.CovidDeaths$
group by location,population
order by PercentOfPopulInfected desc

--Showing countries with Highest Death Count per Population


Select continent,population,MAX(cast(total_deaths as int)) as TotalDeathCount,MAX(total_deaths/population)*100 as DeathCountPerPopulation
From PortfolioProject.dbo.CovidDeaths$
where continent IS NOT NULL
group by continent,population
order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as totalCases,SUM(new_deaths) as TotalDeaths,SUM(new_deaths) /Nullif(sum(new_cases),0)*100 as DeathPercentage--total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
where continent is Not NULL
group by date
order by 1,2

--Looking at the total vaccination vs the total population

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) Over (PARTITION by dea.location,dea.date)
 as RollingVacPopulation
from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ as vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not NULL 
order By 2,3

--CTE
With PopvsVac(Continent,location,date,population,new_vaccinations,RollingVacPopulation) as
(Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) Over (PARTITION by dea.location,dea.date)
 as RollingVacPopulation
from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ as vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not NULL 
--order By 2,3
)
Select *,(RollingVacPopulation/population)*100 as Vacper from PopvsVac

--temp Table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated (Continent nvarchar(255),Location nvarchar(255),Date datetime,Population Numeric,New_Vaccinations numeric,RollingPeopleVaccinated numeric)
Select * from #PercentPopulationVaccinated

Insert into #PercentPopulationVaccinated 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) Over (PARTITION by dea.location,dea.date)
 as RollingVacPopulation
from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ as vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not NULL 
order By 2,3

-- Creaing View to store data for later visualization

drop View if exists PercentPopulationVaccinated
GO
Create View PercentPopulationVaccinated as

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) Over (PARTITION by dea.location,dea.date)
 as RollingVacPopulation
from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ as vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not NULL ;
--order By 2,3

Select Location,RollingVacPopulation from PercentPopulationVaccinated where location='Australia' and RollingVacPopulation is not null
order by 2 desc

