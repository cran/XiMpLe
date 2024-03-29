# library(XiMpLe)
# library(testthat)

context("XML generation")

test_that("generate empty XML node", {
  sampleXMLStandard <- dget("sample_XML_node_empty_dput.txt")
  expect_that(
    XMLNode("empty"),
    equals(sampleXMLStandard)
  )
})

test_that("generate closed XML node", {
  sampleXMLStandard <- dget("sample_XML_node_closed_dput.txt")
  expect_that(
    XMLNode("empty", ""),
    equals(sampleXMLStandard)
  )
})

test_that("generate closed XML node with attributes", {
  # re-create object sampleXMLnode.attrs
  load("sample_XML_node_attrs.RData")
  # three ways to the same result
  expect_that(
    XMLNode("empty", "test", attrs=list(foo="bar")),
    equals(sampleXMLnode.attrs)
  )
  expect_that(
    XMLNode("empty", "test", foo="bar"),
    equals(sampleXMLnode.attrs)
  )
  expect_that(
    XMLNode("empty", .children=list("test", foo="bar")),
    equals(sampleXMLnode.attrs)
  )
})

test_that("generate generator functions", {
  # for this test, we'll put generated functions to their own environment
  my_functions <- new.env()
  gen_tag_functions(c("x","y","abc"), envir=my_functions)
  my_func_list <- as.list(my_functions)

  expect_that(
    sort(c("x_","y_","abc_")),
    equals(sort(names(my_func_list)))
  )
  expect_true(all(sapply(my_func_list, is.function)))

  XML_node_x <- my_func_list[["x_"]]("foo")

  expect_that(
    XML_node_x,
    equals(XMLNode("x", "foo"))
  )
})

test_that("generate nested XML tag tree", {
  # re-create object sampleXMLTree
  load("sample_XML_tree.RData")

  sampleXMLnode.empty <- XMLNode("empty")
  sampleXMLnode.closed <- XMLNode("empty", "")
  sampleXMLnode.attrs <- XMLNode("empty", "test", attrs=list(foo="bar"))
  sampleXMLTree.test <- XMLTree(
    XMLNode("tree",
      sampleXMLnode.empty,
      sampleXMLnode.closed,
      sampleXMLnode.attrs
    )
  )

  expect_that(
    sampleXMLTree.test,
    equals(sampleXMLTree)
  )
})


context("XML parsing")

test_that("parse XML file", {
  # re-create object sampleRSSparsed
  load("sample_RSS_parsed.RData")

  sampleRSSFile <- normalizePath("koRpus_RSS_sample.xml")
  XMLtoParse <- file(sampleRSSFile, encoding="UTF-8")
  sampleRSSparsed.test <- parseXMLTree(XMLtoParse)
  close(XMLtoParse)

  expect_that(
    sampleRSSparsed.test,
    equals(sampleRSSparsed))
})


context("extracting nodes")

test_that("extract node from parsed XML tree", {
  # re-create object sampleRSSparsed
  load("sample_RSS_parsed.RData")
  # re-create object sampleXMLnode.extracted
  load("sample_XML_node_extracted.RData")

  sampleXMLnode.test <- node(sampleRSSparsed, node=list("rss","channel","atom:link"))

  expect_that(
    sampleXMLnode.test,
    equals(sampleXMLnode.extracted))
})


context("changing node values")

test_that("change attribute values in XML node", {
  # re-create object sampleRSSparsed
  load("sample_RSS_parsed.RData")
  # re-create object sampleRSSparsed.changed
  load("sample_RSS_changed.RData")

  # replace URL
  node(sampleRSSparsed,
    node=list("rss","channel","atom:link"),
    what="attributes", element="href") <- "http://example.com"

  # remove "rel" attribute
  node(sampleRSSparsed,
    node=list("rss","channel","atom:link"),
    what="attributes", element="rel") <- NULL

  expect_that(
    sampleRSSparsed,
    equals(sampleRSSparsed.changed))
})

test_that("change nested text value in XML node", {
  # re-create object sampleRSSparsed
  load("sample_RSS_parsed.RData")
  # re-create object sampleXMLnode.extracted
  load("sample_RSS_changed_value.RData")

  # change text
  node(sampleRSSparsed,
    node=list("rss","channel","item","title"),
    what="value",
    cond.value="Changes in koRpus version 0.04-30") <- "this value was changed!"

  expect_that(
    sampleRSSparsed,
    equals(sampleRSSparsed.changed.value))
})

context("getter/setter methods")

test_that("set and get XML node name", {
  sampleXMLnode <- XMLNode("name", attrs=list(atr="test"))
  # set node name
  XMLName(sampleXMLnode) <- "changed"
  sampleXMLnode.name <- XMLName(sampleXMLnode)

  expect_that(
    sampleXMLnode.name,
    equals("changed"))
})

test_that("set and get XML node attributes", {
  sampleXMLnode <- XMLNode("name", attrs=list(atr="test"))
  # set node attributes
  XMLAttrs(sampleXMLnode) <- list()
  sampleXMLnode.attrs <- XMLAttrs(sampleXMLnode)

  expect_that(
    sampleXMLnode.attrs,
    equals(list()))
})

test_that("set and get XML node text value", {
  sampleXMLnode <- XMLNode("name", attrs=list(atr="test"))
  # set node name
  XMLValue(sampleXMLnode) <- "added value"
  sampleXMLnode.value <- XMLValue(sampleXMLnode)

  expect_that(
    sampleXMLnode.value,
    equals("added value"))
})

test_that("set and get XML node children", {
  sampleXMLnode <- XMLNode("name", attrs=list(atr="test"))
  # children will be returned as a list
  sampleXMLChild <- list(XMLNode("child", attrs=list(atr="test")))
  # set node children
  XMLChildren(sampleXMLnode) <- sampleXMLChild
  sampleXMLnode.children <- XMLChildren(sampleXMLnode)

  expect_that(
    sampleXMLnode.children,
    equals(sampleXMLChild))
})

test_that("set and get XML tree children", {
  load("sample_XML_tree.RData")
  # children will be returned as a list
  sampleXMLChild <- list(XMLNode("child", attrs=list(atr="test")))
  # set node children
  XMLChildren(sampleXMLTree) <- sampleXMLChild
  sampleXMLTree.children <- XMLChildren(sampleXMLTree)

  expect_that(
    sampleXMLTree.children,
    equals(sampleXMLChild))
})

test_that("set and get XML tree DTD info", {
  load("sample_XML_tree.RData")
  sampleDTD <- list(doctype="html", decl="PUBLIC",
    id="-//W3C//DTD XHTML 1.0 Transitional//EN",
    refer="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  # set missing values
  XMLDTD(sampleXMLTree) <- sampleDTD
  # try to get them back
  sampleXMLTree.DTD <- XMLDTD(sampleXMLTree)

  expect_that(
    sampleXMLTree.DTD,
    equals(sampleDTD))
})

test_that("set and get XML tree decl info", {
  load("sample_XML_tree.RData")
  sampleDecl <- list(version="1.0", encoding="UTF-8")
  # set missing values
  XMLDecl(sampleXMLTree) <- sampleDecl
  # try to get them back
  sampleXMLTree.decl <- XMLDecl(sampleXMLTree)

  expect_that(
    sampleXMLTree.decl,
    equals(sampleDecl))
})

test_that("set and get XML tree file info", {
  load("sample_XML_tree.RData")
  # set missing values
  XMLFile(sampleXMLTree) <- "somefile.xml"
  # try to get them back
  sampleXMLTree.file <- XMLFile(sampleXMLTree)

  expect_that(
    sampleXMLTree.file,
    equals("somefile.xml"))
})


context("getter/setter methods: XMLScan")

test_that("scan XML tree for node names", {
  load("sample_XML_tree.RData")

  # this should return a list of 3
  sampleXMLTree.nodes <- XMLScan(sampleXMLTree, "empty")

  expect_is(
    sampleXMLTree.nodes,
    "list")
  expect_that(
    length(sampleXMLTree.nodes),
    equals(3))
})

test_that("remove XML nodes from tree by name", {
  load("sample_XML_tree.RData")

  # this should remove all nodes,
  # exept the parent "tree" node
  XMLScan(sampleXMLTree, "empty") <- NULL

  expect_identical(
    sampleXMLTree,
    XMLTree(XMLNode("tree")))
})

context("XML validation")

test_that("define XML validation scheme", {
  load("sample_XML_validity.RData")
  
  # should generate an object of class XiMpLe.validity
  # try something HTMLish
  # first define <li> validation to use recursively
  XML.validity.li <- XMLValidity(
    children=list(
      li=c("a", "br", "strong")
    ),
    attrs=list(
      a=c("href") # allow only href for testing
    ),
    allChildren=c("!--"),
    allAttrs=c("id", "class"),
    empty=c("br")
  )
  sample_XML_validity.generated <- XMLValidity(
    children=list(
      body=c("a", "p", "ol", "ul", "strong"),
      head=c("title"),
      html=c("head", "body"),
      ol=XML.validity.li,
      p=c("a", "br", "ol", "ul", "strong"),
      ul=XML.validity.li
    ),
    attrs=list(
      a=c("href", "name"),
      p=c("align")
    ),
    allChildren=c("!--"),
    allAttrs=c("id", "class"),
    empty=c("br"),
    ignore=c("foobar")
  )

  expect_that(
    sample_XML_validity.generated,
    equals(sample_XML_validity))
})

test_that("validate XML objects: child nodes", {
  load("sample_XML_validity.RData")

  validChildNodes <- XMLNode("html",
    XMLNode("head",
      XMLNode("!--", "comment always passes"),
      XMLNode("title", "test")
    ),
    XMLNode("!--", "comment always passes"),
    XMLNode("body",
      XMLNode("!--", "comment always passes"),
      XMLNode("p",
        XMLNode("!--", "comment always passes"),
        XMLNode("a", "my link"),
        XMLNode("br"),
        "text goes on"
      ),
      XMLNode("p",
        XMLNode("ol",
          XMLNode("!--",
            XMLNode("undefined", "should be OK because of 'graceful' default mode")
          ),
          XMLNode("li",
            "firstly this"
          ),
          XMLNode("!--", "comment always passes"),
          XMLNode("li",
            "secondly this"
          )
        )
      )
    )
  )
  invalidChildNodes <- XMLNode("html",
    XMLNode("head",
      XMLNode("title", 
        XMLNode("body", "test")
      )
    )
  )
  undefinedChildNodes <- XMLNode("html",
    XMLNode("head",
      XMLNode("meta", "test")
    )
  )
  invalidEmptyNode <- XMLNode("p",
    XMLNode("br", "test")
  )
  validityResultT <- validXML(
    validChildNodes,
    validity=sample_XML_validity,
    attributes=FALSE
  )
  # the object "validityResultF" should be available after this call
  expect_warning(
    validityResultF <- validXML(
      invalidChildNodes,
      validity=sample_XML_validity,
      attributes=FALSE,
      warn=TRUE
    ),
    regexp="Invalid XML nodes for <title> section: body"
  )
  expect_true(validityResultT)
  expect_false(validityResultF)
  expect_error(
    validXML(
      invalidChildNodes,
      validity=sample_XML_validity,
      attributes=FALSE
    ),
    regexp="Invalid XML nodes for <title> section: body"
  )
  expect_error(
    validXML(
      undefinedChildNodes,
      validity=sample_XML_validity,
      attributes=FALSE
    ),
    regexp="Invalid XML nodes for <head> section: meta"
  )
  expect_error(
    validXML(
      invalidEmptyNode,
      validity=sample_XML_validity,
      attributes=FALSE
    ),
    regexp="Invalid XML node <br />: Should be empty, but it isn't!"
  )
})

test_that("validate XML objects: attributes", {
  load("sample_XML_validity.RData")

  validAttributes <- XMLNode("html",
    XMLNode("head",
      XMLNode("title", "test", attrs=list(id="title"))
    ),
    XMLNode("body",
      XMLNode("p",
        XMLNode("a", "my link", attrs=list(href="link.html", class="underline", name="valid"))
      ),
      XMLNode("p",
        XMLNode("ol",
          XMLNode("li",
            "firstly this"
          ),
          XMLNode("li",
            "secondly this",
            attrs=list(id="li2")
          )
        ),
        attrs=list(class="ordered")
      ),
      attrs=list(id="body")
    )
  )
  invalidAttributes <- XMLNode("html",
    XMLNode("head",
      XMLNode("title", "test", attrs=list(href="title.html"))
    )
  )
  invalidRecursion <- XMLNode("html",
    XMLNode("body",
      XMLNode("ol", 
        XMLNode("li",
          XMLNode("a", attrs=list(name="invalid"))
        )
      )
    )
  )
  undefinedAttributes <- XMLNode("body",
    XMLNode("p",
      XMLNode("strong", "test"),
      attrs=list(style="text-align: right;")
    )
  )
  validityResultT <- validXML(
    validAttributes,
    validity=sample_XML_validity,
    children=FALSE
  )
  # the object "validityResultF" should be available after this call
  expect_warning(
    validityResultF <- validXML(
      invalidAttributes,
      validity=sample_XML_validity,
      children=FALSE,
      warn=TRUE
    ),
    regexp="Invalid XML attributes for <title> node: href"
  )
  # the object "validityResultF" should be available after this call
  expect_warning(
    validityResultRecursionF <- validXML(
      invalidRecursion,
      validity=sample_XML_validity,
      children=FALSE,
      warn=TRUE
    ),
    regexp="Invalid XML attributes for <a> node: name"
  )
  expect_true(validityResultT)
  expect_false(validityResultF)
  expect_error(
    validXML(
      invalidAttributes,
      validity=sample_XML_validity,
      children=FALSE
    ),
    regexp="Invalid XML attributes for <title> node: href"
  )
  expect_error(
    validXML(
      undefinedAttributes,
      validity=sample_XML_validity,
      children=FALSE
    ),
    regexp="Invalid XML attributes for <p> node: style"
  )
})


context("Class updates")

test_that("update XML tag tree from XiMpLe.doc to XiMpLe_doc", {
  load("sample_XML_tree_old.RData")
  load("sample_XML_tree.RData")

  sampleXMLTree_old <- as_XiMpLe_doc(sampleXMLTree_old)

  expect_that(
    sampleXMLTree_old,
    equals(sampleXMLTree)
  )
})
