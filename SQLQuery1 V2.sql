/* 
COVID 19 Data Exploration 
Skills used : Joins,CTE, Temp Table, Windows Function, Aggregate Functions Creating Views, Conversion of Data types
*/

SELECT * 
FROM PortfolioProject..covid_deaths
order by 3,4

-- Data to start with
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covid_deaths
ORDER BY 1,2

--Total Cases vs Total Deaths
-- Likelihood of a person dying if gets infected in a country
SELECT  location, date , total_cases,new_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..covid_deaths
WHERE location like 'India'
and continent is not null
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT  LOCATION, date , total_cases,new_cases,total_deaths, (total_cases/population)*100 as populatioInfectionPercentage
From PortfolioProject..covid_deaths
order by 1,2

-- Countries with Highest Infection Rate compared to Population
SELECT  LOCATION,population , MAX(total_cases) as HiInfCt, MAX((total_cases/population))*100 as populatioInfectionPercentage
From PortfolioProject..covid_deaths
Group by location,population
order by populatioInfectionPercentage desc

-- Countries with Highest Death Count per Population
SELECT  LOCATION, MAX(cast(total_deaths as int)) as TotalDeathCnt
From PortfolioProject..covid_deaths
Where continent is not null
Group by location
order by TotalDeathCnt desc

--Filtering data based on Continents
-- Continents with heighest death count
SELECT  continent, MAX(cast(total_deaths as int)) as TotalDeathCnt
From PortfolioProject..covid_deaths
Where continent is not null
Group by continent
order by TotalDeathCnt desc


--Global Numbers
Select SUM(new_cases) as totalCase,SUM(cast(new_deaths as int)) as totalDeaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..covid_deaths
where continent is not null
order by 1,2

--Total populatio vs Vaccinations using CTE
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
with PopvsVac (Continent,Location,Date,Population,new_vaccinations,TotalVaccTillDay)
as
(
select da.continent, da.location, da.date, da.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by da.location order by da.location,da.date) as TotalVaccTillDay
--, (TotalVaccTillDay/da.population)*100
From  PortfolioProject..covid_deaths da
join PortfolioProject..covid_vacinations vac
on vac.location=da.location
and vac.date = da.date
where da.continent is not null 
order by 2,3
)
select * ,(TotalVaccTillDay/population)*100 
from PopvsVac 

-- Temp Table to perform Calculation on Partition By
Drop Table if exists #PerPopVac
create table #PerPopVac
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalVaccTillDay numeric)

Insert into #PerPopVac
select da.continent, da.location, da.date, da.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by da.location order by da.location,da.date) as TotalVaccTillDay
--, (TotalVaccTillDay/da.population)*100
From  PortfolioProject..covid_deaths da
join PortfolioProject..covid_vacinations vac
on vac.location=da.location
and vac.date = da.date
where da.continent is not null 

select * ,(TotalVaccTillDay/population)*100 
from #PerPopVac

-- Creating View to store data

Create view PerPopVacc as
select da.continent, da.location, da.date, da.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by da.location order by da.location,da.date) as TotalVaccTillDay
From  PortfolioProject..covid_deaths da
join PortfolioProject..covid_vacinations vac
on vac.location=da.location
and vac.date = da.date
where da.continent is not null 

select * from PerPopVacc

--View of Deaths By Continent
Create View DeathByContinent as
SELECT  continent, MAX(cast(total_deaths as int)) as TotalDeathCnt
From PortfolioProject..covid_deaths
Where continent is not null
Group by continent

select * from DeathByContinent