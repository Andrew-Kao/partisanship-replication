/*

	BUILD THE MAIN PANEL

*/

global runOld = 0

// cd "/Users/AndrewKao/Documents/College/3rd Yr/Econometrics/partisanship/build/"

if $runOld == 1{
/**

	1: governers
	Create a panel where each observation represents an election for governer, with voteShare = Democrat/(Democrat + Republican) votes
	Exception handling -> when electionType != G, when month != 11 or 99
	Note that two data sources are used for this part
	
**/


* source: https://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/2/datadocumentation

import delim "raw/ICPSR_00002 2/DS0001/state_data_label.csv", clear  // note this is the output of SPSS syntax

rename   (ïv1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13) (candNumber source year state office congresssionalDist asterisk blank voteTotal month electionType partyN candName)

keep if office == "Governor"
keep if partyN == 100 | party == 200

gen party = "Democrat" if partyN == 100
replace party = "Republican" if partyN == 200
drop partyN

replace year = year + 1000
keep if year >= 1941

drop source congresssionalDist asterisk blank candName candNumber office

bys year state: gen uniques = _N
drop if uniques > 2  // some elections are weird i.e. Louisiana 1975 where 6 Democratic candidates run in the general election for democrats

egen election = group(year state)
bys election: egen votes = sum(voteTotal)
gen voteShare = voteTotal/votes
keep if voteShare >= .5
replace voteShare = 1 - voteShare if party == "Republican"   // 55% of all governers are Democrat

drop votes party voteTotal uniques election

save "data/governers", replace


* source: http://library.cqpress.com/elections/download-data.php

tempfile newgoverners
save `newgoverners'
forv year = 1991/2017 {
import delim "raw/congressQuarterly/export_`year'.csv", clear

drop if _n <= 3
gen lRow = 1 if v1 == "CensusPopAll"
drop if lRow[_n+1] == 1
carryforward lRow, replace
drop if lRow ==1

rename (v5 v21)  (state voteShare)
keep state voteShare
gen year = `year'

append using `newgoverners', force
tempfile newgoverners
save `newgoverners'

}

destring voteShare, replace

append using "data/governers"

drop if missing(voteShare)

save "data/governers", replace


/*

	2: ideology
	DW-Nominate scores are used

*/

* source: https://legacy.voteview.com/dwnomin.htm

use "raw/dwNominate/HL01113D21_BSSE", clear

gen year = 1787 + 2 * cong // first year of congress
keep if year >= 1941
bys cong: egen congressIdeology = mean(dwnom1)
bys year: gen unique = _n
keep if unique == 1
keep year congressIdeology

save "data/ideology", replace

}




set more off

clear
quietly infix              ///
  int     year      1-4    ///
  byte    datanum   5-6    ///
  double  serial    7-14   ///
  double  cbserial  15-27  ///
  double  hhwt      28-37  ///
  byte    stateicp  38-39  ///
  byte    gq        40-40  ///
  int     pernum    41-44  ///
  double  perwt     45-54  ///
  int     age       55-57  ///
  byte    race      58-58  ///
  int     raced     59-61  ///
  using `"raw/ipums/usa_00001.dat"'

replace hhwt     = hhwt     / 100
replace perwt    = perwt    / 100

format serial   %8.0g
format cbserial %13.0g
format hhwt     %10.2f
format perwt    %10.2f

label var year     `"Census year"'
label var datanum  `"Data set number"'
label var serial   `"Household serial number"'
label var cbserial `"Original Census Bureau household serial number"'
label var hhwt     `"Household weight"'
label var stateicp `"State (ICPSR code)"'
label var gq       `"Group quarters status"'
label var pernum   `"Person number in sample unit"'
label var perwt    `"Person weight"'
label var age      `"Age"'
label var race     `"Race [general version]"'
label var raced    `"Race [detailed version]"'

label define year_lbl 1850 `"1850"'
label define year_lbl 1860 `"1860"', add
label define year_lbl 1870 `"1870"', add
label define year_lbl 1880 `"1880"', add
label define year_lbl 1900 `"1900"', add
label define year_lbl 1910 `"1910"', add
label define year_lbl 1920 `"1920"', add
label define year_lbl 1930 `"1930"', add
label define year_lbl 1940 `"1940"', add
label define year_lbl 1950 `"1950"', add
label define year_lbl 1960 `"1960"', add
label define year_lbl 1970 `"1970"', add
label define year_lbl 1980 `"1980"', add
label define year_lbl 1990 `"1990"', add
label define year_lbl 2000 `"2000"', add
label define year_lbl 2001 `"2001"', add
label define year_lbl 2002 `"2002"', add
label define year_lbl 2003 `"2003"', add
label define year_lbl 2004 `"2004"', add
label define year_lbl 2005 `"2005"', add
label define year_lbl 2006 `"2006"', add
label define year_lbl 2007 `"2007"', add
label define year_lbl 2008 `"2008"', add
label define year_lbl 2009 `"2009"', add
label define year_lbl 2010 `"2010"', add
label define year_lbl 2011 `"2011"', add
label define year_lbl 2012 `"2012"', add
label define year_lbl 2013 `"2013"', add
label define year_lbl 2014 `"2014"', add
label define year_lbl 2015 `"2015"', add
label define year_lbl 2016 `"2016"', add
label values year year_lbl

label define stateicp_lbl 01 `"Connecticut"'
label define stateicp_lbl 02 `"Maine"', add
label define stateicp_lbl 03 `"Massachusetts"', add
label define stateicp_lbl 04 `"New Hampshire"', add
label define stateicp_lbl 05 `"Rhode Island"', add
label define stateicp_lbl 06 `"Vermont"', add
label define stateicp_lbl 11 `"Delaware"', add
label define stateicp_lbl 12 `"New Jersey"', add
label define stateicp_lbl 13 `"New York"', add
label define stateicp_lbl 14 `"Pennsylvania"', add
label define stateicp_lbl 21 `"Illinois"', add
label define stateicp_lbl 22 `"Indiana"', add
label define stateicp_lbl 23 `"Michigan"', add
label define stateicp_lbl 24 `"Ohio"', add
label define stateicp_lbl 25 `"Wisconsin"', add
label define stateicp_lbl 31 `"Iowa"', add
label define stateicp_lbl 32 `"Kansas"', add
label define stateicp_lbl 33 `"Minnesota"', add
label define stateicp_lbl 34 `"Missouri"', add
label define stateicp_lbl 35 `"Nebraska"', add
label define stateicp_lbl 36 `"North Dakota"', add
label define stateicp_lbl 37 `"South Dakota"', add
label define stateicp_lbl 40 `"Virginia"', add
label define stateicp_lbl 41 `"Alabama"', add
label define stateicp_lbl 42 `"Arkansas"', add
label define stateicp_lbl 43 `"Florida"', add
label define stateicp_lbl 44 `"Georgia"', add
label define stateicp_lbl 45 `"Louisiana"', add
label define stateicp_lbl 46 `"Mississippi"', add
label define stateicp_lbl 47 `"North Carolina"', add
label define stateicp_lbl 48 `"South Carolina"', add
label define stateicp_lbl 49 `"Texas"', add
label define stateicp_lbl 51 `"Kentucky"', add
label define stateicp_lbl 52 `"Maryland"', add
label define stateicp_lbl 53 `"Oklahoma"', add
label define stateicp_lbl 54 `"Tennessee"', add
label define stateicp_lbl 56 `"West Virginia"', add
label define stateicp_lbl 61 `"Arizona"', add
label define stateicp_lbl 62 `"Colorado"', add
label define stateicp_lbl 63 `"Idaho"', add
label define stateicp_lbl 64 `"Montana"', add
label define stateicp_lbl 65 `"Nevada"', add
label define stateicp_lbl 66 `"New Mexico"', add
label define stateicp_lbl 67 `"Utah"', add
label define stateicp_lbl 68 `"Wyoming"', add
label define stateicp_lbl 71 `"California"', add
label define stateicp_lbl 72 `"Oregon"', add
label define stateicp_lbl 73 `"Washington"', add
label define stateicp_lbl 81 `"Alaska"', add
label define stateicp_lbl 82 `"Hawaii"', add
label define stateicp_lbl 83 `"Puerto Rico"', add
label define stateicp_lbl 96 `"State groupings (1980 Urban/rural sample)"', add
label define stateicp_lbl 97 `"Military/Mil. Reservations"', add
label define stateicp_lbl 98 `"District of Columbia"', add
label define stateicp_lbl 99 `"State not identified"', add
label values stateicp stateicp_lbl

label define gq_lbl 0 `"Vacant unit"'
label define gq_lbl 1 `"Households under 1970 definition"', add
label define gq_lbl 2 `"Additional households under 1990 definition"', add
label define gq_lbl 3 `"Group quarters--Institutions"', add
label define gq_lbl 4 `"Other group quarters"', add
label define gq_lbl 5 `"Additional households under 2000 definition"', add
label define gq_lbl 6 `"Fragment"', add
label values gq gq_lbl

label define age_lbl 000 `"Less than 1 year old"'
label define age_lbl 001 `"1"', add
label define age_lbl 002 `"2"', add
label define age_lbl 003 `"3"', add
label define age_lbl 004 `"4"', add
label define age_lbl 005 `"5"', add
label define age_lbl 006 `"6"', add
label define age_lbl 007 `"7"', add
label define age_lbl 008 `"8"', add
label define age_lbl 009 `"9"', add
label define age_lbl 010 `"10"', add
label define age_lbl 011 `"11"', add
label define age_lbl 012 `"12"', add
label define age_lbl 013 `"13"', add
label define age_lbl 014 `"14"', add
label define age_lbl 015 `"15"', add
label define age_lbl 016 `"16"', add
label define age_lbl 017 `"17"', add
label define age_lbl 018 `"18"', add
label define age_lbl 019 `"19"', add
label define age_lbl 020 `"20"', add
label define age_lbl 021 `"21"', add
label define age_lbl 022 `"22"', add
label define age_lbl 023 `"23"', add
label define age_lbl 024 `"24"', add
label define age_lbl 025 `"25"', add
label define age_lbl 026 `"26"', add
label define age_lbl 027 `"27"', add
label define age_lbl 028 `"28"', add
label define age_lbl 029 `"29"', add
label define age_lbl 030 `"30"', add
label define age_lbl 031 `"31"', add
label define age_lbl 032 `"32"', add
label define age_lbl 033 `"33"', add
label define age_lbl 034 `"34"', add
label define age_lbl 035 `"35"', add
label define age_lbl 036 `"36"', add
label define age_lbl 037 `"37"', add
label define age_lbl 038 `"38"', add
label define age_lbl 039 `"39"', add
label define age_lbl 040 `"40"', add
label define age_lbl 041 `"41"', add
label define age_lbl 042 `"42"', add
label define age_lbl 043 `"43"', add
label define age_lbl 044 `"44"', add
label define age_lbl 045 `"45"', add
label define age_lbl 046 `"46"', add
label define age_lbl 047 `"47"', add
label define age_lbl 048 `"48"', add
label define age_lbl 049 `"49"', add
label define age_lbl 050 `"50"', add
label define age_lbl 051 `"51"', add
label define age_lbl 052 `"52"', add
label define age_lbl 053 `"53"', add
label define age_lbl 054 `"54"', add
label define age_lbl 055 `"55"', add
label define age_lbl 056 `"56"', add
label define age_lbl 057 `"57"', add
label define age_lbl 058 `"58"', add
label define age_lbl 059 `"59"', add
label define age_lbl 060 `"60"', add
label define age_lbl 061 `"61"', add
label define age_lbl 062 `"62"', add
label define age_lbl 063 `"63"', add
label define age_lbl 064 `"64"', add
label define age_lbl 065 `"65"', add
label define age_lbl 066 `"66"', add
label define age_lbl 067 `"67"', add
label define age_lbl 068 `"68"', add
label define age_lbl 069 `"69"', add
label define age_lbl 070 `"70"', add
label define age_lbl 071 `"71"', add
label define age_lbl 072 `"72"', add
label define age_lbl 073 `"73"', add
label define age_lbl 074 `"74"', add
label define age_lbl 075 `"75"', add
label define age_lbl 076 `"76"', add
label define age_lbl 077 `"77"', add
label define age_lbl 078 `"78"', add
label define age_lbl 079 `"79"', add
label define age_lbl 080 `"80"', add
label define age_lbl 081 `"81"', add
label define age_lbl 082 `"82"', add
label define age_lbl 083 `"83"', add
label define age_lbl 084 `"84"', add
label define age_lbl 085 `"85"', add
label define age_lbl 086 `"86"', add
label define age_lbl 087 `"87"', add
label define age_lbl 088 `"88"', add
label define age_lbl 089 `"89"', add
label define age_lbl 090 `"90 (90+ in 1980 and 1990)"', add
label define age_lbl 091 `"91"', add
label define age_lbl 092 `"92"', add
label define age_lbl 093 `"93"', add
label define age_lbl 094 `"94"', add
label define age_lbl 095 `"95"', add
label define age_lbl 096 `"96"', add
label define age_lbl 097 `"97"', add
label define age_lbl 098 `"98"', add
label define age_lbl 099 `"99"', add
label define age_lbl 100 `"100 (100+ in 1960-1970)"', add
label define age_lbl 101 `"101"', add
label define age_lbl 102 `"102"', add
label define age_lbl 103 `"103"', add
label define age_lbl 104 `"104"', add
label define age_lbl 105 `"105"', add
label define age_lbl 106 `"106"', add
label define age_lbl 107 `"107"', add
label define age_lbl 108 `"108"', add
label define age_lbl 109 `"109"', add
label define age_lbl 110 `"110"', add
label define age_lbl 111 `"111"', add
label define age_lbl 112 `"112 (112+ in the 1980 internal data)"', add
label define age_lbl 113 `"113"', add
label define age_lbl 114 `"114"', add
label define age_lbl 115 `"115 (115+ in the 1990 internal data)"', add
label define age_lbl 116 `"116"', add
label define age_lbl 117 `"117"', add
label define age_lbl 118 `"118"', add
label define age_lbl 119 `"119"', add
label define age_lbl 120 `"120"', add
label define age_lbl 121 `"121"', add
label define age_lbl 122 `"122"', add
label define age_lbl 123 `"123"', add
label define age_lbl 124 `"124"', add
label define age_lbl 125 `"125"', add
label define age_lbl 126 `"126"', add
label define age_lbl 129 `"129"', add
label define age_lbl 130 `"130"', add
label define age_lbl 135 `"135"', add
label values age age_lbl

label define race_lbl 1 `"White"'
label define race_lbl 2 `"Black/African American/Negro"', add
label define race_lbl 3 `"American Indian or Alaska Native"', add
label define race_lbl 4 `"Chinese"', add
label define race_lbl 5 `"Japanese"', add
label define race_lbl 6 `"Other Asian or Pacific Islander"', add
label define race_lbl 7 `"Other race, nec"', add
label define race_lbl 8 `"Two major races"', add
label define race_lbl 9 `"Three or more major races"', add
label values race race_lbl

label define raced_lbl 100 `"White"'
label define raced_lbl 110 `"Spanish write_in"', add
label define raced_lbl 120 `"Blank (white) (1850)"', add
label define raced_lbl 130 `"Portuguese"', add
label define raced_lbl 140 `"Mexican (1930)"', add
label define raced_lbl 150 `"Puerto Rican (1910 Hawaii)"', add
label define raced_lbl 200 `"Black/African American/Negro"', add
label define raced_lbl 210 `"Mulatto"', add
label define raced_lbl 300 `"American Indian/Alaska Native"', add
label define raced_lbl 302 `"Apache"', add
label define raced_lbl 303 `"Blackfoot"', add
label define raced_lbl 304 `"Cherokee"', add
label define raced_lbl 305 `"Cheyenne"', add
label define raced_lbl 306 `"Chickasaw"', add
label define raced_lbl 307 `"Chippewa"', add
label define raced_lbl 308 `"Choctaw"', add
label define raced_lbl 309 `"Comanche"', add
label define raced_lbl 310 `"Creek"', add
label define raced_lbl 311 `"Crow"', add
label define raced_lbl 312 `"Iroquois"', add
label define raced_lbl 313 `"Kiowa"', add
label define raced_lbl 314 `"Lumbee"', add
label define raced_lbl 315 `"Navajo"', add
label define raced_lbl 316 `"Osage"', add
label define raced_lbl 317 `"Paiute"', add
label define raced_lbl 318 `"Pima"', add
label define raced_lbl 319 `"Potawatomi"', add
label define raced_lbl 320 `"Pueblo"', add
label define raced_lbl 321 `"Seminole"', add
label define raced_lbl 322 `"Shoshone"', add
label define raced_lbl 323 `"Sioux"', add
label define raced_lbl 324 `"Tlingit (Tlingit_Haida, 2000/ACS)"', add
label define raced_lbl 325 `"Tohono O Odham"', add
label define raced_lbl 326 `"All other tribes (1990)"', add
label define raced_lbl 328 `"Hopi"', add
label define raced_lbl 329 `"Central American Indian"', add
label define raced_lbl 330 `"Spanish American Indian"', add
label define raced_lbl 350 `"Delaware"', add
label define raced_lbl 351 `"Latin American Indian"', add
label define raced_lbl 352 `"Puget Sound Salish"', add
label define raced_lbl 353 `"Yakama"', add
label define raced_lbl 354 `"Yaqui"', add
label define raced_lbl 355 `"Colville"', add
label define raced_lbl 356 `"Houma"', add
label define raced_lbl 357 `"Menominee"', add
label define raced_lbl 358 `"Yuman"', add
label define raced_lbl 359 `"South American Indian"', add
label define raced_lbl 360 `"Mexican American Indian"', add
label define raced_lbl 361 `"Other Amer. Indian tribe (2000,ACS)"', add
label define raced_lbl 362 `"2+ Amer. Indian tribes (2000,ACS)"', add
label define raced_lbl 370 `"Alaskan Athabaskan"', add
label define raced_lbl 371 `"Aleut"', add
label define raced_lbl 372 `"Eskimo"', add
label define raced_lbl 373 `"Alaskan mixed"', add
label define raced_lbl 374 `"Inupiat"', add
label define raced_lbl 375 `"Yup'ik"', add
label define raced_lbl 379 `"Other Alaska Native tribe(s) (2000,ACS)"', add
label define raced_lbl 398 `"Both Am. Ind. and Alaska Native (2000,ACS)"', add
label define raced_lbl 399 `"Tribe not specified"', add
label define raced_lbl 400 `"Chinese"', add
label define raced_lbl 410 `"Taiwanese"', add
label define raced_lbl 420 `"Chinese and Taiwanese"', add
label define raced_lbl 500 `"Japanese"', add
label define raced_lbl 600 `"Filipino"', add
label define raced_lbl 610 `"Asian Indian (Hindu 1920_1940)"', add
label define raced_lbl 620 `"Korean"', add
label define raced_lbl 630 `"Hawaiian"', add
label define raced_lbl 631 `"Hawaiian and Asian (1900,1920)"', add
label define raced_lbl 632 `"Hawaiian and European (1900,1920)"', add
label define raced_lbl 634 `"Hawaiian mixed"', add
label define raced_lbl 640 `"Vietnamese"', add
label define raced_lbl 641 `"Bhutanese"', add
label define raced_lbl 642 `"Mongolian"', add
label define raced_lbl 643 `"Nepalese"', add
label define raced_lbl 650 `"Other Asian or Pacific Islander (1920,1980)"', add
label define raced_lbl 651 `"Asian only (CPS)"', add
label define raced_lbl 652 `"Pacific Islander only (CPS)"', add
label define raced_lbl 653 `"Asian or Pacific Islander, n.s. (1990 Internal Census files)"', add
label define raced_lbl 660 `"Cambodian"', add
label define raced_lbl 661 `"Hmong"', add
label define raced_lbl 662 `"Laotian"', add
label define raced_lbl 663 `"Thai"', add
label define raced_lbl 664 `"Bangladeshi"', add
label define raced_lbl 665 `"Burmese"', add
label define raced_lbl 666 `"Indonesian"', add
label define raced_lbl 667 `"Malaysian"', add
label define raced_lbl 668 `"Okinawan"', add
label define raced_lbl 669 `"Pakistani"', add
label define raced_lbl 670 `"Sri Lankan"', add
label define raced_lbl 671 `"Other Asian, n.e.c."', add
label define raced_lbl 672 `"Asian, not specified"', add
label define raced_lbl 673 `"Chinese and Japanese"', add
label define raced_lbl 674 `"Chinese and Filipino"', add
label define raced_lbl 675 `"Chinese and Vietnamese"', add
label define raced_lbl 676 `"Chinese and Asian write_in"', add
label define raced_lbl 677 `"Japanese and Filipino"', add
label define raced_lbl 678 `"Asian Indian and Asian write_in"', add
label define raced_lbl 679 `"Other Asian race combinations"', add
label define raced_lbl 680 `"Samoan"', add
label define raced_lbl 681 `"Tahitian"', add
label define raced_lbl 682 `"Tongan"', add
label define raced_lbl 683 `"Other Polynesian (1990)"', add
label define raced_lbl 684 `"1+ other Polynesian races (2000,ACS)"', add
label define raced_lbl 685 `"Guamanian/Chamorro"', add
label define raced_lbl 686 `"Northern Mariana Islander"', add
label define raced_lbl 687 `"Palauan"', add
label define raced_lbl 688 `"Other Micronesian (1990)"', add
label define raced_lbl 689 `"1+ other Micronesian races (2000,ACS)"', add
label define raced_lbl 690 `"Fijian"', add
label define raced_lbl 691 `"Other Melanesian (1990)"', add
label define raced_lbl 692 `"1+ other Melanesian races (2000,ACS)"', add
label define raced_lbl 698 `"2+ PI races from 2+ PI regions"', add
label define raced_lbl 699 `"Pacific Islander, n.s."', add
label define raced_lbl 700 `"Other race, n.e.c."', add
label define raced_lbl 801 `"White and Black"', add
label define raced_lbl 802 `"White and AIAN"', add
label define raced_lbl 810 `"White and Asian"', add
label define raced_lbl 811 `"White and Chinese"', add
label define raced_lbl 812 `"White and Japanese"', add
label define raced_lbl 813 `"White and Filipino"', add
label define raced_lbl 814 `"White and Asian Indian"', add
label define raced_lbl 815 `"White and Korean"', add
label define raced_lbl 816 `"White and Vietnamese"', add
label define raced_lbl 817 `"White and Asian write_in"', add
label define raced_lbl 818 `"White and other Asian race(s)"', add
label define raced_lbl 819 `"White and two or more Asian groups"', add
label define raced_lbl 820 `"White and PI"', add
label define raced_lbl 821 `"White and Native Hawaiian"', add
label define raced_lbl 822 `"White and Samoan"', add
label define raced_lbl 823 `"White and Guamanian"', add
label define raced_lbl 824 `"White and PI write_in"', add
label define raced_lbl 825 `"White and other PI race(s)"', add
label define raced_lbl 826 `"White and other race write_in"', add
label define raced_lbl 827 `"White and other race, n.e.c."', add
label define raced_lbl 830 `"Black and AIAN"', add
label define raced_lbl 831 `"Black and Asian"', add
label define raced_lbl 832 `"Black and Chinese"', add
label define raced_lbl 833 `"Black and Japanese"', add
label define raced_lbl 834 `"Black and Filipino"', add
label define raced_lbl 835 `"Black and Asian Indian"', add
label define raced_lbl 836 `"Black and Korean"', add
label define raced_lbl 837 `"Black and Asian write_in"', add
label define raced_lbl 838 `"Black and other Asian race(s)"', add
label define raced_lbl 840 `"Black and PI"', add
label define raced_lbl 841 `"Black and PI write_in"', add
label define raced_lbl 842 `"Black and other PI race(s)"', add
label define raced_lbl 845 `"Black and other race write_in"', add
label define raced_lbl 850 `"AIAN and Asian"', add
label define raced_lbl 851 `"AIAN and Filipino (2000 1%)"', add
label define raced_lbl 852 `"AIAN and Asian Indian"', add
label define raced_lbl 853 `"AIAN and Asian write_in (2000 1%)"', add
label define raced_lbl 854 `"AIAN and other Asian race(s)"', add
label define raced_lbl 855 `"AIAN and PI"', add
label define raced_lbl 856 `"AIAN and other race write_in"', add
label define raced_lbl 860 `"Asian and PI"', add
label define raced_lbl 861 `"Chinese and Hawaiian"', add
label define raced_lbl 862 `"Chinese, Filipino, Hawaiian (2000 1%)"', add
label define raced_lbl 863 `"Japanese and Hawaiian (2000 1%)"', add
label define raced_lbl 864 `"Filipino and Hawaiian"', add
label define raced_lbl 865 `"Filipino and PI write_in"', add
label define raced_lbl 866 `"Asian Indian and PI write_in (2000 1%)"', add
label define raced_lbl 867 `"Asian write_in and PI write_in"', add
label define raced_lbl 868 `"Other Asian race(s) and PI race(s)"', add
label define raced_lbl 869 `"Japanese and Korean (ACS)"', add
label define raced_lbl 880 `"Asian and other race write_in"', add
label define raced_lbl 881 `"Chinese and other race write_in"', add
label define raced_lbl 882 `"Japanese and other race write_in"', add
label define raced_lbl 883 `"Filipino and other race write_in"', add
label define raced_lbl 884 `"Asian Indian and other race write_in"', add
label define raced_lbl 885 `"Asian write_in and other race write_in"', add
label define raced_lbl 886 `"Other Asian race(s) and other race write_in"', add
label define raced_lbl 887 `"Chinese and Korean"', add
label define raced_lbl 890 `"PI and other race write_in:"', add
label define raced_lbl 891 `"PI write_in and other race write_in"', add
label define raced_lbl 892 `"Other PI race(s) and other race write_in"', add
label define raced_lbl 893 `"Native Hawaiian or PI other race(s)"', add
label define raced_lbl 899 `"API and other race write_in"', add
label define raced_lbl 901 `"White, Black, AIAN"', add
label define raced_lbl 902 `"White, Black, Asian"', add
label define raced_lbl 903 `"White, Black, PI"', add
label define raced_lbl 904 `"White, Black, other race write_in"', add
label define raced_lbl 905 `"White, AIAN, Asian"', add
label define raced_lbl 906 `"White, AIAN, PI"', add
label define raced_lbl 907 `"White, AIAN, other race write_in"', add
label define raced_lbl 910 `"White, Asian, PI"', add
label define raced_lbl 911 `"White, Chinese, Hawaiian"', add
label define raced_lbl 912 `"White, Chinese, Filipino, Hawaiian (2000 1%)"', add
label define raced_lbl 913 `"White, Japanese, Hawaiian (2000 1%)"', add
label define raced_lbl 914 `"White, Filipino, Hawaiian"', add
label define raced_lbl 915 `"Other White, Asian race(s), PI race(s)"', add
label define raced_lbl 916 `"White, AIAN and Filipino"', add
label define raced_lbl 917 `"White, Black, and Filipino"', add
label define raced_lbl 920 `"White, Asian, other race write_in"', add
label define raced_lbl 921 `"White, Filipino, other race write_in (2000 1%)"', add
label define raced_lbl 922 `"White, Asian write_in, other race write_in (2000 1%)"', add
label define raced_lbl 923 `"Other White, Asian race(s), other race write_in (2000 1%)"', add
label define raced_lbl 925 `"White, PI, other race write_in"', add
label define raced_lbl 930 `"Black, AIAN, Asian"', add
label define raced_lbl 931 `"Black, AIAN, PI"', add
label define raced_lbl 932 `"Black, AIAN, other race write_in"', add
label define raced_lbl 933 `"Black, Asian, PI"', add
label define raced_lbl 934 `"Black, Asian, other race write_in"', add
label define raced_lbl 935 `"Black, PI, other race write_in"', add
label define raced_lbl 940 `"AIAN, Asian, PI"', add
label define raced_lbl 941 `"AIAN, Asian, other race write_in"', add
label define raced_lbl 942 `"AIAN, PI, other race write_in"', add
label define raced_lbl 943 `"Asian, PI, other race write_in"', add
label define raced_lbl 944 `"Asian (Chinese, Japanese, Korean, Vietnamese); and Native Hawaiian or PI; and Other"', add
label define raced_lbl 949 `"2 or 3 races (CPS)"', add
label define raced_lbl 950 `"White, Black, AIAN, Asian"', add
label define raced_lbl 951 `"White, Black, AIAN, PI"', add
label define raced_lbl 952 `"White, Black, AIAN, other race write_in"', add
label define raced_lbl 953 `"White, Black, Asian, PI"', add
label define raced_lbl 954 `"White, Black, Asian, other race write_in"', add
label define raced_lbl 955 `"White, Black, PI, other race write_in"', add
label define raced_lbl 960 `"White, AIAN, Asian, PI"', add
label define raced_lbl 961 `"White, AIAN, Asian, other race write_in"', add
label define raced_lbl 962 `"White, AIAN, PI, other race write_in"', add
label define raced_lbl 963 `"White, Asian, PI, other race write_in"', add
label define raced_lbl 964 `"White, Chinese, Japanese, Native Hawaiian"', add
label define raced_lbl 970 `"Black, AIAN, Asian, PI"', add
label define raced_lbl 971 `"Black, AIAN, Asian, other race write_in"', add
label define raced_lbl 972 `"Black, AIAN, PI, other race write_in"', add
label define raced_lbl 973 `"Black, Asian, PI, other race write_in"', add
label define raced_lbl 974 `"AIAN, Asian, PI, other race write_in"', add
label define raced_lbl 975 `"AIAN, Asian, PI, Hawaiian other race write_in"', add
label define raced_lbl 976 `"Two specified Asian  (Chinese and other Asian, Chinese and Japanese, Japanese and other Asian, Korean and other Asian); Native Hawaiian/PI; and Other Race"', add
label define raced_lbl 980 `"White, Black, AIAN, Asian, PI"', add
label define raced_lbl 981 `"White, Black, AIAN, Asian, other race write_in"', add
label define raced_lbl 982 `"White, Black, AIAN, PI, other race write_in"', add
label define raced_lbl 983 `"White, Black, Asian, PI, other race write_in"', add
label define raced_lbl 984 `"White, AIAN, Asian, PI, other race write_in"', add
label define raced_lbl 985 `"Black, AIAN, Asian, PI, other race write_in"', add
label define raced_lbl 986 `"Black, AIAN, Asian, PI, Hawaiian, other race write_in"', add
label define raced_lbl 989 `"4 or 5 races (CPS)"', add
label define raced_lbl 990 `"White, Black, AIAN, Asian, PI, other race write_in"', add
label define raced_lbl 991 `"White race; Some other race; Black or African American race and/or American Indian and Alaska Native race and/or Asian groups and/or Native Hawaiian and Other Pacific Islander groups"', add
label define raced_lbl 996 `"2+ races, n.e.c. (CPS)"', add
label values raced raced_lbl

keep if year > 1940

gen under15D = (age < 15)
gen over65D = (age > 65 & !missing(age))
gen blackD = (race == 2)

collapse (count) pop=datanum (sum) under15S=under15D over65S=over65D blackS=blackD , by(year stateicp)

gen under15 = under15S/pop
gen over65 = over65S/pop
gen black = blackS/pop

keep year stateicp under15 over65 black pop

rename stateicp state






