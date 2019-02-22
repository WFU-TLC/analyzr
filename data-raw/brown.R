# Description: Switchboard Dialogue Act Corpus
# Usage:
# Author: Jerid Francom
# Date: 2018-12-03

# SETUP -------------------------------------------------------------------

# Libraries
library(tidyverse)
library(readtext)
library(tidytext)
library(analyzr)

# RUN ---------------------------------------------------------------------

# Download data -----------------------------------------------------------

get_compressed_data(url = "https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/corpora/brown.zip", target_dir = "data-raw/original/brown/")


# Read data ---------------------------------------------------------------

# Text
text <-
  readtext(file = "data-raw/original/brown/*", verbosity = 0) %>% # read all files
  filter(str_detect(doc_id, "\\d+$")) %>%  # select only content files
  mutate(text = str_squish(text)) %>% # remove extra whitespace
  as_tibble() # avoid printing too much text to the Console

# Categories
categories <-
  read_delim(file = "data-raw/original/brown/cats.txt", delim = " ", col_names = c("doc_id", "category"))

# Join text and categories ------------------------------------------------

brown <- left_join(categories, text) # join `text` and `categories` by doc_id

# Create word-tag dataset -------------------------------------------------

brown_words <-
  brown %>%
  unnest_tokens(term, text, token = "regex", pattern = " ") %>% # tokenize by whitespace
  filter(!str_detect(term, "\\d")) %>% # remove tokens with numbers
  filter(!str_detect(term, "\\.$")) %>% # remove punctuation tokens
  separate(col = term, into = c("word", "tag"), sep = "/") %>%  # create word, tag columns
  filter(str_detect(word, "^\\w")) # words only

# Write data to csv -------------------------------------------------------

write_csv(brown, path = "data-raw/derived/brown.csv", col_names = TRUE)
write_csv(brown_words, path = "data-raw/derived/brown_words.csv", col_names = TRUE)
