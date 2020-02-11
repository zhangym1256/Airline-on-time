
shinyServer(function(input, output,session) {
  
  
  observe({
    dest <- unique(df %>% 
                     filter(df$ORIGIN == input$origin) %>% .$DEST)
    updateSelectInput(session, 'dest',choices = sort(unique(df[df$ORIGIN ==input$origin,'DEST'])),
                      selected=ifelse("LAX" %in% df[df$ORIGIN ==input$origin,'DEST'],"LAX",sort(unique(df[df$ORIGIN ==input$origin,'DEST']))[1]))
    
  })
  
  observe({
    departuretime <- unique(df %>%
                              filter(df$ORIGIN == input$origin & df$DEST == input$dest) %>% .$TIME_OF_DAY_DEP)
    updateSelectInput(session, 'departuretime',choices = sort(unique(df[df$ORIGIN ==input$origin & df$DEST == input$dest,'TIME_OF_DAY_DEP'])))
    
  })
  
  
  ##################################        Airport Tab       ####################################
  
  ### Infobox to show the average delay in mins for user selected origin airport
  df_dep = reactive({
    df %>% filter(ORIGIN == input$origin, DEST == input$dest) %>% 
      group_by(ORIGIN) %>%
      summarise(average_delay = round(mean(DEP_DELAY)),
                ORIGIN_LONGITUDE = first(ORIGIN_LONGITUDE),
                ORIGIN_LATITUDE = first(ORIGIN_LATITUDE),
                ORIGIN_CITY = first(ORIGIN_CITY_NAME))
  })
  
  output$depbox = renderInfoBox({
    infoBox(title= tags$p(paste(df_dep()$ORIGIN,"Average Delay"),style = "font-size:120%; color:dodgerblue"),value = paste(df_dep()$average_delay, "mins"),icon = icon("plane-departure"),color ="aqua")
  })
  
  ### Infobox to show the average delay in mins for user selected arrival airport
  df_arr = reactive({
    df %>% filter(ORIGIN == input$origin, DEST == input$dest) %>% 
      group_by(DEST) %>%
      summarise(average_delay = round(mean(ARR_DELAY)),
                DEST_LONGITUDE = first(DEST_LONGITUDE),
                DEST_LATITUDE = first(DEST_LATITUDE),
                DEST_CITY = first(DEST_CITY_NAME))
  })
  
  output$arrbox = renderInfoBox({
    infoBox(title = tags$p(paste(df_arr()$DEST,"Average Delay"),style = "font-size:120%;color:red"),value = paste(df_arr()$average_delay,"mins"),icon = icon("plane-arrival"),color ="red")
  })
  
  
  ### Map for Origin Airports Average delay 
  pal = colorQuantile(palette = 'YlGnBu',
                      domain = origin_airport$DEP_DELAY)
  
  output$map1 <- renderLeaflet({
    leaflet() %>% addProviderTiles("CartoDB.Voyager") %>% 
      addCircleMarkers(data = origin_airport, lng = ~LONG, lat = ~LAT,
                       radius = ifelse(origin_airport$DEP_DELAY>150,8,ifelse(origin_airport$DEP_DELAY > 120,6,4)),
                       color = ~pal(DEP_DELAY),
                       label = paste(paste(origin_airport$ORIGIN,"in",origin_airport$City),paste("Average Delay:",origin_airport$DEP_DELAY,"mins"),sep=" | "),
                       stroke = FALSE, fillOpacity = 0.5) %>% 
      addMarkers(lng = df_dep()$ORIGIN_LONGITUDE,lat = df_dep()$ORIGIN_LATITUDE,
                 label = paste(paste(df_dep()$ORIGIN,"in",df_dep()$ORIGIN_CITY),paste("Average Delay:",df_dep()$average_delay,"mins"),sep=" | "))
    
  })
  
  
  ### Map for Arrival Airports average delay  
  pal2 = colorQuantile(palette = 'YlOrRd',
                       domain = dest_airport$ARR_DELAY)
  
  output$map2 <- renderLeaflet({
    leaflet() %>% addProviderTiles("CartoDB.Voyager") %>% #Esri.WorldTopoMap
      addCircleMarkers(data = dest_airport, lng = ~LONG, lat = ~LAT,
                       radius = ifelse(dest_airport$ARR_DELAY>150,8,ifelse(dest_airport$ARR_DELAY > 120,6,4)),
                       color = ~pal2(ARR_DELAY),
                       label = paste(paste(dest_airport$DEST,"in",dest_airport$City),paste("Average Delay:",dest_airport$ARR_DELAY,"mins"),sep=" | "),
                       stroke = FALSE, fillOpacity = 0.5) %>% 
      addAwesomeMarkers(lng = df_arr()$DEST_LONGITUDE,lat = df_arr()$DEST_LATITUDE,
                        label = paste(paste(df_arr()$DEST,"in",df_arr()$DEST_CITY),paste("Average Delay:",df_arr()$average_delay,"mins"),sep=" | "))
  }) 
  
  
  
  ##################################        Carrier Tab       ####################################
  
  day = reactive({
    df %>%
      filter(ORIGIN == input$origin, DEST == input$dest, 
             TIME_OF_DAY_DEP == input$departuretime) %>% 
      group_by(DAY_OF_WEEK) %>% 
      mutate(day = ifelse(DAY_OF_WEEK == "1","Monday",ifelse(
        DAY_OF_WEEK=="2","Tuesday",ifelse(
          DAY_OF_WEEK=="3","Wednesday",ifelse(
            DAY_OF_WEEK=="4","Thursday",ifelse(
              DAY_OF_WEEK=="5","Friday",ifelse(
                DAY_OF_WEEK=="6","Saturday","Sunday"))))))) %>% 
      summarise(ARR_DELAY= mean(ARR_DELAY), count = n(),day=first(day)) 
  })
  
  ### Infobox to show the day in a week that has the most flights between the chosen airports 
  output$mostflights = renderInfoBox({
    day =day() %>% arrange(desc(count)) %>% head(1)
    infoBox(title = tags$p("Day with Most Flights", style ="font-size:120%; color:navy"),day$day,icon = icon("calendar-check"),color ="blue")
  }) 
  
  ### Infobox to show the best day in a week to travel based on the average delay in mins  
  output$bestday = renderInfoBox({
    day=day() %>% arrange(ARR_DELAY) %>% head(1)
    infoBox(title = tags$p("Best Day to Travel",style = "font-size:120%; color:green"),day$day,icon = icon("thumbs-up"),color ="green")
  })
  
  ### Infobox to show the worst day in a week to travel based on the average delay in mins   
  output$worstday = renderInfoBox({
    day=day() %>% arrange(desc(ARR_DELAY)) %>% head(1)
    infoBox(title = tags$p("Worst Day to Travel",style = "font-size:120%; color:maroon"),day$day,icon = icon("thumbs-down"),color ="maroon")
  })
  
  
  df_delay = reactive({
    df %>% rename(Carrier = Description,`Day of Week` = DAY_OF_WEEK,`Carrier Delay`= CARRIER_DELAY) %>% 
      filter(ORIGIN == input$origin, DEST == input$dest, 
             TIME_OF_DAY_DEP == input$departuretime) %>% 
      group_by(`Day of Week`,Carrier) %>% 
      summarise(Count =n(),
                Arrival = round(mean(ARR_DELAY)),
                Departure =round(mean(DEP_DELAY)),
                `Carrier Delay`= round(mean(`Carrier Delay`)))
  })
  
  ### Graph to show the total counts of flights by days between the two selected airports
  output$count = renderPlotly({
    df_delay() %>% 
      ggplot(aes(x=`Day of Week`, y = Count,fill = Carrier))+geom_col(position = 'dodge')+
      labs(x="Day of the Week", y = "Counts of Flights")+
      ggtitle("Counts of Flights by Carrier")+
      scale_x_discrete(limits=c(1:7),labels = Day)+
      theme_classic()
  })
  
  ### Graph to show the average departure delay in mins by days and by carriers during selected departure time period between the two airports
  output$depdelay = renderPlotly({
    df_delay() %>% 
      ggplot(aes(x=`Day of Week`, y = Departure, fill = Carrier))+
      geom_col(position = 'dodge') + 
      labs(x="Day of the Week", y = "Average Depature Delay (mins)")+
      ggtitle("Average Depature Delay by Carrier")+
      scale_x_discrete(limits=c(1:7),labels = Day)+
      theme_classic()
  }) 
  
  ### Graph to show the average arrival delay in mins by days and by carriers during selected departure time period between the two airports
  output$arrdelay = renderPlotly({
    df_delay() %>% 
      ggplot(aes(x=`Day of Week`, y = Arrival, fill = Carrier))+
      geom_col(position = 'dodge') + 
      labs(x="Day of the Week", y = "Average Arrival Delay (mins)")+
      ggtitle("Average Arrival Delay by Carrier",)+
      scale_x_discrete(limits=c(1:7),labels = Day)+
      theme_classic()
  })
  
  ### Graph to show the average delay in mins that is caused by carrier 
  output$carrier = renderPlotly({
    df_delay() %>% 
      ggplot(aes(x=`Day of Week`, y = `Carrier Delay`, fill = Carrier))+
      geom_col(position = 'dodge') + 
      labs(x="Day of the Week", y = "Delay Caused by Carrier(mins)")+
      ggtitle("Average Delay Caused by Carrier")+
      scale_x_discrete(limits=c(1:7),labels = Day)+
      theme_classic()
  })
  
  ### table summary of the 4 charts 
  output$summary <- renderTable({
    df_delay() 
  },digits =0, align = 'c')
  
  
  ##################################        Data Tab       ####################################
  
  ### Cleaned data in Data Tab 
  output$data <- renderDataTable({
    datatable(df,rownames=F,
              options = list(scrollX=TRUE, scrollCollapse=TRUE)) %>% 
      formatStyle(input$selected,
                  background = "skyblue",fontweight = "bold") 
  })
  
  
})




