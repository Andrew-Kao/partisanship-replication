
/*

	remember to do abortion regressions

*/

* Cleaning 

global dir = "~/Documents/College/3rd Yr/Econometrics/partisanship-replication"

clear
set mem 20m
set more off
set matsize 800
use "$dir/build/data/final_data.dta", clear
drop if year==. | year<1925 | stfips>56 | stfips==.
for num 02 01 05 04 06 08 09 11 10 12 13 15 19 16 17 18 20 21 22 25 24 23 26 27 29 28 30 37 38 31 33 34 35 32 36 39 40 41 42 44 45 46 47 48 49 51 50 53 55 54 56: gen byte yearX=year-1950 if stfips==X \ recode yearX .=0


bysort stfips (year): gen newyear=_n
tsset stfips newyear
replace year=int(year)
gen decade=(int(year/10))*10


* Turning rates from 0/1 into 0/100 variables
for var afdc_reca eitc_s_child1 stax_topr stax_corpr redist atr stemploy unionization poverty_pct unemployment gini gini_pt: replace X=X*100

gen ep=employed/pop_noninst

* Label Vars
label var gov_dem "Democrat Governer"
label var leg_dem "Democrat Legislature"
label var all_dem "Democrat Governer and Legislature"
label var all_rep "Republican Governer and Legislature"
label var dem_voteshare "Voteshare Received by Democratic Candidate"
label var prscore "Poole-Rosenthal Score of Congressional Reps"
label var lnpop "Log Population"
label var pop15 "Percent Population under 15"
label var pop65 "Percent Population over 65"
label var black "Percent Population Black"
label var stax_topr "Top Income Tax Rate"
label var stax_corpr "Top Corporate Tax Rate"
label var redist "Tax Redistribution Index"
label var atr "Average Income Tax Rate"
label var minwage "Log Real Minimum Wage"
label var afdc_max "Log Maximum Welfare Benefit (AFDC)"
label var stemploy "Percent Population Gov Employees"
label var stempavw "Log Average Real Wage Gov Employees"
label var unionization "Unionization Rate"
label var incrate "Incarceration Rate"
label var executions "Executions per 100,000"
label var transfers "Log State Transfers per Capita"
label var ui "Log State UI Payments per Capita"
label var afdc_reca "Percent Population on Welfare"
label var stinctax "Log Real State Income Tax Receipt per Capita"
label var stothertax "Log Real Other Income Tax Receipt per Capita"
label var stnontaxes "Log Real Non-Tax Revenue per Capita"
label var strevenue "Log Real State Revenue per Capita"
label var mean_faminc "Log Real Mean Family Pre-Tax Income" // pre-tax
label var mean_faminc_pt "Log Real Mean Family Post-Tax Income"
label var faminc50 "Log Real Median Family Pre-Tax Income"
label var famincpt50 "Log Real Median Family Post-Tax Income"
label var employeecomp "Log Mean Real Wage"
label var poverty_pct "Percent Population Poverty"
label var gini "Pre-Tax Gini"
label var gini_pt "Post-Tax Gini"
label var unemploymentrate "Unemployment Rate"
label var naep_read "Average NAEP 4th Grade Score" // reading literacy
label var pcrime "Property Crimes per 100,000"
label var vcrime "Violent Crimes per 100,000"
label var mrate "Murder Rate per 100,000"
label var psuicide "Suicide Rate per 100,000"
label var ep "Employment Rate"


* OUTCOMES
global policies stax_topr stax_corpr redist atr minwage afdc_max stemploy stempavw 
global outcome unionization incrate executions transfers ui afdc_reca stinctax stothertax stnontaxes strevenue
global welfare1 mean_faminc mean_faminc_pt faminc50 famincpt50 employeecomp poverty_pct gini gini_pt 
global welfare2 unemploymentrate naep_read pcrime vcrime mrate psuicide  
global abortion abortions

* subset of outcomes
global subpolicies  stax_topr stax_corpr atr minwage afdc_max stemploy 
global suboutcome unionization incrate transfers afdc_reca strevenue
global subwelfare1 employeecomp poverty_pct gini
global subwelfare2 unemploymentrate naep_read mrate   

* SPECIFICATION a: Keep First Year
global reg1a gov_dem i.stfips i.year, r cluster(stfips)
global reg2a gov_dem lnpop pop15 pop65 black i.stfips i.year, r cluster(stfips)
global reg3a gov_dem leg_dem leg_rep lnpop pop15 pop65 black i.stfips i.year, r cluster(stfips)
global reg4a gov_dem leg_dem leg_rep lnpop pop15 pop65 black prscore i.stfips i.year, r cluster(stfips)
global reg5a gov_dem leg_dem leg_rep dem_voteshare prscore lnpop pop15 pop65 black i.stfips i.year if dem_voteshare<=.8 & dem_voteshare>=.2, r cluster(stfips)
 
* SPECIFICATION b: Omit First Year
global reg1b gov_dem i.stfips i.year if termyear~=1, r cluster(stfips)
global reg2b gov_dem lnpop pop15 pop65 black i.stfips i.year if termyear~=1, r cluster(stfips)
global reg3b gov_dem leg_dem leg_rep lnpop pop15 pop65 black i.stfips i.year if termyear~=1, r cluster(stfips)
global reg4b gov_dem leg_dem leg_rep lnpop pop15 pop65 black prscore i.stfips i.year if termyear~=1, r cluster(stfips)
global reg5b gov_dem leg_dem leg_rep dem_voteshare prscore lnpop pop15 pop65 black i.stfips i.year if termyear~=1 & dem_voteshare<=.8 & dem_voteshare>=.2, r cluster(stfips)

* SPECIFICATION c: Extension 
global reg1c gov_dem i.stfips i.year if termyear~=1 & dem_voteshare<=.8 & dem_voteshare>=.2, r cluster(stfips)
global reg2c gov_dem i.stfips i.year if termyear~=1 & dem_voteshare<=.55 & dem_voteshare>=.45, r cluster(stfips)
global reg3c gov_dem i.stfips i.year if termyear~=1 & dem_voteshare<=.51 & dem_voteshare>=.49, r cluster(stfips)
global reg4c gov_dem leg_dem leg_rep dem_voteshare prscore lnpop pop15 pop65 black i.stfips i.year if termyear~=1 & dem_voteshare<=.55 & dem_voteshare>=.45, r cluster(stfips)
global reg5c gov_dem leg_dem leg_rep dem_voteshare prscore lnpop pop15 pop65 black i.stfips i.year if termyear~=1 & dem_voteshare<=.51 & dem_voteshare>=.49, r cluster(stfips)

* Summary Stats

reg lnpop gov_dem i.stfips i.year, r
estpost tabstat gov_dem leg_dem dem_voteshare lnpop pop15 pop65 black $subpolicies $suboutcome $subwelfare1 $subwelfare2 if e(sample) & year>=1941, stats(mean sd n min max) col(s) //all_dem all_rep prscore
eststo m1

esttab m1 using "$dir/output/tables/summary.tex", cells("mean(fmt(2)) sd min max") nostar ///
 label booktabs mtitles("Summary Statistics") replace

eststo clear

*** MANY DEP VAR CODE ***

cap program drop runreg
program runreg 
syntax anything, specification(string)
local i = 1
foreach depvar of global `1' {
reg `depvar' ${reg1`specification'} 
local m1 = _b[gov_dem]
local s1 = _se[gov_dem]
local df1 = e(df_r)
reg `depvar' ${reg2`specification'} 
local m2 = _b[gov_dem]
local s2 = _se[gov_dem]
local df2 = e(df_r)
reg `depvar' ${reg3`specification'}
local m3 = _b[gov_dem]
local s3 = _se[gov_dem]
local df3 = e(df_r)
reg `depvar' ${reg4`specification'}
local m4 = _b[gov_dem]
local s4 = _se[gov_dem]
local df4 = e(df_r)
reg `depvar' ${reg5`specification'}
local m5 = _b[gov_dem]
local s5 = _se[gov_dem]
local df5 = e(df_r)

mat means = (`m1',`m2',`m3',`m4',`m5')
mat ses = (`s1',`s2',`s3',`s4',`s5')
local label : var label `depvar'

matrix stars = J(1,10,0)
forvalues k = 1/5 {
local j = `k'*2 - 1
matrix stars[1,`j'] =   ///
	(abs(means[1,`k']/ses[1,`k']) > invttail(`df`k'',0.1/2)) + ///
	(abs(means[1,`k']/ses[1,`k']) > invttail(`df`k'',0.05/2)) +   ///
	(abs(means[1,`k']/ses[1,`k']) > invttail(`df`k'',0.01/2))
}
mat A = (`m1',`s1',`m2', `s2',`m3', `s3',`m4', `s4',`m5',`s5')

if `i' == 1 {
frmttable using "$dir/output/tables/`1'_`specification'.tex", statmat(A) sdec(4) ctitle("Dep Var", "(1)", "(2)", "(3)", "(4)", "(5)") rtitle("`label'") replace tex ///
	annotate(stars) asymbol(*,**,***) substat(1) fragment statfont(scriptsize)
}
else {
frmttable using "$dir/output/tables/`1'_`specification'.tex", statmat(A) sdec(4) ctitle("Dep Var", "(1)", "(2)", "(3)", "(4)", "(5)") rtitle("`label'") append tex ///
	annotate(stars) asymbol(*,**,***) substat(1) fragment statfont(scriptsize)
}
local i = `i' + 1

}

end


*** RUN REGRESSIONS ***
runreg "policies", specification("a")
runreg "policies", specification("b")
runreg "policies", specification("c")
runreg "outcome", specification("a")
runreg "outcome", specification("b")
runreg "outcome", specification("c")
runreg "welfare1", specification("a")
runreg "welfare1", specification("b")
runreg "welfare1", specification("c")
runreg "welfare2", specification("a")
runreg "welfare2", specification("b")
runreg "welfare2", specification("c")
runreg "abortion", specification("a")
runreg "abortion", specification("b")
runreg "abortion", specification("c")









