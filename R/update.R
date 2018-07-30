#' Update tidytransit packages
#'
#' This will check to see if all tidytransit packages (and optionally, their
#' dependencies) are up-to-date, and will install after an interactive
#' confirmation.
#'
#' @param recursive If \code{TRUE}, will also check all dependencies of
#'   tidytransit packages.
#' @export
#' @examples
#' \dontrun{
#' tidytransit_update()
#' }
#' @importFrom cli cat_line cat_bullet
#' @importFrom dplyr filter
tidytransit_update <- function(recursive = FALSE) {

  deps <- tidytransit_deps(recursive)
  behind <- dplyr::filter(deps, behind)

  if (nrow(behind) == 0) {
    cli::cat_line("All tidytransit packages up-to-date")
    return(invisible())
  }

  cli::cat_line("The following packages are out of date:")
  cli::cat_line()
  cli::cat_bullet(format(behind$package), " (", behind$local, " -> ", behind$cran, ")")

  cli::cat_line()
  cli::cat_line("Start a clean R session then run:")

  pkg_str <- paste0(deparse(behind$package), collapse = "\n")
  cli::cat_line("install.packages(", pkg_str, ")")

  invisible()
}

#' List all tidytransit dependencies
#'
#' @param recursive If \code{TRUE}, will also list all dependencies of
#'   tidytransit packages.
#' @export
#' @importFrom purrr map2_lgl
#' @importFrom tibble tibble
tidytransit_deps <- function(recursive = FALSE) {
  pkgs <- utils::available.packages()
  deps <- tools::package_dependencies("tidytransit", pkgs, recursive = recursive)

  pkg_deps <- unique(sort(unlist(deps)))

  base_pkgs <- c(
    "base", "dplyr", "tibble", "readr", "httr", "htmltools",
    "magrittr", "stringr", "assertthat", "scales", "here"
  )
  pkg_deps <- setdiff(pkg_deps, base_pkgs)

  cran_version <- lapply(pkgs[pkg_deps, "Version"], base::package_version)
  local_version <- lapply(pkg_deps, utils::packageVersion)

  behind <- purrr::map2_lgl(cran_version, local_version, `>`)

  tibble::tibble(
    package = pkg_deps,
    cran = cran_version %>% purrr::map_chr(as.character),
    local = local_version %>% purrr::map_chr(as.character),
    behind = behind
  )
}
