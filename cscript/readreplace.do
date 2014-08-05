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
preserve
do `do'
tempfile expected_dta
sa `expected_dta'
restore
readreplace using correctedValues.csv, id(uniqueid)
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
mata: assert(st_matrix("changes") == (2, 3, 1, 1, 0, 1, 2, 0, 1, 0, 0, 0, 1))
mata: assert(sum(st_matrix("changes")) == `r(N)')
compdta `expected_dta'
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
rcof "noi readreplace using correctedValues.csv, id(uniqueid)" == 198
cd ..

* Test 4
cd 4
u firstEntry, clear
rcof "noi readreplace using too_few.csv,  id(uniqueid)" == 198
rcof "noi readreplace using too_many.csv, id(uniqueid)" == 198
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
