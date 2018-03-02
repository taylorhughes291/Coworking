#If you want to get the full census file, please download 2016 1-year PUMS data to the folder Starting Point Data Files
# as "ss16pca.csv" on the census.gov website. That is how I obtained the data for SB and Ventura Counties.

Census <- read.csv("Starting Point Data Files/ss16pca.csv")

# Now we must select only the entries that are within our market areas, which include South Coast Santa Barbara, Ventura City, Oxnard/Port Hueneme, and we'll throw in Camarillo/Moorpark as well.
MarketCensus <- Census[Census$PUMA == 08303 | Census$PUMA == 11104 | Census$PUMA == 11103 | Census$PUMA == 11106, ]
write.csv(MarketCensus, file = "PUMS Data SB-Ventura County Market Areas.csv")

