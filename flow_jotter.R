
# Script to automate plotting MFI, %, N plots from FlowJo -----------------
# Sam Old, 29th Sep 2022 --------------------------------------------------

rm(list = ls()); "Clearing local memory in R";

# Functions required for this script --------------------------------------

# Check the last row is formatted & apply filter --------------------------
check_plotrow <- function(xs = NULL, sheet = NULL) {

  if (tolower(xs[nrow(xs),1]) == "plot") {

    xs[nrow(xs),1] <- tolower(xs[nrow(xs),1])
    xs <- xs[,tolower(as.character(xs[nrow(xs),])) %in% c("plot", "y")]
    xs <- slice_head(xs, n = (nrow(xs) - 1))

  } else {
    cat("\nLast row does not contain optional plot status. Sheet: ", sheet, "\n")
  }
  return(xs)
}

# Remove and report columns with duplications/error prone symbols ---------
clean_columns <- function(pd = NULL) {

  cn <- colnames(pd)
  if (length(cn[duplicated(cn)]) > 0) {
    cat("\n\tDuplicated colnames:   ", cn[duplicated(cn)], "\n")
  }
  if (length(cn[grep("\\/", cn)]) > 0) {
    cat('\n\tColnames with a "/":   ', cn[grep("\\/", cn)], "\n")
  }

  removed <- c(cn[duplicated(cn)], cn[grep("\\/", cn)])
  if(length(removed) > 0 ) {
    cat("\nRemoved columns:   ", removed)
  }

  pd <- pd[,cn[!cn %in% removed]]
  return(pd)
}


# Load packages and data for script ---------------------------------------

# Package install instructions:
#   Update all/some/none? [a/s/n]: a
#   Do you want to install from sources the
#     packages which need compilation? (Yes/no/cancel): no

if (!require("tidyverse", quietly = TRUE))
  install.packages("tidyverse", dependencies = TRUE)
if (!require("readxl", quietly = TRUE))
  install.packages("readxl")
if(!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
if(!require("ggcyto", quietly = TRUE))
  BiocManager::install("ggcyto")

library(ggcyto)
library(readxl)
library(tidyverse)

# Select your excel file from flowjo
excel_file <- file.choose()
file_loc <- dirname(excel_file)
setwd(file_loc)

# Read, filter, clean and prepare plot_data -------------------------------

# Read in all excel data, and apply plotting filters
sheets      <- readxl::excel_sheets(excel_file)
excel_sheet <- read_excel(path = excel_file, sheet = sheets[1]) %>%
  rename(`Samples` = `...1`) %>%
  select(where(~!all(is.na(.x)))) %>%
  check_plotrow(xs = ., sheet = sheets[1])

# Merge Additional excel sheets for plotting
if (length(sheets) > 1) {

  for (i in 2:length(sheets)) {

    additional_sheet <- read_excel(path = excel_file, sheet = sheets[i]) %>%
      rename(`Samples` = `...1`) %>%
      select(where(~!all(is.na(.x)))) %>%
      check_plotrow(xs = ., sheet = sheets[i])

    excel_sheet <- left_join(excel_sheet, additional_sheet, by = "Samples")
  }
}

# Factorise Samples for plot grouping
plot_data <- excel_sheet %>%
  mutate(Samples = factor(gsub("\\_.*", "", Samples)))

# Filter columns with error prone names
plot_data <- clean_columns(plot_data)


# Create each plot --------------------------------------------------------

if (dir.exists(paths = paste0(file_loc, "/flow_jotter_plots"))) {
  unlink(paste0(file_loc, "/flow_jotter_plots"), recursive = TRUE)
  cat("Deleted folder", paste0(file_loc, "/flow_jotter_plots"), "without backup")
}

dir.create(paste0(file_loc, "/flow_jotter_plots"))
setwd(paste0(file_loc, "/flow_jotter_plots"))
cat("Creating folder", paste0(file_loc, "/flow_jotter_plots"), "to store saved images")

error_columns <- NULL;
for (i in 2:ncol(plot_data)) {
  plot_data_temp <- plot_data[,c(1, i)]
  label <- colnames(plot_data_temp)[2]

  if (substr(label, 1, 1) == "%") {

    cat("\n\tWriting Percentage plot to /flow_jotter_plots/:", label)
    g <- ggplot(plot_data_temp,
           aes(x = Samples, y = as.numeric(!!sym(label)), colour = Samples)) +
      scale_colour_grey() +
      labs(title = paste("Percentage", substr(label, 3, 1000000L))) +
      ylab("Percentage") +
      scale_y_continuous(limits = c(0, NA),
                         expand = expansion(mult = c(0, .1))) +
      # geom_boxplot(outlier.alpha = 0, show.legend = NA) +
      geom_jitter(height = 0, width = 0.1, size = 3, alpha = 0.8) +
      theme_bw()

    label <- paste("Percentage", substr(label, 3, 1000000L))

  } else if (substr(label, 1, 1) == "N") {

    cat("\n\tWriting Number plot to /flow_jotter_plots/:", label)
    g <- ggplot(plot_data_temp,
           aes(x = Samples, y = as.numeric(!!sym(label)), colour = Samples)) +
      scale_colour_grey() +
      labs(title = label) +
      ylab("Number") +
      scale_y_continuous(limits = c(0, NA),
                         expand = expansion(mult = c(0, .1))) +
      # geom_boxplot(outlier.alpha = 0, show.legend = NA) +
      geom_jitter(height = 0, width = 0.1, size = 3, alpha = 0.8) +
      theme_bw()

  } else if (substr(label, 1, 1) == "M") {

    # Create an MFI plot
    cat("\n\tWriting MFI plot to /flow_jotter_plots/:", label)
    g <- ggplot(plot_data_temp,
               aes(x = Samples, y = as.numeric(!!sym(label)), colour = Samples)) +
      scale_colour_grey() +
      labs(title = label) +
      ylab("MFI (biexponential)") +
      geom_jitter(height = 0, width = 0.1, size = 3, alpha = 0.8) +
      scale_y_flowjo_biexp(
        limits = c(
          min(0, min(as.numeric(plot_data_temp[[label]])) * 1.1),
          max(as.numeric(plot_data_temp[[label]]))*1.1)) +
      theme_bw()
  } else {
    error_columns <- c(error_columns, label)
  }

  ggsave(filename = paste0(file_loc, "/flow_jotter_plots/", label, ".pdf"),
         plot = g, device = "pdf", units = "in",
         height = 5, width = 5)
}

if (length(error_columns != 0)) {
  cat('\nThe following columns do not start with either "%", "M", or "N":\n\t', error_columns)
}

setwd(file_loc)

