/**
Using the REDCap API with Stata
Luke Stevens, Murdoch Childrens Research Institute 
20-Jun-2017

1. Simple_Export.do 
   A basic API call to download all data from your REDCap project to a CSV file.
*/

version 12
set more off
clear 

local token "<insert your token here>"
local outfile "exported_data.csv"

shell c:\curl\curl.exe		///
	--output `outfile' 		///
	--form token=`token'	///
	--form content=record 	///
	--form format=csv 		///
	--form type=flat 		///
	"https://redcap.mcri.edu.au/api/"

import delimited `outfile'
br
