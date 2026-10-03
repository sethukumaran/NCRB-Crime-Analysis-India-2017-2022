-- NCRB Crime Analysis 2017-2022
-- Dialect: PostgreSQL-compatible SQL
-- Load the CSV into table: ncrb_crime_raw
-- Grain: registration-circle record within a district/year.
-- Therefore district-level queries aggregate registration_circle rows first.

-- 1. Dataset coverage
SELECT
    MIN(year) AS first_year,
    MAX(year) AS last_year,
    COUNT(*) AS raw_rows,
    COUNT(DISTINCT state_name) AS states_uts,
    COUNT(DISTINCT district_name) AS districts
FROM ncrb_crime_raw;

-- 2. Data-quality check
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN state_name IS NULL THEN 1 ELSE 0 END) AS null_states,
    SUM(CASE WHEN district_name IS NULL THEN 1 ELSE 0 END) AS null_districts,
    SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS null_years
FROM ncrb_crime_raw;

-- 3. Total recorded cases by year
SELECT
    year,
    SUM(
        murder_homicide + rape_sexual_violence + attempted_rape +
        assault_modesty + kidnapping_abduction + kidnapping_ransom +
        human_trafficking + crimes_against_children + pocso_crimes +
        cruelty_domestic_violence + dowry_crimes + acid_attack +
        suicide_abetment + hurt_grievous_hurt + juvenile_crimes +
        cybercrime + cyber_fraud + identity_privacy_crimes +
        cyber_harassment_threats + online_sexual_obscene_crimes +
        cheating_fraud + theft_property_crimes + forgery_counterfeiting +
        immoral_traffic_prostitution + other_ipc_special_laws
    ) AS total_cases
FROM ncrb_crime_raw
GROUP BY year
ORDER BY year;

-- 4. Top crime categories (excluding the catch-all "other" category)
SELECT category, total_cases
FROM (
    SELECT 'crimes_against_children' AS category, SUM(crimes_against_children) AS total_cases FROM ncrb_crime_raw
    UNION ALL SELECT 'cruelty_domestic_violence', SUM(cruelty_domestic_violence) FROM ncrb_crime_raw
    UNION ALL SELECT 'kidnapping_abduction', SUM(kidnapping_abduction) FROM ncrb_crime_raw
    UNION ALL SELECT 'cheating_fraud', SUM(cheating_fraud) FROM ncrb_crime_raw
    UNION ALL SELECT 'rape_sexual_violence', SUM(rape_sexual_violence) FROM ncrb_crime_raw
    UNION ALL SELECT 'assault_modesty', SUM(assault_modesty) FROM ncrb_crime_raw
    UNION ALL SELECT 'cybercrime', SUM(cybercrime) FROM ncrb_crime_raw
    UNION ALL SELECT 'pocso_crimes', SUM(pocso_crimes) FROM ncrb_crime_raw
    UNION ALL SELECT 'juvenile_crimes', SUM(juvenile_crimes) FROM ncrb_crime_raw
    UNION ALL SELECT 'theft_property_crimes', SUM(theft_property_crimes) FROM ncrb_crime_raw
    UNION ALL SELECT 'murder_homicide', SUM(murder_homicide) FROM ncrb_crime_raw
    UNION ALL SELECT 'forgery_counterfeiting', SUM(forgery_counterfeiting) FROM ncrb_crime_raw
) x
ORDER BY total_cases DESC;

-- 5. Year-over-year trend for cybercrime
WITH yearly AS (
    SELECT year, SUM(cybercrime) AS cybercrime_cases
    FROM ncrb_crime_raw
    GROUP BY year
)
SELECT
    year,
    cybercrime_cases,
    LAG(cybercrime_cases) OVER (ORDER BY year) AS prior_year,
    ROUND(
        100.0 * (cybercrime_cases - LAG(cybercrime_cases) OVER (ORDER BY year))
        / NULLIF(LAG(cybercrime_cases) OVER (ORDER BY year), 0), 2
    ) AS yoy_growth_pct
FROM yearly
ORDER BY year;

-- 6. Cybercrime share of all recorded categories by year
WITH yearly AS (
    SELECT
        year,
        SUM(cybercrime) AS cybercrime_cases,
        SUM(
            murder_homicide + rape_sexual_violence + attempted_rape +
            assault_modesty + kidnapping_abduction + kidnapping_ransom +
            human_trafficking + crimes_against_children + pocso_crimes +
            cruelty_domestic_violence + dowry_crimes + acid_attack +
            suicide_abetment + hurt_grievous_hurt + juvenile_crimes +
            cybercrime + cyber_fraud + identity_privacy_crimes +
            cyber_harassment_threats + online_sexual_obscene_crimes +
            cheating_fraud + theft_property_crimes + forgery_counterfeiting +
            immoral_traffic_prostitution + other_ipc_special_laws
        ) AS total_cases
    FROM ncrb_crime_raw
    GROUP BY year
)
SELECT
    year,
    cybercrime_cases,
    total_cases,
    ROUND(100.0 * cybercrime_cases / NULLIF(total_cases, 0), 2) AS cybercrime_share_pct
FROM yearly
ORDER BY year;

-- 7. State ranking by total recorded cases
SELECT
    state_name,
    SUM(
        murder_homicide + rape_sexual_violence + attempted_rape +
        assault_modesty + kidnapping_abduction + kidnapping_ransom +
        human_trafficking + crimes_against_children + pocso_crimes +
        cruelty_domestic_violence + dowry_crimes + acid_attack +
        suicide_abetment + hurt_grievous_hurt + juvenile_crimes +
        cybercrime + cyber_fraud + identity_privacy_crimes +
        cyber_harassment_threats + online_sexual_obscene_crimes +
        cheating_fraud + theft_property_crimes + forgery_counterfeiting +
        immoral_traffic_prostitution + other_ipc_special_laws
    ) AS total_cases
FROM ncrb_crime_raw
GROUP BY state_name
ORDER BY total_cases DESC
LIMIT 10;

-- 8. State ranking by cybercrime
SELECT state_name, SUM(cybercrime) AS cybercrime_cases
FROM ncrb_crime_raw
GROUP BY state_name
ORDER BY cybercrime_cases DESC
LIMIT 10;

-- 9. District ranking: aggregate all registration circles to district/year first
WITH district_year AS (
    SELECT
        year,
        state_name,
        district_name,
        SUM(
            murder_homicide + rape_sexual_violence + attempted_rape +
            assault_modesty + kidnapping_abduction + kidnapping_ransom +
            human_trafficking + crimes_against_children + pocso_crimes +
            cruelty_domestic_violence + dowry_crimes + acid_attack +
            suicide_abetment + hurt_grievous_hurt + juvenile_crimes +
            cybercrime + cyber_fraud + identity_privacy_crimes +
            cyber_harassment_threats + online_sexual_obscene_crimes +
            cheating_fraud + theft_property_crimes + forgery_counterfeiting +
            immoral_traffic_prostitution + other_ipc_special_laws
        ) AS total_cases
    FROM ncrb_crime_raw
    GROUP BY year, state_name, district_name
)
SELECT
    state_name,
    district_name,
    SUM(total_cases) AS cases_2017_2022
FROM district_year
GROUP BY state_name, district_name
ORDER BY cases_2017_2022 DESC
LIMIT 10;

-- 10. 2017 vs 2022 category change
WITH yearly AS (
    SELECT
        SUM(murder_homicide) AS murder_homicide_2017,
        SUM(rape_sexual_violence) AS rape_2017,
        SUM(cybercrime) AS cyber_2017,
        SUM(cheating_fraud) AS cheating_2017
    FROM ncrb_crime_raw
    WHERE year = 2017
),
latest AS (
    SELECT
        SUM(murder_homicide) AS murder_homicide_2022,
        SUM(rape_sexual_violence) AS rape_2022,
        SUM(cybercrime) AS cyber_2022,
        SUM(cheating_fraud) AS cheating_2022
    FROM ncrb_crime_raw
    WHERE year = 2022
)
SELECT
    ROUND(100.0 * (murder_homicide_2022 - murder_homicide_2017) / NULLIF(murder_homicide_2017,0),2) AS murder_growth_pct,
    ROUND(100.0 * (rape_2022 - rape_2017) / NULLIF(rape_2017,0),2) AS rape_growth_pct,
    ROUND(100.0 * (cyber_2022 - cyber_2017) / NULLIF(cyber_2017,0),2) AS cyber_growth_pct,
    ROUND(100.0 * (cheating_2022 - cheating_2017) / NULLIF(cheating_2017,0),2) AS cheating_growth_pct
FROM yearly CROSS JOIN latest;

-- 11. Concentration: top 5 states' share of cybercrime
WITH state_cyber AS (
    SELECT state_name, SUM(cybercrime) AS cyber_cases
    FROM ncrb_crime_raw
    GROUP BY state_name
),
ranked AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY cyber_cases DESC) AS rn
    FROM state_cyber
)
SELECT
    ROUND(100.0 * SUM(CASE WHEN rn <= 5 THEN cyber_cases ELSE 0 END) / SUM(cyber_cases), 2)
    AS top_5_state_cyber_share_pct
FROM ranked;
