library(shinythemes)

shinyUI(
   navbarPage("Data viewer",
                    tabPanel("Tables", 
                             fluidPage(theme = shinytheme("united"),
                                       sidebarLayout(
                                         sidebarPanel(fileInput( "file", label = "Input your data" ),
                                                      actionButton( "read", label = "Read table" ),
                                                      br(),
                                                      hr(),
                                                      uiOutput(outputId = "factorcheckboxes"),
                                                      width = 3),
                                         mainPanel(
                                           tabsetPanel(
                                             tabPanel("Table", br(), dataTableOutput( outputId = "table")),
                                             tabPanel("Summary", verbatimTextOutput("summary"))
                                             
                                           ))
                                       )
                             )),
                    tabPanel("Plots",
                             fluidPage(theme = shinytheme("united"),
                                       sidebarLayout(
                                         sidebarPanel(
                                           radioButtons("plottype", 
                                                        label = "Select type of plot",
                                                        choices = list("Boxplot" = "box", 
                                                                       "Scatterplot" = "scat",
                                                                       "Histogram" = "hist"),
                                                        selected = 1, inline = TRUE),
                                           hr(),
                                           br(),
                                           selectInput(inputId = "variable.x", label = "Select X variable:", choices = "Please read file with your data", selected = "all"),
                                           selectInput(inputId = "variable.y", label = "Select Y variable:", choices = "Please read file with your data", selected = "all"),
                                           selectInput(inputId = "variable.color",  label = "Group by:", choices = "Please read file with your data", selected = "all"),
                                           width = 3
                                                      ),
                                         mainPanel(
                                           tabsetPanel(
                                             tabPanel("Plot",
                                                      br(),
                                                      
                                                      plotOutput("plot", width = "auto" ), 
                                                      uiOutput(outputId = "downloadbutton")
          
                                             ), 
                                             tabPanel("Empty", br()),
                                             tabPanel("Empty", br())
                                           ))
                                       )
                             )),
                    navbarMenu("Another new panel",
                               tabPanel("Sub-Component A", "This is it la la la"),
                               tabPanel("Sub-Component B"))
                    )

)

