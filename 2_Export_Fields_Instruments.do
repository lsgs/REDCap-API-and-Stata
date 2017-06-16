/**
Using the REDCap API with Stata
Luke Stevens, Murdoch Childrens Research Institute 
20-Jun-2017

2. Export_Fields_Instruments.do 
   Specify specific fields and instruments to download.
   
   --form fields=varname // include varname in downloaded dataset

   --form fields[]=varname1 // include varname1 ...
   --form fields[]=varname2 // ...and varname2 in downloaded dataset
   
   --form forms=formname // include all variables of formname in downloaded dataset

   --form forms[]=formname1 // include all variables of formname1 ...
   --form forms[]=formname2 // ...and all from formname2 in downloaded dataset
*/

version 12
set more off
clear 

local token "<insert your token here>"
local outfile "exported_data.csv"

shell c:\curl\curl.exe			///
	--output `outfile' 			///
	--form token=`token'		///
	--form content=record 		///
	--form format=csv 			///
	--form type=flat 			///
	--form fields[]=record_id	///
	--form fields[]=gender		///
	--form forms=randomisation 	///
	"https://redcap.mcri.edu.au/api/"

import delimited `outfile'
br
