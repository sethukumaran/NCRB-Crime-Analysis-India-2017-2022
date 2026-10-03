# NCRB-Crime-Analysis-India-2017-2022

This project analyzes district-level crime records covering **2017–2022** across **36 States/UTs and 788 districts**, with 25 crime categories. The objective is to identify meaningful changes in crime patterns, concentration hotspots, category-level growth, and emerging cybercrime exposure.

The analysis is designed from a senior data analyst perspective, combining:

- Exploratory Data Analysis (EDA)
- Data-quality validation
- Time-series trend analysis
- State and district benchmarking
- Crime-category contribution analysis
- Cybercrime concentration analysis
- SQL business questions
- Python-based visualization



## Dataset

**File:** `NCRB_Crime_Analysis_2017_2022_with_25Crime_categories_Districtwise.csv`

### Coverage

| Metric | Value |
|---|---:|
| Years | 2017–2022 |
| Raw records | 5,920 |
| States/UTs | 36 |
| Districts | 788 |
| Crime categories | 25 |
| Missing values | 0 |
| Exact duplicate rows | 0 |

### Major crime fields

- Murder / homicide
- Rape / sexual violence
- Attempted rape
- Assault on modesty
- Kidnapping / abduction
- Kidnapping for ransom
- Human trafficking
- Crimes against children
- POCSO crimes
- Cruelty / domestic violence
- Dowry crimes
- Acid attack
- Suicide abetment
- Hurt / grievous hurt
- Juvenile crimes
- Cybercrime
- Cyber fraud
- Identity / privacy crimes
- Cyber harassment / threats
- Online sexual / obscene crimes
- Cheating / fraud
- Theft / property crimes
- Forgery / counterfeiting
- Immoral traffic / prostitution
- Other IPC / special laws


# Executive Summary

### 1. Overall recorded crime volume increased over the study period

Across the 25 supplied categories, the dataset records approximately **1.12 million cases in 2017** and **1.49 million in 2022**, representing about **32.7% growth** between the endpoints.

However, the annual series is not monotonic: total recorded volume peaked around **2020** at approximately **2.01 million**, then declined in 2021 and 2022.

This means the correct business interpretation is not simply "crime increased every year." The dataset shows substantial year-to-year variation and a pronounced 2020 peak.

### 2. Cybercrime is the clearest structural growth area

Cybercrime increased from **29,775 cases in 2017** to **99,633 in 2022**, an increase of approximately **234.6%**.

Cybercrime's share of all recorded categories also increased:

- 2017: approximately **2.65%**
- 2022: approximately **6.69%**

Cyber fraud alone increased by approximately **421.8%** between 2017 and 2022.

**Analyst interpretation:** digital crime represents a rapidly expanding component of the observed crime mix and is an important area for capability planning, specialist resources, awareness programs and fraud-response capacity.

### 3. Crimes against children are a major volume category

`crimes_against_children` is the largest named category in the dataset after excluding the catch-all `other_ipc_special_laws`, with approximately **859,032 recorded cases** over 2017–2022.

POCSO crimes also show substantial growth from 2017 to 2022.

This suggests that child-safety indicators should be monitored separately rather than hidden inside an overall crime-volume KPI.

### 4. Domestic violence and interpersonal crimes remain major contributors

`cruelty_domestic_violence`, `kidnapping_abduction`, `cheating_fraud`, `rape_sexual_violence`, and `assault_modesty` are among the largest named categories.

These categories together represent a substantial portion of the dataset and indicate that a balanced crime dashboard should not focus only on violent crime or cybercrime.

### 5. Crime volume is geographically concentrated

By raw recorded volume across the full period, the largest state/UT totals in this dataset include:

- Tamil Nadu
- Uttar Pradesh
- Maharashtra
- Rajasthan
- Madhya Pradesh
- West Bengal
- Telangana

These are **volume rankings**, not crime-rate rankings. Larger populations, reporting levels, administrative structures and the number of registration circles can affect raw counts.

### 6. Cybercrime is particularly concentrated

The top five states in cybercrime volume account for approximately **69.2% of all cybercrime cases** in this dataset.

The highest cumulative cybercrime volumes are observed in:

- Telangana
- Uttar Pradesh
- Maharashtra
- Karnataka
- Assam

This concentration can support targeted capacity planning, but raw case volume should not be interpreted as risk per capita without population denominators.


# Key Business / Analytical Insights

## Insight 1 — The crime mix is changing

The dataset indicates a shift toward a larger role for technology-enabled crime.

Cybercrime grew much faster than many traditional categories. Cyber fraud and online sexual/obscene crimes show particularly high endpoint growth.

### Business implication

A public-safety analytics program could track:

- cybercrime volume
- cyber fraud volume
- digital investigation workload
- district-level cyber concentration
- year-over-year change
- cybercrime share of total recorded crime


## Insight 2 — 2020 is an important anomaly / structural break to investigate

Total recorded crime reaches its highest annual value in the supplied dataset in 2020.

At the same time, several categories behave differently from the surrounding years.

### Business implication

2020 should be treated as an investigation point rather than simply included in a trend line without context.

Possible follow-up questions:

- Did reporting practices change?
- Did category definitions change?
- Did registration/reporting mechanisms change?
- Did the composition of cases change?
- Did administrative aggregation differ?
- Were specific states responsible for the spike?

The dataset alone cannot establish the cause.


## Insight 3 — Cybercrime concentration creates an opportunity for targeted capability planning

The top five states account for about 69.2% of cybercrime volume.

### Business implication

A resource-planning dashboard could prioritize:

- cyber investigation teams
- fraud-response capabilities
- digital forensics capacity
- investigator training
- citizen awareness programs
- incident-response workflows

The analysis should be supplemented with population, internet usage, reporting and enforcement-capacity data before making resource-allocation decisions.


## Insight 4 — Raw state rankings should not be treated as risk rankings

Tamil Nadu has the largest raw total in this dataset, but a raw count is not a crime rate.

A senior analyst should explicitly distinguish:

**Volume KPI**

> Number of recorded cases

from

**Rate KPI**

> Recorded cases per population / per 100,000 population

### Recommended enhancement

Join this dataset with:

- State population by year
- District population by year
- Internet users / broadband penetration
- Urbanization
- Police personnel strength
- Reporting / FIR registration indicators

Then calculate standardized rates.


## Insight 5 — District-level hotspot analysis should use aggregated district-year data

The presence of multiple registration circles means a raw row-level district ranking can be misleading.

The project therefore aggregates:

`registration circle → district/year → state/year`

before producing district-level rankings.

This is an important data-modeling decision for reproducible analytics.


# Important Findings Table

| Metric | Result |
|---|---:|
| Raw records | 5,920 |
| Years | 2017–2022 |
| States/UTs | 36 |
| Districts | 788 |
| 2017 total across 25 categories | 1,121,770 |
| 2020 total across 25 categories | 2,012,163 |
| 2022 total across 25 categories | 1,489,009 |
| 2017→2022 total growth | 32.7% |
| Cybercrime 2017 | 29,775 |
| Cybercrime 2022 | 99,633 |
| Cybercrime growth | 234.6% |
| Cybercrime share 2017 | 2.65% |
| Cybercrime share 2022 | 6.69% |
| Cyber fraud growth | 421.8% |
| Top-5 state cybercrime concentration | 69.2% |


# SQL Analysis

The file `analysis_queries.sql` contains PostgreSQL-compatible queries covering:

1. Dataset coverage
2. Data-quality checks
3. Annual crime totals
4. Crime-category ranking
5. Cybercrime year-over-year growth
6. Cybercrime share of total crime
7. State rankings
8. Cybercrime state rankings
9. District rankings after circle aggregation
10. 2017 vs 2022 category growth
11. Top-five cybercrime concentration

# Python Analysis

The main Python file is:

`ncrb_crime_analysis.py`

It performs:

### Data loading

```python
df = pd.read_csv(INPUT_FILE)
```

### Data-quality validation

- shape
- data types
- missing values
- exact duplicates
- year coverage
- state coverage
- district coverage

### Analytical transformations

- total crime calculation
- annual aggregation
- state-year aggregation
- district-year aggregation
- category ranking
- state ranking
- district ranking
- cybercrime concentration
- endpoint growth

### Visualizations

The script automatically generates eight charts:

1. Total crime trend
2. Top crime categories
3. Key category trends
4. Top states
5. Top cybercrime states
6. Cybercrime share
7. Top districts
8. Cybercrime subcategory trends


# Visualization Gallery

All charts are stored under:

`outputs/visualizations/`



### Executive KPIs

- Total recorded cases
- YoY change
- Cybercrime cases
- Cybercrime share
- Crimes against children
- Top state
- Top district

### Trend section

- Total crime by year
- Cybercrime by year
- Cyber fraud by year
- Crimes against children by year

### Geographic section

- State ranking
- District ranking
- Cybercrime concentration
- State-year heatmap

### Category section

- Crime category ranking
- Category contribution %
- 2017 vs 2022 growth
- Emerging categories

---

# Data Quality & Modeling Considerations

## 1. Raw counts are not rates

The dataset contains counts, not population-normalized rates.

Avoid statements such as:

> "State X is the most dangerous."

Instead use:

> "State X has the highest recorded case volume in this dataset."

A rate-based comparison requires population denominators.

## 2. Reporting behavior matters

Recorded crime is influenced by:

- reporting behavior
- registration practices
- administrative processes
- enforcement
- awareness
- classification
- data completeness

Therefore, recorded cases should not automatically be interpreted as the true underlying incidence of crime.

## 3. `other_ipc_special_laws` is a catch-all category

This category is extremely large and can dominate overall totals.

For category-level insight, it is useful to show:

- all categories
- named categories excluding the catch-all

Both perspectives are preserved in the project.

## 4. 2020 requires contextual investigation

The 2020 peak should be investigated with external contextual data before drawing causal conclusions.

## 5. District names/codes can evolve

District boundaries, administrative names and codes can change over time. A production-grade longitudinal analysis should use a stable geographic mapping table where possible.

---

# Recommended Next-Level Enhancements

To take this project from a portfolio analysis to a production analytics project, add:

### 1. Population-normalized crime rates

```text
Crime Rate = Recorded Cases / Population × 100,000
```

### 2. District-level population

Calculate comparable district crime rates.

### 3. Socioeconomic enrichment

Join:

- population
- literacy
- unemployment
- urbanization
- income
- internet penetration


# Conclusion

This analysis shows that the NCRB dataset contains substantial variation across years, crime categories, states and districts. The most important analytical signal is the changing crime mix: cybercrime and cyber-fraud categories expand considerably between 2017 and 2022, while several traditional categories show relatively modest growth or decline.

At the same time, crimes against children, domestic violence, kidnapping, sexual violence and fraud remain major components of recorded crime volume.

From a senior analytics perspective, the most important lesson is that **crime volume should not be treated as a standalone measure of underlying risk**. Population size, reporting behavior, administrative structure and district boundaries materially affect raw counts. A stronger decision-support system would therefore combine this dataset with population denominators and socioeconomic / digital-penetration indicators.

The project demonstrates an end-to-end analytical workflow:

**Raw data → Data quality → Correct aggregation → EDA → SQL analysis → Trend analysis → Geographic benchmarking → Business insights → Visualization → Decision-support recommendations**

This makes the project suitable as a **Data Analyst / Business Analyst portfolio project** demonstrating practical SQL, Python, EDA, visualization, data modeling and analytical storytelling skills.
