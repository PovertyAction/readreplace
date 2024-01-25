
**Important Notice:** 
This repository is no longer under active development. We have developed a new version of the program called `ipareadreplace`. The new program is part of the `ipacheck` package and is housed [here](https://github.com/PovertyAction/high-frequency-checks). Thank you for your support and understanding.

readreplace
===========

`readreplace` modifies the dataset currently in memory by making replacements that are specified in an external dataset, the replacements file.

The list of differences saved by the SSC program [`cfout`](https://github.com/PovertyAction/cfout) is designed for later use by `readreplace`. After the addition of a new variable to the `cfout` differences file that holds the new (correct) values, the file can be used as the `readreplace` replacements file.

`readreplace` is available through SSC: type `ssc install cfout` in Stata to install.

Certification script
--------------------

The [certification script](http://www.stata.com/help.cgi?cscript) of `readreplace` is [`cscript/readreplace.do`](/cscript/readreplace.do). If you are new to certification scripts, you may find [this](http://www.stata-journal.com/sjpdf.html?articlenum=pr0001) Stata Journal article helpful. See [this guide](/cscript/Tests.md) for more on `readreplace` testing.

Stata help file
---------------

Converted automatically from SMCL:

```
log html readreplace.sthlp readreplace.md
```

The help file looks best when viewed in Stata as SMCL.

<pre>
<b><u>Title</u></b>
<p>
    <b>readreplace</b> -- Make replacements that are specified in an external
        dataset
<p>
<p>
<a name="syntax"></a><b><u>Syntax</u></b>
<p>
        <b>readreplace using</b> <i>filename</i><b>,</b> <b>id(</b><i>varlist</i><b>)</b> <b><u>var</u></b><b>iable(</b><i>varname</i><b>)</b> <b><u>val</u></b><b>ue(</b>
          <i>varname</i><b>)</b> [<i>options</i>]
<p>
    <i>options</i>               Description
    -------------------------------------------------------------------------
    Main
    * <b>id(</b><i>varlist</i><b>)</b>         variables for matching observations with the
                            replacements specified in the using dataset
    * <b><u>var</u></b><b>iable(</b><i>varname</i><b>)</b>   variable in the using dataset that indicates the
                            variables to replace
    * <b><u>val</u></b><b>ue(</b><i>varname</i><b>)</b>      variable in the using dataset that stores the new
                            values
<p>
    Import
      <b>insheet</b>             use <b>insheet</b> to import <i>filename</i>; the default
      <b><u>u</u></b><b>se</b>                 use <b>use</b> to load <i>filename</i>
      <b><u>exc</u></b><b>el</b>               use <b>import excel</b> to import <i>filename</i>
      <b>import(</b><i>options</i><b>)</b>     options to specify to the import command
    -------------------------------------------------------------------------
    * <b>id()</b>, <b>variable()</b>, and <b>value()</b> are required.
<p>
<p>
<b><u>Description</u></b>
<p>
    <b>readreplace</b> modifies the dataset currently in memory by making
    replacements that are specified in an external dataset, the replacements
    file.
<p>
    The list of differences saved by the SSC program <b>cfout</b> is designed for
    later use by <b>readreplace</b>. After the addition of a new variable to the
    <b>cfout</b> differences file that holds the new (correct) values, the file can
    be used as the <b>readreplace</b> replacements file.
<p>
<p>
<a name="remarks"></a><b><u>Remarks</u></b>
<p>
    <b>readreplace</b> changes the contents of existing variables by making
    replacements that are specified in a separate dataset, the replacements
    file. The replacements file should be long by replacement such that each
    observation is a replacement to complete.  Replacements are described by
    a variable that contains the name of the variable to change, specified to
    option <b>variable()</b>, and a variable that stores the new value for the
    variable, specified to option <b>value()</b>. The replacements file should also
    hold variables shared by the dataset in memory that indicate the subset
    of the data for which each change is intended; these are specified to
    option <b>id()</b>, and are used to match observations in memory to their
    replacements in the replacements file.
<p>
    Below, an example replacements file is shown with three variables:
    <b>uniqueid</b>, to be specified to <b>id()</b>, <b>Question</b>, to be specified to
    <b>variable()</b>, and <b>CorrectValue</b>, to be specified to <b>value()</b>.
<p>
<b>    </b>+--------------------------------------+
<b>    </b>|<b> uniqueid     Question   CorrectValue </b>|
<b>    </b>|--------------------------------------|
<b>    </b>|<b>      105     district             13 </b>|
<b>    </b>|<b>      125          age              2 </b>|
<b>    </b>|<b>      138       gender              1 </b>|
<b>    </b>|<b>      199     district             34 </b>|
<b>    </b>|<b>        2   am_failure              3 </b>|
<b>    </b>+--------------------------------------+
<p>
    For each observation of the replacements file, <b>readreplace</b> essentially
    runs the following <b>replace</b> command:
<p>
    <b>replace</b> <i>Question_value</i> <b>=</b> <i>CorrectValue_value</i> <b>if uniqueid ==</b> <i>uniqueid_value</i>
<p>
    That is, the effect of <b>readreplace</b> here is the same as these five <b>replace</b>
    commands:
<p>
    <b>replace district   = 13 if uniqueid == 105</b>
    <b>replace age        = 2  if uniqueid == 125</b>
    <b>replace gender     = 1  if uniqueid == 138</b>
    <b>replace district   = 34 if uniqueid == 199</b>
    <b>replace am_failure = 3  if uniqueid == 2</b>
<p>
    The variable specified to <b>value()</b> may be numeric or string; either is
    accepted.
<p>
    The replacements file may be one of the following formats:
<p>
        o <i>Comma-separated data.</i> This is the default format, but you may
            specify option <b>insheet</b>; either way, <b>readreplace</b> will use <b>insheet</b>
            to import the replacements file. You can also specify any options
            for <b>insheet</b> to option <b>import()</b>.
        o <i>Stata dataset.</i> Specify option <b>use</b> to <b>readreplace</b>, passing any
            options for <b>use</b> to <b>import()</b>.
        o <i>Excel file.</i> Specify option <b>excel</b> to <b>readreplace</b>, passing any
            options for <b>import excel</b> to <b>import()</b>.
<p>
    <b>readreplace</b> may be employed for a variety of purposes, but it was
    designed to be used as part of a data entry process in which data is
    entered two times for accuracy.  After the second entry, the two separate
    entry datasets need to be reconciled.  <b>cfout</b> can compare the first and
    second entries, saving the list of differences in a format that is useful
    for data entry teams.  Data entry operators can then add a new variable
    to the differences file for the correct value.  Once this variable has
    been entered, load either of the two entry datasets, then run <b>readreplace</b>
    with the new replacements file.
<p>
    The GitHub repository for <b>readreplace</b> is here.  Previous versions may be
    found there: see the tags.
<p>
<p>
<a name="remarks_promoting"></a><b><u>Remarks for promoting storage types</u></b>
<p>
    <b>readreplace</b> will change variables' storage types in much the same way as
    <b>replace</b>, promoting storage types according to these rules:
<p>
        1.  Storage types are only promoted; they are never compressed.
        2.  The storage type of <b>float</b> variables is never changed.
        3.  If a variable of integer type (<b>byte</b>, <b>int</b>, or <b>long</b>) is replaced
            with a noninteger value, its storage type is changed to <b>float</b> or
            <b>double</b> according to the current <b>set type</b> setting.
        4.  If a variable of integer type is replaced with an integer value
            that is too large or too small for its current storage type, it
            is promoted to a longer type (<b>int</b>, <b>long</b>, or <b>double</b>).
        5.  When needed, <b>str</b><i>#</i> variables are promoted to a longer <b>str</b><i>#</i> type or
            to <b>strL</b>.
<p>
<p>
<a name="examples"></a><b><u>Examples</u></b>
<p>
    Make the changes specified in <b>correctedValues.csv</b>
        <b>. use firstEntry</b>
        <b>. readreplace using correctedValues.csv, id(uniqueid)</b>
            <b>variable(question) value(correctvalue)</b>
<p>
    Same as the previous <b>readreplace</b> command, but specifies option <b>case</b> to
    <b>insheet</b> to import the replacements file
        <b>. use firstEntry</b>
        <b>. readreplace using correctedValues.csv, id(uniqueid)</b>
            <b>variable(Question) value(CorrectValue) import(case)</b>
<p>
    Same as the previous <b>readreplace</b> command, but loads the replacements file
    as a Stata dataset
        <b>. use firstEntry</b>
        <b>. readreplace using correctedValues.dta, id(uniqueid)</b>
            <b>variable(Question) value(CorrectValue) use</b>
<p>
<p>
<a name="results"></a><b><u>Stored results</u></b>
<p>
    <b>readreplace</b> stores the following in <b>r()</b>:
<p>
    Scalars
      <b>r(N)</b>           number of real changes
<p>
    Macros
      <b>r(varlist)</b>     variables replaced
<p>
    Matrices
      <b>r(changes)</b>     number of real changes by variable
<p>
<p>
<a name="authors"></a><b><u>Authors</u></b>
<p>
    Ryan Knight
    Matthew White
<p>
    For questions or suggestions, submit a GitHub issue or e-mail
    researchsupport@poverty-action.org.
<p>
<p>
<b><u>Also see</u></b>
<p>
    Help:  <b>[D] generate</b>
<p>
    User-written:  <b>cfout</b>, <b>bcstats</b>, <b>mergeall</b>
</pre>
