library(tidyverse)

data <- read.csv("Naplan_Features.csv")

data$Statistical_Area_1 <- NULL
data$CENTRE_CODE <- NULL
data$v1 <- NULL
data$notstated <- NULL


data <- data %>%
  select(-starts_with("notapplicable")) %>%
  select(-starts_with("unlinkedrecord")) %>%
  select(-starts_with("notstated")) %>%
  select(-starts_with("inadequatelydescribed")) %>%
  select(-starts_with("X"))

data$oid_ <- NULL
data$cat <- NULL
data$target_fid <- NULL
data$join_count <- NULL
data$quadkey <- NULL
data$shape_area <- NULL
data$shape_length <- NULL
data$school_age_id <- NULL
data$calendar_year <- NULL
data$Calendar_Year <- NULL


data$v169 <- NULL
data$v234 <- NULL
data$v74 <- NULL
data$v78 <- NULL
data$v81 <- NULL

data <- data %>%
  select(-ends_with("PCTNMS"))
data$unique_code <- NULL