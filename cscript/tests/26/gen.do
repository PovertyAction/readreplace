vers 10

clear
set obs 1

gen id = _n

foreach type in byte int long float double {
	gen `type' zero_`type' = 0
}

sa gen_master
