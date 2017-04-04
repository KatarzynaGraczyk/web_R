options(shiny.maxRequestSize = 1000 * 1024 ^ 2)

library(ggplot2)
library(data.table)


shinyServer(function(input, output, session) {

#-------------------------------- Table reading ---------------------------
  
  values <- reactiveValues(df_data = NULL, sel.table = NULL)
  
  # read data 
  observeEvent(input$read, 
               {if (is.null(input$file$datapath) == FALSE) {
                  progress <- Progress$new(session, min = 1, max = 15)
                  on.exit(progress$close())
                  progress$set(message = 'Reading table in progress ...')
                  values$df_data <- NULL
                  if (length(scan(input$file$datapath, what = "character", nmax = 2)) > 0) {
                    values$df_data <- fread(input$file$datapath,  h = T)
                  }
                  }
                 }
               )
  
  # check if a user read data
  check.data <- reactive({
    validate(
      need(is.null(values$df_data) == FALSE, "Please read file with your data")#,
      #need(is.null(values$df_data) == FALSE & is.null(input$file$datapath) == FALSE, "Readed empty file. Please read file with your data")
    )
  })
  
  # render button box 
  output$factorcheckboxes <- renderUI({
    check.data()
    factornames <- colnames(values$df_data)
    radioButtons(inputId = "variable",
                 label = "Select one from avaliable variables:", 
                 choices = factornames, 
                 selected = "all", 
                 inline = FALSE 
                 )
  })
  
  check.variable <- reactive({
    validate(
      need(length(input$variable) > 0, "")
    )
  })
  
  # render selection of variables to remove
  output$factorselect <- renderUI({ 
    check.variable()
    levelnames <- unique(values$df_data[[input$variable]])
    selectInput(inputId = "factors", 
                label = "Select group of variables to remove:", 
                choices = levelnames, 
                multiple = T
                )
    })
  
  # if the user select values to remove, this function filter out this selected rows
  observeEvent(input$factors, {
    if ( is.null(input$factors)) {
      values$sel.table = NULL
    } else {
    values$sel.table <- values$df_data[-which(values$df_data[[input$variable]] %in% input$factors), ]
    }
    })
  
  # rendering table, if some values are excluded by user changed table is rendered
  output$table = renderDataTable({
    if (is.null(input$factors)) {
      values$df_data
    } else {
      values$sel.table 
    }
  })
  
# -------------------------- UI rendering - update select input - PLOTS ----------------------

  # render new variables names in plot tabs
  observe({
    check.data()
    updateSelectInput(session, "variable.x", choices = colnames(values$df_data))
    updateSelectInput(session, "variable.y",  choices = colnames(values$df_data))
    updateSelectInput(session, "variable.color", choices = c("NULL",colnames(values$df_data)))
  })

#-------------------------------------- PLOTS -------------------------------------------
  
  # crete reactive values to store readed data
  plot.dat <- reactiveValues(main = NULL, layer = NULL)
  
  # define input to render plot
  observeEvent(input$plottype, {
    # define general layout of plot
    plot.dat$main <- ggplot(data = values$df_data, 
                            mapping = aes(x = values$df_data[[input$variable.x]], 
                                          y = values$df_data[[input$variable.y]]
                                          )
                            ) + 
      theme(axis.text.x = element_text(angle = 90, hjust = 0.5), 
            plot.title = element_text(hjust = 0.5)
            ) +
      labs(list(title = paste(input$variable.x, "vs" ,input$variable.y, sep = " "), 
                x = input$variable.x, 
                y = input$variable.y, 
                color = "Group by:\n")
           )
    
    # define plot GEOMETRY
    if (input$plottype == "box") {
        observeEvent(input$variable.color, {
          if (input$variable.color == "NULL") {
            plot.dat$layer <- geom_boxplot()
            } else {
              plot.dat$layer <- geom_boxplot(mapping = aes(colour = values$df_data[[input$variable.color]]))
            }
          }
        )
      }
    
    if (input$plottype == "hist") {
       observeEvent(input$variable.color, {
         if (input$variable.color == "NULL") {
           plot.dat$layer <- geom_bar(stat = "identity")
         } else {
           plot.dat$layer <- geom_bar(mapping = aes(fill = values$df_data[[input$variable.color]]), 
                                      stat = "identity", 
                                      position = "dodge")
           }
         }
       )
    }
    
    if (input$plottype == "scat") {
      observeEvent(input$variable.color, {
        if (input$variable.color == "NULL") {
          plot.dat$layer <- geom_point()
          } else {
            plot.dat$layer <- geom_point(mapping = aes(colour = values$df_data[[input$variable.color]]), 
                                         stat = "identity")
            }
        }
      )
    }
    
    # download button 
    output$downloadbutton <- renderUI({
      check.data()
      downloadButton(outputId = "download", 
                     label = " Download the plot")
      })
    })
   
  # download parameter generation
   observe({
     check.data()
     output$plot <- renderPlot({plot.dat$main + plot.dat$layer})
     output$download <- downloadHandler(
       # specify the file name
       filename = function() {
         # paste("output", input$format)
         if (input$plottype == "box") {
           paste("boxplot_", input$variable.x,"_vs_", input$variable.y, ".png", sep = "")
         } else if (input$plottype == "hist") {
           paste("histogram_", input$variable.x,"_vs_", input$variable.y,  ".png", sep = "")
         } else if (input$plottype == "scat") {
           paste("scatterplot_",  input$variable.x,"_vs_", input$variable.y, ".png", sep = "")
         }
       } , 
       content = function(file) {
         # open the divice
         # create the plot
         # close the divice
         png(file, width = 1200, height = 800, units = "px")
         print(plot.dat$main + plot.dat$layer )
         dev.off()
         }
       )
     })

  
 #--------------------------- summary table -------------------------
  output$summary <- renderPrint({ 
    summary(values$df_data)
  })
   
})
