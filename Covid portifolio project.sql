CREATE TABLE vaccinations
(iso_code varchar(50),
 continent varchar(50),
 country varchar(50),
 date date,	
 new_tests int,
 total_tests int,
 total_tests_per_thousand double precision,
 new_tests_per_thousand double precision,
 new_tests_smoothed double precision,
 new_tests_smoothed_per_thousand double precision,
 positive_rate	double precision,
 tests_per_case double precision,
 tests_units varchar(100),
 total_vaccinations double precision,	
 people_vaccinated double precision,
 people_fully_vaccinated double precision,	
 new_vaccinations double precision,
 new_vaccinations_smoothed double precision,
 total_vaccinations_per_hundred	double precision,
 people_vaccinated_per_hundred	double precision,
 people_fully_vaccinated_per_hundred double precision,
 new_vaccinations_smoothed_per_million double precision,
 stringency_index double precision ,
 population_density double precision,
 median_age double precision,	
 aged_65_older double precision,
 aged_70_older double precision,
 gdp_per_capita double precision,
 extreme_poverty double precision,
 cardiovasc_death_rate double precision,
 diabetes_prevalence double precision,
 female_smokers	double precision,
 male_smokers double precision,
 handwashing_facilities double precision,
 hospital_beds_per_thousand double precision,
 life_expectancy double precision,
 human_development_index double precision
);

CREATE TABLE deaths
(iso_code varchar(50),
continent varchar(100),
 country varchar(100),
 date date,
 total_cases double precision,
 new_cases double precision,
 new_cases_smoothed double precision,
 total_deaths double precision,
 new_deaths double precision,
 new_deaths_smoothed double precision,
 total_cases_per_million double precision,
 new_cases_per_million double precision,
 new_cases_smoothed_per_million double precision,
 total_deaths_per_million double precision,
 new_deaths_per_million double precision,
 new_deaths_smoothed_per_million double precision,
 reproduction_rate double precision,
 icu_patients double precision,
 icu_patients_per_million double precision,
 hosp_patients	double precision,
 hosp_patients_per_million double precision,
 weekly_icu_admissions double precision,
 weekly_icu_admissions_per_million double precision,
 weekly_hosp_admissions	double precision,
 weekly_hosp_admissions_per_million double precision,
 new_tests double precision,
 total_tests double precision,
 total_tests_per_thousand double precision,
 new_tests_per_thousand double precision,
 new_tests_smoothed double precision,
 new_tests_smoothed_per_thousand double precision,
 positive_rate double precision,
 tests_per_case	double precision,
 tests_units varchar(100),	
 total_vaccinations double precision,
 people_vaccinated double precision,
 people_fully_vaccinated double precision,
 new_vaccinations double precision,
 new_vaccinations_smoothed double precision,
 total_vaccinations_per_hundred	double precision,
 people_vaccinated_per_hundred double precision,	
 people_fully_vaccinated_per_hundred double precision,
 new_vaccinations_smoothed_per_million double precision,
 stringency_index double precision,
 population double precision,
 population_density double precision,
 median_age double precision,
  aged_65_older double precision,
 aged_70_older double precision,
 gdp_per_capita double precision,
 extreme_poverty double precision,
 cardiovasc_death_rate double precision,
 diabetes_prevalence double precision,
 female_smokers double precision,
 male_smokers double precision,
 handwashing_facilities double precision,
 hospital_beds_per_thousand double precision,
 life_expectancy double precision,
 human_development_index double precision
 );


SELECT* 
FROM public.deaths
ORDER BY 3,4;

SELECT* 
FROM public.deaths
ORDER BY 3,4;

SELECT country,date,total_cases,new_cases,total_deaths,population
FROM public.deaths
ORDER BY 1,2

--TOTAL CASES VS TOTAL DEATHS
--Shows likelihood od dying if you contract covid
SELECT country,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS deathpercentage
FROM public.deaths
WHERE country='Africa'
ORDER BY 1,2;

--TOTAL CASES VS THE POPULATION
--shows the percentage that got COVID
SELECT country,date,total_cases,Population,(total_deaths/Population)*100 
AS infectedpercentage
FROM public.deaths
--WHERE country='Africa'
ORDER BY 1,2;

SELECT country,date,total_cases,new_cases,total_deaths,population
FROM public.deaths
ORDER BY 1,2

--TOTAL CASES VS TOTAL DEATHS
--Shows likelihood od dying if you contract covid
SELECT country,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS deathpercentage
FROM public.deaths
WHERE country='Africa'
ORDER BY 1,2;

--TOTAL CASES VS THE POPULATION
--shows the percentage that got COVID
SELECT country,date,total_cases,Population,(total_deaths/Population)*100 
AS infectedpercentage
FROM public.deaths
--WHERE country='Africa'
ORDER BY 1,2;

--Countries  with highest infection rate compared to population
SELECT country,population,MAX(total_cases)AS highestinfectioncount,
MAX((total_cases/population))*100 AS infectedpercentage
FROM public.deaths
GROUP BY country,population
ORDER BY infectedpercentage DESC;
--showing countries with highest death count
SELECT country,MAX(total_deaths)AS totaldeathcount
FROM public.deaths
WHERE continent IS NOT NULL
GROUP BY country
ORDER BY country;
--by continent
SELECT continent,MAX(total_deaths)AS totaldeathcount
FROM public.deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeathcount desc;


--GLOBAL NUMBERS
SELECT date,SUM(new_cases)as total_cases,SUM(new_deaths) as total_deaths,
(SUM(new_deaths)/SUM(new_cases))*100 as deathpercent
FROM public.deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--joining 2 tables
SELECT *
FROM public.deaths JOIN public.vaccinations
ON deaths.country=vaccinations.country
AND deaths.date=vaccinations.date

--looking at total population vs vaccination
SELECT deaths.continent,deaths.country,deaths.date,deaths.population,vaccinations.new_vaccinations
FROM public.deaths JOIN public.vaccinations
ON deaths.country=vaccinations.country
AND deaths.date=vaccinations.date
WHERE deaths.continent is not null
order by 1,2,3

--partition
SELECT deaths.continent,deaths.country,deaths.date,deaths.population,
vaccinations.new_vaccinations,
SUM(vaccinations.new_vaccinations)OVER (PARTITION BY deaths.country 
										ORDER BY deaths.country,deaths.date)AS accpeoplevaccinated
FROM public.deaths JOIN public.vaccinations
ON deaths.country=vaccinations.country
AND deaths.date=vaccinations.date
WHERE deaths.continent is not null
order by 2,3

--USING CTE
WITH popvsvac(continent,country,date,population,new_vaccinations,accpeoplevaccinated)
as
(SELECT deaths.continent,deaths.country,deaths.date,deaths.population,
vaccinations.new_vaccinations,
SUM(vaccinations.new_vaccinations)OVER (PARTITION BY deaths.country 
										ORDER BY deaths.country,deaths.date)AS accpeoplevaccinated
FROM public.deaths JOIN public.vaccinations
ON deaths.country=vaccinations.country
AND deaths.date=vaccinations.date
WHERE deaths.continent is not null
 )
 SELECT *,(accpeoplevaccinated/population)*100
 FROM popvsvac
 
 --create TEMP TABLE
 DROP TABLE IF EXISTS temptab;
 CREATE TEMP TABLE temptab(
 continent varchar(100),
country varchar(100),
date date,
population numeric,
new_vaccinations numeric,
 accpeoplevaccinated numeric);

INSERT INTO temptab(
SELECT deaths.continent,deaths.country,deaths.date,deaths.population,
vaccinations.new_vaccinations,
SUM(vaccinations.new_vaccinations)OVER (PARTITION BY deaths.country 
										ORDER BY deaths.country,deaths.date)AS accpeoplevaccinated
FROM public.deaths JOIN public.vaccinations
ON deaths.country=vaccinations.country
AND deaths.date=vaccinations.date
WHERE deaths.continent is not null
 );
SELECT *,(accpeoplevaccinated/population)*100
FROM temptab;

--creating view to store data for later
CREATE VIEW maxdeathsvscountry as
SELECT country,MAX(total_deaths)AS totaldeathcount
FROM public.deaths
WHERE continent IS NOT NULL
GROUP BY country
ORDER BY country;