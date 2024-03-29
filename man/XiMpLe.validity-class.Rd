% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/00_class_03_XiMpLe.validity.R,
%   R/zzz_is_get_utils.R
\docType{class}
\name{XiMpLe.validity,-class}
\alias{XiMpLe.validity,-class}
\alias{XMLValidity}
\alias{XiMpLe.validity-class}
\alias{is.XiMpLe.validity}
\title{Class XiMpLe.validity}
\usage{
is.XiMpLe.validity(x)
}
\arguments{
\item{x}{An arbitrary \code{R} object.}
}
\description{
Used for objects that describe valid child nodes and attributes of \code{XiMpLe_node}s.
}
\details{
A contructor function \code{XMLValidity(...)} is available to be used instead of \code{new("XiMpLe.validity",
      ...)}.
}
\section{Slots}{

\describe{
\item{\code{children}}{Named list of vectors or XiMpLe.validity objects. The element name defines the parent node
name and each character string a valid child node name. If a value is in turn of class XiMpLe.validity,
this object will be used for recursive validation of deeper nodes.}

\item{\code{attrs}}{Named list of character vectors. The element name defines the parent node name and each character
string a valid attribute name.}

\item{\code{allChildren}}{Character vector,
      names of globally valid child nodes for all nodes, if any.}

\item{\code{allAttrs}}{Character vector, names of globally valid attributes for all nodes,
      if any.}

\item{\code{empty}}{Character vector, names of nodes that must be empty nodes (i.e.,
      no closing tag), if any.}

\item{\code{ignore}}{Character vector, names of nodes that should be ignored, if any.}
}}

\examples{
HTMLish <- XMLValidity(
   children=list(
     body=c("a", "p", "ol", "ul", "strong"),
     head=c("title"),
     html=c("head", "body"),
     li=c("a", "br", "strong"),
     ol=c("li"),
     p=c("a", "br", "ol", "ul", "strong"),
     ul=c("li")
   ),
   attrs=list(
     a=c("href", "name"),
     p=c("align")
   ),
   allChildren=c("!--"),
   allAttrs=c("id", "class"),
   empty=c("br")
)

# this example uses recursion: the <b> node can have the "foo"
# attribute only below an <a> node; the <d> node is also only valid
# in an <a> node
XMLRecursion <- XMLValidity(
   children=list(
     a=XMLValidity(
       children=list(
         b=c("c")
       ),
       attrs=list(
         b=c("foo")
       ),
       allChildren=c("d")
     )
   ),
   attrs=list(
     b=c("bar")
   )
 )
}
\seealso{
\code{\link[XiMpLe:validXML]{validXML}}
}
\keyword{classes}
