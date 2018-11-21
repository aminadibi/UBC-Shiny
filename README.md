---
title: "Shiny Tutorial for UBC R Meeting"
author: "amin adibi"
date: "November 20, 2018"
output: html_document
---

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
