
# Shiny Tutorial for UBC R Meeting
By: Amin Adibi



## Welcome to Shiny

Shiny is the R package that helps you make simple and interactive web app using R. In this short tutorial, we'll learn how to create an interactive web app to visualize median household income in Vancouver. You can see the app in action [here](https://shefa.shinyapps.io/vancity-income/).

Before we start let's make sure you have all the required packages installed:

```
`install.packages(c("shiny","sf", "ggplot2", "leaflet", "shinythemes"))`

```
Make sure you got no errors. Now let's run one of Shiny's example apps, Hello Shiny, to make sure we've set up Shiny correctly. 

To run Hello Shiny, type:
```
library(shiny)
runExample("01_hello")
```

### Creating a new shiny app

Using RStudio's file menu, create a new Shiny Web App. The default code will look like this:

```
#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Old Faithful Geyser Data"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         sliderInput("bins",
                     "Number of bins:",
                     min = 1,
                     max = 50,
                     value = 30)
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("distPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$distPlot <- renderPlot({
      # generate bins based on input$bins from ui.R
      x    <- faithful[, 2] 
      bins <- seq(min(x), max(x), length.out = input$bins + 1)
      
      # draw the histogram with the specified number of bins
      hist(x, breaks = bins, col = 'darkgray', border = 'white')
   })
}

# Run the application 
shinyApp(ui = ui, server = server)
```
Let's explore the structure of this app further. 

All Shiny apps have two components:

* a user-interface script  
* a server script  

The user-interface (ui) script controls the look of your app. The server script contains the back-end of the app.


