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


/* -------------------------------------------------------------------------- */
					/* basic				*/

* Test 1
cd 1
insheet using correctedValues.csv, c n case clear
conf numeric var uniqueid CorrectValue
tostring uniqueid CorrectValue, replace
conf str var uniqueid CorrectValue
gen cmd = "replace " + Question + " = " + CorrectValue + ///
	" if uniqueid == " + uniqueid
tempfile do
outsheet cmd using `do', non noq
u firstEntry, clear
do `do'
tempfile expected_dta
sa `expected_dta'
#d ;
foreach cmd in
	"readreplace using correctedValues.csv, id(uniqueid)"
	"readreplace using correctedValues.csv, id(uniqueid) variable(Question) value(CorrectValue)"
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
insheet using correctedValues.csv, c n case clear
drop in 1/L
tempfile t
outsheet using `t', c
u firstEntry, clear
readreplace using `t', id(uniqueid)
assert !r(N)
assert "`r(varlist)'" == ""
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
`readreplace' var(Question) val(CorrectValue)
assert r(N) == 12
cd ..

* Test 4
cd 4
u firstEntry, clear
rcof "noi readreplace using too_few.csv,  id(uniqueid)" == 198
loc readreplace readreplace using too_many.csv, id(uniqueid)
rcof "noi `readreplace'" == 198
* Works under 2.0.0 syntax
`readreplace' var(Question) val(CorrectValue)
assert r(N) == 12
cd ..

* Test 6
cd 6
insheet using correctedValues.csv, c n case clear
assert Question == "district" in 1
u firstEntry, clear
readreplace using correctedValues.csv, ///
	id(uniqueid) var(Question) val(CorrectValue)
#d ;
foreach q in
	distric
	distric?
	distric*
	d~strict
	district-district
	DoesNotExist
	""
	"embedded space"
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
			id(uniqueid) var(Question) val(CorrectValue)"
			== 111;
		#d cr
		compdta firstEntry
	}
}
cd ..

* Test 7
cd 7
u firstEntry, clear
readreplace using correctedValues.csv, id(uniqueid)
assert uniqueid <= 1000
insheet using correctedValues.csv, c n case clear
assert uniqueid <= 1000
forv i = 1/2 {
	replace uniqueid = 1000 + `i' in `i'
	tempfile bad`i'
	outsheet using `bad`i'', c
}
u firstEntry, clear
forv i = 1/2 {
	rcof "noi readreplace using `bad`i'', id(uniqueid)" == 198
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
`rr' var(Question) val(CorrectValue)
assert !r(N)
rcof "noi `rr' var(Question)" == 198
rcof "noi `rr' val(CorrectValue)" == 198
cd ..

* Test 16
cd 16
u firstEntry, clear
loc opts id(uniqueid) var(Question) val(CorrectValue)
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
readreplace using correct.csv, id(uniqueid) var(Question) val(CorrectValue)
assert r(N) == 1
u firstEntry, clear
#d ;
rcof "noi readreplace using correct.csv,
	id(uniqueid) var(Question) val(Question)"
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
readreplace using correct.csv, id(uniqueid) var(Question) val(CorrectValue)
assert r(N) == 1
restore
#d ;
rcof "noi readreplace using correct.csv,
	id(uniqueid) var(uniqueid) val(CorrectValue)"
	== 198;
rcof "noi readreplace using correct.csv,
	id(uniqueid) var(Question) val(uniqueid)"
	== 198;
#d cr
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
