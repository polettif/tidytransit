.onAttach <- function(...) {
  needed <- core[!is_attached(core)]
  if (length(needed) == 0)
    return()

  crayon::num_colors(TRUE)
  tidytransit_attach()

  if (!"package:conflicted" %in% search()) {
    x <- tidytransit_conflicts()
    msg(tidytransit_conflict_message(x), startup = TRUE)
  }

}

is_attached <- function(x) {
  paste0("package:", x) %in% search()
}
