*set maxvar 10000
use "C:\Users\Nemoo\Desktop\oh\played data\6.27_zxy.dta", clear

* Rename death year variables
rename d0vyear dthyear_0
rename d2vyear dthyear_2
rename d5vyear dthyear_5
rename d8vyear dthyear_8
rename d11vyear dthyear_11
rename d14vyear dthyear_14
rename d18vyear dthyear_18

* Rename death indicators
rename dth_f1 dth_0 
rename dth_f2 dth_2 
rename dth_f3 dth_5 
rename dth_f4 dth_8 
rename dth_f5 dth_11 
rename dth_f6 dth_14 
rename dth_f7 dth_18 

* Replace missing codes with actual missing values for death year variables
foreach var of varlist dthyear_* {
    replace `var' = . if `var' == -9 | `var' == -8 | `var' == -7 | `var' == 9999
}

* Initialize death event year variable
gen death_year = .

* Loop through waves to find the first occurrence of death
foreach wave in 0 2 5 8 11 14 18 {
    replace death_year = dthyear_`wave' if death_year == . & dth_`wave' == 1
}

* Set death year to the last observed year if no death occurred
foreach wave in 18 14 11 8 5 2 0 {
    replace death_year = dthyear_`wave' if death_year == . & !missing(dthyear_`wave')
}

* Calculate the time to event from baseline year
gen time_to_death = death_year - yearin_98

* Initialize cognitive impairment event year variable
gen event_year = .

* Loop through waves to find the first occurrence of cognitive impairment
foreach wave in 0 2 5 8 11 14 18 {
    replace event_year = yearin_`wave' if event_year == . & mmse_bi_`wave' == 1
}

* Set event year to the last observed year if no cognitive impairment occurred
foreach wave in 18 14 11 8 5 2 0 {
    replace event_year = yearin_`wave' if event_year == . & !missing(yearin_`wave')
}

* Calculate the time to event from baseline year
gen time_to_event = event_year - yearin_98

* Create combined time-to-event variable
gen combined_time_to_event = .
replace combined_time_to_event = time_to_event if !missing(time_to_event)
replace combined_time_to_event = time_to_death if !missing(time_to_death) & (missing(combined_time_to_event) | time_to_death < combined_time_to_event)

* Create the event type indicator
gen event_type = .
replace event_type = 1 if combined_time_to_event == time_to_event
replace event_type = 2 if combined_time_to_event == time_to_death

* Handle censored data explicitly
replace event_type = 0 if combined_time_to_event == . & (missing(time_to_event) & missing(time_to_death))

* Check for inconsistencies
list id combined_time_to_event time_to_event time_to_death if combined_time_to_event >= . | combined_time_to_event <= 0

* Ensure that entry and exit times are logical
gen entry_time = 0
replace combined_time_to_event = . if combined_time_to_event <= entry_time


rename g21_cat Natural_Teeth

label define Natural_Teeth_lbl 0 "0 Teeth" 1 "1-9 Teeth" 2 "10-19 Teeth" 3 "20+ Teeth"
label values Natural_Teeth Natural_Teeth_lbl

rename g22 Denture
label define Denture_lbl 0 "No" 1 "Yes"
label values Denture Denture_lbl


* Set the data for survival analysis
stset combined_time_to_event, failure(event_type == 1) id(id)

* Declare the categorical variable g21_cat with 3 as the reference group
stcrreg ib4.Natural_Teeth, compete(event_type == 2)
* Perform the Cox model for competing risks
stcrreg Denture, compete(event_type == 2)
* Perform the Cox model for competing risks
stcrreg cmm_bi, compete(event_type == 2)


