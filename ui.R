library(shinythemes)



shinyUI(
   navbarPage("My first shiny app",
                    tabPanel("Plots and tables", 
                             fluidPage(theme = shinytheme("united"),
                               sidebarLayout(
                                 sidebarPanel(fileInput( "file", label = "Input your data" ),
                                        actionButton( "read", label = "Read table" ),
                                        br(),
                                        hr(),
                                        selectInput(inputId = "variable.x",label = "X axis:", choices = "Read table first", selected = "all"),
                                        selectInput(inputId = "variable.y",label = "Y axis:", choices = "Read table first", selected = "all"),
                                        selectInput(inputId = "variable.color",label = "Group by:",  choices = "Read table first", selected = "all"),
                                        width = 3),
                                 mainPanel(
                                   tabsetPanel(
                                     tabPanel("Table", br(), dataTableOutput( outputId = "table")),
                                     tabPanel("Plot",
                                              br(),
                                              radioButtons("plottype", 
                                                           label = "Select type of plot",
                                                           choices = list("Boxplot" = "box", 
                                                                          "Scatterplot" = "scat",
                                                                          "Histogram" = "hist"),
                                                           selected = 1, inline = TRUE),
                                              textOutput("warning"),
                                              plotOutput("plot", width = "auto" )
                                              ), 
                                     tabPanel("Summary", verbatimTextOutput("summary"))
                                     
                                   ))
                                  )
                                 )),
                    tabPanel("New panel",
                             "This is it "),
                    navbarMenu("Another new panel",
                               tabPanel("Sub-Component A", "This is it la la la"),
                               tabPanel("Sub-Component B"))
                    )

)

