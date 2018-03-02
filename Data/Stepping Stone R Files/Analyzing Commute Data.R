CensusPop <- read.csv(file = "SB-Ventura Census Tract Populations.csv")

# Now let's get the observations down to within an hour driving time in traffic of Carpinteria
CensusPop <- CensusPop[CensusPop$DrivingTime <= 3600 | is.na(CensusPop$DrivingTime),]

# Looks like there are some NAs in DriveTime and BikeTime, but there are really a lot
# of NAs in TransitTime. Let's try to open a few of these NAs and see if there's a 
# reason for this. Please make sure you have package "ggmap" installed.

NoRouteDrive <- CensusPop[is.na(CensusPop$DrivingTime),]
NoRouteDrive

NoRouteBike <- CensusPop[is.na(CensusPop$BikingTime),]
NoRouteBike

NoRouteTransit <- CensusPop[is.na(CensusPop$TransitTime),]
NoRouteTransit

# Driving: Immediately for rows 2 and 4 we can see that there is only water in this census tract... My guess is that 
# these tracts cover the Channel Islands and the surrounding waters. Upon Google searching these tracts, the 
# first 5 are indeed the Channel Islands (which I assume nobody will be commuting from) and the final two are
# large rural swaths far from Carpinteria that I am comfortable with excluding from analysis.

# Biking: non-existent bike routes are a subset of the non-existent Drive routes so I am comfortable with their
# exclusion.

# Transit: No lie, there are a lot of non-existent routes for transit lines. Moving straight down into the SB 
# County non-existent routes, we already see that the first NA route in the census tract right next to Carp which
# is problematic

