#' @name greta-functions
#'
#' @title R functions that work for greta arrays
#'
#' @description This is a list of functions in base R that are currently
#'   implemented to transform greta arrays Also see \link{greta-operators} and
#'   \link{greta-transforms}.
#'
#' @section Usage: \preformatted{
#'
#'  # logarithms and exponentials
#'  log(x)
#'  exp(x)
#'  log1p(x)
#'  expm1(x)
#'
#'  # miscellaneous mathematics
#'  abs(x)
#'  mean(x)
#'  sqrt(x)
#'  sign(x)
#'
#'  # rounding of numbers
#'  ceiling(x)
#'  floor(x)
#'  round(x, digits = 0)
#'
#'  # trigonometry
#'  cos(x)
#'  sin(x)
#'  tan(x)
#'  acos(x)
#'  asin(x)
#'  atan(x)
#'
#'  # special mathematical functions
#'  lgamma(x)
#'  digamma(x)
#'
#'  # matrix operations
#'  t(x)
#'  chol(x, ...)
#'  diag(x, nrow, ncol)
#'  solve(a, b, ...)
#'
#'  # reducing operations
#'  sum(..., na.rm = TRUE)
#'  prod(..., na.rm = TRUE)
#'  min(..., na.rm = TRUE)
#'  max(..., na.rm = TRUE)
#'
#'  # miscellaneous operations
#'  sweep(x, MARGIN, STATS, FUN = c('-', '+', '/', '*'))
#'
#'  }
#'
#' @details TensorFlow only enables rounding to integers, so \code{round()} will
#'   error if \code{digits} is set to anything other than \code{0}.
#'
#'   Any additional arguments to \code{chol()} and \code{solve()} will be
#'   ignored, see the TensorFlow documentation for details of these routines.
#'
#'   \code{diag()} can only be used to extract the diagonal part of a square and
#'   two-dimensional greta array, it cannot be used to create a matrix-like
#'   greta array from a vector-like greta array, nor to assign the diagonal
#'   elements of a greta array. A static diagonal matrix can always be created
#'   with e.g. \code{diag(3)}.
#'
#'   \code{sweep()} only works on two-dimensional greta arrays (so \code{MARGIN}
#'   can only be either 1 or 2), and for subtraction, addition, division and
#'   multiplication.
#'
#' @examples
#' x = as_data(matrix(1:9, nrow = 3, ncol = 3))
#' a = log(exp(x))
#' b = log1p(expm1(x))
#' c = sign(x - 5)
#' d = abs(x - 5)
#'
#' e = diag(x)
#'
#' z = t(a)
#'
#' y = sweep(x, 1, e, '-')
#'
NULL

#' @export
log.greta_array <- function (x, base = exp(1)) {
  op("tf$log", x)
}

#' @export
exp.greta_array <- function (x) {
  op("tf$exp", x)
}

#' @export
log1p.greta_array <- function (x) {
  log(1 + x)
}

#' @export
expm1.greta_array <- function (x) {
  exp(x) - 1
}

#' @export
abs.greta_array <- function (x) {
  op("tf$abs", x)
}

#' @export
sqrt.greta_array <- function (x) {
  op("tf$sqrt", x)
}

#' @export
sign.greta_array <- function (x) {
  op("tf$sign", x)
}

#' @export
ceiling.greta_array <- function (x) {
  op("tf$ceil", x)
}

#' @export
floor.greta_array <- function (x) {
  op("tf$floor", x)
}

#' @export
round.greta_array <- function (x, digits = 0) {
  if (digits != 0)
    stop("TensorFlow round only supports rounding to integers")
  op("tf$round", x)
}

# trigonometry functions
#' @export
cos.greta_array <- function (x) {
  op("tf$cos", x)
}

#' @export
sin.greta_array <- function (x) {
  op("tf$sin", x)
}

#' @export
tan.greta_array <- function (x) {
  op("tf$tan", x)
}

#' @export
acos.greta_array <- function (x) {
  op("tf$acos", x)
}

#' @export
asin.greta_array <- function (x) {
  op("tf$asin", x)
}

#' @export
atan.greta_array <- function (x) {
  op("tf$atan", x)
}

#' @export
lgamma.greta_array <- function (x) {
  op("tf$lgamma", x)
}

#' @export
digamma.greta_array <- function (x) {
  op("tf$digamma", x)
}

#' @export
t.greta_array <- function (x) {

  # reverse the dimensions
  dimfun <- function (elem_list) {
    x <- elem_list[[1]]
    if (length(dim(x)) != 2)
      stop ('only 2D arrays can be transposed')
    rev(dim(x))
  }

  op("tf$transpose", x, dimfun = dimfun)
}

#' @export
chol.greta_array <- function (x, ...) {

  if (!identical(list(), list(...)))
    warning ('chol() options are ignored by TensorFlow')

  dimfun <- function (elem_list) {
    dim <- dim(elem_list[[1]])
    if ( !(length(dim) == 2 && dim[1] == dim[2]) )
      stop ('only 2D, square greta arrays can be Cholesky decomposed')
    dim
  }

  op("tf$cholesky", x, dimfun = dimfun)
}

#' @rdname greta-overloaded
#' @export
diag <- function (x = 1, nrow, ncol)
  UseMethod('diag', x)

# wrapper function to avoid a CRAN check warning about using a .Internal() call
#' @export
diag.default <- function (...)
  base::diag(...)

#' @export
diag.greta_array <- function (x = 1, nrow, ncol) {

  # can only extract from a node, cannot create from a node or assign.
  if (missing(x) | !missing(nrow) | !missing(ncol))
    stop ('diag can only be used to extract diagonal elements from a matrix, not to create or assign values')

  dimfun <- function (elem_list) {

    x <- elem_list[[1]]
    dim <- dim(x)

    # check the rank isn't too high
    if (length(dim) != 2)
      stop ('cannot only extract the diagonal from a node with exactly two dimensions')

    if (dim[1] != dim[2])
      stop ('diagonal elements can only be extracted from square matrices')

    # return the dimensions
    c(dim[1], 1)

  }

  # return the extraction op
  op('tf$diag_part', x, dimfun = dimfun)

}

#' @export
solve.greta_array <- function (a, b, ...) {

  # check the matrix is square
  if (dim(a)[1] != dim(a)[2]) {
    stop (sprintf('a must be square, but has %i rows and %i columns',
                  dim(a)[1], dim(a)[2]))
  }

  # if they just want the matrix inverse, do that
  if (missing(b)) {

    dimfun <- function (elem_list) {

      a <- elem_list[[1]]

      # a must be square
      if (dim(a)[1] != dim(a)[2]) {
        stop (sprintf('a must be square, but has %i rows and %i columns',
                      dim(a)[1], dim(a)[2]))
      }

      # return the dimensions
      dim(a)

    }

    return (op("tf$matrix_inverse", a, dimfun = dimfun))

  } else {


    dimfun <- function (elem_list) {

      a <- elem_list[[1]]
      b <- elem_list[[2]]

      # a must be square
      if (dim(a)[1] != dim(a)[2]) {
        stop (sprintf('a must be square, but has %i rows and %i columns',
                      dim(a)[1], dim(a)[2]))
      }

      # b must have the right number of rows
      if (dim(b)[1] != dim(a)[1]) {
        stop (sprintf('b must have the same number of rows as a (%i), but has %i rows instead',
                      dim(a)[1], dim(b)[1]))
      }

      # return the dimensions
      dim(b)

    }

    # ... and solve the linear equations
    return (op("tf$matrix_solve", a, b))

  }

}

# sum, prod, min, mean, max

#' @export
sum.greta_array <- function (..., na.rm = TRUE) {

  # combine all elements into a column vector
  dots <- list(...)
  flat_dots <- lapply(dots, flatten)
  vec <- do.call(c, flat_dots)

  # results will be 1 x 1
  dimfun <- function (x) c(1, 1)

  # sum the elements
  op('tf$reduce_sum',
     vec,
     dimfun = dimfun)

}

#' @export
prod.greta_array <- function (..., na.rm = TRUE) {

  # combine all elements into a column vector
  dots <- list(...)
  flat_dots <- lapply(dots, flatten)
  vec <- do.call(c, flat_dots)

  # results will be 1 x 1
  dimfun <- function (x) c(1, 1)

  # sum the elements
  op('tf$reduce_prod',
     vec,
     dimfun = dimfun)

}

#' @export
min.greta_array <- function (..., na.rm = TRUE) {

  # combine all elements into a column vector
  dots <- list(...)
  flat_dots <- lapply(dots, flatten)
  vec <- do.call(c, flat_dots)

  # results will be 1 x 1
  dimfun <- function (x) c(1, 1)

  # sum the elements
  op('tf$reduce_min',
     vec,
     dimfun = dimfun)

}

#' @export
mean.greta_array <- function (x, trim = 0, na.rm = TRUE, ...) {

  # results will be 1 x 1
  dimfun <- function (x) c(1, 1)

  # sum the elements
  op('tf$reduce_mean',
     x,
     dimfun = dimfun)

}

#' @export
max.greta_array <- function (..., na.rm = TRUE) {

  # combine all elements into a column vector
  dots <- list(...)
  flat_dots <- lapply(dots, flatten)
  vec <- do.call(c, flat_dots)

  # results will be 1 x 1
  dimfun <- function (x) c(1, 1)

  # sum the elements
  op('tf$reduce_max',
     vec,
     dimfun = dimfun)

}


# tensorflow version of sweep, based on broadcasting of tf ops
tf_sweep <- function (x, STATS, MARGIN, FUN) {

  # if the second margin, transpose before and after
  if (MARGIN == 2)
    x <- tf$transpose(x)

  # apply the function rowwise
  result <- do.call(FUN, list(x, STATS))

  if (MARGIN == 2)
    result <- tf$transpose(result)

  result

}

#' @rdname greta-overloaded
#' @export
sweep <- function (x, MARGIN, STATS, FUN = "-", check.margin = TRUE, ...)
  UseMethod('sweep', x)

#' @export
sweep.default <- base::sweep

#' @export
sweep.greta_array <- function (x, MARGIN, STATS, FUN = c('-', '+', '/', '*'), check.margin = TRUE, ...) {

  # only allow these four functions
  FUN <- match.arg(FUN)

  STATS <- as.greta_array(STATS)

  if (!MARGIN %in% seq_len(2))
    stop ('MARGIN can only be 1 or 2')

  dimfun <- function (elem_list) {

    x <- elem_list[[1]]
    STATS <- elem_list[[2]]

    # x must be 2D
    if (length(dim(x)) != 2) {
      stop (sprintf('x must be a 2D array, but has %i dimensions',
                    length(dim(x))))
    }

    # STATS must be a column array
    if (length(dim(STATS)) != 2 & dim(STATS)[2] != 1) {
      stop (sprintf('STATS must be a column vector array, but has dimensions %s',
                    paste(dim(STATS), collapse = ' x ')))
    }

    # STATS must have the same dimension as the correct dim of x
    if (dim(x)[MARGIN] != dim(STATS)[1])
      stop ('the number of elements of STATS does not match dim(x)[MARGIN]')

    # return the dimensions of x
    dim(x)

  }

  op("tf_sweep",
     x,
     STATS,
     operation_args = list(MARGIN = MARGIN,
                           FUN = FUN),
     dimfun = dimfun)

}
