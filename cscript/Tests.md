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
<tr>
	<td>6</td>
	<td>User mistakes</td>
	<td>The variable name variable contains a value that is not an unabbreviated variable name.</td>
</tr>
<tr>
	<td>7</td>
	<td>User mistakes</td>
	<td>Specify a replacements file with ID values not in the dataset in memory.</td>
</tr>
<tr>
	<td>8</td>
	<td>Basic</td>
	<td>Specify a replacements file with no observations.</td>
</tr>
<tr>
	<td>9</td>
	<td>Basic</td>
	<td>Specify a string ID variable and a replacements file to <code>insheet</code> that has no observations.</td>
</tr>
<tr>
	<td>10</td>
	<td>Basic</td>
	<td>Specify a replacements file whose variable name variable includes both numeric and string variables.</td>
</tr>
<tr>
	<td>11</td>
	<td>User mistakes</td>
	<td>Specify a replacements file whose variable name variable is numeric.</td>
</tr>
<tr>
	<td>12</td>
	<td>Basic</td>
	<td>Specify a replacements file whose variable name variable includes a string variable but whose new value variable is numeric.</td>
</tr>
<tr>
	<td>13</td>
	<td>Basic</td>
	<td>Specify a replacements file whose variable name variable includes a numeric variable but whose new value variable is string. Further, while all the values for numeric variables are numeric when converted by Mata's <code>strtoreal()</code>, some contain leading and trailing spaces.</td>
</tr>
<tr>
	<td>14</td>
	<td>User mistakes</td>
	<td>Specify a replacements file whose variable name variable includes a numeric variable but whose new value variable specifies a string value for that variable. Blank values (<code>""</code>) are interpreted as string, and are not converted to <code>sysmiss</code>.</td>
</tr>
<tr>
	<td>15</td>
	<td>User mistakes</td>
	<td>Specify option <code>variable()</code> without option <code>value()</code>, and vice versa.</td>
</tr>
<tr>
	<td>16</td>
	<td>User mistakes</td>
	<td>Specify nonexistent variables to options <code>id()</code>, <code>variable()</code>, and <code>value()</code>.</td>
</tr>
<tr>
	<td>17</td>
	<td>User mistakes</td>
	<td>Specify the same variable to options <code>variable()</code> and <code>value()</code>.</td>
</tr>
<tr>
	<td>18</td>
	<td>User mistakes</td>
	<td>Specify the same variable to options <code>id()</code> and <code>variable()</code> and to <code>id()</code> and <code>value()</code>.</td>
</tr>
<tr>
	<td>19</td>
	<td>Basic</td>
	<td>Simple tests of options <code>use</code>, <code>insheet</code>, <code>excel</code>, and <code>import()</code>.</td>
</tr>
<tr>
	<td>20</td>
	<td>User mistakes</td>
	<td>Specify multiple import command options.</td>
</tr>
<tr>
	<td>21</td>
	<td>User mistakes</td>
	<td>When the ID variable has different names in the dataset in memory and the replacements file, specify a <code>varlist</code> to option <code>id()</code> that matches both names.</td>
</tr>
</table>
