#install.packages("tidyverse")
library(tidyverse)
library(dplyr)
library(readxl)
library(cmdstanr)
library(bayesplot)

census_2021 <- read_excel("data/neighbourhood-profiles-2021-158-model.xlsx", 
                                 sheet = 1)

census_2016 <- read.csv("data/neighbourhood-profiles-2016-140-model.csv")


break_in_data <- read.csv("data/Break_and_Enter_Open_Data_391431356942250275.csv", 
                          header = TRUE, 
                          stringsAsFactors = FALSE)

head(break_in_data)

census_2021_clean <- read_excel("data/neighbourhood-profiles-2021-158-model_clean.xlsx", 
                                sheet = 1)
colnames(census_2021_clean) <- gsub("\\.", " ", colnames(census_2021_clean))

break_in <- break_in_data %>%
  filter(REPORT_YEAR %in% c(2019,2020))

break_in <- break_in %>%
  mutate(
    OCC_DATE = mdy_hms(OCC_DATE, tz = "UTC"),
    REPORT_DATE = mdy_hms(REPORT_DATE, tz = "UTC"),
    delay = as.numeric(difftime(REPORT_DATE, OCC_DATE, units = "days")),
    night = ifelse(OCC_HOUR >= 19 | OCC_HOUR <= 3, 1, 0),
    OCC_DOW = trimws(OCC_DOW),
    weekend = ifelse(OCC_DOW %in% c("Saturday", "Sunday"), 1, 0),
    apartment = ifelse(PREMISES_TYPE == "Apartment", 1, 0),
    NEIGHBOURHOOD_158 = gsub(" \\(.*\\)", "", NEIGHBOURHOOD_158)
  )

income_rows <- census_2021_clean %>%
  filter(`Neighbourhood Name` %in% c(
    "Median total income in 2019 among recipients ($)",
    "Median total income in 2020  among recipients ($)"
  ))

income_long <- income_rows %>%
  pivot_longer(
    cols = -`Neighbourhood Name`,
    names_to = "NEIGHBOURHOOD_158",
    values_to = "income"
  ) %>%
  mutate(
    REPORT_YEAR = ifelse(grepl("2019", `Neighbourhood Name`), 2019, 2020)
  )


break_in_joined <- break_in %>%
  left_join(income_long, by = c("NEIGHBOURHOOD_158", "REPORT_YEAR")) %>%
  select(-`Neighbourhood Name`)

break_in_final <- break_in_joined %>%
  group_by(NEIGHBOURHOOD_158, REPORT_YEAR) %>%
  summarise(
    crime_count = n(),                   
    avg_delay = mean(delay, na.rm = TRUE),
    prop_night = mean(night),            
    prop_weekend = mean(weekend),
    prop_apartment = mean(apartment),
    income = as.numeric(first(income)))

break_in_std <-break_in_final %>%
  ungroup() %>% 
  mutate(across(
    .cols = c(income, avg_delay, prop_night,prop_weekend, prop_apartment),
    .fns = ~ (. - mean(., na.rm = TRUE)) / sd(., na.rm = TRUE)
  ))

break_in_std <- break_in_std %>% 
  filter(NEIGHBOURHOOD_158 != "NSA")


summary(break_in_std)

colSums(is.na(break_in_std))

# we lose 4 neighbourhoods
# later: add priors for these from prior census if possible?