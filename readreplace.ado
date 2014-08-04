*! v1 by Ryan Knight 12jan2011

cap prog drop readreplace
prog def readreplace
	syntax using/ , ID(varname) [DIsplay]
	
	* Check that ID is actually a unique identifier and get its type
	capture confirm numeric variable `id'
	if !_rc {
		local quote
	}
	else {
		local quote `"""'
		/* " */
	}
	* Read in the file
	tempname myfile
	file open `myfile' using `"`using'"', read // "
	file read `myfile' line
	if "`display'"!="" {
		di as txt "Reading line: " as res `"`line'"' // "
	}
	gettoken idval 0: line, parse(",")
	gettoken c1 0: 0, parse(",")
	gettoken q 0: 0, parse(",")
	gettoken c2 0: 0, parse(",")
	gettoken qval 0: 0, parse(",")
	gettoken c3 0: 0, parse(",")
	
	* Check that it is comma separated and doesn't have too many/few rows
	cap assert "`c1'" =="," & "`c2'"=="," & "`c3'"==""
	if _rc {
		di _newline as err "Error: Using file has improper format"
		di as txt "The using file must have the format: " as res "`id',varname,correct_value"
		di as txt "Your files has the format: " as res "`line'"
		file close `myfile'
		exit 198
	}
	* Loop through lines in the file, making replacements as necessary
	if "`display'" == "" {
		local qui qui
	}
	local changes = 0
	file read `myfile' line 
	while r(eof)==0 {
		if "`display'"!="" {
			di as txt "Reading line: " as res `"`line'"' // "
		}
		gettoken idval 0: line, parse(",")
		gettoken c1 0: 0, parse(",")
		gettoken q 0: 0, parse(",")
		if `"`q'"' == "," {
			di as err `"Question missing in line `line' "' // "
			exit 198
		}
		gettoken c2 0: 0, parse(",")
		local qval `0'
		
		* Delete double quotes that result if you use commas within quotes in a csv file
		local qval: subinstr local qval `""""' `"""', all
		
		* check that q is a variable
		capture confirm variable `q'
		if _rc {
			di _newline as err "Error!" _newline as res "`q'" as txt " is not a variable name"
			di as txt "The using file must have the format: " as res "`id',varname,correct_value"
			file close `myfile'	
			exit 198
		}
		
		* check that the observation exists
		qui count if `id' == `quote'`idval'`quote'
		if `r(N)' == 0 {
			di _newline as err "Observation " as res `"`idval'"' as err " not found" // "
			file close `myfile'	
			exit 198
		}
		
		* Check var type
		capture confirm numeric variable `q'
		if _rc {
			local vquote `"""'
		}	
		else {
			local vquote
			if `"`qval'"' == `""' {
				// "
				local qval .
			}
		}
		
		* Make replacement
		qui count if `q'!=`vquote'`qval'`vquote' & `id'==`quote'`idval'`quote'
		local changes = `changes' + `r(N)'
		if `r(N)' > 0 {
			if "`display'" != "" {
				di as input `"replace `q'=`vquote'`qval'`vquote' if `id'==`quote'`idval'`quote'"' //"
			}
			`qui' replace `q'=`vquote'`qval'`vquote' if `id'==`quote'`idval'`quote'
		}
		file read `myfile' line
	}
	file close `myfile'
	di _newline as txt "Total changes made: " as res `changes'
end
