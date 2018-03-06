library(shiny)
library(dplyr)
library(highcharter)
library(xml2)
library(rvest)

tbl <-
  read_html('https://en.wikipedia.org/wiki/List_of_S%26P_500_companies') %>% html_nodes(css = 'table')
tbl <- tbl[1] %>% html_table() %>% as.data.frame()
tbl$Ticker.symbol <- gsub(pattern = '\\.', '-', tbl$Ticker.symbol)
SM500security <- tbl$Security
SM500symbol <- tbl$Ticker.symbol
SM500Industries <- unique(tbl$GICS.Sector)
indicators.names <- c(
  "Simple Moving Average",
  "Exponential Moving Average",
  "Bollinger Bands",
  "Commodity Channel Index",
  "Chande Momentum Oscillator",
  "Moving Average Convergence Divergence"
)
indicators.func <- c("SMA", "EMA", "BBands", "CCI", "CMO", "MACD")
indicators <- data.frame()
# Define UI for application that draws a histogram
shinyUI(navbarPage(
  # Application title
  "Stock data",
  tabPanel(
    "chart of the stock",
    sidebarPanel(
      selectInput(
        "symbol",
        label = h3("name"),
        choices = SM500symbol,
        selected = 1
      ),
      
      selectInput(
        "plottype",
        label = h3("Plot"),
        choices = c(
          "candlestick",
          "line",
          "area",
          "spline",
          "ohlc",
          "column",
          "columnrange"
        ),
        selected = 3
      ),
      
      selectInput(
        "indicator",
        label = h3("Indicator"),
        choices = indicators.names,
        multiple = TRUE
      ),
      selectInput(
        "comparision",
        label = h3("Comparision"),
        choices = SM500symbol,
        multiple = TRUE
      )
    ),
    
    
    mainPanel(highchartOutput("stockplot"))
  ),
  tabPanel(
    "historical data for stock",
    sidebarPanel(
      selectInput(
        "industry",
        label = h3("Industry"),
        choices = c("All", SM500Industries),
        selected = 1
      ),
      
      
      uiOutput("compAbbr")
    ),
    mainPanel(dataTableOutput('selectedstock'))
  ),
  tabPanel("Predict stock",
           sidebarPanel(
             selectizeInput(
               'predictstock',
               'Abbreviation of Company',
               choices = SM500symbol,
               options = list(
                 placeholder = 'Please select a company below',
                 onInitialize = I('function() { this.setValue(""); }')
               )
             ),
             numericInput(
               "periods",
               "period that you want to predict(days)",
               value = 365
             ),
             downloadButton("downloadData", "Download")
           ),
           mainPanel(
             plotOutput("predictstockplot")
           ))
))