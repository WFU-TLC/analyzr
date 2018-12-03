# Description:
# Usage:
# Author: Jerid Francom
# Date: 2018-12-03


# SETUP -------------------------------------------------------------------

# Libraries

pacman::p_load(tidyverse, tidytext)

# Custom functions

get_compressed_data <- function(url, target_dir, force = FALSE) {
  # Get the extension of the target file
  ext <- tools::file_ext(url)
  # Check to see if the target file is a compressed file
  if(!ext %in% c("zip", "gz", "tar")) stop("Target file given is not supported")
  # Check to see if the data already exists
  if(!dir.exists(target_dir) | force == TRUE) { # if data does not exist, download/ decompress
    cat("Creating target data directory \n") # print status message
    dir.create(path = target_dir, recursive = TRUE, showWarnings = FALSE) # create target data directory
    cat("Downloading data... \n") # print status message
    temp <- tempfile() # create a temporary space for the file to be written to
    download.file(url = url, destfile = temp) # download the data to the temp file
    # Decompress the temp file in the target directory
    if(ext == "zip") {
      unzip(zipfile = temp, exdir = target_dir, junkpaths = TRUE) # zip files
    } else {
      untar(tarfile = temp, exdir = target_dir) # tar, gz files
    }
    cat("Data downloaded! \n") # print status message
  } else { # if data exists, don't download it again
    cat("Data already exists \n") # print status message
  }
}


extract_sdac_metadata <- function(file) {
  # Function: to read a Switchboard Corpus Dialogue file and extract meta-data
  cat("Reading", basename(file), "...")

  # Read `file` by lines
  doc <- read_lines(file)

  # Extract `doc_id`, `speaker_a_id`, and `speaker_b_id`
  doc_speaker_info <-
    doc[str_detect(doc, "\\d+_\\d+_\\d+")] %>% # isolate pattern
    str_extract("\\d+_\\d+_\\d+") %>% # extract the pattern
    str_split(pattern = "_") %>% # split the character vector
    unlist() # flatten the list to a character vector
  doc_id <- doc_speaker_info[1] # extract `doc_id`
  speaker_a_id <- doc_speaker_info[2] # extract `speaker_a_id`
  speaker_b_id <- doc_speaker_info[3] # extract `speaker_b_id`

  # Extract `text`
  text_start_index <- # find where header info stops
    doc %>%
    str_detect(pattern = "={3,}") %>% # match 3 or more `=`
    which() # find vector index

  text_start_index <- text_start_index + 1 # increment index by 1
  text_end_index <- length(doc) # get the end of the text section

  text <- doc[text_start_index:text_end_index] # extract text
  text <- str_trim(text) # remove leading and trailing whitespace
  text <- text[text != ""] # remove blank lines

  data <- data.frame(doc_id, text) # tidy format `doc_id` and `text`

  data <- # extract column information from `text`
    data %>%
    mutate(damsl_tag = str_extract(string = text, pattern = "^.+?\\s")) %>%  # extract damsl tags
    mutate(speaker_turn = str_extract(string = text, pattern = "[AB]\\.\\d+")) %>% # extract speaker_turn pairs
    mutate(utterance_num = str_extract(string = text, pattern = "utt\\d+")) %>% # extract utterance number
    mutate(utterance_text = str_extract(string = text, pattern = ":.+$")) %>%  # extract utterance text
    select(-text)

  data <- # separate speaker_turn into distinct columns
    data %>%
    separate(col = speaker_turn, into = c("speaker", "turn_num"))

  data <- # clean up column information
    data %>%
    mutate(damsl_tag = str_trim(damsl_tag)) %>% # remove leading/ trailing whitespace
    mutate(utterance_num = str_replace(string = utterance_num, pattern = "utt", replacement = "")) %>% # remove 'utt'
    mutate(utterance_text = str_replace(string = utterance_text, pattern = ":\\s", replacement = "")) %>% # remove ': '
    mutate(utterance_text = str_trim(utterance_text)) # trim leading/ trailing whitespace

  data <- # link speaker with speaker_id
    data %>%
    mutate(speaker_id = case_when(
      speaker == "A" ~ speaker_a_id,
      speaker == "B" ~ speaker_b_id
    ))
  cat(" done.\n")
  return(data) # return the data frame object
}

# RUN ---------------------------------------------------------------------


# Download data -----------------------------------------------------------

get_compressed_data(url = "https://catalog.ldc.upenn.edu/docs/LDC97S62/swb1_dialogact_annot.tar.gz",
                    target_dir = "data-raw/original/sdac/")


# Organize data -----------------------------------------------------------

# From corpus files

files <- # Get the target files to extract the data from
  list.files(path = "data-raw/original/sdac", # path to main directory
             pattern = "\\.utt", # files to match
             full.names = TRUE, # extract full path to each file
             recursive = TRUE) # drill down in each sub-directory of `sdac/`

sdac_files <- # Read files and return a tidy dataset
  files %>% # pass file names
  map(extract_sdac_metadata) %>% # read and tidy iteratively
  bind_rows() # bind the results into a single data frame

# Write as plain text (.csv) format
write_csv(sdac_files, path = "data-raw/derived/sdac_files.csv")

# Download metadata

sdac_speaker_meta <- # get metadata from url
  read_csv(file = "https://catalog.ldc.upenn.edu/docs/LDC97S62/caller_tab.csv",
           col_names = c("speaker_id", # changed from `caller_no`
                         "pin",
                         "target",
                         "sex",
                         "birth_year",
                         "dialect_area",
                         "education",
                         "ti",
                         "payment_type",
                         "amt_pd",
                         "con",
                         "remarks",
                         "calls_deleted",
                         "speaker_partition"))

sdac_speaker_meta <- # move `speaker_id` to the first column
  sdac_speaker_meta %>%
  select(as.character(speaker_id), everything())

# Write as plain text (.csv) format

write_csv(sdac_speaker_meta, path = "data-raw/derived/sdac_speaker_meta.csv")

# Merge corpus and metadata -----------------------------------------------

sdac_files$speaker_id <- # convert to integer
  sdac_files$speaker_id %>%
  as.numeric()

sdac <- # join by `speaker_id`
  left_join(sdac_files, sdac_speaker_meta)

# Write as plain text (.csv) format

write_csv(sdac, path = "data-raw/derived/sdac.csv")
