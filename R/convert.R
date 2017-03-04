
# Lyx -> LaTeX -> Rmd ----
lyx2rmd = function(lyxfile, dest = '.', keep_tex = TRUE, ...) {
  # Convert to LaTeX file ----
  texfile = lyx2tex(lyxfile, dest, ...)
  if (!keep_tex) on.exit(unlink(texfile))

  # Convert to Rmarkdown file ----
  tex2rmd(texfile, dest, ...)
}

# Lyx -> LaTeX ----
lyx2tex = function(lyxfile, dest = '.', mode = "latex", lyxpath = NULL,
                   overwrite = TRUE, ...) {

  texfile = file.path(dest, stringr::str_replace(basename(lyxfile), "lyx$", "tex"))

  # Lyx command
  if (is.null(lyxpath)) {
    # Search for the environment variable LYX
    lyxpath = Sys.getenv("LYX")
    if (lyxpath == "") {
      # Assume lyx command is in the PATH
      lyxpath = "lyx"
    }
  }

  force_overwrite = ifelse(overwrite, "--force-overwrite", "")

  # Escape white space in the path
  lyxfile = stringr::str_replace_all(lyxfile, " ", "\\\\ ")

  # Command passed to shell
  cmd_lyx2tex = paste(lyxpath, force_overwrite, "--export-to", mode, texfile, lyxfile)

  # Run the command
  system(cmd_lyx2tex)

  # Return path to the LaTeX path
  return(texfile)
}


# LaTeX -> Rmd ----
tex2rmd = function(texfile, dest = '.', title_as_chapter_name = TRUE, ...) {

  doc = readr::read_lines(texfile)

  # Title of the document set to chapter name
  if (title_as_chapter_name) {
    doc_title = na.omit(stringr::str_match(doc, "\\\\title\\{(.+)\\}"))[[2]]
    title_line = paste("#", doc_title, "\n")
  }

  # Ignore anything before \maketitle and \end{document} line ----
  skip = 0
  for (line in doc) {
    skip = skip + 1
    if (startsWith(line, "\\maketitle")) break
  }

  doc = doc[(skip + 1):(length(doc) - 1)] # Drop unnecessary \end{document}
  if (title_as_chapter_name) {
    doc = c(title_line, doc)
  }

  # Simple command-level replacement
  doc = convert_command(doc)

  # Replace theorems ----
  doc = convert_theorem(doc)

  # Replace itemize ----
  doc = convert_list(doc)

  # Write out ----
  rmdfile = file.path(dest, stringr::str_replace(basename(texfile), "tex$", "Rmd"))
  readr::write_lines(doc, rmdfile)
  return(rmdfile)
}

# Convert simple commands ----
convert_command = function(doc, config_file = tex2rmd_patterns) {
  # Simple replacements ----
  rules = readr::read_csv(config_file)
  rules$replace = stringr::str_replace(rules$replace, "\\\\n", "\n")

  for (i in 1:nrow(rules)) {
    doc = stringr::str_replace_all(doc, rules$pattern[i], rules$replace[i])
  }

  return(doc)
}

# Convert theorem environments ----
convert_theorem = function(doc, config_file = tex2rmd_theorems) {
  thms = readr::read_csv(config_file)
  for (i in 1:nrow(thms)) {
    if (thms$engine[i]) {
      # \begin{env} to ```{env}
      doc = stringr::str_replace(doc,
              paste0("\\\\begin\\{", thms$tex[i], "\\}"),
              paste0("```{", thms$bookdown[i], "}"))

      # ```{env}[description] to ```{env, name='description'}
      doc = stringr::str_replace(doc,
              paste0("(```\\{", thms$bookdown[i], ")\\}\\[(.+)\\]"),
              paste0("\\1, name='\\2'}"))

    } else {
      # \begin{env} to ```{block2, type='env'}
      doc = stringr::str_replace(doc,
              paste0("\\\\begin\\{", thms$tex[i], "\\}"),
              paste0("```{block2, type='", thms$bookdown[i], "'}"))

      # ```{block2, type='env'} to ```{block2, type='env', name='description'}
      doc = stringr::str_replace(doc,
              paste0("(```\\{block2, type='", thms$bookdown[i], "')\\}\\[(.+)\\]"),
              paste0("\\1, name='\\2'}"))
    }

    # \end{environ}
    doc = stringr::str_replace(doc,
            paste0("\\\\end\\{", thms$tex[i], "\\}"),
            "```\n")
  }
  return(doc)
}

# Convert lists ----
convert_list = function(doc) {
  nesting = c()
  for (i in seq_along(doc)) {
    if (startsWith(doc[i], "\\begin{itemize}")) {
      doc[i] = ""
      nesting = append(nesting, "itemize")
    } else if (startsWith(doc[i], "\\begin{enumerate}")) {
      doc[i] = ""
      nesting = append(nesting, "enumerate")
    }
    if (length(nesting) > 0 && startsWith(doc[i], "\\item ")) {
      if (nesting[length(nesting)] == "itemize") {
        doc[i] = stringr::str_replace(doc[i], "\\\\item",
                             paste0(strrep(" ", 4 * (length(nesting) - 1)), "-"))
      } else if (nesting[length(nesting)] == "enumerate") {
        doc[i] = stringr::str_replace(doc[i], "\\\\item",
                             paste0(strrep(" ", 4 * (length(nesting) - 1)), "1."))
      }
    }
    if (startsWith(doc[i], "\\end{itemize}")) {
      doc[i] = ""
      nesting = head(nesting, length(nesting) - 1)
    }
  }
  return(doc)
}
