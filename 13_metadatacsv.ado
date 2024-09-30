cap program drop metadatacsv
program define metadatacsv
version 13

preserve

qui describe, replace clear
local fullpath: char _dta[d_filename]
mata: st_local("fullname", pathbasename("`fullpath'"))
local length=strpos("`fullname'",".")-1
local filestub=substr("`fullname'",1,`length')

restore,preserve

tempname mem
tempfile vals dtavals

qui uselabel,clear
qui count
local numlab=r(N)
if `numlab'>0 {
	gen recnum=_n
	assert trunc==0
	qui levelsof lname, local(levels)

	qui file open `mem' using "`vals'", write
	foreach x of local levels {
		local fullab
		qui su recnum if lname=="`x'"
		local j=r(min)
		local k=r(max)
		forval i=`j'/`k' {
			local val=value[`i']
			local lab=label[`i']
			local fullab `fullab' `val', `lab' | 
		}
		local lenlab=strlen("`fullab'")-2
		local fullab=substr("`fullab'",1,`lenlab')
		file write `mem' "`x'" _tab "`fullab'" _newline
	}
	qui file close `mem'

	qui import delimited using "`vals'",varnames(nonames) clear
	rename v1 vallab
	rename v2 choices
	qui save `dtavals'
}

restore,preserve

describe, clear replace

if `numlab'>0 {
	qui merge m:1 vallab using `dtavals'
	drop _merge
	sort position
}
else {
	qui gen choices=""
}
drop position

order name varlab type isnumeric format vallab choices

export delimited "dict_`filestub'.csv", replace

qui restore

end
