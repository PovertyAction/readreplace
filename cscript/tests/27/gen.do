vers 10

clear
set obs 1

gen id = _n

gen str_2 = "xx"
if c(stata_version) >= 13 {
	gen str_L = (c(maxstrvarlen) + 3) * "y"
	assert "`:type str_L'" == "strL"
}

sa gen_master
