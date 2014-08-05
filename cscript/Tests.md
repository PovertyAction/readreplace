readreplace tests
=================

Below is a list of `readreplace` tests. Unless marked otherwise, all tests are implemented in the [cscript](/cscript/readreplace.do). Each test is associated with a unique positive integer ID.

Contributions of new tests are welcome. When adding a test to the cscript, please add a row to the table below. All datasets should be readable by Stata 10, the minimal supported version.

<table>
<tr>
	<th>Test ID</th>
	<th>Area</th>
	<th>Description</th>
</tr>
<tr>
	<td>1</td>
	<td>Basic</td>
	<td>Help file example for <code>readreplace</code> version 1</td>
</tr>
<tr>
	<td>2</td>
	<td>User mistakes</td>
	<td>Specify <code>.csv</code> files that result in an <code>insheet</code> error.</td>
</tr>
<tr>
	<td>3</td>
	<td>User mistakes</td>
	<td>Specify a <code>.csv</code> file whose first column is not the ID variable.</td>
</tr>
<tr>
	<td>4</td>
	<td>User mistakes</td>
	<td>Specify <code>.csv</code> files that do not contain exactly three columns.</td>
</tr>
<tr>
	<td>5</td>
	<td>Basic</td>
	<td>Specify deprecated option <code>display</code>; it should have no effect.</td>
</tr>
</table>
