
*****************************************************************
*** Replication file for                                      ***
*** "Macroeconomic Expectations and Credit Card Spending"     ***
*** by Misha Galashin, Martin Kanz, and Ricardo Perez-Truglia ***
*** Review of Financial Studies (2018)                        ***
*****************************************************************

* set maxvar 31000
* set matsize 11000

* Working Directory
cap: cd "~/Dropbox/replication_folder/"

* Define global paths for data and output for better maintainability
global data "Data"
global output "Output"	

* Specific data file to be used
global data_file "$data/data_ready_for_analysis_het_final2.dta"

* Load the dataset
use "$data_file", clear

* Other Working Directories
* cap: cd "C:/Users/javie/Dropbox/Macroeconomic Expectations and Consumption/Analysis stata/replication_folder"
* cap: cd "C:/Users/Martin/Dropbox/Macro Expectations and Consumption/Analysis stata/replication_folder"
* cap: cd "C:/Users/ricar/Dropbox/Economist/Papers/Macroeconomic Expectations and Consumption/Analysis stata/replication_folder"
* cap: cd "/Users/luisacefala/Dropbox/Ricardo/MayBank/Malaysian Project Data and Code/replication_folder"
* cap: cd "/Users/mgalashin/Dropbox/Macroeconomic Expectations and Consumption/Analysis stata/replication_folder"
* cap: cd "D:/Dropbox/Macroeconomic Expectations and Consumption/Analysis stata/replication_folder"
**** 

*****************************
****       Tables        ****
*****************************

*-----------------------------------------------------------
* Table 1: Definition of Durable and Tradable Expenditures
*-----------------------------------------------------------

* ssc install texsave, replace
* use "$data/categories_mcc_20200715.dta", clear 

import delimited "$data/categories_mcc_$version_date.csv", clear
save "$data/categories_mcc_$version_date.dta", replace

use "$data/categories_mcc_$version_date.dta", clear

	replace mcc_grp="Automotive" if mcc_grp=="Automative"
	replace mcc_grp="Books and Stationery" if mcc_grp=="Books n Stationary"
	replace mcc_grp="Camera and Photo" if mcc_grp=="Camera & Photo"
	replace mcc_grp="Computer Equipment" if mcc_grp=="Computer"
	replace mcc_grp="Department Store" if mcc_grp=="Dept Store (AMEX)"
	replace mcc_grp="Direct Marketing" if mcc_grp=="Direct Mktg"
	replace mcc_grp="Food and Beverage" if mcc_grp=="Dining (Hotel)"
	replace mcc_grp="Electronics" if mcc_grp=="Elect & Electr"
	replace mcc_grp="Food and Beverage" if mcc_grp=="Food & Beverage" | mcc_grp=="Food & Beverage (Other)"
	replace mcc_grp="Groceries" if mcc_grp=="Grocery"  
	replace mcc_grp="Health and Beauty" if mcc_grp=="Health & Beauty" 
	replace mcc_grp="Sporting Goods" if  mcc_grp=="Golf/Sport" 
	replace mcc_grp="Insurance" if  mcc_grp=="Insurance (Other)" 
	replace mcc_grp="Home Improvement" if  mcc_grp=="Interior Deco/Bulding/Renovation" 
	replace mcc_grp="Jewellery and Watches" if  mcc_grp=="Jewellery & Wch" 
	replace mcc_grp="Medical and Optical" if  mcc_grp=="Medical & Optic" 
	replace mcc_grp="Petrol" if  mcc_grp=="Petrol (Dealers)" 
	replace mcc_grp="Utilities" if  mcc_grp=="Utilities (Others)" 
	replace mcc_grp="Retail" if  mcc_grp=="Retail /Business Outlet" | mcc_grp=="Retail / Business Outlet"
	replace mcc_grp="Apparel" if mcc_grp=="Textile"

	* N are the number of respondents
	local N=2782
	destring txn_sum, replace
	replace txn_sum=txn_sum/1.63
	
	collapse (sum) txn_sum (mean) durable (mean) nondurable (mean) tradable (mean) nontradable (mean) missing, by(mcc_grp)

	gen av_exp=txn_sum/2872
	replace av_exp = av_exp/12

	egen tot_exp=sum(txn_sum)
	egen tot_exp_durable=sum(txn_sum*durable)
	egen tot_exp_nondurable=sum(txn_sum*nondurable)
	egen tot_exp_tradable=sum(txn_sum*tradable) 
	egen tot_exp_nontradable=sum(txn_sum*nontradable)
	egen tot_exp_missing=sum(txn_sum*missing)

	* For waffle chart

	egen tot_exp_trad_dur=sum(txn_sum*durable*tradable)
	egen tot_exp_trad_nondur=sum(txn_sum*nondurable*tradable)
	egen tot_exp_nontrad_dur=sum(txn_sum*durable*nontradable)
	egen tot_exp_nontrad_nondur=sum(txn_sum*nondurable*nontradable)


	*egen tot_exp_nontrad=sum(txn_sum) if tradable==0 // this will be correct in the future when uncategorized have 'missining' instead of zero.
	*egen tot_exp_uncat=sum(txn_sum) if durable==. & nondurable==. & tradable==.

	gen ratio_durable=((txn_sum*durable)/tot_exp_durable)*100 if durable!=0
	gen ratio_nondurable=((txn_sum*nondurable)/tot_exp_nondurable)*100 if nondurable!=0
	gen ratio_tradable=((txn_sum*tradable)/tot_exp_tradable)*100 if tradable!=0
	gen ratio_nontradable=((txn_sum*nontradable)/tot_exp_nontradable)*100 if nontradable!=0

	expand 2 in 1

	replace mcc_grp= "Uncategorized" if _n==39
	replace txn_sum= tot_exp_missing if mcc_grp=="Uncategorized"
	*replace av_exp=txn_sum/3148
	gen ratio_uncat=(txn_sum/tot_exp)*100 if mcc_grp=="Uncategorized"
	replace durable=. if mcc_grp=="Uncategorized"
	replace nondurable=. if mcc_grp=="Uncategorized"
	replace tradable=. if mcc_grp=="Uncategorized"
	replace nontradable=. if mcc_grp=="Uncategorized"
	replace ratio_durable=. if mcc_grp=="Uncategorized"
	replace ratio_nondurable=. if mcc_grp=="Uncategorized"
	replace ratio_tradable=. if mcc_grp=="Uncategorized"
	replace ratio_nontradable=. if mcc_grp=="Uncategorized"

	replace av_exp = (txn_sum/2872)/12 if mcc_grp=="Uncategorized"
	replace durable=durable*100
	replace tradable=tradable*100
	replace nondurable=nondurable*100
	replace nontradable=nontradable*100

	drop if missing==1

	gen ratio=(txn_sum/tot_exp)*100

	format ratio %9.1fc
	format ratio_durable %9.1fc
	format ratio_nondurable %9.1fc
	format ratio_tradable %9.1fc
	format ratio_nontradable %9.1fc
	format durable %9.0fc
	format nondurable %9.0fc
	format tradable %9.0fc
	format nontradable %9.0fc

	format av_exp %9.0fc
	replace ratio_durable=0 if ratio_durable==.
	replace ratio_nondurable=0 if ratio_nondurable==.
	replace ratio_tradable=0 if ratio_tradable==.
	replace ratio_nontradable=0 if ratio_nontradable==.

	preserve
		keep mcc_grp av_exp durable tradable ratio

		label variable durable "Durables (\%)"
		*label variable nondurable "NonDur"
		label variable tradable "Tradables (\%)"
		*label variable nontradable "NonTrad"
		label variable ratio "Ratio*    (\%)"


		tostring av_exp, replace force
		split av_exp, parse(".") limit(1)
		replace av_exp1=substr(av_exp1,1,1) + "," + substr(av_exp,2,3) if length(av_exp1)==4 
		label variable av_exp1 ""
		drop av_exp 
		order av_exp1, after(mcc_grp)
		
		tostring durable, replace force
		split durable, parse(".") limit(1)
		replace durable1=substr(durable1,1,1) + "," + substr(durable1,2,3) if length(durable1)==4 
		label variable durable1 ""
		drop durable
		replace durable1 = "--" if durable1==""
		order durable1, after(av_exp1)

		tostring tradable, replace force
		split tradable, parse(".") limit(1)
		replace tradable1=substr(tradable1,1,1) + "," + substr(tradable1,2,3) if length(tradable1)==4 
		label variable tradable1 ""
		drop tradable
		replace tradable1 = "--" if tradable1==""
		order tradable1, after(durable1)
		drop if mcc_grp=="Sporting Goods"
		drop ratio

		texsave using "$output/Tables/expenditures_mccdescription_1.tex", ///
		replace frag nofix varlabels headerlines("& Avg. Monthly & Durables (\%) & Tradables (\%) \\ & Expenditure, USD & & \\ &(1)&(2)&(3)") ///
		
		
		filefilter "$output/Tables/expenditures_mccdescription_1.tex" "$output/Tables/expenditures_mccdescription_2.tex", ///
		from("\BSbegin{table}[tbp] \BScentering" ) to("") replace
		filefilter "$output/Tables/expenditures_mccdescription_2.tex" "$output/Tables/expenditures_mccdescription_3.tex", ///
		from("\BSend{table}") to("") replace
		filefilter "$output/Tables/expenditures_mccdescription_3.tex" "$output/Tables/expenditures_mccdescription.tex", ///
		from("{}&{}&{}&{} \BStabularnewline") to("") replace
		!rm "$output/Tables/expenditures_mccdescription_1.tex"  "$output/Tables/expenditures_mccdescription_2.tex" ///
		"$output/Tables/expenditures_mccdescription_3.tex"
	restore
	
	
*-----------------------------------------------------------
* Table 2: External Validity
*-----------------------------------------------------------

	* ssc install winsor
	* ssc install winsor2

*** Build data

	use "$data/survey_pretreat_20220617.dta", clear

	merge m:1 respondent_id period using "$data/debt_pretreat_20220617.dta" // not matched came from missing periods in using data
	drop _merge

	split period, p("-")
	drop period3
	destring period2 period1, replace


	gen periodx= period2 - 4 if period1==2019
	replace periodx= period2 - 16 if period1==2018
	drop period period2 period1
	rename periodx period

	replace txn_amt=txn_amt/1.63 //WB data (2018 US PPP)
	rename cur_bal_end_date txn_bal_end
	rename cur_credit_limit_sum txn_credit_limit
	replace txn_bal_end=txn_bal_end/1.63
	replace txn_credit_limit=txn_credit_limit/1.63 
	replace txn_amt=. if txn_bal_end==.

	*Reshape data
	rename respondent_id id
	gen ids=id
	tostring ids, replace

	replace period=1 if period==-12  
	replace period=2 if period==-11
	replace period=3 if period==-10
	replace period=4 if period==-9
	replace period=5 if period==-8
	replace period=6 if period==-7
	replace period=7 if period==-6
	replace period=8 if period==-5
	replace period=9 if period==-4
	replace period=10 if period==-3
	replace period=11 if period==-2
	replace period=12 if period==-1

	drop first_acct_open_date 
	replace good_category="gr_or_din" if good_category=="groceries_or_dining"
	replace good_category="trad_dur" if good_category=="tradable_durable"

	reshape wide txn_num txn_amt, i(id period) j(good_category) string
	reshape wide txn_num* txn_amt* txn_bal_end* txn_credit_limit, i(id) j(period)

	tempfile temp1
	save "tempfile4"

	use "$data/to_select_insample_ev.dta", clear

	drop period 

	collapse treatment_infla treatment_forex prior_forex prior_infla, by(respondent_id)
	rename respondent_id id
	gen ids=id
	tostring ids, replace

	merge 1:1  id using "tempfile4.dta"
	*merge 1:1  id using "$data_file"

	
	gen tot_in_sample=0
	replace tot_in_sample=1 if _merge==3

	gen in_sample_outliers=0
	replace in_sample_outliers=1 if tot_in_sample==1 & abs(prior_forex-4.7)<0.01 | tot_in_sample==1 & abs(prior_forex-3.7)<0.01
	replace in_sample_outliers=1 if id==7374 | id==10813

	drop _merge

	merge 1:1 id using "$data/demo.dta"
	drop _merge
	
	destring annual_income, replace force

	merge m:1 id using "$data_file", force

	*replace annual_income="" if annual_income=="NA"
	destring annual_income, replace
	replace annual_income=annual_income/1.63
	*gen mincome=annual_income/12

	gen male=.
	replace male=1 if sex=="2"
	replace male=0 if sex=="1"
	destring age, replace force
	destring married, replace force
	destring dependents, replace force
	gen exp_over_inc=tmamtall_pre12/mincome
	gen participant=0
	replace participant=1 if tot_in_sample==1 &  in_sample_outliers==0
	*replace participant=1 if tot_in_sample==1 &  in_sample_outliers==0

	
	* Impute
	replace mincome=0 if mincome==.

*** Actually build the table

*** Panel A: Demographics

	preserve
		encode treatment_type,gen(treatment)
		
		postfile desc str60 variables str12 All str12 Part str12 NoPart str12 Pvalue using "$output/external_validity9.dta", replace

		post desc ("\multicolumn{5}{l}{Panel A: Demographics}") ("") ("") ("") ("")

		foreach var in male age mincome {

		sum `var'
			local m0=string(r(mean), "%9.2fc") 
			local s0=string(r(sd)/sqrt(r(N)), "%9.2fc")

			sum `var' if participant==1
			local m1=string(r(mean), "%9.2fc")
			local s1=string(r(sd)/sqrt(r(N)), "%9.2fc")

			sum `var' if participant==0
			local m2=string(r(mean), "%9.2fc")
			local s2=string(r(sd)/sqrt(r(N)), "%9.2fc")

			xi: reg `var' participant, r
			local p=string(Ftail(e(df_m),e(df_r),e(F)), "%9.3fc")

			post desc ("`var'") ("`m0'") ("`m1'") ("`m2'") ("`p'")  
			post desc ("") ("(`s0')") ("(`s1')") ("(`s2')") ("")  


		}

	*** Panel B: Monthly Expenditures
		
		post desc ("\multicolumn{5}{l}{Panel B: Monthly Expenditures (2018-19)}") ("") ("") ("") ("")

		*foreach var in tmamtall_pre12_w	tmamtdurable_pre12_w tmamttrad_dur_pre12_w tmamtnondurable_pre12_w tmamtelectronics_pre12_w tmamtgroceries_pre12_w tmbal_end_pre12_w {
		foreach var in tmamtall_pre12 tmamtdurable_pre12 tmamttrad_dur_pre12 tmbal_end_pre12 {
			*tmamtnondurable_pre12 tmamtelectronics_pre12 tmamtgroceries_pre12 

			sum `var'
			local m0=string(r(mean), "%9.2fc")
			local s0=string(r(sd)/sqrt(r(N)), "%9.2fc")

			sum `var' if participant==1
			local m1=string(r(mean), "%9.2fc")
			local s1=string(r(sd)/sqrt(r(N)), "%9.2fc")

			sum `var' if participant==0
			local m2=string(r(mean), "%9.2fc")
			local s2=string(r(sd)/sqrt(r(N)), "%9.2fc")


			xi: reg `var' participant, r
			local p=string(Ftail(e(df_m),e(df_r),e(F)), "%9.3fc")


			post desc ("`var'") ("`m0'") ("`m1'") ("`m2'") ("`p'")  
			post desc ("") ("(`s0')") ("(`s1')") ("(`s2')") ("")  

		}

		cou 
		local m0=r(N)
		cou if participant==1
		local m1=r(N)
		cou if participant==0
		local m2=r(N)


		post desc ("`var'") ("`m0'") ("`m1'") ("`m2'") ("") 

		postclose desc 

		use "$output/external_validity2.dta", clear 

		replace variable="\hspace{0.2cm} Male=1" if variable=="male" 
		replace variable="\hspace{0.2cm} Age" if variable=="age"
		replace variable="\hspace{0.2cm} Monthly Av. Income" if variable=="mincome"
		replace variable="\hspace{0.2cm} Total" if variable=="tmamtall_pre12"
		replace variable="\hspace{0.2cm} Durables" if variable=="tmamtdurable_pre12"
		replace variable="\hspace{0.2cm} Trad Durables" if variable=="tmamttrad_dur_pre12"
		replace variable="\hspace{0.2cm} Debt Balance" if variable=="tmbal_end_pre12"
		replace variable="\hspace{0.2cm} Observations" if _n==_N

		foreach var of varlist All-Pvalue { 
			replace `var'=substr(`var',1,2)+","+substr(`var',3,3) if _n==_N & length(`var')==5 
			replace `var'=substr(`var',1,1)+","+substr(`var',2,3) if _n==_N & length(`var')==4
		}

		label variable variables "" 
		label variable All ""
		label variable Part ""
		label variable NoPart ""
		label variable Pvalue ""


		texsave using "$output/Tables/External_validity_tex_4.tex", ///
		replace frag nofix varlabels hlines(7 16) ///
		headerlines(" & & \multicolumn{2}{c}{Responded to survey} & \\ & All & Yes & No & P-Value \\ \cmidrule(lr){2-2} \cmidrule(lr){3-3} \cmidrule(lr){4-4} \cmidrule(lr){5-5}  &(1)&(2)&(3)&(4)") 
		*align(lcccc) headlines("\newcolumntype{Y}{>{\centering\arraybackslash}X}")
		
		* Remove \begin{table} and \end{table} from the tex output
		filefilter "$output/Tables/External_validity_tex_1.tex" "$output/Tables/External_validity_tex_2.tex", ///
		from("\BSbegin{table}[tbp] \BScentering" ) to("") replace
		filefilter "$output/Tables/External_validity_tex_2.tex" "$output/Tables/External_validity_tex_3.tex", ///
		from("\BSend{table}") to("") replace
		* Remove unnecessary row (where the empty labels are created) in the header
		filefilter "$output/Tables/External_validity_tex_3.tex" "$output/Tables/External_validity_tex_4.tex", ///
		from("&&&&") to("\BSvspace{0.25cm}") replace
		* Remove extra columns generated by the post desc command, and add \\
		filefilter "$output/Tables/External_validity_tex_4.tex" "$output/Tables/External_validity_tex_5.tex", ///
		from("{}&{}&{}&{}&{} \BStabularnewline") to("") replace
		* Resize from \linewidth to 0.6\linewidth to better fit in the page
		filefilter "$output/Tables/External_validity_tex_5.tex" "$output/Tables/External_validity_tex_6.tex", ///
		from("\BSbegin{tabularx}{\BSlinewidth}{lcccc}") to ("\BSbegin{tabularx}{400pt}{lYYYY}") replace
		* Format
		filefilter "$output/Tables/External_validity_tex_6.tex" "$output/Tables/External_validity_tex_7.tex", ///
		from("Panel A: Demographics") to("\BStextbf{Panel A: Demographics}") replace
		
		filefilter "$output/Tables/External_validity_tex_7.tex" "$output/Tables/External_validity_tex.tex", ///
		from("Panel B: Monthly Expenditures (2018--19)") to("\BStextbf{Panel B: Monthly Expenditures (Pre--Treatment)}") replace

		!rm "$output/Tables/External_validity_tex_1.tex" "$output/Tables/External_validity_tex_2.tex" ///
			"$output/Tables/External_validity_tex_3.tex" "$output/Tables/External_validity_tex_4.tex" ///
			"$output/Tables/External_validity_tex_5.tex" "$output/Tables/External_validity_tex_6.tex"  ///
			"$output/Tables/External_validity_tex_7.tex" 
	restore

*-----------------------------------------------------------
* Table 3: Randomization Balance Test
*-----------------------------------------------------------

	*** Panel A: Demographics
	preserve
		encode treatment_type,gen(treatment)

		postfile desc str60 variables str12 All str12 Erate str12 PIrate str12 Both str12 pvalue using "$data/summary_balance2.dta", replace

		post desc ("\multicolumn{5}{l}{\textbf{Panel A: Demographics}}") ("") ("") ("") ("") ("")

		foreach var in college married dependents selfemp mincome {

			sum `var' if participant==1
			local m0=string(r(mean), "%9.2fc") 
			local s0=string(r(sd)/sqrt(r(N)), "%9.2fc")

			sum `var' if treatment_forex==1
			local m1=string(r(mean), "%9.2fc")
			local s1=string(r(sd)/sqrt(r(N)), "%9.2fc")

			sum `var' if treatment_infla==1
			local m2=string(r(mean), "%9.2fc")
			local s2=string(r(sd)/sqrt(r(N)), "%9.2fc")

			sum `var' if treatment_both==1
			local m3=string(r(mean), "%9.2fc")
			local s3=string(r(sd)/sqrt(r(N)), "%9.2fc")

			xi: reg `var' i.treatment, r
			local p=string(Ftail(e(df_m),e(df_r),e(F)), "%9.2fc")

			post desc ("`var'") ("`m0'") ("`m1'") ("`m2'") ("`m3'") ("`p'") 
			post desc ("") ("(`s0')") ("(`s1')") ("(`s2')") ("(`s3')") ("") 

		}

		*** Panel B: Monthly Expenditures

		post desc ("\multicolumn{5}{l}{Panel B: Monthly Expenditures (Pre-Treatment Period)}") ("") ("") ("") ("") ("")

		foreach var in tmamtall_pre12	tmamtdurable_pre12	tmamttrad_dur_pre12	tmbal_end_pre12 {

			sum `var' if participant == 1
			local m0=string(r(mean), "%9.2fc") 
			local s0=string(r(sd)/sqrt(r(N)), "%9.2fc")

			sum `var' if treatment_forex==1
			local m1=string(r(mean), "%9.2fc")
			disp `m1'
			local s1=string(r(sd)/sqrt(r(N)), "%9.2fc")

			sum `var' if treatment_infla==1
			local m2=string(r(mean), "%9.2fc")
			local s2=string(r(sd)/sqrt(r(N)), "%9.2fc")

			sum `var' if treatment_both==1
			local m3=string(r(mean), "%9.2fc")
			local s3=string(r(sd)/sqrt(r(N)), "%9.2fc")

			xi: reg `var' i.treatment, r
			local p=string(Ftail(e(df_m),e(df_r),e(F)), "%9.2fc")

			post desc ("`var'") ("`m0'") ("`m1'") ("`m2'") ("`m3'") ("`p'") 
			post desc ("") ("(`s0')") ("(`s1')") ("(`s2')") ("(`s3')") ("") 

		}

		*** Panel C: Prior Beliefs
		post desc ("\multicolumn{5}{l}{\textbf{Panel C: Prior Beliefs}}") ("") ("") ("") ("") ("")

		foreach var in prior_forex_ad prior_infla{
		
			sum `var'
			local m0=string(r(mean), "%9.2fc") 
			local s0=string(r(sd)/sqrt(r(N)), "%9.2fc")

			sum `var' if treatment_forex==1
			local m1=string(r(mean), "%9.2fc")
			local s1=string(r(sd)/sqrt(r(N)), "%9.2fc")

			sum `var' if treatment_infla==1
			local m2=string(r(mean), "%9.2fc")
			local s2=string(r(sd)/sqrt(r(N)), "%9.2fc")

			sum `var' if treatment_both==1
			local m3=string(r(mean), "%9.2fc")
			local s3=string(r(sd)/sqrt(r(N)), "%9.2fc")

			xi: reg `var' i.treatment, r
			local p=string(Ftail(e(df_m),e(df_r),e(F)), "%9.2fc")

			post desc ("`var'") ("`m0'") ("`m1'") ("`m2'") ("`m3'") ("`p'") 
			post desc ("") ("(`s0')") ("(`s1')") ("(`s2')") ("(`s3')") ("") 
			
		}
		cou 
		local m0=r(N)

		cou if treatment_forex==1 & treatment_infla==0
		local m1=r(N)
		cou if treatment_infla==1 & treatment_forex==0
		local m2=r(N)
		cou if treatment_both==1
		local m3=r(N)

		post desc ("`var'") ("`m0'") ("`m1'") ("`m2'") ("`m3'") ("") 
			
		postclose desc 

		use "$data/summary_balance2.dta", clear 

		replace variable="\hspace{0.2cm} College" if variable=="college" 
		replace variable="\hspace{0.2cm} Married" if variable=="married"
		replace variable="\hspace{0.2cm} Number of Dependents" if variable=="dependents"
		replace variable="\hspace{0.2cm} Self-employed" if variable=="selfemp"
		replace variable="\hspace{0.2cm} Monthly Average Income" if variable=="mincome"
		replace variable="\hspace{0.2cm} Total" if variable=="tmamtall_pre12"
		replace variable="\hspace{0.2cm} Durables" if variable=="tmamtdurable_pre12"
		replace variable="\hspace{0.2cm} Tradable Durables" if variable=="tmamttrad_dur_pre12"
		replace variable="\hspace{0.2cm} Nondurables" if variable=="tmamtnondurables_pre12"
		replace variable="\hspace{0.2cm} Electronics" if variable=="tmamtelectronics_pre12"
		replace variable="\hspace{0.2cm} Groceries" if variable=="tmamtgroceries_pre12"
		replace variable="\hspace{0.2cm} Debt" if variable=="tmbal_end_pre12"
		replace variable="\hspace{0.2cm} Prior Exchange Rate" if variable=="prior_forex_ad"
		replace variable="\hspace{0.2cm} Prior Inflation" if variable=="prior_infla"
		replace variable="Observations" if _n==_N

		foreach var of varlist All-Both {
		
			replace `var'=substr(`var',1,2)+","+substr(`var',3,3) if _n==_N & length(`var')==5 
			replace `var'=substr(`var',1,1)+","+substr(`var',2,3) if _n==_N & length(`var')==4
		
		}

		label variable variable "" 
		label variable All ""
		label variable Erate "Exchange Rate"
		label variable PIrate "Inflation Rate"
		label variable Both "Both"
		label variable pvalue "p-value"

		texsave using "$output/Tables/Summary_balance_2.tex", replace frag ///
		nofix varlabels hlines(11 20 25) ///
		headerlines(" & All & \multicolumn{4}{c}{Treatment} \\ \cmidrule(lr){2-2} \cmidrule(lr){3-6} &(1)&(2)&(3)&(4)&(5)") ///
		align(lccccc) headlines("\newcolumntype{Y}{>{\centering\arraybackslash}X}") noendash
			
		* Remove \begin{table} and \end{table} from the tex output
		filefilter "$output/Tables/Summary_balance_1.tex" "$output/Tables/Summary_balance_2.tex", ///
		from("\BSbegin{table}[tbp] \BScentering" ) to("") replace
		filefilter "$output/Tables/Summary_balance_2.tex" "$output/Tables/Summary_balance_3.tex", ///
		from("\BSend{table}") to("") replace
		* Fix header for panel B which currently was too long and was exported cut
		filefilter "$output/Tables/Summary_balance_3.tex" "$output/Tables/Summary_balance_4.tex", ///
		from("\BSmulticolumn{5}{l}{Panel B: Monthly Expenditures (Pre-Treatm") to ("\BSmulticolumn{5}{l}{\BStextbf{Panel B: Monthly Expenditures (Pre-Treatment)}}") replace
		* Remove unnecessary row (where the empty labels are created) in the header
		filefilter "$output/Tables/Summary_balance_4.tex" "$output/Tables/Summary_balance_5.tex", ///
		from("&&&&&") to("\BSvspace{0.25cm}") replace
		* Columns of same width
		filefilter "$output/Tables/Summary_balance_5.tex" "$output/Tables/Summary_balance.tex", ///
		from("\BSbegin{tabularx}{\BSlinewidth}{lccccc}") to ("\BSbegin{tabularx}{500pt}{lYYYYY}") replace
	
		!rm "$output/Tables/Summary_balance_1.tex" "$output/Tables/Summary_balance_2.tex" ///
			"$output/Tables/Summary_balance_3.tex" "$output/Tables/Summary_balance_4.tex" ///
			"$output/Tables/Summary_balance_5.tex"
	restore
	
*---------------------------------------------------------------------------
* Table 4: Reduced Form, Effect of Information on Expectations and Behavior
*---------------------------------------------------------------------------

	use "$data_file", clear
	* No Winsorize
estimates clear
	quietly{
		xi: reg update_infla int_infla_gap int_forex_gap prior_infla prior_forex_ad female age age2 have_child dependents college ln_Y household_size i.surveyor i.week, robust
		sum update_infla if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo a
	xi: reg update_forex_ad int_forex_gap int_infla_gap prior_infla prior_forex_ad female age age2 have_child dependents college ln_Y household_size i.surveyor i.week i.surveyor i.week, robust
		sum update_forex_ad if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo b
		
		xi: reg tmamtdurable_post3_w int_infla_gap int_forex_gap prior_infla prior_forex_ad tmamtdurable_pre3_w female age age2 have_child dependents college ln_Y household_size i.surveyor i.week i.surveyor i.week, robust
		sum tmamtdurable_post3_w if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo c
	
		xi: reg tmamttrad_dur_post3_w int_infla_gap int_forex_gap prior_infla prior_forex_ad tmamttrad_dur_pre3_w female age age2 have_child dependents college ln_Y household_size i.surveyor i.week, robust
		sum tmamttrad_dur_post3_w if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo d
		
		xi: reg tmrepayment_post3_w int_infla_gap int_forex_gap prior_infla prior_forex_ad female age age2 have_child dependents college ln_Y household_size i.surveyor i.week, robust
		sum vardolbal_end_pre3_w if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo e
		
		xi: reg tmamtall_post3_w int_infla_gap int_forex_gap prior_infla prior_forex_ad tmamtall_pre3_w female age age2 have_child dependents college ln_Y household_size i.surveyor i.week, robust											
		sum tmamtall_post3_w if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo f
	}
	esttab a b c d e f using "$output/Tables/reduced_form_debt.tex", replace ///
	substitute(/begin{tabular} /resizebox{1/textwidth}{!}{/begin{tabular} /end{tabular} /end{tabular}}) ///
	keep(int*) star(* 0.10 ** 0.05 *** 0.01) ///
	scalars("N Observations" "r2 \$R^2\$" "mean_depvar Outcome Mean" "sd_depvar Outcome SD") ///
	sfmt(%9.0fc  %9.3fc %9.3fc %9.3fc) noobs ///
	mtitles("\$\Delta\$ Inflation" "\$\Delta\$ Depreciation" "Durables" "Trad. Dur." "Debt" "Total" ) ///
	mgroups( "Survey Data" "Transaction Data", pattern(1 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))    ///
	compress se b(3) se(3) label nonotes ///
	collabels(none) ///
	varlabels(int_infla_gap "\$\left(\pi_{i,t}^{signal}-\pi_{i,t}^{prior}\right)\cdot T_{i,t}^{\pi}\$" int_forex_gap "\$\left(d_{i,t}^{signal}-d_{i,t}^{prior}\right)\cdot T_{i,t}^{d}\$") 

	** For the body text:
	xi: reg update_infla int_infla_gap gap_infla int_forex_gap gap_forex tmbal_end_pre3 tmbal_end_last3 tmbal_end_preq2 tmbal_end_preq3 tmamtall_pre3 tmamtall_last3 tmamtall_preq2 tmamtall_preq3 tmamtnondurables_pre3 tmamtnondurables_last3 tmamtnondurables_preq2 tmamtnondurables_preq3 tmamttrad_dur_pre3 tmamttrad_dur_last3 tmamttrad_dur_preq2 tmamttrad_dur_preq3 tmamtdurable_pre3 tmamtdurable_last3 tmamtdurable_preq2 tmamtdurable_preq3 dependents i.surveyor i.week
	eststo a1
	xi: reg update_forex_ad int_forex_gap gap_forex int_infla_gap gap_infla tmbal_end_pre3 tmbal_end_last3 tmbal_end_preq2 tmbal_end_preq3 tmamtall_pre3 tmamtall_last3 tmamtall_preq2 tmamtall_preq3 tmamtnondurables_pre3 tmamtnondurables_last3 tmamtnondurables_preq2 tmamtnondurables_preq3 tmamttrad_dur_pre3 tmamttrad_dur_last3 tmamttrad_dur_preq2 tmamttrad_dur_preq3 tmamtdurable_pre3 tmamtdurable_last3 tmamtdurable_preq2 tmamtdurable_preq3 dependents i.surveyor i.week
	eststo a2
	suest a1 a2, vce(robust)
	test [a1_mean]int_infla_gap=[a2_mean]int_forex_gap
	est clear

*---------------------------------------------------------------------------
* Table 5: Effect of Information on survey outcomes, IV with Extras
*---------------------------------------------------------------------------	

	use "$data_file", clear

xi: twostepweakiv 2sls tmamtdurable_post3_w (update_infla update_forex_ad = int_infla_gap int_forex_gap)  gap_infla gap_forex tmbal_end_pre3 tmbal_end_last3 tmbal_end_preq2 tmbal_end_preq3 tmamtall_pre3 tmamtall_last3 tmamtall_preq2 tmamtall_preq3 tmamtnondurables_pre3 tmamtnondurables_last3 tmamtnondurables_preq2 tmamtnondurables_preq3 tmamttrad_dur_pre3 tmamttrad_dur_last3 tmamttrad_dur_preq2 tmamttrad_dur_preq3 tmamtdurable_pre3 tmamtdurable_last3 tmamtdurable_preq2 tmamtdurable_preq3 dependents i.surveyor i.week,   level(95) usegrid citestlist(AR K LC)

putexcel set "Santiago/results.xls", sheet("regress results") replace
putexcel A1=("Grid descript") B1=(e(grid_descript))	

xi: twostepweakiv 2sls tmamttrad_dur_post3_w (update_infla update_forex_ad = int_infla_gap int_forex_gap)  gap_infla gap_forex tmbal_end_pre3 tmbal_end_last3 tmbal_end_preq2 tmbal_end_preq3 tmamtall_pre3 tmamtall_last3 tmamtall_preq2 tmamtall_preq3 tmamtnondurables_pre3 tmamtnondurables_last3 tmamtnondurables_preq2 tmamtnondurables_preq3 tmamttrad_dur_pre3 tmamttrad_dur_last3 tmamttrad_dur_preq2 tmamttrad_dur_preq3 tmamtdurable_pre3 tmamtdurable_last3 tmamtdurable_preq2 tmamtdurable_preq3 dependents i.surveyor i.week,  level(95) usegrid citestlist(AR K LC)

putexcel A2=("Grid descript") B2=(e(grid_descript))		


xi: twostepweakiv 2sls tmtotal_repayment_post3_w (update_infla update_forex_ad = int_infla_gap int_forex_gap)  gap_infla gap_forex tmbal_end_pre3 tmbal_end_last3 tmbal_end_preq2 tmbal_end_preq3 tmamtall_pre3 tmamtall_last3 tmamtall_preq2 tmamtall_preq3 tmamtnondurables_pre3 tmamtnondurables_last3 tmamtnondurables_preq2 tmamtnondurables_preq3 tmamttrad_dur_pre3 tmamttrad_dur_last3 tmamttrad_dur_preq2 tmamttrad_dur_preq3 tmamtdurable_pre3 tmamtdurable_last3 tmamtdurable_preq2 tmamtdurable_preq3 dependents i.surveyor i.week,  level(95) usegrid citestlist(AR K LC)

putexcel A3=("Grid descript") B3=(e(grid_descript))		
	
xi: twostepweakiv 2sls tmamtall_post3_w (update_infla update_forex_ad = int_infla_gap int_forex_gap) gap_infla gap_forex tmbal_end_pre3 tmbal_end_last3 tmbal_end_preq2 tmbal_end_preq3 tmamtall_pre3 tmamtall_last3 tmamtall_preq2 tmamtall_preq3 tmamtnondurables_pre3 tmamtnondurables_last3 tmamtnondurables_preq2 tmamtnondurables_preq3 tmamttrad_dur_pre3 tmamttrad_dur_last3 tmamttrad_dur_preq2 tmamttrad_dur_preq3 tmamtdurable_pre3 tmamtdurable_last3 tmamtdurable_preq2 tmamtdurable_preq3 dependents i.surveyor i.week,  level(95) usegrid citestlist(AR K LC)

putexcel A4=("Grid descript") B4=(e(grid_descript))

	
	estadd scalar FKP=e(widstat)
	
	estimates clear
	quietly{
	
		xi: ivreg2 tmamtdurable_post3_w (update_infla update_forex_ad = int_infla_gap int_forex_gap)  gap_infla gap_forex tmbal_end_pre3 tmbal_end_last3 tmbal_end_preq2 tmbal_end_preq3 tmamtall_pre3 tmamtall_last3 tmamtall_preq2 tmamtall_preq3 tmamtnondurables_pre3 tmamtnondurables_last3 tmamtnondurables_preq2 tmamtnondurables_preq3 tmamttrad_dur_pre3 tmamttrad_dur_last3 tmamttrad_dur_preq2 tmamttrad_dur_preq3 tmamtdurable_pre3 tmamtdurable_last3 tmamtdurable_preq2 tmamtdurable_preq3 dependents i.surveyor i.week, robust 
		estadd scalar wit=`e(cdf)'
		estadd scalar FKP=e(widstat)
		sum tmamtdurable_post3_w if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo a
		
		xi: ivreg2 tmamttrad_dur_post3_w (update_infla update_forex_ad = int_infla_gap int_forex_gap)  gap_infla gap_forex tmbal_end_pre3 tmbal_end_last3 tmbal_end_preq2 tmbal_end_preq3 tmamtall_pre3 tmamtall_last3 tmamtall_preq2 tmamtall_preq3 tmamtnondurables_pre3 tmamtnondurables_last3 tmamtnondurables_preq2 tmamtnondurables_preq3 tmamttrad_dur_pre3 tmamttrad_dur_last3 tmamttrad_dur_preq2 tmamttrad_dur_preq3 tmamtdurable_pre3 tmamtdurable_last3 tmamtdurable_preq2 tmamtdurable_preq3 dependents i.surveyor i.week, robust 
		sum tmamttrad_dur_post3_w if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		estadd scalar FKP=e(widstat)
		eststo b
		xi: ivreg2 vardolbal_end_pre3_w (update_infla update_forex_ad = int_infla_gap int_forex_gap)  gap_infla gap_forex tmbal_end_pre3 tmbal_end_last3 tmbal_end_preq2 tmbal_end_preq3 tmamtall_pre3 tmamtall_last3 tmamtall_preq2 tmamtall_preq3 tmamtnondurables_pre3 tmamtnondurables_last3 tmamtnondurables_preq2 tmamtnondurables_preq3 tmamttrad_dur_pre3 tmamttrad_dur_last3 tmamttrad_dur_preq2 tmamttrad_dur_preq3 tmamtdurable_pre3 tmamtdurable_last3 tmamtdurable_preq2 tmamtdurable_preq3 dependents i.surveyor i.week, robust 
		sum vardolbal_end_pre3_w if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		estadd scalar FKP=e(widstat)
		eststo c
		xi: ivreg2 tmamtall_post3_w (update_infla update_forex_ad = int_infla_gap int_forex_gap) gap_infla gap_forex tmbal_end_pre3 tmbal_end_last3 tmbal_end_preq2 tmbal_end_preq3 tmamtall_pre3 tmamtall_last3 tmamtall_preq2 tmamtall_preq3 tmamtnondurables_pre3 tmamtnondurables_last3 tmamtnondurables_preq2 tmamtnondurables_preq3 tmamttrad_dur_pre3 tmamttrad_dur_last3 tmamttrad_dur_preq2 tmamttrad_dur_preq3 tmamtdurable_pre3 tmamtdurable_last3 tmamtdurable_preq2 tmamtdurable_preq3 dependents i.surveyor i.week, robust 
		sum tmamtall_post3_w if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		estadd scalar FKP=e(widstat)
		eststo d
	}
	
	
	*esttab a b c d, r2 star(* 0.10 ** 0.05 *** 0.01) compress br se b(3) se(3) label
	esttab a b c d using "santiago/iv_expend_beliefs_extended.tex", replace ///
	substitute(\begin{tabular} \resizebox{1\textwidth}{!}{\begin{tabular} \end{tabular} \end{tabular}}) ///
	keep(update*) star(* 0.10 ** 0.05 *** 0.01) ///
	scalars("N Observations" "mean_depvar Outcome Mean" "sd_depvar Outcome SD" "FKP Kleiberg-Paap F-statistics" ) ///
	sfmt(%9.0fc %9.3fc %9.3fc %9.3fc) ///
	mtitles("Dur." "Trad. Dur." "Debt" "Total") ///
	mgroups("Transaction Data", pattern(1 0 0 0 ) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	compress se b(3) se(3)  label ///
	collabels(none) nonotes noobs ///
	varlabels(update_infla "\$ \Delta \$ Inflation" update_forex_ad "\$ \Delta \$ Exchange Rate")	
	
* Make final adjustment of table in R	
	

*filename <-"santiago/iv_expend_beliefs_extended.tex"

*cis <- read_excel("santiago/results.xls",col_names= F)
*colnames(cis) <- c("des","ci")
*cis <- separate(cis,col=2,into=c("infla1","infla2","er1","er2"),sep=",")
*cis$infla <- paste0(cis$infla1,",",cis$infla2)
*cis$er <- paste0(cis$er1,",",cis$er2)

*#data <- read.table(filename,sep=" ",header=T)

*b <- readLines(filename)
*sink(file = "Output/Tables/iv_expend_beliefs_extended.tex")

*cat(b[1:10])
*cat(c(" Weak IV 95\\% CI & ",cis$infla[1]," & ",cis$infla[2]," & ",cis$infla[3]," & ",cis$infla[4] ,"\\\\\r\n"))
*cat(b[11:12])
*cat(" Weak IV 95\\% CI & ",cis$er[1]," & ",cis$er[2]," & ",cis$er[3]," & ",cis$er[4],"\\\\\r\n")
*cat(b[13:length(b)])

*sink(file = NULL)

*---------------------------------------------------------------------------
* Table 6: Effect of Information on Behavior, OLS
*---------------------------------------------------------------------------

	use "$data_file", clear

	estimates clear
	quietly{
	
		xi: reg tmamtdurable_post3_w update_infla update_forex_ad tmbal_end_pre3 tmbal_end_last3 tmbal_end_preq2 tmbal_end_preq3 tmamtall_pre3 tmamtall_last3 tmamtall_preq2 tmamtall_preq3 tmamtnondurables_pre3 tmamtnondurables_last3 tmamtnondurables_preq2 tmamtnondurables_preq3 tmamttrad_dur_pre3 tmamttrad_dur_last3 tmamttrad_dur_preq2 tmamttrad_dur_preq3 tmamtdurable_pre3 tmamtdurable_last3 tmamtdurable_preq2 tmamtdurable_preq3 dependents i.surveyor i.week, robust
		sum tmamtdurable_post3_w if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo a
		xi: reg tmamttrad_dur_post3_w update_infla update_forex_ad tmbal_end_pre3 tmbal_end_last3 tmbal_end_preq2 tmbal_end_preq3 tmamtall_pre3 tmamtall_last3 tmamtall_preq2 tmamtall_preq3 tmamtnondurables_pre3 tmamtnondurables_last3 tmamtnondurables_preq2 tmamtnondurables_preq3 tmamttrad_dur_pre3 tmamttrad_dur_last3 tmamttrad_dur_preq2 tmamttrad_dur_preq3 tmamtdurable_pre3 tmamtdurable_last3 tmamtdurable_preq2 tmamtdurable_preq3 dependents i.surveyor i.week, robust
		sum tmamttrad_dur_post3_w if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo b
		xi: reg vardolbal_end_pre3_w update_infla update_forex_ad tmbal_end_pre3 tmbal_end_last3 tmbal_end_preq2 tmbal_end_preq3 tmamtall_pre3 tmamtall_last3 tmamtall_preq2 tmamtall_preq3 tmamtnondurables_pre3 tmamtnondurables_last3 tmamtnondurables_preq2 tmamtnondurables_preq3 tmamttrad_dur_pre3 tmamttrad_dur_last3 tmamttrad_dur_preq2 tmamttrad_dur_preq3 tmamtdurable_pre3 tmamtdurable_last3 tmamtdurable_preq2 tmamtdurable_preq3 dependents i.surveyor i.week, robust
		sum vardolbal_end_pre3_w if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo c
		xi: reg tmamtall_post3_w update_infla update_forex_ad tmbal_end_pre3 tmbal_end_last3 tmbal_end_preq2 tmbal_end_preq3 tmamtall_pre3 tmamtall_last3 tmamtall_preq2 tmamtall_preq3 tmamtnondurables_pre3 tmamtnondurables_last3 tmamtnondurables_preq2 tmamtnondurables_preq3 tmamttrad_dur_pre3 tmamttrad_dur_last3 tmamttrad_dur_preq2 tmamttrad_dur_preq3 tmamtdurable_pre3 tmamtdurable_last3 tmamtdurable_preq2 tmamtdurable_preq3 dependents i.surveyor i.week, robust
		sum tmamtall_post3_w if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo d
		
	}
	
	*esttab a b c d, r2 star(* 0.10 ** 0.05 *** 0.01) compress br se b(3) se(3) label
	esttab a b c d using "$output/Tables/post_expend_updates.tex", replace ///
	substitute(\begin{tabular} \resizebox{1\textwidth}{!}{\begin{tabular} \end{tabular} \end{tabular}}) ///
	keep(update*) star(* 0.10 ** 0.05 *** 0.01) ///
	scalars("N Observations" "r2 \$R^2\$" "mean_depvar Outcome Mean" "sd_depvar Outcome SD") ///
	sfmt(%9.0fc %9.3fc %9.3fc) noobs ///
	mtitles("Durables" "Trad. Dur." "Debt" "Total") ///
	mgroups("Transaction Data", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	compress se b(3) se(3) label ///
	collabels(none) nonotes ///
	varlabels(update_infla "\$\Delta\$ Inflation" update_forex_ad "\$\Delta\$ Exchange Rate")

	
*---------------------------------------------------------------------------
* Table 7: Effect of Information on Survey Outcomes
*---------------------------------------------------------------------------

* ssc install varlabels

	use "$data_file", clear

* Using survey responses as dependent variable (NO LASSO)
	estimates clear
	quietly{
		xi: reg update_infla int_infla_gap gap_infla int_forex_gap gap_forex tmbal_end_pre3 tmbal_end_last3 tmbal_end_preq2 tmbal_end_preq3 tmamtall_pre3 tmamtall_last3 tmamtall_preq2 tmamtall_preq3 tmamtnondurables_pre3 tmamtnondurables_last3 tmamtnondurables_preq2 tmamtnondurables_preq3 tmamttrad_dur_pre3 tmamttrad_dur_last3 tmamttrad_dur_preq2 tmamttrad_dur_preq3 tmamtdurable_pre3 tmamtdurable_last3 tmamtdurable_preq2 tmamtdurable_preq3 dependents i.surveyor i.week, robust
		sum update_infla if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo a
		xi: reg update_forex_ad int_forex_gap gap_forex int_infla_gap gap_infla tmbal_end_pre3 tmbal_end_last3 tmbal_end_preq2 tmbal_end_preq3 tmamtall_pre3 tmamtall_last3 tmamtall_preq2 tmamtall_preq3 tmamtnondurables_pre3 tmamtnondurables_last3 tmamtnondurables_preq2 tmamtnondurables_preq3 tmamttrad_dur_pre3 tmamttrad_dur_last3 tmamttrad_dur_preq2 tmamttrad_dur_preq3 tmamtdurable_pre3 tmamtdurable_last3 tmamtdurable_preq2 tmamtdurable_preq3 dependents i.surveyor i.week, robust
		sum update_forex_ad if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo b
		xi: reg post_durable int_infla_gap  gap_infla int_forex_gap gap_forex tmbal_end_pre3 tmbal_end_last3 tmbal_end_preq2 tmbal_end_preq3 tmamtall_pre3 tmamtall_last3 tmamtall_preq2 tmamtall_preq3 tmamtnondurables_pre3 tmamtnondurables_last3 tmamtnondurables_preq2 tmamtnondurables_preq3 tmamttrad_dur_pre3 tmamttrad_dur_last3 tmamttrad_dur_preq2 tmamttrad_dur_preq3 tmamtdurable_pre3 tmamtdurable_last3 tmamtdurable_preq2 tmamtdurable_preq3 dependents i.surveyor i.week, robust
		sum post_credit_durable if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo c
		xi: reg post_electronic int_infla_gap gap_infla int_forex_gap gap_forex tmbal_end_pre3 tmbal_end_last3 tmbal_end_preq2 tmbal_end_preq3 tmamtall_pre3 tmamtall_last3 tmamtall_preq2 tmamtall_preq3 tmamtnondurables_pre3 tmamtnondurables_last3 tmamtnondurables_preq2 tmamtnondurables_preq3 tmamttrad_dur_pre3 tmamttrad_dur_last3 tmamttrad_dur_preq2 tmamttrad_dur_preq3 tmamtdurable_pre3 tmamtdurable_last3 tmamtdurable_preq2 tmamtdurable_preq3 dependents  i.surveyor i.week, robust
		sum post_electronic if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo d
		xi: reg post_credit_durable int_infla_gap gap_infla int_forex_gap gap_forex tmbal_end_pre3 tmbal_end_last3 tmbal_end_preq2 tmbal_end_preq3 tmamtall_pre3 tmamtall_last3 tmamtall_preq2 tmamtall_preq3 tmamtnondurables_pre3 tmamtnondurables_last3 tmamtnondurables_preq2 tmamtnondurables_preq3 tmamttrad_dur_pre3 tmamttrad_dur_last3 tmamttrad_dur_preq2 tmamttrad_dur_preq3 tmamtdurable_pre3 tmamtdurable_last3 tmamtdurable_preq2 tmamtdurable_preq3 dependents  i.surveyor i.week, robust
		sum post_credit_durable if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo e
		xi: reg post_credit_card int_infla_gap gap_infla int_forex_gap gap_forex tmbal_end_pre3 tmbal_end_last3 tmbal_end_preq2 tmbal_end_preq3 tmamtall_pre3 tmamtall_last3 tmamtall_preq2 tmamtall_preq3 tmamtnondurables_pre3 tmamtnondurables_last3 tmamtnondurables_preq2 tmamtnondurables_preq3 tmamttrad_dur_pre3 tmamttrad_dur_last3 tmamttrad_dur_preq2 tmamttrad_dur_preq3 tmamtdurable_pre3 tmamtdurable_last3 tmamtdurable_preq2 tmamtdurable_preq3 dependents i.surveyor i.week, robust
		sum post_credit_card if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo f

	}

	esttab a b c d e f using "$output/Tables/reduced_form_w_survey_dependent_variable.tex", replace ///
	substitute(\begin{tabular} \resizebox{1\textwidth}{!}{\begin{tabular} \end{tabular} \end{tabular}}) ///
	keep(int*) star(* 0.10 ** 0.05 *** 0.01) ///
	scalars("N Observations" "r2 \$R^2\$" "mean_depvar Outcome Mean" "sd_depvar Outcome SD") ///
	sfmt(%9.0fc %9.3fc %9.3fc %9.3fc) noobs ///
	mtitles("\$\Delta\$ Inflation" "\$\Delta\$ Depreciation" "Dur." "Trad. Dur." "Debt" "Total") ///
	mgroups("Survey Data", pattern(1 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))    ///
	compress se b(3) se(3) label ///
	collabels(none) nonotes ///
	varlabels(int_infla_gap "\$\left(\pi_{i,t}^{signal} - \pi_{i,t}^{prior}\right)\cdot T_{i,t}^{\pi}\$" int_forex_gap "\$\left(d_{i,t}^{signal} - d_{i,t}^{prior}\right)\cdot T_{i,t}^{d}\$") 

*---------------------------------------------------------------------------
* Table C1: Robustness check: reduced form
*---------------------------------------------------------------------------
	
	use "$data_file", clear
	
	* Robustness check

estimates clear
	quietly{
		xi: reg update_infla int_infla_gap int_forex_gap prior_infla prior_forex_ad female age age2 have_child dependents college ln_Y household_size i.surveyor i.week, robust
		sum update_infla if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo a
	xi: reg update_forex_ad int_forex_gap int_infla_gap prior_infla prior_forex_ad female age age2 have_child dependents college ln_Y household_size i.surveyor i.week i.surveyor i.week, robust
		sum update_forex_ad if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo b
		
		xi: reg tmamtdurable_post3_w int_infla_gap int_forex_gap prior_infla prior_forex_ad tmamtdurable_pre3_w female age age2 have_child dependents college ln_Y household_size i.surveyor i.week i.surveyor i.week, robust
		sum tmamtdurable_post3_w if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo c
	
		xi: reg tmamttrad_dur_post3_w int_infla_gap int_forex_gap prior_infla prior_forex_ad tmamttrad_dur_pre3_w female age age2 have_child dependents college ln_Y household_size i.surveyor i.week, robust
		sum tmamttrad_dur_post3_w if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo d
		
		xi: reg tmrepayment_post3_w int_infla_gap int_forex_gap prior_infla prior_forex_ad female age age2 have_child dependents college ln_Y household_size i.surveyor i.week, robust
		sum vardolbal_end_pre3_w if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo e
		
		xi: reg tmamtall_post3_w int_infla_gap int_forex_gap prior_infla prior_forex_ad tmamtall_pre3_w female age age2 have_child dependents college ln_Y household_size i.surveyor i.week, robust											
		sum tmamtall_post3_w if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo f
	}
	*esttab a b c d e f g, keep(gap* int*) r2 star(* 0.10 ** 0.05 *** 0.01) compress br se b(3) se(3) label
	esttab d e f c using "$output/Tables/reduced_form_robust_check.tex", replace ///
	substitute(\begin{tabular} \resizebox{1\textwidth}{!}{\begin{tabular} \end{tabular} \end{tabular}}) ///
	keep(int*)  star(* 0.10 ** 0.05 *** 0.01) ///
	scalars("obs Observations" "r2 \$R^2\$" "mean_depvar Outcome Mean" "sd_depvar Outcome SD") ///
	sfmt(%9.0fc %9.3fc %9.3fc) noobs ///
	mtitles("Durables" "Trad. Dur." "Debt" "Total") ///
	mgroups( "Transaction Data", pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))    ///
	compress se b(3) se(3) label ///
	collabels(none) nonotes ///
	varlabels(int_infla_gap "\$\left(\pi_{i,t}^{signal} - \pi_{i,t}^{prior}\right)\cdot T_{i,t}^{\pi}\$" int_forex_gap "\$\left(d_{i,t}^{signal} - d_{i,t}^{prior}\right)\cdot T_{i,t}^{d}\$") 

	
*---------------------------------------------------------------------------
* Table 4: Reduced Form, Effect of Information on Expectations and Behavior
* Income (split)
*---------------------------------------------------------------------------

use "$data_file", clear

* Calculate mean annual income
drop if gap_forex <= -12 | gap_forex >= 5


estimates clear
	quietly{
		xi: reg update_infla int_infla_gap int_forex_gap prior_infla prior_forex_ad female age age2 have_child dependents college ln_Y household_size i.surveyor i.week, robust
		sum update_infla if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo a
	xi: reg update_forex_ad int_forex_gap int_infla_gap prior_infla prior_forex_ad female age age2 have_child dependents college ln_Y household_size i.surveyor i.week i.surveyor i.week, robust
		sum update_forex_ad if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo b
		
		xi: reg tmamtdurable_post3_w int_infla_gap int_forex_gap prior_infla prior_forex_ad tmamtdurable_pre3_w female age age2 have_child dependents college ln_Y household_size i.surveyor i.week i.surveyor i.week, robust
		sum tmamtdurable_post3_w if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo c
	
		xi: reg tmamttrad_dur_post3_w int_infla_gap int_forex_gap prior_infla prior_forex_ad tmamttrad_dur_pre3_w female age age2 have_child dependents college ln_Y household_size i.surveyor i.week, robust
		sum tmamttrad_dur_post3_w if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo d
		
		xi: reg tmrepayment_post3_w int_infla_gap int_forex_gap prior_infla prior_forex_ad female age age2 have_child dependents college ln_Y household_size i.surveyor i.week, robust
		sum vardolbal_end_pre3_w if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo e
		
		xi: reg tmamtall_post3_w int_infla_gap int_forex_gap prior_infla prior_forex_ad tmamtall_pre3_w female age age2 have_child dependents college ln_Y household_size i.surveyor i.week, robust											
		sum tmamtall_post3_w if e(sample)		
		estadd scalar mean_depvar = r(mean)
		estadd scalar sd_depvar=r(sd)
		eststo f
	}
	esttab a b c d e f using "$output/Tables/reduced_form_filter_referee_report.tex", replace ///
	substitute(/begin{tabular} /resizebox{1/textwidth}{!}{/begin{tabular} /end{tabular} /end{tabular}}) ///
	keep(int*) star(* 0.10 ** 0.05 *** 0.01) ///
	scalars("N Observations" "r2 \$R^2\$" "mean_depvar Outcome Mean" "sd_depvar Outcome SD") ///
	sfmt(%9.0fc  %9.3fc %9.3fc %9.3fc) noobs ///
	mtitles("\$\Delta\$ Inflation" "\$\Delta\$ Depreciation" "Durables" "Trad. Dur." "Debt" "Total" ) ///
	mgroups( "Survey Data" "Transaction Data", pattern(1 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))    ///
	compress se b(3) se(3) label nonotes ///
	collabels(none) ///
	varlabels(int_infla_gap "\$\left(\pi_{i,t}^{signal}-\pi_{i,t}^{prior}\right)\cdot T_{i,t}^{\pi}\$" int_forex_gap "\$\left(d_{i,t}^{signal}-d_{i,t}^{prior}\right)\cdot T_{i,t}^{d}\$") 

