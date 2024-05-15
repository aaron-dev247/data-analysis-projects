-- Preview data
SELECT TOP 1000 * FROM covid_deaths ORDER BY location, date;
SELECT TOP 1000 * FROM covid_vaccination ORDER BY location, date;

-- total deadths vs total cases ratio
SELECT location, date, total_cases, total_deaths, total_deaths / total_cases * 100 AS dead_rate
FROM covid_deaths
ORDER BY location, date DESC;

-- total cases vs population ratio
SELECT location, date, population, total_cases, total_cases / population * 100 AS infection_rate
FROM covid_deaths
ORDER BY location, date DESC;

-- Infection rate per country
SELECT location, population, max(total_cases) AS highest_infection_count, max(total_cases / population) * 100 AS highest_infection_rate
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY highest_infection_rate DESC;

-- Death count per country
SELECT location, max(total_deaths) AS death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY death_count DESC;

-- Heghest death count rank by continent
SELECT continent, sum(death_count) AS death_count
FROM (
	select continent, location, max(total_deaths) AS death_count
	from covid_deaths
	where continent IS NOT NULL
	group BY continent, location
) sub
GROUP BY continent
ORDER BY death_count DESC;

-- Global death rate
SELECT sum(new_cases) AS total_cases, sum(new_deaths) AS total_deaths, sum(new_deaths)/sum(new_cases) * 100 AS death_rate
FROM covid_deaths;

-- Population vs Vaccination
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
FROM covid_deaths dea 
JOIN covid_vaccination vac
ON dea.date = vac.date
AND dea.location = vac.location
WHERE new_vaccinations IS NOT NULL;

-- Vaccination rate
WITH pop_vs_vac (location, date, population, new_vaccinations, total_vaccinations)
AS (
	select dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(vac.new_vaccinations) over (partition BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
	from covid_deaths dea 
	join covid_vaccination vac
	on dea.date = vac.date
	and dea.location = vac.location
	where new_vaccinations IS NOT NULL
)
SELECT location, date, population, new_vaccinations, total_vaccinations, total_vaccinations / population * 100 AS vaccination_rate
FROM pop_vs_vac;

-- Population vs Vaccination view
CREATE VIEW pop_vs_vac
AS (
	select dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(vac.new_vaccinations) over (partition BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
	from covid_deaths dea 
	join covid_vaccination vac
	on dea.date = vac.date
	and dea.location = vac.location
	where new_vaccinations IS NOT NULL
);
