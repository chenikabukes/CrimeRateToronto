#### Preamble ####
# Purpose: Cleans the raw housing and crime data and adds 'Group' classification for neighborhoods.
# Author: Chenika Bukes
# Date: 24 September 2024
# Contact: chenika.bukes@mail.utoronto.ca
# License: MIT
# Pre-requisites:
# - Installed `tidyverse` and `janitor` R packages
# - Raw housing and crime data files saved as CSV or Excel

#### Workspace setup ####
library(tidyverse)
library(janitor)
library(readxl)

#### Clean housing data ####
# Read the third worksheet of the Excel file, which contains the housing data
raw_data_housing <- read_excel("./data/raw_data/wellbeing-toronto-housing.xlsx", sheet = 3)

# Cleaning steps:
housing_cleaned_data <- 
  raw_data_housing %>%
  janitor::clean_names() %>%
  select(neighbourhood, neighbourhood_id, home_prices) %>%
  mutate(
    home_prices = as.numeric(gsub(",", "", home_prices)) # Remove commas and convert to numeric
  ) %>%
  drop_na(home_prices) %>%
  filter(home_prices > 0) %>%
  rename(
    neighbourhood_name = neighbourhood,
    neighbourhood_code = neighbourhood_id,
    price = home_prices
  )

# Get the top 10 and bottom 10 neighborhoods based on home prices
top_10 <- housing_cleaned_data %>%
  arrange(desc(price)) %>%
  slice(1:10) %>%
  mutate(Group = "Top 10")

bottom_10 <- housing_cleaned_data %>%
  arrange(price) %>%
  slice(1:10) %>%
  mutate(Group = "Bottom 10")

# Combine the top and bottom 10 neighborhoods into one dataset
housing_cleaned_data <- bind_rows(top_10, bottom_10)

# Save cleaned housing data
write_csv(housing_cleaned_data, "./data/clean_data/housing_cleaned_data.csv")

#### Clean crime statistics data ####
# Read the crime data CSV
raw_data_crime <- read_csv("./data/raw_data/crime_raw_data.csv")

# Cleaning steps for crime data:
crime_cleaned_data <- 
  raw_data_crime %>%
  janitor::clean_names() %>%
  # Select neighborhood ID and crime rate columns
  select(
    hood_id, starts_with("assault_rate"), starts_with("autotheft_rate"),
    starts_with("biketheft_rate"), starts_with("breakenter_rate"),
    starts_with("homicide_rate"), starts_with("robbery_rate"),
    starts_with("shooting_rate"), starts_with("theftfrommv_rate"),
    starts_with("theftover_rate")
  ) %>%
  pivot_longer(
    cols = -hood_id, # Keep neighborhood ID intact
    names_to = "crime_year", # Combine crime type and year
    values_to = "rate" # Values are the crime rates
  ) %>%
  # Separate the 'crime_year' column into 'crime' and 'year'
  separate(crime_year, into = c("crime", "year"), sep = "_rate_") %>%
  mutate(year = as.numeric(year))

# Save cleaned crime data
write_csv(crime_cleaned_data, "./data/clean_data/crime_cleaned_data.csv")


#### Data validation tests ####

# Test 1: Check that housing prices are numeric 
test_price_numeric_cleaned <- is.numeric(housing_cleaned_data$price)
if (!test_price_numeric_cleaned) {
  stop("Test 1 failed: Housing prices are not numeric.")
} else {
  message("Test 1 passed: Housing prices are numeric.")
}

# Test 2: Check that housing prices are numeric within a reasonable range (domain knowledge)
test_price_range_cleaned <- all(housing_cleaned_data$price > 0 & housing_cleaned_data$price < 10000000)
if (!test_price_range_cleaned) {
  stop("Test 2 failed: Housing prices are outside the reasonable range.")
} else {
  message("Test 2 passed: Housing prices are within the expected range.")
}


# Test 3: Check that the crime rates are non-negative in the cleaned crime data
test_non_negative_crime_cleaned <- all(crime_cleaned_data$rate >= 0, na.rm = TRUE)
if (!test_non_negative_crime_cleaned) {
  stop("Test 3 failed: Some crime rates are negative in the cleaned data.")
} else {
  message("Test 3 passed: All crime rates are non-negative.")
}


# Test 4: Ensure that the years are within the expected range (2014-2023)
test_year_range_cleaned <- all(crime_cleaned_data$year >= 2014 & crime_cleaned_data$year <= 2023)
if (!test_year_range_cleaned) {
  stop("Test 4 failed: Some Year values are outside the expected range (2014-2023).")
} else {
  message("Test 4 passed: All Year values are within the range 2014-2023.")
}

# Test 5: Validate that crime types are properly categorized (expected crime types)
expected_crime_types <- c("assault", "autotheft", "biketheft", "breakenter", "homicide", "robbery", "shooting", "theftfrommv", "theftover")
valid_crime_types <- all(crime_cleaned_data$crime %in% expected_crime_types)
if (!valid_crime_types) {
  stop("Test 5 failed: There are unexpected crime types in the cleaned data.")
} else {
  message("Test 5 passed: All crime types are as expected.")
}

# Test 6: Validate that the Group variable in housing data contains only "Top 10" and "Bottom 10"
valid_groups_cleaned <- all(housing_cleaned_data$Group %in% c("Top 10", "Bottom 10"))
if (!valid_groups_cleaned) {
  stop("Test 6 failed: Group contains values other than 'Top 10' and 'Bottom 10'.")
} else {
  message("Test 6 passed: Group contains only 'Top 10' and 'Bottom 10'.")
}

# Test 7: Ensure the average crime rates are higher for Bottom 10 neighborhoods than Top 10 neighborhoods
average_crime_rates <- crime_cleaned_data %>%
  inner_join(housing_cleaned_data, by = c("hood_id" = "neighbourhood_code")) %>%
  group_by(Group) %>%
  summarise(average_rate = mean(rate, na.rm = TRUE))

bottom_10_avg <- average_crime_rates %>%
  filter(Group == "Bottom 10") %>%
  pull(average_rate)

top_10_avg <- average_crime_rates %>%
  filter(Group == "Top 10") %>%
  pull(average_rate)

test_higher_bottom_10 <- bottom_10_avg > top_10_avg
if (!test_higher_bottom_10) {
  stop("Test 7 failed: Bottom 10 neighborhoods do not have consistently higher average crime rates than Top 10 neighborhoods.")
} else {
  message("Test 7 passed: Bottom 10 neighborhoods have consistently higher average crime rates than Top 10 neighborhoods.")
}

