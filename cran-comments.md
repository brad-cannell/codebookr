## Test environments
* local OS X install, R 4.2.1
* win-builder (devel and release)

## R CMD check results
There were no ERRORs

There were no WARNINGs

There were 2 NOTEs

1. checking CRAN incoming feasibility ... [17s] NOTE
  Maintainer: 'Brad Cannell <brad.cannell@gmail.com>'
  
  Days since last update: 2
  
We realize that it has only been two days since we submitted our last update, but this bug fix is important.

2. We encountered this note on Windows Server 2022, R-devel, 64 bit running `devtools::check_rhub()`.

checking for non-standard things in the check directory ... NOTE
Found the following files/directories:
    ''NULL''

There is no file name given. We aren't sure what this note is referring to. Therefore, no action was taken.

3. We encountered this note on Windows Server 2022, R-devel, 64 bit running `devtools::check_rhub()`.

checking for detritus in the temp directory ... NOTE
Found the following files/directories:
  'lastMiKTeXException'
  
We aren't able to locate this file/directory or recreate this problem on any other system. Therefore, no action was taken.

## Downstream dependencies
There are currently no downstream dependencies for this package.
