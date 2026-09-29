zeguo_departure_observed <- function(survey) {
  after <- arrow::read_parquet(project_path(
    "data", "zeguo-2005", "source-materials", "post.parquet"
  ))
  fields <- c(paste0("d20", sprintf("%02d", 6:35), "p"),
    paste0("post_d304", 3:6)
  )
  stopifnot(
    all(c("p", "pp", "preandpost", fields) %in% names(survey)),
    !anyNA(survey$p), !anyDuplicated(survey$p),
    !anyNA(after$p), !anyDuplicated(after$p),
    all(is.na(survey$preandpost) | survey$preandpost == 1)
  )
  observed <- !is.na(survey$pp)
  stopifnot(
    identical(observed, !is.na(survey$preandpost)),
    all(survey$pp[observed] %in% after$p),
    all(survey$p[observed] == survey$pp[observed]),
    !any(survey$p[!observed] %in% after$p),
    all(is.na(as.matrix(survey[!observed, fields])))
  )
  observed
}

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
