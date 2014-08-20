{smcl}
{* *! version 0.1  14sep2010}{...}
{title:Title}

{phang}
{cmd:readreplace} {hline 2}
Make replacements that are specified in an external dataset


{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:readreplace using} {it:{help filename}}{cmd:,}
{opth id(varlist)} {opth var:iable(varname)} {opth val:ue(varname)}
[{it:options}]

{* Using -help odbc- as a template.}{...}
{* 20 is the position of the last character in the first column + 3.}{...}
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{* Using -help heckman- as a template.}{...}
{p2coldent:* {opth id(varlist)}}variables for matching observations with
the replacements specified in the using dataset{p_end}
{p2coldent:* {opth var:iable(varname)}}variable in the using dataset that
indicates the variables to replace{p_end}
{p2coldent:* {opth val:ue(varname)}}variable in the using dataset that
stores the new values{p_end}

{syntab:Import}
{synopt:{opt insheet}}use {helpb insheet} to import {it:filename};
the default{p_end}
{synopt:{opt u:se}}use {helpb use} to load {it:filename}{p_end}
{synopt:{opt exc:el}}use {helpb import excel} to import {it:filename}{p_end}
{synopt:{opt import(options)}}options to specify to the import command{p_end}
{synoptline}
{p2colreset}{...}
{* Using -help heckman- as a template.}{...}
{p 4 6 2}* {opt id()}, {opt variable()}, and {opt value()} are required.


{title:Description}

{pstd}
{cmd:readreplace} modifies the dataset currently in memory by
making replacements that are specified in an external dataset,
the replacements file.

{pstd}
The list of differences saved by the SSC program {helpb cfout} is designed for
later use by {cmd:readreplace}. After the addition of a new variable to
the {cmd:cfout} differences file that holds the new (correct) values,
the file can be used as the {cmd:readreplace} replacements file.


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

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:readreplace} stores the following in {cmd:r()}:

{* Using -help spearman- as a template.}{...}
{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of real changes{p_end}

{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(varlist)}}variables replaced{p_end}

{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(changes)}}number of real changes by variable{p_end}
{p2colreset}{...}


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
