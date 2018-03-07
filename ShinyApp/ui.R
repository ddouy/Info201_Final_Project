library(shiny)
library(dplyr)
library(highcharter)
library(xml2)
library(rvest)
library(shinythemes)

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
shinyUI (navbarPage(
  theme = shinytheme("readable"),
  # Application title
  "Stock Trends: Visualize & Predict",
  tabPanel(
    "Stock Trends Graphed",
    sidebarPanel(
      selectInput(
        "symbol",
        label = h3("Company"),
        choices = SM500symbol,
        selected = 1
      ),
      
      selectInput(
        "plottype",
        label = h3("Plot Types"),
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
        label = h3("Indicator Options"),
        choices = indicators.names,
        multiple = TRUE
      ),
      selectInput(
        "comparision",
        label = h3("Company to Compare Against"),
        choices = SM500symbol,
        multiple = TRUE
      )
    ),
    
    
    mainPanel(highchartOutput("stockplot"))
  ),
  tabPanel(
    "Stock Historical Data",
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
  tabPanel("Predict Stocks",
           sidebarPanel(
             selectizeInput(
               'predictstock',
               'Company Symbols',
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
           )),
  tabPanel("About Us",
           h2("Introductions"),
           p("Greetings! We are Sangho Bak, Yao Dou, Jeffrey Jing, and David Lee, also known as team \"50/50\", from INFO 201 BD.
              We're proud and honored to bring you Stock Trends: Visualize and Predict, an interactive program that allows users
              to analyze stock trends and compare two different stocks from the S&P 500. All data is exportable and downloadable,
              and is and will always be free to use."),
           h3 ("About Us"),
           p("We came upon the name 50/50 when we realized that our group consisted of two koreans and two chinese people. However,
              we have high hopes that together we'll combine for a solid 100%. Sangho Bak is a Junior who is currently a student in
              the Foster School of Business, is the oldest member of the group. Jeffrey Jing and David Lee are both Sophomores, who
              are actively seeking to major in an engineering/technology related field. Yao Dou, the youngest member of our group,
              is a brilliant Freshman who is only sixteen! Yao is a significant contributor in making ST:VP, and is actively seeking
              to become a computer science major. The entire team has no doubts of his abilities, and are all rooting for his future
              success. Together, this ragtag team proudly brings to you Stock Trends: Visualiza and Predict. ")
           )
))