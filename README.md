# London NHS Prescribing Analysis

**Industry:** Healthcare and Public Sector Data
**Data period:** April 2025 to March 2026

> **A note on the data:** every figure in this project comes from real, publicly released NHS Business Services Authority (NHSBSA) open data, covering prescribing across five London Integrated Care Boards (ICBs) over twelve consecutive months. Nothing here is simulated or estimated — every number quoted in this README was checked directly against the underlying SQL output before being written down.

---

## Report Preview

*(Add a screenshot or short screen-recording GIF of Page 1 here, saved to `images/report_preview.gif`)*

---

## TL;DR

A three page Power BI dashboard analysing over two million real NHS prescribing records across five London ICBs and ten common drugs, built on a cleaned and merged data model with Python, explored through SQL, and finished with a custom NHS-branded Power BI theme, KPI cards, and a page navigator.

**Key findings:**

- Respiratory drugs cost the NHS the most overall, £33.04 million, 41 per cent of all spend, despite being prescribed far less often, 3.1 million items, than Cardiovascular drugs at 15.6 million items
- Just two drugs, Insulin glargine and Beclometasone dipropionate, make up 51 per cent of all prescribing cost, despite representing a small share of total items
- North West London has the highest total cost at £19.2 million, despite North East London having slightly more prescribed items
- Every one of the five London ICBs prescribes the same five categories in exactly the same order, cost differences come from scale, not from different underlying health needs
- South East London holds 6 of the 10 highest spending practices, despite not being the highest spending ICB overall
- Prescribing volume stayed almost flat across the year, up 1.7 per cent, but total cost suddenly dropped 35.6 per cent starting January 2026, a genuine unexplained anomaly rather than a gradual trend

---

## Project Files

| File | Description | Link |
|---|---|---|
| Python cleaning and merging | Combines 12 monthly NHSBSA exports, keeps only needed columns, adds disease category labels, checks for unmatched rows | [nhs_prescribing.ipynb](./nhs_prescribing.ipynb) |
| Python, loading to MySQL | Loads the cleaned CSV into a local MySQL database | [uploading_to_MYSQL.ipynb](./uploading_to_MYSQL.ipynb) |
| SQL queries | All business-question queries used to answer the report's core questions | [london_prescribing_sql.sql](./london_prescribing_sql.sql) |
| Power BI report | Full three page .pbix file, open in Power BI Desktop to explore | [Download .pbix](./NHS_London_Prescribing_Analysis.pbix) |
| Power BI theme | Custom NHS-branded colour theme used throughout the report | [nhs_london_prescribing_theme.json](./nhs_london_prescribing_theme.json) |

*(Raw monthly CSVs are not included in this repository due to file size — see Phase 1 below for the exact NHSBSA source and filters used to reproduce them.)*

---

## Why I Built This Project

Healthcare spending is a topic almost everyone has an opinion on, but the public rarely sees the actual numbers behind it. I wanted to work with a genuinely large, messy, real-world government dataset rather than a pre-cleaned tutorial file, and use it to answer a specific, open question: **does how often a drug is prescribed actually predict how much it costs the NHS?**

I deliberately narrowed the scope to five London ICBs and ten common drugs across five everyday health categories, diabetes, mental health, respiratory, cardiovascular and pain relief, so the project could go deep rather than broad. Over two million prescribing records later, the answer turned out to be more interesting than expected. Cost and volume regularly point in opposite directions, and one finding, an unexplained 35.6 per cent cost drop starting January 2026, is a genuinely open question I would want to take to a real stakeholder to investigate further.

The goal throughout was to give an honest account of what the data actually shows, including the parts that did not match my initial assumptions, rather than force a tidy narrative onto the numbers.

---

## Project Overview

A data analysis project looking at NHS prescribing cost and volume across five London ICBs between April 2025 and March 2026. Built for a portfolio piece using real NHSBSA open prescribing data, working through the full pipeline, raw data, Python cleaning, MySQL, SQL analysis, and a three page interactive Power BI dashboard.

The project covers **2,035,897 prescribing records** across **5 London ICBs**, **10 drugs**, and **5 disease categories**, spanning 12 consecutive months.

The core question: does prescribing volume predict prescribing cost? Put simply, no. The most prescribed category is not the most expensive one, and a small number of drugs quietly account for the majority of spend.

---

## Insights

#### Datasets

- Raw monthly NHSBSA exports are not included in this repository due to file size, see Phase 1 below for the exact source and filters used
- The cleaned, merged dataset, `london_prescribing_clean.csv`, is produced by the Python notebook below and loaded directly into MySQL

#### Data Cleaning and Analysis

- The full Python cleaning and merging work is in [nhs_prescribing.ipynb](./nhs_prescribing.ipynb)
- The MySQL loading step is in [uploading_to_MYSQL.ipynb](./uploading_to_MYSQL.ipynb)
- The SQL queries used to answer all business questions are in [london_prescribing_sql.sql](./london_prescribing_sql.sql)
- The finished three page Power BI report can be found in this repository as a .pbix file

---

## Tools and Technologies

| Category | Tools |
|---|---|
| Programming and cleaning | Python (Pandas), Jupyter Notebook |
| Database management | MySQL, SQLAlchemy, PyMySQL |
| Visualisation and dashboard | Power BI |
| Data storage | CSV files |
| Version control | GitHub |

---

## Project Phases

---

### Phase 1: Data Collection

Source data was manually downloaded from the [NHSBSA Open Data Portal, English Prescribing Dataset (EPD) with SNOMED Code](https://opendata.nhsbsa.net/dataset/english-prescribing-dataset-epd-with-snomed-code), filtered at source to keep the project focused:

- **ICB filter:** 5 London ICBs, North East, North Central, North West, South East, and South West London
- **Drug filter:** 10 chemical substances across 5 disease categories, shown below
- **Time range:** April 2025 to March 2026, 12 consecutive months, chosen deliberately before a London ICB naming and merger change, so all five ICBs have consistent names throughout the period

| Category | Drugs |
|---|---|
| Diabetes | Metformin hydrochloride, Insulin glargine |
| Mental Health | Sertraline hydrochloride, Citalopram hydrobromide |
| Respiratory | Salbutamol, Beclometasone dipropionate |
| Cardiovascular | Atorvastatin, Amlodipine |
| Pain Relief | Paracetamol, Ibuprofen |

This produced 12 monthly CSV files, `EPD_SNOMED_202504-000000000000.csv` through `EPD_SNOMED_202603-000000000000.csv`, each a genuine, unmodified government export.

---

### Phase 2: Data Cleaning and Merging (Python and Pandas)

**Notebook:** [nhs_prescribing.ipynb](./nhs_prescribing.ipynb)

Before any analysis, the raw monthly exports needed real cleaning. Each file arrived with 27 columns, most of which were not needed, and none of them included a disease category label, since NHSBSA does not provide that mapping directly.

**Finding and combining all 12 monthly files**

```python
import pandas as pd
import glob

matching_files = glob.glob("*EPD_SNOMED_*.csv")
list_of_tables = [pd.read_csv(file) for file in matching_files]
combined = pd.concat(list_of_tables, ignore_index=True)
```

*(Add a screenshot of this step here, `images/py_01_combine.png`)*

All 12 monthly exports were combined into a single table using `pandas` and `glob`, rather than opening and merging each file by hand.

**Reducing to the columns actually needed**

```python
columns_we_want = [
    "YEAR_MONTH", "ICB_NAME", "PRACTICE_NAME",
    "BNF_CHEMICAL_SUBSTANCE", "BNF_PRESENTATION_NAME",
    "ITEMS", "ACTUAL_COST", "QUANTITY",
]
columns_available = [col for col in columns_we_want if col in combined.columns]
combined = combined[columns_available]
```

*(Add a screenshot here, `images/py_02_column_select.png`)*

27 raw columns were reduced down to the 8 actually needed for analysis.

**Adding a disease category label**

```python
drug_to_category = {
    "Metformin hydrochloride": "Diabetes",
    "Insulin glargine": "Diabetes",
    "Sertraline hydrochloride": "Mental Health",
    "Citalopram hydrobromide": "Mental Health",
    "Salbutamol": "Respiratory",
    "Beclometasone dipropionate": "Respiratory",
    "Atorvastatin": "Cardiovascular",
    "Amlodipine": "Cardiovascular",
    "Paracetamol": "Pain Relief",
    "Ibuprofen": "Pain Relief",
}
combined["DISEASE_CATEGORY"] = combined["BNF_CHEMICAL_SUBSTANCE"].map(drug_to_category)
```

*(Add a screenshot here, `images/py_03_category_mapping.png`)*

Since NHSBSA data does not pre-label drugs by disease category, a 9th column was added using a manual Python dictionary lookup built by hand for the 10 target drugs.

**Checking what didn't match, rather than assuming the mapping worked**

```python
missing = combined[combined["DISEASE_CATEGORY"].isna()]
print(f"Rows without a category: {len(missing)}")
if len(missing) > 0:
    print(missing["BNF_CHEMICAL_SUBSTANCE"].unique())
```

*(Add a screenshot here, `images/py_04_missing_check.png`)*

313 rows did not match any of the 10 target drugs. Checking exactly which drug they belonged to, rather than dropping them blindly, showed all 313 were a single stray drug, Almotriptan, that had slipped through the original download filter. This is a deliberate two-step habit: build the mapping, then verify what it missed, since it is easy to assume a lookup dictionary worked and never actually check.

**Removing the unmatched rows and exporting the final file**

```python
combined = combined[combined["DISEASE_CATEGORY"].notna()]
combined.to_csv("london_prescribing_clean.csv", index=False)
```

*(Add a screenshot here, `images/py_05_export.png`)*

Final dataset: **2,035,897 rows**, down from 2,036,210 before the cleanup, 9 columns, ready for MySQL.

---

### Phase 3: Loading into MySQL

**Notebook:** [uploading_to_MYSQL.ipynb](./uploading_to_MYSQL.ipynb)

```python
import pandas as pd
import os
from sqlalchemy import create_engine

df = pd.read_csv("london_prescribing_clean.csv")

db_user = os.environ.get("DB_USER", "root")
db_password = os.environ.get("DB_PASSWORD", "")
engine = create_engine(f"mysql+pymysql://{db_user}:{db_password}@localhost/nhs_project")

df.to_sql("london_prescribing", con=engine, if_exists="replace", index=False, chunksize=5000)
```

*(Add a screenshot here, `images/py_06_mysql_load.png`)*

The cleaned CSV was loaded into a local MySQL database using `pandas.to_sql()` with `sqlalchemy` and `pymysql`, rather than `LOAD DATA INFILE`, which repeatedly hit local file permission restrictions in this environment. Database credentials are read from environment variables rather than hardcoded, so this notebook is safe to publish as-is. Row count in MySQL matched the cleaned CSV exactly, 2,035,897 rows.

---

### Phase 4: Exploratory Data Analysis (SQL)

**Queries:** [london_prescribing_sql.sql](./london_prescribing_sql.sql)

Each query below was written to answer a specific business question, and every result was cross-checked directly against the Power BI dashboard before being finalised.

---

**Business question: What's the overall scale of prescribing across London?**

```sql
SELECT
    SUM(items) AS total_items,
    ROUND(SUM(actual_cost), 2) AS total_cost
FROM london_prescribing;
```

*(Add a screenshot here, `images/sql_01_overall_totals.png`)*

Across the full 12 months, London's five ICBs recorded **29,720,015 items** at a total cost of **£80,587,945.86**. This is the baseline figure every other percentage in this project is measured against.

---

**Business question: Which disease category has the highest total prescribing cost?**

```sql
SELECT disease_category,
       SUM(items) AS total_items,
       ROUND(SUM(actual_cost), 2) AS total_cost
FROM london_prescribing
GROUP BY disease_category
ORDER BY total_cost DESC;
```

*(Add a screenshot here, `images/sql_02_category_cost.png`)*

Respiratory tops the list at £33.04 million, 41 per cent of all spend, followed by Diabetes at £23.34 million, 29 per cent, Cardiovascular at £12.15 million, 15.1 per cent, Pain Relief at £6.87 million, 8.5 per cent, and Mental Health at £5.18 million, 6.4 per cent. Respiratory and Diabetes together account for exactly 70 per cent of all prescribing cost across London.

---

**Business question: How does prescribing volume change month over month, by category?**

```sql
SELECT `year_month`,
       disease_category,
       SUM(items) AS total_items
FROM london_prescribing
GROUP BY `year_month`, disease_category
ORDER BY `year_month`, disease_category;
```

*(Add a screenshot here, `images/sql_03_monthly_trend.png`)*

Cardiovascular consistently dominates monthly item volume across the entire year. Respiratory is the one category that breaks pattern, dipping sharply in January and February 2026, the opposite of the winter increase you would normally expect, rather than following the same steady shape as the other four categories.

---

**Business question: Which London ICB has the highest total prescribing cost?**

```sql
SELECT icb_name,
       SUM(items) AS total_items,
       ROUND(SUM(actual_cost), 2) AS total_cost
FROM london_prescribing
GROUP BY icb_name
ORDER BY total_cost DESC;
```

*(Add a screenshot here, `images/sql_04_icb_cost.png`)*

North West London leads at £19.23 million from 7.40 million items. North East London actually has more items, 7.77 million, but a lower total cost of £17.74 million, since North West London's drug mix skews towards pricier prescriptions.

---

**Business question: Within each category, which specific drug drives the most cost?**

```sql
SELECT disease_category,
       bnf_chemical_substance,
       SUM(items) AS total_items,
       ROUND(SUM(actual_cost), 2) AS total_cost
FROM london_prescribing
GROUP BY disease_category, bnf_chemical_substance
ORDER BY disease_category, total_cost DESC;
```

*(Add a screenshot here, `images/sql_05_top_drug_per_category.png`)*

Insulin glargine drives Diabetes cost at £13.16 million from only 308,442 items, far ahead of Metformin. Beclometasone dipropionate drives Respiratory cost at £28.18 million, more than double Salbutamol's £4.87 million, despite Salbutamol having more items, 1.75 million versus 1.37 million.

---

**Business question: What's the average cost per item across all 10 drugs?**

```sql
SELECT bnf_chemical_substance,
       SUM(items) AS total_items,
       ROUND(SUM(actual_cost), 2) AS total_cost,
       ROUND(SUM(actual_cost) / SUM(items), 4) AS avg_cost_per_item
FROM london_prescribing
GROUP BY bnf_chemical_substance
ORDER BY avg_cost_per_item DESC;
```

*(Add a screenshot here, `images/sql_06_cost_per_item.png`)*

Insulin glargine is the single most expensive drug per item at £42.66, followed by Beclometasone dipropionate at £20.62. At the other end, Amlodipine is the cheapest at £0.75 per item. That is a roughly 57 times spread between the most and least expensive drug in the whole dataset, and it is exactly why cost and prescription volume tell two different stories.

---

**Business question: Which practices have the highest total prescribing cost?**

```sql
SELECT practice_name,
       icb_name,
       ROUND(SUM(actual_cost), 2) AS total_cost
FROM london_prescribing
GROUP BY practice_name, icb_name
ORDER BY total_cost DESC
LIMIT 10;
```

*(Add a screenshot here, `images/sql_07_top_practices.png`)*

Medicus Health Partners, in North Central London, tops the list at £886,450. Notably, 6 of the 10 highest spending practices sit in South East London, Nexus Health Group, The Lewisham Care Partnership, Modality Lewisham, Valentine Health Partnership, Sidcup Medical Centre, and Eltham Medical Practice, despite South East London not being the highest spending ICB overall. Spend at the practice level is concentrated, not evenly spread.

*One data quality issue caught while building this in Power BI is worth noting here: two different practices in two different ICBs are both named "Churchill Medical Centre". A naive Top 10 filter on practice name alone merged them incorrectly and pushed a genuine top-10 practice out of the list. The fix was to filter on a combined practice name and ICB field instead, so two same-named practices in different boroughs are correctly treated as distinct entities.*

---

**Business question: Does one ICB prescribe disproportionately more of a certain category than the others?**

```sql
SELECT icb_name,
       disease_category,
       SUM(items) AS total_items
FROM london_prescribing
GROUP BY icb_name, disease_category
ORDER BY icb_name, total_items DESC;
```

*(Add a screenshot here, `images/sql_08_category_mix_by_icb.png`)*

No. Every one of the five ICBs prescribes the same five categories in exactly the same order by item volume, Cardiovascular, then Diabetes, then Mental Health, then Respiratory, then Pain Relief, without exception. The differences between ICBs are entirely a matter of scale, not a difference in which health conditions are more common in one area versus another.

---

**Business question: Has total cost grown faster or slower than total items over the 12 months?**

```sql
SELECT `year_month`,
       SUM(items) AS total_items,
       ROUND(SUM(actual_cost), 2) AS total_cost
FROM london_prescribing
GROUP BY `year_month`
ORDER BY `year_month`;
```

*(Add a screenshot here, `images/sql_09_items_vs_cost_by_month.png`)*

Items grew from 2.48 million in April 2025 to 2.52 million in March 2026, up 1.7 per cent, essentially flat across the year. Total cost, by contrast, held steady between £7.0 million and £7.9 million a month through December 2025, then dropped sharply to £4.78 million in January 2026 and stayed low for the rest of the period, a fall of 35.6 per cent from April to March. This is a genuine step-change rather than a gradual trend, and it is flagged in this project as an open question rather than a forced explanation. The two most likely causes, a pricing or tariff change, or a shift towards generic alternatives, cannot be distinguished using this dataset alone.

---

### Phase 5: Advanced Analysis and Visual Design (Power BI)

Moved into Power BI for the visual and interactive work. All screenshots are in the `images` folder. A page navigator at the top of the report lets you click between all three pages, styled to match the NHS colour palette used throughout.

---

## Page 1: Overview

*(Add a screenshot here, `images/page1.png`)*

This is the landing page of the report, designed to answer "what do I need to know in the first ten seconds" before anyone digs into the detail pages.

**Key finding banner** A callout at the top of the page stating the headline finding in plain English: Respiratory drugs cost the NHS more than any other category, £33.0 million, despite far lower item volume than Cardiovascular, 15.6 million items, driven by inhaler pricing rather than prescription count.

**Four KPI cards** Total prescribing cost, £80.6 million across 12 months and 5 categories. Highest cost category, Respiratory, at £33.04 million from 3.1 million items. Highest volume category, Cardiovascular, at 15.6 million items and £12.1 million. Top ICB by cost, NW London, at £19.1 million total. Each card uses a coloured accent bar matching its category, and a smaller subtitle line giving the supporting number underneath the headline figure.

**Monthly items by disease category, line chart** Five lines, one per category, showing item volume across all 12 months. Cardiovascular consistently sits well above the other four throughout the year. Respiratory is the one line that breaks pattern, dipping sharply in January and February 2026, rather than showing the winter increase you might expect.

**Total cost share by category, donut chart** Respiratory and Diabetes together account for exactly 70 per cent of all prescribing cost, despite representing a much smaller share of total items between them.

**Total cost by London ICB, bar chart** North West London leads at roughly £19.2 million, despite North East London recording more prescribed items overall, £17.7 million against North West's £19.2 million, a pricier drug mix rather than a higher prescription count.

**Page outcome:** this page establishes the report's central argument in the first ten seconds, cost and prescribing volume do not move together, and Respiratory is the clearest example of that pattern.

---

## Page 2: Category Deep-Dive

*(Add a screenshot here, `images/page2.png`)*

This page moves from the whole-network view into the individual drugs driving each category's cost.

**Key finding banner** Just two drugs, Insulin glargine and Beclometasone, make up 51 per cent of all prescribing costs, even though they're only a small part of total prescriptions. The other 8 drugs are cheap and prescribed a lot, but they barely add to the overall cost.

**Top drug by cost, within each category, grouped bar chart** Every category's two drugs shown side by side, darker bar for the higher cost drug, lighter bar for the lower cost drug. Respiratory's gap is by far the largest, Beclometasone towering over Salbutamol, followed by Diabetes, where Insulin glargine still costs notably more than Metformin despite Metformin being prescribed far more often.

**Average cost per item, all 10 drugs ranked, horizontal bar chart** All ten drugs ranked by cost per item, colour coded by category. Insulin glargine and Beclometasone sit clearly apart from the rest at the top, £42.66 and £20.62 per item, while the remaining eight drugs cluster near the bottom of the scale, all under £4 per item. This single chart is the clearest visual proof in the whole report that a small number of low-volume drugs can dominate cost while the majority of prescriptions barely register.

**Detail table** Every one of the 10 drugs listed with total items, total cost, and average cost per item, sorted highest cost first, so Beclometasone and Insulin glargine sit at the top of the table, directly under the key finding banner they support.

**Page outcome:** this page proves the "cost does not equal volume" argument at the individual drug level, not just the category level, and identifies the exact two drugs responsible for over half of all prescribing spend.

---

## Page 3: ICB & Practice Comparison

*(Add a screenshot here, `images/page3.png`)*

The final page shifts focus onto geography and individual practices, and surfaces the project's one open, unresolved finding.

**Anomaly banner** Styled with a red accent to visually distinguish it from the two blue "confirmed finding" banners on the earlier pages, since this one flags a genuine open question rather than a closed finding: prescriptions stayed roughly the same all year, up 1.7 per cent, but costs suddenly dropped by 35.6 per cent in January 2026, a sudden drop, not something that happened slowly.

**Total items vs. total cost, by month, dual-axis combo chart** Items shown as light blue-grey bars, cost as a red line, both plotted against separate scales so both series stay readable despite their very different units. The two track each other closely from April through December 2025, then the red cost line breaks away sharply in January 2026 while the bars stay essentially flat, a clean visual proof of the step-change described in the banner above.

**Top 10 practices by total cost, table** Medicus Health Partners leads at £886,450. South East London holds 6 of the 10 highest spending practices, despite not being the highest spending ICB overall, showing that spend is concentrated in a handful of large practices in that borough rather than spread evenly across it.

**Category mix by ICB, 100 per cent stacked bar chart** All five ICBs shown side by side, each bar showing the same proportional breakdown, Cardiovascular, then Diabetes, then Mental Health, then Respiratory, then Pain Relief, in identical order every single time. Every bar is visually the same shape, which is itself the finding, prescribing patterns are consistent across London, and cost differences between ICBs come from scale rather than from different underlying health needs.

**Page outcome:** this page closes the report by proving that geography changes the scale of spending, not the shape of it, and honestly flags the one genuine anomaly in the dataset as something worth investigating further, rather than something already explained.

---

## Skills This Project Demonstrates

- End-to-end data pipeline construction, from raw multi-file government exports through Python cleaning, MySQL loading, SQL analysis, and finally an interactive Power BI report
- Data quality verification as a habit, not an afterthought, including checking for unmatched category mappings and catching a duplicate-name filtering bug through independent SQL verification
- SQL query writing across aggregation, grouping, and multi-dimensional business questions
- Power BI report design, including a custom theme, KPI cards with coloured accent bars, dynamic DAX measures, and a page navigator
- Translating raw statistics into plain English findings, and being willing to flag an anomaly as genuinely unresolved rather than forcing an explanation the data does not fully support

---

## Key Findings

- Respiratory drugs cost the NHS the most overall, £33.04 million, 41 per cent of all spend, despite being prescribed far less often than Cardiovascular drugs
- Just two drugs, Insulin glargine and Beclometasone dipropionate, make up 51 per cent of all prescribing cost
- North West London has the highest total cost, £19.2 million, despite North East London having slightly more prescribed items
- Every one of the five London ICBs prescribes the same categories in the same order, cost differences come from scale, not differing health needs
- South East London holds 6 of the 10 highest spending practices, despite not being the highest spending ICB overall
- Prescribing volume stayed almost flat across the year, up 1.7 per cent, but total cost suddenly dropped 35.6 per cent starting January 2026, an unexplained step-change flagged for further investigation

---

## Limitations

- Disease category mapping is manual. The 10 drugs were mapped to 5 categories by hand, since NHSBSA data does not include this label. A drug prescribed off-label for a condition outside its usual category would not be reflected here
- The January 2026 cost drop is flagged, not explained. This dataset alone cannot distinguish between a pricing or tariff policy change and a shift towards generic alternatives, both are plausible, and confirming either would need additional NHSBSA pricing data outside this project's scope
- Ten drugs and five ICBs is a deliberately narrow slice of a much larger national dataset, chosen to keep the analysis manageable and reproducible, rather than to represent all of NHS prescribing

---

## What Could Be Added With More Time

- A drill-through page allowing any practice or drug to be explored in full detail
- Direct NHSBSA pricing and tariff data, to properly investigate the cause of the January 2026 cost drop rather than only flagging it
- Extending the same analysis to additional ICBs outside London, to see whether the "identical category ranking" finding holds true nationally

---

## Data Source

NHS Business Services Authority (NHSBSA), [English Prescribing Dataset (EPD) with SNOMED Code](https://opendata.nhsbsa.net/dataset/english-prescribing-dataset-epd-with-snomed-code), Open Government Licence.

---

## About Me

I built this report as part of my own practice in data analysis and business intelligence, with a particular interest in healthcare and public sector data. I am currently looking for opportunities in London within data analysis or business intelligence roles, and I would welcome the chance to talk through this project, the choices behind it, or any part of the underlying data model.

Feel free to open the .pbix file yourself, explore the pages, and reach out with any questions or feedback.

## Contact

**[Your name]**

Data Analyst | SQL • Power BI • Python

London, UK

*(Add your email and LinkedIn badges/links here, matching the style of your other project's README)*
