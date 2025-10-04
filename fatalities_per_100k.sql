-- View column names
SELECT *
FROM `bigquery-public-data.census_bureau_acs.state_2015_1yr`
LIMIT 1000;

-- Ask: What do I have, what do I need?

-- Need to find a key that matches each geo_id to their repsective state name
SELECT table_name 
  FROM `bigquery-public-data.census_bureau_acs`.INFORMATION_SCHEMA.TABLES 
  WHERE table_name LIKE 'state%2015%';

-- List all columns for state_2015_1yr
SELECT column_name 
  FROM `bigquery-public-data.census_bureau_acs`.INFORMATION_SCHEMA.COLUMNS 
  WHERE table_name = 'state_2015_1yr';

-- Find population-related columns in state_2015_1yr
SELECT column_name 
  FROM `bigquery-public-data.census_bureau_acs`.INFORMATION_SCHEMA.COLUMNS 
  WHERE table_name = 'state_2015_1yr' 
  AND LOWER(column_name) LIKE '%pop%';

-- Check columns in table geo_us_boundaries for any state-related info
SELECT column_name 
FROM `bigquery-public-data.geo_us_boundaries`.INFORMATION_SCHEMA.COLUMNS 
WHERE table_name = 'states';

-- Join (state_2015_1yr) & (geo_us_boundaries.states) on geo_id
SELECT 
  s.state_name,     -- s = alias for state boundaries table(geo_us_boundaries.states)
                    -- s.state_name = state as a word (i.e. California)
  p.total_pop       -- p = alias for population table (state_2015_1yr)
                    -- p.total_pop = 2015 population estimate
FROM `bigquery-public-data.census_bureau_acs.state_2015_1yr` p
JOIN `bigquery-public-data.geo_us_boundaries.states` s
  ON p.geo_id = s.geo_id
ORDER BY s.state_name;

-- join population + fatalities by state for a table of each state, its 2015 population, and the number of fatalities
WITH pop AS (
  SELECT 
    s.state_name,
    p.total_pop
  FROM `bigquery-public-data.census_bureau_acs.state_2015_1yr` p
  JOIN `bigquery-public-data.geo_us_boundaries.states` s
    ON p.geo_id = s.geo_id
),
fatals AS (
  SELECT 
    state_name,
    SUM(number_of_fatalities) AS total_fatalities
  FROM `bigquery-public-data.nhtsa_traffic_fatalities.accident_2015`
  GROUP BY state_name
)
SELECT 
  f.state_name,
  p.total_pop,
  f.total_fatalities
FROM fatals f
JOIN pop p
  ON f.state_name = p.state_name
ORDER BY f.total_fatalities DESC;

-- Calculate fatalities as percent of state population
WITH pop AS (
  SELECT 
    s.state_name,
    p.total_pop
  FROM `bigquery-public-data.census_bureau_acs.state_2015_1yr` p
  JOIN `bigquery-public-data.geo_us_boundaries.states` s
    ON p.geo_id = s.geo_id
),
fatals AS (
  SELECT 
    state_name,
    SUM(number_of_fatalities) AS total_fatalities
  FROM `bigquery-public-data.nhtsa_traffic_fatalities.accident_2015`
  GROUP BY state_name
)
SELECT 
  f.state_name,
  p.total_pop,
  f.total_fatalities,
  SAFE_DIVIDE(f.total_fatalities, p.total_pop) * 100 AS fatality_percent
FROM fatals f
JOIN pop p
  ON f.state_name = p.state_name
ORDER BY fatality_percent DESC;


-- Calculate fatalities per 100,000 residents instead of raw percent
WITH pop AS (
  SELECT 
    s.state_name,
    p.total_pop
  FROM `bigquery-public-data.census_bureau_acs.state_2015_1yr` p
  JOIN `bigquery-public-data.geo_us_boundaries.states` s
    ON p.geo_id = s.geo_id
),
fatals AS (
  SELECT 
    state_name,
    SUM(number_of_fatalities) AS total_fatalities
  FROM `bigquery-public-data.nhtsa_traffic_fatalities.accident_2015`
  GROUP BY state_name
)
SELECT 
  f.state_name AS state_name,
  p.total_pop AS total_pop,
  f.total_fatalities AS total_fatalities,
  ROUND(SAFE_DIVIDE(f.total_fatalities, p.total_pop) * 100000, 0) AS fatalities_per_100k
FROM fatals f
JOIN pop p
  ON f.state_name = p.state_name
ORDER BY fatalities_per_100k DESC;
