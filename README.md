# traffic-fatalities

2015 state fatality rates from NHTSA and ACS.

**Datasets**
- Fatalities: `bigquery-public-data.nhtsa_traffic_fatalities.accident_2015`
- Population: `bigquery-public-data.census_bureau_acs.state_2015_1yr`
- Boundaries: `bigquery-public-data.geo_us_boundaries.states`

**Purpose**
Calculate state-level traffic fatality rates normalized per 100,000 residents for 2015.

**Queries**
- `sql/fatalities_by_state.sql`
- `sql/population_join.sql`
- `sql/fatalities_per_100k.sql`

*Data is shared under the Creative Commons Attribution 4.0 International License (CC BY 4.0). Code is under the MIT License.*
