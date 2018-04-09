/**
Using the REDCap API with Stata
Luke Stevens, Murdoch Childrens Research Institute 
10-Apr-2018

9. Delete_Records.do
   An example of deleting multiple records.
   Nb. The user must have the "Delete Records" permission enabled.
*/

version 12
set more off
clear 

local curlpath="c:\curl\curl.exe"
local apiurl="https://redcap.mcri.edu.au/api/"
local tempfile "tempdata.csv"

local token "<insert your token here>"

*_______________________________________________________________________________
* first generate and import a few records that we can afterwards delete
** find the name of the record_id field
local cmd="`curlpath'" 		         	///
          + " --form token=`token'" 	///
          + " --form content=metadata" 	///
          + " --form format=csv" 		///
          + " --output `tempfile'" ///
          + " `apiurl'"

shell `cmd'
import delimited `tempfile'

local pkfield=field_name in 1

clear

** generate some test records and import
gen str11 `pkfield'=""
local recidstem="DELETETEST"
local numrecs=4
set obs `numrecs'
forvalues i=1/`numrecs' {
	replace `pkfield'="`recidstem'"+string(`i') in `i'
}

export delimited using `tempfile', nolabel replace

local cmd="`curlpath'" 			///
          + " --form token=`token'" 	///
          + " --form content=record" 	///
          + " --form format=csv" 		///
          + " --form type=flat" 		///
          + " --form data='<`tempfile'' `apiurl'"

shell `cmd'
shell rm `tempfile'
*_______________________________________________________________________________

* now build the delete command
local recordlist
forvalues i=1/`numrecs' {
	local recordlist="`recordlist' --form records[]=`recidstem'"+string(`i')
}

local cmd="`curlpath'" 					///
          + " --form token=`token'" 	///
          + " --form content=record" 	///
          + " --form action=delete"		///
          + " `recordlist' " /// 
          + " `apiurl'"

shell `cmd'

* now check your project's Logging page...
*_______________________________________________________________________________
