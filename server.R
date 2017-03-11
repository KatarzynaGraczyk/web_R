options(shiny.maxRequestSize = 1000 * 1024 ^ 2)

library(ggplot2)
library(data.table)


shinyServer(function(input, output, session) {

#---------------------- Table reading ---------------------------
  
  values <- reactiveValues(df_data = NULL, sel.table = NULL)
  
  observeEvent(input$read, {
    progress <- Progress$new(session, min = 1, max = 15)
    on.exit(progress$close())
    progress$set(message = 'Reading table in progress ...')
    values$df_data <- fread(input$file$datapath,  h = T)
  })
  
  generate.checkbox <- reactive({
    validate(
      need(input$read, "Please read file with your data")
    )
  })
  
  output$factorcheckboxes <- renderUI({
    generate.checkbox()
    factornames <- colnames(values$df_data)
    checkboxGroupInput(inputId = "variable",label = "Variables:", choices = factornames, selected = "all", inline = FALSE)
  })
  
  output$table = renderDataTable({
    values$df_data
  })
# ------------ UI rendering - update select input ----------------

  observe({  
    updateSelectInput(session, "variable.x", choices = colnames(values$df_data))
    updateSelectInput(session, "variable.y",  choices = colnames(values$df_data))
    updateSelectInput(session, "variable.color", choices = c("NULL",colnames(values$df_data)))
  })

#------------------------- plots ---------------------------------
  plot.dat <- reactiveValues(main = NULL, layer = NULL)
  
  observeEvent(input$plottype, {
    plot.dat$main <- ggplot(data = values$df_data, aes(x = values$df_data[[input$variable.x]], 
                                                     y = values$df_data[[input$variable.y]])) + 
      theme(axis.text.x = element_text(angle = 90, hjust = 0.5), plot.title = element_text(hjust = 0.5)) +
      labs(list(title = paste(input$variable.x, "vs" ,input$variable.y, sep = " "), x = input$variable.x, y = input$variable.y, color = "Group by:\n"))
    if (input$plottype == "box") {
      observeEvent(input$variable.color, {if (input$variable.color == "NULL") {
        plot.dat$layer <- geom_boxplot()
      } else {
        plot.dat$layer <- geom_boxplot(mapping = aes(colour = values$df_data[[input$variable.color]]))
      }})
    }
     else if (input$plottype == "hist") {
       observeEvent(input$variable.color, {if (input$variable.color == "NULL") {
         plot.dat$layer <- geom_bar(stat = "identity")
       } else {
         plot.dat$layer <- geom_bar(mapping = aes(fill = values$df_data[[input$variable.color]]), stat = "identity", position = "dodge")
       }})
    } else if (input$plottype == "scat") {
      observeEvent(input$variable.color, {if (input$variable.color == "NULL") {
        plot.dat$layer <- geom_point()
      } else {
        plot.dat$layer <- geom_point(mapping = aes(colour = values$df_data[[input$variable.color]]), stat = "identity")
      }})
        }
   })
   
   observe({
     output$plot <- renderPlot({plot.dat$main + plot.dat$layer })
   })

 #--------------------------- summary table -------------------------
  output$summary <- renderPrint({ 
    summary(values$df_data)
  })
   
})
