#### Preamble ####
# Purpose: Cleans the raw housing data 
# Author: Chenika Bukes 
# Date: 20 September 2024 
# Contact: chenika.bukes@mail.utoronto.ca 
# License: MIT
# Pre-requisites: 
#   - Installed the `tidyverse` and `janitor` R packages
#   - Raw housing and crime data files saved as CSV or Excel
# Any other information needed? 
# This script processes and cleans both housing price and crime rate data for further analysis.

#### Workspace setup ####
library(tidyverse)
library(janitor)
library(readxl)

#### Clean data ####
# Read the third worksheet of the Excel file, which contains the housing data
raw_data_housing <- read_excel("./data/raw_data/wellbeing-toronto-housing.xlsx", sheet = 3)

# Cleaning steps:
housing_cleaned_data <- 
  raw_data_housing |> 
  janitor::clean_names() |> # Clean column names (makes them lower_snake_case)
  select(neighbourhood, neighbourhood_id, home_prices) |> # Select relevant columns
  mutate(
    # Clean and convert "home_prices" to numeric if needed
    home_prices = as.numeric(gsub(",", "", home_prices)) # Remove commas and convert to numeric
  ) |> 
  # If any neighborhood has invalid/missing home price, remove the row
  drop_na(home_prices) |> 
  filter(home_prices > 0) |>  
  rename(
    neighbourhood_name = neighbourhood, 
    neighbourhood_code = neighbourhood_id,
    price = home_prices
  )

#### Save cleaned housing data ####
write_csv(housing_cleaned_data, "./data/clean_data/housing_cleaned_data.csv")

#### Clean crime statistics data ####
# Read the crime data CSV
raw_data_crime <- read_csv("./data/raw_data/crime_raw_data.csv")

# Cleaning steps for crime data:
crime_cleaned_data <- raw_data_crime %>%
  janitor::clean_names() %>%
  # Select neighborhood ID and crime rate columns
  select("hood_id", starts_with("assault_rate"), starts_with("autotheft_rate"),
         starts_with("biketheft_rate"), starts_with("breakenter_rate"),
         starts_with("homicide_rate"), starts_with("robbery_rate"),
         starts_with("shooting_rate"), starts_with("theftfrommv_rate"),
         starts_with("theftover_rate")) %>%
  # Pivot to long format to extract year and crime type
  pivot_longer(
    cols = -hood_id,  # Keep neighborhood ID intact
    names_to = "crime_year",  # Combine crime type and year
    values_to = "rate"        # Values are the crime rates
  ) %>%
  # Separate the 'crime_year' column into 'crime' and 'year'
  separate(crime_year, into = c("crime", "year"), sep = "_rate_") %>%
  # Convert year to numeric 
  mutate(year = as.numeric(year))

#### Save cleaned crime data ####
write_csv(crime_cleaned_data, "./data/clean_data/crime_cleaned_data.csv")

