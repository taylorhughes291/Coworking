library(tidycensus)
library(tidyverse)
library(dplyr)
library(data.table)
library(bit64)
library(gmapsdistance)
census_api_key("baa4385d952532460bbc284b6763cf9d3fe75e31")
```
```{r, warning = FALSE, message = FALSE}
# In order to get the FIPS Code for Santa Barbara and Ventura Counties
data(fips_codes)
subset(fips_codes, county == "Santa Barbara County" | county == "Ventura County")
# Looks like SB County is 083 and Ventura County is 111

# Now if we want to get population and average income by Census Tract in Santa Barbara and Ventura Counties
CensusPop <- get_acs(geography = "tract", 
                     variables = c("B01003_001", "B19013_001E"), 
                     state = "CA", 
                     county = c("083","111"))
CensusPop <- subset(CensusPop, select = -moe)
CensusPop <- CensusPop %>% spread(variable, estimate)
names(CensusPop) <- c("GEOID", "NAME", "Population", "AverageIncome")

PopTotal <- sum(CensusPop$Population)
SampleTotal <- nrow(MarketCensus)
CensusPop$SampleSize <- round((CensusPop$Population/PopTotal)*SampleTotal)

CensusPop$SampleCount <- 0


MarketCensusSB <- subset(MarketCensus, subset = MarketCensus$PUMA == 8303)
MarketCensus11103 <- subset(MarketCensus, subset = MarketCensus$PUMA == 11103)
MarketCensus11104 <- subset(MarketCensus, subset = MarketCensus$PUMA == 11104)
MarketCensus11106 <- subset(MarketCensus, subset = MarketCensus$PUMA == 11106)

CensusPop$ID <- c(1:nrow(CensusPop))
CensusSampleCounterSB <- subset(CensusPop, subset = PUMA5CE == "08303")
CensusSampleCounter11103 <- subset(CensusPop, subset = PUMA5CE == "11103")
CensusSampleCounter11104 <- subset(CensusPop, subset = PUMA5CE == "11104")
CensusSampleCounter11106 <- subset(CensusPop, subset = PUMA5CE == "11106")


for (i in 1: nrow(MarketCensusSB)) { 
if (is.na(MarketCensusSB$TotalIncome[i])) {
  MarketCensusSB$Location[i] <- NA
  } else {
    print(i)
    MarketCensusSB$Location[i] <- CensusSampleCounterSB$ID[which.min(abs(MarketCensusSB$TotalIncome[i] - CensusSampleCounterSB$AverageIncome))]
    CensusSampleCounterSB$SampleCount[CensusSampleCounterSB$ID == MarketCensusSB$Location[i]] <- CensusSampleCounterSB$SampleCount[CensusSampleCounterSB$ID == MarketCensusSB$Location[i]] + 1
    if (CensusSampleCounterSB$SampleCount[CensusSampleCounterSB$ID == MarketCensusSB$Location[i]] >= CensusSampleCounterSB$SampleSize[CensusSampleCounterSB$ID == MarketCensusSB$Location[i]]) {
      CensusSampleCounterSB <- subset(CensusSampleCounterSB, subset = CensusSampleCounterSB$ID != MarketCensusSB$Location[i])
    }
    }
}

for (i in 1: nrow(MarketCensus11103)) { 
  if (is.na(MarketCensus11103$TotalIncome[i])) {
    MarketCensus11103$Location[i] <- NA
  } else {
    print(i)
    MarketCensus11103$Location[i] <- CensusSampleCounter11103$ID[which.min(abs(MarketCensus11103$TotalIncome[i] - CensusSampleCounter11103$AverageIncome))]
    CensusSampleCounter11103$SampleCount[CensusSampleCounter11103$ID == MarketCensus11103$Location[i]] <- CensusSampleCounter11103$SampleCount[CensusSampleCounter11103$ID == MarketCensus11103$Location[i]] + 1
    if (CensusSampleCounter11103$SampleCount[CensusSampleCounter11103$ID == MarketCensus11103$Location[i]] >= CensusSampleCounter11103$SampleSize[CensusSampleCounter11103$ID == MarketCensus11103$Location[i]]) {
      CensusSampleCounter11103 <- subset(CensusSampleCounter11103, subset = CensusSampleCounter11103$ID != MarketCensus11103$Location[i])
    }
  }
}

for (i in 1: nrow(MarketCensus11104)) { 
  if (is.na(MarketCensus11104$TotalIncome[i])) {
    MarketCensus11104$Location[i] <- NA
  } else {
    print(i)
    MarketCensus11104$Location[i] <- CensusSampleCounter11104$ID[which.min(abs(MarketCensus11104$TotalIncome[i] - CensusSampleCounter11104$AverageIncome))]
    CensusSampleCounter11104$SampleCount[CensusSampleCounter11104$ID == MarketCensus11104$Location[i]] <- CensusSampleCounter11104$SampleCount[CensusSampleCounter11104$ID == MarketCensus11104$Location[i]] + 1
    if (CensusSampleCounter11104$SampleCount[CensusSampleCounter11104$ID == MarketCensus11104$Location[i]] >= CensusSampleCounter11104$SampleSize[CensusSampleCounter11104$ID == MarketCensus11104$Location[i]]) {
      CensusSampleCounter11104 <- subset(CensusSampleCounter11104, subset = CensusSampleCounter11104$ID != MarketCensus11104$Location[i])
    }
  }
}

for (i in 1: nrow(MarketCensus11106)) { 
  if (is.na(MarketCensus11106$TotalIncome[i])) {
    MarketCensus11106$Location[i] <- NA
  } else {
    print(i)
    MarketCensus11106$Location[i] <- CensusSampleCounter11106$ID[which.min(abs(MarketCensus11106$TotalIncome[i] - CensusSampleCounter11106$AverageIncome))]
    CensusSampleCounter11106$SampleCount[CensusSampleCounter11106$ID == MarketCensus11106$Location[i]] <- CensusSampleCounter11106$SampleCount[CensusSampleCounter11106$ID == MarketCensus11106$Location[i]] + 1
    if (CensusSampleCounter11106$SampleCount[CensusSampleCounter11106$ID == MarketCensus11106$Location[i]] >= CensusSampleCounter11106$SampleSize[CensusSampleCounter11106$ID == MarketCensus11106$Location[i]]) {
      CensusSampleCounter11106 <- subset(CensusSampleCounter11106, subset = CensusSampleCounter11106$ID != MarketCensus11106$Location[i])
    }
  }
}

MarketCensus <- rbind(MarketCensusSB, MarketCensus11103, MarketCensus11104, MarketCensus11106)
for(i in 1:nrow(MarketCensus)) {
  MarketCensus$Tract[i] <- CensusPop$NAME[MarketCensus$Location[i] == CensusPop$ID]
}
