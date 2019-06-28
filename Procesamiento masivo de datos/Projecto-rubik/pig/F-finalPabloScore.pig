-- Pablo Aliaga
-- Eric Jonsson
-- Erick Lemus

-- This script finds the actors/actresses with the highest number of good movies

raw_results = LOAD 'hdfs://cm:9000/uhadoop2019/elsueco/WCA_export_Results.tsv' USING PigStorage('\t') AS (competitionId, eventId, roundTypeId, pos, best, average, personName, personId, personCountryId, formatId, value1, value2, value3, value4, value5, regionalSingleRecord, regionalAverageRecord);
-- Later you can change the above file to 'hdfs://cm:9000/uhadoop/shared/imdb/imdb-stars.tsv' to see the full output


raw_persons = LOAD 'hdfs://cm:9000/uhadoop2019/elsueco/WCA_export_Persons.tsv' USING PigStorage('\t') AS (id, subid, name, countryId, gender);
-- Later you can change the above file to 'hdfs://cm:9000/uhadoop/shared/imdb/imdb-ratings.tsv' to see the full output

raw_countries = LOAD 'hdfs://cm:9000/uhadoop2019/elsueco/WCA_export_Countries.tsv' USING PigStorage('\t') AS (id, name, continentId, iso2);
-- Later you can change the above file to 'hdfs://cm:9000/uhadoop/shared/imdb/imdb-ratings.tsv' to see the full output

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

-- Now to implement the script

--De WCA_export_Results.tsv

--filter eventId = 333
results_333 = FILTER raw_results BY eventId == '333';

results_cut = FOREACH results_333 GENERATE personId, average;

--groupBy personID
results_by_person = GROUP results_cut BY personId;

--Select min(average) para cada persona
results_grouped = FOREACH results_by_person GENERATE group AS person, MIN(results_cut.average) AS time;

filtered_grouped = FILTER results_grouped BY time > 0;

group_results = GROUP filtered_grouped all;

total_people = FOREACH group_results GENERATE COUNT(filtered_grouped) as totalPeople;

total_average = FOREACH group_results GENERATE AVG(filtered_grouped.time) as totalAverage;



--Generar tabla personID, min(average)

persons_cut = FOREACH raw_persons GENERATE id, name as personName, countryId, gender; 

--join con WCA_export_Persons.tsv con personID = id
results_person = JOIN filtered_grouped BY person, persons_cut BY id;

--*** filter by gender

--groupBy countryId
results_by_country = GROUP results_person BY countryId;

--Generar tabla countryId, avg(average)
average_per_country = FOREACH results_by_country GENERATE group AS countryId, AVG(results_person.time) AS time_country, COUNT(results_person) AS nPerson;

average_per_country_2 = FILTER average_per_country BY nPerson > 0 AND nPerson IS NOT NULL;

--Join con WCA_export_Countries.tsv con id = countryId
results_country = JOIN average_per_country_2 BY countryId, raw_countries BY id;

--Generar tabla name(country), avg
prefinal_results = CROSS results_country, total_people;
prefinal_results2 = CROSS prefinal_results, total_average;

final_results = FOREACH prefinal_results2 GENERATE name, time_country, nPerson , (time_country + totalAverage*LOG(totalPeople/nPerson)*LOG(time_country/totalAverage + 1))/2 as pablo_score;

filtered_results = FILTER final_results BY time_country > 0;


--orderby average
results_ordered = ORDER filtered_results BY pablo_score ASC;

STORE results_ordered INTO '/uhadoop2019/elsueco/results_project13/';
