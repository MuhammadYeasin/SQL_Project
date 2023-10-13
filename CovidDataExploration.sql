select*
from covid19Project..CovidDeaths$
where continent is not null
order by 3,4

select*
from covid19Project..CovidVaccinations$ 
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from covid19Project..CovidDeaths$
where continent is not null
order by 1,2 

--looking at total cases vs total deaths
--likelyhood of dying if you had covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from covid19Project..CovidDeaths$
where continent is not null and location like 'Bangladesh'
order by 1,2 

--looking at total cases vs population
select location,date,total_cases,population,(total_cases/population)*100 as PercentageOfTotalCases
from covid19Project..CovidDeaths$
where continent is not null
--where location like 'Bangladesh'
order by 1,2 


--looking at countries with highest rate
select location,population,max(total_cases) as HighestAffectedCountry,max((total_cases/population))*100 as PercentageOfTotalCases
from covid19Project..CovidDeaths$
where continent is not null
group by population,location
order by PercentageOfTotalCases desc


--showing counries with highest death per population
select location,max(cast(total_deaths as int)) as totalDeathCount
from covid19Project..CovidDeaths$
where continent is not null
group by location
order by totalDeathCount desc

--break things down by continent

select location,max(cast(total_deaths as int)) as totalDeathCount
from covid19Project..CovidDeaths$
where continent is  null
group by location
order by totalDeathCount desc

--global numbers

select date,sum(new_cases) as TotalNewCases,sum(cast(new_deaths as int)) as TotalNewDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from covid19Project..CovidDeaths$
where continent is not null
--where location like 'Bangladesh'
group by date
order by 1

--looking for total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date )
as RollingPeopleVaccinated

from covid19Project..CovidDeaths$ as dea
join covid19Project..CovidVaccinations$ as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--using cte

with polVsVac(continent,location,date,population,new_vaccination,RollingPeopleVaccinated) as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date )
as RollingPeopleVaccinated

from covid19Project..CovidDeaths$ as dea
join covid19Project..CovidVaccinations$ as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select*,(RollingPeopleVaccinated/population)*100
from polVsVac



--Temp table
drop table if exists #PercentPolulationVaccinated
create table #PercentPolulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPolulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date )
as RollingPeopleVaccinated

from covid19Project..CovidDeaths$ as dea
join covid19Project..CovidVaccinations$ as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select*,(RollingPeopleVaccinated/Population)*100
from #PercentPolulationVaccinated


-- creating view to store data for later visualization

create view PercentPolulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date )
as RollingPeopleVaccinated

from covid19Project..CovidDeaths$ as dea
join covid19Project..CovidVaccinations$ as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPolulationVaccinated