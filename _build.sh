#!/bin/sh

Rscript -e "bookdown::clean_book(clean = TRUE)"
Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::gitbook')"
Rscript -e "bookdown::render_book('index.Rmd', output_format = 'bookdown::pdf_book')"

cp static/CNAME _book/CNAME
