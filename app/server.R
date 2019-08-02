######################### PACKAGES #############################

user <- unname(Sys.info()["user"])
if (user == "shiny") {
  # Set library locations
  .libPaths(c(
    "C:/Users/eagle/OneDrive/Documents/R/win-library/3.4"
  ))
}

# Load Package
library(shiny)
library(leaflet)
library(scales)
library(lattice)
library(dplyr)
library(htmltools)
library(maps)
library(plotly)
library(data.table)
library(dtplyr)
library(shiny)
library(plotly)
library(leaflet)
library(shinydashboard)
library(imager)
library(shinythemes)
library(lettercase)
library(parcoords)
# devtools::install_github("timelyportfolio/parcoords")
# devtools::install_github("timelyportfolio/parcoords", force = TRUE)
# library(parcoords, lib.loc = "C:/Users/eagle/OneDrive/Documents/R/win-library/3.4")
# library(parcoords, lib.loc = "C:/Users/eagle/AppData/Local/Temp/RtmpwPuYTM/devtools2a9441aa786/timelyportfolio-parcoords-324d00b")
# library(parcoords, lib.loc = "C:/PROGRA~1/R/R-34~1.3/bin/x64/R")
# library(parcoords, lib.loc = "C:/Users/eagle/OneDrive/Documents/R/win-library/3.4")

########################### RUN APP ##############################

# Set WD
#setwd("C:/Users/eagle/Desktop/Group 8 Project 2/Project/Project_2_Ivy_Difference/Project_2_Ivy_Difference")
# Run App
#runApp(getwd())

############################ DATA ##################################

#load("history.RData")
schdata <- read.csv("final3data.csv", stringsAsFactors = F)
schdata$IvyIndicator <- ifelse(
  schdata$Name == "Brown University", "Yes",
  ifelse(
    schdata$Name == "Columbia University in the City of New York", "Yes",
    ifelse(
      schdata$Name == "Cornell University", "Yes",
      ifelse(
        schdata$Name == "Dartmouth College", "Yes", 
        ifelse(
          schdata$Name == "Harvard University", "Yes",
          ifelse(
            schdata$Name == "University of Pennsylvania", "Yes",
            ifelse(
              schdata$Name == "Princeton University", "Yes",
              ifelse(
                schdata$Name == "Yale University", "Yes", "No"
              )
            )
          )
        )
      )
    )
  )
)
schdata$Coast <- ifelse(
  schdata$Longitude < -100, "West", 
  ifelse(schdata$Longitude < -85, "Middle", "East"))
schdata$Earn <- as.numeric(as.character(schdata$Earn))

######################### DEFINE SERVER ###############################

# Define server logic required to draw a histogram
shinyServer(function(input, output){
  
  # Define background image
  #image <- load.image("background.png")
  #output$background <- renderPlot({
  #  plot(image, axes=FALSE, width = 1400, height = 500, unit = "px")
  #})
  
  output$background <- renderImage({
    list(
      src = "background.png",
      contentType = "png"
    )
  }, deleteFile = FALSE)
  
  # Define reactive ({})
  major<-reactive({
    major<-input$major
  })
  
  st<-reactive({
    st<-input$schtype
  })
  
  ivy<-reactive({
    ivy<-input$ivy
  })
  
  coast<-reactive({
    coast<-input$coast
  })
  
  ct<-reactive({
    ct<-input$citytype
  })
  
  budget<-reactive({
    budget<-input$budget
  })
  
  v1<-reactive({
    if (major() == "All") {
      v1<-schdata
    } 
    else {
      selectmaj<-paste("Major", "_", major(), sep="")
      v1<- schdata %>% filter_(paste(selectmaj, "==", 1))}}) 
  
  v2<- reactive({
    if (st() == "All") {
      v2<-v1() 
    }  
    else {
      v2<- filter(v1(), Ownership==st())
    }})
  
  v2.ivy<- reactive({
    if (ivy() == "All") {
      v2.ivy<-v2()
    }  
    else {
      v2.ivy<- filter(v2(), IvyIndicator==ivy())
    }})
  
  v2.coast<- reactive({
    if (coast() == "All") {
      v2.coast<-v2.ivy()
    }  
    else {
      v2.coast<- filter(v2.ivy(), Coast==coast())
    }})
  
  v2.budget<- reactive({
    v2.budge<- na.omit(v2.coast()[as.numeric(as.character(v2.coast()$AvgCost)) < budget(), ])
    })
  
  v3<- reactive({
    if (ct() == "All") {
      v3<- v2.budget()} 
    else {
      v3<- filter(v2.budget(), Citytype==ct()) 
    }})   
  
  

  output$tablerank = renderDataTable({
    final1dat<-v3()
    final1dat[,c(3,4,2,10,13,14,27,28, 29,30,31,33)]
  },options = list(orderClasses = TRUE))
  
  output$parcoords <- renderParcoords({
    parcoords(v3()[,c(3,12,30,13,26,27)],
              rownames = F, 
              brushMode = "1d-axes", 
              reorderable = T, 
              queue = F, 
              color = list(colorBy ="Name"))
  }) 
  
  
  
  output$tablerank2 <- renderDataTable({
    data<-v3()
    w1<-0.2 #input$Earn
    w2<-input$rank
    w3<-input$AvgCost
    w4<-input$CrimeRate
    w5<-input$HappyRank
    final2dat<-data %>%
      select(Name,Earn, ADMrate,Rank,AvgCost,CrimeRate,HappyRank, State, SAT, Enrollment, Deadline)%>%
      mutate(Enrollment = as.numeric(Enrollment))%>%
      mutate(Deadline = as.Date(Deadline, "%m/%d/%y"))%>%
      arrange(Earn,Rank)%>%
      mutate(Earn1=seq(1:nrow(data)))%>%
      arrange(AvgCost,Rank)%>%
      mutate(AvgCost1=seq(1:nrow(data)))%>%
      arrange(CrimeRate,Rank)%>%
      mutate(CrimeRate1=seq(1:nrow(data)))%>%
      arrange(HappyRank,Rank)%>%
      mutate(HappyRank1=seq(1:nrow(data))) %>%
      mutate(new_rank=w1*Earn1+ w2*Rank+w3*AvgCost1+w4*CrimeRate1+w5*HappyRank1) %>%
      arrange(new_rank)
    colnames(final2dat)[2] <- "Earnings"
    final2dat[,c(4,1,8, 3, 9, 5,10,11, 2, 6,7)]
  },options = list(orderClasses = TRUE, autoWidth = TRUE,
                   columnDefs = list(list(width = '175px', targets = c(1)), list(width = '25px', targets = c(0,2)))))
  
  output$map <- renderLeaflet({
    urls <- paste0(as.character("<b><a href='http://"), as.character(v3()$URL), "'>", as.character(v3()$Name),as.character("</a></b>"))
    content <- paste(sep = "<br/>",
                     urls, 
                     paste("Rank:", as.character(v3()$Rank), 
                           "; City:", as.character(v3()$City),
                           "; Ownership:", as.character(v3()$Ownership),
                           "; Admission Rate:", as.character(v3()$ADMrate),
                           "; Happy Rank:", as.character(v3()$HappyRank),
                           "; Happy Score:", as.character(v3()$HappyScore)
                     )
    )
    mapStates = map("state", fill = TRUE, plot = FALSE)
    colorData <- ifelse(v3()$Citytype == "City", 
                        "purple", 
                        ifelse(v3()$Citytype == "Rural",
                               "yellow",
                               ifelse(v3()$Citytype == "Suburb",
                                      "blue", "green")))
    pal <- colorFactor("viridis", colorData)
    colorBy <- input$citytype
    leaflet(data = mapStates) %>% addTiles() %>%
      addPolygons(fillColor = topo.colors(10, alpha = NULL), stroke = FALSE) %>%
      addCircles(~v3()$Longitude, ~v3()$Latitude, fillColor=colorData,
                 stroke=FALSE, radius = 300000-v3()$Rank*1000,
                 fillOpacity = 0.4, popup = content) %>%
      addLegend("bottomleft", #pal=pal, 
                values=NA, colors = unique(colorData), labels = unique(v3()$Citytype),
                title="Type of City",
                   layerId="colorLegend")
    # %>%
      #addMarkers(v3()$Longitude, v3()$Latitude, 
      #           popup = content)
  })
  
  output$ADMchart <- renderPlotly({
    edu <- v3()
    adm <- edu %>% select(Name, ADMrate)
    adm$ADMrate <- as.numeric(as.character(adm$ADMrate))
    b <- ggplot(data = adm,aes(x=ADMrate)) + 
      geom_histogram(aes(y = ..density..), alpha = 0.7, fill = "#56B4E9") +
      geom_density(fill = "#CC79A7", alpha = 0.5) +
      theme(panel.background = element_rect(fill = '#ffffff')) + 
      ggtitle("Density of Admission Rate with Histogram overlay")
    ggplotly(b)
  })
  
  output$cost <- renderPlotly({
    edu <- v3()
    fee <- edu %>% select(Name, AvgCost)
    fee$AvgCost <- as.numeric(as.character(fee$AvgCost))
    c <- ggplot(data = fee,aes(x=AvgCost)) + 
      geom_histogram(aes(y = ..density..), alpha = 0.7, fill = "#56B4E9") +
      geom_density(fill = "#CC79A7", alpha = 0.5) +
      theme(panel.background = element_rect(fill = '#ffffff')) + 
      ggtitle("Density of Average Cost with Histogram overlay")
    ggplotly(c)
  })
  
  output$earnchart <- renderPlotly({
    edu <- v3()
    earn <- edu %>% select(Name, Earn) %>% arrange(desc(Earn)) 
    earn$Earn <- as.numeric(as.character(earn$Earn))
    a <- ggplot(data = earn,aes(x=Earn)) + 
      geom_histogram(aes(y = ..density..), alpha = 0.7, fill = "#56B4E9") +
      geom_density(fill = "#CC79A7", alpha = 0.5) +
      theme(panel.background = element_rect(fill = '#ffffff')) + 
      ggtitle("Density of Earnings with Histogram overlay")
    ggplotly(a)
  })
  
  #output$text0<- renderText({"Please read the following:"})
  
  output$explain1<- renderText({"
    (1) Click on *Search*.
    "})
  
  output$explain2<- renderText({"
    (2) Choose your desired major, school size, type of school, and location. 
    If you don't have strong preferences, choose the default option *All*.
    "})
  
  output$explain3<- renderText({"
    (3) Select your budget.
    "})
  
  output$explain4<- renderText({"
    (4) Use the slider bars available to rate how highly you value 
    variables such as  performance, cost, safety and life quality.
    "})
  
  output$explain5<- renderText({"
    (5) Click on: *Find my dream college* and make your dreams come true!
    "})
  
  output$explain6 <- renderText({"
    This will display a map of the colleges that best fit your criteria, 
    including pop up windows and tabs that will give you all the data you 
    want on your preferred list of colleges!
    "})
  
  # Dictionary here
  # Dictionary here
  # Dictionary here
  output$dictonary1 <- renderText({"
    Rank: Forbes Ranking
    "})
  
  
  #output$text1<- renderText({"Please rate how highly you value the following:"})
  
  output$introduction<- renderText({"
    Many of you refer to us as Group 8, but we are a group of data 
    science international graduate students who understand the struggle 
    of finding your dream school. To get into Columbia University,  we 
    were inspired by many key moments and mentors when applying to universities. 
    As fortunate as we felt to have such expert guidance, we realized that it 
    was inaccessible to most of our peers. That is why we created the College 
    Fair, an app dedicated to high schoolers who want to do their college 
    research in an effective and seamless way. 
    "})
  
  output$introduction1<- renderText({"
    - Chuqiao Rong
    "})
  
  output$introduction2<- renderText({"
    - Peilin Li
    "})
  
  output$introduction3<- renderText({"
    - Qiaqia Sun
    "})
  
  output$introduction4<- renderText({"
    - Yadir Lakehal
    "})
  
  output$introduction5<- renderText({"
    - Yiding Xie
    "})
  
  output$introduction6<- renderText({"
    - Yiqiao Yin
    "})
  
  
  output$sat <- renderPlotly({
    edu <- v3()
    cr <- edu %>% select(Name, SAT) %>% arrange(desc(SAT)) 
    cr$SAT <- as.numeric(as.character(cr$SAT))
    d <- ggplot(data = cr,aes(x=SAT)) + 
      geom_histogram(aes(y = ..density..), alpha = 0.7, fill = "#56B4E9") +
      geom_density(fill = "#CC79A7", alpha = 0.5) +
      theme(panel.background = element_rect(fill = '#ffffff')) + 
      ggtitle("Density of SAT Score with Histogram Overlay")
    ggplotly(d)
  })
  
  output$act <- renderPlotly({
    edu <- v3()
    cr <- edu %>% select(Name, ACT) %>% arrange(desc(ACT)) 
    cr$ACT <- as.numeric(as.character(cr$ACT))
    d <- ggplot(data = cr,aes(x=ACT)) + 
      geom_histogram(aes(y = ..density..), alpha = 0.7, fill = "#56B4E9") +
      geom_density(fill = "#CC79A7", alpha = 0.5) +
      theme(panel.background = element_rect(fill = '#ffffff')) + 
      ggtitle("Density of ACT Score with Histogram Overlay")
    ggplotly(d)
  })
  
  output$crimer <- renderPlotly({
    edu <- v3()
    cr <- edu %>% select(Name, CrimeRate) %>% arrange(desc(CrimeRate)) 
    cr$CrimeRate <- as.numeric(as.character(cr$CrimeRate))
    d <- ggplot(data = cr,aes(x=CrimeRate)) + 
      geom_histogram(aes(y = ..density..), alpha = 0.7, fill = "#56B4E9") +
      geom_density(fill = "#CC79A7", alpha = 0.5) +
      theme(panel.background = element_rect(fill = '#ffffff')) + 
      ggtitle("Density of Crime Rate with Histogram Overlay")
    ggplotly(d)
  })
  
  output$happy_score <- renderPlotly({
    edu <- v3()
    cr <- edu %>% select(Name, HappyScore) %>% arrange(desc(HappyScore)) 
    cr$HappyScore <- as.numeric(as.character(cr$HappyScore))
    d <- ggplot(data = cr,aes(x=HappyScore)) + 
      geom_histogram(aes(y = ..density..), alpha = 0.7, fill = "#56B4E9") +
      geom_density(fill = "#CC79A7", alpha = 0.5) +
      theme(panel.background = element_rect(fill = '#ffffff')) + 
      ggtitle("Density of Happy Score with Histogram Overlay")
    ggplotly(d)
  })
  
  output$Enrollment <- renderPlotly({
    edu <- v3()
    cr <- edu %>% select(Name, Enrollment) %>% arrange(desc(Enrollment)) 
    cr$Enrollment <- as.numeric(as.character(cr$Enrollment))
    d <- ggplot(data = cr,aes(x=Enrollment)) + 
      geom_histogram(aes(y = ..density..), alpha = 0.7, fill = "#56B4E9") +
      geom_density(fill = "#CC79A7", alpha = 0.5) +
      theme(panel.background = element_rect(fill = '#ffffff')) + 
      ggtitle("Density of Undergraduate Enrollment with Histogram Overlay")
    ggplotly(d)
  })
  
  observeEvent(input$resetAll, {
    reset("input1")
  })
  
  })

######################### END SCRIPT ###############################

