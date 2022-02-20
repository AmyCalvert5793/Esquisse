

library(shinythemes)
library(esquisse)
library(modeldata)
library(shiny)
library(dplyr)
library(httr)


#Data upon opening
req <- httr::GET(url = "https://cran.ocpu.io/MASS/data/Boston/json")
req_parsed <- httr::content(req, type = "application/json")

boston <- dplyr::bind_rows(req_parsed)


#Shiny Esquisse
ui <- fluidPage(theme = shinytheme("cerulean"),
    titlePanel("Visualize the Boston Dataset"),
    sidebarLayout(
        sidebarPanel(
            radioButtons(
                inputId = "data",
                label = "Choose Data:",
                choices = c("Boston", "BostonHigh"),
                inline = TRUE
            )
        ),
        mainPanel(
            tabsetPanel(
                tabPanel(
                    title = "Build Graph",
                    esquisserUI(
                        id = "esquisse",
                        header = FALSE, #don't display gadget title
                        choose_data = FALSE # dont display button to change data
                    )
                ),
                tabPanel(
                    title = "Output",
                    verbatimTextOutput("module_out")
                )
            )
        )
    )
)

#Call data depending on user input.
server <- function(input, output, session) {
    data_r <- reactiveValues(data = boston, name = "Boston")
    observeEvent(input$data, {
        if (input$data == "Boston") {
            
            req <- httr::GET(url = "https://cran.ocpu.io/MASS/data/Boston/json")
            req_parsed <- httr::content(req, type = "application/json")
            
            
            boston <- dplyr::bind_rows(req_parsed)
            
            data_r$data <- boston
            data_r$name <- "Boston"
        } else {
            
            #Currently a placeholder, filters Boston dataset to only rows where tax >300
            
            library(dplyr)
            #req <- httr::GET(url = "https://cran.ocpu.io/MASS/data/Boston/json")
            #req_parsed <- httr::content(req, type = "application/json")
            
            
            #bostonhigh <- dplyr::bind_rows(req_parsed)%>%filter(tax>=300)
            bostonhigh <- boston%>%filter(tax>=300)
            
            data_r$data <- bostonhigh
            data_r$name <- "BostonHigh"
        }
    })
    result <- callModule(
        module = esquisserServer,
        id = "esquisse",
        data = data_r
    )
    output$module_out <- renderPrint({
        str(reactiveValuesToList(result))
    })
}
#Launches app in the browser
runApp(list(ui=ui,server=server), launch.browser=TRUE)
#shinyApp(ui, server)