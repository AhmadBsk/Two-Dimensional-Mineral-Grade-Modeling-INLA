# Two-Dimensional Mineral Grade Modeling Using INLA+SPDE

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/R-4.0%2B-blue.svg)](https://www.r-project.org/)

## 📄 Associated Paper
This repository contains the R code for the paper:  
**"Two-Dimensional Mineral Grade Modeling Using an Approximate Bayesian Approach in the Korour-2 Porphyry Copper Deposit, Kerman, Iran"** (submitted to *Computers & Geosciences*).

---

## 📌 Abstract

The complexity of tectonic and geological changes, combined with limited observed data in mining areas, poses significant challenges for mineral reserve modeling and estimation. Traditional statistical methods often struggle with highly skewed data and sparse observations, leading to inaccurate variogram estimation. To address these limitations, this study employs a Model-based Geostatistics approach using an approximate Bayesian method – the Integrated Nested Laplace Approximation (INLA) – for two-dimensional mineral grade modeling. The Stochastic Partial Differential Equation (SPDE) approach is integrated with INLA to enhance computational efficiency in analyzing dense geostatistical data. We apply the INLA+SPDE method to lithogeochemical data from the Korour-2 porphyry copper deposit in Kerman, Iran, focusing on copper grade estimation at the mineral range level. The performance of this method is compared with universal Kriging, a widely used geostatistical technique. Our results demonstrate that the INLA+SPDE approach not only improves computational speed but also provides more accurate identification of mineralization points and better uncertainty quantification compared to traditional Kriging. This study highlights the potential of Bayesian Geostatistics as a robust alternative for mineral resource estimation in complex geological settings.

---

## ⚙️ Requirements & Installation

This project is written in **R (version 4.0 or higher)**.

### 1. Install Required Packages
Run the following commands in your R console:

```r
# Install general packages
packages <- c("gstat", "sp", "ggplot2", "dplyr", "tidyr", "gridExtra", "viridis", "sf", "automap", "readxl", "openxlsx")
install.packages(packages[!packages %in% installed.packages()])
```

### 2. Install INLA Package
The INLA package is not available on CRAN. Install it from the dedicated repository:

```r
install.packages("INLA", repos = "https://inla.r-inla-download.org/R/stable")
```

> **Note**: For exact reproduction of results, refer to the `sessionInfo.txt` file (if provided) or use `renv` to restore the package environment.

---

## 🚀 How to Run

To reproduce the entire analysis and generate all figures and tables from the paper, follow these steps:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/AhmadBsk/Two-Dimensional-Mineral-Grade-Modeling-INLA.git
   ```
2. **Set the working directory** to the project root (e.g., open the project in RStudio).
3. **Ensure all required packages are installed** (see above).
4. **Place the data file** (`keror2-2.xlsx`) in the `data/` folder.  
   *( full dataset is confidential, a sample file `data/sample_data.xlsx` is provided for testing.)*
5. **Run the master script**:
   ```r
   source("code/run_all.R")
   ```
   This script sequentially executes all steps:
   - Data preprocessing and outlier handling
   - Trend analysis, histogram, and variogram modeling
   - Cross-validation for INLA+SPDE and universal kriging at multiple sampling densities (5%, 10%, 20%, 33%, 50%)
   - Anomaly detection using probability plots (for the 20% fraction as an example)
   - Generation of all figures and summary tables

All outputs (figures, tables, cross-validation results) will be saved in the `results/` directory.

---

## 📂 Repository Structure

```
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
│   ├── keror2-2.xlsx          # Raw copper grade data (not included in repo – confidential)
│   └── sample_data.csv        # Small sample for testing
│
├── results/                   # Output files (created by scripts)
│   ├── figures/               # Generated figures (PNG/PDF)
│   └── tables/                 # Generated tables (CSV)
│
├── docs/                       # Additional documentation (optional)
├── LICENSE                     # MIT License file
└── README.md                    # This file
```

---

## 📊 Data

The data used in this study were collected from the **Korour-2 porphyry copper deposit** in Kerman Province, Iran.

- **File format**: Excel (`.xlsx`) or CSV
- **Number of samples**: 352
- **Sampling grid**: 100 × 100 meters
- **Primary variable**: Copper grade (ppm)

> ⚠️ **Note**: Due to confidentiality agreements regarding exploration data, the full dataset (`keror2-2.xlsx`) is **not** included in this repository. A sample file (`data/sample_data.csv`) with the same structure (five randomly selected points) is provided for testing the code. For access to the complete dataset, please contact the corresponding author.

---

## 📈 Key Results

- The **INLA+SPDE** model consistently outperformed universal kriging across all sampling densities (5% to 50%).
- At low sampling density (5%), INLA+SPDE identified **4 times more** true anomaly points compared to kriging.
- **MAE** and **RMSE** error metrics were 10–12% lower for the Bayesian approach compared to universal kriging.
- INLA+SPDE demonstrated superior uncertainty quantification and more accurate delineation of mineralization zones.

For detailed results and discussion, please refer to the full paper.

---

## 📝 How to Cite

If you use this code in your research, please cite both the paper and this repository:

**Paper citation**:
```
Boskabadi, A., et al. (2025). "Two-Dimensional Mineral Grade Modeling Using an Approximate Bayesian Approach in the Korour-2 Porphyry Copper Deposit, Kerman, Iran". Computers & Geosciences. [DOI]
```

**Repository citation (BibTeX)**:
```bibtex
@misc{boskabadi2025inla,
  author = {Boskabadi, Ahmadreza},
  title = {R code for: Two-Dimensional Mineral Grade Modeling Using INLA+SPDE},
  year = {2025},
  publisher = {GitHub},
  journal = {GitHub repository},
  howpublished = {\url{https://github.com/AhmadBsk/Two-Dimensional-Mineral-Grade-Modeling-INLA}}
}
```

---

## 📜 License

This project is licensed under the **MIT License**. See the `LICENSE` file for details.

---

## ✉️ Contact

For questions, suggestions, or collaboration inquiries, please contact the corresponding author:  
**Ahmadreza Boskabadi** – [ahmadreza.boskabadi@gmail.com](mailto:ahmadreza.boskabadi@gmail.com)
