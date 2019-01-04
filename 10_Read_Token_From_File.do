/**
Using the REDCap API with Stata
Luke Stevens, Murdoch Childrens Research Institute 
04-Jan-2019

10. Read_Token_From_File.do 
   Do not save API tokens in scripts that may get seen by others.
   Your script should read in your token from a private location.
*/

version 12
set more off
clear 

* specify a text file where the token is stored as the only text of first line
local tokenfile "C:\Users\my.username\Documents\ThisProject\API_Token\token.txt"

* read in your token from token.txt file in working directory
import delimited "`tokenfile'", varnames(nonames)
local token=v1 in 1

local tmpcsvfile "temp.csv"

shell curl 						/// 
	--output `tmpcsvfile' 		///
	--form token=`token'  		///
	--form content=record   	///
	--form format=csv   		///
	--form type=flat 	  		///
	"https://redcap.mcri.edu.au/api/"

import delimited `tmpcsvfile', clear
rm `tmpcsvfile'
br
