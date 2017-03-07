journal_record = function(date = NULL, description = NULL, data = "data/history.csv") {
  history = readr::read_csv(data, col_types = readr::cols())
  if (is.null(date)) {
    date = lubridate::today()
  } else {
    date = lubridate::as_date(date)
  }
  history = tibble::add_row(history, date = date, description = description)
  readr::write_csv(history, data)
}

journal_read = function(date = NULL, data = "data/history.csv") {
  history = readr::read_csv(data, col_types = readr::cols())
  if (!is.null(date)) {
    history = dplyr::filter(history, date == date)
  }
  dplyr::arrange(history, desc(date))
}
