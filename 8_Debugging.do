/**
Using the REDCap API with Stata
Luke Stevens, Murdoch Childrens Research Institute 
20-Jun-2017

8. Debugging.do
   How to troubleshoot your do-file and API calls:
   - Badly formed curl command -> display and copy to command prompt
   - API returns error         -> review contents of outfile
*/

version 12
set more off
clear 

local token "<insert your token here>"
local outfile "test_download.csv"

local cmd="c:\curl\curl.exe" 			///
          + " --output `outfile'" 		///
          + " --form token=`token'" 	///
          + " --form content=record" 	///
          + " --form format=csv" 		///
          + " --form type=flat" 		/// note no space between this and url -> "no url"
          + "https://redcap.mcri.edu.au/api/"

display "`cmd'" // copy -> open command prompt -> right-click paste -> run
shell `cmd'

import delimited `outfile'
br
