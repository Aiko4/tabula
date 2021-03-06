context("Plots")

test_count <- as(mississippi, "CountMatrix")
test_freq <- as(mississippi, "AbundanceMatrix")
test_incid <- as(mississippi, "IncidenceMatrix")
test_occ <- as(mississippi, "OccurrenceMatrix")
test_sim <- similarity(test_count)

test_that("Bertin plot", {
  # Count data
  # No threshold, no scale
  gg_bertin <- plot_bertin(test_count)
  vdiffr::expect_doppelganger("bertin", gg_bertin)
  # Threshold, no scale
  gg_bertin_threshold <- plot_bertin(test_count, threshold = mean)
  vdiffr::expect_doppelganger("bertin_threshold", gg_bertin_threshold)
  # No threshold, scale
  scale_01 <- function(x) (x - min(x)) / (max(x) - min(x))
  gg_bertin_scale <- plot_bertin(test_count, scale = scale_01)
  vdiffr::expect_doppelganger("bertin_scale", gg_bertin_scale)
})
test_that("Ford plot", {
  # Count data
  for (i in c(TRUE, FALSE)) {
    # Count data
    gg_ford <- plot_ford(test_count, EPPM = i)
    vdiffr::expect_doppelganger(paste0("ford_count_EPPM-", i), gg_ford)
  }
})
test_that("Matrix plot", {
  for (i in c(TRUE, FALSE)) {
    # Count data
    gg_mtx_count <- plot_heatmap(test_count, PVI = i)
    vdiffr::expect_doppelganger(paste0("mtx_count_PVI-", i), gg_mtx_count)
  }
  # Frequency data
  gg_mtx_freq <- plot_heatmap(test_freq)
  vdiffr::expect_doppelganger("mtx_freq", gg_mtx_freq)
  # Incidence data
  gg_mtx_incid <- plot_heatmap(test_incid)
  vdiffr::expect_doppelganger("mtx_incid", gg_mtx_incid)
})
test_that("Rank plot", {
  for (i in c(TRUE, FALSE)) {
    # Count data
    gg_rank_count <- plot_rank(test_count, facet = i)
    vdiffr::expect_doppelganger(paste0("rank_count_facet-", i), gg_rank_count)
    # Frequency data
    gg_rank_freq <- plot_rank(test_freq, facet = i)
    vdiffr::expect_doppelganger(paste0("rank_freq_facet-", i), gg_rank_freq)
  }
  for (j in c("x", "y", "xy", "yx")) {
    # Count data
    gg_rank_log <- plot_rank(test_count, log = j)
    vdiffr::expect_doppelganger(paste0("rank_count_log-", j), gg_rank_log)
  }
})
test_that("Spot plot - Abundance", {
  # Count data, no threshold
  gg_spot_count <- plot_spot(test_count)
  vdiffr::expect_doppelganger("spot_count", gg_spot_count)
  # Frequency data
  gg_spot_freq <- plot_spot(test_freq, threshold = mean)
  vdiffr::expect_doppelganger("spot_freq", gg_spot_freq)
})
test_that("Spot plot - Similarity", {
  gg_spot_sim <- plot_spot(test_sim)
  vdiffr::expect_doppelganger("spot_sim", gg_spot_sim)
})
test_that("Spot plot - Co-Occurrence", {
  gg_spot_occ <- plot_spot(test_occ)
  vdiffr::expect_doppelganger("spot_occ", gg_spot_occ)
})
test_that("Time plot", {
  # Keep only decoration types that have a maximum frequency of at least 50
  keep <- apply(X = merzbach, MARGIN = 2, FUN = function(x) max(x) >= 50)
  counts <- as(merzbach[, keep], "CountMatrix")
  # Use the row names as time coordinates (roman numerals)
  dates <- as.numeric(as.roman(rownames(counts)))
  # Plot time vs abundance
  for (i in c(TRUE, FALSE)) {
    gg_time_facet <- plot_time(counts, dates, facet = i)
    vdiffr::expect_doppelganger(paste0("time_facet-", i), gg_time_facet)
  }
  # Plot time vs abundance and highlight selection
  for (i in c(TRUE, FALSE)) {
    gg_time_roll <- plot_time(counts, dates, highlight = "FIT", roll = i)
    vdiffr::expect_doppelganger(paste0("time_FIT_roll-", i), gg_time_roll)
  }

  # Errors
  expect_error(plot_time(counts, dates, highlight = "FIT",
                         roll = TRUE, window = 2), "must be an odd integer")
})
test_that("Date plot", {
  count_zuni <- as(zuni, "CountMatrix")
  expect_warning(set_dates(count_zuni) <- list(value = c(X = 1097),
                                               error = c(X = 1119)))

  set_dates(count_zuni) <- list(value = c(LZ0569 = 1097, LZ0279 = 1119),
                                error = c(LZ0569 = 30, LZ0279 = 30))

  expect_s3_class(plot_date(count_zuni, select = NULL), "ggplot")
  expect_s3_class(plot_date(count_zuni, select = "LZ0569"), "ggplot")
  gg_date <- plot_date(count_zuni, select = c(1, 2))
  vdiffr::expect_doppelganger("date", gg_date)

  expect_error(plot_date(count_zuni, select = "X"), "Wrong selection")
})
test_that("Date model", {
  dates <- c(
    LZ0569 = 1097, LZ0279 = 1119, CS16 = 1328, LZ0066 = 1111,
    LZ0852 = 1216, LZ1209 = 1251, CS144 = 1262, LZ0563 = 1206,
    LZ0329 = 1076, LZ0005Q = 859, LZ0322 = 1109, LZ0067 = 863,
    LZ0578 = 1180, LZ0227 = 1104, LZ0610 = 1074
  )
  counts <- zuni[rownames(zuni) %in% names(dates), ]
  counts <- arkhe::as_count(counts)

  model <- date_event(counts, dates, cutoff = 90)
  expect_s4_class(model, "DateModel")
  event <- predict_event(model, counts)

  for (i in c(TRUE, FALSE)) {
    gg_date_act <- plot_date(event, type = "activity", event = i,
                             select = c(1, 2))
    vdiffr::expect_doppelganger(paste0("date_activity_event-", i), gg_date_act)
  }
  gg_date_tempo <- plot_date(event, type = "tempo", select = 1)
  vdiffr::expect_doppelganger("date_tempo", gg_date_tempo)

  # Errors
  expect_error(date_event(counts, dates, cutoff = 10),
               "Cutoff value is below 50%")
  expect_error(plot_date(event, select = "X"), "Wrong selection")
})
