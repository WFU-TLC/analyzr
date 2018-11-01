#' Silly Printer Function
#'
#' @param r A vector of length $n$
#' @param y A vector of length $n$
#'
#' @return The first 5 rows of the data frame as a tibble
#' @export
#'
#' @import tibble
#' @examples
printer <- function(r, x) {
  x <- data_frame(x = x, r = r)
  print(head(x))
}
