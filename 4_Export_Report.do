/**
Using the REDCap API with Stata
Luke Stevens, Murdoch Childrens Research Institute 
20-Jun-2017

4. Export_Report.do
   Specify a REDCap report to download.
   
   --form content=report
   --form report_id=<id> // numeric report id from right-hand column of report list

   	--form longitudinal_reports=1 // can be used with "longitudinal reports" too (invalid variable names) 
*/

version 12
set more off
clear 

local token "<insert your token here>"
local report_id=<report id here>
local outfile "exported_data.csv"

shell c:\curl\curl.exe				///
	--output `outfile' 				///
	--form token=`token'			///
	--form content=report 			///
	--form format=csv 				///
	--form type=flat 				///
	--form report_id=`report_id'	///
	"https://redcap.mcri.edu.au/api/"

import delimited `outfile'
br
