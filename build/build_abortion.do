/*
	Create the abortion dataset and merge in with panel

	Data scraped from http://www.johnstonsarchive.net/policy/abortion/index.html#US
	Why abortion? https://news.gallup.com/poll/235640/above-issues-abortion-divides-liberals-conservatives.aspx?
*/

global data = "/Users/AndrewKao/Documents/College/3rd Yr/Econometrics/partisanship-replication/build/raw/abortion"

clear

cap program drop addState

program addState
syntax anything, fips(string)

preserve

import delim using "${data}/`1'.csv", clear

keep v1 v3
rename v1 year
rename v3 abortions
keep if _n > 4
destring year, replace
destring abortions, replace ignore(",")

gen stfips = `fips'

tempfile a
save `a'

restore

append using `a'
end

addState "alabama", fips(1)
addState "alaska", fips(2)
addState "arizona", fips(3)
addState "arkansas", fips(4)
addState "california", fips(5)
addState "colorado", fips(8)
addState "connecticut", fips(9)
addState "delaware", fips(10)
addState "florida", fips(12)
addState "georgia", fips(13)
addState "hawaii", fips(15)
addState "idaho", fips(16)
addState "illinois", fips(17)
addState "indiana", fips(18)
addState "iowa", fips(19)
addState "kansas", fips(20)
addState "kentucky", fips(21)
addState "louisiana", fips(22)
addState "maine", fips(23)
addState "maryland", fips(24)
addState "massachusetts", fips(25)
addState "michigan", fips(26)
addState "minnesota", fips(27)
addState "mississippi", fips(28)
addState "missouri", fips(29)
addState "montana", fips(30)
addState "nebraska", fips(31)
addState "nevada", fips(32)
addState "newhampshire", fips(33)
addState "newjersey", fips(34)
addState "newmexico", fips(35)
addState "newyork", fips(36)
addState "northcarolina", fips(37)
addState "northdakota", fips(38)
addState "ohio", fips(39)
addState "oklahoma", fips(40)
addState "oregon", fips(41)
addState "pennsylvania", fips(42)
addState "rhodeisland", fips(44)
addState "southcarolina", fips(45)
addState "southdakota", fips(46)
addState "tennessee", fips(47)
addState "texas", fips(48)
addState "utah", fips(49)
addState "vermont", fips(50)
addState "virginia", fips(51)
addState "washington", fips(53)
addState "westvirginia", fips(54)
addState "wisconsin", fips(55)
addState "wyoming", fips(56)


tempfile abortion
save `abortion'

use "/Users/AndrewKao/Documents/College/3rd Yr/Econometrics/partisanship-replication/partisanship_for_web.dta", clear

merge m:1 year stfips using `abortion', keep(1 3) nogen

save "/Users/AndrewKao/Documents/College/3rd Yr/Econometrics/partisanship-replication/build/data/final_data.dta", replace
