chapter_graphics = function(dirname) {
  include_graphics_ = function (basename) {
    knitr::include_graphics(file.path(dirname, basename))
  }
  include_graphics_
}
