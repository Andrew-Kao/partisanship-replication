/*

	examining and building indices

*/


global dir = "~/Documents/College/3rd Yr/Econometrics/partisanship-replication"
use "$dir/build/data/final_data.dta", clear
drop if year==. | year<1925 | stfips>56 | stfips==.
for num 02 01 05 04 06 08 09 11 10 12 13 15 19 16 17 18 20 21 22 25 24 23 26 27 29 28 30 37 38 31 33 34 35 32 36 39 40 41 42 44 45 46 47 48 49 51 50 53 55 54 56: gen byte yearX=year-1950 if stfips==X \ recode yearX .=0


bysort stfips (year): gen newyear=_n
tsset stfips newyear
replace year=int(year)
gen decade=(int(year/10))*10

for var afdc_reca eitc_s_child1 stax_topr stax_corpr redist atr stemploy unionization poverty_pct unemployment gini gini_pt: replace X=X*100

** PCA by groups
global policies stax_topr stax_corpr redist atr minwage afdc_max stemploy stempavw 
global outcome unionization incrate executions transfers ui afdc_reca stinctax stothertax stnontaxes strevenue
global welfare1 mean_faminc mean_faminc_pt faminc50 famincpt50 employeecomp poverty_pct gini gini_pt 
global welfare2 unemploymentrate naep_read pcrime vcrime mrate psuicide  

pca ${policies}, com(4)
rotate

global outcomes stax_topr stax_corpr redist atr minwage afdc_max stemploy stempavw unionization ///
	incrate executions transfers ui afdc_reca stinctax stothertax stnontaxes strevenue ///
	mean_faminc mean_faminc_pt faminc50 famincpt50 employeecomp poverty_pct gini gini_pt  ///
	unemploymentrate naep_read pcrime vcrime mrate psuicide  
	
pca ${outcomes}, com(4)
rotate 
* 68% explained with 4 factors seems decent

* factor 1 - econ benefits (family income, wages, unionization, anti-unemployment, low tax rates)
* factor 2 - crime/inequality (high incarceration rates and crimes, gini coefficient, lower minimum wage/corporate tax rate)
* factor 3 - worker benefits (high minimum wage, afdc max payment, unemployment, unionization, poverty, corporate tax rate?)  -- this one is confusing
* factor 4 - government size (tax rates on corporate/individuals, amount redistribute/atr, state employment/afdc max, state income tax + revenue)


* without 'duplicate' outcomes
global outcomes stax_topr stax_corpr redist atr minwage afdc_max stemploy stempavw unionization ///
	incrate executions transfers ui afdc_reca stinctax stothertax strevenue ///
	mean_faminc employeecomp poverty_pct gini  ///
	unemploymentrate naep_read pcrime vcrime mrate psuicide  
	
pca ${outcomes}, com(4)
rotate 

* factor 1 - high wages (workers), unionization, tax rates, low poverty, top income tax, state employees, lower suicide
* factor 2 - crime/inequalty (same as above)
* factor 3 - social safety net (high minwage/afdc, unionization, unemployment, top tax rates)
* factor 4 - government size (same as before)


* 3 factors might be more parsimonious
pca ${outcomes}, com(3)
rotate 

* factor 1 - worker benefits/social safety (high minwage/transfers, wages, unionization, large budget, higher family income)
* factor 2 - crime/inequality (high incarceration/crime, poverty, gini, unemployment, low taxes and transfers)
* factor 3 - government size (see above factor 4)
