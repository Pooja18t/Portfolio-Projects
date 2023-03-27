select * from PortfolioProject..coviddeaths$
where continent is not null

select *from PortfolioProject..covidvaccinations$

--total_cases vs total_deaths
-- % of population got covid
select location , date , population, total_cases,(total_cases/population )*100 as percentofPopulationInfected
from PortfolioProject..coviddeaths$
where location like '%aus%' and ((total_cases/population)*100 )and  continent is not null
order by 1,2 

-- COUNTRIES WITH HIGEST INFECTION RATE compared to the population
select location  , population, max(total_cases) as HigestInfectionCount,max((total_cases/population ))*100 as percentofPopulationInfected 
from PortfolioProject..coviddeaths$
where continent is not null
Group by Location,population
order by percentofPopulationInfected desc

--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION 

select location , max(total_deaths) as TotaldeadCount
from PortfolioProject..coviddeaths$
where continent is  null
Group by Location
order by TotaldeadCount desc


--CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION 
select continent , max(total_deaths) as TotaldeadCount
from PortfolioProject..coviddeaths$
where continent is not null
Group by continent
order by TotaldeadCount desc

--GLOBAL NUMBERS
SELECT date,  sum(new_cases)as new_cases , sum(new_deaths)as new_deaths ,SUM(cast(new_deaths as int) )/SUM(new_cases)  AS globaldeaths 
FROM PortfolioProject..coviddeaths$
WHERE continent IS NOT NULL  
GROUP BY date
HAVING  SUM(new_cases)!=0  and SUM(new_deaths ) is not null 
ORDER BY 1,2 

-- TOTAL DATE OF GLOBAL

SELECT sum(new_cases)as new_cases , sum(new_deaths)as new_deaths ,SUM(cast(new_deaths as int) )/SUM(new_cases)  AS globaldeaths
FROM PortfolioProject..coviddeaths$
WHERE continent IS NOT NULL  
--GROUP BY date
HAVING  SUM(new_cases)!=0  and SUM(new_deaths ) is not null 
ORDER BY 1,2 

-- TOTAL POPULATION vs vaccination
select cd.continent, cd.location, cd.date, cd.population,cv.new_vaccinations, 
sum(cv.new_vaccinations) over 
(partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeaths$ cd
join PortfolioProject..covidvaccinations$ cv
 
 on cd.location= cv.location and
 cd.date = cv.date
 where cd.continent is not null -- and cv.new_vaccinations is not null
 
 order by 2,3 


 -- CTE: 

 With popvsvac (continent , location, date , population,new_vaccinations, RollingPeopleVaccinated)
 as
 (select cd.continent, cd.location, cd.date, cd.population,cv.new_vaccinations, 
sum(cv.new_vaccinations) over 
(partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeaths$ cd
join PortfolioProject..covidvaccinations$ cv
 
 on cd.location= cv.location and
 cd.date = cv.date
 where cd.continent is not null )-- and cv.new_vaccinations is not null
 
 -- order by 2,3

 select *,(RollingPeopleVaccinated/population)*100
 from popvsvac

 --TEMP TABLE 
 drop table if exists #percentpopulationvalinated 
 Create table #percentpopulationvalinated 
 (continent nvarchar(255), 
 location nvarchar(255),
 date datetime, 
 population numeric,
 new_vaccinations numeric, 
 RollingPeopleVaccinated numeric)

 Insert into #percentpopulationvalinated 
 select cd.continent, cd.location, cd.date, cd.population,cv.new_vaccinations, 
sum(cv.new_vaccinations) over 
(partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeaths$ cd
join PortfolioProject..covidvaccinations$ cv
 
 on cd.location= cv.location and
 cd.date = cv.date
 --where cd.continent is not null

 select *,(RollingPeopleVaccinated/population)*100
 from #percentpopulationvalinated 

 -- view to store date for later Visualizations

 create view percentpopulationvalinated as
 select cd.continent, cd.location, cd.date, cd.population,cv.new_vaccinations, 
sum(cv.new_vaccinations) over 
(partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeaths$ cd
join PortfolioProject..covidvaccinations$ cv
 
 on cd.location= cv.location and
 cd.date = cv.date
 where cd.continent is not null
