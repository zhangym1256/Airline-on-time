library(dplyr)
library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(maps)
library(plotly)
library(tidyr)
library(leaflet)
library(RColorBrewer)
library(rsconnect)

df = read.csv("Sep_to_Nov.csv", stringsAsFactors = F)

# A list to change the day of the week label in graphs 
Day = c("Mon","Tues","Weds","Thur","Fri","Sat","Sun")

# Dataset for depature airport map  
origin_airport = df %>% group_by(ORIGIN) %>% 
  summarise(DEP_DELAY = round(mean(DEP_DELAY)), 
            LONG = first(ORIGIN_LONGITUDE),
            LAT = first(ORIGIN_LATITUDE),
            City = first(ORIGIN_CITY_NAME)) %>% 
  arrange(desc(DEP_DELAY))

# Dataset for arrival airport map  
dest_airport = df %>% group_by(DEST) %>% 
  summarise(ARR_DELAY =round(mean(ARR_DELAY)), 
            LONG = first(DEST_LONGITUDE),
            LAT = first(DEST_LATITUDE),
            City = first(DEST_CITY_NAME)) %>% 
  arrange(desc(ARR_DELAY))