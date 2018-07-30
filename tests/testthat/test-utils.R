context("test-utils.R")

test_that("tidytransit packages returns character vector of package names", {
  out <- tidytransit_packages()
  expect_type(out, "character")
  expect_true("trread" %in% out)
})
