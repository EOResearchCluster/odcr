#' Suppress messages and warnings
#' @keywords internal
#' @noRd
quiet <- function(expr){
  #return(expr)
  return(suppressWarnings(suppressMessages(expr)))
}

#' Outputs errors, warnings and messages
#'
#' @param input character
#' @param type numeric, 1 = message/cat, 2 = warning, 3 = error and stop
#' @param msg logical. If \code{TRUE}, \code{message} is used instead of \code{cat}. Default is \code{FALSE}.
#' @param sign character. Defines the prefix string.
#'
#' @keywords internal
#' @noRd
out <- function(input, type = 1, ll = NULL, msg = FALSE, sign = "", verbose = getOption("odcr.verbose")){
  if(is.null(ll)) if(isTRUE(verbose)) ll <- 1 else ll <- 2
  if(type == 2 & ll <= 2){warning(paste0(sign,input), call. = FALSE, immediate. = TRUE)}
  else{if(type == 3){stop(input, call. = FALSE)}else{if(ll == 1){
    if(msg == FALSE){ cat(paste0(sign,input),sep="\n")
    } else{message(paste0(sign,input))}}}}
}

#' @keywords internal
#' @noRd
.check_class <- function(x, name, class_str){
  if(!any(grepl(class_str, class(x)))){
    out(paste0("'", name, "' must be of class '", class_str, "'..."), type = 3)
  }
}

#' @keywords internal
#' @noRd
.transform_query <- function(dc, query){

  # translate measurements for this dc
  if(!is.null(query$measurements)){
    dc_measurements <- dc$list_measurements()
    query$measurements <- unlist(.translate_measurements(query$measurements, dc_measurements))
  }
  return(query)
}

# translate measurements vector
#' @keywords internal
#' @noRd
.translate_measurements <- function(x, dc_measurements){
  sapply(x, function(.x){
    if(any(grepl(tolower(.x), tolower(dc_measurements$name)))){
      return(.x)
    }else{
      #sapply(tolower(dc_measurements$aliases), function(y) , simplify = F, USE.NAMES = F)
      dc_measurements$name[sapply(dc_measurements$aliases, function(y) any(sapply(y, function(.y) .x == .y)))]
    }
  }, simplify = F, USE.NAMES = F)
}

# get measurements from dataset
#' @keywords internal
#' @importFrom utils tail
#' @noRd
.get_measurements <- function(x){
  unlist(lapply(tail(strsplit(as.character(x$data_vars), ".\n")[[1]], n=-1), function(.x) trimws(strsplit(.x, "\\(")[[1]][1])))
}


#' @importFrom sf st_crs st_set_crs
#' @importFrom stars read_stars st_set_dimensions
#' @importFrom methods as
#'
#' @keywords internal
#' @noRd
.xarray_convert <- function(x, filename = tempfile(fileext = ".ncdf"), method = "stars"){

  if(!any(grepl("xarray", class(x)))){
    out("'x' must be of class 'xarray...'.", type = 3)
  }

  # delete ncdf conflicting attribute
  try(x$time$attrs$units <- NULL, silent = T)

  # write x to ncdf
  x$to_netcdf(path = filename, format = "NETCDF4")

  # load values from xarray
  if(any(method == "stars", method == "raster")){
    y <- read_stars(filename, quiet = T)
    y <- st_set_crs(y, as.numeric(x$spatial_ref$values)) # THIS MIGHT BE BREAKING IF THERE IS NO EPSG VALUE AS CRS!
    y <- st_set_dimensions(y, "band", names = "time")
  }

  if(method == "raster"){
    y_names <- names(y)
    if(length(y_names) > 1){
      out("Raster* cannot represent four dimensions, only three. Coercing to a list of Raster* instead.", type = 2)
      y <- lapply(1:length(y_names), function(i){
        as(y[i], "Raster")
      })
      names(y) <- y_names
    } else{
      y <- as(y, "Raster")
    }
  }

  return(y)
}

#' @keywords internal
#' @noRd
.rm_name <- function(x){
  x$name <- NULL
  x
}

#' @keywords internal
#' @noRd
.rm_attr <- function(x, attr){
  x$attrs[[attr]] <- NULL
  x
}

#' @importFrom reticulate import
#' @keywords internal
#' @noRd
.dc_available <- function(){
  dc <- try(import("datacube"), silent = T)
  if(inherits(dc, "try-error")) FALSE else TRUE
}

#' @importFrom reticulate import
#' @keywords internal
#' @noRd
.dc_version <- function(){
  dc <- try(import("datacube"), silent = T)
  if(!inherits(dc, "try-error")) dc$"__version__" else ""
}

# global reference to datacube
datacube <- NULL
np <- NULL


#' @importFrom reticulate import
#' @keywords internal
#' @noRd
.onLoad <- function(libname, pkgname) {
  Sys.setenv(RETICULATE_MINICONDA_ENABLED=FALSE)

  # use superassignment to update global references
  datacube <<- reticulate::import("datacube", delay_load = TRUE)
  np <<- reticulate::import("numpy", delay_load = TRUE)

  options(odcr.dc = NA)
  options(odcr.verbose = TRUE)
}

#' @keywords internal
#' @noRd
.onAttach = function(libname, pkgname) {
  if(.dc_available()){
    m <- paste0("Linking to datacube ", .dc_version())
  } else{
    m <- "Could not auto-link to datacube, please use odcr::config() to link to the correct python binary/environment that has the datacube module installed."
  }
  packageStartupMessage(m)
}
