Select *
From PortfolioProject ..CovidDeaths
order by 3,4

Select *
From PortfolioProject ..CovidVac
order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases,new_cases, total_deaths, population
From PortfolioProject ..CovidDeaths
Order by 1,2

-- Looking at Total Cases vs Total Deaths aka death percentage
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as death_percentage
From PortfolioProject ..CovidDeaths
Order by 1,2

-- Looking at Total Cases vs Population
--Shows what percentage of population contracted Covid
Select Location, date, Population, total_cases, (total_cases/Population) *100 as contraction_rate
From PortfolioProject ..CovidDeaths
Where location like '%states%'
Order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population)) *100 as PercentPopulationInfected
From PortfolioProject ..CovidDeaths
Group by Location, Population
Order by PercentPopulationInfected desc


--Showing Countries with the Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as Total_Death_Count
From PortfolioProject ..CovidDeaths
Where continent is not null
Group by Location
Order by Total_Death_Count desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(Total_deaths as int)) as Total_Death_Count
From PortfolioProject ..CovidDeaths
Where continent is not null
Group by continent
Order by Total_Death_Count desc

--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM (new_cases)*100 as Death_Percent
From PortfolioProject ..CovidDeaths
where continent is not null
--Group by date
Order by 1,2

--Joining the Covid Deaths and Covid Vaccinations tables together on location and date. Since we didn't specify a join type, it defaults to an inner join

Select *
From PortfolioProject .. CovidDeaths dea --dea and vac are aliases so that we don't have to type out the entire table name
Join PortfolioProject .. CovidVac vac
	On dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccinations

--Since the columns can be found in both tables, we specify by putting the table alias in front of the column that we want to call.
--Partition by location has the count to start over when the location changes this is also grouped by location and date to present data as a rolling total.

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProject .. CovidDeaths dea 
Join PortfolioProject .. CovidVac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3

---USE CTE This allows us to incorporate the new column "Rolling_People_Vaccinated" into our aggregate function.

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)

as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProject .. CovidDeaths dea 
Join PortfolioProject .. CovidVac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3  The order by clause can't be used with CTE

)

Select *, (Rolling_People_Vaccinated/Population) *100  as Percent_Population_Vaccinated
From PopvsVac

--Using a Temp Table to extract the same data as CTE

Drop Table if exists #PercentofPopulationVaccinated
Create Table #PercentofPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric,
)
Insert into #PercentofPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProject .. CovidDeaths dea 
Join PortfolioProject .. CovidVac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3  The order by clause can't be used with CTE

Select *, (Rolling_People_Vaccinated/Population) *100  as Percent_Population_Vaccinated
From #PercentofPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentofPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProject .. CovidDeaths dea 
Join PortfolioProject .. CovidVac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null


Select *
From PercentofPopulationVaccinated

-------------------------------------------------
--Creating Queries for Tableau Dashboard

--Table 1

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM (new_cases)*100 as Death_Percent
From PortfolioProject ..CovidDeaths
where continent is not null
Order by 1,2

--Table 2 
 --Removed 'World' European Union and International to keep veracity of data--

 Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
 From PortfolioProject .. CovidDeaths
 Where continent is null
 and location not in ('World', 'European Union', 'International')
 Group by location
 order by TotalDeathCount desc

 --Table 3

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population)) *100 as PercentPopulationInfected
From PortfolioProject ..CovidDeaths
Group by Location, Population
Order by PercentPopulationInfected desc

--Table 4 

Select Location, Population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population)) *100 as PercentPopulationInfected
From PortfolioProject ..CovidDeaths
Group by Location, Population, date
Order by PercentPopulationInfected desc







