/*
Covid 19 Data Exploration 
skills used: Joins, Windows Functions, Aggregate Functions, Converting Data Types, CTE's, Temp Tables, Creating Views
*/

select * 
from [dbo].[CovidVaccinations$]

select * 
from [dbo].[CovidDeaths$]
order by 3,4

-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from [dbo].[CovidDeaths$]
order by 1,2

-- looking at total cases vs total deaths

select location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 DeathPercentage
from [dbo].[CovidDeaths$]
where location like '%nam'
order by 1,2

-- looking at total cases vs population
-- showing what percentage of population got covid

select location, date, total_cases, population, 
round((total_cases/population)*100,2) CovidCasesPercentage
from [dbo].[CovidDeaths$]
--where location like '%nam'
order by 1,2


-- looking at countries with highest infection rate compared to population

select location, date, total_cases, population, 
max((total_cases/population)*100) CovidCasesPercentage
from [dbo].[CovidDeaths$]
group by location,date, total_cases, population
--where location like '%nam'
order by 1,2

--- break things down by continent

select continent, max(cast(total_deaths as int)) as TotalDeath
from CovidDeaths$
where continent is not null
group by continent
order by TotalDeath

select location, max(cast(total_deaths as int)) as TotalDeath
from CovidDeaths$
where continent is null
group by location
order by TotalDeath desc

 
 select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
 ,sum(cast (vac.new_vaccinations as int)) over(partition by dea.location order by dea.location) as RollingPeopleVaccinated
 , (RollingPeopleVaccinated/population)*100
 from CovidDeaths$ dea
 join CovidVaccinations$ vac
 on dea.location = vac.location and dea.date = vac.date
 where dea.continent is not null 
 order by 2,3 desc


 --- use CTE
 with PopuvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as 
 (
 select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
 ,sum(cast (vac.new_vaccinations as int)) over(partition by dea.location order by dea.location) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
 from CovidDeaths$ dea
 join CovidVaccinations$ vac
 on dea.location = vac.location and dea.date = vac.date
 where dea.continent is not null 
 --order by 2,3 desc
 )

select * from PopuvsVac


-- temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(50),
location nvarchar (50),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
 select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
 ,sum(cast (vac.new_vaccinations as int)) over(partition by dea.location order by dea.location) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
 from CovidDeaths$ dea
 join CovidVaccinations$ vac
 on dea.location = vac.location and dea.date = vac.date
 where dea.continent is not null 
 --order by 2,3 desc

 select * from #PercentPopulationVaccinated

 -- creating views to store data for later visualizations

 create view PercentPopulationVaccinated as
 select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
 ,sum(cast (vac.new_vaccinations as int)) over(partition by dea.location order by dea.location) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
 from CovidDeaths$ dea
 join CovidVaccinations$ vac
 on dea.location = vac.location and dea.date = vac.date
 where dea.continent is not null 
 --order by 2,3 desc

 select * from PercentPopulationVaccinated
