CPType <- sapply(CensusPop, class)
CPType <- as.vector(CPType)
CensusPop <- read.table(file = "SB-Ventura Census Tract Populations.txt", header = TRUE, colClasses = CPType)
CensusPop$MapSearchURL <- paste("https://www.google.com/maps/search/?api=1&query=", CensusPop$GoogleInput, sep = "")
# Now let's get the observations down to within an hour driving time in traffic of Carpinteria

# Looks like there are some NAs in DriveTime and BikeTime, but there are really a lot
# of NAs in TransitTime. Let's try to open a few of these NAs and see if there's a 
# reason for this. Please make sure you have package "ggmap" installed.

NoRouteDrive <- CensusPop[is.na(CensusPop$DrivingTime),]
NoRouteDrive
for(i in 1: length(NoRouteDrive$MapSearchURL)) {
  browseURL(NoRouteDrive[i, "MapSearchURL"])
}

NoRouteBike <- CensusPop[is.na(CensusPop$BikingTime),]
NoRouteBike
for(i in 1: length(NoRouteBike$MapSearchURL)) {
  browseURL(NoRouteBike[i, "MapSearchURL"])
}

NoRouteTransit <- CensusPop[is.na(CensusPop$TransitTime),]
NoRouteTransit
for(i in 1: length(NoRouteTransit$MapSearchURL)) {
  browseURL(NoRouteTransit[i, "MapSearchURL"])
}

# Driving: Immediately for rows 2 and 4 we can see that there is only water in this census tract... My guess is that 
# these tracts cover the Channel Islands and the surrounding waters. Upon Google searching these tracts, the 
# first 5 are indeed the Channel Islands (which I assume nobody will be commuting from) and the final two are
# large rural swaths far from Carpinteria that I am comfortable with excluding from analysis.

# Biking: non-existent bike routes are a subset of the non-existent Drive routes so I am comfortable with their
# exclusion.

# Transit: No lie, there are a lot of non-existent routes for transit lines. Moving straight down into the SB 
# County non-existent routes, we already see that the first NA route in the census tract right next to Carp which
# is problematic. Upon further inspection, I am KIND OF comfortable with this since all of these areas 
# are in the hills for the most parts, with some population centers bleeding into the edge right before
# the foothills, and how many people are really taking the bus to the coworking space from a rural area?

