-- Data Exploration : 

select * from Covid_Deaths where continent is not null order by 3,4 ; 

select count(*) from Covid_Deaths where continent is not null ; 


-- Selecting Data to be used 

select location , date , total_cases , new_cases , total_deaths , population 
from Covid_Deaths where continent is not null order by 1,2 ; 

-- Total cases vs Total deaths

select location , date , total_cases , total_deaths , (total_deaths/total_cases)*100 as 'death %' 
from Covid_Deaths where continent is not null order by 1,2 ; 

select location , date , total_cases , total_deaths , (total_deaths/total_cases)*100 as 'death %' 
from Covid_Deaths where location like 'india' and continent is not null order by 1,2 ;

-- Total cases vs Population 

select location , date , total_cases , population , round((total_cases/population)*100,2) as 'infected %' 
from Covid_Deaths where continent is not null order by 1,2 ; 

select location , date , total_cases , population , round((total_cases/population)*100,2) as 'infected %' 
from Covid_Deaths where location = 'india' and continent is not null order by 1,2 ; 

-- countries with higest infection rates 

select location , population , max(total_cases) as highest_cases , max((total_cases/population))*100 as 'infected %' 
from Covid_Deaths where continent is not null
group by location
order by 4 desc ; 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
from Covid_Deaths
Group by Location,date
order by PercentPopulationInfected desc 

-- countries with highest death rates 

select location , population , max(total_deaths) as highest_death_count , max((total_deaths/population))*100 as 'death %' 
from Covid_Deaths where continent is not null
group by location
order by 4 desc ; 

select location , max(total_deaths) as highest_death_count 
from Covid_Deaths where continent is not null
group by location 
order by 2 desc ; 

-- Breakup by continent 

select continent , max(total_deaths) as highest_death_count 
from Covid_Deaths where continent is not null
group by continent  
order by 2 desc ; 

select location , max(total_deaths) as highest_death_count 
from Covid_Deaths where continent is null
group by location  
order by 2 desc ; 

-- Global Numbers 

select date , sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths 
from Covid_Deaths where continent is null  
group by date
order by 2,3 ; 

select sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths , 
sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Covid_Deaths where continent is null  
order by 1,2 ; 

-- Vaccination Data 

select * from Covid_Vaccinations where continent is not null order by 3,4 ;

select count(*) from Covid_Vaccinations where continent is not null ; 

-- Total population vs vaccination

select cd.continent , cd.location , cd.date , cd.population , cv.new_vaccinations ,
SUM(cv.new_vaccinations) OVER (Partition by cv.location Order by cd.location, cd.date) as Runningtotal_PeopleVaccinated ,
from Covid_Deaths cd join Covid_Vaccinations cv 
on cd.location = cv.location and cd.date = cv.date 
where cd.continent is not null 
order by 2,3 ;

-- Used CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Runningtotal_PeopleVaccinated)
as(
    select cd.continent , cd.location , cd.date , cd.population , cv.new_vaccinations ,
    SUM(cv.new_vaccinations) OVER (Partition by cv.location Order by cd.location, cd.date) as Runningtotal_PeopleVaccinated 
    from Covid_Deaths cd join Covid_Vaccinations cv 
    on cd.location = cv.location and cd.date = cv.date 
    where cd.continent is not null ) 

select *, (Runningtotal_PeopleVaccinated/Population)*100 as 'vaccinated_pop %'
From PopvsVac  

-- alternate approach : creating a view

Create View PercentPopulationVaccinated as 
select cd.continent , cd.location , cd.date , cd.population , cv.new_vaccinations ,
    SUM(cv.new_vaccinations) OVER (Partition by cv.location Order by cd.location, cd.date) as Runningtotal_PeopleVaccinated 
    from Covid_Deaths cd join Covid_Vaccinations cv 
    on cd.location = cv.location and cd.date = cv.date 
    where cd.continent is not null  
