## Test environments
* local OS X install, R 4.1.3
* win-builder (devel and release)

## R CMD check results
There was one ERROR

* checking package dependencies ... ERROR
  Package required but not available: 'flextable'
  
We encountered this error on Windows Server 2022, R-devel, 64 bit running `devtools::check_rhub()`. The flextable package is listed under Imports in our DESCRIPTION file. We can't recreate the the issue on any other system.

There were no WARNINGs

There were 2 NOTEs

* Maintainer: 'Brad Cannell <brad.cannell@gmail.com>'. 

No action taken.

* checking examples ... [16s] NOTE
  Examples with CPU (user + system) or elapsed time > 10s
           user system elapsed
  codebook 12.1      1   13.78
  
We wrapped the `codebook()` example with `\dontrun{}`. Our understanding is that this is permissible when example execution takes > 5 secs.

## Downstream dependencies
There are currently no downstream dependencies for this package.
