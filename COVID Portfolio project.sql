--select * from SQL_Project..CovidDeaths
--order by 3,4;
--select * from CovidVaccinations order by 3,4

select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
order by 1,2;


--Total_cases VS. Total_deaths // Death rate in particular country:
select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathRate
from CovidDeaths
where location like '%india%'

--Population that got covid:
select location, date, total_cases, population, (total_cases / population)*100 AS covid_Positive_population
from CovidDeaths
where location like '%india%'


--Looking at countries with highest cases compared to population:
select location, population, Max(total_cases) as highest_cases, MAX(total_cases / population)*100 AS covid_Positive_population
from CovidDeaths 
group by location,population
order by covid_Positive_population desc


--Countries with highest death count per populations
select location,max(cast(total_deaths as int)) as total_death_Count
from CovidDeaths
where continent is not null
group by location
order by total_death_Count desc


--Total deaths in different continents
select continent, max(cast(total_deaths as int)) as total_death_Count
from CovidDeaths
where continent is not null
group by continent
order by total_death_Count desc

--total cases and total deaths in the world during pendamic
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int)) / sum(new_cases) * 100 as deathPercentage
from CovidDeaths



--Number of people got vaccinationed every day and total number of vationation in specific location
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over(partition  by death.location order by death.location, death.date) 
as RollingPeoplevaccinated
from CovidDeaths as death
join CovidVaccinations as vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null


--USE CTE
with vaccinationRate(Continent, Location, Date, Population, Vaccination, RollingPeoplevaccinated )
as
(
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over(partition  by death.location order by death.location, death.date) 
as RollingPeoplevaccinated
from CovidDeaths as death
join CovidVaccinations as vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null
)
select *, (RollingPeoplevaccinated / Population) *100 as vaccineRate
from vaccinationRate


--Temp Table:

drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeoplevaccinated numeric
)

insert into #percentPopulationVaccinated
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over(partition  by death.location order by death.location, death.date) 
as RollingPeoplevaccinated
from CovidDeaths as death
join CovidVaccinations as vac
	on death.location = vac.location
	and death.date = vac.date
--where death.continent is not null
select *, (RollingPeoplevaccinated / Population) *100 as vaccineRate
from #percentPopulationVaccinated


--Creating view


create view percentPopulationVaccinated 
as
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over(partition  by death.location order by death.location, death.date) 
as RollingPeoplevaccinated
from CovidDeaths as death
join CovidVaccinations as vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null

select * from percentPopulationVaccinated