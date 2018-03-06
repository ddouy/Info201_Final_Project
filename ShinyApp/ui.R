

library(shiny)
library(plotly)
library(shinythemes)
library(dplyr)
data <- read.table('cereal.tsv', stringsAsFactors = FALSE)
names <- data %>% filter_at(1)
ui <- fluidPage(
  # Set theme
  theme = shinytheme("spacelab"),
  
  # Some help text
  h2("Stock Data"),
  
  # Vertical space
  tags$hr(),
  
  # Window length selector
  selectInput("company", label = "Select companies to compare", choices = names),
  
  # Plotly Chart Area
  fluidRow(
    column(6, plotlyOutput(outputId = "timeseries", height = "600px")),
    column(6, plotlyOutput(outputId = "correlation", height = "600px"))),
  
  tags$hr(),
  tags$blockquote()
  )
