#### Preamble ####
# Purpose: Downloads and saves the data from the Neighbourhood Crime Rates dataset on Open Data Toronto
# Author: Chenika Bukes
# Date: 20 September 2024
# Contact: chenika.bukes@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
#   - Installed the `opendatatoronto` and `tidyverse` packages
#   - An internet connection with live Open Data Toronto api to download the data
# Any other information needed? 
#   - This script downloads data for the Neighborhood Crime Rates dataset from Open Data Toronto and saves it as a CSV file for further analysis.
#   - The housing price data was downloaded directly from the site as an excel file. 

#### Workspace setup ####
library(opendatatoronto)
library(tidyverse)

#### Download Crime Statstic Data for each Neighborhood ####
# Get the package information for the Neighborhood Crime Rates
package <- show_package("neighbourhood-crime-rates")  
package

# Get all resources for this package
resources <- list_package_resources("neighbourhood-crime-rates")  

# Identify datastore resources; by default, Toronto Open Data sets datastore resource format to CSV for non-geospatial and GeoJSON for geospatial resources
datastore_resources <- filter(resources, tolower(format) %in% c('csv', 'geojson'))

# Load the first datastore resource as a sample
the_raw_data <- filter(datastore_resources, row_number() == 1) %>% get_resource()
the_raw_data

#### Save data ####
write_csv(the_raw_data, "./data/raw_data/crime_raw_data.csv") 

         


