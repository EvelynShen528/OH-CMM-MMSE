
use "/Users/shenjuntian/Desktop/Oral Health/02 Data cleaning/0626 Dynamic/Dynamic_08/Full_dat08_18_f7_covariances_18_f7_covariances.dta"


*一、提取98longdata里98年份入组的人:
describe id
gen id_str = string(id, "%08.0f")
gen ends_with_08 = substr(id_str, length(id_str)-1, 2) == "08" ///
                   | substr(id_str, length(id_str)-1, 2) == "09"
tab ends_with_08
keep if ends_with_08 == 1
drop id_str
drop ends_with_08 

*二、处理interview year
gen yearin_8 = .
replace yearin_8=2008 if yearin==2008
replace yearin_8=2009 if yearin==2009
label variable yearin_8 "year of the 2008 interview"

rename yearin_11 year_11
gen yearin_11 = .
replace yearin_11=2011 if year_11==2011
replace yearin_11=2012 if year_11==2012
label variable yearin_11 "year of the 2011 interview"



*三、Oral Health
*基线自然牙分类
gen g21_cat = g21
replace g21_cat = 0 if g21 <= 0
replace g21_cat = 1 if g21 > 0 & g21 < 10
replace g21_cat = 2 if g21 >= 10 & g21 <= 19
replace g21_cat = 3 if g21 >= 20
tab g21_cat
order g21_cat, after(g21)
label variable g21_cat "natural teeth divided by four categories"
*把不带假牙的设置为0而不是2，带假牙的继续是1；这样cox逻辑不会有问题
replace g22 =0 if g22 ==2
label define g22label 0 "no" 1 "yes" 9 "missing"
label values g22 g22label
tab g22


* 四.Cardiometabolic Multimorbidity
codebook g15a1 
codebook g15b1
codebook g15b1
codebook g15d1
*以上这步主要是看一下missing和dont`know是不是分别是9和3，不同年份cros可能不一样，下面的代码要灵活调整，不要弄错了
gen temp_hyp = (g15a1 == 1)
gen temp_dia = (g15b1 == 1)
gen temp_hrt = (g15c1 == 1)
gen temp_strk = (g15d1 == 1)
egen cmm = rowtotal(temp_hyp temp_dia temp_hrt temp_strk)
drop temp_hyp temp_dia temp_hrt temp_strk

gen cmm_bi=cmm
replace cmm_bi=0 if cmm < 2
replace cmm_bi=1 if cmm >= 2

replace cmm =. if g15a1 == 9 | g15a1 == 3
replace cmm =. if g15b1 == 9 | g15b1 == 3
replace cmm =. if g15c1 == 9 | g15c1 == 3
replace cmm =. if g15d1 == 9 | g15d1 == 3
replace cmm_bi=. if cmm ==. 

tabulate cmm
label variable cmm "count of cardiometabolic multimorbidity"
*检查cmm不要有超过4的数值
tabulate cmm_bi
label variable cmm_bi "whether has cardiometabolic multimorbidity"
*检查observation总数和cmm要是一样的
****************************新发cmm*************************
///2011////
codebook g15a1_11 
codebook g15b1_11
codebook g15c1_11
codebook g15d1_11
gen temp_hyp_11 = (g15a1_11 == 1)
gen temp_dia_11 = (g15b1_11 == 1)
gen temp_hrt_11 = (g15c1_11 == 1)
gen temp_strk_11 = (g15d1_11 == 1)
egen cmm_11 = rowtotal(temp_hyp_11 temp_dia_11 temp_hrt_11 temp_strk_11)
drop temp_hyp_11 temp_dia_11 temp_hrt_11 temp_strk_11

gen cmm_bi_11=cmm_11
replace cmm_bi_11=0 if cmm_11 < 2
replace cmm_bi_11=1 if cmm_11 >= 2

replace cmm_11 =. if g15a1_11 == 9 | g15a1_11 == 3 | g15a1_11 == . | g15a1_11 == 8
replace cmm_11 =. if g15b1_11 == 9 | g15b1_11 == 3 | g15b1_11 == . | g15b1_11 == 8
replace cmm_11 =. if g15c1_11 == 9 | g15c1_11 == 3 | g15c1_11 == . | g15c1_11 == 8
replace cmm_11 =. if g15d1_11 == 9 | g15d1_11 == 3 | g15d1_11 == . | g15d1_11 == 8
replace cmm_bi_11 =. if cmm_11 ==. 
///2014////
codebook g15a1_14 
codebook g15b1_14
codebook g15c1_14
codebook g15d1_14
gen temp_hyp_14 = (g15a1_14 == 1)
gen temp_dia_14 = (g15b1_14 == 1)
gen temp_hrt_14 = (g15c1_14 == 1)
gen temp_strk_14 = (g15d1_14 == 1)
egen cmm_14 = rowtotal(temp_hyp_14 temp_dia_14 temp_hrt_14 temp_strk_14)
drop temp_hyp_14 temp_dia_14 temp_hrt_14 temp_strk_14

gen cmm_bi_14=cmm_14
replace cmm_bi_14=0 if cmm_14 < 2
replace cmm_bi_14=1 if cmm_14 >= 2

replace cmm_14 =. if g15a1_14 == 9 | g15a1_14 == 3 | g15a1_14 == . | g15a1_14 == 8
replace cmm_14 =. if g15b1_14 == 9 | g15b1_14 == 3 | g15b1_14 == . | g15b1_14 == 8
replace cmm_14 =. if g15c1_14 == 9 | g15c1_14 == 3 | g15c1_14 == . | g15c1_14 == 8
replace cmm_14 =. if g15d1_14 == 9 | g15d1_14 == 3 | g15d1_14 == . | g15d1_14 == 8
replace cmm_bi_14 =. if cmm_14 ==. 
///2018////
codebook g15a1_18 
codebook g15b1_18
codebook g15c1_18
codebook g15d1_18
gen temp_hyp_18 = (g15a1_18 == 1)
gen temp_dia_18 = (g15b1_18 == 1)
gen temp_hrt_18 = (g15c1_18 == 1)
gen temp_strk_18 = (g15d1_18 == 1)
egen cmm_18 = rowtotal(temp_hyp_18 temp_dia_18 temp_hrt_18 temp_strk_18)
drop temp_hyp_18 temp_dia_18 temp_hrt_18 temp_strk_18

gen cmm_bi_18=cmm_18
replace cmm_bi_18=0 if cmm_18 < 2
replace cmm_bi_18=1 if cmm_18 >= 2

replace cmm_18 =. if g15a1_18 == 9 | g15a1_18 == 3 | g15a1_18 == . | g15a1_18 == 8
replace cmm_18 =. if g15b1_18 == 9 | g15b1_18 == 3 | g15b1_18 == . | g15b1_18 == 8
replace cmm_18 =. if g15c1_18 == 9 | g15c1_18 == 3 | g15c1_18 == . | g15c1_18 == 8
replace cmm_18 =. if g15d1_18 == 9 | g15d1_18 == 3 | g15d1_18 == . | g15d1_18 == 8
replace cmm_bi_18 =. if cmm_18 ==. 
///新发cmm统计////
gen cmm_new = .
replace cmm_new = 1 if cmm_bi_11 == 1 | cmm_bi_14 == 1 | cmm_bi_18 == 1
replace cmm_new = 0 if  cmm_new ==.
tabulate cmm_new

* 五.MMSE
rename mmse mmse_f0
**************************2008年******************************
* Step 1: set missing row less than 10
gen byte mis_c16 = (c16 == 99 | c16 == 88)
foreach var in c11 c12 c13 c14 c15 c21a c21b c21c c31a c31b c31c c31d c31e c32 c41a c41b c41c c51a c51b c52 c53a c53b c53c {
  gen byte mis_`var' = (`var' == 9 | `var' == 8)
}
egen total_mis_dontknow = rowtotal(mis_*)
replace c16 = 0 if total_mis_dontknow <=10 & c16==99
replace c16 = 0 if total_mis_dontknow <=10 & c16==88
foreach var in c11 c12 c13 c14 c15 c21a c21b c21c c31a c31b c31c c31d c31e c32 c41a c41b c41c c51a c51b c52 c53a c53b c53c {
  replace `var' = 0 if total_mis_dontknow <=10 & inlist(`var', 8, 9)
}
* Step 2: Generate m1 variable without deleting any data
gen m1 = . 
replace m1 = 0 if c16==88
replace m1 = . if c16==99
replace m1 = . if c16<0
replace m1 = 7 if c16 >= 7 
replace m1 = c16 if c16 < 7 & c16 >= 0
tab m1
* Step 3: Generate m2 variable without deleting any data
foreach var in c11 c12 c13 c14 c15 c21a c21b c21c c31a c31b c31c c31d c31e c32 c41a c41b c41c c51a c51b c52 c53a c53b c53c {
    replace `var' = 0 if `var' == 8
    replace `var' = . if `var' < 0
    replace `var' = . if `var' == 9
}
gen m2 = c11 + c12 + c13 + c14 + c15 + c21a + c21b + c21c + c31a + c31b + c31c + c31d + c31e + c32 + c41a + c41b + c41c + c51a + c51b + c52 + c53a + c53b + c53c 
tab m2
* Step 4: Generate mmse variable and keep those with missing less than 10
gen mmse = m1 + m2

drop  mis_* total_mis_dontknow m1 m2
tab mmse
* Step 5: Generate mmse_bi variable without deleting any data
* Generate mmse binary variable with cut off point as 18
gen mmse_by18 = mmse
replace mmse_by18 = 1 if mmse < 18
replace mmse_by18 = 0 if mmse >= 18
replace mmse_by18 = . if mmse == .
* Generate mmse binary variable with cut off point as 20
gen mmse_by20 = mmse
replace mmse_by20 = 1 if mmse < 20
replace mmse_by20 = 0 if mmse >= 20
replace mmse_by20 = . if mmse == .
* Generate mmse binary variable with cut off point as 24
gen mmse_by24 = mmse
replace mmse_by24 = 1 if mmse < 24
replace mmse_by24 = 0 if mmse >= 24
replace mmse_by24 = . if mmse == .
* Generate mmse binary variable according to the educational level. 
gen mmse_edu = mmse
replace mmse_byedu = 1 if edug == 1 & mmse < 19
replace mmse_byedu = 0 if edug == 1 & mmse >= 19  ///without education
replace mmse_byedu = 1 if edug == 2 & mmse < 22
replace mmse_byedu = 0 if edug == 2 & mmse >= 22  ///primary school (6 yrs)
replace mmse_byedu = 1 if edug == 3 & mmse < 26
replace mmse_byedu = 0 if edug == 3 & mmse >= 26 & mmse <= 28  ///middle school or higher (>6 yrs)
* Generate mmse quaternary variable, classified as no (MMSE score: 25–30), mild (18–24), moderate (10–17), and severe (0–9)
gen mmse_quat = mmse
replace mmse_quat = 0 if mmse >= 25
replace mmse_quat = 1 if mmse >= 18 & mmse <= 24
replace mmse_quat = 2 if mmse >= 10 & mmse <=17
replace mmse_quat = 3 if mmse >= 0 & mmse <= 9

*检查不要有超过30的数值，超过了要检查代码重新计算，不可以直接剔除>99的
tabulate mmse_by18
tabulate mmse_by20
tabulate mmse_by24
tabulate mmse_byedu
tabulate mmse_quat
**************************2011年******************************
* Step 1: set missing row less than 10
gen byte mis_c16_11 = (c16_11 == 99 | c16_11 == 88)
foreach var in c11_11 c12_11 c13_11 c14_11 c15_11 c21a_11 c21b_11 c21c_11 c31a_11 c31b_11 c31c_11 c31d_11 c31e_11 c32_11 c41a_11 c41b_11 c41c_11 c51a_11 c51b_11 c52_11 c53a_11 c53b_11 c53c_11 {
  gen byte mis_`var' = (`var' == 9 | `var' == 8)
}
egen total_mis_dontknow = rowtotal(mis_*)
replace c16_11 = 0 if total_mis_dontknow <=10 & c16_11==99
replace c16_11 = 0 if total_mis_dontknow <=10 & c16_11==88
foreach var in c11_11 c12_11 c13_11 c14_11 c15_11 c21a_11 c21b_11 c21c_11 c31a_11 c31b_11 c31c_11 c31d_11 c31e_11 c32_11 c41a_11 c41b_11 c41c_11 c51a_11 c51b_11 c52_11 c53a_11 c53b_11 c53c_11 {
  replace `var' = 0 if total_mis_dontknow <=10 & inlist(`var', 8, 9)
}
* Step 2: Generate m1 variable without deleting any data
gen m1_11 = . 
replace m1_11 = 0 if c16_11==88
replace m1_11 = . if c16_11==99
replace m1_11 = . if c16_11<0
replace m1_11 = 7 if c16_11 >= 7 
replace m1_11 = c16_11 if c16_11 < 7 & c16_11 >= 0
tab m1_11
* Step 3: Generate m2 variable without deleting any data
foreach var in c11_11 c12_11 c13_11 c14_11 c15_11 c21a_11 c21b_11 c21c_11 c31a_11 c31b_11 c31c_11 c31d_11 c31e_11 c32_11 c41a_11 c41b_11 c41c_11 c51a_11 c51b_11 c52_11 c53a_11 c53b_11 c53c_11 {
    replace `var' = 0 if `var' == 8
    replace `var' = . if `var' < 0
    replace `var' = . if `var' == 9
}
gen m2_11 = c11_11 + c12_11 + c13_11 + c14_11 + c15_11 + c21a_11 + c21b_11 + c21c_11 + c31a_11 + c31b_11 + c31c_11 + c31d_11 + c31e_11 + c32_11 + c41a_11 + c41b_11 + c41c_11 + c51a_11 + c51b_11 + c52_11 + c53a_11 + c53b_11 + c53c_11 
tab m2_11
* Step 4: Generate mmse variable and keep those with missing less than 10
gen mmse_11 = m1_11 + m2_11

drop  mis_* total_mis_dontknow m1_11 m2_11
tab mmse_11
* Step 5: Generate mmse_bi variable without deleting any data
* Generate mmse binary variable with cut off point as 18
gen mmse_by18_11 = mmse_11
replace mmse_by18_11 = 1 if mmse_11 < 18
replace mmse_by18_11 = 0 if mmse_11 >= 18
replace mmse_by18_11 = . if mmse_11 == .
* Generate mmse binary variable with cut off point as 20
gen mmse_by20_11 = mmse_11
replace mmse_by20_11 = 1 if mmse_11 < 20
replace mmse_by20_11 = 0 if mmse_11 >= 20
replace mmse_by20_11 = .  if mmse_11 == .
* Generate mmse binary variable with cut off point as 24
gen mmse_by24_11 = mmse_11
replace mmse_by24_11 = 1 if mmse_11 < 24
replace mmse_by24_11 = 0 if mmse_11 >= 24
replace mmse_by24_11 = .  if mmse_11 == .
* Generate mmse binary variable according to the educational level
gen mmse_byedu = mmse_11
replace mmse_byedu_11 = 1 if edug == 1 & mmse_11 < 19
replace mmse_byedu_11 = 0 if edug == 1 & mmse_11 >= 19  ///without education
replace mmse_byedu_11 = 1 if edug == 2 & mmse_11 < 22
replace mmse_byedu_11 = 0 if edug == 2 & mmse_11 >= 22  ///primary school (6 yrs)
replace mmse_byedu_11 = 1 if edug == 3 & mmse_11 < 26
replace mmse_edu_11 = 0 if edug == 3 & mmse_11 >= 26 & mmse_11 <= 28  ///middle school or higher (>6 yrs)
* Generate mmse quaternary variable, classified as no (MMSE score: 25–30), mild (18–24), moderate (10–17), and severe (0–9)
gen mmse_quat_11 = mmse_11
replace mmse_quat = 0 if mmse_11 >= 25
replace mmse_quat = 1 if mmse_11 >= 18 & mmse_11 <= 24
replace mmse_quat = 2 if mmse_11 >= 10 & mmse_11 <=17
replace mmse_quat = 3 if mmse_11 >= 0 & mmse_11 <= 9

*检查不要有超过30的数值，超过了要检查代码重新计算，不可以直接剔除>99的
tabulate mmse_by18_11
tabulate mmse_by20_11
tabulate mmse_by24_11
tabulate mmse_byedu_11
tabulate mmse_quat_11
**************************2014年******************************
* Step 1: set missing row less than 10
gen byte mis_c16_14 = (c16_14 == 99 | c16_14 == 88)
foreach var in c11_14 c12_14 c13_14 c14_14 c15_14 c21a_14 c21b_14 c21c_14 c31a_14 c31b_14 c31c_14 c31d_14 c31e_14 c32_14 c41a_14 c41b_14 c41c_14 c51a_14 c51b_14 c52_14 c53a_14 c53b_14 c53c_14 {
  gen byte mis_`var' = (`var' == 9 | `var' == 8)
}
egen total_mis_dontknow = rowtotal(mis_*)
replace c16_14 = 0 if total_mis_dontknow <=10 & c16_14==99
replace c16_14 = 0 if total_mis_dontknow <=10 & c16_14==88
foreach var in c11_14 c12_14 c13_14 c14_14 c15_14 c21a_14 c21b_14 c21c_14 c31a_14 c31b_14 c31c_14 c31d_14 c31e_14 c32_14 c41a_14 c41b_14 c41c_14 c51a_14 c51b_14 c52_14 c53a_14 c53b_14 c53c_14 {
  replace `var' = 0 if total_mis_dontknow <=10 & inlist(`var', 8, 9)
}
* Step 2: Generate m1 variable without deleting any data
gen m1_14 = . 
replace m1_14 = 0 if c16_14==88
replace m1_14 = . if c16_14==99
replace m1_14 = . if c16_14<0
replace m1_14 = 7 if c16_14 >= 7 
replace m1_14 = c16_14 if c16_14 < 7 & c16_14 >= 0
tab m1_14
* Step 3: Generate m2 variable without deleting any data
foreach var in c11_14 c12_14 c13_14 c14_14 c15_14 c21a_14 c21b_14 c21c_14 c31a_14 c31b_14 c31c_14 c31d_14 c31e_14 c32_14 c41a_14 c41b_14 c41c_14 c51a_14 c51b_14 c52_14 c53a_14 c53b_14 c53c_14 {
    replace `var' = 0 if `var' == 8
    replace `var' = . if `var' < 0
    replace `var' = . if `var' == 9
}
gen m2_14 = c11_14 + c12_14 + c13_14 + c14_14 + c15_14 + c21a_14 + c21b_14 + c21c_14 + c31a_14 + c31b_14 + c31c_14 + c31d_14 + c31e_14 + c32_14 + c41a_14 + c41b_14 + c41c_14 + c51a_14 + c51b_14 + c52_14 + c53a_14 + c53b_14 + c53c_14 
tab m2_14
* Step 4: Generate mmse variable and keep those with missing less than 10
gen mmse_14 = m1_14 + m2_14

drop  mis_* total_mis_dontknow m1_14 m2_14
tab mmse_14
* Step 5: Generate mmse_bi variable without deleting any data
* Generate mmse binary variable with cut off point as 18
gen mmse_by18_14 = mmse_11_14
replace mmse_by18_14 = 1 if mmse_14 < 18
replace mmse_by18_14 = 0 if mmse_14 >= 18
replace mmse_by18_14 = . if mmse_14 == .
* Generate mmse binary variable with cut off point as 20
gen mmse_by20_14 = mmse_14
replace mmse_by20_14 = 1 if mmse_14 < 20
replace mmse_by20_14 = 0 if mmse_14 >= 20
replace mmse_by20_14 = .  if mmse_14 == .
* Generate mmse binary variable with cut off point as 24
gen mmse_by24_14 = mmse_14
replace mmse_by24_14 = 1 if mmse_14 < 24
replace mmse_by24_14 = 0 if mmse_14 >= 24
replace mmse_by24_14 = .  if mmse_14 == .
* Generate mmse binary variable according to the educational level
gen mmse_byedu_14 = mmse_14
replace mmse_byedu_14 = 1 if edug == 1 & mmse_14 < 19
replace mmse_byedu_14 = 0 if edug == 1 & mmse_14 >= 19  ///without education
replace mmse_byedu_14 = 1 if edug == 2 & mmse_14 < 22
replace mmse_byedu_14 = 0 if edug == 2 & mmse_14 >= 22  ///primary school (6 yrs)
replace mmse_byedu_14 = 1 if edug == 3 & mmse_14 < 26
replace mmse_byedu_14 = 0 if edug == 3 & mmse_14 >= 26 & mmse_14 <= 28  ///middle school or higher (>6 yrs)
* Generate mmse quaternary variable, classified as no (MMSE score: 25–30), mild (18–24), moderate (10–17), and severe (0–9)
gen mmse_quat = mmse_14
replace mmse_quat_14 = 0 if mmse_14 >= 25
replace mmse_quat_14 = 1 if mmse_14 >= 18 & mmse_14 <= 24
replace mmse_quat_14 = 2 if mmse_14 >= 10 & mmse_14 <=17
replace mmse_quat_14 = 3 if mmse_14 >= 0 & mmse_14 <= 9
*检查不要有超过30的数值，超过了要检查代码重新计算，不可以直接剔除>99的
tabulate mmse_by18_14
tabulate mmse_by20_14
tabulate mmse_by24_14
tabulate mmse_byedu_14
tabulate mmse_quat_14
**************************2018年******************************
* Step 1: set missing row less than 10
gen byte mis_c16_18 = (c16_18 == 99 | c16_18 == 88)
foreach var in c11_18 c12_18 c13_18 c14_18 c15_18 c21a_18 c21b_18 c21c_18 c31a_18 c31b_18 c31c_18 c31d_18 c31e_18 c32_18 c41a_18 c41b_18 c41c_18 c51a_18 c51b_18 c52_18 c53a_18 c53b_18 c53c_18 {
  gen byte mis_`var' = (`var' == 9 | `var' == 8)
}
egen total_mis_dontknow = rowtotal(mis_*)
replace c16_18 = 0 if total_mis_dontknow <=10 & c16_18==99
replace c16_18 = 0 if total_mis_dontknow <=10 & c16_18==88
foreach var in c11_18 c12_18 c13_18 c14_18 c15_18 c21a_18 c21b_18 c21c_18 c31a_18 c31b_18 c31c_18 c31d_18 c31e_18 c32_18 c41a_18 c41b_18 c41c_18 c51a_18 c51b_18 c52_18 c53a_18 c53b_18 c53c_18 {
  replace `var' = 0 if total_mis_dontknow <=10 & inlist(`var', 8, 9)
}
* Step 2: Generate m1 variable without deleting any data
gen m1_18 = . 
replace m1_18 = 0 if c16_18==88
replace m1_18 = . if c16_18==99
replace m1_18 = . if c16_18<0
replace m1_18 = 7 if c16_18 >= 7 
replace m1_18 = c16_18 if c16_18 < 7 & c16_18 >= 0
tab m1_18
* Step 3: Generate m2 variable without deleting any data
foreach var in c11_18 c12_18 c13_18 c14_18 c15_18 c21a_18 c21b_18 c21c_18 c31a_18 c31b_18 c31c_18 c31d_18 c31e_18 c32_18 c41a_18 c41b_18 c41c_18 c51a_18 c51b_18 c52_18 c53a_18 c53b_18 c53c_18 {
    replace `var' = 0 if `var' == 8
    replace `var' = . if `var' < 0
    replace `var' = . if `var' == 9
}
gen m2_18 = c11_18 + c12_18 + c13_18 + c14_18 + c15_18 + c21a_18 + c21b_18 + c21c_18 + c31a_18 + c31b_18 + c31c_18 + c31d_18 + c31e_18 + c32_18 + c41a_18 + c41b_18 + c41c_18 + c51a_18 + c51b_18 + c52_18 + c53a_18 + c53b_18 + c53c_18 
tab m2_18
* Step 4: Generate mmse variable and keep those with missing less than 10
gen mmse_18 = m1_18 + m2_18

drop  mis_* total_mis_dontknow m1_18 m2_18
tab mmse_18
* Step 5: Generate mmse_bi variable without deleting any data
* Generate mmse binary variable with cut off point as 18
gen mmse_by18_18 = mmse_18
replace mmse_by18_18 = 1 if mmse_18 < 18
replace mmse_by18_18 = 0 if mmse_18 >= 18
replace mmse_by18_18 = . if mmse_18 == .
* Generate mmse binary variable with cut off point as 20
gen mmse_by20_18 = mmse_18
replace mmse_by20_18 = 1 if mmse_18 < 20
replace mmse_by20_18 = 0 if mmse_18 >= 20
replace mmse_by20_18 = .  if mmse_18 == .
* Generate mmse binary variable with cut off point as 24
gen mmse_by24_18 = mmse_18
replace mmse_by24_18 = 1 if mmse_18 < 24
replace mmse_by24_18 = 0 if mmse_18 >= 24
replace mmse_by24_18 = .  if mmse_18 == .
* Generate mmse binary variable according to the educational level
gen mmse_byedu_18 = mmse_18
replace mmse_byedu_18 = 1 if edug == 1 & mmse_18 < 19
replace mmse_byedu_18 = 0 if edug == 1 & mmse_18 >= 19  ///without education
replace mmse_byedu_18 = 1 if edug == 2 & mmse_18 < 22
replace mmse_byedu_18 = 0 if edug == 2 & mmse_18 >= 22  ///primary school (6 yrs)
replace mmse_byedu_18 = 1 if edug == 3 & mmse_18 < 26
replace mmse_byedu_18 = 0 if edug == 3 & mmse_18 >= 26 & mmse_18 <= 28  ///middle school or higher (>6 yrs)
* Generate mmse quaternary variable, classified as no (MMSE score: 25–30), mild (18–24), moderate (10–17), and severe (0–9)
gen mmse_quat = mmse_18
replace mmse_quat_18 = 0 if mmse_18 >= 25
replace mmse_quat_18 = 1 if mmse_18 >= 18 & mmse_18 <= 24
replace mmse_quat_18 = 2 if mmse_18 >= 10 & mmse_18 <=17
replace mmse_quat_18 = 3 if mmse_18 >= 0 & mmse_18 <= 9
*检查不要有超过30的数值，超过了要检查代码重新计算，不可以直接剔除>99的
tabulate mmse_by18_18
tabulate mmse_by20_18
tabulate mmse_by24_18
tabulate mmse_byedu_18
tabulate mmse_quat_18

* 六.drop
drop if trueage <65
drop if mmse == .
drop if mmse_11 == .
drop if mmse <18
drop if g21 == 99
drop if g21 == 88
drop if g22 == 9
drop if g22 == 8
drop if g21 >32
*针对是否看新发cmm下面这条要灵活选择
drop if cmm == .
drop if cmm_new == .


* 七.计算cox需要的status和livetime,需根据入组年份修改
* Status （98入组那就是从00开始
* Generate Status with mmse cut off point as 18
gen status_18 = .
replace status_by18 = 1 if mmse_by18_11 == 1 | mmse_by18_14 == 1 | mmse_by18_18 == 1
replace status_by18 = 0 if status_18 == .
tabulate status_18
* Generate Status with mmse cut off point as 20
gen status_20 = .
replace status_by20 = 1 if mmse_by20_11 == 1 | mmse_by20_14 == 1 | mmse_by20_18 == 1
replace status_by20 = 0 if status_20 == .
tabulate status_20
* Generate Status with mmse cut off point as 24
gen status_24 = .
replace status_24 = 1 if mmse_24_11 == 1 | mmse_24_14 == 1 | mmse_24_18 == 1
replace status_24 = 0 if status_24 == .
tabulate status_24
* Generate Status with mmse according to educational level
gen status_edu
replace status_edu = 1 if mmse_edu_11 == 1 | mmse_edu_14 == 1 | mmse_edu_18 == 1
replace status_edu = 0 if status_edu == .
tabulate status_edu
* livetime 
* Generate Livetime with mmse cut off point as 18
gen livetime_18 = .
replace livetime_18 = yearin_11 - yearin_8 if mmse_by18 == 0 & mmse_by18_11 == 1
replace livetime_18 = yearin_11 - yearin_8 if mmse_by18 == 0 & mmse_by18_11 == 0 & mmse_by18_14 == .
replace livetime_18 = yearin_14 - yearin_8 if mmse_by18 == 0 & mmse_by18_11 == 0 & mmse_by18_14 == 1
replace livetime_18 = yearin_14 - yearin_8 if mmse_by18 == 0 & mmse_by18_11 == 0 & mmse_by18_14 == 0 & mmse_by18_18 == .
replace livetime_18 = yearin_18 - yearin_8 if mmse_by18 == 0 & mmse_by18_11 == 0 & mmse_by18_14 == 0 & mmse_by18_18 == 1
replace livetime_18 = yearin_18 - yearin_8 if mmse_by18 == 0 & mmse_by18_11 == 0 & mmse_by18_14 == 0 & mmse_by18_18 == 0
tab livetime_18
* Generate Livetime with mmse cut off point as 20
gen livetime_20 = .
replace livetime_20 = yearin_11 - yearin_8 if mmse_by20 == 0 & mmse_by20_11 == 1
replace livetime_20 = yearin_11 - yearin_8 if mmse_by20 == 0 & mmse_by20_11 == 0 & mmse_by20_14 == .
replace livetime_20 = yearin_14 - yearin_8 if mmse_by20 == 0 & mmse_by20_11 == 0 & mmse_by20_14 == 1
replace livetime_20 = yearin_14 - yearin_8 if mmse_by20 == 0 & mmse_by20_11 == 0 & mmse_by20_14 == 0 & mmse_by20_18 == .
replace livetime_20 = yearin_18 - yearin_8 if mmse_by20 == 0 & mmse_by20_11 == 0 & mmse_by20_14 == 0 & mmse_by20_18 == 1
replace livetime_20 = yearin_18 - yearin_8 if mmse_by20 == 0 & mmse_by20_11 == 0 & mmse_by20_14 == 0 & mmse_by20_18 == 0
tab livetime_20
* Generate Livetime with mmse cut off point as 24
gen livetime_24 = .
replace livetime_24 = yearin_11 - yearin_8 if mmse_by24 == 0 & mmse_by24_11 == 1
replace livetime_24 = yearin_11 - yearin_8 if mmse_by24 == 0 & mmse_by24_11 == 0 & mmse_by24_14 == .
replace livetime_24 = yearin_14 - yearin_8 if mmse_by24 == 0 & mmse_by24_11 == 0 & mmse_by24_14 == 1
replace livetime_24 = yearin_14 - yearin_8 if mmse_by24 == 0 & mmse_by24_11 == 0 & mmse_by24_14 == 0 & mmse_by24_18 == .
replace livetime_24 = yearin_18 - yearin_8 if mmse_by24 == 0 & mmse_by24_11 == 0 & mmse_by24_14 == 0 & mmse_by24_18 == 1
replace livetime_24 = yearin_18 - yearin_8 if mmse_by24 == 0 & mmse_by24_11 == 0 & mmse_by24_14 == 0 & mmse_by24_18 == 0
tab livetime_24
* Generate Livetime with mmse according to educational level
gen livetime_edu_24 = .
replace livetime_edu_24 = yearin_11 - yearin_8 if mmse_byedu == 0 & mmse_byedu_11 == 1
replace livetime_edu_24 = yearin_11 - yearin_8 if mmse_byedu == 0 & mmse_byedu_11 == 0 & mmse_byedu_14 == .
replace livetime_edu_24 = yearin_14 - yearin_8 if mmse_byedu == 0 & mmse_byedu_11 == 0 & mmse_byedu_14 == 1
replace livetime_edu_24 = yearin_14 - yearin_8 if mmse_byedu == 0 & mmse_byedu_11 == 0 & mmse_byedu_14 == 0 & mmse_byedu_18 == .
replace livetime_edu_24 = yearin_18 - yearin_8 if mmse_byedu == 0 & mmse_byedu_11 == 0 & mmse_byedu_14 == 0 & mmse_byedu_18 == 1
replace livetime_edu_24 = yearin_18 - yearin_8 if mmse_byedu == 0 & mmse_byedu_11 == 0 & mmse_byedu_14 == 0 & mmse_byedu_18 == 0
tab livetime_edu_24



* 七. 计算死亡竞争风险模型的Status
* Generate event and time variables
* Rename death year variables
rename d11vyear dthyear_11
rename d14vyear dthyear_14
rename d18vyear dthyear_18
* Rename death indicators
rename dth_f1 dth_11 
rename dth_f2 dth_14 
rename dth_f3 dth_18
* Replace missing codes with actual missing values for death year variables
foreach var of varlist dthyear_* {
    replace `var' = . if `var' == -9 | `var' == -8 | `var' == -7 | `var' == 9999
}
* Initialize death event year variable
gen death_year = .
* Loop through waves to find the first occurrence of death
foreach wave in 11 14 18 {
    replace death_year = dthyear_`wave' if death_year == . & dth_`wave' == 1
}
* Set death year to the last observed year if no death occurred
foreach wave in 18 14 11 {
    replace death_year = dthyear_`wave' if death_year == . & !missing(dthyear_`wave')
}
* Calculate the time to event from baseline year
gen time_to_death = death_year - yearin_8
* Initialize cognitive impairment event year variable
gen event_year = .
* Loop through waves to find the first occurrence of cognitive impairment
foreach wave in 11 14 18 {
    replace event_year = yearin_`wave' if event_year == . & mmse_bi_`wave' == 1
}
* Set event year to the last observed year if no cognitive impairment occurred
foreach wave in 18 14 11 {
    replace event_year = yearin_`wave' if event_year == . & !missing(yearin_`wave')
}
* Calculate the time to event from baseline year
gen time_to_event = event_year - yearin_8
* Create combined time-to-event variable
gen combined_time_to_event = .
replace combined_time_to_event = time_to_event if !missing(time_to_event)
replace combined_time_to_event = time_to_death if !missing(time_to_death) & (missing(combined_time_to_event) | time_to_death < combined_time_to_event)
* Create the event type indicator
gen event_type = .
replace event_type = 1 if combined_time_to_event == time_to_event
replace event_type = 2 if combined_time_to_event == time_to_death
* Handle censored data explicitly
replace event_type = 0 if combined_time_to_event == . & (missing(time_to_event) & missing(time_to_death))
* 到这就创完变量了，一个event_type，一个combined_time_to_event，下面有点问题可能，下面几行码是检查用的
* Check for inconsistencies
list id combined_time_to_event time_to_event time_to_death if combined_time_to_event >= . | combined_time_to_event <= 0
* Ensure that entry and exit times are logical
gen entry_time = 0
replace combined_time_to_event = . if combined_time_to_event <= entry_time


////////////////////////////////////
* （1）保留一个完整版
save as "Full_08in"

* （2）再保留我们需要的变量，不然append之后太多
keep id trueage a1 residence edug occu f45 marital r_smkl_pres r_smkl_past r_smkl_start r_smkl_quit r_smkl_freq r_dril_pres r_dril_past r_dril_start r_dril_quit r_dril_type r_dril_freq SBP DBP srhealth hypertension diabetes strokecvd disease disease_sum psycho d91 d92 d93 d94 socialactivity g15o1 g15o1_11 g15o1_14 g15o1_18 g21 g21_cat g22 cmm cmm_bi cmm_new status_18 status_20 status_24 status_edu livetime_18 livetime_20 livetime_24 livetime_edu mmse mmse_by18 mmse_by20 mmse_by24 mmse_byedu mmse_quat mmse_11 mmse_by18_11 mmse_by20_11 mmse_by24_11 mmse_byedu_11 mmse_quat_11 mmse_14 mmse_by18_14 mmse_by20_14 mmse_by24_14 mmse_byedu_14 mmse_quat_14 mmse_18 mmse_by18_18 mmse_by20_18 mmse_by24_18 mmse_byedu_18 mmse_quat_18 combined_time_to_event event_type death_year time_to_death event_year time_to_event entry_time

save as "Br_08in"




