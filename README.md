# data-512-a4
## Description
This repository contains data and code for assignments 4-7 of DATA 512, Autumn 2021.
It was created by Emily Linebarger (elineb@uw.edu) in Fall 2021. 

The purpose of this assignment was to do an analysis of how "pandemic hobbies" of bread baking, gardening, and pet adoption grew during the first half of 2020 in relation to rising COVID-19 cases.

## Data 
All of the raw, intermediate, and final outputs of this analysis can be found in the file "data-512-a4-data.zip". 
Inside this zip file, the structure is: 
 * raw_data: Contains raw data directly from source. 
 * prepped_data: Contains cleaned data to be used for plotting 
 * pngs: Contains PNGs of final graphs for report. 
 
The raw data sources used in this project were: 
* Johns Hopkins University: COVID-19 cases and deaths (https://www.kaggle.com/antgoldbloom/covid19-data-from-john-hopkins-university?select=RAW_us_confirmed_cases.csv)
* US Department of Agriculture Food Price Outlook: Contains food price index data from 1974 - 2020. (https://www.ers.usda.gov/data-products/food-price-outlook/)
* US Census Bureau, Monthly Retail Trade Report There are several datasets here, but I’m most interested in the “Retail and Food Services Sales” and “Retail Industries” datasets. These provide economic survey data for retailers in the United States from 1992-present. (https://www.census.gov/retail/index.html)
* St. Louis Federal Reserve, Retail Sales for building materials and garden supply retailers This is a monthly dataset available from 1992 - 2021. (https://fred.stlouisfed.org/series/RSBMGESD)
* Shelter Animals Count, COVID-19 Statistics This organization attempts to be a national source of data on shelter animals. They have a public dataset available about COVID-19 (2019 - 2020), as well as selected data available from 2016-2018. (https://www.shelteranimalscount.org/COVID-19)

## Code
This code uses a mixture of R and python code. The scripts should be run in the following order to reproduce the analysis: 
1. `shelter_animals_count_extraction.py` This tableau scraper extracts COVID-19 data from the Tableau site for Shelter Animals Count. 
2. `clean_data.R` This script reads in inputs from the "raw_data" folder inside data-512-a4-data, and creates prepped datasets for plotting inside "prepped_data". 
3. `analysis.R` This script creates the regressions, PNGs, and other analyses for the final paper. 
