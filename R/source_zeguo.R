read_zeguo_sources <- function(directory) {
  read <- function(name) {
    arrow::read_parquet(file.path(directory, paste0(name, ".parquet")))
  }
  merged <- read("merged")
  before <- read("pre")
  after <- read("post")
  stopifnot(!anyNA(before$p), !anyDuplicated(before$p),
    !anyNA(after$p), !anyDuplicated(after$p), !anyDuplicated(merged$p),
    setequal(merged$p, before$p), all(stats::na.omit(merged$pp) %in% after$p)
  )
  fields <- paste0("d304", 3:6)
  baseline <- before[match(merged$p, before$p), fields]
  post <- after[match(merged$pp, after$p), fields]
  names(baseline) <- paste0("pre_", fields)
  names(post) <- paste0("post_", fields)
  dplyr::bind_cols(merged, baseline, post)
}
