# PLOT DIVERSITY
#' @include AllClasses.R AllGenerics.R
NULL

#' @export
#' @rdname plot_diversity
#' @aliases plot_diversity,DiversityIndex-method
setMethod(
  f = "plot_diversity",
  signature = signature(object = "DiversityIndex"),
  definition = function(object) {

    # Prepare data
    count <- cbind.data.frame(
      label = names(object[["index"]]),
      x = object[["size"]],
      y = object[["index"]]
    )
    # Simulated assemblages
    gg_sim <- NULL
    if (length(object[["simulation"]]) != 0) {
      # Build a long table for ggplot2
      refined <- object[["simulation"]]
      sim_stacked <- utils::stack(as.data.frame(refined), select = -c(1))
      sim <- cbind.data.frame(
        size = refined[, 1],
        sim_stacked,
        type = ifelse(sim_stacked[["ind"]] == "mean", "mean", "conf. int.")
      )
      sim <- stats::na.omit(sim)
      gg_sim <- ggplot2::geom_path(
        mapping = ggplot2::aes(x = .data$size, y = .data$values,
                               colour = .data$type, group = .data$ind),
        data = sim, inherit.aes = FALSE
      )
    }

    y_lab <- switch (
      class(object),
      HeterogeneityIndex = "Heterogeneity",
      EvennessIndex = "Evenness",
      RichnessIndex = "Richness",
      "Diversity"
    )
    # ggplot
    ggplot2::ggplot(data = count,
                    mapping = ggplot2::aes(x = .data$x, y = .data$y,
                                           label = .data$label)) +
      ggplot2::geom_point() +
      gg_sim +
      ggplot2::scale_x_log10() +
      ggplot2::labs(x = "Sample size",
                    y = paste(y_lab, object[["method"]], sep = ": "),
                    colour = "Simulation")
  }
)
