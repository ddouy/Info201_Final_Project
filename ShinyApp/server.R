library(shiny)
library(dplyr)
library(xml2)
library(rvest)
library(quantmod)
library(highcharter)
library(data.table)

source("index.R")

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
indicators.func <- c("SMA","EMA","BBands","CCI","CMO","MACD")

indicators <- data.frame(indicators.names,indicators.func, stringsAsFactors = FALSE)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  output$compAbbr <- renderUI({
    field <- input$industry
    if (field != "All") {
      compsymbols <-
        tbl %>% filter(GICS.Sector == field)
      compsymbols <- compsymbols$Ticker.symbol
    } else {
      compsymbols <-
        tbl$Ticker.symbol
    }
    selectInput("symbols", "Company Abbreviation", compsymbols)
  })
  
  output$selectedstock <- renderDataTable({
    stocktable <- setnames(setDT(as.data.frame(
      getSymbols(input$symbols, auto.assign = FALSE)), keep.rownames = TRUE)[], 1, "Date")
    stocktable <- stocktable[order(as.Date(stocktable$Date, "%Y-%m-%d"), decreasing = TRUE),]
  }
  )
  
  output$industry <- renderPrint({
    input$industry
  })
  
  output$stockplot <- renderHighchart({
    stock <- getSymbols(input$symbol, auto.assign = FALSE)
    chart <- StockChart(stock, input$plottype)
    if (length(input$indicator) != 0) {
      for(i in input$indicator) {
        funcname <- indicators %>% filter(indicators.names == i) %>% select(indicators.func)
        chart <- AddIndicator(chart,funcname[[1]], stock)
      }
    }
    if (length(input$comparision) != 0) {
      for (i in input$comparision) {
        otherstock <- getSymbols(i, auto.assign = FALSE)
        chart <- AddComparision(chart, otherstock, input$plottype)
      }
    }
    chart
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste(input$predictstock, ".csv", sep = "")
    },
    content = function(file) {
      write.csv(GetPredictStockData(getSymbols(input$predictstock, auto.assign = FALSE), input$periods), file, row.names = FALSE)
    }
  )
  
  output$predictstockplot <- renderPlot({
    if (input$predictstock != "") {
      stock <- getSymbols(input$predictstock, auto.assign = FALSE)
      periods <- input$periods
      return(PredictStock(stock, periods))
    }
  })
})
