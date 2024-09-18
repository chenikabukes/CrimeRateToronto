#### Preamble ####
# Purpose: Simulates data for the TTC’s Transport Bus Initiative Usage dataset to develop tests and validate the analysis process.
# Author: Chenika Bukes
# Date: 17/09/2024
# Contact: chenika.bukes@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `tidyverse` R package installed
# Any other information needed? This script creates a simulated dataset that mirrors the structure of the actual dataset to facilitate testing and validation.


#### Workspace setup ####
library(tidyverse)

#### Simulate data ####

# Define the number of days for the simulation period (e.g., 5 months from November 15, 2023, to April 15, 2024)
set.seed(123)  # For reproducibility
start_date <- as.Date("2023-11-15")
end_date <- as.Date("2024-04-15")
date_seq <- seq(start_date, end_date, by = "days")

# Define the number of clients per day using a Poisson distribution to simulate real-world variability
simulated_clients <- rpois(length(date_seq), lambda = 50)  # Average of 50 clients per day

# Define the proportion of clients transported vs. stationary
prop_transported <- 0.7  # Assume 70% are transported on average
prop_stationary <- 1 - prop_transported

# Generate the number of clients transported and stationary based on proportions
simulated_clients_transported <- rbinom(length(date_seq), size = simulated_clients, prob = prop_transported)
simulated_clients_stationary <- simulated_clients - simulated_clients_transported

# Combine into a simulated data frame
simulated_data <- tibble(
  Date = date_seq,
  Clients = simulated_clients,
  Clients_transported = simulated_clients_transported,
  Clients_stationary = simulated_clients_stationary
)

# Display the simulated data
print(simulated_data)

#### Data validation tests ####

# Test 1: Check that the total number of clients matches the sum of transported and stationary
test_total_clients <- all(simulated_data$Clients == (simulated_data$Clients_transported + simulated_data$Clients_stationary))
if (!test_total_clients) {
  stop("Test 1 failed: The total number of clients does not match the sum of transported and stationary clients.")
} else {
  message("Test 1 passed: The total number of clients matches the sum of transported and stationary clients.")
}

# Test 2: Check that all client counts are non-negative
test_non_negative <- all(simulated_data$Clients >= 0 & simulated_data$Clients_transported >= 0 & simulated_data$Clients_stationary >= 0)
if (!test_non_negative) {
  stop("Test 2 failed: There are negative values in the client counts.")
} else {
  message("Test 2 passed: All client counts are non-negative.")
}

# Test 3: Check that the proportion of transported clients is within a reasonable range (e.g., 50-90%)
simulated_proportion_transported <- mean(simulated_data$Clients_transported / simulated_data$Clients)
if (simulated_proportion_transported < 0.5 | simulated_proportion_transported > 0.9) {
  stop("Test 3 failed: The proportion of transported clients is outside the expected range.")
} else {
  message("Test 3 passed: The proportion of transported clients is within the expected range.")
}

# Save simulated data
write_csv(simulated_data, "./data/analysis_data/simulated_data.csv")



