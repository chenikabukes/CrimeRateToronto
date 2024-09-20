#### Preamble ####
# Purpose: Simulates crime rate trends using Poisson distribution for the bottom 10 and top 10 housing price neighborhoods over the years 2014 to 2023 and saves the corresponding line plot to analysis_data.
# Author: Chenika Bukes
# Date: 20 September 2024
# Contact: chenika.bukes@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - Installed `tidyverse` package

#### Workspace setup ####
library(tidyverse)

#### Simulate data ####

# Set seed for reproducibility
set.seed(888)

# Define the years for the simulation period (2014 to 2023)
years <- 2014:2023
n_years <- length(years)

# Create the grid of all combinations of neighborhoods and years
data_grid <- expand.grid(
  Neighborhood = c(rep("Bottom 10", 10), rep("Top 10", 10)),
  Year = years
)

# Simulate crime rates using Poisson distribution
# Bottom 10 neighborhoods will generally have higher crime rates (higher lambda)
# Top 10 neighborhoods will generally have lower crime rates (lower lambda)

# Introduce annual variation in lambda 
data_grid$Year_Index <- as.numeric(data_grid$Year) - min(as.numeric(data_grid$Year))  

data_grid$lambda <- ifelse(data_grid$Neighborhood == "Bottom 10",
                           50 + data_grid$Year_Index * 5,  # Bottom 10: Higher lambda with increasing trend
                           30 + data_grid$Year_Index * 3)  # Top 10: Lower lambda with smaller increase

# Simulate crime rates for each neighborhood per year using Poisson distribution
data_grid$Crime_Rate <- rpois(nrow(data_grid), lambda = data_grid$lambda)

# Save simulated data
write_csv(data_grid, "./data/analysis_data/simulated_crime_data.csv")

#### Plot the crime rate trends over time ####

# Aggregate data by year and neighborhood to calculate mean crime rates for each year
crime_trends <- data_grid %>%
  group_by(Year, Neighborhood) %>%
  summarise(Average_Crime_Rate = mean(Crime_Rate)) %>%
  ungroup()

# Plot the crime rate trends over the years
crime_plot <- ggplot(crime_trends, aes(x = Year, y = Average_Crime_Rate, color = Neighborhood)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  labs(title = "Crime Rate Trends Over Time (Simulated Using Poisson Distribution)",
       x = "Year",
       y = "Average Crime Rate (per 100,000)",
       color = "Neighborhood") +
  theme_minimal() +
  scale_color_manual(values = c("Bottom 10" = "red", "Top 10" = "blue"))

# Save the plot as a PNG file in the same folder as the simulated data
ggsave("./data/analysis_data/crime_rate_trends_plot.png", plot = crime_plot, width = 8, height = 6)
