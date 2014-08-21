* -readreplace- cscript

* -version- intentionally omitted for -cscript-.

* 1 to execute profile.do after completion; 0 not to.
local profile 1


/* -------------------------------------------------------------------------- */
					/* initialize			*/

* Check the parameters.
assert inlist(`profile', 0, 1)

* Set the working directory to the readreplace directory.
c readreplace
cd cscript

cap log close readreplace
log using readreplace, name(readreplace) s replace
di "`c(username)'"
di "`:environment computername'"

clear
if c(stata_version) >= 11 ///
	clear matrix
clear mata
set varabbrev off
set type float
vers 10.1: set seed 529948906
set more off

cd ..
adopath ++ `"`c(pwd)'"'
adopath ++ `"`c(pwd)'/cscript/ado"'
cd cscript

timer clear 1
timer on 1

* Preserve select globals.
loc FASTCDPATH : copy glo FASTCDPATH

cscript readreplace adofile readreplace

* Check that Mata issues no warning messages about the source code.
if c(stata_version) >= 13 {
	matawarn readreplace.ado
	assert !r(warn)
	cscript
}

* Restore globals.
glo FASTCDPATH : copy loc FASTCDPATH

cd tests

loc dirs : dir . dir *
foreach dir of loc dirs {
	* Delete generated datasets.
	loc dtas : dir "`dir'" file "gen*.dta"
	foreach dta of loc dtas {
		erase "`dir'/`dta'"
	}

	* Create generated datasets.
	cap conf f "`dir'/gen.do"
	if !_rc {
		cd "`dir'"
		do gen
		cd ..
	}
}

pr repl2do
	syntax using, id(varname num) VARiable(varname str) VALue(varname str)

	preserve

	assert `value' == strofreal(real(`value'), "%24.0g")

	qui tostring `id', replace
	tempvar cmd
	gen `cmd' = "replace " + `variable' + " = " + `value' + ///
		" if `id' == " + `id'
	assert strlen(`cmd') < c(maxstrvarlen)

	qui outsheet `cmd' `using', non noq
end


/* -------------------------------------------------------------------------- */
					/* basic				*/

* Test 1
cd 1
insheet using correctedValues.csv, c n case clear
tostring CorrectValue, replace
tempfile do
repl2do using `do', id(uniqueid) var(Question) val(CorrectValue)
u firstEntry, clear
do `do'
tempfile expected_dta
sa `expected_dta'
#d ;
foreach cmd in
	"readreplace using correctedValues.csv, id(uniqueid)"
	"readreplace using correctedValues.csv, id(uniqueid) variable(question) value(correctvalue)"
{;
	#d cr
	u firstEntry, clear
	`cmd'
	assert r(N) == 12
	loc varlist `r(varlist)'
	loc expected age am_failure district do_well feel_useless gender income ///
		little_pride no_good_at_all person_of_worth positive_attitude ///
		satisfied_w_self want_selfrespect
	assert `:list varlist == expected'
	mat changes = r(changes)
	assert "`:rownames changes'" == "changes"
	assert "`:rowfullnames changes'" == "changes"
	loc colnames : colnames changes
	assert `:list colnames == varlist'
	loc colnames : colfullnames changes
	assert `:list colnames == varlist'
	mata: assert(st_matrix("changes") == ///
		(2, 3, 1, 1, 0, 1, 2, 0, 1, 0, 0, 0, 1))
	mata: assert(sum(st_matrix("changes")) == `r(N)')
	compdta `expected_dta'
}
cd ..

* Test 5
cd 5
u firstEntry, clear
preserve
readreplace using correctedValues.csv, id(uniqueid)
tempfile temp
sa `temp'
restore
readreplace using correctedValues.csv, id(uniqueid) display
compdta `temp'
cd ..

* Test 8
cd 8
u firstEntry, clear
readreplace using correctedValues.csv, id(uniqueid)
assert r(N) == 12
assert "`r(varlist)'" != ""
conf mat r(changes)
insheet using correctedValues.csv, c n case clear
drop in 1/L
tempfile t
outsheet using `t', c
u firstEntry, clear
readreplace using `t', id(uniqueid)
assert !r(N)
assert "`r(varlist)'" == ""
cap conf mat r(changes)
assert _rc
compdta firstEntry
cd ..

* Test 9
cd 9
u firstEntry, clear
readreplace using correctedValues.csv, id(uniqueid)
assert r(N) == 12
assert "`r(varlist)'" != ""
u firstEntry, clear
tostring uniqueid, replace
conf str var uniqueid
tempfile idstr
sa `idstr'
rcof "noi readreplace using correctedValues.csv, id(uniqueid)" == 106
insheet using correctedValues.csv, c n case clear
drop in 1/L
tempfile t
outsheet using `t', c
insheet using `t', c n case clear
conf numeric var uniqueid
u `idstr', clear
readreplace using `t', id(uniqueid)
assert !r(N)
assert "`r(varlist)'" == ""
cd ..

* Test 10
cd 10
u firstEntry, clear
readreplace using correct_num.csv, id(uniqueid)
assert r(N) == 12
u firstEntry, clear
cou if uniqueid == 105
assert r(N)
assert firstname == "Marcos" if uniqueid == 105
readreplace using correct_str.csv, id(uniqueid)
assert r(N) == 2
assert firstname == "Lindsey" if uniqueid == 105
insheet using correct_str.csv, c n case clear
tempfile str
sa `str'
insheet using correct_num.csv, c n case clear
tostring CorrectValue, replace
assert c(k) == 3
append using `str'
assert c(k) == 3
tempfile all
outsheet using `all', c
u firstEntry, clear
readreplace using `all', id(uniqueid)
assert r(N) == 14
cd ..

* Test 12
cd 12
u firstEntry, clear
isid uniqueid
cou if inlist(uniqueid, 105, 999)
assert r(N) == 2
assert firstname == "Marcos" if uniqueid == 105
assert firstname == "London" if uniqueid == 999
readreplace using correctedValues.csv, id(uniqueid)
assert r(N) == 14
assert firstname == "." if uniqueid == 105
assert firstname == "2" if uniqueid == 999
tempname fh
file open `fh' using correctedValues.csv, r
file r `fh' line
file r `fh' line
assert `"`line'"' == "105,firstname,"
file close `fh'
cd ..

* Test 13
cd 13
insheet using correctedValues.csv, c n case clear
cou if Question == "gender" & CorrectValue != strtrim(CorrectValue)
assert r(N)
assert strtrim(CorrectValue) == strofreal(real(CorrectValue)) ///
	if Question == "gender"
u firstEntry, clear
isid uniqueid
cou if inlist(uniqueid, 1, 2, 3, 4, 5, 6)
assert r(N) == 6
assert inlist(gender, 1, 2) if inlist(uniqueid, 1, 2, 3, 4, 5, 6)
readreplace using correctedValues.csv, id(uniqueid)
assert r(N) == 7
assert gender == 0  if inlist(uniqueid, 1, 4)
assert gender == .  if inlist(uniqueid, 2, 5)
assert gender == .a if inlist(uniqueid, 3, 6)
cd ..

* Test 19
cd 19
u firstEntry, clear
readreplace using correctedValues.csv, ///
	id(uniqueid) var(question) val(correctvalue)
assert r(N) == 12
tempfile expected
sa `expected'
insheet using correctedValues.csv, c n case clear
tempfile dta
sa `dta'
#d ;
loc good
	insheet		correctedValues.csv		""
										uniqueid	question	correctvalue
	insheet		correctedValues.csv		clear
										uniqueid	question	correctvalue
	insheet		correctedValues.csv		comma
										uniqueid	question	correctvalue
	insheet		correctedValues.csv		names
										uniqueid	question	correctvalue
	insheet		correctedValues.csv		case
										uniqueid	Question	CorrectValue
	insheet		correctedValues.csv		"case clear"
										uniqueid	Question	CorrectValue
	insheet		correctedValues.csv		"comma names case"
										uniqueid	Question	CorrectValue
	""			correctedValues.csv		""
										uniqueid	""			""
	use			`dta'					""
										uniqueid	Question	CorrectValue
	use			`dta'					clear
										uniqueid	Question	CorrectValue
	use			`dta'					nolabel
										uniqueid	Question	CorrectValue
	use			`dta'					"nolabel clear"
										uniqueid	Question	CorrectValue
;
loc bad
	insheet		correctedValues.csv		"clear clear"
										uniqueid	question	correctvalue
										198
	insheet		correctedValues.csv		not_an_option
										uniqueid	question	correctvalue
										198
	insheet		correctedValues.csv		nonames
										uniqueid	question	correctvalue
										111
	insheet		correctedValues.csv		tab
										uniqueid	question	correctvalue
										111
	insheet		correctedValues.csv		`"delimiter("\`=char(59)'")"'
										uniqueid	question	correctvalue
										111
	insheet		`dta'					case
										uniqueid	Question	CorrectValue
										111
	use			`dta'					""
										uniqueid	""			""
										198
	use			`dta'					"clear clear"
										uniqueid	Question	CorrectValue
										198
	use			`dta'					not_an_option
										uniqueid	Question	CorrectValue
										198
	use			correctedValues.csv		""
										uniqueid	Question	CorrectValue
										610
;
#d cr
if c(stata_version) < 12 {
	#d ;
	loc bad `bad'

	excel		correctedValues.csv		firstrow
										uniqueid	Question	CorrectValue
										199
	excel		correctedValues.csv		""
										uniqueid	""			""
										198
	;
	#d cr
}
else {
	tempfile first_var letters
	export excel using `first_var', first(var)
	export excel using `letters'
	#d ;
	loc good `good'

	excel		`first_var'				firstrow
										uniqueid	Question	CorrectValue
	excel		`first_var'				"firstrow clear"
										uniqueid	Question	CorrectValue
	excel		`first_var'				"firstrow case(lower)"
										uniqueid	question	correctvalue
	excel		`letters'				""
										A			B			C
	;
	loc bad `bad'

	excel		`first_var'				""
										uniqueid	""			""
										198
	excel		`first_var'				firstrow
										uniqueid	""			""
										198
	excel		`first_var'				"firstrow clear clear"
										uniqueid	Question	CorrectValue
										198
	excel		`first_var'				"firstrow not_an_option"
										uniqueid	Question	CorrectValue
										198
	excel		`first_var'				"firstrow allstring"
										uniqueid	Question	CorrectValue
										106
	excel		correctedValues.csv		firstrow
										uniqueid	Question	CorrectValue
										603
	;
	#d cr
}
foreach list in good bad {
	while `:list sizeof `list'' {
		gettoken cmd		`list' : `list'
		gettoken fn			`list' : `list'
		gettoken import		`list' : `list'
		gettoken id			`list' : `list'
		gettoken var		`list' : `list'
		gettoken val		`list' : `list'
		if "`list'" == "bad" {
			gettoken rc		`list' : `list'
			conf n `rc'
		}

		loc cmds "`cmd'"
		if inlist("`cmd'", "insheet", "") ///
			loc cmds "`cmds' """
		foreach cmd_opt of loc cmds {
			u firstEntry, clear

			foreach opt in id var val import {
				if "``opt''" == "" ///
					loc `opt'_opt
				else ///
					loc `opt'_opt `opt'(``opt'')
			}
			loc command readreplace using `fn', ///
				`id_opt' `var_opt' `val_opt' `cmd_opt' `import_opt'
			di as res _n `"{p 0 4 2}`command'{p_end}"'

			if "`list'" == "good" {
				if "`id'" != "uniqueid" ///
					ren uniqueid `id'
				`command'
				assert r(N) == 12
				if "`id'" != "uniqueid" ///
					ren `id' uniqueid
				compdta `expected'

			}
			else if "`list'" == "bad" {
				rcof `"noi `command'"' == `rc'
			}
			else {
				err 9
			}
		}
	}
}
rcof "noi readreplace using correctedValues.csv, id(uniqueid) insheet" == 198
cd ..

* Test 22
cd 22
* Basic tests of these more complicated datasets
* Numeric variables
u gen_correct, clear
drop if var == "string"
tempfile nostr
sa `nostr'
tempfile do
repl2do using `do', id(numid1) var(var) val(correct)
u gen_master, clear
do `do'
* Destroy the sortlist.
d, varl
assert "`r(sortlist)'" != ""
gen order = _n
sort order
drop order
d, varl
assert "`r(sortlist)'" == ""
tempfile expected
sa `expected'
u gen_master, clear
readreplace using `nostr', id(numid1) var(var) val(correct) u
compdta `expected'
* String variables
u gen_correct, clear
keep if var == "string"
tempfile stronly
sa `stronly'
u gen_master, clear
gen order = _n
assert "`:char _dta[]'" == ""
merge numid1 using `stronly', sort keep(correct)
loc chars : char _dta[]
foreach char of loc chars {
	char _dta[`char']
}
assert _merge != 2
replace string = correct if _merge == 3
drop correct _merge
sort order
drop order
tempfile expected
sa `expected'
u gen_master, clear
readreplace using `stronly', id(numid1) var(var) val(correct) u
compdta `expected'
* Perfect IDs
if c(stata_version) >= 13 {
	foreach dta in gen_master gen_correct {
		u "`dta'", clear
		gen stridL = strid1 + c(maxstrvarlen) * "x"
		assert "`:type stridL'" == "strL"
		sa, replace
	}
	loc stridL stridL
}
u gen_master, clear
readreplace using gen_correct, id(numid1) var(var) val(correct) u
loc N_perfect = r(N)
tempfile expected
sa `expected'
foreach id in numid2_* strid1 strid2_* mixid* `stridL' {
	u gen_master, clear
	readreplace using gen_correct, id(`id') var(var) val(correct) u
	assert r(N) == `N_perfect'
	compdta `expected'
}
* Imperfect IDs
u gen_master, clear
readreplace using gen_correct, id(numid3) variable(var) value(correct) u
loc N_imperfect = r(N)
assert reldif(`N_perfect', `N_imperfect') < .01
tempfile expected
sa `expected'
u gen_master, clear
readreplace using gen_correct, id(strid3) variable(var) value(correct) u
assert r(N) == `N_imperfect'
compdta `expected'
cd ..

* Test 25
cd 25
u firstEntry, clear
drop in 1/L
tempfile noobs
sa `noobs'
#d ;
rcof "noi readreplace using correctedValues.csv,
	id(uniqueid) var(question) val(correctvalue)"
	== 198;
#d cr
insheet using correctedValues.csv, c n clear
drop in 1/L
tempfile correct_noobs
outsheet using `correct_noobs', c
u `noobs', clear
readreplace using `correct_noobs', id(uniqueid) var(question) val(correctvalue)
assert !r(N)
assert "`r(varlist)'" == ""
cap conf mat r(changes)
assert _rc
compdta `noobs'
cd ..

* Test 26
cd 26
#d ;
loc replace
	// variable		new value	new type
	// zero_byte
	zero_byte		1				byte
	zero_byte		0.1				c(type)
		// c(type) even though double can store the value precisely and
		// float cannot: assert 2147483620.1 != float(2147483620.1)
	zero_byte		2147483620.1	c(type)
	zero_byte		32741			long
	zero_byte		2147483621		double
	zero_byte		-127			byte
	zero_byte		-128			int
	zero_byte		100				byte
	zero_byte		101				int
	// zero_int
		// No compress
	zero_int		1				int
	zero_int		0.1				c(type)
	zero_int		2147483620.1	c(type)
	zero_int		32741			long
	zero_int		2147483621		double
	zero_int		-32767			int
	zero_int		-32768			long
	zero_int		32740			int
	zero_int		32741			long
	// zero_long
	zero_long		1				long
	zero_long		0.1				c(type)
	zero_long		2147483620.1	c(type)
	zero_long		32741			long
	zero_long		-2147483647		long
	zero_long		-2147483648		double
	zero_long		2147483620		long
	zero_long		2147483621		double
	// zero_float
	zero_float		1				float
	zero_float		0.1				float
	zero_float		2147483620.1	float
	zero_float		32741			float
	zero_float		-9999999		float
	zero_float		-10000000		float
	zero_float		-9999999.1		float
	zero_float		9999999			float
	zero_float		10000000		float
	zero_float		9999999.1		float
	// zero_double
	zero_double		1				double
	zero_double		0.1				double
	zero_double		2147483620.1	double
	zero_double		32741			double
;
#d cr
loc c_type `c(type)'
tempfile t
while `:list sizeof replace' {
	gettoken var  replace : replace
	gettoken val  replace : replace
	gettoken type replace : replace
	mac li _var _val _type

	clear
	set obs 1
	gen id  = 1
	gen var = "`var'"
	gen val = "`val'"
	sa `t', replace

	if "`type'" == "c(type)" {
		loc types float double
		loc set_type 1
	}
	else {
		loc types `type'
		loc set_type 0
	}
	foreach vartype of loc types {
		if `set_type' ///
			set type `vartype'

		u gen_master, clear
		assert _N == 1
		readreplace using `t', id(id) var(var) val(val) u
		assert r(N) == 1
		assert "`r(varlist)'" == "`var'"
		assert "`:type `var''" == "`vartype'"
		gen `vartype' val = `val'
		assert `var' == val
	}
	if `set_type' ///
		set type `c_type'
}
cd ..

* Test 27
cd 27
mata: st_local("xmax", c("maxstrvarlen") * "x")
#d ;
loc replace
	// variable		new value	new type
	str_2			""			str2
	str_2			x			str2
	str_2			yy			str2
	str_2			xxx			str3
	str_2			`xmax'		str`c(maxstrvarlen)'
;
#d cr
if c(stata_version) >= 13 {
	mata: st_local("maxmore", st_local("xmax") + "x")
	#d ;
	loc replace
	// variable		new value	new type
	`replace'
	str_2			\0			strL
	str_2			x\0			strL
	str_2			`maxmore'	strL
	str_L			""			strL
	str_L			x			strL
	str_L			\0			strL
	str_L			`xmax'		strL
	str_L			`maxmore'	strL
	;
	#d cr
}
tempfile t
while `:list sizeof replace' {
	gettoken var  replace : replace
	gettoken val  replace : replace
	gettoken type replace : replace
	mac li _var _type
	cap noi mac li _val

	mata: st_strscalar("val0", subinstr(st_local("val"), "\0", char(0), .))

	clear
	set obs 1
	gen id  = 1
	gen var = "`var'"
	gen val = val0
	d
	mata: st_sdata(., "val")
	sa `t', replace

	u gen_master, clear
	assert _N == 1
	readreplace using `t', id(id) var(var) val(val) u
	assert r(N) == 1
	assert "`r(varlist)'" == "`var'"
	assert "`:type `var''" == "`type'"
	assert `var' == val0
}
cd ..

* Test 28
loc curdir "`c(pwd)'"
cd ../../help/example/2.0.0
* Make the changes specified in correctedValues.csv
use firstEntry, clear
readreplace using correctedValues.csv, id(uniqueid) variable(question) value(correctvalue)
* Same as the previous -readreplace- command,
* but specifies option -case- to -insheet- to import the replacements file
use firstEntry, clear
readreplace using correctedValues.csv, id(uniqueid) variable(Question) value(CorrectValue) import(case)
* Same as the previous -readreplace- command,
* but loads the replacements file as a Stata dataset
use firstEntry, clear
readreplace using correctedValues.dta, id(uniqueid) variable(Question) value(CorrectValue) use
cd "`curdir'"


/* -------------------------------------------------------------------------- */
					/* user mistakes		*/

* Test 2
cd 2
u firstEntry, clear
rcof "noi readreplace using correct.csv, id(uniqueid)" == 601
rcof "noi readreplace using correctedValues.csv, id(uniqueid)" == 198
cd ..

* Test 3
cd 3
u firstEntry, clear
loc readreplace readreplace using correctedValues.csv, id(uniqueid)
rcof "noi `readreplace'" == 198
* Works under 2.0.0 syntax
`readreplace' var(question) val(correctvalue)
assert r(N) == 12
cd ..

* Test 4
cd 4
u firstEntry, clear
rcof "noi readreplace using too_few.csv,  id(uniqueid)" == 198
loc readreplace readreplace using too_many.csv, id(uniqueid)
rcof "noi `readreplace'" == 198
* Works under 2.0.0 syntax
`readreplace' var(question) val(correctvalue)
assert r(N) == 12
cd ..

* Test 6
cd 6
insheet using correctedValues.csv, c n case clear
assert Question == "district" in 1
u firstEntry, clear
readreplace using correctedValues.csv, ///
	id(uniqueid) var(question) val(correctvalue)
#d ;
foreach q in
	distric
	distric?
	distric*
	d~strict
	district-district
	"district gender"
	_all
	DoesNotExist
	""
{;
	#d cr
	qui insheet using correctedValues.csv, c n case clear
	qui replace Question = `"`q'"' in 1
	tempfile t
	outsheet using `t', c

	u firstEntry, clear
	foreach varabbrev in "" varabbrev {
		#d ;
		rcof "noi `varabbrev' readreplace using `t',
			id(uniqueid) var(question) val(correctvalue)"
			== 111;
		#d cr
		compdta firstEntry
	}
}
cd ..

* Test 7
cd 7
u firstEntry, clear
isid uniqueid
gen id2_1 = cond(_n <= _N / 2, 1, 2)
gen order = _n
bys id2_1: gen id2_2 = _n
sort order
drop order
assert uniqueid <= 1000
assert id2_2    <= 1000
tempfile first
sa `first'
insheet using correctedValues.csv, c n case clear
assert uniqueid <= 1000
gen order = _n
merge uniqueid using `first', sort uniqus keep(id2_*)
drop if _merge == 2
assert _merge == 3
drop _merge
sort order
drop order
tempfile good
outsheet using `good', c
forv i = 1/2 {
	foreach var of var uniqueid id2_2 {
		replace `var' = 1000 + `i' in `i'
	}
	tempfile bad`i'
	outsheet using `bad`i'', c
}
u `first', clear
readreplace using `good', id(uniqueid) var(question) val(correctvalue)
tempfile expected
sa `expected'
u `first', clear
readreplace using `good', id(id2_*) var(question) val(correctvalue)
compdta `expected'
u `first', clear
foreach id in uniqueid id2_* {
	forv i = 1/2 {
		#d ;
		rcof "noi readreplace using `bad`i'',
			id(`id') var(question) val(correctvalue)"
			== 198;
		#d cr
	}
}
cd ..

* Test 11
cd 11
u firstEntry, clear
rcof "noi readreplace using correct_str.csv, id(uniqueid)" == 111
cd ..

* Test 14
cd 14
u firstEntry, clear
rcof "noi readreplace using correct_string.csv, id(uniqueid)" == 109
rcof "noi readreplace using correct_blank.csv,  id(uniqueid)" == 109
cd ..

* Test 15
cd 15
u firstEntry, clear
loc rr readreplace using correctedValues.csv, id(uniqueid)
`rr'
assert r(N) == 12
`rr' var(question) val(correctvalue)
assert !r(N)
rcof "noi `rr' var(question)" == 198
rcof "noi `rr' val(correctvalue)" == 198
cd ..

* Test 16
cd 16
u firstEntry, clear
loc opts id(uniqueid) var(question) val(correctvalue)
rcof "noi readreplace using no_id.csv,  `opts'" == 111
rcof "noi readreplace using no_var.csv, `opts'" == 111
rcof "noi readreplace using no_val.csv, `opts'" == 111
cd ..

* Test 17
cd 17
insheet using correct.csv, c n case clear
assert _N == 1
assert Question == CorrectValue
u firstEntry, clear
readreplace using correct.csv, id(uniqueid) var(question) val(correctvalue)
assert r(N) == 1
u firstEntry, clear
#d ;
rcof "noi readreplace using correct.csv,
	id(uniqueid) var(question) val(question)"
	== 198;
#d cr
cd ..

* Test 18
cd 18
u firstEntry, clear
tostring uniqueid, replace
conf str var uniqueid
replace uniqueid = "firstname" if uniqueid == "1"
cou if uniqueid == "firstname"
assert r(N)
preserve
readreplace using correct.csv, ///
	id(uniqueid) var(question) val(correctvalue) import(n)
assert r(N) == 1
restore
#d ;
rcof "noi readreplace using correct.csv,
	id(uniqueid) var(uniqueid) val(correctvalue) import(n)"
	== 198;
rcof "noi readreplace using correct.csv,
	id(uniqueid) var(question) val(uniqueid) import(n)"
	== 198;
#d cr
cd ..

* Test 20
cd 20
u firstEntry, clear
readreplace using correctedValues.csv, ///
	id(uniqueid) var(question) val(correctvalue) insheet
loc opts insheet use excel
while `:list sizeof opts' {
	gettoken opt1 opts : opts
	foreach opt2 of loc opts {
		#d ;
		rcof "noi readreplace using correctedValues.csv,
			id(uniqueid) var(question) val(correctvalue) `opt1' `opt2'"
			== 198;
		#d cr
	}
}
cd ..

* Test 21
cd 21
u firstEntry, clear
foreach id in uniqueid unique* {
	foreach varabbrev in "" varabbrev {
		#d ;
		rcof "noi `varabbrev' readreplace using correctedValues.csv,
			id(`id') var(question) val(correctvalue)"
			== 111;
		#d cr
	}
}
cd ..

* Test 23
cd 23
u firstEntry, clear
#d ;
rcof "noi readreplace using correctedValues.csv,
	id(uniqueid) var(question) val(correctvalue)"
	== 198;
#d cr
cd ..

* Test 24
cd 22
u gen_correct, clear
drop if var == "string"
tempfile nostr_dta nostr_numid1 nostr_numid2
sa `nostr_dta'
order *id* var correct
outsheet numid1  var correct using `nostr_numid1', c
outsheet numid2* var correct using `nostr_numid2', c
u gen_master, clear
readreplace using `nostr_dta', id(numid2*) var(var) val(correct) u
tempfile expected
sa `expected'
u gen_master, clear
readreplace using `nostr_numid1', id(numid1)
compdta `expected'
u gen_master, clear
rcof "noi readreplace using `nostr_numid2', id(numid2*)" == 103
cd ..


/* -------------------------------------------------------------------------- */
					/* finish up			*/

cd ..

timer off 1
timer list 1

if `profile' {
	cap conf f C:\ado\profile.do
	if !_rc ///
		run C:\ado\profile
}

timer list 1

log close readreplace
