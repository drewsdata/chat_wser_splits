library(here)
library(readr)
library(dplyr)
library(shiny)
library(bslib)
library(querychat)

wser_results <- read_csv(here("/home/drew/projects/r/querychat_wser_splits/data/wser_split_data_2017_2024.csv")) %>% 
  mutate(
    time = case_when(
    time == "dnf" ~ "DNF",
    TRUE ~ time
  )) %>% 
  mutate(
    buckle_type = case_when(
      time < "24:00:00" ~ "silver",
      time > "24:00:00" & time < "30:00:00" ~ "bronze",
      time == "DNF" ~ "no buckle",
      TRUE ~ "no buckle"
    )
  )

# 1. Configure querychat. This is where you specify the dataset and can also
#    override options like the greeting message, system prompt, model, etc.
# querychat_config <- querychat_init(mtcars,
querychat_config <- querychat_init(wser_results,
                                   create_chat_func = purrr::partial(ellmer::chat_gemini, model = "gemini-2.0-flash"))

ui <- page_sidebar(
  # 2. Use querychat_sidebar(id) in a bslib::page_sidebar.
  #    Alternatively, use querychat_ui(id) elsewhere if you don't want your
  #    chat interface to live in a sidebar.
  sidebar = querychat_sidebar("chat"),
  DT::DTOutput("dt")
)

server <- function(input, output, session) {
  
  # 3. Create a querychat object using the config from step 1.
  querychat <- querychat_server("chat", querychat_config)
  
  output$dt <- DT::renderDT({
    # 4. Use the filtered/sorted data frame anywhere you wish, via the 
    #    querychat$df() reactive.
    DT::datatable(querychat$df())
  })
}

shinyApp(ui, server)