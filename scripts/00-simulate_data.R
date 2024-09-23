#### Preamble ####
# Purpose: Simulates crime rate trends using Poisson distribution for the bottom 10 and top 10 housing price neighborhoods over the years 2014 to 2023 and saves the corresponding line plot to analysis_data.
# Author: Chenika Bukes
# Date: 24 September 2024
# Contact: chenika.bukes@mail.utoronto.ca
# License: MIT
# Pre-requisites:
# - Installed `tidyverse` and `purrr` packages

#### Workspace setup ####
library(tidyverse)
library(purrr)

#### Simulate Data ####
set.seed(888) 

# Number of years and crime types
years <- 2014:2023
n_years <- length(years)
crime_types <- c("assault", "autotheft", "biketheft", "breakenter", "homicide", "robbery", "shooting", "theftfrommv", "theftover")
n_crime_types <- length(crime_types)

# Simulate house prices for top 10 and bottom 10 neighborhoods
n_neighborhoods <- 10

# Average house prices for top 10 and bottom 10
top_10_avg_price <- 1500000
bottom_10_avg_price <- 400000

# Simulate house prices with some noise
top_10_prices <- rnorm(n_neighborhoods, mean = top_10_avg_price, sd = 100000)
bottom_10_prices <- rnorm(n_neighborhoods, mean = bottom_10_avg_price, sd = 50000)

# Create data frame for house prices
house_prices <- data.frame(
  Neighborhood = c(paste0("Top_", 1:10), paste0("Bottom_", 1:10)),
  Price = c(top_10_prices, bottom_10_prices),
  Group = rep(c("Top 10", "Bottom 10"), each = n_neighborhoods)
)

# Simulate crime rates for each neighborhood, crime type, and year
crime_rates <- expand.grid(
  Neighborhood = c(paste0("Top_", 1:10), paste0("Bottom_", 1:10)),
  Crime_Type = crime_types,
  Year = years
)

# Add the Group based on the Neighborhood
crime_rates$Group <- ifelse(grepl("Top_", crime_rates$Neighborhood), "Top 10", "Bottom 10")

# Simulate the crime rates for each row
crime_rates$Rate <- pmap_int(list(crime_rates$Crime_Type, crime_rates$Group), simulate_crime_rate)

# Merge the house prices with crime rates
simulation_data <- crime_rates %>%
  left_join(house_prices, by = c("Neighborhood", "Group"))

# Save the simulated crime data to a CSV file
write.csv(simulation_data, "data/analysis_data/simulated_crime_data.csv", row.names = FALSE)



