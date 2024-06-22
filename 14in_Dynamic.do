*00入组分wave处理
*98年的固定队列已经完成，我们需要做的是00，02，05，08，11，14这六个固定队列 （因为18入组的没有纵向数据）
*这六个数据集每一个都涵盖了分别从入组年份xx-18年的longitudinal data
*我写好了最多的7个wave，你们删掉不要的就行；比如负责05年进组，那你只要保留我写的05-18的cros data
*但是除了根据表格wave数量以外，特别注意需要修改的三个地方：
*（1）第一步剔除要根据你负责的年份也就是按照入组年份！！！！剩余代码可以直接用，毕竟我写好了最多7个wave，你们删掉不要的就行；比如负责05年进组，那你只要保留我写的05-18的cros data
*（2）Merge之后的drop，c. 随访第一年mmse missing的人，要按你的入组年份加一个wave，不要直接用我这的02
*（3）计算status和livetime都要特别注意，有什么不清楚的可以群里问

///////////////////////////////////////////////////////////////////////////////
* wave 2014
（1）14年入组---基线（14）
*导入2014原始数据库
*一、提取此cross-sectional数据中某年份入组的人:
*跑完这一步去google sheet 检查一下n是否正确：
*需改动：入组年份
describe id
gen id_str = string(id, "%08.0f")
gen ends_with_14 = substr(id_str, length(id_str)-1, 2) == "14"
tab ends_with_14
keep if ends_with_14 == 1
drop id_str ends_with_14


*二、给所有变量赋值上年份除了id，因为id是我们merge的抓手
foreach var of varlist _all {
    rename `var' `var'_14
}
rename id_14 id

*三、处理interview year
*如果此年份没有yearin这个变量，需要先加一下这个变量(这种情况就是都是当年的数据，非跨年）；如果名字不一样，也请统一格式yearin_2000
*00 02 05 14都是当年完成所有问卷，但00 02 05没有yearin变量所以要生成；08-09 11-12 14 17-18-19已经有yearin变量，而且年份在前面rename时候已经统一格式了，所以什么都不用做
order yearin_14, after(id)

*四、Oral Health
gen g21_cat_14 = g21_14
replace g21_cat_14 = 0 if g21_14 <= 0
replace g21_cat_14 = 1 if g21_14 > 0 & g21_14 < 10
replace g21_cat_14 = 2 if g21_14 >= 10 & g21_14 <= 19
replace g21_cat_14 = 3 if g21_14 >= 20
tab g21_cat_14
*把不带假牙的设置为0而不是2，带假牙的继续是1；这样cox逻辑不会有问题
replace g22_14 =0 if g22_14 ==2
tab g22_14

* 五.Cardiometabolic Multimorbidity
codebook g15a1_14
codebook g15b1_14
codebook g15b1_14 
codebook g15d1_14
*以上这步主要是看一下missing和dont`know是不是分别是9和3，不同年份cros可能不一样，下面的代码要灵活调整，不要弄错了
gen temp_hyp_14 = (g15a1_14 == 1)
gen temp_dia_14 = (g15b1_14 == 1)
gen temp_hrt_14 = (g15c1_14 == 1)
gen temp_strk_14 = (g15d1_14 == 1)
egen cmm_14 = rowtotal(temp_hyp_14 temp_dia_14 temp_hrt_14 temp_strk_14)
drop temp_hyp_14 temp_dia_14 temp_hrt_14 temp_strk_14

gen cmm_bi_14=cmm_14
replace cmm_bi_14=0 if cmm_14 < 2
replace cmm_bi_14=1 if cmm_14 >= 2

replace cmm_14=. if g15a1_14 == . | g15a1_14 == 8| g15a1_14 == 9
replace cmm_14=. if g15b1_14 == . | g15b1_14 == 8| g15b1_14 == 9
replace cmm_14=. if g15c1_14 == . | g15b1_14 == 8| g15b1_14 == 9
replace cmm_14=. if g15d1_14 == . | g15d1_14 == 8 | g15d1_14 == 9
replace cmm_bi_14=. if cmm_14==. 

tabulate cmm_14
*检查cmm不要有超过4的数值
tabulate cmm_bi_14
*检查observation总数和cmm要是一样的

* 六.MMSE
* Step 1: Generate m1 variable without deleting any data
replace c16_14=0 if c16_14==88
gen m1_14 = c16_14
replace m1_14 = 7 if c16_14 >= 7 & c16_14!=99
replace m1_14 = c16_14 if c16_14 < 7
replace m1_14 = . if c16_14 == 99
* Step 2: Generate m2 variable without deleting any data
replace c11_14=0 if c11_14==8
replace c12_14=0 if c12_14==8
replace c13_14=0 if c13_14==8
replace c14_14=0 if c14_14==8
replace c15_14=0 if c15_14==8
replace c21a_14=0 if c21a_14==8
replace c21b_14=0 if c21b_14==8
replace c21c_14=0 if c21c_14==8
replace c31a_14=0 if c31a_14==8
replace c31b_14=0 if c31b_14==8
replace c31c_14=0 if c31c_14==8
replace c31d_14=0 if c31d_14==8
replace c31e_14=0 if c31e_14==8
replace c32_14=0 if c32_14==8
replace c41a_14=0 if c41a_14==8
replace c41b_14=0 if c41b_14==8
replace c41c_14=0 if c41c_14==8
replace c51a_14=0 if c51a_14==8
replace c51b_14=0 if c51b_14==8
replace c52_14=0 if c52_14==8
replace c53a_14=0 if c53a_14==8
replace c53b_14=0 if c53b_14==8
replace c53c_14=0 if c53c_14==8
gen m2_14 = c11_14 + c12_14 + c13_14 + c14_14 + c15_14 + c21a_14 + c21b_14 + c21c_14 + c31a_14 + c31b_14 + c31c_14 + c31d_14 + c31e_14 + c32_14 + c41a_14 + c41b_14 + c41c_14 + c51a_14 + c51b_14 + c52_14 + c53a_14 + c53b_14 + c53c_14 
replace m2_14 = . if c11_14== 9
replace m2_14 = . if c12_14==9
replace m2_14 = . if c13_14==9
replace m2_14 = . if c14_14==9
replace m2_14 = . if c15_14==9
replace m2_14 = . if c21a_14==9
replace m2_14 = . if c21b_14==9
replace m2_14 = . if c21c_14==9
replace m2_14 = . if c31a_14==9
replace m2_14 = . if c31b_14==9
replace m2_14 = . if c31c_14==9
replace m2_14 = . if c31d_14==9
replace m2_14 = . if c31e_14==9
replace m2_14 = . if c32_14==9
replace m2_14 = . if c41a_14==9
replace m2_14 = . if c41b_14==9
replace m2_14 = . if c41c_14==9
replace m2_14 = . if c51a_14==9
replace m2_14 = . if c51b_14==9
replace m2_14 = . if c52_14==9
replace m2_14 = . if c53a_14==9
replace m2_14 = . if c53b_14==9
replace m2_14 = . if c53c_14==9
* Step 3: Generate mmse variable without deleting any data
gen mmse_14 = m1_14 + m2_14
replace mmse_14 = . if m1_14==.
replace mmse_14 = . if m2_14==.
* Step 4: Generate mmse_bi variable without deleting any data
gen mmse_bi_14 = mmse_14
replace mmse_bi_14 = 1 if mmse_14 < 18
replace mmse_bi_14 = 0 if mmse_14 >= 18
replace mmse_bi_14 = . if mmse_14 == .
tabulate mmse_14
*检查不要有超过30的数值，超过了要检查代码重新计算，不可以直接剔除>99的
tabulate mmse_bi_14
*另存为，命名为00in_14,也就是入组年份in_wave年份，把你负责的入组年份的所有wave放在一个文件夹(名字00in_Merge)里面

///////////////////////////////////////////////////////////////////////////////
* wave 2018
（2）14年入组---随访1（18）
*导入2018原始数据库
*一、提取此cross-sectional数据中某年份入组的人:
*跑完这一步去google sheet 检查一下n是否正确：
*需改动：入组年份
describe id
gen id_str = string(id, "%08.0f")
gen ends_with_14 = substr(id_str, length(id_str)-1, 2) == "14"
tab ends_with_14
keep if ends_with_14 == 1
drop id_str ends_with_14


*二、给所有变量赋值上年份除了id，因为id是我们merge的抓手
foreach var of varlist _all {
    rename `var' `var'_18
}
rename id_18 id

*三、处理interview year
*如果此年份没有yearin这个变量，需要先加一下这个变量(这种情况就是都是当年的数据，非跨年）；如果名字不一样，也请统一格式yearin_2000
*00 02 05 14都是当年完成所有问卷，但00 02 05没有yearin变量所以要生成；08-09 11-12 14 17-18-19已经有yearin变量，而且年份在前面rename时候已经统一格式了，所以什么都不用做
order yearin_18, after(id)

*四、Oral Health
gen g21_cat_18 = g21_18
replace g21_cat_18 = 0 if g21_18 <= 0
replace g21_cat_18 = 1 if g21_18 > 0 & g21_18 < 10
replace g21_cat_18 = 2 if g21_18 >= 10 & g21_18 <= 19
replace g21_cat_18 = 3 if g21_18 >= 20
tab g21_cat_18
*把不带假牙的设置为0而不是2，带假牙的继续是1；这样cox逻辑不会有问题
replace g22_18 =0 if g22_18 ==2

* 五.Cardiometabolic Multimorbidity
codebook g15a1_18
codebook g15b1_18
codebook g15b1_18
codebook g15d1_18
*以上这步主要是看一下missing和dont`know是不是分别是9和3，不同年份cros可能不一样，下面的代码要灵活调整，不要弄错了
gen temp_hyp_18 = (g15a1_18 == 1)
gen temp_dia_18 = (g15b1_18 == 1)
gen temp_hrt_18 = (g15c1_18 == 1)
gen temp_strk_18 = (g15d1_18 == 1)
egen cmm_18 = rowtotal(temp_hyp_18 temp_dia_18 temp_hrt_18 temp_strk_18)
drop temp_hyp_18 temp_dia_18 temp_hrt_18 temp_strk_18

gen cmm_bi_18=cmm_18
replace cmm_bi_18=0 if cmm_18 < 2
replace cmm_bi_18=1 if cmm_18 >= 2

replace cmm_18=. if g15a1_18 == . | g15a1_18 == 8| g15a1_18 == 9
replace cmm_18=. if g15b1_18 == . | g15b1_18 == 8
replace cmm_18=. if g15c1_18 == . | g15c1_18 == 8
replace cmm_18=. if g15d1_18 == . | g15d1_18 == 8
replace cmm_bi_18=. if cmm_18==. 

tabulate cmm_18
*检查cmm不要有超过4的数值
tabulate cmm_bi_18
*检查observation总数和cmm要是一样的

* 六.MMSE
* Step 1: Generate m1 variable without deleting any data
replace c16_18=0 if c16_18==88
gen m1_18 = c16_18
replace m1_18 = 7 if c16_18 >= 7 & c16_18!=99
replace m1_18 = c16_18 if c16_18 < 7
replace m1_18 = . if c16_18 == 99
* Step 2: Generate m2 variable without deleting any data
replace c11_18=0 if c11_18==8
replace c12_18=0 if c12_18==8
replace c13_18=0 if c13_18==8
replace c14_18=0 if c14_18==8
replace c15_18=0 if c15_18==8
replace c21a_18=0 if c21a_18==8
replace c21b_18=0 if c21b_18==8
replace c21c_18=0 if c21c_18==8
replace c31a_18=0 if c31a_18==8
replace c31b_18=0 if c31b_18==8
replace c31c_18=0 if c31c_18==8
replace c31d_18=0 if c31d_18==8
replace c31e_18=0 if c31e_18==8
replace c32_18=0 if c32_18==8
replace c41a_18=0 if c41a_18==8
replace c41b_18=0 if c41b_18==8
replace c41c_18=0 if c41c_18==8
replace c51a_18=0 if c51a_18==8
replace c51b_18=0 if c51b_18==8
replace c52_18=0 if c52_18==8
replace c53a_18=0 if c53a_18==8
replace c53b_18=0 if c53b_18==8
replace c53c_18=0 if c53c_18==8
gen m2_18 = c11_18 + c12_18 + c13_18 + c14_18 + c15_18 + c21a_18 + c21b_18 + c21c_18 + c31a_18 + c31b_18 + c31c_18 + c31d_18 + c31e_18 + c32_18 + c41a_18 + c41b_18 + c41c_18 + c51a_18 + c51b_18 + c52_18 + c53a_18 + c53b_18 + c53c_18 
replace m2_18 = . if c11_18== 9
replace m2_18 = . if c12_18==9
replace m2_18 = . if c13_18==9
replace m2_18 = . if c14_18==9
replace m2_18 = . if c15_18==9
replace m2_18 = . if c21a_18==9
replace m2_18 = . if c21b_18==9
replace m2_18 = . if c21c_18==9
replace m2_18 = . if c31a_18==9
replace m2_18 = . if c31b_18==9
replace m2_18 = . if c31c_18==9
replace m2_18 = . if c31d_18==9
replace m2_18 = . if c31e_18==9
replace m2_18 = . if c32_18==9
replace m2_18 = . if c41a_18==9
replace m2_18 = . if c41b_18==9
replace m2_18 = . if c41c_18==9
replace m2_18 = . if c51a_18==9
replace m2_18 = . if c51b_18==9
replace m2_18 = . if c52_18==9
replace m2_18 = . if c53a_18==9
replace m2_18 = . if c53b_18==9
replace m2_18 = . if c53c_18==9
* Step 3: Generate mmse variable without deleting any data
gen mmse_18 = m1_18 + m2_18
replace mmse_18 = . if m1_18==.
replace mmse_18 = . if m2_18==.
* Step 4: Generate mmse_bi variable without deleting any data
gen mmse_bi_18 = mmse_18
replace mmse_bi_18 = 1 if mmse_18 < 18
replace mmse_bi_18 = 0 if mmse_18 >= 18
replace mmse_bi_18 = . if mmse_18 == .
tabulate mmse_18
*检查不要有超过30的数值，超过了要检查代码重新计算，不可以直接剔除>99的
tabulate mmse_bi_18
*另存为，命名为00in_18,也就是入组年份in_wave年份，把你负责的入组年份的所有wave放在一个文件夹(名字00in_Merge)里面


///////////////////////////////////////////////////////////////////////////////
*Merge
clear
set maxvar 32767

* 设置工作路径到包含数据文件的目录
cd "/Users/shenjuntian/Desktop/Oral Health/00in_Merge"

* 加载第一个数据集
use "14in_14.dta", clear

* 逐个合并剩余的数据集
merge 1:m id using "14in_18.dta"
drop _merge

* 保存合并后的数据集
*确认一下Obs是不是你对应入组年份的n就可以保存了
save "14in_Merge.dta", replace

///////////////////////////////////////////////////////////////////////////////
*Merge之后
* 1.Drop and Clean (一定要去表格记录！！！！！！)
drop if mmse_14 <18
drop if mmse_14 == .
drop if mmse_18 == .
*此条对应c. 随访第一年mmse missing的人，但02是我00入组的随访后一年，你们要特别注意根据你们的入组年份改的
drop if g21_14 == 88|g21_14 == .|g21_14 == 99
drop if g22_14 == 9|g21_14 == .|g22_14 == 8
drop if cmm_14 == .
drop if g21_14 > 32

* 2.计算status和livetime,需根据入组年份修改
* Status （00入组那就是从02开始）
gen status = .
replace status = 1 if mmse_bi_18 == 1
replace status = 0 if status == .
tabulate status
* livetime 
gen livetime = .
replace livetime = yearin_18 - yearin_14 if mmse_bi_14 == 0 & mmse_bi_18 == 1
replace livetime = yearin_18 - yearin_14 if mmse_bi_14 == 0 & mmse_bi_18 == 0
tab livetime
*保存，整个00in_Merge文件夹上传Google drive，然后02in_Merge.dta方便的话可以发下微信
///////////////////////////////////////////////////////////////////////////////
*这个do-file也要放进对应的文件夹一并上传






