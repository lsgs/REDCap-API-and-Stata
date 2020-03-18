/**
Using the REDCap API with Stata
Luke Stevens, Murdoch Childrens Research Institute 
20-Jun-2017

7. Build_Command_String.do
   An example of building the curl command programmatically.
   - Timestamp in downloaded file name
   - Iterate a supplied list of fields
   - Iterate a supplied list of evnts
   - Iterate a supplied list of instruments
*/

version 12
set more off
clear 

local token="<insert your token here>"

local content="record"
local format="csv"
local type="flat"

local data "token=`token'&content=`content'&format=`format'&type=`type'"

local curlpath="c:\curl\curl.exe"
local apiurl="https://redcap.mcri.edu.au/api/"

local dttm : display %td_CY-N-D  date("$S_DATE", "DMY") "_$S_TIME"
local outfile = "redcap_api_export_"+trim(subinstr(subinstr("`dttm'","-","",.),":","",.))+".csv"


// Request selected fields 
local param "fields"
local i 0 
foreach listentry in ///
	record_id /// // include record id field if you're not downloading the first form
	dob       ///
	gender    ///
{
	local data "`data'&`param'[`i']=`listentry'" 
	local i=`i'+1
}

// Request selected events 
local param "events"
local i=0 
foreach listentry in ///
	enrolment_arm_1				///
	randomisation_arm_1 		///
	3month_questionnai_arm_1 	///
	6month_visit_arm_1			///
	9month_questionnai_arm_1	///	
	12month_visit_arm_1			///
{
	local data "`data'&`param'[`i']=`listentry'" 
	local i=`i'+1
}


// Request selected instruments 
local param "forms"
local i=0 
foreach listentry in ///
	visit			///
	questionnaire 	///
{
	local data "`data'&`param'[`i']=`listentry'" 
	local i=`i'+1
}

shell curl --output "`outfile'" --data "`data'" "`apiurl'"

import delimited using `outfile', varnames(1) clear
br
