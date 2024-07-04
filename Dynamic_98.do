
use "/Users/shenjuntian/Desktop/Oral Health/02 Data cleaning/0626 Dynamic/Dynamic_98/Full_dat98_18_f7_covariances.dta"


*一、提取98longdata里98年份入组的人:
describe id
gen id_str = string(id, "%08.0f")
gen ends_with_98 = substr(id_str, length(id_str)-1, 2) == "98"
tab ends_with_98
keep if ends_with_98 == 1
drop id_str
drop ends_with_98 

*二、处理interview year
drop yearin_0 yearin_2 yearin_5 
rename year9899 yearin_98

gen yearin_0 = .
replace yearin_0 = 2000 if monthin_0 > 0 
order yearin_0, before(monthin_0)
label variable yearin_0 "year of the 2000 interview"

gen yearin_2 = .
replace yearin_2 = 2002 if monthin_2 > 0 
order yearin_2, before(monthin_2)
label variable yearin_2 "year of the 2002 interview"

gen yearin_5 = .
replace yearin_5 = 2005 if monthin_5 > 0 
order yearin_5, before(monthin_5)
label variable yearin_5 "year of the 2005 interview"

rename yearin_8 year_8
gen yearin_8 = .
replace yearin_8=2008 if year_8==2008
replace yearin_8=2009 if year_8==2009
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
codebook g17a1 
codebook g17b1
codebook g17b1
codebook g17d1
*以上这步主要是看一下missing和dont`know是不是分别是9和3，不同年份cros可能不一样，下面的代码要灵活调整，不要弄错了
gen temp_hyp = (g17a1 == 1)
gen temp_dia = (g17b1 == 1)
gen temp_hrt = (g17c1 == 1)
gen temp_strk = (g17d1 == 1)
egen cmm = rowtotal(temp_hyp temp_dia temp_hrt temp_strk)
drop temp_hyp temp_dia temp_hrt temp_strk

gen cmm_bi=cmm
replace cmm_bi=0 if cmm < 2
replace cmm_bi=1 if cmm >= 2

replace cmm =. if g17a1 == 9 | g17a1 == 3
replace cmm =. if g17b1 == 9 | g17b1 == 3
replace cmm =. if g17c1 == 9 | g17c1 == 3
replace cmm =. if g17d1 == 9 | g17d1 == 3
replace cmm_bi=. if cmm ==. 

tabulate cmm
label variable cmm "count of cardiometabolic multimorbidity"
*检查cmm不要有超过4的数值
tabulate cmm_bi
label variable cmm_bi "whether has cardiometabolic multimorbidity"
*检查observation总数和cmm要是一样的


* 五.MMSE
rename mmse mmse_f0
**************************1998年******************************
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
gen mmse_bi = mmse
replace mmse_bi = 1 if mmse < 18
replace mmse_bi = 0 if mmse >= 18
replace mmse_bi = . if mmse == .
*检查不要有超过30的数值，超过了要检查代码重新计算，不可以直接剔除>99的
tabulate mmse_bi
**************************2000年******************************
* Step 1: set missing row less than 10
gen byte mis_c16_0 = (c16_0 == 99 | c16_0 == 88)
foreach var in c11_0 c12_0 c13_0 c14_0 c15_0 c21a_0 c21b_0 c21c_0 c31a_0 c31b_0 c31c_0 c31d_0 c31e_0 c32_0 c41a_0 c41b_0 c41c_0 c51a_0 c51b_0 c52_0 c53a_0 c53b_0 c53c_0 {
  gen byte mis_`var' = (`var' == 9 | `var' == 8)
}
egen total_mis_dontknow = rowtotal(mis_*)
replace c16_0 = 0 if total_mis_dontknow <=10 & c16_0==99
replace c16_0 = 0 if total_mis_dontknow <=10 & c16_0==88
foreach var in c11_0 c12_0 c13_0 c14_0 c15_0 c21a_0 c21b_0 c21c_0 c31a_0 c31b_0 c31c_0 c31d_0 c31e_0 c32_0 c41a_0 c41b_0 c41c_0 c51a_0 c51b_0 c52_0 c53a_0 c53b_0 c53c_0 {
  replace `var' = 0 if total_mis_dontknow <=10 & inlist(`var', 8, 9)
}
* Step 2: Generate m1 variable without deleting any data
gen m1_0 = . 
replace m1_0 = 0 if c16_0==88
replace m1_0 = . if c16_0==99
replace m1_0 = . if c16_0<0
replace m1_0 = 7 if c16_0 >= 7 
replace m1_0 = c16_0 if c16_0 < 7 & c16_0 >= 0
tab m1_0
* Step 3: Generate m2 variable without deleting any data
foreach var in c11_0 c12_0 c13_0 c14_0 c15_0 c21a_0 c21b_0 c21c_0 c31a_0 c31b_0 c31c_0 c31d_0 c31e_0 c32_0 c41a_0 c41b_0 c41c_0 c51a_0 c51b_0 c52_0 c53a_0 c53b_0 c53c_0 {
    replace `var' = 0 if `var' == 8
    replace `var' = . if `var' < 0
    replace `var' = . if `var' == 9
}
gen m2_0 = c11_0 + c12_0 + c13_0 + c14_0 + c15_0 + c21a_0 + c21b_0 + c21c_0 + c31a_0 + c31b_0 + c31c_0 + c31d_0 + c31e_0 + c32_0 + c41a_0 + c41b_0 + c41c_0 + c51a_0 + c51b_0 + c52_0 + c53a_0 + c53b_0 + c53c_0 
tab m2_0
* Step 4: Generate mmse variable and keep those with missing less than 10
gen mmse_0 = m1_0 + m2_0

drop  mis_* total_mis_dontknow m1_0 m2_0
tab mmse_0
* Step 5: Generate mmse_bi variable without deleting any data
gen mmse_bi_0 = mmse_0
replace mmse_bi_0 = 1 if mmse_0 < 18
replace mmse_bi_0 = 0 if mmse_0 >= 18
replace mmse_bi_0 = . if mmse_0 == .
*检查不要有超过30的数值，超过了要检查代码重新计算，不可以直接剔除>99的
tabulate mmse_bi_0
**************************2002年******************************
* Step 1: set missing row less than 10
gen byte mis_c16_2 = (c16_2 == 99 | c16_2 == 88)
foreach var in c11_2 c12_2 c13_2 c14_2 c15_2 c21a_2 c21b_2 c21c_2 c31a_2 c31b_2 c31c_2 c31d_2 c31e_2 c32_2 c41a_2 c41b_2 c41c_2 c51a_2 c51b_2 c52_2 c53a_2 c53b_2 c53c_2 {
  gen byte mis_`var' = (`var' == 9 | `var' == 8)
}
egen total_mis_dontknow = rowtotal(mis_*)
replace c16_2 = 0 if total_mis_dontknow <=10 & c16_2==99
replace c16_2 = 0 if total_mis_dontknow <=10 & c16_2==88
foreach var in c11_2 c12_2 c13_2 c14_2 c15_2 c21a_2 c21b_2 c21c_2 c31a_2 c31b_2 c31c_2 c31d_2 c31e_2 c32_2 c41a_2 c41b_2 c41c_2 c51a_2 c51b_2 c52_2 c53a_2 c53b_2 c53c_2 {
  replace `var' = 0 if total_mis_dontknow <=10 & inlist(`var', 8, 9)
}
* Step 2: Generate m1 variable without deleting any data
gen m1_2 = . 
replace m1_2 = 0 if c16_2==88
replace m1_2 = . if c16_2==99
replace m1_2 = . if c16_2<0
replace m1_2 = 7 if c16_2 >= 7 
replace m1_2 = c16_2 if c16_2 < 7 & c16_2 >= 0
tab m1_2
* Step 3: Generate m2 variable without deleting any data
foreach var in c11_2 c12_2 c13_2 c14_2 c15_2 c21a_2 c21b_2 c21c_2 c31a_2 c31b_2 c31c_2 c31d_2 c31e_2 c32_2 c41a_2 c41b_2 c41c_2 c51a_2 c51b_2 c52_2 c53a_2 c53b_2 c53c_2 {
    replace `var' = 0 if `var' == 8
    replace `var' = . if `var' < 0
    replace `var' = . if `var' == 9
}
gen m2_2 = c11_2 + c12_2 + c13_2 + c14_2 + c15_2 + c21a_2 + c21b_2 + c21c_2 + c31a_2 + c31b_2 + c31c_2 + c31d_2 + c31e_2 + c32_2 + c41a_2 + c41b_2 + c41c_2 + c51a_2 + c51b_2 + c52_2 + c53a_2 + c53b_2 + c53c_2 
tab m2_2
* Step 4: Generate mmse variable and keep those with missing less than 10
gen mmse_2 = m1_2 + m2_2

drop  mis_* total_mis_dontknow m1_2 m2_2
tab mmse_2
* Step 5: Generate mmse_bi variable without deleting any data
gen mmse_bi_2 = mmse_2
replace mmse_bi_2 = 1 if mmse_2 < 18
replace mmse_bi_2 = 0 if mmse_2 >= 18
replace mmse_bi_2 = . if mmse_2 == .
*检查不要有超过30的数值，超过了要检查代码重新计算，不可以直接剔除>99的
tabulate mmse_bi_2
**************************2005年******************************
* Step 1: set missing row less than 10
gen byte mis_c16_5 = (c16_5 == 99 | c16_5 == 88)
foreach var in c11_5 c12_5 c13_5 c14_5 c15_5 c21a_5 c21b_5 c21c_5 c31a_5 c31b_5 c31c_5 c31d_5 c31e_5 c32_5 c41a_5 c41b_5 c41c_5 c51a_5 c51b_5 c52_5 c53a_5 c53b_5 c53c_5 {
  gen byte mis_`var' = (`var' == 9 | `var' == 8)
}
egen total_mis_dontknow = rowtotal(mis_*)
replace c16_5 = 0 if total_mis_dontknow <=10 & c16_5==99
replace c16_5 = 0 if total_mis_dontknow <=10 & c16_5==88
foreach var in c11_5 c12_5 c13_5 c14_5 c15_5 c21a_5 c21b_5 c21c_5 c31a_5 c31b_5 c31c_5 c31d_5 c31e_5 c32_5 c41a_5 c41b_5 c41c_5 c51a_5 c51b_5 c52_5 c53a_5 c53b_5 c53c_5 {
  replace `var' = 0 if total_mis_dontknow <=10 & inlist(`var', 8, 9)
}
* Step 2: Generate m1 variable without deleting any data
gen m1_5 = . 
replace m1_5 = 0 if c16_5==88
replace m1_5 = . if c16_5==99
replace m1_5 = . if c16_5<0
replace m1_5 = 7 if c16_5 >= 7 
replace m1_5 = c16_5 if c16_5 < 7 & c16_5 >= 0
tab m1_5
* Step 3: Generate m2 variable without deleting any data
foreach var in c11_5 c12_5 c13_5 c14_5 c15_5 c21a_5 c21b_5 c21c_5 c31a_5 c31b_5 c31c_5 c31d_5 c31e_5 c32_5 c41a_5 c41b_5 c41c_5 c51a_5 c51b_5 c52_5 c53a_5 c53b_5 c53c_5 {
    replace `var' = 0 if `var' == 8
    replace `var' = . if `var' < 0
    replace `var' = . if `var' == 9
}
gen m2_5 = c11_5 + c12_5 + c13_5 + c14_5 + c15_5 + c21a_5 + c21b_5 + c21c_5 + c31a_5 + c31b_5 + c31c_5 + c31d_5 + c31e_5 + c32_5 + c41a_5 + c41b_5 + c41c_5 + c51a_5 + c51b_5 + c52_5 + c53a_5 + c53b_5 + c53c_5 
tab m2_5
* Step 4: Generate mmse variable and keep those with missing less than 10
gen mmse_5 = m1_5 + m2_5

drop  mis_* total_mis_dontknow m1_5 m2_5
tab mmse_5
* Step 5: Generate mmse_bi variable without deleting any data
gen mmse_bi_5 = mmse_5
replace mmse_bi_5 = 1 if mmse_5 < 18
replace mmse_bi_5 = 0 if mmse_5 >= 18
replace mmse_bi_5 = . if mmse_5 == .
*检查不要有超过30的数值，超过了要检查代码重新计算，不可以直接剔除>99的
tabulate mmse_bi_5
**************************2008年******************************
* Step 1: set missing row less than 10
gen byte mis_c16_8 = (c16_8 == 99 | c16_8 == 88)
foreach var in c11_8 c12_8 c13_8 c14_8 c15_8 c21a_8 c21b_8 c21c_8 c31a_8 c31b_8 c31c_8 c31d_8 c31e_8 c32_8 c41a_8 c41b_8 c41c_8 c51a_8 c51b_8 c52_8 c53a_8 c53b_8 c53c_8 {
  gen byte mis_`var' = (`var' == 9 | `var' == 8)
}
egen total_mis_dontknow = rowtotal(mis_*)
replace c16_8 = 0 if total_mis_dontknow <=10 & c16_8==99
replace c16_8 = 0 if total_mis_dontknow <=10 & c16_8==88
foreach var in c11_8 c12_8 c13_8 c14_8 c15_8 c21a_8 c21b_8 c21c_8 c31a_8 c31b_8 c31c_8 c31d_8 c31e_8 c32_8 c41a_8 c41b_8 c41c_8 c51a_8 c51b_8 c52_8 c53a_8 c53b_8 c53c_8 {
  replace `var' = 0 if total_mis_dontknow <=10 & inlist(`var', 8, 9)
}
* Step 2: Generate m1 variable without deleting any data
gen m1_8 = . 
replace m1_8 = 0 if c16_8==88
replace m1_8 = . if c16_8==99
replace m1_8 = . if c16_8<0
replace m1_8 = 7 if c16_8 >= 7 
replace m1_8 = c16_8 if c16_8 < 7 & c16_8 >= 0
tab m1_8
* Step 3: Generate m2 variable without deleting any data
foreach var in c11_8 c12_8 c13_8 c14_8 c15_8 c21a_8 c21b_8 c21c_8 c31a_8 c31b_8 c31c_8 c31d_8 c31e_8 c32_8 c41a_8 c41b_8 c41c_8 c51a_8 c51b_8 c52_8 c53a_8 c53b_8 c53c_8 {
    replace `var' = 0 if `var' == 8
    replace `var' = . if `var' < 0
    replace `var' = . if `var' == 9
}
gen m2_8 = c11_8 + c12_8 + c13_8 + c14_8 + c15_8 + c21a_8 + c21b_8 + c21c_8 + c31a_8 + c31b_8 + c31c_8 + c31d_8 + c31e_8 + c32_8 + c41a_8 + c41b_8 + c41c_8 + c51a_8 + c51b_8 + c52_8 + c53a_8 + c53b_8 + c53c_8 
tab m2_8
* Step 4: Generate mmse variable and keep those with missing less than 10
gen mmse_8 = m1_8 + m2_8

drop  mis_* total_mis_dontknow m1_8 m2_8
tab mmse_8
* Step 5: Generate mmse_bi variable without deleting any data
gen mmse_bi_8 = mmse_8
replace mmse_bi_8 = 1 if mmse_8 < 18
replace mmse_bi_8 = 0 if mmse_8 >= 18
replace mmse_bi_8 = . if mmse_8 == .
*检查不要有超过30的数值，超过了要检查代码重新计算，不可以直接剔除>99的
tabulate mmse_bi_8
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
gen mmse_bi_11 = mmse_11
replace mmse_bi_11 = 1 if mmse_11 < 18
replace mmse_bi_11 = 0 if mmse_11 >= 18
replace mmse_bi_11 = . if mmse_11 == .
*检查不要有超过30的数值，超过了要检查代码重新计算，不可以直接剔除>99的
tabulate mmse_bi_11
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
gen mmse_bi_14 = mmse_14
replace mmse_bi_14 = 1 if mmse_14 < 18
replace mmse_bi_14 = 0 if mmse_14 >= 18
replace mmse_bi_14 = . if mmse_14 == .
*检查不要有超过30的数值，超过了要检查代码重新计算，不可以直接剔除>99的
tabulate mmse_bi_14
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
gen mmse_bi_18 = mmse_18
replace mmse_bi_18 = 1 if mmse_18 < 18
replace mmse_bi_18 = 0 if mmse_18 >= 18
replace mmse_bi_18 = . if mmse_18 == .
*检查不要有超过30的数值，超过了要检查代码重新计算，不可以直接剔除>99的
tabulate mmse_bi_18

* 六.drop
drop if mmse == .
drop if mmse_0 == .
drop if mmse <18
drop if g21 == 99
drop if g22 == 9
drop if cmm == .
drop if g21 >32

* 七.计算cox需要的status和livetime,需根据入组年份修改
* Status （98入组那就是从00开始）
gen status = .
replace status = 1 if mmse_bi_0 == 1 | mmse_bi_2 == 1 | mmse_bi_5 == 1 | mmse_bi_8 == 1 | mmse_bi_11 == 1 | mmse_bi_14 == 1 | mmse_bi_18 == 1
replace status = 0 if status == .
tabulate status
* livetime 
gen livetime = .
replace livetime = yearin_0 - yearin_98 if mmse_bi == 0 & mmse_bi_0 == 1
replace livetime = yearin_0 - yearin_98 if mmse_bi == 0 & mmse_bi_0 == 0 & mmse_bi_2 == .
replace livetime = yearin_2 - yearin_98 if mmse_bi == 0 & mmse_bi_0 == 0 & mmse_bi_2 == 1
replace livetime = yearin_2 - yearin_98 if mmse_bi == 0 & mmse_bi_0 == 0 & mmse_bi_2 == 0 & mmse_bi_5 == .
replace livetime = yearin_5 - yearin_98 if mmse_bi == 0 & mmse_bi_0 == 0 & mmse_bi_2 == 0 & mmse_bi_5 == 1
replace livetime = yearin_5 - yearin_98 if mmse_bi == 0 & mmse_bi_0 == 0 & mmse_bi_2 == 0 & mmse_bi_5 == 0 & mmse_bi_8 == .
replace livetime = yearin_8 - yearin_98 if mmse_bi == 0 & mmse_bi_0 == 0 & mmse_bi_2 == 0 & mmse_bi_5 == 0 & mmse_bi_8 == 1
replace livetime = yearin_8 - yearin_98 if mmse_bi == 0 & mmse_bi_0 == 0 & mmse_bi_2 == 0 & mmse_bi_5 == 0 & mmse_bi_8 == 0 & mmse_bi_11 == .
replace livetime = yearin_11 - yearin_98 if mmse_bi == 0 & mmse_bi_0 == 0 & mmse_bi_2 == 0 & mmse_bi_5 == 0 & mmse_bi_8 == 0 & mmse_bi_11 == 1
replace livetime = yearin_11 - yearin_98 if mmse_bi == 0 & mmse_bi_0 == 0 & mmse_bi_2 == 0 & mmse_bi_5 == 0 & mmse_bi_8 == 0 & mmse_bi_11 == 0 & mmse_bi_14 == .
replace livetime = yearin_14 - yearin_98 if mmse_bi == 0 & mmse_bi_0 == 0 & mmse_bi_2 == 0 & mmse_bi_5 == 0 & mmse_bi_8 == 0 & mmse_bi_11 == 0 & mmse_bi_14 == 1
replace livetime = yearin_14 - yearin_98 if mmse_bi == 0 & mmse_bi_0 == 0 & mmse_bi_2 == 0 & mmse_bi_5 == 0 & mmse_bi_8 == 0 & mmse_bi_11 == 0 & mmse_bi_14 == 0 & mmse_bi_18 == .
replace livetime = yearin_18 - yearin_98 if mmse_bi == 0 & mmse_bi_0 == 0 & mmse_bi_2 == 0 & mmse_bi_5 == 0 & mmse_bi_8 == 0 & mmse_bi_11 == 0 & mmse_bi_14 == 0 & mmse_bi_18 == 1
replace livetime = yearin_18 - yearin_98 if mmse_bi == 0 & mmse_bi_0 == 0 & mmse_bi_2 == 0 & mmse_bi_5 == 0 & mmse_bi_8 == 0 & mmse_bi_11 == 0 & mmse_bi_14 == 0 & mmse_bi_18 == 0
tab livetime

* 七. 计算死亡竞争风险模型的Status
* Generate event and time variables
* Rename death year variables
rename d0vyear dthyear_0
rename d2vyear dthyear_2
rename d5vyear dthyear_5
rename d8vyear dthyear_8
rename d11vyear dthyear_11
rename d14vyear dthyear_14
rename d18vyear dthyear_18
* Rename death indicators
rename dth_f1 dth_0 
rename dth_f2 dth_2 
rename dth_f3 dth_5 
rename dth_f4 dth_8 
rename dth_f5 dth_11 
rename dth_f6 dth_14 
rename dth_f7 dth_18 
* Replace missing codes with actual missing values for death year variables
foreach var of varlist dthyear_* {
    replace `var' = . if `var' == -9 | `var' == -8 | `var' == -7 | `var' == 9999
}
* Initialize death event year variable
gen death_year = .
* Loop through waves to find the first occurrence of death
foreach wave in 0 2 5 8 11 14 18 {
    replace death_year = dthyear_`wave' if death_year == . & dth_`wave' == 1
}
* Set death year to the last observed year if no death occurred
foreach wave in 18 14 11 8 5 2 0 {
    replace death_year = dthyear_`wave' if death_year == . & !missing(dthyear_`wave')
}
* Calculate the time to event from baseline year
gen time_to_death = death_year - yearin_98
* Initialize cognitive impairment event year variable
gen event_year = .
* Loop through waves to find the first occurrence of cognitive impairment
foreach wave in 0 2 5 8 11 14 18 {
    replace event_year = yearin_`wave' if event_year == . & mmse_bi_`wave' == 1
}
* Set event year to the last observed year if no cognitive impairment occurred
foreach wave in 18 14 11 8 5 2 0 {
    replace event_year = yearin_`wave' if event_year == . & !missing(yearin_`wave')
}
* Calculate the time to event from baseline year
gen time_to_event = event_year - yearin_98
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
*这是开始cox
* Set the data for survival analysis
stset combined_time_to_event, failure(event_type == 1) id(id)
* Perform the Cox model for competing risks
stcrreg g21 g22, compete(event_type == 2)


////////////////////////////////////
* （1）保留一个完整版
save as "Full_98in"


* （2）再保留我们需要的变量，不然append之后太多
keep id trueage a1 residence edug occu f45 marital r_smkl_pres r_smkl_past r_smkl_start r_smkl_quit r_smkl_freq r_dril_pres r_dril_past r_dril_start r_dril_quit r_dril_type r_dril_freq SBP DBP srhealth hypertension diabetes strokecvd disease disease_sum g21 g21_cat g22 cmm cmm_bi status livetime mmse mmse_bi mmse_0 mmse_bi_0 mmse_2 mmse_bi_2 mmse_5 mmse_bi_5 mmse_8 mmse_bi_8 mmse_11 mmse_bi_11 mmse_14 mmse_bi_14 mmse_18 mmse_bi_18

combined_time_to_event event_type entry_time

save as "Br_98in"




