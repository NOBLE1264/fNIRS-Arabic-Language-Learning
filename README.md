# fNIRS - Arabic Language Learning

This repository contains MATLAB scripts, analysis pipelines, and supporting documents for a study investigating the neural mechanisms of Arabic language learning using functional Near-Infrared Spectroscopy (fNIRS). The project compares brain activation patterns between learners exposed to **Virtual Reality (VR)**–based learning and those taught through a **Traditional online classroom**.

## Overview
The study integrates behavioral assessments (receptive and productive tests) with neuroimaging data to evaluate how immersive, task-based VR learning environments influence cortical activation across frontal, temporal, and parietal language regions.

The repository includes:
- MATLAB code for preprocessing, normalization, and statistical analysis of fNIRS signals  
- Scripts for between-group comparisons (VR vs. Traditional)  
- Data processing utilities and feature extraction functions  

## Key Components
- `preprocessNIRSData.m` – Preprocessing of raw fNIRS signals  
- `applyNormalization.m` – Baseline and test normalization routines  
- `computePvals_Std.m` – Statistical comparisons between groups  
- `Between_Group_Analysis.m` – Between-group heatmap generation  
- `Test_Results_Analysis.m` – Behavioral test analysis  
- `createDatabase.m` – Converts raw recordings into structured datasets for analysis *(requires NIRS Toolbox)*  
- `Traditional/` and `VR/` – Example group data folders  

## Dependencies
If you plan to use the `createDatabase.m` script, you must first install the **NIRS Toolbox** for MATLAB, which provides the required functions for importing, visualizing, and processing fNIRS data.
Download and installation instructions are available here:  
**[https://github.com/huppertt/nirs-toolbox](https://github.com/huppertt/nirs-toolbox)**

## Citation
If you use or adapt any materials from this repository, please cite:
> Amadi, N. et al. *fNIRS evidence for enhanced brain activity during task-based Arabic learning in virtual reality*, Florida International University, 2025.

## Data Availability
All MATLAB scripts and representative processed datasets are available here.  
Raw fNIRS recordings containing identifiable information are withheld for privacy but may be shared upon reasonable request.
