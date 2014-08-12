*! v1 by Ryan Knight 12jan2011
pr readreplace, rclass
	vers 10.1

	syntax using, id(varname) [DIsplay *]

	* "m" suffix for "master"
	unab vars_m : _all

	qui ds, has(t numeric)
	loc numvars `r(varlist)'
	foreach var of loc id {
		loc idtypes `idtypes' `:type `var''
	}

	preserve

	keep `id'
	if _N ///
		qui duplicates drop
	tempfile idvals
	qui sa `idvals'

	import_replacements `using', id(`id') `options'
	loc variable	`r(variable)'
	loc value		`r(value)'

	* "r" suffix for "replacements file"
	qui levelsof `variable', loc(vars_r) miss
	loc rnotm : list vars_r - vars_m
	if `:list sizeof rnotm' {
		gettoken first : rnotm
		if !`:length loc first' ///
			loc first """"
		else {
			loc first "`"`first'"'"
			loc first : list clean first
		}
		di as err "{p}"
		di as err "option variable(): a value of variable `variable',"
		di as err `"`first', is not a variable in memory"'
		di as err "{p_end}"
		ex 111
	}
	loc overlap : list vars_r & id
	if "`overlap'" != "" {
		di as err "{p}"
		di as err "option variable(): variable `variable' cannot contain"
		di as err "a variable name specified to option id()"
		di as err "{p_end}"
		ex 198
	}

	if _N {
		* Check storage types. If _N == 0, some types may not be correct:
		* for instance, if the file is -insheet-ed, all types will be byte.
		* However, as no replacements will be made, this is not a problem.

		* -id()-
		foreach var of loc id {
			cap conf numeric var `var'
			if !_rc != `:list var in numvars' {
				loc typem : word `:list posof "`var'" in id' of `idtypes'
				loc typeu : type `var'
				di as err "{p}"
				di as err "option id(): variable `var' is"
				di as err "`typem' in dataset in memory but"
				di as err "`typeu' in replacements file"
				di as err "{p_end}"
				ex 106
			}
		}

		* It is not necessary to check the storage type of
		* the variable name variable: the check above of
		* the variable's values is sufficient.

		* `value'
		* "replvars" for "replacement variables"
		qui levelsof `variable', loc(replvars)
		cap conf str var `value'
		if _rc {
			loc tostring tostring `value', replace format(%24.0g)
			loc replvars_str : list replvars - numvars
			if `:list sizeof replvars_str' {
				di as txt "{p}"
				di "note: variable {res:`value'} of the replacements file is"
				di "numeric, but variable {res:`variable'} contains"
				di "string variables. {res:`value'} will be converted to"
				di "string:"
				di "{p_end}"
				di _n "{cmd:`tostring'}" _n
			}
			qui `tostring'
			conf str var `value'
		}
		else {
			* Check the new values for numeric variables.
			tempvar trimval
			qui gen `trimval' = strtrim(`value')
			loc replvars_num : list replvars & numvars
			foreach var of loc replvars_num {
				qui cou if `variable' == "`var'" & (`trimval' == "." | ///
					strlen(`trimval') == 2 & inrange(`trimval', ".a", ".z"))
				loc miss_str = r(N)
				qui cou if `variable' == "`var'" & mi(real(`trimval'))
				loc miss_num = r(N)
				if `miss_str' != `miss_num' {
					di as err "option value(): cannot replace " ///
						"numeric variable `var' with string value"
					ex 109
				}
			}
		}

		* ID values in the replacements file but not the dataset in memory
		tempvar order merge
		gen `order' = _n
		qui merge `id' using `idvals', sort uniqus _merge(`merge')
		qui drop if `merge' == 2
		qui cou if `merge' == 1
		if r(N) {
			loc values = plural(r(N), "value")
			loc variables = plural(`:list sizeof id', "variable")
			di as err "{p}"
			di as err "option id(): `values' of `variables' `id' in"
			di as err "replacements file not found in dataset in memory"
			di as err "{p_end}"
			loc max 1
			foreach var of loc id {
				loc max = max(`max', strlen("`var'"))
			}
			li `id' if `merge' == 1, ab(`max') noo
			ex 198
		}
		sort `order'
	}

	if "`display'" != "" {
		di as txt "note: option {opt display} is deprecated " ///
			"and will be ignored."
	}

	keep `id' `variable' `value'
	sort `variable', stable
	mata: readreplace("id", "variable", "value", "varlist", "N", "changes")
	* Return stored results.
	ret sca N = `N'
	ret loc varlist `varlist'
	if `return(N)' ///
		ret mat changes = `changes'

	di as txt _n "Total changes made: " as res `return(N)'

	restore, not
end


/* -------------------------------------------------------------------------- */
					/* import				*/

pr import_replacements, rclass
	syntax using, id(varname) [VARiable(str) VALue(str) ///
		Use insheet EXCel import(str asis)]

	* Version 1 syntax
	if "`variable'`value'" == "" {
		di as txt "note: you are using old {cmd:readreplace} syntax; " ///
			"see {helpb readreplace} for new syntax."

		syntax using, id(varname)

		loc insheet insheet
		loc import comma names case
	}
	* Version 2.0.0
	else {
		* Check -variable()- and -value()-.
		if "`variable'" != "" & "`value'" == "" {
			loc 0
			syntax, value(varname)
			/*NOTREACHED*/
		}
		if "`variable'" == "" & "`value'" != "" {
			loc 0
			syntax, variable(varname)
			/*NOTREACHED*/
		}

		if "`use'`insheet'`excel'" == "" ///
			loc insheet insheet

		* Check -use-, -insheet-, and -excel-.
		if ("`use'" != "") + ("`insheet'" != "") + ("`excel'" != "") != 1 {
			di as err "options use, insheet, and excel are mutually exclusive"
			ex 198
		}
	}

	* Import the replacements file.
	loc importexcel = cond("`excel'" != "", "import excel", "")
	loc clear clear
	loc import : list import - clear
	loc cmd `use'`insheet'`importexcel' `using', clear `import'
	cap `cmd'
	if _rc {
		loc rc = _rc
		* Display the error message.
		cap noi `cmd'
		di as err "(error in option {bf:`use'`insheet'`excel'})"
		ex `rc'
	}

	* Checks based on -readreplace- syntax version
	* Version 1
	if "`variable'`value'" == "" {
		unab rest : _all
		gettoken first		rest : rest
		gettoken variable	rest : rest
		gettoken value : rest

		if "`first'" != "`id'" | c(k) != 3 {
			di as err "Error: Using file has improper format"
			di as err "The using file must have the format: " ///
				as res "`id',varname,correct_value"
			ex 198
		}
	}
	* Version 2.0.0
	else {
		* Check -id()-.
		* Contrary to the option's name, the variable list specified to
		* -id()- need not uniquely identify observations,
		* in either the dataset in memory or the replacements file.
		foreach var of loc id {
			cap conf var `var', exact
			if _rc {
				di as err "variable `var' not found in replacements file" _n ///
					"(error in option {bf:id()})"
				ex 111
			}
		}

		* Check -variable()- and -value()-.

		loc 0 , variable(`variable')
		syntax, variable(varname)
		loc 0 , value(`value')
		syntax, value(varname)

		if "`variable'" == "`value'" {
			di as err "variable `variable' cannot be specified to " ///
				"both options variable() and value()"
			ex 198
		}

		* Check -id()-, -variable()-, and -value()-.
		foreach opt in variable value {
			if `:list `opt' in id' {
				di as err "variable ``opt'' cannot be specified to " ///
					"both options id() and `opt'()"
				ex 198
			}
		}
	}

	ret loc variable	`variable'
	ret loc value		`value'
end

					/* import				*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* type definitions, etc.	*/

* Convert real x to string using -strofreal(x, `RealFormat')-.
loc RealFormat	""%24.0g""

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

loc boolean		`RS'
loc True		1
loc False		0

* A local macro name
loc lclname		`SS'

mata:

					/* type definitions, etc.	*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* interface with Stata		*/

// Returns `True' if any of vars are strL and `False' if not.
`boolean' st_anystrL(`TR' vars)
{
	`RS' n, i
	`boolean' any

	any = `False'
	i = 0
	n = length(vars)
	while (++i <= n & !any)
		any = st_vartype(vars[i]) == "strL"

	return(any)
}

// With parallel syntax to -st_sview()-, for observations i and variables j,
// if any of j are strL, makes V a copy of the specified dataset subset;
// if none are, makes V a view.
void st_sviewL(`TM' V, `RM' i, `TR' j)
{
	if (st_anystrL(j))
		V = st_sdata(i, j)
	else {
		pragma unset V
		st_sview(V, i, j)
	}
}

// Returns a duplicate of view V.
`TM' st_copy_view(`TM' V)
{
	`TM' cp

	pragma unset cp
	st_subview(cp, V, ., .)
	assert(isview(cp) == isview(V))
	assert((&cp) != (&V))

	return(cp)
}

// Returns the list of numeric types that can store the values of X.
// The list is ordered by decreasing precision (for noninteger X) and
// increasing size, meaning that the first element is often the optimal type.
`SR' numeric_types(`RM' X)
{
	`RS' min, max, n
	`SR' types

	n = length(X)
	if (!all(X :== floor(X)) & n)
		types = "double", "float"
	else {
		min = min(X)
		max = max(X)

		pragma unset types
		if (min >= -127 & max <= 100 | !n)
			types = types, "byte"
		if (min >= -32767 & max <= 32740 | !n)
			types = types, "int"
		if (min >= -9999999 & max <= 9999999 | !n)
			types = types, "float"
		if (min >= -2147483647 & max <= 2147483620 | !n)
			types = types, "long"
		types = types, "double"
	}

	return(types)
}

// Promotes the storage type of variable var so that
// it can store the values of X.
void st_promote_type(`SS' var, `TM' X)
{
	`RS' maxlen
	`SS' type_old, type_new, strpound
	`SR' numtypes

	type_new = type_old = st_vartype(var)
	if (st_isnumvar(var)) {
		// Never recast floats to doubles.
		numtypes = numeric_types(X)
		if (!anyof(numtypes, type_old))
			type_new = numtypes[1]
	}
	else {
		if (type_old != "strL") {
			maxlen = max(strlen(X))
			if (maxlen == .)
				maxlen = 0
			if (strtoreal(subinstr(type_old, "str", "", 1)) < maxlen) {
				strpound = sprintf("str%f",
					min((max((maxlen, 1)), c("maxstrvarlen"))))
				if (c("stata_version") < 13)
					type_new = strpound
				else
					type_new = maxlen <= c("maxstrvarlen") ? strpound : "strL"
			}
		}
	}

	if (type_new != type_old) {
		printf("{txt}%s was {res:%s} now {res:%s}\n", var, type_old, type_new)
		stata(sprintf("recast %s %s", type_new, var))
	}
}

`SR' st_sortlist()
{
	stata("qui d, varl")
	return(tokens(st_global("r(sortlist)")))
}

					/* interface with Stata		*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* make replacements	*/

/* For two lists of colvectors, -pcomp()- compares the idx1-th element of
the colvectors of list1 to the idx2-th element of the colvectors of list2.
-pcomp()- compares first the idx1-th element of the first colvector of list1 to
the idx2-th element of the first colvector of list2, then the idx1-th element of
the second colvector of list1 to the idx2-th element of the second colvector of
list2, and so on, until one of the pairs are unequal or
all the colvectors have been compared. If a list1 value is less than
the corresponding list2 value, -pcomp()- returns -1; if it is greater than the
corresponding value, it returns 1; and if all pairs are equal, it returns 0. */
`RS' pcomp(
	pointer(`TC') rowvector list1, `RS' idx1,
	pointer(`TC') rowvector list2, `RS' idx2)
{
	`RS' n, i
	`TS' val1, val2

	n = length(list1)
	for (i = 1; i <= n; i++) {
		val1 = (*list1[i])[idx1]
		val2 = (*list2[i])[idx2]
		if (val1 < val2)
			return(-1)
		if (val1 > val2)
			return(1)
	}

	return(0)
}

// -binary_search_first()- searches a sorted list of colvectors, tosearch, for
// the idx-th element of the colvectors of another list, target. It returns
// the index of the first element of the colvectors of tosearch that
// equals the element of target.
`RM' binary_search_first(pointer(`TC') rowvector tosearch,
	pointer(`TC') rowvector target, `RS' idx)
{
	`RS' lo, hi, mid, comp
	`RM' first

	lo = 1
	hi = length(*tosearch[1])
	while (lo <= hi) {
		mid = floor((lo + hi) / 2)
		comp = pcomp(target, idx, tosearch, mid)
		if (comp < 0)
			hi = mid - 1
		else if (comp == 0) {
			first = mid
			hi = mid - 1
		}
		else
			lo = mid + 1
	}

	return(first)
}

// -binary_search_last()- searches a sorted list of colvectors, tosearch, for
// the idx-th element of the colvectors of another list, target. It returns
// the index of the last element of the colvectors of tosearch that
// equals the element of target.
`RM' binary_search_last(pointer(`TC') rowvector tosearch,
	pointer(`TC') rowvector target, `RS' idx)
{
	`RS' lo, hi, mid, comp
	`RM' last

	lo = 1
	hi = length(*tosearch[1])
	while (lo <= hi) {
		mid = floor((lo + hi) / 2)
		comp = pcomp(target, idx, tosearch, mid)
		if (comp > 0)
			lo = mid + 1
		else if (comp == 0) {
			last = mid
			lo = mid + 1
		}
		else
			hi = mid - 1
	}

	return(last)
}

void readreplace(
	/* variable names */
	`lclname' _id, `lclname' _variable, `lclname' _value,
	/* output */
	`lclname' _varlist, `lclname' _changes_N, `lclname' _changes_mat)
{
	// "repl" for "replacement"
	`RS' id_k, repl_N, repl_k, first, last, i, j
	`RR' changes
	`RC' value_num, obsnum, touseobs
	`SS' order, prev, changes_name
	`SR' sortlist, id_names, repl_names
	`SC' variable, value
	`TS' val
	`TC' id_view, repl_view
	`boolean' isnum, isstrL
	// "r" suffix for "replacements file"; "m" suffix for "master."
	pointer(`TC') rowvector id_r, id_m

	// Save the replacements file.

	// Check that the dataset is sorted by the variable name variable.
	sortlist = st_sortlist()
	assert(length(sortlist))
	assert(sortlist[1] == st_local(_variable))

	// ID variables
	id_names = tokens(st_local(_id))
	id_k = length(id_names)
	assert(id_k)
	id_r = J(1, id_k, NULL)
	for (i = 1; i <= id_k; i++) {
		if (st_isnumvar(id_names[i]))
			id_r[i] = &st_data( ., id_names[i])
		else
			id_r[i] = &st_sdata(., id_names[i])
	}

	// Variable name and new value variables
	variable = st_sdata(., st_local(_variable))
	value    = st_sdata(., st_local(_value))
	value_num = strtoreal(value)

	repl_N = st_nobs()

	stata("restore, preserve")

	if (!repl_N) {
		st_local(_varlist, "")
		st_local(_changes_N, "0")
		st_local(_changes_mat, "")
		return
	}

	// Create views onto the ID variables of the master dataset.
	id_m = J(1, id_k, NULL)
	order = st_tempname()
	stata(sprintf("gen double %s = _n", order))
	stata("sort " + invtokens(id_names))
	for (i = 1; i <= id_k; i++) {
		pragma unset id_view
		if (st_isnumvar(id_names[i]))
			st_view(  id_view, ., id_names[i])
		else
			st_sviewL(id_view, ., id_names[i])
		// Copy id_view to a new address. While &id_view is constant in
		// each iteration, &st_copy_view(id_view) will differ.
		id_m[i] = &st_copy_view(id_view)
	}

	// Promote variable types.
	repl_names = uniqrows(variable)'
	repl_k = length(repl_names)
	for (i = 1; i <= repl_k; i++) {
		st_promote_type(repl_names[i],
			select((st_isnumvar(repl_names[i]) ? value_num : value),
			variable :== repl_names[i]))
	}

	// Make the replacements.
	changes = J(1, repl_k, 0)
	prev = ""
	j = 0
	obsnum = 1::st_nobs()
	for (i = 1; i <= repl_N; i++) {
		// Change in variable name
		if (variable[i] != prev) {
			prev = variable[i]
			j++
			pragma unset repl_view
			if (isnum = st_isnumvar(variable[i]))
				st_view(  repl_view, ., variable[i])
			else
				st_sviewL(repl_view, ., variable[i])
			isstrL = st_vartype(variable[i]) == "strL"
		}

		// Select observations by ID.
		first = binary_search_first(id_m, id_r, i)
		last  = binary_search_last( id_m, id_r, i)
		touseobs = select(obsnum, obsnum :>= first :& obsnum :<= last)

		// Changes
		val = isnum ? value_num[i] : value[i]
		changes[j] = changes[j] + sum(repl_view[touseobs] :!= val)
		if (isstrL)
			st_sstore(touseobs, variable[i], J(length(touseobs), 1, val))
		else
			repl_view[touseobs] = J(length(touseobs), 1, val)
	}

	stata("sort " + order)

	// Return results to Stata.
	st_local(_varlist, invtokens(repl_names))
	st_local(_changes_N, strofreal(sum(changes), `RealFormat'))
	changes_name = st_tempname()
	st_matrix(changes_name, changes)
	st_matrixrowstripe(changes_name, ("", "changes"))
	st_matrixcolstripe(changes_name, (J(repl_k, 1, ""), repl_names'))
	st_local(_changes_mat, changes_name)
}

					/* make replacements	*/
/* -------------------------------------------------------------------------- */

end
