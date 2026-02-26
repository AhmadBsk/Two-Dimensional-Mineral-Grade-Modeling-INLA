# Two-Dimensional Mineral Grade Modeling Using INLA+SPDE

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/R-4.0%2B-blue.svg)](https://www.r-project.org/)

### 📄 Associated Paper
This repository contains the R code for the paper:
**"Two-Dimensional Mineral Grade Modeling Using an Approximate Bayesian Approach in the Korour-2 Porphyry Copper Deposit, Kerman, Iran"** (submitted to Computers & Geosciences).

---

## 📌 Abstract

The complexity of tectonic and geological changes, combined with limited observed data in mining areas, poses significant challenges for mineral reserve modeling and estimation. Traditional statistical methods often struggle with highly skewed data and sparse observations, leading to inaccurate variogram estimation. To address these limitations, this study employs a Model-based Geostatistics approach using an approximate Bayesian method the Integrated Nested Laplace Approximation (INLA) for two-dimensional mineral grade modeling. The Stochastic Partial Differential Equation (SPDE) approach is integrated with INLA to enhance computational efficiency in analyzing dense geostatistical data. We apply the INLA+SPDE method to lithogeochemical data from the Korour-2 porphyry copper deposit in Kerman, Iran, focusing on copper grade estimation at the mineral range level. The performance of this method is compared with universal Kriging, a widely used geostatistical technique. Our results demonstrate that the INLA+SPDE approach not only improves computational speed but also provides more accurate identification of mineralization points and better uncertainty quantification compared to traditional Kriging. This study highlights the potential of Bayesian Geostatistics as a robust alternative for mineral resource estimation in complex geological settings.

---

## ⚙️ Requirements & Installation

This project is written in **R (version 4.0 or higher)**.

### 1. Install Required Packages
Run the following commands in your R console:

```r
# Install general packages
packages <- c("gstat", "sp", "ggplot2", "dplyr", "tidyr", "gridExtra", "viridis", "sf")
install.packages(packages[!packages %in% installed.packages()])

### 2. Install INLA Package
The INLA package is not available on CRAN. Install it from the dedicated repository:
install.packages("INLA", repos = "https://inla.r-inla-download.org/R/stable")

📂 Repository Structure
Two-Dimensional-Mineral-Grade-Modeling-INLA/
│
├── code/                     # R scripts
│   ├── 01_preprocessing.R    # Data preprocessing and cleaning
│   ├── 02_variogram_analysis.R # Variogram analysis
│   ├── 03_kriging_universal.R  # Universal kriging implementation
│   ├── 04_inla_spde_model.R    # INLA+SPDE model implementation
│   ├── 05_cross_validation.R   # Cross-validation procedures
│   ├── 06_anomaly_detection.R  # Anomaly detection analysis
│   ├── 07_figures_tables.R     # Generate final figures and tables
│   ├── functions/               # Helper functions
│   │   └── helpers.R
│   └── run_all.R                # Master script to run the entire analysis
│
├── data/                     # Data files
│   ├── raw_data.csv           # Raw copper grade data (anonymized)
│   └── README-data.md         # Data description and access information
│
├── results/                   # Output files
│   ├── figures/               # Generated figures (PDF/PNG)
│   └── tables/                 # Generated tables (CSV)
│
├── docs/                       # Additional documentation
├── LICENSE                     # MIT License file
└── README.md                    # This file


📊 Data
The data used in this study were collected from the Korour-2 porphyry copper deposit in Kerman Province, Iran.
File format: CSV
Number of samples: 352
Sampling grid: 100 × 100 meters
Primary variable: Copper grade (ppm)
⚠️ Note: Due to confidentiality agreements regarding exploration data, the full raw_data.csv file is not included in this repository. A sample file (data/sample_data.csv) with the same structure is provided for testing the code. For access to the complete dataset, please contact the corresponding author.

📈 Key Results
The INLA+SPDE model consistently outperformed universal kriging across all sampling densities (5% to 50%).
At low sampling density (5%), INLA+SPDE identified 4 times more true anomaly points compared to kriging.
MAE and RMSE error metrics were 10-12% lower for the Bayesian approach compared to universal kriging.
INLA+SPDE demonstrated superior uncertainty quantification and more accurate delineation of mineralization zones.
For detailed results and discussion, please refer to the full paper.

📝 How to Cite
If you use this code in your research, please cite both the paper and this repository:
Paper citation:
[Ahmadreza Boskabadi], [2025]. "Two-Dimensional Mineral Grade Modeling Using an Approximate Bayesian Approach in the Korour-2 Porphyry Copper Deposit, Kerman, Iran". Computers & Geosciences. [DOI]

Repository citation (BibTeX):
@misc{yourname2024inla,
  author = {[Boskabadi], [Ahmadreza]},
  title = {R code for: Two-Dimensional Mineral Grade Modeling Using INLA+SPDE},
  year = {2025},
  publisher = {GitHub},
  journal = {GitHub repository},
  howpublished = {\url{https://github.com/AhmadBsk/Two-Dimensional-Mineral-Grade-Modeling-INLA}}
}

📜 License
This project is licensed under the MIT License. See the LICENSE file for details.

✉️ Contact
For questions, suggestions, or collaboration inquiries, please contact the corresponding author:
[ahmadreza.boskabadi@gmail.com]
