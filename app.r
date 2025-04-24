library(here)
library(readr)
library(dplyr)
library(shiny)
library(bslib)
library(querychat)
library(stringr)

# Function to convert duration-style time columns
convert_duration_columns <- function(df) {
  # Get column names that end with "_time"
  time_cols <- names(df)[str_detect(names(df), "_time$")]
  
  # Loop through each time column and apply the conversion
  for (col in time_cols) {
    df <- df %>% 
      mutate(across(
        all_of(col),
        ~{
          # Split the time string by colon
          parts <- str_split(., ":", simplify = TRUE)
          
          # Convert to numeric and calculate total seconds
          if(ncol(parts) == 3) {
            hours <- as.numeric(parts[,1])
            minutes <- as.numeric(parts[,2])
            seconds <- as.numeric(parts[,3])
          } else if(ncol(parts) == 2) {
            hours <- as.numeric(parts[,1])
            minutes <- as.numeric(parts[,2])
            seconds <- 0
          } else {
            hours <- as.numeric(.)
            minutes <- 0
            seconds <- 0
          }
          
          # Format with potentially more than 24 hours
          sprintf("%d:%02d:%02d", hours, minutes, seconds)
        },
        .names = "{.col}"
      ))
  }
  
  return(df)
}

wser_results <- read_csv(here("data","wser_split_data_2017_2024.csv")) %>% 
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

wser_results <- convert_duration_columns(wser_results) 

# replace NA:NA:NA string times
wser_results <- wser_results %>%
  mutate(across(ends_with("_time"), function(x) {
    x[x == "NA:NA:NA"] <- NA
    return(x)
  }))

GOOGLE_API_KEY <- Sys.getenv("GOOGLE_API_KEY")

# 1. Configure querychat. This is where you specify the dataset and can also
#    override options like the greeting message, system prompt, model, etc.
# querychat_config <- querychat_init(mtcars,
querychat_config <- querychat_init(wser_results,
                                   greeting = readLines("greeting.md"),
                                   data_description = readLines("data_description.md"),
                                   create_chat_func = purrr::partial(ellmer::chat_gemini, model = "gemini-2.0-flash"))

ui <- page_sidebar(
  # 2. Use querychat_sidebar(id) in a bslib::page_sidebar.
  #    Alternatively, use querychat_ui(id) elsewhere if you don't want your
  #    chat interface to live in a sidebar.
  sidebar = querychat_sidebar("chat", width = "40%"),
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