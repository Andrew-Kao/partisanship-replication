clear
set mem 20m
set more off
set matsize 800
cd "~/Downloads/Partisanship_data_for_web"
use partisanship_for_web, clear
drop if year==. | year<1925 | stfips>56 | stfips==.
for num 02 01 05 04 06 08 09 11 10 12 13 15 19 16 17 18 20 21 22 25 24 23 26 27 29 28 30 37 38 31 33 34 35 32 36 39 40 41 42 44 45 46 47 48 49 51 50 53 55 54 56: gen byte yearX=year-1950 if stfips==X \ recode yearX .=0
gen ep=employed/pop_noninst
tsset stfips year
gen dem_voteshareb=dem_voteshare if dem_voteshare<.5
gen dem_votesharea=dem_voteshare if dem_voteshare>=.5
for any a b: recode dem_voteshareX .=0

* Summary statistics
gen margin=(abs(dem_voteshare-.5))*100
sum margin if gov_dem~=., d
gen legmargin=min((abs(house_pctdem-.5)),(abs(senate_pctdem-.5)))*100
sum legmargin if leg_dem~=., d

sort stfips year
bysort stfips: gen newyear=_n
tsset stfips newyear
replace year=int(year)
gen decade=(int(year/10))*10
*gen pres_dem=1 if (year>=1933 & year<=1952) | (year>=1961 & year<=1968) | (year>=1977 & year<=1980) | (year>=1993 & year<=2000) 
*recode pres_dem .=0
* for num 1/4: gen gov_demX=gov_dem if region==X \ recode gov_demX .=0 if gov_dem~=.
for num 3: gen gov_dems=gov_dem if region==X \ recode gov_dems .=0 if gov_dem~=. \ gen gov_demns=gov_dem if region~=X \ recode gov_demns .=0 if gov_dem~=. 
gen stax_difr=stax_topr-stax_botr
gen stax_ratr=stax_topr/stax_botr
gen dem_voteshare2=dem_voteshare^2
set more off

global policies stax_topr stax_corpr redist atr minwage afdc_max stemploy stempavw 
global outcome unionization incrate executions transfers ui afdc_reca stinctax stothertax stnontaxes strevenue
global welfare1 mean_faminc mean_faminc_pt faminc50 famincpt50 employeecomp poverty_pct gini gini_pt 
global welfare2 unemploymentrate naep_read pcrime vcrime mrate psuicide  
global reg1a X gov_dem i.stfips i.year
global reg2a X gov_dem lnpop pop15 pop65 black i.stfips i.year 
global reg3a X gov_dem leg_dem leg_rep lnpop pop15 pop65 black i.stfips i.year
global reg4a X gov_dem leg_dem leg_rep prscore lnpop pop15 pop65 black i.stfips i.year
global reg1b X gov_dem i.stfips i.year if termyear~=1
global reg2b X gov_dem lnpop pop15 pop65 black i.stfips i.year if termyear~=1
global reg3b X gov_dem leg_dem leg_rep lnpop pop15 pop65 black i.stfips i.year if termyear~=1
global reg4b X gov_dem leg_dem leg_rep lnpop pop15 pop65 black prscore i.stfips i.year if termyear~=1
global reg5b X gov_dem leg_dem leg_rep dem_voteshare prscore lnpop pop15 pop65 black i.stfips i.year if termyear~=1 & dem_voteshare<=.8 & dem_voteshare>=.2

* Turning rates from 0/1 into 0/100 variables
for var afdc_reca eitc_s_child1 stax_topr stax_corpr redist atr stemploy unionization poverty_pct unemployment gini gini_pt: replace X=X*100

tsset stfips year

* Summary stats
xi: reg lnpop gov_dem i.stfips i.year,r 
tabstat gov_dem leg_dem all_dem all_rep dem_voteshare prscore lnpop pop15 pop65 black $policies $outcome $welfare1 $welfare2 if e(sample) & year>=1941, stats(mean sd n min max) col(s)
* Code for calculating minimum and maximum years for dep vars 
* Note that if the asterisks preceding the next 3 lines are removed, it will create the summary stats, but the rest of the dofile will not run properly.
*for var $policies $outcome $welfare1 $welfare2: egen temp=min(year) if X~=. \ replace X=temp \ drop temp
*for var $policies $outcome $welfare1 $welfare2: egen temp=max(year) if X~=. \ replace X=temp \ drop temp
*tabstat gov_dem leg_dem all_dem all_rep dem_voteshare lnpop pop15 pop65 black $policies $outcome $welfare1 $welfare2 if e(sample) & year>=1941, stats(mean sd n min max) col(s)

xi: reg stax_topr gov_dem leg_dem leg_rep prscore lnpop pop15 pop65 black i.stfips i.year,r cluster(stfips) 
sum year if e(sample)
xi: reg naep gov_dem leg_dem leg_rep prscore lnpop pop15 pop65 black i.stfips i.year,r cluster(stfips) 
sum year if e(sample)

******************
* What do Governors do?
******************
* Policies
for var minwage : xi: reg $reg1a,r cluster(stfips) \ outreg using table1.doc, /// coefastr 
	nocons se /// bracket 3aster
	 replace ct("DROP") bdec(4) 
for var $policies: xi: reg $reg1a,r cluster(stfips)  \ outreg using table1.doc, /// coefastr  bracket 3aster
	nocons se append ct("Reg1 - X") bdec(4) \ xi: reg $reg2a,r cluster(stfips)  \ outreg using table1.doc, /// coefastr  bracket 3aster
	 nocons se append ct("Reg2 - X") bdec(4) \ xi: reg $reg3a,r cluster(stfips)  \ outreg using table1.doc, /// coefastr  bracket 3aster
	 nocons se append ct("Reg3 - X") bdec(4) \ xi: reg $reg4a,r cluster(stfips)  \ outreg using table1.doc, /// coefastr bracket 3aster
	  nocons se append ct("Reg4 - X") bdec(4) 
* Intermediate outcomes
for var unionization : xi: reg $reg1b,r cluster(stfips) \ outreg using table2.doc, /// 
	coefastr nocons se bracket 3aster replace ct("DROP") bdec(4) 
for var $outcome: xi: reg $reg1b,r cluster(stfips)  \ outreg using table2.doc, /// coefastr
	nocons se bracket 3aster append ct("Reg1 - X") bdec(4) \ xi: reg $reg2b,r cluster(stfips)  \ outreg using table2.doc, coefastr nocons se bracket 3aster append ct("Reg2 - X") bdec(4) \ xi: reg $reg3b,r cluster(stfips) \ outreg using table2.doc, coefastr nocons se bracket 3aster append ct("Reg3 - X") bdec(4) \ xi: reg $reg4b,r cluster(stfips) \ outreg using table2.doc, coefastr nocons se bracket 3aster append ct("Reg4 - X") bdec(4) \ xi: reg $reg5b,r cluster(stfips) \ outreg using table2.doc, coefastr nocons se bracket 3aster append ct("Reg5 - X") bdec(4) 
* Welfare
for var persinc_percap : xi: reg $reg1b,r cluster(stfips) \ outreg using table3.doc, coefastr nocons se bracket 3aster replace ct("DROP") bdec(4) 
for var $welfare1 $welfare2: xi: reg $reg1b,r cluster(stfips)  \ outreg using table3.doc, coefastr nocons se bracket 3aster append ct("Reg1 - X") bdec(4) \ xi: reg $reg2b,r cluster(stfips)  \ outreg using table3.doc, coefastr nocons se bracket 3aster append ct("Reg2 - X") bdec(4) \ xi: reg $reg3b,r cluster(stfips) \ outreg using table3.doc, coefastr nocons se bracket 3aster append ct("Reg3 - X") bdec(4) \ xi: reg $reg4b,r cluster(stfips)  \ outreg using table3.doc, coefastr nocons se bracket 3aster append ct("Reg4 - X") bdec(4) \ xi: reg $reg5b,r cluster(stfips)  \ outreg using table3.doc, coefastr nocons se bracket 3aster append ct("Reg5 - X") bdec(4) 
* Population
for var lnpop: xi: reg X gov_dem i.stfips i.year if termyear~=1 \ outreg using table3.doc, coefastr nocons se bracket 3aster append ct("X") bdec(4) \ xi: reg X gov_dem pop15 pop65 black i.stfips i.year if termyear~=1 \ outreg using table3.doc, coefastr nocons se bracket 3aster append ct("X") bdec(4) \ xi: reg X gov_dem leg_dem leg_rep pop15 pop65 black i.stfips i.year if termyear~=1 \ outreg using table3.doc, coefastr nocons se bracket 3aster append ct("X") bdec(4) \ xi: reg X gov_dem leg_dem leg_rep prscore pop15 pop65 black i.stfips i.year if termyear~=1 \ outreg using table3.doc, coefastr nocons se bracket 3aster append ct("X") bdec(4) \ xi: reg X gov_dem leg_dem leg_rep dem_voteshare prscore pop15 pop65 black i.stfips i.year if termyear~=1 & dem_voteshare<=.8 & dem_voteshare>=.2 \ outreg using table3.doc, coefastr nocons se bracket 3aster append ct("X") bdec(4)

* See "help multproc" for definitions of Bonferroni & Sidak adjustments

******************
* SUR estimation
******************
set matsize 2000
global sureg1a gov_dem i.stfips i.year
log using sureg_mysureg, replace
xi: mysureg (stax_topr $sureg1a) (stax_corpr $sureg1a) (redist $sureg1a) (atr $sureg1a) (minwage $sureg1a) (afdc_max $sureg1a) (stemploy $sureg1a) (stempavw $sureg1a), cluster(stfips)
test gov_dem
log close
gen commonsamp=1 if stax_topr~=. & stax_corpr~=. & redist~=. & atr~=. & minwage~=. & afdc_max~=. & stemploy~=. & stempavw~=. 
for var minwage : xi: reg $reg1a if commonsamp==1,r cluster(stfips) \ outreg using table_sureg.doc, coefastr nocons se bracket 3aster replace ct("DROP") bdec(4) 
for var $policies: xi: reg $reg1a if commonsamp==1,r cluster(stfips)  \ outreg using table_sureg.doc, coefastr nocons se bracket 3aster append ct("Reg1 - X") bdec(4) 

***********************************
* Robustness checks for referees
***********************************
* Does lagged politics affect union membership?
xi: reg f4.unionization gov_dem i.stfips i.year if termyear~=1,r cluster(stfips)
xi: reg unionization gov_dem i.stfips i.year if termyear~=1,r cluster(stfips)
* Are changes in population associated with partisanship? 
xi: reg d.lnpop gov_dem i.stfips i.year if termyear~=1, r cluster(stfips)
xi: reg lnpop gov_dem i.stfips i.year if termyear~=1, r cluster(stfips) 
* How correlaed are the political varibles?
xi: areg gov_dem leg_dem leg_rep i.stfips, a(year) r
* What does it look like if we add d(gov_dem)?
global diff_reg1a X d.gov_dem gov_dem i.stfips i.year
global diff_reg1b X s2.gov_dem gov_dem i.stfips i.year if termyear~=1
for var minwage : xi: reg $diff_reg1a,r cluster(stfips) \ outreg using table_difftest.doc, coefastr nocons se bracket 3aster replace ct("DROP") bdec(4) 
for var $policies: xi: reg $diff_reg1a,r cluster(stfips)  \ outreg using table_difftest.doc, coefastr nocons se bracket 3aster append ct("X") bdec(4)
for var $outcome: xi: reg $diff_reg1b,r cluster(stfips)  \ outreg using table_difftest.doc, coefastr nocons se bracket 3aster append ct("X") bdec(4) 
for var $welfare1 $welfare2: xi: reg $diff_reg1b,r cluster(stfips)  \ outreg using table_difftest.doc, coefastr nocons se bracket 3aster append ct("X") bdec(4) 

