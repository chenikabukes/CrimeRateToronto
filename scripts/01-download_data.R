#### Preamble ####
# Purpose: Downloads and saves the data from the TTC's Transport Bus Initiative Usage dataset on Open Data Toronto
# Author: Chenika Bukes
# Date: 17/09/2024
# Contact: chenika.bukes@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
#   - Access to the Open Data Toronto API
#   - The `opendatatoronto` and `tidyverse` R packages installed
#   - An internet connection to download the data
# Any other information needed? This script downloads data for the Transport Bus Initiative Usage dataset from Open Data Toronto and saves it as a CSV file for further analysis.


#### Workspace setup ####
library(opendatatoronto)
library(tidyverse)

#### Download data ####
# Get the package information for the Transport Bus Initiative Usage dataset
package <- show_package("transport-bus-initiative-usage")  # Update this with the correct package ID
package

# Get all resources for this package
resources <- list_package_resources("transport-bus-initiative-usage")  # Update this with the correct package ID

# Identify datastore resources; by default, Toronto Open Data sets datastore resource format to CSV for non-geospatial and GeoJSON for geospatial resources
datastore_resources <- filter(resources, tolower(format) %in% c('csv', 'geojson'))

# Load the first datastore resource as a sample
the_raw_data <- filter(datastore_resources, row_number() == 1) %>% get_resource()
the_raw_data

#### Save data ####
write_csv(the_raw_data, "./data/raw_data/raw_data.csv") 

         
