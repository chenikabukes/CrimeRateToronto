#### Preamble ####
# Purpose: Test and validate the simulated crime rate data.
# Author: Chenika Bukes
# Date: 20 September 2024
# Contact: chenika.bukes@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - Installed `tidyverse` package

#### Workspace setup ####
library(tidyverse)

#### Load the simulated data ####
simulated_data <- read_csv("./data/analysis_data/simulated_crime_data.csv")

#### Data validation tests ####

# Test 1: Check that the crime rates are within a reasonable range (0 to 100)
test_crime_rate_range <- all(simulated_data$Crime_Rate >= 0 & simulated_data$Crime_Rate <= 10000)
if (!test_crime_rate_range) {
  stop("Test 1 failed: Crime rates are outside the expected range (0-100).")
} else {
  message("Test 1 passed: Crime rates are within the expected range.")
}

# Test 2: Check that there are no negative crime rates
test_non_negative_crime <- all(simulated_data$Crime_Rate >= 0)
if (!test_non_negative_crime) {
  stop("Test 2 failed: There are negative crime rates in the data.")
} else {
  message("Test 2 passed: All crime rates are non-negative.")
}

# Test 3: Check that average crime rates are consistently higher for Bottom 10 neighborhoods compared to Top 10
average_crime_rates <- simulated_data %>%
  group_by(Neighborhood) %>%
  summarise(Average_Crime_Rate = mean(Crime_Rate))

bottom_10_avg <- average_crime_rates %>%
  filter(Neighborhood == "Bottom 10") %>%
  summarise(Bottom_10_Avg_Crime = mean(Average_Crime_Rate))

top_10_avg <- average_crime_rates %>%
  filter(Neighborhood == "Top 10") %>%
  summarise(Top_10_Avg_Crime = mean(Average_Crime_Rate))

test_higher_bottom_10 <- bottom_10_avg$Bottom_10_Avg_Crime > top_10_avg$Top_10_Avg_Crime

if (!test_higher_bottom_10) {
  stop("Test 3 failed: Bottom 10 neighborhoods do not have consistently higher average crime rates than Top 10 neighborhoods.")
} else {
  message("Test 3 passed: Bottom 10 neighborhoods have consistently higher average crime rates than Top 10 neighborhoods.")
}

