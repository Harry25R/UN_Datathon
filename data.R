library(readxl)
library(tidyverse)

qsa.clean <- data.frame()
my.col <- NULL
# QLD 2008 - 2011
for (idx in 8:11) {
  if (idx <= 9)
    qsa <- read_xlsx(paste0("./NAPLAN_OUTCOMES_PER_SCHOOL/qsa_stats_naplan_0", idx, "_outcomes.xlsx"))
  else
    qsa <- read_xlsx(paste0("./NAPLAN_OUTCOMES_PER_SCHOOL/qsa_stats_naplan_", idx, "_outcomes.xlsx"))
  
  qsa <- as.data.frame(qsa)
  
  for (i in 11:nrow(qsa)) {
    if (!is.na(qsa[i,2])) {
      if (qsa[i,1] == "School") {
        next
      } else {
        entry <- list()
        entry$year <- idx
        entry$school <- qsa[i,1]
        entry$locality <- qsa[i,2]
        # number of enrolments
        entry$enrol <- sum(as.numeric(qsa[i,4:7]))
        entry$Y3.read <- as.numeric(qsa[(i+1),8])
        entry$Y3.writ <- as.numeric(qsa[(i+1),9])
        entry$Y3.spel <- as.numeric(qsa[(i+1),10])
        entry$Y3.gp <- as.numeric(qsa[(i+1),11])
        entry$Y3.nmcy <- as.numeric(qsa[(i+1),12])
        entry$Y5.read <- as.numeric(qsa[(i+1),13])
        entry$Y5.writ <- as.numeric(qsa[(i+1),14])
        entry$Y5.spel <- as.numeric(qsa[(i+1),15])
        entry$Y5.gp <- as.numeric(qsa[(i+1),16])
        entry$Y5.nmcy <- as.numeric(qsa[(i+1),17])
        entry$Y7.read <- as.numeric(qsa[(i+1),18])
        entry$Y7.writ <- as.numeric(qsa[(i+1),19])
        entry$Y7.spel <- as.numeric(qsa[(i+1),20])
        entry$Y7.gp <- as.numeric(qsa[(i+1),21])
        entry$Y7.nmcy <- as.numeric(qsa[(i+1),22])
        entry$Y9.read <- as.numeric(qsa[(i+1),23])
        entry$Y9.writ <- as.numeric(qsa[(i+1),24])
        entry$Y9.spel <- as.numeric(qsa[(i+1),25])
        entry$Y9.gp <- as.numeric(qsa[(i+1),26])
        entry$Y9.nmcy <- as.numeric(qsa[(i+1),27])
        my.col <- colnames(as.data.frame(entry))
        entry <- as.data.frame(entry) %>%
          pivot_longer(cols = -c(school, locality, year, enrol), names_to = "Achievement")
        qsa.clean <- rbind(qsa.clean, entry)
      }
    }
  }
}


qld.location <- read.csv("./NAPLAN_OUTCOMES_PER_SCHOOL/UniqueLocalitiesQLD.csv")
qcaa.clean <- data.frame()
# 2012 - 2019
for (idx in 12:19) {
  if (idx == 12)
    qcaa <- read_xlsx(paste0("./NAPLAN_OUTCOMES_PER_SCHOOL/qsa_stats_naplan_", idx, "_outcomes.xlsx"))
  else if (idx == 13)
    qcaa <- read.csv(paste0("./NAPLAN_OUTCOMES_PER_SCHOOL/qsa_stats_naplan_", idx, "_outcomes.csv"))
  else
    qcaa <- read.csv(paste0("./NAPLAN_OUTCOMES_PER_SCHOOL/qcaa_stats_naplan_", idx, "_outcomes.csv"))
  
  # find those in QLD
  qcaa$LOCALITY <- toupper(qcaa$LOCALITY) %>%
    parse_character()
  if (idx == 12) {
    qcaa <- qcaa %>%
      filter(LOCALITY %in% qld.location$Suburb) %>%
      mutate(enrol = as.numeric(Yr3)+as.numeric(Yr5)+as.numeric(Yr7)+as.numeric(Yr9)) %>%
      select(School, LOCALITY, enrol, ends_with("_score")) 
    
    qcaa <- qcaa %>%
      # pass rate use only
      # mutate(across(ends_with("_score"), ~./100)) %>%
      mutate(year = idx, .before = 1)
    
  } else {
    qcaa <- qcaa %>%
      filter(LOCALITY %in% qld.location$Suburb) %>%
      mutate(enrol = as.numeric(YR3ENR)+as.numeric(YR5ENR)+as.numeric(YR7ENR)+as.numeric(YR9ENR)) %>%
      # select(SCHOOL, enrol, ends_with("PCTNMS")) 
      select(SCHOOL, LOCALITY, enrol, ends_with("MEAN")) 
    qcaa <- qcaa %>%
      # mutate(across(ends_with("PCTNMS"), parse_number)) %>%
      # mutate(across(ends_with("PCTNMS"), ~./100)) %>%
      mutate(year = idx, .before = 1)
  }
  colnames(qcaa) <- my.col
  qcaa <- qcaa %>%
    pivot_longer(cols = -c(school, year, locality, enrol), names_to = "Achievement")
    
  qcaa.clean <- rbind(qcaa.clean, qcaa)
}

# 
final.qld <- rbind(qsa.clean, qcaa.clean)
sum(is.na(final.qld$value))

final.qld <- final.qld %>%
  distinct(school, locality, Achievement, year, .keep_all = T)
saveRDS(final.qld, "final.qld.rds")

