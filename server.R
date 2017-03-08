options(shiny.maxRequestSize=1000*1024^2)

library(ggplot2)
library(data.table)
plotType <- function(x, type) {
  switch(type,
         A = hist(x),
         B = barplot(x),
         C = pie(x))
}

shinyServer(function(input, output, session) {
  
  values <- reactiveValues(df_data = NULL)
  
  observeEvent(input$read, {
    progress <- Progress$new(session, min=1, max=15)
    on.exit(progress$close())
    progress$set(message = 'Reading table in progress ...')
    values$df_data <- fread(input$file$datapath,  h=T)
  })
  
  output$sel.x <- renderUI({
    factornames <- colnames(values$df_data)
    selectInput(inputId = "variable.x",label = "X axis:", choices = factornames, selected = "all")
    })
  output$sel.y <- renderUI({
    factornames <- colnames(values$df_data)  
  selectInput(inputId = "variable.y",label = "Y axis:", choices = factornames, selected = "all")
  })
  output$sel.col <- renderUI({
    factornames <- colnames(values$df_data)
  selectInput(inputId = "variable.color",label = "Group by:", choices = factornames, selected = "all")
  })
  
  output$table <- renderDataTable ({ values$df_data })
  
   sel.columns <-  reactiveValues(vec = NULL)
   
   data_my <- reactive({
     validate(
       need(length(input$variable) == 3, "Please select three features")
     )
     sel.columns$vec <- as.vector(input$variable)
      })
   
   
   
   
  output$plot <- renderPlot({
    data_my()
    ggplot(data = values$df_data) +
      geom_point(mapping = aes(x = values$df_data[[sel.columns$vec[1]]], y = values$df_data[[sel.columns$vec[2]]], color = values$df_data[[sel.columns$vec[3]]])) +
      labs(list(title = paste(input$variable[1], "vs" ,sel.columns$vec[2], sep = " "), x = sel.columns$vec[1], y = sel.columns$vec[2]))
  })
  
  output$summary <- renderPrint({ 
    summary(values$df_data)
  })
   
})
