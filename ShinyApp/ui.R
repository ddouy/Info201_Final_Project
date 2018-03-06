
library(shiny)
library(dplyr)
library(xml2)
library(rvest)

tbl <- read_html('https://en.wikipedia.org/wiki/List_of_S%26P_500_companies') %>% html_nodes(css = 'table')
tbl <- tbl[1] %>% html_table() %>% as.data.frame()
tbl$Ticker.symbol <- gsub(pattern = '\\.', '-', tbl$Ticker.symbol)
SM500security <- tbl$Security
SM500symbol <- tbl$Ticker.symbol
SM500Industries <- unique(tbl$GICS.Sector)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Stock data"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      dateRangeInput("dates", label = "Date range",
                     start = "2007-01-03", end = "2018-03-01",
                     min = "2007-01-03", max = "2018-03-01"),
    
    
    selectInput("industry", label = h3("Industry"), 
                choices = SM500Industries, 
                selected = 1),

   
    uiOutput("compAbbr"),
    
    selectInput("plots", label = h3("plot"), choices = c("Line", "Area", "Candle", "Hollow Candle",
                                                         "Bar", "Colored Bar"),
                selected = 1),
    
    selectInput("indicators", label = h3("indicator"), choices = c("Moving Average", "Moving Average Envelope",
                                                                   "Moving Average Deviation", "Bollinger Bands",
                                                                   "RSI", "MACD"), multiple = TRUE, selected = 1)
    
  ),
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot")
    )
  )
))
