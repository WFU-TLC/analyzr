#' Switchboard Dialog Act Corpus Files
#'
#' A dataset of the corpus files containing the 1,1150 conversations of 440 speakers of American
#' English.
#'
#' @format A data frame with 223,606 rows and 7 variables:
#' \describe{
#'   \item{doc_id}{ID for each conversation document}
#'   \item{damsl_tag}{DAMSL dialog act annotation labels}
#'   \item{speaker}{Label for each speaker in the conversation}
#'   \item{turn_num}{Number of contiguous utterance turns for a given speaker}
#'   \item{utterance_num}{The cumulative number of utterances in the conversation}
#'   \item{utterance_text}{The actual dialog utterance}
#'   \item{speaker_id}{Unique speaker identification code}
#' }
#' @source \url{https://catalog.ldc.upenn.edu/docs/LDC97S62/}
"sdac_files"
