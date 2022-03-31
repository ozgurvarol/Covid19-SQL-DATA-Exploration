select * from CovidDeaths WHERE continent is not null order by 1,2
select * from CovidVaccinate order by 1, 2
--we found null data on continent so we shouldn't take this values.

---select data that we are going to be using;

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths order by 1,2

---Looking at Total Cases vs Total Deaths...

SELECT Location, date, total_cases, total_deaths, 
ROUND((total_deaths/total_cases)*100, 3) as DeathPercentage
FROM CovidDeaths
where location like '%states%' and continent is not null
order by 1,2


---Now, we are looking at Total Cases vs Population
---It will show us what percentage of population got Covid in USA.

SELECT Location, date, total_cases, Population, 
ROUND((total_cases/Population)*100, 3) as CovidPercentage
FROM CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

--------We are looking at COuntries with Highest Infection Rate compared to Population...

SELECT Location, Population, MAX(total_cases) as Highest_Infection_Count,
MAX((total_cases/Population))*100 as Percent_Infected_Population
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location, Population
ORDER By Percent_Infected_Population desc

--Show Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as bigint)) as Total_Death_Count
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Total_Death_Count DESC

---Showing continents with the highest death count Per Pop

SELECT continent, MAX(cast(Total_deaths as bigint)) as Total_Death_Count
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count DESC

----Lets check all new cases by date. --Lets do Percentage of new deaths based on New Cases

SELECT date, SUM(new_cases) as New_Cases, SUM(cast(new_deaths as bigint)) as New_Deaths,
ROUND(SUM(cast(new_deaths as bigint))/SUM(new_cases)*100, 3) as Death_Percentage
FROM CovidDeaths	
where continent is not null
GROUP BY date
ORDER BY Death_Percentage DESC
---so, we are seeing here that after vaccination death percentages getting lower
--even cases gettin more than before  
---february 19,24 and 20 on 2020 was highest death percantages....



-----lets see total population and new vaccinations by date. and we have to you joins..

SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations as NEW_VACCINATIONS
FROM CovidDeaths dea JOIN CovidVaccinate vac
ON dea.location = vac.location and dea.date = vac.date   ---here I connect 2 tables with 2 keys. location and date.
where dea.continent is not null
order by 2,3

--- I am seeing new vaccinations per day. what if I would like to see new vaccinations per day
--and total vaccinations for every day.. ;;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as NEW_VACCINATIONS,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) as TOTAL_VACCINATIONS
FROM CovidDeaths dea JOIN CovidVaccinate vac
ON dea.location = vac.location and dea.date = vac.date   ---here I connect 2 tables with 2 keys. location and date.
where dea.continent is not null
order by 2,3
--now after new vaccinations total vac = new vacc+new day vac.

----I want to see percentage of new vaccc by population.
---I will create CTE for that
----1st way with CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, TOTAL_VACCINATIONS) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as NEW_VACCINATIONS,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) as TOTAL_VACCINATIONS
FROM CovidDeaths dea JOIN CovidVaccinate vac
ON dea.location = vac.location and dea.date = vac.date   ---here I connect 2 tables with 2 keys. location and date.
where dea.continent is not null
)
select *, ROUND((TOTAL_VACCINATIONS/population)*100,3) as VaccinationPercentage
from PopVsVac

----I can do something using with TEMP table
DROP TABLE if exists #Vaccination_Percentage
CREATE TABLE #Vaccination_Percentage
(
continent nvarchar(255),
location  nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TOTAL_VACCINATIONS numeric
)
INSERT INTO #VAccination_Percentage
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as NEW_VACCINATIONS,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) as TOTAL_VACCINATIONS
FROM CovidDeaths dea JOIN CovidVaccinate vac
ON dea.location = vac.location and dea.date = vac.date   ---here I connect 2 tables with 2 keys. location and date.
where dea.continent is not null

select *, ROUND((TOTAL_VACCINATIONS/population)*100,3) as VaccinationPercentage
from #VAccination_Percentage order by 1,2
---this was second way...

---I will create view to soter data for later visualizations..

CREATE VIEW Percentage_Population_Vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as NEW_VACCINATIONS,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) as TOTAL_VACCINATIONS
FROM CovidDeaths dea JOIN CovidVaccinate vac
ON dea.location = vac.location and dea.date = vac.date   ---here I connect 2 tables with 2 keys. location and date.
where dea.continent is not null

select * from Percentage_Population_Vaccinated
---I will use this view for Tableau later on....__
