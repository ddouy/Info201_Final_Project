library(rvest)
library(quantmod)
library(highcharter)
library(prophet)
library(dplyr)

# tbl <- read_html('https://en.wikipedia.org/wiki/List_of_S%26P_500_companies') %>% html_nodes(css = 'table')
# tbl <- tbl[1] %>% html_table() %>% as.data.frame()
# tbl$Ticker.symbol <- gsub(pattern = '\\.', '-', tbl$Ticker.symbol)
# SM500security <- tbl$Security
# SM500symbol <- tbl$Ticker.symbol
# SM500Industries <- unique(tbl$GICS.Sector)
# 
# getSymbols(SM500symbol, warnings = FALSE)
# 
# SM500symbol <- as.list(SM500symbol)
# 
# SM500List <- list()
# i <- 1
# while(i < 506) {
#   SM500List[[i]] <- eval(as.name(SM500symbol[[i]]))
#   i <- i + 1
# }

PredictStock <- function(stock, the_periods) {
  stock <- as.data.frame(stock)
  ds <-  as.Date(row.names(stock))
  y <- log(stock %>% select(y = ends_with("Close")))
  df <- data.frame(ds, y)
  m <- prophet(df)
  future <- make_future_dataframe(m, periods = the_periods)
  forecast <- predict(m,future)
  prophet_plot_components(m, forecast)
}

GetPredictStockData <- function(stock, the_periods) {
  stock <- as.data.frame(stock)
  ds <-  as.Date(row.names(stock))
  y <- log(stock %>% select(y = ends_with("Close")))
  df <- data.frame(ds, y)
  m <- prophet(df)
  future <- make_future_dataframe(m, periods = the_periods)
  forecast <- predict(m,future)
  finaldata <- tail(forecast, the_periods)
  finaldata$yhat <- exp(finaldata$yhat)
  finaldata$yhat_lower <- exp(finaldata$yhat_lower)
  finaldata$yhat_upper <- exp(finaldata$yhat_upper)
  finaldata <- finaldata %>% select(ds, yhat, yhat_lower, yhat_upper)
}

## SM500 <- data.frame(as.xts(Reduce(function(...) merge(... , all=TRUE), SM500List)))

StockChart <- function(symbolstock, plottype) {
  highchart(type = "stock") %>% 
    hc_exporting(enabled = TRUE) %>%
    hc_add_series(symbolstock, type = plottype)
}

AddIndicator <- function(chart, indicator_func_name, stock) {
  FUN <- match.fun(indicator_func_name)
  chart %>%
    hc_add_series(name = indicator_func_name, FUN(Cl(stock)))
}

AddComparision <- function(chart, stock, plottype) {
  chart %>% 
    hc_add_series(stock, type = plottype)
}

# StockChart("AAPL", "candlestick")
# 
# highchart(type = "stock") %>% 
#   hc_exporting(enabled = TRUE) %>%
#   hc_add_series(AMZN) %>% 
#   hc_add_series(name = "Moving Average", EMA(Cl(AMZN)), color = "yellow") %>% 
#   hc_add_series(name = "BB", BBands(HLC(AMZN))) %>% 
#   hc_add_series(name = "CCI(20)", CCI(HLC(AMZN)))