select*
from PortfolioProject..['covid death$']
order by 3,4

select top 1094 location,continent, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..['covid death$']
order by 1,2,3

-- 1. Total cases vs total deaths
-- nb. rows 1095 and beyond contain duplicate/incorrect records

select top 1094 location,continent, date, total_cases, total_deaths, (total_deaths / total_cases )*100 as deathpercent
from PortfolioProject..['covid death$']
where location like '%states%' 
order by 1,2,3
 

 -- Total cases vs Population
 --shows the percentage of population that got covid

select top 1094 location,continent, date, total_cases, population, (total_cases / population )*100 as PercentinfectedPopulation
from PortfolioProject..['covid death$']
where location like '%states%' 
order by 1,2,3


--countries with highest infection rate compared to polulation 

select top 1094(location), continent, max(total_cases) as totalCase, population, max((total_cases / population ))*100 as PercentPopulationInfected
from PortfolioProject..['covid death$']
Where continent is not null
group by location, population, continent
order by PercentPopulationInfected desc
 
 --Countries with highest death count per population

 select top 1094(location), continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..['covid death$']
where continent is not null
group by location, continent
order by TotalDeathCount desc

----Death totals by continent

select top 1094 (continent), max(cast(total_deaths as int)) as TotalCountDeathCountbyContinent
from PortfolioProject..['covid death$']
where continent is not null
group by continent
order by TotalCountDeathCountbyContinent desc


--Daily infections across the world

select top 1094 date, sum( new_cases) as GlobalNewCases, SUM(CAST(new_deaths as int)) as globalNewDeaths, (SUM(CAST(new_deaths as int))/sum( new_cases))*100 as DeathPercentdaily
from PortfolioProject..['covid death$']
where continent is not null
group by date
order by 1,2


--total infections accross the world

select top 1094 sum( new_cases) as GlobaCases, SUM(CAST(new_deaths as int)) as globalDeaths, (SUM(CAST(new_deaths as int))/sum( new_cases))*100 as DeathPercent
from PortfolioProject..['covid death$']
where continent is not null
order by 1,2


--total population vs vaccination accross the world

select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as sumofVacToDate
from PortfolioProject..['covid death$'] as dea
join PortfolioProject..['covid vaccinations$'] as vac
on dea.location =vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


with PopvsVac (continent, location, date, population, new_vaccinations, sumofVacToDate) as

(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as sumofVacToDate
from PortfolioProject..['covid death$'] as dea
join PortfolioProject..['covid vaccinations$'] as vac
on dea.location =vac.location
and dea.date=vac.date
where dea.continent is not null
)
select*, (sumofVacToDate/population)*100 as PercenttPopulationvacc
from PopvsVac


--views
--1
use PortfolioProject
go
create view PerPopvaccbylocation as
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as sumofVacToDate
from PortfolioProject..['covid death$'] as dea
join PortfolioProject..['covid vaccinations$'] as vac
on dea.location =vac.location
and dea.date=vac.date
where dea.continent is not null

--2
use PortfolioProject
go
create view DeathPercentbydate as
select top 1094 date, sum( new_cases) as GlobalNewCases, SUM(CAST(new_deaths as int)) as globalNewDeaths, (SUM(CAST(new_deaths as int))/sum( new_cases))*100 as DeathPercent
from PortfolioProject..['covid death$']
where continent is not null
group by date

--3
use PortfolioProject
go
create view GlobaldeathPercent as
select top 1094 sum( new_cases) as GlobaCases, SUM(CAST(new_deaths as int)) as globalDeaths, (SUM(CAST(new_deaths as int))/sum( new_cases))*100 as DeathPercenttotal
from PortfolioProject..['covid death$']
where continent is not null
order by 1,2

--4
use PortfolioProject
go
create view USdeathPercent as
select top 1094 location,continent, date, total_cases, total_deaths, (total_deaths / total_cases )*100 as deathpercent
from PortfolioProject..['covid death$']
where location like '%states%' 
order by 1,2,3

--5

use PortfolioProject
go
create view HighestDeathCountPerPopulation as
 select top 1094(location), continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..['covid death$']
where continent is not null
group by location, continent
order by TotalDeathCount desc