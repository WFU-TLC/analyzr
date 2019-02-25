# Description:
# Usage:
# Author: Jerid Francom
# Date: 2019-02-24

# SETUP -------------------------------------------------------------------

# Libraries
library(tidyverse)
library(analyzr)

# RUN ---------------------------------------------------------------------

# Download/ decompress data
# Source: http://www.dt.fee.unicamp.br/~tiago/smsspamcollection/
get_compressed_data(url = "http://www.dt.fee.unicamp.br/~tiago/smsspamcollection/smsspamcollection.zip", target_dir = "data-raw/original/sms/")

# Read data
sms <-
  read_tsv(file = "data-raw/original/sms/SMSSpamCollection.txt", col_names = c("sms_type", "message"), trim_ws = TRUE)

# Write data
write_csv(sms, path = "data-raw/derived/sms.csv", col_names = TRUE)
usethis::use_data(sms)
