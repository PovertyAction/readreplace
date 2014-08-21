vers 10

clear
set obs 10000


/* -------------------------------------------------------------------------- */
					/* unique IDs			*/

* Create the unique ID variables.

* Numeric

* numid1: a single variable that uniquely identifies observations.
gen numid1 = _n
isid numid1
lab var numid1 "Numeric unique ID (#1)"

* numid2_*: two variables that uniquely identify observations.
gen numid2_1 = cond(_n <= _N / 2, 1, 2)
bys numid2_1: gen numid2_2 = _n
isid numid2_*
lab var numid2_1 "Numeric unique ID along with numid2_2 (#2)"
lab var numid2_2 "Numeric unique ID along with numid2_1 (#2)"

* numid3: a single variable that almost but doesn't quite uniquely identify
* observations.
gen numid3 = _n
replace numid3 = 1 in 2
lab var numid3 "Almost a numeric unique ID (#3)"

* Create equivalent string ID variables.
foreach var of var numid* {
	loc newvar : subinstr loc var "num" "str"
	loc len 50
	mata: st_sstore(., st_addvar("str`len'", "`newvar'"), ///
		inbase(16, st_data(., "`var'")))
	assert strlen(`newvar') < `len'
	forv i = 0/9 {
		loc c = char(65 + `i')
		assert !strpos(`newvar', "`c'")
		replace `newvar' = subinstr(`newvar', "`i'", "`c'", .)
	}
	loc lab : var lab `var'
	loc lab : subinstr loc lab "numeric" "string", all
	loc lab : subinstr loc lab "Numeric" "String", all
	loc lab : subinstr loc lab "num"     "str",    all
	lab var `newvar' "`lab'"
}

gen mixid1 = cond(_n <= _N / 2, "A", "B")
bys mixid1: gen mixid2 = _n
lab var mixid1 "Mixed-type unique ID along with mixid2"
lab var mixid2 "Mixed-type unique ID along with mixid1"


/* -------------------------------------------------------------------------- */
					/* other variables		*/

loc RS	real scalar
loc RR	real rowvector
loc RC	real colvector
loc RM	real matrix
loc SS	string scalar
loc SR	string rowvector
loc SC	string colvector
loc SM	string matrix
loc TS	transmorphic scalar
loc TR	transmorphic rowvector
loc TC	transmorphic colvector
loc TM	transmorphic matrix

cap mata: mata drop randstr()
mata:
void function randstr(`SS' _var, `RR' _okchars)
{
	`RS' nchars, nobs, i
	`RC' len
	`SC' var

	// Check _var, defining var as a view onto it.
	assert(st_vartype(_var) == "str244")
	pragma unset var
	st_sview(var, ., _var)

	// Check _okchars.
	nchars = length(_okchars)
	assert(nchars)

	nobs = st_nobs()
	len = ceil(244 * runiform(nobs, 1))
	for (i = 1; i <= nobs; i++)
		var[i] = invtokens(char(_okchars[ceil(nchars * runiform(1, len[i]))]))
}
end

loc fracmiss .1
mata: okchars = 1..255
foreach suffix in "" correct {
	* integer
	gen integer`suffix' = ceil(100 * runiform()) if runiform() > `fracmiss'

	* real
	gen real`suffix' = runiform() if runiform() > `fracmiss'

	* string
	gen str244 string`suffix' = ""
	mata: randstr("string`suffix'", okchars)
	* Add missing values.
	assert !mi(string`suffix')
	replace string`suffix' = "" if runiform() <= `fracmiss'
	* Check the maximum length of the variable.
	gen len = strlen(string`suffix')
	su len
	assert r(max) == 244
	drop len
	* Check that all ASCII characters are represented.
	forv i = 1/255 {
		cou if strpos(string`suffix', char(`i'))
		assert r(N)
	}
	* Check that the variable contains a string that requires
	* an expression that includes multiple strings.
	if c(stata_version) >= 11.2 {
		mata: i = n = 0
		mata: while (n < 2 & ++i <= st_nobs()) ///
			specialexp(st_sdata(i, "string`suffix'"), n);;
		mata: assert(n > 1)
	}
}
lab var integer		"Some integer"
lab var real		"Some real number [0, 1)"
lab var string		"Some string"

gen unused = "Hello world"
lab var unused "Constant, unused variable"

compress
preserve
drop *correct
sa gen_master, replace
restore


/* -------------------------------------------------------------------------- */
					/* replacements file	*/

gen order = _n
foreach var of var integer real string {
	gen u1 = runiform()
	gen u2 = runiform()
	isid u1 u2
	sort u1 u2
	replace `var'correct = `var' in 1/`=floor(.3 * _N)'
	drop u1 u2
}
sort order
drop order

drop integer real string

gen i = _n
tostring *correct, replace format(%24.0g)
reshape long @correct, i(i) j(var) str
drop i
assert inlist(var, "integer", "real", "string")
lab var var			"Variable to replace"
lab var correct		"Correct value"

loc isid 1
preserve
while `isid' {
	restore, preserve

	sample 20, by(var)

	* *id3 are not unique IDs in gen_master.dta.
	* Check that they also are not in the replacements file.
	loc isid 0
	foreach var of var *id3 {
		cap isid `var'
		loc isid = `isid' | !_rc
	}
}
restore, not

order *id* var

sa gen_correct, replace
