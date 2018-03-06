library(shiny)


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  
  
  
  output$industry <- renderPrint({ input$industry })
  output$name <- renderPrint({ input$names})
  
  
})
