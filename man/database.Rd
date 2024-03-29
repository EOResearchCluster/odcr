% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/database.R
\name{database}
\alias{database}
\alias{database_connect}
\alias{database_get_active}
\title{Connect to a database}
\usage{
database_connect(..., object = F)

database_get_active()
}
\arguments{
\item{...}{optional arguments to index or configure a connection.}

\item{object}{logical, whether the connection should be returned or not.}
}
\value{
None or the connection of class 'datacube.api.core.Datacube', if \code{object = T}
}
\description{
These functions connect to a database that houses a datacube.
}
\examples{
\dontrun{
library(odcr)

# connect to a database, store the Daatcube connection internally (default and recommended)
database_connect(app = "Sentinel_2")

# retrieve the current connection as an object
dc <- database_get_active()

# or return a Datacube object
dc <- database_connect(app = "Sentinel_2", object = TRUE)


}
}
