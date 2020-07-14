# Replicating a study in MIMIC-IV

This folder contains code for replicating a study on indwelling arterial catheters:

> Hsu DJ, Feng M, Kothari R, Zhou H, Chen KP, Celi LA. The association between indwelling arterial catheters and mortality in hemodynamically stable patients with respiratory failure: a propensity score analysis. CHEST Journal. 2015 Dec 1;148(6):1470-6.

The study showed, in the MIMIC-II database, that after adjustment for various confounders, indwelling arterial catheters were not associated with a mortality benefit.

The code here reproduces this study in the MIMIC-IV database.
All code was newly written based upon the description of the study in the published paper. When it was unclear from the paper what choices were made, the original code was consulted for clarity.
As the original study was performed in MIMIC-II, the patients in this study are entirely distinct, and this can be considered a replication of the original study.

## Requirements

In order to run the code, you must:

1. Have a Google account authenticated to access MIMIC-IV via BigQuery.
2. The ability to create an environment with `conda`

## Running the study

1. (Optional) Run the `generate-tables.sh` bash script: this generates derived views of MIMIC-IV which are used in the data analysis.
2. Run through the analysis in one of three ways:
    * (Recommended) Open the `aline_analysis.ipynb` notebook in Google Colaboratory.
    * Run the `aline_analysis.py` file from the command line.
    * Step through the `aline_analysis.ipynb` notebook.

## Modifications

There are a few differences between our reproduction and the original study. Notably:

* the original study subselected variables using a genetic algorithm, whereas we simply use the final set of variables they report
* we did not include PO2 and PCO2 in the propensity score
* we removed patients based on hospital service, not ICU service
