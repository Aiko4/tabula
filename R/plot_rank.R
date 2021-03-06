# PLOT RANK
#' @include AllClasses.R AllGenerics.R
NULL

#' @export
#' @rdname plot_line
#' @aliases plot_rank,CountMatrix-method
setMethod(
  f = "plot_rank",
  signature = signature(object = "CountMatrix"),
  definition = function(object, log = NULL, facet = TRUE) {
    freq <- methods::as(object, "AbundanceMatrix")
    plot_rank(freq, log = log, facet = facet)
  }
)

#' @export
#' @rdname plot_line
#' @aliases plot_rank,AbundanceMatrix-method
setMethod(
  f = "plot_rank",
  signature = signature(object = "AbundanceMatrix"),
  definition = function(object, log = NULL, facet = TRUE) {
    # Prepare data
    data <- prepare_rank(object)
    # Get number of cases
    n <- nrow(object)

    # ggplot
    log_x <- log_y <- NULL
    if (!is.null(log)) {
      if (log == "x" || log == "xy" || log == "yx")
        log_x <- ggplot2::scale_x_log10()
      if (log == "y" || log == "xy" || log == "yx")
        log_y <- ggplot2::scale_y_log10()
    }
    if (facet) {
      facet <- ggplot2::facet_wrap(ggplot2::vars(.data$case), ncol = n)
      aes_plot <- ggplot2::aes(x = .data$rank, y = .data$data)
    } else {
      facet <- NULL
      aes_plot <- ggplot2::aes(x = .data$rank, y = .data$data,
                               colour = .data$case)
    }
    ggplot2::ggplot(data = data, mapping = aes_plot) +
      ggplot2::geom_point() + ggplot2::geom_line() +
      ggplot2::labs(x = "Rank", y = "Frequency",
                    colour = "Assemblage", fill = "Assemblage") +
      log_x + log_y + facet
  }
)

# Prepare data for rank plot
# Must return a data.frame
prepare_rank <- function(object) {
  # Build a long table for ggplot2 (preserve original ordering)
  data <- arkhe::as_long(object, as_factor = TRUE)
  # Remove zeros in case of log scale
  data <- data[data$data > 0, ]

  data <- by(
    data,
    INDICES = data$case,
    FUN = function(x) {
      data <- x[order(x$data, decreasing = TRUE), ]
      data <- cbind.data.frame(rank = seq_len(nrow(data)), data)
      data
    }
  )
  data <- do.call(rbind.data.frame, data)
  data
}
