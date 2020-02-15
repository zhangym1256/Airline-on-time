#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

dashboardPage(
    dashboardHeader(title = 'U.S. Airline Ontime Performance'),
    dashboardSidebar(
        sidebarUserPanel(tags$p("Yunmei Zhang",style="color:royalblue"), image="https://www.graphicsprings.com/filestorage/stencils/74c08b6397f7ec133797932eeaac13e0.png?width=500&height=500"),
        sidebarMenu(menuItem("About", tabName = "Manual", icon = icon("info")),
                    menuItem("Airport", tabName = "airport", icon = icon("globe-americas")),
                    menuItem("Carrier",tabName = "carrier", icon = icon("plane-departure")),
                    menuItem("Data", tabName = "data", icon = icon("database")),
                    menuItem("Author",tabName = "author", icon = icon("user"))),
        selectInput(inputId = "origin",
                    label = "Departure Airport",
                    choices = sort(unique(df[,"ORIGIN"])),
                    selected ="JFK"),
        selectInput(inputId = "dest",
                    label = "Arrival Airport",
                    choices = unique(df[,"DEST"])),
        selectizeInput(inputId = "departuretime",
                       label = "Depature Time",
                       choices = sort(unique(df[,"TIME_OF_DAY_DEP"])))
    ),
    
    dashboardBody(
        tabItems(
            tabItem(tabName = "Manual",
                    fluidRow(column(10,align="center",offeset =1,tags$h3("Welcome to my Airline Shiny App!", style="color:royalblue"),
                                    tags$h4("Coded by Yunmei(May) Zhang",style="color:royalblue"),
                                    tags$h4("<zhangym1256@gmail.com>",style="color:royalblue"),
                                    tags$img(src="https://images2.minutemediacdn.com/image/upload/c_crop,h_1418,w_2518,x_0,y_247/f_auto,q_auto,w_1100/v1554745450/shape/mentalfloss/555807istock-932651818.jpg", width = "450", height = "250"))),
                    br(),
                    br(),
                    fluidRow(column(6, offset =2, tags$p("This interactive app is designed to help you select a day of the week and an airline in U.S. to fly based on the average delay time to reduce your chance of a delay. The data used for this app is published by United States Department of Transportation from 09/2019 to 11/2019. There are a few tabs on the sidebar, I will go over how to use them in the following paragraphs.",style="color:royalblue;font-size:120%;text-align:center"))),
                    fluidRow(column(8,offset=1,tags$h4("Airport",style="color:navy;text-decoration:underline"),
                                    tags$p("This tab shows the on-time performance of each airport in the States. The two information boxes on the top display the average delay in mins for your selected airports from the drilldown menu in the left sidebar. They serve as general guideline on what to expect if you choose these two airports. ",style="color:royalblue"),
                                    br(),
                                    tags$p("Underneath the boxes are two maps: the top for the departure and the bottom for the arrival airports. Each map is marked by circles indicating the locations of all U.S. airports. The size and color of a circle indicate how severe the average delay is for that airport. Hover your mouse over the markers for more details. It might potentially save you some time by flying from nearby airports instead.",style="color:royalblue"),
                                    br(),
                                    tags$h4("Carrier",style="color:navy;text-decoration:underline"),
                                    tags$p("Once you have selected your departure and arrival airports as well as the travel time from the sidebar, the carrier on-time performance will be populated on this tab for comparison. Travel time is categorized into 4 groups: early morning (midnight - 6am), morning (6am - noon), afternoon (noon - 6pm) and evening (6pm - midnight).",style="color:royalblue"),
                                    br(),
                                    tags$p("Three boxes on the top provide guidline on what day of the week has the most flights between your selected airports and travel time, best and worst days of the week to travel based on the average delay across all carriers(third graph in this tab). Airfare could be cheaper on days with more flights. And avoiding busy days could improve your overall travel experience.",style="color:royalblue"),
                                    br(),
                                    tags$p("There are four bar charts under the boxes. All charts are plotted against the day of the week. Available carriers are indicated by colors of the bars. The first graph shows the counts of flights by days and carriers. The 2nd (top right) and 3rd (bottom left) are the average departure and arrival delay in mins for the selected scenario. The last graph looks at the average arrival delay that is caused by carriers only, not other uncontrollable factors such as weather or security issues.",style="color:royalblue"),
                                    br(),
                                    tags$p("There is also a table tab located on the top, which is a summary table of the information plotted in graphs.",style="color:royalblue"),
                                    br(),
                                    tags$h4("Data",style="color:navy;text-decoration:underline"),
                                    tags$p("You can explore the cleaned data in this tab. The table includes over 300,000 flights (rows in the table), which covers 370 U.S. airports and 26 commericial carriers.",style="color:royalblue"),
                                    br(),
                                    tags$h4("Author", style="color:navy;text-decoration:underline"),
                                    tags$p("Hey, thanks for reading! If you want to know more about me, feel free to check my LinkedIn profile and blog posts. You can also find my codes from my github.",style="color:royalblue"),
                                    br(),
                                    tags$strong("I hope you will like the app. Now it is time to explore! ",style="color:royalblue;font-size:120%")))),
            tabItem(tabName = "airport", 
                    tags$h3("Airport Maps"),
                    fluidRow(infoBoxOutput("depbox"),
                             infoBoxOutput("arrbox")),
                    tags$p("Depature Airport Delay",style = "font-size:130%;color:royalblue"),
                    br(),
                    leafletOutput("map1"),
                    br(),
                    br(),
                    tags$p("Arrival Airport Delay",style = "font-size:130%;color:red"),
                    br(),
                    leafletOutput("map2")),
            tabItem(tabName = "carrier", 
                    tabsetPanel(
                        tabPanel('Graph',
                                 fluidRow(infoBoxOutput("mostflights"),
                                          infoBoxOutput("bestday"),
                                          infoBoxOutput("worstday")),
                                 fluidRow(box(title = "Flights Count", status = "info",plotlyOutput('count',height = 300)),
                                          box(title = "Departure Delay", status = "warning",plotlyOutput('depdelay',height =300))),
                                 fluidRow(box(title = "Arrival Delay",status = "success",plotlyOutput('arrdelay',height = 300)),
                                          box(title = "Carrier Delay",status = "danger",plotlyOutput('carrier',height = 300)))),
                        tabPanel('Table', tableOutput("summary")))),
            tabItem(tabName = "data", dataTableOutput('data')),
            tabItem(tabName = "author",
                    box(title="About Author", status ="info",
                        tags$img(class = "img-responsive img-rounded center-block", src = "Profile.JPG", style = "max-width: 120px"),
                        br(),
                        tags$p("Yunmei(May) Zhang graduated from Cornell University with a master degree in Chemical Engineering. She started her career as a process engineer in a manufacturer where she utlized the power of data in problem solving and optimization. Her data-driven nature and interest in storytelling with visualizations motivate her to become a data analyst. She is eager to learn new techniques and apply them to solve real-life problems!"),
                        br(),
                        tags$p(tags$b("LinkedIn:",tags$a(href="https://www.linkedin.com/in/yunmei-may-zhang-3704002a/", target="_blank","https://www.linkedin.com/in/yunmei-may-zhang-3704002a/"))),
                        tags$p(tags$b("Github:",tags$a(href="https://github.com/zhangym1256?tab=repositories",target = "_blank","https://github.com/zhangym1256?tab=repositories"))),
                        tags$p(tags$b("Blog Posts:",tags$a(href="https://nycdatascience.com/blog/author/yunmei-zhang/",target = "_blank", "https://nycdatascience.com/blog/author/yunmei-zhang/")))
                        
                    )))
    )
)



