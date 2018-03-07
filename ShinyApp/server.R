library(shiny)
library(rvest)
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
  
  v <- reactiveValues(doPlot = FALSE)
  
  observeEvent(input$go, {
    # 0 will be coerced to FALSE
    # 1+ will be coerced to TRUE
    v$doPlot <- input$go
  })
  
  
  output$stockplot <- renderHighchart({
    if (v$doPlot == FALSE) return()
    if (isolate(input$symbol) != "") {
      stock <- getSymbols(isolate(input$symbol), auto.assign = FALSE)
      chart <- StockChart(stock, isolate(input$plottype))
      if (length(isolate(input$indicator)) != 0) {
        withProgress(message = "Adding indicators", value = 0, {
          for(i in isolate(input$indicator)) {
            funcname <- indicators %>% filter(indicators.names == i) %>% select(indicators.func)
            chart <- AddIndicator(chart,funcname[[1]], stock)
            incProgress(1/length(isolate(input$indicator)), detail = paste("add", i))
          }
          Sys.sleep(0.8)
        })
      }
      if (length(isolate(input$comparision)) != 0) {
        withProgress(message = "Adding comparison companies", value = 0, {
          for (i in isolate(input$comparision)) {
            otherstock <- getSymbols(i, auto.assign = FALSE)
            chart <- AddComparision(chart, otherstock, isolate(input$plottype))
            incProgress(1/length(isolate(input$comparision)), detail = paste("add", i))
          }
          Sys.sleep(0.8)
        })
      }
      return(chart)
    }
  })
  
  v2 <- reactiveValues(doPlot = FALSE)
  
  observeEvent(input$go2, {
    # 0 will be coerced to FALSE
    # 1+ will be coerced to TRUE
    v2$doPlot <- input$go2
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
    if (v2$doPlot == FALSE) return()
    if (isolate(input$predictstock) != "") {
      withProgress(message = "Doing plot", value = 0, {
        stock <- getSymbols(isolate(input$predictstock), auto.assign = FALSE)
        incProgress(0.4, detail = "getting data")
        periods <- isolate(input$periods)
        PredictStock(stock, periods)
        incProgress(0.4, detail = "predicting")
        Sys.sleep(1)
        incProgress(0.2, detail = "done")
        Sys.sleep(1)
      })
    }
  })
})
