library(tidycensus)
library(tidyverse)
library(dplyr)
census_api_key("baa4385d952532460bbc284b6763cf9d3fe75e31")

# In order to get the FIPS Code for Santa Barbara and Ventura Counties
data(fips_codes)
subset(fips_codes, county == "Santa Barbara County" | county == "Ventura County")
# Looks like SB County is 083 and Ventura County is 111

#Now if we want to get population by Census Tract in Santa Barbara and Ventura Counties
CensusPop <- get_acs(geography = "tract", variables = "B01003_001", state = "CA", county = c("083","111"))

# Write it to an excel file to analyze
write.csv(CensusPop, file = "SB-Ventura Census Tract Populations.csv")


# YOU NEED TO GET ONLY THE PUMA MARKET AREA TRACTS - maybe if we filter out by drive time?
