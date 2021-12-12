library(ggplot2)
library(data.table)
library(stargazer)

setwd("~/Desktop/data-512-a4-data/prepped_data")

#--------------------------------------------
# Baking graphics 
#--------------------------------------------

consumer_prices <- fread("consumer_price_indices_2019_2020.csv", header = TRUE)

# These global lists are used throughout the analysis. 
BAKING_CATEGORIES = c('Eggs', 'Dairy products', 'Cereals and bakery products')
AGGREGATE_CATEGORIES = c("All food", "Food away from home", "Food at home", 
                         "Meats, poultry and fish", "Fruits and vegetables")

# Plot 1 - how did baking products (dairy products and cereals and bakery products)
# change in price from 2019 to 2020? 
plot_data = copy(consumer_prices)
plot_data = plot_data[, .(item, annual_2020_percent_change)]
plot_data = melt(plot_data, id.vars = 'item', variable.name = 'year')
plot_data[grepl("2020", year), year:="2020"]

# Comparing change in category; highlighting baking categories 
plot_data = copy(consumer_prices)
plot_data = plot_data[, .(item, annual_2020_percent_change, historical_average)]

plot_data[item %in% BAKING_CATEGORIES, is_baking_category:=TRUE]

ggplot(plot_data, aes(x = item, y = annual_2020_percent_change, fill= is_baking_category)) + 
  geom_bar(stat = 'identity') + 
  theme_bw() + 
  theme(legend.position = "none") + 
  coord_flip() + 
  labs(title = "Change in consumer price index from 2019 to 2020", subtitle = "Baking categories highlighted in red",
       x = "Category", y = "Change in percentage points")

ggsave("../pngs/change_in_cpi_baking_highlighted.png")


# Show change versus historical average 
plot_data[, hist_avg_diff:=annual_2020_percent_change-historical_average]

ggplot(plot_data, aes(x = item, y = hist_avg_diff, fill= is_baking_category)) + 
  geom_bar(stat = 'identity') + 
  theme_bw() + 
  theme(legend.position = "none") + 
  coord_flip() + 
  labs(title = "2020 Percentage point increase from historical average", subtitle = "Baking categories highlighted in red",
       x = "Category", y = "Change in percentage points")

ggsave("../pngs/change_from_historical_average.png")

# How much did all baking categories change vs. all non-baking categories? 
plot_data[, mean(change_from_2019_to_2020), by = 'is_baking_category']


# Now look at historical pricing data, from 1974 to 2020. 
consumer_prices <- fread("consumer_price_indices_1974_2020.csv", header = TRUE)

# Make a time series plot of the data 
plot_data = copy(consumer_prices)
plot_data = plot_data[!item %in% AGGREGATE_CATEGORIES] 
plot_data = melt(plot_data, id.vars = 'item', variable.name = 'year')
plot_data[item %in% BAKING_CATEGORIES, is_baking_category:=TRUE]
plot_data[is.na(is_baking_category), is_baking_category:=FALSE]

# Collapse 
plot_data$value <- as.numeric(plot_data$value) # Some NAs created for processed fruits and vegetables before 1998
plot_data[, year:=paste0(year, "-01-01")]
plot_data$year <- as.Date(plot_data$year)
plot_data = plot_data[, .(value=sum(value, na.rm = TRUE)), by = c('year', 'is_baking_category')]

ggplot(plot_data, aes(x = year, y = value, group = is_baking_category, color = is_baking_category)) + 
  geom_line() + 
  theme_bw() + 
  labs(title = "Annual percentage change in select consumer price indices", x = "Year", y = "Annual percent change",
       color = "Baking CPI")

ggsave("../pngs/cpi_time_series.png")


#---------------------------------------
# Gardening 
#---------------------------------------

# Advance retail sales 
advance_retail_sales = fread("advance_sales_garden_supply_retailers.csv")

# First, make a general time series plot 
plot_data = copy(advance_retail_sales)
plot_data$date <- as.Date(plot_data$date)

ggplot(plot_data, aes(x = date, y = advance_retail_sales)) + 
  geom_line(color = "orange") + 
  theme_bw() + 
  scale_y_continuous(labels = scales::dollar) + 
  labs(title = "Advance retail sales from building materials/garden supply stores, 1992 - 2021", 
       x = "Year", y = "$ Sales")

ggsave("../pngs/gardening_retail_sales_ts_1992_2021.png")

# Now zoom in on 2019 - 2021
ggplot(plot_data[date >= "2019-01-01" & date <= "2021-12-01"], aes(x = date, y = advance_retail_sales)) + 
  geom_line(color = "orange") + 
  theme_bw() + 
  scale_y_continuous(labels = scales::dollar) + 
  labs(title = "Advance retail sales from building materials/garden supply stores, 2019 - 2021", 
       x = "Year", y = "$ Sales")

ggsave("../pngs/gardening_retail_sales_ts_2019_2021.png")

# Covariance analysis with COVID-19 cases
cases = fread('confirmed_cases.csv')
cases$date <- as.Date(cases$date, "%m/%d/%y")

plot_data = merge(advance_retail_sales, cases, by = 'date')

model = lm(advance_retail_sales ~ confirmed_cases, data = plot_data)
summary(model) 

stargazer(model, type = "html", out = "../pngs/model_fit_gardening.html")

# Calculate covariance 
# Super high!!
cov(plot_data$advance_retail_sales, plot_data$confirmed_cases)

# Show this relationship 
ggplot(plot_data, aes(x = confirmed_cases, y = advance_retail_sales)) + 
  geom_point() + 
  stat_smooth(method = "lm") + 
  theme_bw() + 
  scale_y_continuous(labels = scales::dollar) + 
  labs(title = "Relationship between US cases and advance sales of garden supplies", 
       subtitle = "Data represent Feb. 2020 - Sep. 2021", x = "Confirmed cases", y = "Advance sales ($)") 

ggsave("../pngs/covariance_cases_garden_retail_sales.png")


#---------------------------------------
# Animal adoptions
#---------------------------------------

monthly_shelter_intake = fread('monthly_shelter_intake.csv')

plot_data = copy(monthly_shelter_intake) 
plot_data[, month:=tstrsplit(month, " ", keep = 1)]
plot_data[, date:=paste0(month, " 01, ", year)]

plot_data$date <- as.Date(plot_data$date, format = "%b %d, %Y")
plot_data = plot_data[, .(monthly_shelter_intake, date)]


# Shelter intake time series 
ggplot(plot_data, aes(x = date, y = monthly_shelter_intake)) + 
  geom_line() + 
  theme_bw() + 
  labs(title = "Monthly shelter intake", subtitle = "Data available from January 2019 - December 2020",
       x = "Date", y = "Monthly shelter intake")

ggsave("../pngs/shelter_intake_ts.png")

# Shelter intake, only for months that overlap with case data 
ggplot(plot_data[date >= "2020-02-01" & date <= "2020-12-01"], aes(x = date, y = monthly_shelter_intake)) + 
  geom_line() + 
  theme_bw() + 
  labs(title = "Monthly shelter intake", subtitle = "Data available from January 2019 - December 2020",
       x = "Date", y = "Monthly shelter intake")

# Regression with COVID-19 cases and monthly shelter intake 
cases = fread('confirmed_cases.csv')
cases$date <- as.Date(cases$date, "%m/%d/%y")

plot_data = merge(plot_data, cases, by = 'date')

model = lm(monthly_shelter_intake ~ confirmed_cases, data = plot_data)
summary(model) 

stargazer(model, type = "html", out = "../pngs/model_fit_shelter_intake.html")

# Live outcomes 
live_outcomes = fread('monthly_shelter_live_outcomes.csv')

plot_data = copy(live_outcomes) 
plot_data[, month:=tstrsplit(month, " ", keep = 1)]
plot_data[, date:=paste0(month, " 01, ", year)]

plot_data$date <- as.Date(plot_data$date, format = "%b %d, %Y")
plot_data = plot_data[, .(monthly_live_outcomes, date)]

# Live outcomes TS
ggplot(plot_data, aes(x = date, y = monthly_live_outcomes)) + 
  geom_line() + 
  theme_bw() + 
  labs(title = "Monthly live outcomes", subtitle = "Data available from February 2020 - December 2020",
       x = "Date", y = "Monthly live outcomes")

ggsave("../pngs/shelter_intake_ts.png")
