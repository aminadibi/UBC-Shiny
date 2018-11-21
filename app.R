#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(sf)
library(ggplot2)
library(leaflet)
library(shinythemes)
# Define UI for application that draws a histogram
ui <- fluidPage(
   theme = shinytheme("united"),
   # Application title
   titlePanel("Vancouver Income"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        sliderInput("range", label = h3("Income Range"), min = 0, 
                    max = 200000, value = c(0, 110000))
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        leafletOutput("censusPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   vancouver <- readRDS("./vancouver.rds")
   
   output$censusPlot <- renderLeaflet({
     df_vancouver <- subset(vancouver, ((median_hh_income > input$range[1]) & (median_hh_income < input$range[2]) ))
     leaflet(df_vancouver) %>% 
       addProviderTiles(providers$CartoDB.Positron) %>%
       addPolygons()
     
     bins <- c(0, 30000, 40000, 50000,60000, 70000, 80000, 90000,100000, 110000, Inf)
     pal <- colorBin("RdYlBu", bins = bins)
     leaflet(df_vancouver) %>% 
       addProviderTiles(providers$CartoDB.Positron) %>%
       addPolygons(fillColor = ~pal(median_hh_income),
                   color = "white",
                   weight = 1,
                   opacity = 1,
                   fillOpacity = 0.65) %>% 
       addLegend("topright", pal = pal, values = ~median_hh_income,
                 title = "Median Income (2016)",
                 labFormat = labelFormat(prefix = "$"),
                 opacity = 1)
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

