library(dplyr)
library(tidyr)
library(readr)

Nov = read.csv("Nov_2019.csv", stringsAsFactors = F)
Oct = read.csv("Oct_2019.csv",stringsAsFactors = F)
Sep = read.csv("Sep_2019.csv",stringsAsFactors = F)


# Merging 3 months of data into one dataframe 
df = rbind(Sep,Oct,Nov)

# Merge dataset to get description of airline
Airline = read.csv("CARRIERS.csv",stringsAsFactors = F)
df <- left_join(df,Airline,by=c('OP_UNIQUE_CARRIER' = 'Code'))

# Only get the first word from the airline description
first_word <- function(x){
  x = unlist(strsplit(x,split = " "))[1]
}
df$Description = lapply(df$Description,first_word)
df$Description = as.character(df$Description)


# Preping airport ongitude and latitude data for merging
Airport = read.csv("Airport.csv") 
Airport <- Airport %>% filter(AIRPORT_COUNTRY_CODE_ISO=="US") %>% 
  group_by(AIRPORT) %>% summarise(LATITUDE = first(LATITUDE),
                                  LONGITUDE=first(LONGITUDE))
Airport$AIRPORT = as.character(Airport$AIRPORT)


# Merge 2 data set to get longitude and latitude of U.S. airports
df = left_join(df,Airport,by = c("ORIGIN" = "AIRPORT"))
df <- df %>% rename(ORIGIN_LATITUDE=LATITUDE,ORIGIN_LONGITUDE=LONGITUDE)
df =left_join(df,Airport,by = c("DEST" = "AIRPORT"))
df <- df %>% rename(DEST_LATITUDE=LATITUDE,DEST_LONGITUDE=LONGITUDE)

# Add Travel Time Period Column
df <- df %>% mutate(TIME_OF_DAY_DEP = ifelse(CRS_DEP_TIME<600, "Early Morning", ifelse(CRS_DEP_TIME<1200, "Morning",ifelse(CRS_DEP_TIME<1800,"Afternoon","Evening"))),
                    TIME_OF_DAY_ARR = ifelse(CRS_ARR_TIME<600, "Early Morning", ifelse(CRS_ARR_TIME<1200, "Morning",ifelse(CRS_ARR_TIME<1800,"Afternoon","Evening")))) 
# Drop rows that have missing values in either DEP_DELAY OR ARR_DELAY columns
df <- na.omit(df, cols=c("DEP_DELAY","ARR_DELAY"))

View(df)
str(df)
class(df$Description)

write.csv(df,file="Sep_to_Nov.csv")


###########################################################################################


