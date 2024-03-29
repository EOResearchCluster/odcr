% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/xarray_methods.R
\name{Extract}
\alias{Extract}
\alias{[.xarray.core.dataset.Dataset}
\alias{[.xarray.core.dataarray.DataArray}
\alias{[[.xarray.core.dataset.Dataset}
\alias{[[.xarray.core.dataarray.DataArray}
\alias{xar_sel_time}
\alias{[[<-.xarray.core.dataset.Dataset}
\alias{$<-.xarray.core.dataset.Dataset}
\title{Methods to extract from or assign to \code{odcr} classes}
\usage{
\method{[}{xarray.core.dataset.Dataset}(x, i = NULL, j = NULL, k = NULL, ...)

\method{[}{xarray.core.dataarray.DataArray}(x, i = NULL, j = NULL, k = NULL, ...)

\method{[[}{xarray.core.dataset.Dataset}(x, ...)

\method{[[}{xarray.core.dataarray.DataArray}(x, ...)

xar_sel_time(x, query, exact_match = T)

\method{[[}{xarray.core.dataset.Dataset}(x, ...) <- value

\method{$}{xarray.core.dataset.Dataset}(x, ...) <- value
}
\arguments{
\item{x}{\code{xarray} object, the dataset to be subsetted from or assigned to}

\item{i}{numeric, first dimension index}

\item{j}{numeric, second dimension index}

\item{k}{numeric, third dimension index}

\item{...}{numeric or character, index or indices by which to extract/assign (additional) elements}

\item{query}{character vector, one or more time/date character vectors in the format of the time dimension of \code{x} or an abbreviated form of it (e.g. only the date component)}

\item{exact_match}{logical, whether to return only exact matches (default) or to search for closest elements to each element in \code{query} using \verb{[difftime()]}}

\item{value}{\code{xarray} object, the dataset that should be assigned to \code{x}}
}
\value{
Subsetted \code{xarray} object
}
\description{
\code{[} allows to subset an \code{xarray} object by its dimensions (see \code{\link[=dim]{dim()}})

\code{[[} allows to subset an \code{xarray} object by measurements/variables (e.g. spectral band), either named (character) or indexed (numeric).

\code{xar_sel_time()} allows to subset an \code{xarray} object by a character vector of dates/times.

\verb{[[<-} allows to assign a measurement/variable (e.g. spectral band), either named (character) or indexed (numeric), to an existing \code{xarray} object.
}
\examples{
\dontrun{
library(odcr)

# connect to a database, store the Daatcube connection internally (default and recommended)
database_connect(app = "Sentinel_2")

# build a query list
lat <- 22.821
lon <- 28.518
buffer <- 0.05

query <- list(
  'time' = c('2020-01', '2020-03'),
  'x' = c(lon - buffer, lon + buffer),
  'y' = c(lat + buffer, lat - buffer),
  'output_crs' = 'epsg:6933',
  'resolution' = c(-20,20)
)

# load data and return an xarray object for a query
ds <- dc_load(query = c(product = "s2_l2a", dask_chunks = dict(), query))

# return dimensions of ds
dim(ds)

# subset/index ds by time, x, y
ds[13, 11:20, 21:30]

# subset/index ds by time
ds[13,,]

# subset/index ds by variable/measurement
ds[[2]]

# or do the same with a named variable or alias
ds[["nir"]]

# subset/index by exact time vectors
xar_sel_time(ds, c("2020-01-02", "2020-01-07"))

# or find closest times/date subsets by time vectors
xar_sel_time(ds, c("2020-01-01", "2020-01-07"), exact_match = F)
}
}
