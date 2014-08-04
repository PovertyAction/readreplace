readreplace
===========

`readreplace` makes replacements using a very specifically formatted .csv file. It is intended for use with the output from [`cfout`](https://github.com/PovertyAction/cfout).

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
<b>help readreplace</b>
-------------------------------------------------------------------------------
<p>
<b><u>Title</u></b>
<p>
    <b>readreplace</b> -- Make many replacements to a dataset from a .csv file
<p>
<b><u>Syntax</u></b>
<p>
        <b>readreplace using</b><i> filename</i> <b>, id</b>(<i>varname</i>) [<b>display</b>]
<p>
    <i>options</i>               Description
    -------------------------------------------------------------------------
      <b>id(</b><i>varname</i><b>)</b>         Required. Name of unique identifier
      <b><u>di</u></b><b>splay</b>             show detail on what readreplace is doing
    -------------------------------------------------------------------------
<p>
<b><u>Description</u></b>
<p>
    <b>readreplace</b> makes replacements using a very specifically-formated .csv
    file.  It is intended for use with the output from cfout.
<p>
<b><u>Remarks</u></b>
<p>
    <b>readreplace</b> is intended to be used as part of the data entry process when
    data is entered two times for accuracy.  After the second entry, the
    datasets need to be reconciled.  cfout will compare the first and second
    entries and generate a list of discrepancies in a format that is useful
    for the data entry teams.  The data entry operators can then simply type
    the correct value in a new column of the cfout results.  To make the
    changes in your dataset, load your data then run readreplace using the
    new .csv file.
<p>
    <b>readreplace</b> requires the using file to be a .csv file with the format
<p>
                  <i> id value, question name , correct value </i>
<p>
    It then runs the replaces
<p>
        replace <i>question name</i> = <i>correct value</i> if <i>id varname</i> == <i>id value</i>
<p>
    for each line in the csv file, with allowances for whether the
    variables/ids are string or numeric.  The display option is useful for
    debugging.  The first row is assumed to be a header row, and no
    replacements are made to data in the first row.
<p>
<b><u>Examples</u></b>
<p>
    readreplace using "corrected values.csv", id(uniqueid)
<p>
<b><u>Also see</u></b>
<p>
    Online:  cf, cfout
</pre>
