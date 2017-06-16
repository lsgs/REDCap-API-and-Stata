/**
Using the REDCap API with Stata
Luke Stevens, Murdoch Childrens Research Institute 
20-Jun-2017

3. Export_Filter.do
   Specify an expression that will filter the records downloaded.
   
   --form filterLogic="<expr>" // expression in REDCap syntax
*/

version 12
set more off
clear 

local token "<insert your token here>"
local outfile "exported_data.csv"

shell c:\curl\curl.exe									///
	--output `outfile' 									///
	--form token=`token'								///
	--form content=record 								///
	--form format=csv 									///
	--form type=flat 									///
	--form filterLogic="[enrolment_arm_1][gender]='1'" 	///
	"https://redcap.mcri.edu.au/api/"

import delimited `outfile'
br

/**
Note this is equivalent to downloading all followed by
keep if redcap_event_name=="enrolment_arm_1" & gender==1
*/
