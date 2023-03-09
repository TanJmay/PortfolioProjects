
select * 
from [dbo].[CovidDeaths$]
where continent is not null
order by 3,4


--select * from [dbo].[CovidVaccination$] order by 3,4


--Select Location, date, total_cases, new_cases, total_deaths, population from CovidDeaths$ order by Total_cases
--Loking total caces for death, dying if you get concate with covid
Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths$ 
where location like '%states%'and continent is not null
order by 1,2


--Looking at Total cases vs population
Select Location, date, population, total_cases,  (total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths$ 
where location like '%india%' and continent is not null
order by 1,2


--looking for country with higest infwection rage compared to population
Select Location, population, MAX(total_cases) as HigestInfectionCount,  MAX(total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths$ 
where  continent is not null-- location like '%india%'
Group by Location, population
order by PercentagePopulationInfected desc


--showing the countries with higest death count per popullation
Select Location,  MAX(cast(total_deaths as int)) as TotalDeathCount	
from CovidDeaths$ 
where  continent is not null--where location like '%india%'
Group by Location
order by TotalDeathCount desc

--countries with higest death count per popullation by continet
Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount	
from CovidDeaths$ 
where  continent is not null--where location like '%india%'
Group by continent
order by TotalDeathCount desc

--WORLD PLUS ALL THE OHTER CONTINENTS
Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount	
from CovidDeaths$ 
where  continent is null--where location like '%india%'
Group by location
order by TotalDeathCount desc


--Global Numbers
Select date,  SUM(cast(new_cases as int)) as Total_cases,
SUM(cast(new_deaths as int)) as Total_Death,
Sum(cast(new_deaths as int))/SUM(new_Cases)*100 as DeathPercentage
from CovidDeaths$ 
where  continent is not null--where location like '%india%'
Group by date
order by 1,2

--Total number of cases/death in percentage
Select SUM(cast(new_cases as int)) as Total_cases,
SUM(cast(new_deaths as int)) as Total_Death,
Sum(cast(new_deaths as int))/SUM(new_Cases)*100 as DeathPercentage
from CovidDeaths$ 
where  continent is not null--where location like '%india%'
order by 1,2

--joining both the table by location and date
select *
from ProjectPortfolio..CovidDeaths$ dea
join ProjectPortfolio..CovidVaccination$ vac
     on dea.location=vac.location
	 and dea.date=vac.date

-- Looking at Total Population vs Vaccination
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
from ProjectPortfolio..CovidDeaths$ dea
join ProjectPortfolio..CovidVaccination$ vac
     on dea.location=vac.location
	 and dea.date=vac.date
where  dea.continent is not null
order by 2,3

--Select dea.continent, dea.location,dea.date,dea.population,vacs.new_vaccinations
--from ProjectPortfolio..CovidDeaths$ dea
--join ProjectPortfolio..CovidVaccinations vacs
--     on dea.location=vacs.location
--	 and dea.date=vacs.date
--where  dea.continent is not null and dea.location like '%Canada%'
--order by 2,3

Select distinct dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over ( Partition by dea.location
order by dea.location,dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths$ dea
join ProjectPortfolio..CovidVaccination$ vac
     on dea.location=vac.location
	 and dea.date=vac.date
where  dea.continent is not null
order by 2,3

-- USE CTE

With PopVsVAC (Contient, Location, Date, Population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select distinct dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over ( Partition by dea.location
order by dea.location,dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths$ dea
join ProjectPortfolio..CovidVaccination$ vac
     on dea.location=vac.location
	 and dea.date=vac.date
where  dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)/100 as CurrentlyVaccinatedPeopl
from PopVsVAC

-- TEMP TABLE

DROP Table if exists #PercentpopulationVaccinated
create table #PercentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
select distinct * from #PercentpopulationVaccinated

insert into #PercentpopulationVaccinated
Select distinct dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over ( Partition by dea.location
order by dea.location,dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths$ dea
join ProjectPortfolio..CovidVaccination$ vac
     on dea.location=vac.location
	 and dea.date=vac.date
where  dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)/100 as PercentageOfRollingPeopleVaccination
from #PercentpopulationVaccinated


--Creating view to store data for later Visualization
Create View PercentpopulationVaccinated 
as
Select distinct dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over ( Partition by dea.location
order by dea.location,dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths$ dea
join ProjectPortfolio..CovidVaccination$ vac
     on dea.location=vac.location
	 and dea.date=vac.date
where  dea.continent is not null


select *
From PercentpopulationVaccinated