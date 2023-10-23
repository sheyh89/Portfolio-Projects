# Portfolio-Projects

select * from CovidDeaths
order by 3,4

--select * from CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths
from CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (convert(float,total_deaths)/nullif(convert(float,total_cases),0))*100 as DeathPercentage
from CovidDeaths
where location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

select location, date, total_cases, population, (convert(float,total_cases)/nullif(convert(float,population),0))*100 as DeathPercentage
from CovidDeaths
--where location like '%states%'
order by 1,2



-- Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max(convert(float,total_cases)/nullif(convert(float,population),0))*100 as PercentPopulationInfected
from CovidDeaths
group by location, population
order by PercentPopulationInfected desc;


-- Showing Countries with highest death count per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;


-- Breakdown by Continent

-- Showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;


-- Global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2


-- Looking at total population vs Vaccinations

select * from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


select dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100 from PopvsVac


-- TEMP TABLE

drop table #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated
