library(shinythemes)

shinyUI(
   navbarPage("My first shiny app",
                    tabPanel("Plots and tables", 
                             fluidPage(theme = shinytheme("united"),
                               sidebarLayout(
                                 sidebarPanel(fileInput( "file", label = "Input your data" ),
                                              #helpText(h6("To load file, click - Read table button")),
                                        actionButton( "read", label = "Read table" ),
                                        br(),
                                        hr(),
                                        uiOutput(outputId="sel.x"), 
                                        uiOutput(outputId="sel.y"),
                                        uiOutput(outputId="sel.col")
                                        ,width = 3),
                                 mainPanel(
                                   tabsetPanel(
                                     tabPanel("Table", br(), dataTableOutput( outputId = "table")),
                                     tabPanel("Plot",
                                              br(),
                                              radioButtons("plottype", 
                                                           label = "Select type of plot",
                                                           choices = list("Boxplot" = 1, 
                                                                          "Scatterplot" = 2,
                                                                          "Histogram" = 3),
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

