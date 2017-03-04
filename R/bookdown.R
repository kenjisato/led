start_preview <- function() {
  bookdown::serve_book(output_dir = "_book",
                       preview = TRUE, in_session = TRUE,
                       daemon = TRUE, initpath = 'index.html')
}

stop_preview <- function(which = NULL) {
  if (is.null(which)) {
    which = servr::daemon_list()
  }
  servr::daemon_stop(which)
}

render_pdf <- function() {
  bookdown::render_book("index.Rmd", output_format = "bookdown::pdf_book")
}
