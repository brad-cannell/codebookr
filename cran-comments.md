## Resubmission
This is a resubmission. In this version I have:

* Edited README. Fixes: "Found the following (possibly) invalid file URI: URI: %7B From: README.md"

* Edited DESCRIPTION. "Please do not start the description with "This package", package name, title or similar."

* Removed \dontrun{} from codebook.R example section.

## Test environments
* local OS X install, R 4.1.3
* win-builder (devel and release)

## R CMD check results
There were no ERRORs
There were no WARNINGs
There was 1 NOTE:

* checking installed package size ... NOTE
    installed size is  7.7Mb
    sub-directories of 1Mb or more:
      help   7.5Mb
      
  As far as I can tell from my online search, this NOTE can be ignored.
  
* Found the following (possibly) invalid URLs:
  URL: https://www.r-pkg.org/pkg/codebookr
    From: README.md
    Status: 500
    Message: Internal Server Error
    
  This url is for a CRAN downloads badge that on my README page. The URL will be valid as soon as codebookr is available on CRAN.

## Downstream dependencies
There are currently no downstream dependencies for this package.
