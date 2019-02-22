#'  The Brown Corpus of Written American English (words)
#'
#' The Brown Corpus was the first computer-readable general corpus of texts
#' prepared for linguistic research on modern English. It contains of over
#' 1 million words (500 samples of 2000+ words each) of running text of edited
#' English prose printed in the United States during the calendar year 1961.
#'
#' This dataset has 1,004,082 rows corresponding to the tokenized words and 4 variables.
#' For more information: \code{\link{http://www.helsinki.fi/varieng/CoRD/corpora/BROWN/}}
#'
#' @format A data frame with 1,004,082 rows and 4 variables:
#' \describe{
#'   \item{doc_id}{Original file name for each written sample}
#'   \item{category}{The writing category of each sample}
#'   \item{word}{Word tokens}
#'   \item{tag}{Part-of-speech tag for each word token}
#' }
#' @source \url{https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/corpora/brown.zip}
"brown_words"
