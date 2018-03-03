library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$value <- renderPrint({ 
    if(input$dates == "2007-01-03")  {
    }
  })
  
})
