/*******************************************************************************
Example of API File Export and Import
Luke Stevens
22-Jan-2021
*******************************************************************************/

version 16
clear 
set more off

import delimited tokens.txt
local apisource=url in 1
local apidest=url in 2
local tokensource=token in 1
local tokendest=token in 2
local fieldsource=field_name in 1
local fielddest=field_name in 2

clear

di "'`apisource''"
di "'`apidest''"
di "'`tokensource''"
di "'`tokendest''"

tempname tmpname
local tempexportfile="`tmpname'.csv"

* download records with files from source project
shell curl 						/// 
	--output `tempexportfile'   ///
	--form token=`tokensource'	///
	--form content=record   	///
	--form format=csv   		///
	--form type=flat 	  		///
	--form filterLogic="[`fieldsource']<>''" ///
	`apisource'

import delimited `tempexportfile', clear
rm `tempexportfile'

* loop through obs and upload file to destination
local N = _N
local thisrec
local thisfile
forvalues i = 1/`N' {
	local thisrec=record_id[`i']
	local thisfile=`fieldsource'[`i']
	local destrec=`thisrec'
	
	if "`thisfile'"!="" {
		* download file from source record
		di  "Record `thisrec': downloading file `thisfile'"
		
		shell curl 						/// 
			--output "`thisfile'"       ///
			--form token=`tokensource'	///
			--form content=file      	///
			--form action=export   		///
			--form record="`thisrec'"	///
			--form field=`fieldsource'	///
			--form returnFomat=json     ///
			`apisource'

		* upload file to destination record
		di  "Uploading file to destination record `destrec'"
		
		shell curl 						 /// 
			--form token=`tokendest'	 ///
			--form content=file      	 ///
			--form action=import   		 ///
			--form record="`destrec'"	 ///
			--form field=`fielddest'	 ///
			--form filename="`thisfile'" ///
			--form file=@"`thisfile'"    ///
			`apidest'
		
		rm `thisfile'
	}
}
