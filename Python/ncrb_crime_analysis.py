"""
NCRB Crime Analysis 2017-2022
Senior Data Analyst Portfolio Project

Run:
    pip install -r requirements.txt
    python ncrb_crime_analysis.py

The script:
1. Loads and validates the raw CSV.
2. Performs EDA and data-quality checks.
3. Aggregates registration-circle records to district/year and state/year.
4. Calculates trends, concentration, rankings and selected growth metrics.
5. Saves analytical CSV outputs.
6. Generates portfolio-ready visualizations.
"""
import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

INPUT_FILE = "NCRB_Crime_Analysis_2017_2022_with_25Crime_categories_Districtwise.csv"
OUTPUT_DIR = "outputs"
VIZ_DIR = os.path.join(OUTPUT_DIR, "visualizations")
os.makedirs(VIZ_DIR, exist_ok=True)

df = pd.read_csv(INPUT_FILE)

# -----------------------------
# 1. Data preparation
# -----------------------------
id_cols = ["year", "state_name", "state_code", "district_name",
           "district_code", "registration_circles"]
crime_cols = [c for c in df.columns if c not in id_cols]

# Enforce numeric crime fields
for c in crime_cols:
    df[c] = pd.to_numeric(df[c], errors="coerce")

df["total_crime"] = df[crime_cols].sum(axis=1)

print("=" * 70)
print("DATASET OVERVIEW")
print("=" * 70)
print("Rows:", len(df))
print("Columns:", len(df.columns))
print("Years:", sorted(df["year"].unique()))
print("States/UTs:", df["state_name"].nunique())
print("Districts:", df["district_name"].nunique())
print("Missing values:", int(df.isna().sum().sum()))
print("Exact duplicate rows:", int(df.duplicated().sum()))
print("\nData types:\n", df.dtypes)

# IMPORTANT: several districts contain multiple registration circles.
# Therefore district-level analysis must aggregate circle rows.
key_duplicates = df.duplicated(["year", "state_code", "district_code"], keep=False)
print("\nRows belonging to district-year groups with multiple circles:",
      int(key_duplicates.sum()))

# -----------------------------
# 2. Basic EDA
# -----------------------------
numeric_summary = df[crime_cols + ["total_crime"]].describe().T
numeric_summary.to_csv(os.path.join(OUTPUT_DIR, "numeric_summary.csv"))

missing = df.isna().sum().sort_values(ascending=False)
missing.to_csv(os.path.join(OUTPUT_DIR, "missing_values.csv"))

# Year-level totals
annual = df.groupby("year")[crime_cols].sum()
annual["total_crime"] = annual.sum(axis=1)
annual.to_csv(os.path.join(OUTPUT_DIR, "annual_crime_totals.csv"))

# Category ranking
category_totals = annual[crime_cols].sum().sort_values(ascending=False)
category_totals.rename("cases_2017_2022").to_csv(
    os.path.join(OUTPUT_DIR, "crime_category_ranking.csv")
)

# State-year aggregation
state_year = (
    df.groupby(["year", "state_name"])[crime_cols]
      .sum()
      .reset_index()
)
state_year["total_crime"] = state_year[crime_cols].sum(axis=1)
state_year.to_csv(os.path.join(OUTPUT_DIR, "state_year_summary.csv"), index=False)

# District-year aggregation (correct analytical grain)
district_year = (
    df.groupby(["year", "state_name", "district_name"])[crime_cols]
      .sum()
      .reset_index()
)
district_year["total_crime"] = district_year[crime_cols].sum(axis=1)
district_year.to_csv(os.path.join(OUTPUT_DIR, "district_year_summary.csv"), index=False)

# -----------------------------
# 3. Business/public-safety insights
# -----------------------------
selected = [
    "murder_homicide", "rape_sexual_violence", "kidnapping_abduction",
    "crimes_against_children", "cybercrime", "cyber_fraud",
    "cheating_fraud", "theft_property_crimes"
]

yoy_2017_2022 = (
    (annual.loc[2022, crime_cols] / annual.loc[2017, crime_cols] - 1) * 100
).sort_values(ascending=False)

# Cyber concentration
cyber_by_state = df.groupby("state_name")["cybercrime"].sum().sort_values(ascending=False)
top5_cyber_share = cyber_by_state.head(5).sum() / cyber_by_state.sum() * 100

# State volume ranking
state_total = (
    df.groupby("state_name")[crime_cols].sum().sum(axis=1)
      .sort_values(ascending=False)
)

# District volume ranking
district_total = (
    district_year.groupby(["state_name", "district_name"])["total_crime"]
    .sum()
    .sort_values(ascending=False)
)

# Selected insight table
insights = pd.DataFrame({
    "metric": [
        "Total recorded cases across 25 categories",
        "2017 total",
        "2022 total",
        "2017-2022 total growth",
        "Cybercrime 2017",
        "Cybercrime 2022",
        "Cybercrime growth 2017-2022",
        "Cybercrime share in 2017",
        "Cybercrime share in 2022",
        "Top 5 states share of cybercrime"
    ],
    "value": [
        annual["total_crime"].sum(),
        annual.loc[2017, "total_crime"],
        annual.loc[2022, "total_crime"],
        (annual.loc[2022, "total_crime"] / annual.loc[2017, "total_crime"] - 1) * 100,
        annual.loc[2017, "cybercrime"],
        annual.loc[2022, "cybercrime"],
        (annual.loc[2022, "cybercrime"] / annual.loc[2017, "cybercrime"] - 1) * 100,
        annual.loc[2017, "cybercrime"] / annual.loc[2017, "total_crime"] * 100,
        annual.loc[2022, "cybercrime"] / annual.loc[2022, "total_crime"] * 100,
        top5_cyber_share
    ]
})
insights.to_csv(os.path.join(OUTPUT_DIR, "key_insights_metrics.csv"), index=False)

# -----------------------------
# 4. Visualizations
# -----------------------------
plt.style.use("default")

def savefig(filename):
    plt.tight_layout()
    plt.savefig(os.path.join(VIZ_DIR, filename), dpi=160, bbox_inches="tight")
    plt.close()

plt.figure(figsize=(10, 5))
plt.plot(annual.index, annual["total_crime"], marker="o")
plt.title("Total Recorded Crime by Year")
plt.xlabel("Year")
plt.ylabel("Cases")
savefig("01_total_crime_trend.png")

top10 = category_totals.drop("other_ipc_special_laws", errors="ignore").head(10).sort_values()
plt.figure(figsize=(10, 6))
plt.barh(top10.index, top10.values)
plt.title("Top 10 Crime Categories, 2017-2022")
plt.xlabel("Cases")
savefig("02_top_crime_categories.png")

plt.figure(figsize=(11, 6))
for c in selected:
    plt.plot(annual.index, annual[c], marker="o", label=c.replace("_", " ").title())
plt.title("Key Crime Category Trends")
plt.xlabel("Year")
plt.ylabel("Cases")
plt.legend(ncol=2, fontsize=8)
savefig("03_key_category_trends.png")

top_states = state_total.head(10).sort_values()
plt.figure(figsize=(10, 6))
plt.barh(top_states.index, top_states.values)
plt.title("Top 10 States/UTs by Recorded Crime Volume")
plt.xlabel("Cases")
savefig("04_top_states.png")

top_cyber = cyber_by_state.head(10).sort_values()
plt.figure(figsize=(10, 6))
plt.barh(top_cyber.index, top_cyber.values)
plt.title("Top 10 States/UTs by Cybercrime Volume")
plt.xlabel("Cybercrime cases")
savefig("05_cyber_states.png")

cyber_share = annual["cybercrime"] / annual["total_crime"] * 100
plt.figure(figsize=(10, 5))
plt.plot(cyber_share.index, cyber_share.values, marker="o")
plt.title("Cybercrime Share of All Recorded Crime")
plt.xlabel("Year")
plt.ylabel("Share (%)")
savefig("06_cyber_share.png")

top_districts = district_total.head(10).sort_values()
labels = [f"{s} - {d}" for s, d in top_districts.index]
plt.figure(figsize=(11, 6))
plt.barh(labels, top_districts.values)
plt.title("Top 10 Districts by Recorded Crime Volume")
plt.xlabel("Cases")
savefig("07_top_districts.png")

cyber_sub = ["cyber_fraud", "identity_privacy_crimes",
             "cyber_harassment_threats", "online_sexual_obscene_crimes"]
plt.figure(figsize=(11, 6))
for c in cyber_sub:
    plt.plot(annual.index, annual[c], marker="o", label=c.replace("_", " ").title())
plt.title("Selected Cybercrime Subcategory Trends")
plt.xlabel("Year")
plt.ylabel("Cases")
plt.legend(fontsize=8)
savefig("08_cyber_subcategories.png")

print("\nAnalysis complete. Outputs saved to:", OUTPUT_DIR)
print("\nTop crime categories excluding 'other_ipc_special_laws':")
print(top10.sort_values(ascending=False).to_string())
print("\nTop states:")
print(state_total.head(10).to_string())
print("\nTop cybercrime states:")
print(cyber_by_state.head(10).to_string())
print("\n2017-2022 growth by category:")
print(yoy_2017_2022.to_string())
