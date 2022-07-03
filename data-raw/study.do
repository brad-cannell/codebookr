version 16.1
set more off
capture log close
cd "/Users/bradcannell/Dropbox/R/Packages/codebookr"

/************************************************************************
Study data
This is the code to create the study data - a simulated dataset that can be
used to demonstrate how to use the codebook package.
Created: 2022-06-14
Brad Cannell

- The original data is created in codebookr/data_raw/study.R
- It is then exported to codebookr/inst/extdata/study.csv
- Below, we import it and add lables
- Then we export the labled data as codebookr/inst/extdata/study.dta so 
  that it can be used for demonstration purposes.
************************************************************************/


// Import data
import delimited "/Users/bradcannell/Dropbox/R/Packages/codebookr/inst/extdata/study.csv", delimiter("", collapse) encoding(ISO-8859-2) clear

// Convert NA to missing
replace id = "" if id == "NA"
replace sex = "" if sex == "NA"
replace date = "" if date == "NA"
destring days, replace force
destring height, replace force

// Coerce date and time types
gen date2 = date(date, "YMD")
format date2 %tdCCYY-NN-DD
drop date
rename date2 date
order date, after(sex)

gen time2 = clock(time, "hms")
format time2 %tcHH:MM:SS
drop time
rename time2 time
order time, after(date)

gen date_time2 = clock(date_time, "YMD#hms#")
format date_time2 %tcCCYY-NN-DD_HH:MM:SS
drop date_time
rename date_time2 date_time
order date_time, after(time)

// Coerce sex to 1's and 2's and then add value lables so that R will add
// the class haven_labeled on import. 
encode sex, gen(sex2)
drop sex
rename sex2 sex
order sex, after(id)

// Add labels to the data
la var id "Participant's study identification number"
la var sex "Biological sex of the participant assigned at birth"
la var date "Participant's date of enrollment"
la var time "Participant's time of enrollment"
la var date_time "Participant's date and time of enrollment"
la var days "Total number of days the participant was enrolled in the study"
la var height "Participant's height in inches at date of enrollment"
la var likert "An example Likert scale item" 
la var outcome "Participant experienced the outcome of interest"

// Save data 
save "inst/extdata/study.dta", replace
