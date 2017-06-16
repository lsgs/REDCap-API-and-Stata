/**
Using the REDCap API with Stata
Luke Stevens, Murdoch Childrens Research Institute 
20-Jun-2017

6. Import_Records.do
   Illustrating data import - API is not just for export. 
   (This example toggles the gender of first record 1 <-> 2)

   Ensure that you (your role) has "API Import" permission.
*/

version 12
set more off
clear 

local token "<insert your token here>"
local outfile "exported_data.csv"
local fileforimport "data_for_import.csv"

shell c:\curl\curl.exe --output `outfile' --form token=`token' --form content=record --form format=csv --form type=flat --form fields[]=record_id --form fields[]=gender "https://redcap.mcri.edu.au/api/"
import delimited `outfile'

keep if _n==1
replace gender=1+(!(gender-1)) // toggle gender 1 <-> 2
export delimited using `fileforimport', nolabel replace

local cmd="c:\curl\curl.exe" 			///
          + " --form token=`token'" 	///
          + " --form content=record" 	///
          + " --form format=csv" 		///
          + " --form type=flat" 		///
          + " --form data="+char(34)+"<`fileforimport'"+char(34) /// The < is critical! It causes curl to read the contents of the file, not just send the file name.
          + " https://redcap.mcri.edu.au/api/"

shell `cmd'
