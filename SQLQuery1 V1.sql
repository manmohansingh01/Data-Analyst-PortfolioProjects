-- how likely  a person will die if gets infected in a country
SELECT  LOCATION, date , total_cases,new_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..covid_deaths
Where location like '%ndia%'
order by 1,2


SELECT  LOCATION, date , total_cases,new_cases,total_deaths, (total_cases/population)*100 as populatioInfectionPercentage
From PortfolioProject..covid_deaths
--Where location like '%ndia%'
order by 1,2

SELECT  LOCATION,population , MAX(total_cases) as HiInfCt, MAX((total_cases/population))*100 as populatioInfectionPercentage
From PortfolioProject..covid_deaths
--Where location like '%ndia%'
Group by location,population
order by populatioInfectionPercentage desc

-- countries with heighest death count
SELECT  LOCATION, MAX(cast(total_deaths as int)) as TotalDeathCnt
From PortfolioProject..covid_deaths
--Where location like '%ndia%'
Where continent is not null
Group by location
order by TotalDeathCnt desc

-- continents with heighest death count
SELECT  continent, MAX(cast(total_deaths as int)) as TotalDeathCnt
From PortfolioProject..covid_deaths
--Where location like '%ndia%'
Where continent is not null
Group by continent
order by TotalDeathCnt desc


--Global
Select SUM(new_cases) as totalCase,SUM(cast(new_deaths as int)) as totalDeaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..covid_deaths
where continent is not null
--Group By date
order by 1,2

--Total populatio vs Vaccinations using CTE
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

-- Temp Table
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
--, (TotalVaccTillDay/da.population)*100
From  PortfolioProject..covid_deaths da
join PortfolioProject..covid_vacinations vac
on vac.location=da.location
and vac.date = da.date
where da.continent is not null 
--order by 2,3

select * from PerPopVacc