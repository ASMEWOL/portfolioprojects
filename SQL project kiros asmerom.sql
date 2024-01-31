select *
from [portfolio project on covid done by asmerom kiros].dbo.covid_death
where continent is not null
order by 3,4

--select *
--from [portfolio project on covid done by asmerom kiros]..covid_vaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from [portfolio project on covid done by asmerom kiros].dbo.covid_death
where continent is not null
order by 1,2

--looking at total_cases vs total_deaths
--shows the likelihood (probability) of dying if you are infected in each day-death_percentage_among_infected

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage_among_infected
from [portfolio project on covid done by asmerom kiros].dbo.covid_death
where location like '%ri%' and continent is not null
order by 1,2

--looking at total_cases vs population
--shows the likelihood(probability) of getting infected in each country in each day-percentage_of_people_infected

select location,date,population,total_cases,(total_cases/population)*100 as percentage_of_people_infected
from [portfolio project on covid done by asmerom kiros].dbo.covid_death
--where location like '%ri%' 
where continent is not null
order by 5 desc


--looking at continent/countries with highest infection rate 

select location,population, max(total_cases) as total_cases_max,(max(total_cases)/population)*100 as percentage_cases
from [portfolio project on covid done by asmerom kiros]..covid_death
where continent is not null
group by location,population
order by 4 desc

--showing countries with highest death count per population

select location,max(cast (total_deaths as int)) as total_death_count
from covid_death
where continent is not null
group by location
order by 2 desc

--showing continent with the highest death count per population

select continent,max(cast (total_deaths as int)) as total_death_count
from covid_death
where continent is not null
group by continent
order by 1 


select location,max(cast (total_deaths as int)) as total_death_count
from covid_death
where continent is  null
group by location
order by 1

--global numbers data

select date,sum(new_cases) as total_cases,sum(convert(int,new_deaths)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as percentage_death_daily
from [portfolio project on covid done by asmerom kiros].dbo.covid_death
--where location like '%ri%' 
where continent is not null
group by date
order by 2 desc 


select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as percentage_death_daily
from [portfolio project on covid done by asmerom kiros].dbo.covid_death
--where location like '%ri%' 
where continent is not null
--group by date
order by 2 desc 


---looking at covid vaccination table
--looking at total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from [portfolio project on covid done by asmerom kiros]..covid_death dea
join [portfolio project on covid done by asmerom kiros]..covid_vaccinations vac
on dea.location=vac.location and 
dea.date=vac.date
where dea.continent is not null 
order by 2,3


--use CTE

with popvsvac (continent,location,date,population,new_vaccinations,rolling_people_vaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from [portfolio project on covid done by asmerom kiros]..covid_death dea
join [portfolio project on covid done by asmerom kiros]..covid_vaccinations vac
on dea.location=vac.location and 
dea.date=vac.date
where dea.continent is not null 
----order by 2,3
)

select *,(rolling_people_vaccinated/population)*100
from popvsvac



with popvsvac (continent,location,population,new_vaccinations,rolling_people_vaccinated)
as
(
select dea.continent,dea.location,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location) as rolling_people_vaccinated
from [portfolio project on covid done by asmerom kiros]..covid_death dea
join [portfolio project on covid done by asmerom kiros]..covid_vaccinations vac
on dea.location=vac.location 
where dea.continent is not null 
----order by 2,3
)

select *,(rolling_people_vaccinated/population)*100
from popvsvac


----using temp table

drop table if exists #percent_population_vaccinated
create table #percent_population_vaccinated
(
continent nvarchar(255),location nvarchar(255),
date datetime,population numeric,new_vaccination numeric,rolling_people_vaccinated numeric
)
insert into #percent_population_vaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location) as rolling_people_vaccinated
from [portfolio project on covid done by asmerom kiros]..covid_death dea
join [portfolio project on covid done by asmerom kiros]..covid_vaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
----order by 2,3

select *,(rolling_people_vaccinated/population)*100
from #percent_population_vaccinated



----creating view based on these values

create view percent_population_vaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location) as rolling_people_vaccinated
from [portfolio project on covid done by asmerom kiros]..covid_death dea
join [portfolio project on covid done by asmerom kiros]..covid_vaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
----order by 2,3

select *
from percent_population_vaccinated
