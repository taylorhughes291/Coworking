library(data.table)
library(bit64)
CensusLoc <- fread("https://www2.census.gov/geo/docs/maps-data/data/gazetteer/2017_Gazetteer/2017_gaz_tracts_06.txt")
head(CensusLoc)

# Now we have all the CA census tracts geographic location.
# Let's try and only select the census tracts we need for our two counties.
# We know that CA code is 06, SB county code is 083, and Ventura county code is 111.
# GEOID is structures as STATE+COUNTY+TRACT (number of digits SS-CCC-TTTTTT)
# Please note that fread() above got rid of the leading 0 of the state ID.
# Also note that all of the GEOIDs we need are included in the Data Frame CensusPop