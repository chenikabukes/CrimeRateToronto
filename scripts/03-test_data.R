#### Preamble ####
# Purpose: Test and validate the simulated crime rate and home price data.
# Author: Chenika Bukes
# Date: 24 September 2024
# Contact: chenika.bukes@mail.utoronto.ca
# License: MIT
# Pre-requisites:
# - Installed `tidyverse` package

#### Workspace setup ####
library(tidyverse)

#### Load the simulated data ####
simulated_data <- read_csv("./data/analysis_data/simulated_crime_data.csv")

#### Data validation tests ####

# Test 1: Check that the crime rates are within a reasonable range for Toronto (0 to 1000, as per simulation)
test_crime_rate_range <- all(simulated_data$Rate >= 0 & simulated_data$Rate <= 1000)
if (!test_crime_rate_range) {
  stop("Test 1 failed: Crime rates are outside the expected range (0-1000).")
} else {
  message("Test 1 passed: Crime rates are within the expected range.")
}

# Test 2: Check that there are no negative crime rates
test_non_negative_crime <- all(simulated_data$Rate >= 0)
if (!test_non_negative_crime) {
  stop("Test 2 failed: There are negative crime rates in the data.")
} else {
  message("Test 2 passed: All crime rates are non-negative.")
}

# Test 3: Check that average crime rates are consistently higher for Bottom 10 neighborhoods compared to Top 10
# as per hypothesis
average_crime_rates <- simulated_data %>%
  group_by(Group) %>%
  summarise(Average_Crime_Rate = mean(Rate))

bottom_10_avg <- average_crime_rates %>%
  filter(Group == "Bottom 10") %>%
  summarise(Bottom_10_Avg_Crime = mean(Average_Crime_Rate))

top_10_avg <- average_crime_rates %>%
  filter(Group == "Top 10") %>%
  summarise(Top_10_Avg_Crime = mean(Average_Crime_Rate))

test_higher_bottom_10 <- bottom_10_avg$Bottom_10_Avg_Crime > top_10_avg$Top_10_Avg_Crime

if (!test_higher_bottom_10) {
  stop("Test 3 failed: Bottom 10 neighborhoods do not have consistently higher average crime rates than Top 10 neighborhoods.")
} else {
  message("Test 3 passed: Bottom 10 neighborhoods have consistently higher average crime rates than Top 10 neighborhoods.")
}

# Test 4: Ensure that the Neighborhood variable is a character and does not contain numbers
test_neighborhood_type <- is.character(simulated_data$Neighborhood)
if (!test_neighborhood_type) {
  stop("Test 4 failed: Neighborhood is not a character variable.")
} else {
  message("Test 4 passed: Neighborhood is a character variable.")
}

# Test 5: Ensure that the Price variable is numeric, without any currency symbols or commas
test_price_numeric <- is.numeric(simulated_data$Price)
if (!test_price_numeric) {
  stop("Test 5 failed: Price is not numeric.")
} else {
  message("Test 5 passed: Price is numeric.")
}

# Test 6: Check that there are no missing values in the dataset
test_no_missing_values <- all(!is.na(simulated_data))
if (!test_no_missing_values) {
  stop("Test 6 failed: There are missing values in the data.")
} else {
  message("Test 6 passed: There are no missing values in the data.")
}

# Test 7: Validate that the number of rows in the dataset matches the expected number of observations
# The number of neighborhoods (20 groups) * (9 Crime Types) * (10 Years) = 1800 rows
expected_rows <- 20 * 9 * 10
actual_rows <- nrow(simulated_data)

if (actual_rows != expected_rows) {
  stop(paste("Test 7 failed: The number of rows in the dataset does not match the expected number of observations. Expected:", expected_rows, "Actual:", actual_rows))
} else {
  message("Test 7 passed: The number of rows in the dataset matches the expected number of observations.")
}

# Test 8: Ensure that the years are within the correct range (2014 to 2023)
test_year_range <- all(simulated_data$Year >= 2014 & simulated_data$Year <= 2023)
if (!test_year_range) {
  stop("Test 8 failed: Some Year values are outside the range 2014-2023.")
} else {
  message("Test 8 passed: All Year values are within the range 2014-2023.")
}

# Test 9: Validate that the Group variable contains only "Top 10" and "Bottom 10"
valid_groups <- all(simulated_data$Group %in% c("Top 10", "Bottom 10"))
if (!valid_groups) {
  stop("Test 9 failed: Group contains values other than 'Top 10' and 'Bottom 10'.")
} else {
  message("Test 9 passed: Group contains only 'Top 10' and 'Bottom 10'.")
}

