
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
Shiny "widgets" can be used to customize the input in the ui: https://shiny.rstudio.com/gallery/widget-gallery.html

### CanCensus Vancouver Income Data

Census data is provided by Statistics Canada and can be accessed through the (proudly!) made-in-Vancouver package `cancensus` https://mountainmath.github.io/cancensus/index.html. 

I have previously downloaded the data and copied it to the repository as `vancouver.rds`. For the curious reader, the code below shows how the data can be obtained through `cancensus` API (you need to have an API key though, and the amount of data you can download is limited. Consult `cancensus` website for more details.)

```
library(cansensus)
options(cancensus.api_key = "your_api_key")
options(cancensus.cache_path = "./data")
vancouver <- get_census(dataset='CA16', regions=list(CMA="59933"),
                      vectors=c("median_hh_income"="v_CA16_2397"), level='CT', quiet = TRUE, 
                      geo_format = 'sf', labels = 'short')

ggplot(vancouver) + geom_sf(aes(fill = median_hh_income), colour = "grey") +
  scale_fill_viridis_c("Median HH Income", labels = scales::dollar) + theme_minimal() +
  theme(panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank()) + 
  coord_sf(datum=NA) +
  labs(title = "Median Household Income", subtitle = "Vancouver Census Subdivisions, 2016 Census")
```

### Load the dataset

The file containing our dataset `vancouver.rds` can found at https://github.com/aminadibi/UBC-Shiny/tree/master. Download the file and copy it to your project folder. Now you can import the dataset using the following command:
```
vancouver <- readRDS("./vancouver.rds")
```

### Visualize with ggplot

The reactive nature of Shiny makes debugging a little bit more difficult. So, before jumping into creating the Shiny app, it might not be bad idea to try to visualize the data using a simple RScript. Let's start with ggplot first:

```
library(ggplot2)
ggplot(vancouver) + geom_sf(aes(fill = median_hh_income), colour = "grey") +
  scale_fill_viridis_c("Median HH Income", labels = scales::dollar) + theme_minimal() +
  theme(panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank()) + 
  coord_sf(datum=NA) +
  labs(title = "Median Household Income", subtitle = "Vancouver Census Subdivisions, 2016 Census")
```

### Visualization with Leaflet

Leaflet is a Java Script library for interactive maps, and can be intergrated with Shiny through its R package. You can learn more about Leaflet here: https://leafletjs.com/

With Leaflet, we can create interactive maps superimposed on navigatable Google-Map-style maps. Let's give this a try: 

```
library(leaflet)
leaflet(vancouver) %>% 
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons()

bins <- c(0, 30000,40000, 50000,60000, 70000,80000, 90000,100000, 110000, Inf)
pal <- colorBin("RdYlBu", domain = vancouver$v_CA16_2397, bins = bins)
leaflet(vancouver) %>% 
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(fillColor = ~pal(median_hh_income),
              color = "white",
              weight = 1,
              opacity = 1,
              fillOpacity = 0.65) %>% 
  addLegend("topright", pal = pal, values = ~median_hh_income,
            title = "Median Household Income (2016)",
            labFormat = labelFormat(prefix = "$"),
            opacity = 1)
```

### Putting it all together

Here's our complete web app code:
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
     
     bins <- c(0, 30000,40000, 50000,60000, 70000,80000, 90000,100000, 110000, Inf)
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
```

### Shipping your app

Once you have created your shiny app, you probably want to ship to your end-users. There are many options, but the most convinient one would be to host it on RStudio's Shiny server, Shinyapps.io. Hosting is free up to a certain traffic. Other convinient options include hosting it on your very own Linux server using Shiny Server (which is free) or its commercial version Shiny Server Pro (expensive). 

