select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select data that we are going to be using


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Verificar Casos Totais Vs Mortes Totais
--Probabilidade de morrer de covid depois de apanhar a doença
--
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%portugal%' and continent is not null
order by 1,2


--Casos Totais Vs População
---Taxa de infeção da população
--
select location, date, population, total_cases,  (total_cases/population)*100 as PercentageOfPoputalion
from PortfolioProject..CovidDeaths
Where location like '%portugal%' and continent is not null
order by 1,2


-----Taxa de infeção por pais em função da população
----
Select location, population, MAX(total_cases) as TaxaInfecaoMax, CONVERT(DECIMAL(5, 2), MAX ((total_cases/population)*100)) as PercentagemPopulacaoInfetada
from PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by PercentagemPopulacaoInfetada desc




--Paises com o maior nº de mortes/populacao 
--
--
Select location, MAX(cast (total_deaths as int)) as TotalMortes
from PortfolioProject..CovidDeaths
where continent is not null 
Group by location
order by TotalMortes desc


----
--- Ver por continente com base no campo localização
--
Select location, MAX(cast (total_deaths as int)) as TotalMortes
from PortfolioProject..CovidDeaths
where continent is null
Group by location
order by TotalMortes desc


----
-- mostrar os continentes com a taxa de mortalidade maior
--- Ver por continente com base no campo continent
--
Select continent, MAX(cast (total_deaths as int)) as TotalMortes
from PortfolioProject..CovidDeaths
--where locationlike ''%portugal%
where continent is not null
Group by continent
order by TotalMortes desc



-- Numeros Globais
---

--total

select  SUM(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths,  CONVERT(DECIMAL(5, 2), SUM(CAST(new_deaths as int))/SUM(new_cases)*100) as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%portugal%' 
where continent is not null
--group by date
order by 1,2


--
--Por dia
select date, SUM(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths,  CONVERT(DECIMAL(5, 2), SUM(CAST(new_deaths as int))/SUM(new_cases)*100) as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%portugal%' 
where continent is not null
group by date
order by 1,2




-----Vacinação-------

--- Total de populçaõ no mundo vs vacinação

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, CONVERT(DECIMAL(5, 2),(RollingPeopleVaccinated/population)*100)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


---Usar CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, CONVERT(DECIMAL(5, 2),(RollingPeopleVaccinated/population)*100)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, CONVERT(DECIMAL(5, 2),(RollingPeopleVaccinated/population)*100) as PopulacaoVacinada
from PopvsVac


---Tabela Temporária

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, CONVERT(DECIMAL(5, 2),(RollingPeopleVaccinated/population)*100)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *, CONVERT(DECIMAL(5, 2),(RollingPeopleVaccinated/population)*100) as PopulacaoVacinada
from #PercentPopulationVaccinated



---Criar View para guarda dados para visualizar mais tarde

Create View DeathPercentage as
select date, SUM(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths,  CONVERT(DECIMAL(5, 2), SUM(CAST(new_deaths as int))/SUM(new_cases)*100) as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%portugal%' 
where continent is not null
group by date
--order by 1,2


Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, CONVERT(DECIMAL(5, 2),(RollingPeopleVaccinated/population)*100)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

------
select *
from PercentPopulationVaccinated