/*******************************************************************************
Download a dataset using the REDCap API
Download metadata for the variables and apply labels etc.

Note the following field types cannot be labelled:
- redcap_data_access_group
- text fields utilising the Bioportal ontology lookup
- dynamic sql

Luke Stevens 06-Mar-2020
*******************************************************************************/

cap program drop get_redcap_metadata
program get_redcap_metadata
	version 16
	args apiurl apitoken

	if !regexm("`apiurl'", "^https://.+/api/$") {
		display "API url appears invalid (`apiurl')"
		exit
	}
	if !(regexm("`apitoken'", "^[A-F0-9]+$") & strlen("`apitoken'")==32) {
		display "API token appears invalid (`apitoken')"
		exit
	}
	
	* download metadata for dataset variables
	quietly {
		frame create redcapmetadata
		frame change redcapmetadata
		local tempcsv="adotempcsv.csv"
		local content="metadata"
		local outformat="csv"
		local data "token=`apitoken'&content=`content'&format=`outformat'"
		noisily display "Downloading REDCap data dictionary..."
		shell curl --output "`tempcsv'" --data "`data'" "`apiurl'"

		capture frame drop redcapmetadata
		frame redcapmetadata: import delimited `tempcsv', bindquotes(strict)
		erase `tempcsv'

		capture confirm variable field_name
		if _rc!=0 | _N==0 {
			display "Could not read data dictionary"
			exit
		}
		
		* remove line breaks and other tricky characters from field labels
		replace field_label = subinstr(field_label, char(10), " ", .) // LF
		replace field_label = subinstr(field_label, char(13), " ", .) // CR
		replace field_label = subinstr(field_label, char(34), "'", .) // "
		replace select_choices_or_calculations = subinstr(select_choices_or_calculations, char(34), "'", .) // "

		* apply metadata
		frame change default

		* define standard labels (end with two underscores to help avoid conflict with any existing)
		label define yesno__ 1 "Yes"  0 "No"
		label define truefalse__ 1 "True" 0 "False" 
		label define checkbox__ 1 "Checked" 0 "Unchecked" 
		label define complete__ 0 "Incomplete" 1 "Unverified" 2 "Complete" 
		
		foreach v of varlist _all {
			frame change redcapmetadata
			
			if regexm("`v'", "^.+___.+$") {
				* checkbox column e.g. cb___opt1
				local ddvar = substr("`v'", 1, strpos("`v'", "___")-1) // e.g. cb
				local cbval = substr("`v'", strpos("`v'", "___")+3, .) // e.g. opt1
			}
			else {
				local ddvar = "`v'"
				local cbval = ""
			}

			count if field_name=="`ddvar'" 

			if r(N)>0 {
				* v is present in data dictionary -> read the metadata
				preserve
				drop if field_name!="`ddvar'"
				local lbl=field_label
				local frm=form_name
				local ftype=field_type
				local valtype=text_validation_type_or_show_sli
				local enum=select_choices_or_calculations
				
				frame change default

				noisily display "Variable `v': `frm' `ftype' `valtype'"
				
				if "`ftype'"=="text" & substr("`valtype'", 1, 5)=="date_" {
					* convert date variables from string to date_
					tostring `v', replace
					gen _temp_ = date(`v',"YMD"), after(`v')
					drop `v'
					rename _temp_ `v'
					format `v' %dM_d,_CY
				}
				else if "`ftype'"=="text" & substr("`valtype'", 1, 9)=="datetime_" {
					* convert date variables from string to date_
					tostring `v', replace
					gen double _temp_ = Clock(`v',"YMDhms"), after(`v')
					drop `v'
					rename _temp_ `v'
					format `v' %tCMonth_dd,_CCYY_HH:MM:SS
				}
				else if "`ftype'"=="dropdown" | "`ftype'"=="radio" | "`ftype'"=="checkbox" {
					* parse out choices and make label values
					local lblvals ""
					local skiplabel 0
					tokenize "`enum'", parse("|")
					while "`*'" != "" {
						if "`1'"!="|" {
							local choice "`1'"
							local choiceval = substr("`choice'", 1, strpos("`choice'", ",")-1)
							local choicelbl = strtrim(substr("`choice'", strpos("`choice'", ",")+1, .))
							
							if "`ftype'"=="checkbox" {
								if "`choiceval'"=="`cbval'"{
									label values `v' checkbox__
									local lbl "`lbl' `choicelbl'"
								}
							}
							else {
								if (regexm("`choiceval'", "^[0-9/-]+$")) {
									label define `v'_ `choiceval' "`choicelbl'", add
								} 
								else {
									local skiplabel 1
									noisily display "-Cannot label non-integer value `choiceval'"
								}
							}
						}
						macro shift // shift tokens `2'->`1', `3'->`2' etc.
					}
					
					if "`ftype'"=="checkbox" {
						label values `v' checkbox__
					}
					else {
						if (!`skiplabel') {
							label values `v' `v'_
						}
					}
				}
				else if "`ftype'"=="yesno" {
					label values `v' yesno__
				}
				else if "`ftype'"=="truefalse" {
					label values `v' truefalse__
				}
				
				* add full label as note in case length >80 hence truncated
				note `v': "`lbl'"
				
				frame change redcapmetadata
				restore
				frame change default
			}
			else {
				frame change default
				if substr("`v'", -9, .)=="_complete" {
					label values `v' complete__
				}

				noisily display "Variable `v': not in data dictionary"
				local lbl "`ddvar'"
			}
			label variable `v' "`lbl'"
		}

		frame drop redcapmetadata
	}
end