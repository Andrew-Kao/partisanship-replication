
* Cleaning 

clear
set mem 20m
set more off
set matsize 800
cd "~/Documents/College/3rd Yr/Econometrics/partisanship-replication"
use partisanship_for_web, clear
drop if year==. | year<1925 | stfips>56 | stfips==.
for num 02 01 05 04 06 08 09 11 10 12 13 15 19 16 17 18 20 21 22 25 24 23 26 27 29 28 30 37 38 31 33 34 35 32 36 39 40 41 42 44 45 46 47 48 49 51 50 53 55 54 56: gen byte yearX=year-1950 if stfips==X \ recode yearX .=0


bysort stfips (year): gen newyear=_n
tsset stfips newyear
replace year=int(year)
gen decade=(int(year/10))*10


* Turning rates from 0/1 into 0/100 variables
for var afdc_reca eitc_s_child1 stax_topr stax_corpr redist atr stemploy unionization poverty_pct unemployment gini gini_pt: replace X=X*100

gen ep=employed/pop_noninst


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
label var ep "employment rate"


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

reg lnpop gov_dem i.stfips i.year, r
tabstat gov_dem leg_dem all_dem all_rep dem_voteshare prscore lnpop pop15 pop65 black $policies $outcome $welfare1 $welfare2 if e(sample) & year>=1941, stats(mean sd n min max) col(s)


