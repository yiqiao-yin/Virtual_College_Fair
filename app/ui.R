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


########################### RUN APP ##############################

# Set WD
#setwd("C:/Users/eagle/Desktop/Group 8 Project 2/Project/Project_2_Ivy_Difference/Project_2_Ivy_Difference")
# Run App
#runApp(getwd())

############################ DATA ##################################

# Load Data
#load("history.RData")
schdata <- read.csv("final3data.csv")
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

########################### DEFINE: UI ###############################

# Define: UI
shinyUI(dashboardPage(
  dashboardHeader(
    title='Virtual College Fair',
    titleWidth = 325),
  #skin = "red",
  #shinythemes::themeSelector(),  # <--- Add this somewhere in the UI
  dashboardSidebar(
    width = 325,
    sidebarMenu(id='sidebarmenu',
                menuItem("Virtual College Fair",tabName="Overview",icon=icon("book")),
                menuItem("About Us", tabName="Intro", icon=icon("group")),
                menuItem("User Manual",tabName="Manual",icon=icon("question-circle")),
                menuItem("Search",tabName="University-Search",icon=icon("search"))
    ),
    hr(),
    h4("Choose your desired options below:"),
    #textOutput("text0"),
    div(
      id = "input1",
      selectInput("major", label = "Major", 
                  choices = c("All" ,"Agriculture"="agriculture", "Architecture",
                              "Biology"="Bio","Business", "Computer Science"="CS", 
                              "Education"="Edu", "Engineering", "History", "Math and Statistics"="MathStat",
                              "Nature Resources"="NatureResource", "Psychology", "Social Science"="SocialScience"), 
                  selected = "All"),
      selectInput("schtype", label="School Type",
                  choices = c("All","Private for-profit", "Private nonprofit", "Public"), selected= "All"),
      selectInput("ivy", label="Ivy League",
                  choices = c("All","Yes", "No"), selected= "All"),
      selectInput("coast", label="Location",
                  choices = c("All","West", "Middle", "East"), selected= "All"),
      selectInput("citytype", label = "City Type",
                  choices = c("All", "City", "Rural", "Suburb","Town"), selected = "All"),
      sliderInput("budget", label="Max Budget",
                  min = 7000, max = 90000, value = 90000, step = 200)
    ),
    #actionButton("resetAll", "Reset all"),
    hr(),
    h4("Rate how highly you value the following:"),
    #textOutput("text1"),
    sliderInput("rank","Academic Performance",0,100,50),
    sliderInput("AvgCost","Cost of Attendance",0,100,50),
    #sliderInput("Earn","Earnings & Jobs",0,100,20),
    sliderInput("CrimeRate","School Safety",0,100,50),
    sliderInput("HappyRank","Quality of Life",0,100,50),
    hr(),
    submitButton("Find my dream college!", width='100%')
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "Overview",
              mainPanel(
                h3("
                   Welcome to the College Fair, the world's first virtual college fair!
                   Here, you can explore and compare over 270 colleges and universities, or search by major, size, location and much more!
                   Try out The College Fair, find your best-fit college and make all your dreams come true!
                   "),
                imageOutput(outputId = "background", height = "800px", width = "1800px")
                )),
      
      tabItem(tabName = "Manual",
              mainPanel(
                h3("Please read the following."),
                textOutput("explain1"),
                tags$head(tags$style("#explain1{
                                     color: black;
                                     font-size: 20px;
                                     font-style: bold;
                                     }"
                )),
                #hr(),
                textOutput("explain2"),
                tags$head(tags$style("#explain2{
                                     color: black;
                                     font-size: 20px;
                                     font-style: bold;
                                     }"
                )),
                #hr(),
                textOutput("explain3"),
                tags$head(tags$style("#explain3{
                                     color: black;
                                     font-size: 20px;
                                     font-style: bold;
                                     }"
                )),
                #hr(),
                textOutput("explain4"),
                tags$head(tags$style("#explain4{
                                     color: black;
                                     font-size: 20px;
                                     font-style: bold;
                                     }"
                )),
                #hr(),
                textOutput("explain5"),
                tags$head(tags$style("#explain5{
                                     color: black;
                                     font-size: 20px;
                                     font-style: bold;
                                     }"
                )),
                #hr(),
                textOutput("explain6"),
                tags$head(tags$style("#explain6{
                                     color: black;
                                     font-size: 20px;
                                     font-style: bold;
                                     }"
                )),
                #hr(),
                # Dictionary here
                # Dictionary here
                # Dictionary here
                # Dictionary here
                # Dictionary here
                # Dictionary here
                # Dictionary here
                # Dictionary here
                # Dictionary here
                # Dictionary here
                # Dictionary here
                hr(),
                h3("Dictionary"),
                h4("Rank: Forbes Rank"),
                h4("State: State which the school is in"),
                h4("ADMrate: Admission Rate"),
                h4("SAT: Average SAT Score"),
                h4("ACT: Average ACT Score"),
                h4("AvgCost: Average cost per year"),
                h4("Enrollment: Total number of undergraduate enrollment"),
                h4("Deadline: Application deadline (regular decision)"),
                h4("Earnings: Average earnings of the graduates"),
                h4("CrimeRate: City crime data collected by FBI. (CrimeRate% = Number of total crime / 
                   Number of city population * 100%)"),
                h4("HappyRank/HappyScore: Happiness Score and Rank, sort by the State which the school is in"),
                h4("Slider: A feature design of slider matplot of a number of different parameters and their corresponding universities")
                )),
      
      tabItem(tabName = "Intro",
              mainPanel(
                textOutput("introduction"),
                tags$head(tags$style("#introduction{
                                     color: black;
                                     font-size: 20px;
                                     font-style: bold;
                                     }"
                )),
                textOutput("introduction1"),
                tags$head(tags$style("#introduction1{
                                     color: black;
                                     font-size: 20px;
                                     font-style: bold;
                                     }"
                )),
                textOutput("introduction2"),
                tags$head(tags$style("#introduction2{
                                     color: black;
                                     font-size: 20px;
                                     font-style: bold;
                                     }"
                )),
                textOutput("introduction3"),
                tags$head(tags$style("#introduction3{
                                     color: black;
                                     font-size: 20px;
                                     font-style: bold;
                                     }"
                )),
                textOutput("introduction4"),
                tags$head(tags$style("#introduction4{
                                     color: black;
                                     font-size: 20px;
                                     font-style: bold;
                                     }"
                )),
                textOutput("introduction5"),
                tags$head(tags$style("#introduction5{
                                     color: black;
                                     font-size: 20px;
                                     font-style: bold;
                                     }"
                )),
                textOutput("introduction6"),
                tags$head(tags$style("#introduction6{
                                     color: black;
                                     font-size: 20px;
                                     font-style: bold;
                                     }"
                ))
              )),
      
      tabItem(tabName = "University-Search",
              fluidRow(
                tabBox(width=12,
                       tabPanel(title="Map",width = 12,solidHeader = T,leafletOutput("map")),
                       tabPanel(title="ADM Rate",width=12,plotlyOutput("ADMchart")),
                       tabPanel(title="SAT Score",plotlyOutput("sat")),
                       tabPanel(title="ACT Score",plotlyOutput("act")),
                       tabPanel(title="Avg Cost",plotlyOutput("cost")), 
                       tabPanel(title="Earnings",width=12,plotlyOutput("earnchart")),
                       tabPanel(title="Crime Rate",plotlyOutput("crimer")),
                       tabPanel(title="Happy Score",plotlyOutput("happy_score")),
                       tabPanel(title="Enrollment",plotlyOutput("Enrollment")),
                       tabPanel(title="Slider",parcoordsOutput( "parcoords", width = "900px", height = "700px" ))
                ),
                tabBox(width = 12,
                       #tabPanel('Ranking',
                       #         dataTableOutput("tablerank"),
                       #         tags$style(type="text/css", '#myTable tfoot {display:none;}')),
                       tabPanel('Ranking',
                                dataTableOutput("tablerank2"),
                                tags$style(type="text/css", '#myTable tfoot {display:none;}')))))
    ))))

######################### END SCRIPT ###############################