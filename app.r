library(here)
library(readr)
library(dplyr)
library(shiny)
library(bslib)
library(querychat)
library(stringr)
library(ellmer)

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

wser_results <- read_csv(here("data","wser_split_data_2017_2025.csv")) %>% 
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
  ) %>% 
  mutate(across(.cols = year, .fns = as.integer))

wser_results <- convert_duration_columns(wser_results) 

# replace NA:NA:NA string times
wser_results <- wser_results %>%
  mutate(across(ends_with("_time"), function(x) {
    x[x == "NA:NA:NA"] <- NA
    return(x)
  }))

wser_results <- wser_results %>%
  mutate(
    across(
      contains("time"),
      ~ str_pad(.x, width = 8, side = "left", pad = "0")
    )
  )

GOOGLE_API_KEY <- Sys.getenv("GOOGLE_API_KEY")
OPENROUTER_API_KEY <- Sys.getenv("OpenRouter")

# Create QueryChat object with the new R6 API
qc <- QueryChat$new(
  data_source = wser_results,
  table_name = "wser_results",
  # greeting = paste(readLines("greeting.md"), collapse = "\n"),
  greeting = "greeting.md",
  data_description = paste(readLines("data_description.md"), collapse = "\n"),
  # client = ellmer::chat_google_gemini(model = "gemini-flash-latest")
  client = ellmer::chat_openrouter(model = "x-ai/grok-code-fast-1")
)

ui <- page_fillable(
  card(
    full_screen = TRUE,
    card_header(h4("Chat with Western States Endurance Run (",tags$a("WSER", href = "https://www.wser.org/",target = "_blank", rel = "noopener noreferrer")," ) Data", align = "center"),
                h6("This dashboard leverages the remarkable open source work of ",tags$a("Posit Software, PBC", href = "https://posit.co/",target = "_blank", rel = "noopener noreferrer"),"
    and is licensed under the Creative Commons Attribution-NonCommercial 4.0 International license. It can be accredited to \"Drew Coughlin\" using this ",
                   tags$a("URL", href = "https://drewsdata.github.io/", target = "_blank", rel = "noopener noreferrer"),
                   ". Underlying data is sourced from ",tags$a("here", href = "https://www.wser.org/splits/", target = "_blank", rel = "noopener noreferrer"),
                   " and relies on the work of many time keeping volunteers at WSER checkpoints. The data set contains race years 2017 to 2025 except 2020 (Covid cancellation). Aid stations 'Dardanelles' ('Cal-1') and 'Ford\'s Bar' ('Cal-3') are excluded.",align = "left")
    ),
    layout_sidebar(
      border = TRUE,
      border_color = "#4682B4",
      bg = "white",
      sidebar = qc$sidebar(width = "33%"),
      DT::DTOutput("dt")
    )
  )
)

server <- function(input, output, session) {
  qc_vals <- qc$server()
  
  output$dt <- DT::renderDT({
    DT::datatable(qc_vals$df(), rownames = FALSE)
  })
}

shinyApp(ui = ui, server = server)