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

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  
  output$compAbbr <- renderUI({
    field <- input$industry
    thing1 <- tbl %>% filter(GICS.Sector == field)
    selectInput("thing1", "Company Abbreviation", thing1)
    
  })
  
  output$industry <- renderPrint({ input$industry })
  
  
  
})
