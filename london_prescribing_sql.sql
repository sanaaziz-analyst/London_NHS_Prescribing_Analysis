CREATE DATABASE IF NOT EXISTS nhs_project;
USE nhs_project;

# putted `` as tried multiple times but table was not creating at end putted `` to create and it worked

CREATE TABLE london_prescribing(
`year_month` VARCHAR(7),
`icb_name` VARCHAR(100),
`practice_name` VARCHAR(150),
`bnf_chemical_substance` VARCHAR(150),
`bnf_presentation_name` VARCHAR(200),
`items` INT,
`actual_cost` DECIMAL(12,2),
`quantity` INT,
`disease_category` VARCHAR(50)
);

select * from london_prescribing

#overall total
SELECT 
SUM(items) AS total_items,
ROUND(SUM(actual_cost), 2) AS total_cost
FROM london_prescribing;

#Which disease category has the highest total prescribing cost?

SELECT disease_category,
SUM(items) AS total_items,
ROUND(SUM(actual_cost), 2) AS total_cost
FROM london_prescribing
GROUP BY disease_category
ORDER BY total_cost DESC;

#How does prescribing volume change month over month?
SELECT
`year_month`,
disease_category,
SUM(items) AS total_items
FROM london_prescribing
GROUP BY `year_month`, disease_category
ORDER BY `year_month`, disease_category;

#Which London ICB has the highest total prescribing cost?
SELECT
icb_name,
SUM(items) AS total_items,
ROUND(SUM(actual_cost), 2) AS total_cost
FROM london_prescribing
GROUP BY icb_name
ORDER BY total_cost DESC;

#Within each category, which specific drug drives the most cost?
SELECT
disease_category,
bnf_chemical_substance,
SUM(items) AS total_items,
ROUND(SUM(actual_cost), 2) AS total_cost
FROM london_prescribing
GROUP BY disease_category, bnf_chemical_substance
ORDER BY disease_category, total_cost DESC;

#average cost per item across all 10 drugs (cheap-high-volume vs expensive-low-volume)?
SELECT
bnf_chemical_substance,
SUM(items) AS total_items,
ROUND(SUM(actual_cost), 2) AS total_cost,
ROUND(SUM(actual_cost) / SUM(items), 4) AS avg_cost_per_item
FROM london_prescribing
GROUP BY bnf_chemical_substance
ORDER BY avg_cost_per_item DESC;

#Which practices have the highest total prescribing cost?
SELECT
practice_name,
icb_name,
ROUND(SUM(actual_cost), 2) AS total_cost
FROM london_prescribing
GROUP BY practice_name, icb_name
ORDER BY total_cost DESC
LIMIT 10;

#does one ICB prescribe disproportionately more of a certain category than others?
SELECT
icb_name,
disease_category,
SUM(items) AS total_items
FROM london_prescribing
GROUP BY icb_name, disease_category
ORDER BY icb_name, total_items DESC;

#has total cost grown faster or slower than total items over the 12 months?
SELECT
`year_month`,
SUM(items) AS total_items,
ROUND(SUM(actual_cost), 2) AS total_cost
FROM london_prescribing
GROUP BY `year_month`
ORDER BY `year_month`;

