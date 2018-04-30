setwd("/Users/applemac/Documents/Coworking Space/Data/Starting Point Files")
Census <- read.csv("ss16pca.csv")

# Now we must select only the entries that are within our market areas, which include South Coast Santa Barbara, Ventura City, Oxnard/Port Hueneme, and we'll throw in Camarillo/Moorpark as well.
MarketCensus <- Census[Census$PUMA == 08303 | Census$PUMA == 11104 | Census$PUMA == 11103 | Census$PUMA == 11106, ]
write.csv(MarketCensus, file = "PUMS Data SB-Ventura County Market Areas")

# Now you have the file in Excel in the case you want to analyze in that format.

#-----------------------------

# In order to get more granular census tract data
library(tidycensus)
library(tidyverse)
library(dplyr)
census_api_key("baa4385d952532460bbc284b6763cf9d3fe75e31")

# In order to get the FIPS Code for Santa Barbara and Ventura Counties
data(fips_codes)
subset(fips_codes, county == "Santa Barbara County" | county == "Ventura County")
# Looks like SB County is 083 and Ventura County is 111

#Now if we want to get population by Census Tract in Santa Barbara and Ventura Counties
CensusPop <- get_acs(geography = "tract", 
                     variables = "B01003_001", 
                     state = "CA", 
                     county = c("083","111"))
names(CensusPop)[names(CensusPop) == "estimate"] <- "Population"



# YOU NEED TO GET ONLY THE PUMA MARKET AREA TRACTS - This does not seem possible, however
# we will attempt to filter out by drive time to get a good enough estimate.


#-------------------------------

# In order to get the latitude and longitude of the census tracts
library(data.table)
library(bit64)
CensusLoc <- fread("https://www2.census.gov/geo/docs/maps-data/data/gazetteer/2017_Gazetteer/2017_gaz_tracts_06.txt")
CensusLoc$GEOID <- as.character(CensusLoc$GEOID)
CensusLoc$GEOID <- paste("0", CensusLoc$GEOID, sep = "")
head(CensusLoc)

# Now we have all the CA census tracts geographic location.
# Let's try and only select the census tracts we need for our two counties.
# We know that CA code is 06, SB county code is 083, and Ventura county code is 111.
# GEOID is structures as STATE+COUNTY+TRACT (number of digits SS-CCC-TTTTTT)
# Please note that fread() above got rid of the leading 0 of the state ID.
# Also note that all of the GEOIDs we need are included in the Data Frame CensusPop
# Let's try and join up the census population data and the census locations, knowing that
# all the GEOIDs we want are in CensusPop. Merge will only show the matches so it 
# should work well.

CensusPop <- merge(x = CensusPop, y = CensusLoc, by = "GEOID")

# Note that Google Maps API requires LAT-LONG format.
CensusPop$GoogleInput <- paste(CensusPop$INTPTLAT, CensusPop$INTPTLONG, sep = "+")

# Drop unnecessary columns
CensusPop <- subset(CensusPop, select = -c(variable, USPS, ALAND, AWATER))

#-----------------------------------

# We can now get the travel time to Carpinteria per census tract using Google Maps API
# for car, public transport, and bike. Please note that since there is a 
# limit of 2,500 calls to Google Maps API per day, you may have problems with this in
# larger market areas. Make sure you have install.packages(gmapsdistance) and you have
# registered for a Google Maps API Key at https://developers.google.com/maps/documentation/distance-matrix/get-api-key#key
# Then make sure you run the command set.api.key("YOUR KEY HERE") 

library(gmapsdistance)
tomorrow <- as.character(Sys.Date() + 1)
DriveTime <- gmapsdistance(origin = CensusPop$GoogleInput, 
                                     destination = "410+Palm+Ave,+Carpinteria,+CA+93013",
                                     mode = "driving",
                                     arr_date = tomorrow,
                                     arr_time = "17:00:00")

BikeTime <- gmapsdistance(origin = CensusPop$GoogleInput, 
                                    destination = "410+Palm+Ave,+Carpinteria,+CA+93013",
                                    mode = "bicycling",
                                    key = "AIzaSyAT1wxOfPoPZowF2lPliMGA884ArKVQ7XU",
                                    arr_date = tomorrow,
                                    arr_time = "17:00:00")

TransitTime <- gmapsdistance(origin = CensusPop$GoogleInput, 
                                    destination = "410+Palm+Ave,+Carpinteria,+CA+93013",
                                    mode = "transit",
                                    key = "AIzaSyAT1wxOfPoPZowF2lPliMGA884ArKVQ7XU",
                                    arr_date = tomorrow,
                                    arr_time = "17:00:00")

# DriveTime is a list with three data frames (Time, Distance, Status). Let's get Time over
# to the CensusPop Data Frame as DrivingTime variable.

DriveTime$Time$or <- as.character(DriveTime$Time$or)
names(DriveTime$Time) <- c("GoogleInput", "DrivingTime")
CensusPop <- merge(x = CensusPop, y = DriveTime$Time, by = "GoogleInput")

BikeTime$Time$or <- as.character(BikeTime$Time$or)
names(BikeTime$Time) <- c("GoogleInput", "BikingTime")
CensusPop <- merge(x = CensusPop, y = BikeTime$Time, by = "GoogleInput")

TransitTime$Time$or <- as.character(TransitTime$Time$or)
names(TransitTime$Time) <- c("GoogleInput", "TransitTime")
CensusPop <- merge(x = CensusPop, y = TransitTime$Time, by = "GoogleInput")

# Write it to an excel file to analyze
write.csv(CensusPop, file = "SB-Ventura Census Tract Populations.csv")
# Looks like there are some NAs in DriveTime and BikeTime, but there are really a lot
# of NAs in TransitTime. Let's try to open a few of these NAs and see if there's a 
# reason for this. Please make sure you have package "ggmap" installed.

library(ggmap)
get_map(location = c(lon = CensusPop$INTPTLAT, lat = CensusPop$INTPTLONG))