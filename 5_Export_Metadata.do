/**
Using the REDCap API with Stata
Luke Stevens, Murdoch Childrens Research Institute 
20-Jun-2017

5. Export_Metadata.do
   Illustrating metadata (data dictionary) download - not just records.
   
   --form fields=varname // download varname metadata (only)

   --form fields[]=varname1 // download varname1 ...
   --form fields[]=varname2 // ...and varname2 metadata
   
   --form forms=formname // download all variables of formname 

   --form forms[]=formname1 // download all variables of formname1 ...
   --form forms[]=formname2 // ...and all from formname2 
*/

version 12
set more off
clear 

local token "<insert your token here>"

local outfile "exported_metadata.csv"

shell c:\curl\curl.exe				///
	--output `outfile' 				///
	--form token=`token'			///
	--form content=metadata			///
	--form format=csv 				///
	"https://redcap.mcri.edu.au/api/"

import delimited `outfile'
br
