<h1 align="center">🏘️ Real Estate Market Analysis Using Crime Data (England & Wales, 2018–2022)</h1>

<p align="center">
  <i>Analyzing how crime influences property value and sales trends across England and Wales to inform smarter real estate investments.</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Language-R-blue?logo=r" alt="R Language" />
  <img src="https://img.shields.io/badge/Big%20Data-Hadoop-orange?logo=apache-hadoop" alt="Hadoop" />
  <img src="https://img.shields.io/badge/Data%20Warehouse-Hive-yellow?logo=apache" alt="Hive" />
  <img src="https://img.shields.io/badge/Visualization-Tableau-blueviolet?logo=tableau" alt="Tableau" />
  <img src="https://img.shields.io/badge/Workflow%20Automation-Apache%20NiFi-green?logo=apache" alt="NiFi" />
  <img src="https://img.shields.io/badge/Project%20Management-JIRA-blue?logo=jira" alt="JIRA" />
</p>

---

## 📌 Table of Contents

- [📈 Business Questions](#-business-questions)
- [🗂️ Datasets Used](#-datasets-used)
- [🛠️ Tools & Technologies](#-tools--technologies)
- [🔍 Methodology](#-methodology)
- [📁 Project Structure](#-project-structure)
- [▶️ How to Run the Project](#️-how-to-run-the-project)
- [📊 Key Insights & Recommendations](#-key-insights--recommendations)
- [⚠️ Limitations](#️-limitations)
- [📚 References](#-references)
- [🤝 Contributions](#-contributions)

---
---

## 📈 Business Questions

1. Which Local Authority Districts (LADs) have **low crime rates and high property sales**?
2. How do **property prices** behave in low-crime areas?
3. What are the **most common crime types** in high-sales LADs?
4. Which **property types** sell most in low-crime LADs?
5. What is the **household composition** in safer LADs (based on Census 2021)?

---

## 🗂️ Datasets Used

| Dataset | Description | Source |
|--------|-------------|--------|
| **Crime Data (2018–2022)** | Monthly crime reports per LSOA | [data.police.uk](https://data.police.uk/data/) |
| **Price Paid Data** | Property sales and price records | [UK Land Registry](https://www.gov.uk/government/statistical-data-sets/price-paid-data-downloads) |
| **Census 2021** | Household composition by LAD | [ONS Census](https://www.ons.gov.uk/) |
| **Postcode Lookup** | Maps postcodes to LSOAs | [ONS Geoportal](https://geoportal.statistics.gov.uk/) |

---

## 🛠️ Tools & Technologies

- **R / RStudio** – Data cleaning, analysis, and transformation
- **Hadoop + Hive** – Big data processing and querying
- **Apache NiFi** – Automated data pipelines
- **Tableau** – Interactive dashboards and visualizations
- **JIRA** – Agile project tracking (Scrum methodology)

---

## 🔍 Methodology

- **Data Modeling**: Used **Kimball's Bottom-Up** approach — individual data marts integrated into a centralized warehouse.
- **ETL Process**: Raw data extracted → cleaned → transformed → loaded into **Hive**.
- **Dimension Tables**: Created for crime type, time, LSOA, and postcode mappings.
- **Automation**: NiFi workflows managed data ingestion and cleaning pipelines.

---

## 📁 Project Structure

```plaintext
├── run-all.R                      # Master script to execute full pipeline
├── CrimeData_cleaning.R          # Cleans and processes raw crime data
├── lookup_cleaning.R             # Cleans postcode-to-LSOA mappings
├── /CrimeDataset                 # Raw input files (monthly crime data)
├── /CrimeDatasetMerged          # Year-wise merged crime files
├── /CrimeDatasetCleaned         # Final cleaned crime datasets
├── /Dimensions                  # Dimension tables: LSOA, time, crime type
├── /DimensionMerged             # Merged outputs for Tableau/dashboarding
├── /DatasetReports              # Data quality and summary reports

```

## ▶️ How to Run the Project

### ✅ Prerequisites

Make sure you have the following installed:

- **R** and **RStudio**
- Required R packages:
  ```r
  install.packages(c("data.table", "dplyr", "digest"))
  ```

## 📊 Key Insights

### 💡 Real Estate Market & Crime Data (2018–2022)

- **🏡 Stockport** emerged as a top-performing Local Authority District (LAD) with:
  - Low overall crime rates
  - High volume of property sales
  - Strong performance in **semi-detached** and **detached** property segments

- **📉 Crime Influence on Sales**:
  - Areas with **lower crime rates** generally saw **higher average sale prices** and **greater transaction volumes**.
  - Conversely, high-crime districts often had **lower property demand**, especially for family-oriented homes.

- **🚨 Most Common Crime Types** in high-sales areas:
  - **Anti-social behaviour** and **violent crimes** were most prevalent
  - However, their presence did not always negatively impact sales in urban hubs with strong amenities

- **🏘️ Property Types in Low-Crime Areas**:
  - **Detached** and **semi-detached** homes had the highest average sales price and were preferred by families
  - **Flats and leasehold properties** had relatively lower demand and were more common in urban, higher-crime zones

- **👨‍👩‍👧 Household Composition (2021 Census)**:
  - Low-crime LADs had a higher concentration of:
    - **Single-person households**
    - **Families with dependent children**
  - These demographic insights can inform targeted real estate marketing strategies

- **📈 Temporal Trend**:
  - Despite fluctuations due to COVID-19, overall patterns suggest **consistent investor interest in low-crime areas**, particularly suburban districts near major cities.







