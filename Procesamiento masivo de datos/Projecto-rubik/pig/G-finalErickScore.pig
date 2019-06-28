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
results_333 = FILTER raw_results BY eventId == '333' AND average > 0;

results_cut = FOREACH results_333 GENERATE personId, average;

--Generar tabla personID

persons_cut = FOREACH raw_persons GENERATE id, name as personName, countryId, gender; 

--join con WCA_export_Persons.tsv con personID = id
results_person = JOIN results_cut BY personId, persons_cut BY id;

--*** filter by gender

--groupBy countryId
results_by_country = GROUP results_person BY countryId;

--Generar tabla countryId, avg(average)
average_per_country = FOREACH results_by_country GENERATE group AS countryId, AVG(results_person.average) AS time_country;

--Join con WCA_export_Countries.tsv con id = countryId
results_country = JOIN average_per_country BY countryId, raw_countries BY id;

--Generar tabla name(country), avg
final_results = FOREACH results_country GENERATE name, time_country; 

--orderby average
results_ordered = ORDER final_results BY time_country ASC;

STORE results_ordered INTO '/uhadoop2019/elsueco/results_project14/';
