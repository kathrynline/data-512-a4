# Data processing 

library(data.table)
library(readxl)

# Set working directory to the unzipped data-512-a4-data folder. 
setwd("~/Desktop/data-512-a4-data")

# BAKING DATASETS 
#-------------------------------
# Consumer price forecasts - 2019 and 2020
#-------------------------------
dt <- read_excel("raw_data/CPIforecast.xlsx")
dt <- data.table(dt)

# Focus on the 2019 and 2020 percent changes, as well as the historical averages 
dt <- dt[, c(1, 6:8)]
names(dt) <- c('item', 'annual_2019_percent_change', 'annual_2020_percent_change', 'historical_average')

# Drop the first 2 rows, these are titles 
dt <- dt[3:nrow(dt)]

# Also drop any NAs, there are separator rows in the excel 
# and footnotes at the bottom 
dt <- dt[!is.na(annual_2019_percent_change)]


write.csv(dt, "prepped_data/consumer_price_indices_2019_2020.csv", row.names = F)

#-------------------------------
# Historical consumer price forecasts 
#-------------------------------
dt <- read_excel("raw_data/historicalcpi.xlsx")
dt <- data.table(dt)

names(dt) <- as.character(dt[1, ])

# Drop the first row after renaming 
dt = dt[2:nrow(dt)]
setnames(dt, 'Consumer Price Index item', 'item')

# Drop any rows where 2019 is blank; these are either 
# NA all the way across or have footnote data. 
dt <- dt[`2019` != "NA"]

write.csv(dt, "prepped_data/consumer_price_indices_1974_2020.csv", row.names = F)

#-------------------------------
# Producer price forecasts 
#-------------------------------

#-------------------------------------------------
# Census monthly retail trade report  
#------------------------------------------------

#-------------------------------
# Nominal food dollars 
#-------------------------------
#dt <- fread("raw_data/FoodDollarDataNominal.csv")
# This is not going to be helpful for my analysis unfortunately! 

# GARDENING DATASETS 
#--------------------------------------------------------------
# St. Louis Fed, advance retail sales for garden supply 
#--------------------------------------------------------------
dt <- fread("raw_data/RSBMGESD.csv")
names(dt) <- c('date', 'advance_retail_sales')

write.csv(dt, 'prepped_data/advance_sales_garden_supply_retailers.csv', row.names = F)
#--------------------------------------------------------------
# St. Louis Fed, retail sales for garden supply 
#--------------------------------------------------------------
dt <- fread("raw_data/MRTSSM444USN.csv")
names(dt) <- c('date', 'retail_sales')

write.csv(dt, 'prepped_data/sales_garden_supply_retailers.csv', row.names = F)

#--------------------------------------------------------------
# St. Louis Fed, personal consumption expenditure on 
# tools and equipment for house and garden
#--------------------------------------------------------------
dt <- fread("raw_data/DTOORC1A027NBEA.csv")
names(dt) <- c('date', 'expenditure_house_and_garden_tools')

write.csv(dt, "prepped_data/personal_exp_on_house_and_garden_tools.csv", row.names = F)

# PET ADOPTION DATASETS 
# All of these data were extracted from a Tableau dashboard using a python script. 
# That script can be found in the root of the repository.
#--------------------------------------------------------------
# Monthly live outcomes 
#--------------------------------------------------------------
dt <- fread("raw_data/shelter_animals_raw/monthly_live_outcome.csv")
dt <- dt[, c(5, 7, 8)]
names(dt) <- c('monthly_live_outcomes', 'year', 'month')

write.csv(dt, "prepped_data/monthly_shelter_live_outcomes.csv", row.names = F)
#--------------------------------------------------------------
# Monthly intake 
#--------------------------------------------------------------
dt <- fread("raw_data/shelter_animals_raw/monthly_intake.csv")
dt <- dt[, c(5, 7, 8)]
names(dt) <- c('monthly_shelter_intake', 'year', 'month')

write.csv(dt, 'prepped_data/monthly_shelter_intake.csv', row.names = F)
#--------------------------------------------------------------
# Shift by category 
#--------------------------------------------------------------

# COVID-19 DATASETS 
#--------------------------------------------------------------
# Confirmed cases 
#--------------------------------------------------------------
dt <- fread('raw_data/RAW_us_confirmed_cases.csv')

# Drop unnecessary columns 
dt = dt[, -c('Province_State', 'Admin2', 'UID', 'iso2', 'iso3', 
             'code3', 'FIPS', 'Lat', 'Long_', 'Combined_Key')]

# Reshape long 
dt = melt(dt, id.vars = 'Country_Region', value.name = 'confirmed_cases', variable.name = 'date')
stopifnot(nrow(dt[is.na(confirmed_cases)])==0) # Assert no NAs.
dt = dt[, .(confirmed_cases = sum(confirmed_cases)), by = 'date']

write.csv(dt, 'prepped_data/confirmed_cases.csv', row.names = F)
