{smcl}
{* *! version 0.1  14sep2010}{...}
{title:Title}

{phang}
{cmd:readreplace} {hline 2}
Make replacements that are specified in an external dataset


{title:Syntax}

{p 8 17 2}
{cmdab:readreplace}
{cmd: using} {it: filename}
{cmd:, id}({varname})
[{cmd:display}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt id(varname)}}Required. Name of unique identifier{p_end}
{synopt:{opt di:splay}}show detail on what readreplace is doing{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{title:Description}

{pstd}
{cmd:readreplace} makes replacements using a very specifically-formated .csv file.
	It is intended for use with the output from {help cfout}.

{title:Remarks}

{pstd}
{cmd: readreplace} is intended to be used as part of the data entry process
	when data is entered two times for accuracy.
	After the second entry, the datasets need to be reconciled.
	{help cfout} will compare the first and second entries and
	generate a list of discrepancies in a format that is useful
	for the data entry teams.
	The data entry operators can then simply type the correct value
	in a new column of the cfout results.
	To make the changes in your dataset,
	load your data then run readreplace	using the new .csv file.

{pstd}
{cmd: readreplace} requires the using file to be a .csv file with the format

{center:{it: id value, question name , correct value } }

{pstd}
	It then runs the replaces

{center: replace {it:question name} = {it:correct value} if {it:id varname} == {it:id value} }

{pstd}
	for each line in the csv file,
	with allowances for whether the variables/ids are string or numeric.
	The display option is useful for debugging.
	The first row is assumed to be a header row, and no replacements are made to data in the first row.

{title:Examples}

{phang}readreplace using "corrected values.csv", id(uniqueid)

{marker authors}{...}
{title:Authors}

{pstd}Ryan Knight, Innovations for Poverty Action{p_end}
{pstd}rknight@poverty-action.org{p_end}

{pstd}Matthew White, Innovations for Poverty Action{p_end}
{pstd}mwhite@poverty-action.org{p_end}


{title:Also see}

{psee}
Help:  {manhelp generate D}

{psee}
User-written:  {helpb cfout}, {helpb bcstats}, {helpb mergeall}
{p_end}
