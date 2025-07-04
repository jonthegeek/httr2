test_that("can request verbose record of request", {
  skip_on_ci()
  skip_on_cran()

  req <- local_app_request(method = "post", function(req, res) {
    res$send_json(list(x = 1), auto_unbox = TRUE)
  })
  req <- req |>
    req_body_raw("This is some text", "text/plain") |>
    req_verbose_test()

  # Snapshot test of response
  verbose_resp <- req |>
    req_verbose(header_resp = TRUE, body_resp = TRUE, header_req = FALSE)
  expect_snapshot(
    . <- req_perform(verbose_resp),
    transform = transform_verbose_response
  )

  # Snapshot test of request
  verbose_req <- req |>
    req_verbose(header_req = TRUE, body_req = TRUE, header_resp = FALSE)
  expect_snapshot(. <- req_perform(verbose_req))

  # Lightweight test for everything else
  verbose_info <- req |>
    req_verbose(info = TRUE, header_req = FALSE, header_resp = FALSE)
  expect_output(. <- req_perform(verbose_info))
})

test_that("redacts headers as needed", {
  skip_on_ci()
  skip_on_cran()

  req <- request(example_url()) |>
    req_verbose_test() |>
    req_verbose(header_req = TRUE, header_resp = FALSE) |>
    req_headers_redacted(Authorization = "abc")

  expect_snapshot(. <- req_perform(req))
})

test_that("can display compressed bodies", {
  skip_on_ci()
  skip_on_cran()

  req <- request(example_url()) |>
    req_url_path("gzip") |>
    req_verbose_test() |>
    req_verbose(header_req = FALSE, header_resp = TRUE, body_resp = TRUE)

  expect_snapshot(. <- req_perform(req), transform = transform_verbose_response)
})

test_that("response json is automatically prettified", {
  skip_on_ci()
  skip_on_cran()

  req <- local_app_request(function(req, res) {
    res$set_header("Content-Type", "application/json")
    res$send('{"foo":"bar","baz":[1,2,3]}')
  })

  req <- req |>
    req_verbose_test() |>
    req_verbose(body_resp = TRUE, header_resp = FALSE, header_req = FALSE)
  expect_snapshot(. <- req_perform(req))

  # Unless we opt-out
  local_options(httr2_pretty_json = FALSE)
  expect_snapshot(. <- req_perform(req))
})

test_that("request json is automatically prettified", {
  skip_on_ci()
  skip_on_cran()

  req <- request(example_url("/post")) |>
    req_verbose_test() |>
    req_body_json(list(foo = "bar", baz = c(1, 2, 3))) |>
    req_verbose(body_req = TRUE, header_resp = FALSE, header_req = FALSE)
  expect_snapshot(. <- req_perform(req))

  # Unless we opt-out
  local_options(httr2_pretty_json = FALSE)
  expect_snapshot(. <- req_perform(req))
})
