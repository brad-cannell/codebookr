## Test environments
* local OS X install, R 4.2.1
* win-builder (devel and release)

## R CMD check results
There were no ERRORs

There were no WARNINGs

There were 3 NOTEs

1. We encountered this note on Windows Server 2022, R-devel, 64 bit running `devtools::check_rhub()`. 

checking Rd files ... NOTE
checkRd: (-1) cb_add_col_attributes.Rd:41-51: Lost braces in \itemize; meant \describe ?
checkRd: (-1) cb_add_col_attributes.Rd:52-61: Lost braces in \itemize; meant \describe ?
checkRd: (-1) cb_add_col_attributes.Rd:62-95: Lost braces in \itemize; meant \describe ?
checkRd: (-1) cb_add_col_attributes.Rd:96-131: Lost braces in \itemize; meant \describe ?
checkRd: (-1) cb_add_col_attributes.Rd:132-141: Lost braces in \itemize; meant \describe ?

cb_add_col_attributes.Rd was automatically created by the roxygen2 package. However, when we preview cb_add_col_attributes.Rd, the help documentation looks as expected. Therefore, no action was taken.

2. We encountered this note on Windows Server 2022, R-devel, 64 bit running `devtools::check_rhub()`.

checking for non-standard things in the check directory ... NOTE

There is no file name given. We aren't sure what this note is referrring to. Therefore, no action was taken.

3. We encountered this note on Windows Server 2022, R-devel, 64 bit running `devtools::check_rhub()`.

checking for detritus in the temp directory ... NOTE
Found the following files/directories:
  'lastMiKTeXException'
  
We aren't able to locate this file/directory or recreate this problem on any other system. Therefore, no action was taken.

## Downstream dependencies
There are currently no downstream dependencies for this package.
