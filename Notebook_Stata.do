





-------------------------------------------
mixed logit后计算支付意愿
Stata   mixlogitwtp 和bayesmixedlogitwtp 都可以
R语言  logitr包 https://cran.r-project.org/web/packages/logitr/index.html
-------------------------------------------
给stata数据库加标签
label data "xxxxd"
-------------------------------------------
An easy way to create duration variables in binary cross-sectional time-series data
ssc install mkduration
-------------------------------------------
* 动态文件编写
* markstat命令 https://data.princeton.edu/stata/markdown
** https://zhuanlan.zhihu.com/p/29707051
* 将下面括号部分存一个 .stmd 文件(Stata设好路径因为要插入图！)，然后跑 markstat using d:\aa.stmd , docx
{
% 演示文档
% 唐程翔
% `s c(current_date)`

Let us read the fuel efficiency data that is shipped with Stata

    sysuse auto, clear

To study how fuel efficiency depends on weight it is useful to
transform the dependent variable from "miles per gallon" to
"gallons per 100 miles"

    gen gphm = 100/mpg

We then obtain a more linear relationship

    twoway scatter gphm weight || lfit gphm weight ///
        , ytitle(Gallons per Mile) legend(off)
    graph export auto.png, width(500) replace

![Fuel Efficiency](auto.png){width="60%"}

That's all for now!上面的code部分在word中没有加框区分，在html加框了。
这个width设置对word没用，对html管用。

}

```s/
    quietly sysuse auto, clear
    quietly gen gphm = 100/mpg
	
    eststo clear
    quietly eststo:  regress gphm foreign
    mat b = e(b)
    quietly sum weight
    scalar mw = r(mean)
    quietly eststo:  reg gphm weight foreign
    scalar dom = _b[_cons] + _b[weight] * mw
    local f %6.2f
	
    esttab
```

The table below shows average fuel efficiency in gallons per 100 miles for foreign 
and domestic cars before and after adjustment for weight:

| Car Type   | Unadjusted            | Adjusted                  |
|:-----------|----------------------:|--------------------------:|
| Foreign    | `s `f' b[1,1]+b[1,2]` | `s `f' dom + _b[foreign]` |
| Domestic   | `s `f' b[1,2]`        | `s `f' dom`               |

-------------------------------------------
动态文件编写(stata14终于能完美支持ASCII中文了）： markdoc, ketchup
help weaver  // weaver里面的markdown子命令一直用不了
这两个命令更好：
help markdoc // 只能输出docx，tex，pdf 
help ketchup // 只能输出pdf, html，for teaching handout, lecture notes
** markdoc 里面的 txt dynamic-text 绝对值得大书一笔！ 可以使用macro，  e.g.  txt why$Rterm_path
例子 D:\stata11\ado\personal\markdoc-5.0.2
------
* markdoc是一个Stata命令
* Markdown是一种语言主要在R中使用，Markdown is a markup language (非常有用) with plain text formatting syntax
------
help sjlatex  // 像stata journal文章一样写pdf文档
help sjlog    // 任何记录进log的部分，转成latex文件

e.g.
	use http://www.ats.ucla.edu/stat/stata/notes/hsb2
	sjlog using desc_hsb2
	des
	sjlog close
	sjlog type desc_hsb2.log.tex
-------------------------------------------
*给dta加notes
help notes
notes: xxxx //把xxxx加到当前dta
-------------------------------------------
*event study事件研究
help eventdd  //画图特别好
其他命令  estudy  eventstudy  eventstudy2  
help eventstudy2
-------------------------------------------
*分组填充
carryforward
xfill
bysort id: replace number=number[1]    //组内第一个替代每一个
-------------------------------------------
*用统计table画图-collapse/contract ：Make dataset of summary/freq statistics这个命令太好了
preserve
  collapse draft, by(timing year) //Make dataset of summary statistics
  gen ldraft=log(draft)
  twoway(connect ldraft year if timing==1955, lcolor(black)) ///
	(connect ldraft year if timing==1956,msymbol(diamond) lcolor(pink) lpattern(dash)), legend(off) ///
	text(10.49 1955.5 "Collectivization in 1955 (569 counties)", color(black)) ///
	text(10.58 1955.7 "Collectivization in 1956 (1031 counties)", color(pink)) ///
	xline(1954, lcolor(black)) xline(1955, lcolor(pink) lpattern(dash)) ///
	xtitle("year") ytitle("log(number of draft animals)")
restore
-------------------------------------------
*分类变量画图
help mrgraph
help mrtab
-------------------------------------------
*画图 + code修图
sysuse auto, clear
twoway scatter mpg rep78, msize(small) ||,   ///
	graphregion(margin(r+50)) yti("里程数") xti("1978年的维修次数")

gr_edit AddTextBox added_text editor `=82+8' `=101'
gr_edit added_text_new = 1
gr_edit added_text_rec = 1
gr_edit added_text[1].text = {}
gr_edit added_text[1].text.Arrpush "Mean mpg by rep78"
gr_edit AddTextBox added_text editor `=82+2' `=112'
gr_edit added_text_new = 2
gr_edit added_text_rec = 2
gr_edit added_text[2].text = {}
gr_edit added_text[2].text.Arrpush "rep78  mpg"
-------------------------------------------
*同时显示多个窗口graph
grss twoway histogram price, frequency bin(20)
grss twoway histogram weight, frequency bin(20)
-------------------------------------------
*标记参与了回归的样本
reg price rep78 weight length foreign
gen esample=1 if e(sample) //标记参与了回归的样本
su price rep78 weight length foreign if esample==1

-------------------------------------------
*合并时，调整graph图的纵横比
graph combine 1.gph 2.gph , ysize(2) xsize(4)
-------------------------------------------
一个相见恨晚的stata命令
sixplot
精简散点图
binscatter  //一个相见恨晚的stata命令
多文件匹配
mmerge
-------------------------------------------
基于putdocx的4个命令： reg2docx, sum2docx, t2docx，corr2docx
-------------------------------------------
* zero inflated regression (most Y zero)
help zinb //Zero-inflated negative binomial regression (Y is a nonnegative count var)
help zip  //Zero-inflated Poisson regression
-------------------------------------------
* Longitudinal data可视化
help xtline
help xtgraph

* boxplot箱线图，https://wiki.mbalib.com/wiki/%E7%AE%B1%E7%BA%BF%E5%9B%BE
gr box x1 x2  //看几个变量(样本)是否具有有对称性，分布的分散程度。

* 3个命令Plots of mean CI over time - twoway lfitci ; caterpillar; ciplot
twoway lfitci yvar xvar

help caterpillar 
help ciplot  //这种图也叫 Caterpillar 

ciplot yhb , by(ym) //医护比

-------------------------------------------
* 直接输出table产生的大panel到excel
help xtable 
xtable mdate region,  cont(mean zfy) filename("肠道疾病门诊费用.xlsx") sheet(table1, replace) replace
-------------------------------------------
DCE设计
help dcreate  //Efficient designs
-------------------------------------------
* 分析幂律, 私人组件 powerlaw（已装） http://coin.wne.uw.edu.pl/mbrzezinski/software
doedit example.do //使用powerlaw，没有help文件，但有例子example.do
见NoteExpress： Brzezinski, M. 2014. Do wealth distributions follow power laws? Evidence from `rich lists'. Physica A 406: 155-162.
 /* Fitting Data into Power Distribution: Estimating alpha and x0. It's not a matter of estimating the 2 parameters together in one step
  Fit your model using -paretofit- for multiple thresholds over a plausible range, and from this, calculate the K-S statistics. */
* R语音
poweRlaw: Analysis of Heavy Tailed Distributions
* 分析分布
help pwlaw  //基于一个变量，计算power统计量Stata journal  D:\aa\LITERATURE\POOL-2014\10.1177@1536867X20953571.pdf
help    qplot //有power law, 见NoteExpress：Speaking Stata: The protean quantile plot. Stata Journal, 2005. 5(3): p. 442-460.
help distplot
				//Do wealth distributions follow power laws?  D:\aa\LITERATURE\分级诊疗-自科\幂律和zipf\brzezinski2014.pdf
-------------------------------------------
webGL：graphical language
现在的所谓可视化工具：一还是基于我们单机的统计分析；二优点在于"交互性"和"面向网络"；
--D3是基于JS
--Plotly绘图底层基于D3
-------------------------------------------
JS：javascript, JSON=JavaScript Object Notation
help libd3 //a Mata wrapper around the D3 JavaScript library
help libjson
help libhtml
-------------------------------------------
//将这句three-way画图：tab ym hoslev , sum(wt) nost nofre 
	egen meanwt=mean(wt), by(ym hoslev)
	separate meanwt, by(hoslev) 
	twoway connected meanwt? ym2, c(L L) sort
	
	egen meancmi=mean(cmi), by(ym hoslev) //分类分组求均数，然后按年月画图连线
	separate meancmi, by(hoslev) 
	twoway connected meanwt? ym2, c(L L) sort title(DRG相对权重) xtitle(年月) ytitle(平均值) msymbol(S Oh) xline(201803) legend(label(1 "二级医院")label(2 "三级医院"))
-------------------------------------------
*单纯转置stata数据库（非矩阵）
help xpose  //https://stata-club.github.io/%E6%8E%A8%E6%96%87/20161219/
help sxpose //Transpose of string variable dataset
*排序时sort只能一个方向，gsort可以两个
gsort +xx 或者 -xx
-------------------------------------------
*Speaking Stata: Between tables and graphs
help graph dot //可以实时运行，显示结果
help graph bar
https://www.stata-journal.com/sjpdf.html?articlenum=gr0034
-------------------------------------------
很其他的命令 taboutgraph:
Suppose you want to plot the output of the two-way tab function? Here is a program that will do it (see below). 
It is actually a wrapper for the tabout command. Some notes about the options:

using: put here the name of the filename that you want to save the tabout data to, in tab separated format. 
The graphs that this command produces will save graphs using the same filename but with different extension.

gc: this stands for graph command. You can use gc("graph bar"), gc("graph hbar")... and maybe others
go: this stands for graph options. These are the options that you would use for the graph command above (e.g. note, title, b1title, subtitle, etc)
ta: this stands for tabout options. These are the options you would use with the tabout command (e.g. c(), f(), etc.) 

taboutgraph var1 var2 [aw=weight] using "filename_to_savedatato.csv", gc("graph bar") ta(cells(col) f(2 2 2 2)) replace go( note("Source: XXX") ///
			b1title("Quintile") title(`"Composition of Population"') ytitle("Percent of population in the quntile"))
-------------------------------------------
Stata处理大数据的新套件：
https://www.stata.com/stata-news/news34-1/users-corner/?utm_source=20190122news_34_1&utm_medium=email&utm_campaign=stata_news&utm_content=users_corner

-------------------------------------------处理多期的一般DID
https://www.econstor.eu/bitstream/10419/193498/1/1066764190.pdf
这篇文章的命令 flexpaneldid: A Stata command for causal analysis with varying treatment time and duration
help flexpaneldid
help flexpaneldid_preprocessing

help bacondecomp  //Bacon decomposition of DID estimation with variation in treatment timing

* 小聪的DID命令
{
webuse nlswork  //使用系统自带数据库
xtset idcode year, delta(1)  //设置面板
xtdescribe   //描述一下这个面板数据情况

gen age2= age^2
gen ttl_exp2=ttl_exp^2
gen tenure2=tenure^2

global xlist "grade age age2 ttl_exp ttl_exp2 tenure tenure2 not_smsa south race"
sum ln_w $xlist  //统计描述相关变量

———————————————————————————————————————————————
**DID方法-----------------------------------
gen time = (year >= 77) & !missing(year)  //政策执行时间为1977年
gen treated = (idcode >2000)&!missing(idcode) //政策执行地方为idcode大于2000的地方
gen did = time*treated  //这就是需要估计的DID，也就所交叉项

reg ln_w did time treated $xlist //这就是一个OLS回归，也可以用diff命令
xtreg ln_w did time treated $xlist i.year, fe //也可以这去做，会省略掉一个虚拟变量

—————————————————————————————————————————————
**PSM-DID方法-------------------------------

** PSM的部分
set seed 0001	//定义种子
gen tmp = runiform() //生成随机数
sort tmp //把数据库随机整理
psmatch2 treated $xlist, out(ln_w) logit ate neighbor(1) common caliper(.05) ties //通过近邻匹配，这里可以要outcome，也可以不要它
pstest $xlist, both graph  //检验协变量在处理组与控制组之间是否平衡
gen common=_support
drop if common == 0  //去掉不满足共同区域假定的观测值
psgraph

** DID的部分，根据上面匹配好的数据
reg ln_w did time treated $xlist 
xtreg ln_w did time treated $xlist i.year, fe

**PSM-DID部分结束--------------------------------------
—————————————————————————————————————————
*交互项 
help xi 
**DID方法需要满足的五个条件检验------------------------

**1.共同趋势假设检验

tab year, gen(yrdum) //产生year dummy，即每一年一个dummy变量
     forval v=1/7{
gen treated`v'=yrdum`v'*treated
}                     //这个相当于产生了政策实行前的那些年份与处理虚拟变量的交互项
xtreg ln_w did treated*  i.year ,fe  //这个没有加控制变量
xtreg ln_w did treated* $xlist i.year ,fe //如果did依然显著，且treated*这些政策施行前年份交互项并不显著，那就好
xtreg ln_w did treated* $xlist i.year if union!=1 ,fe //我们认为工会会影响这个处理组和控制组的共同趋势，因此我们看看union=0的情形

**2.政策干预时间的随机性
gen time1 = (year >= 75) & !missing(year)  //政策执行时间提前到1975年
capture drop treated1
gen treated1= (idcode >2000)&!missing(idcode) //政策执行地方为idcode大于2000的地方
gen did1 = time1*treated1  //这就是需要估计的DID，也就所交叉项

gen time2 = (year >= 76) & !missing(year)  //政策执行时间提前到1976年
capture drop treated2
gen treated2= (idcode >2000)&!missing(idcode) //政策执行地方为idcode大于2000的地方
gen did2 = time2*treated2  //这就是需要估计的DID，也就所交叉项

xtreg ln_w did1 $xlist i.year,fe 
xtreg ln_w did2 $xlist i.year,fe //看看这两式子里did1和did2显著不,显著为好

**3.控制组将不受到政策的影响
gen time3 = (year >= 77) & !missing(year) 
capture drop treated3 
gen treated3= (idcode<1600 & idcode>1000)&!missing(idcode) //我们考虑一个并没有受政策影响地方假设其受到政策影响
gen did3 = time3*treated3  
xtreg ln_w did3 $xlist i.year,fe //最好的情况是did3不显著，证明控制组不受政策影响


**4.政策实施的唯一性，至少证明这个政策才是主要影响因素
gen time4 = (year >= 77) & !missing(year)  
capture drop treated4
gen treated4= (idcode<3000 & idcode>2300)&!missing(idcode) //我们寻找某些受到其他政策影响的地方
gen did4 = time4*treated4  
xtreg ln_w did4 $xlist i.year,fe //did4可能依然显著，但是系数变小，证明还受到其他政策影响

**5.控制组和政策影响组的分组是随机的

xi:xtivreg2 ln_w (did=hours tenure) $xlist i.year,fe first //用工具变量来替代政策变量，解决因为分组非随机导致的内生性问题

————————————————————————————————
**附加的，一般而言，我们需要看看这个政策的动态影响-------------
     forval v=8/15{
gen treated`v'=yrdum`v'*treated  
}               //注意，这里yrdum8就相当于year=78
	
reg  ln_w treated*  

xtreg  ln_w treated*, fe

xtreg ln_w treated* i.year,fe 

xtreg ln_w treated* $xlist i.year,fe  //一般而言上面这些式子里的treated*应该至少部分显著


倍分法 (DID)多个现成命令：
help diff   //sj16-1
help ddid   //Pre-post-treatment estimation of the Average Treatment Effect (ATE) with binary time-varying treatment
didq        //Treatment-effect estimation under alternative assumptions, SJ 15(3):796--808
help absdid //Semiparametric difference-in-differences estimator of Abadie (2005), SJ16-2, 附数据和范例
——————————————————————————————————————
* RDD 多个断点--包括分析、画图、稳健 Analysis of regression-discontinuity designs with multiple cutoffs or multiple scores
https://journals.sagepub.com/doi/pdf/10.1177/1536867X20976320

**RDD断点回归在这里的应用-------------------

tab treated,missing
keep if treated==1
cmogram ln_w year,cut(77) scatter lineat(77) qfitci //绘制断点回归图形

**最优带宽
set more off
rdbwselect ln_w year if 60<=year&year<=85,c(77) kernel(uni) //自己下载安装
rdob ln_w year, c(77)                      //这个命令是imbens新开发的，这里有rdob的程序

reg ln_w time $xlist if 60<year&year<80  //直接对time这个虚拟变量做了ols

}
-------------------------------------------
字符中的dot .
count if regexm(pattern, "\.")  不能用 count if regexm(pattern, ".")
通配符 regexm(str, "[0-9]+\.[0-9]*[%]$") 
-------------------------------------------
面板from unbalanced to balanced
help xtpatternvar
	* 定义面板 hosid ym
	encode hosid , gen(hid)
	xtset hid ym 
	 //unbalanced to balanced
	xtpatternvar, gen(pattern)
	codebook patt
	fre patt , as
-------------------------------------------
矩阵画图
	svmat A
	drop in 24
	gen n=_n
	graph twoway connected A1 n
-------------------------------------------

-------------------------------------------
自动比较两个数据库的变量
help cfvars 文件1 文件2
-------------------------------------------
		//按每个变量值（880种病）导出
	cd  "d:\icd"
	levelsof icd10c , local(levels)
	qui foreach l of local levels {
		export excel using "`l'.xlsx" 	  if icd10c=="`l'" , first(var) replace 	
		drop  if icd10c=="`l'" 
	}
-------------------------------------------
超大数据-内存利用超97%，首先进去drop变量
https://www.cpc.unc.edu/research/tools/data_analysis/statatutorial/misc/large_files
describe using "bigfile.dta"  //不打开bigfile
lookfor and lookfor_all
use list_of_variables using
use in
use if
use if inrange(runiform(),0,.1) using "bigfile.dta"
-------------------------------------------
Stata已经发展了一套"截断时序回归"的module
help itsa
help itsamatch
help itsaperm
-------------------------------------------
茂睿画了很多类似的阴阳hist图
sysuse nlsw88
twoway (histogram wage if union==1, frequency color(gs11) lwidth(none)) ///
				(histogram wage if union==0, frequency color(none) lwidth(medium) lcolor(navy)  legend(order(2 "Non-union" 1 "Union")))
-------------------------------------------
用tab icd10遇到unique值太多的时候，又只想看频率最多的前10个
groups icd10, order(h) select(10)
groups  xx  ,  saving(tab1, replace) //生成唯一值表，用于合并
-------------------------------------------
我觉得最像R的stata图风
set scheme plotplain 
-------------------------------------------
列所有标签
labelbook
-------------------------------------------
SAS怎么导出成Stata格式呢？经过摸索，其实很简单，新建一个代码窗口，输入：
data houlsehold;
set "/folders/myshortcuts/SAS/houlsehold.sas7bdat";  /*注意这是Linux路径 */
proc export data=houlsehold outfile= "/folders/myshortcuts/SAS/houlsehold.dta";
run;
恩就这么简单。其中set后面设置成你的数据文件名的路径（注意前面的/folders/myshortcuts/SAS/，windows下可能略有不同），outfile=后面是你要保存的路径，注意后缀名写.dta，SAS就自动识别出你要转成Stata格式啦。
-------------------------------------------
*解决--csv含20位ID和中文字符，后缀1,2,4表示第1,2,4个变量 字符型导入。
  PS：Stata无法加载16位以上数字digits并保持精度(会损失尾数精度)，这种情况只能以字符型处理
import delimited D:\aa\桌面\aa.csv, stringc(1,2,4) encoding(gb2312) clear 
-------------------------------------------
字符变量转数值变量
encode hosid , gen(hid) 
decode  //vise verse
-------------------------------------------
findname -- List variables matching name patterns or other properties
-------------------------------------------
Stata 15 SE 永久安装版
Serial number: 401506209499

Code: uk4n 5fLi 6wk3 n7q4 kv6h s2ea 719
Authorization: gc83
-------------------------------------------
*inequality不平等
/*第一步：计算Gini 或 CI （常常画图）
  第二步：分解
			1）动态or面板：decomposition of a change in inequality 
				   -- Stata命令：dsginideco(2017) - Decomposition of inequality change into pro-poor growth and mobility components
								 adecomp(2012) - Shapley Decomposition by Components of a Welfare Measure
			2）截面
				   -- Stata命令：INEQDECO--Inequality decompositions by subgroup
								 trnbin0 -- count data Yvar 集中指数非线性分解法
								 ineqrbd -- Regression-based inequality decomposition, following Fields (2003) 
								 ineqfac(2009) -- Inequality decomposition by factor components, following Shorrocks (1982a, b)
								 fgt_ci -- calculates and decomposes Foster–Greer–Thorbecke (and standard) concentration indices
								 rifireg(2016) - Recentered Influence Function (RIF) for (bivariate) rank dependent indices (I) regression */
-------------------------------------------
 **======= Table - r1_mandatory and r2_mandatory's before-after mean comparison - by countries
{
preserve
     * sample selection 
 drop if Country=="" | r1==.  // r1 和 r2 的missing obs完全一样
     * T-test and mean comparison
 encode Country, gen(country)  // string → numerical, so can be used by next ttab
	 foreach v in 1 2 {
	 
		 ttab r`v'_mandatory, by(post) over(country)      // calculate difference
		 mat r=r(coefs)
		 ttab r`v'_mandatory, by(post) // for total
		 mat t=r(coefs)

		 ttab r`v'_mandatory, by(post) over(country) tshow // calculate t-stat
		 mat rr=r(coefs)
		 ttab r`v'_mandatory, by(post) tshow
		 mat tt=r(coefs)

		 tabstat r`v'_mandatory , by(country) s(mean count) save  // calculate mean and observations
		 tabstatmat A

		 mat rr=[r\rr]
		 mat tt=[t\tt]
		 mat rr=[rr,tt]
		 mat rr=rr'
		 mata: st_matrix("rr" , select(st_matrix("rr"),(1,1,1,0,0,1))) //2个mata函数，2个功能
		 mat out`v'=[rr, A] 
		 
	   }
  mat out=[out1 , out2]
  mat colnames out = "Before IFRS" "After IFRS" Diff T-stat Total N  "Before IFRS" "After IFRS" Diff T-stat Total N 
  mat rownames out = AUSTRALIA AUSTRIA BELGIUM CANADA DENMARK FINLAND FRANCE GERMANY GREECE "HONG KONG" INDIA INDONESIA IRELAND ITALY JAPAN KOREA(SOUTH) MALAYSIA NETHERLANDS NORWAY PAKISTAN PHILIPPINES PORTUGAL SINGAPORE "SOUTH AFRICA" SPAIN SWEDEN SWITZERLAND TAIWAN THAILAND "UNITED KINGDOM" "UNITED STATES" Total
     * 格式化out矩阵，加star
  local bc = rowsof(out)
  mat star = J(`bc' , 12 , 0)
  foreach v in 4 10  {
   forvalues k = 1/`bc' {
	  if abs(out[`k' , `v']) <= 1.645  {
	  mat star[`k' , `v'] = 0
	  }
	   else if (abs(out[`k' , `v']) > 1.645 & abs(out[`k' , `v']) <= 1.96 ){
	  mat star[`k' , `v'] = 1
	  }
	   else if (abs(out[`k' , `v']) > 1.96  & abs(out[`k' , `v']) <= 2.58 ){
	  mat star[`k' , `v'] = 2
	  }
	   else if abs(out[`k' , `v']) > 2.58 {
	  mat star[`k' , `v'] = 3
	  }
	  }
	  }
     * output word
  frmttable using output /*in default word */, statmat(out) annotate(star) asymbol(*,**,***) sdec(2,2,2,2,2,0,2,2,2,2,2,0 ) landscape a4  //tex option写成latex文件
restore
}
-------------------------------------------
*一次出6连图（描述分布、正态、柱状）：
sixplot var
-------------------------------------------
* Stata-summary estimates Forest plot of study-specific estimates 合并效应值的森林图
数据录入且进行了对数转换后，在命令窗口输入：
metanlogrr loglci loguci, label(namevar=author) fixed effect(RR) eform //如果是随机效应模型，则把"fixed"改为"random"）

* 只分析proportion -- Metaprop: a Stata command to perform meta-analysis of binomial data
help metaprop_one //升级针对stata13以上版本

* coefplot -- plotting regression coefficients and other estimates
http://www.stata.com/meeting/germany14/abstracts/materials/de14_jann.pdf
-------------------------------------------
* 快速合并系列命名dta
	qui fs *.dta //list文件名
	foreach f in `r(files)' {
	qui append using `f'
	}
-------------------------------------------
* logit回归，输出表格以Odds ratio (OR) 即 exponentiated coefficient形式加z检验系数（eform）
*           或输出 Confidence Interval (CI), 
esttab urban  urbanfe  $usertf ,  $tab replace  nonum  mtitles("Logit model" "Logit model with FE") cells(b(star fmt(%9.3f)) ci(par))  keep(2.edu 3.edu age gender)    eform z   
-------------------------------------------
ScienceDirect的Appendix文件下载：
1、先打开 http://www.sci-hub.cn/ ，
2、搜索文章标题，进入sci-hub保存下载页，
3、再进入文章的正常页面（此时默认代理状态），即可下载Appendix
-------------------------------------------
有了inlist，你还在一直用if吗？
if语句：    gen x=1 if rep78==1|rep==3|rep==4|rep==5
inlist函数：gen x=1 if inlist(rep78,1,3,4,5)
            gen y=1 if inlist(make,"AMC Concord","AMC Pacer","Buick","Ford")
-------------------------------------------
单纯的截图tiff，png调整分辨率96dpi → 300dpi
打开Photoshop，图像 → 图像大小
-------------------------------------------
egen用法：
egen zong=noccur(c),s(",")  //某字符在变量中出现的次数
                            //counting the number of times a string appears in a string variable
-------------------------------------------
epidata文件导出
6数据导出 -> Stata格式 -> 选择.rec文件
-------------------------------------------每个项目用open_work_space或openws，打开文献、word、网页、程序
DOS快捷打开
::打开pdf或默认方式打开任意文件
start ""   "D:\aa\LITERATURE\POOL-2014\tri12307.pdf"
::目录方式打开文件夹
start explorer "D:\desk\Dropbox\IFRS and Inst"
::
-------------------------------------------
取消Word文档中所有超链接
先Ctrl+A(全选)；
然后，Ctrl+Shift+F9(取消超级链接)。
-------------------------------------------
fdta _all , from("AMC") to("SUV")  // 专门替代(字符变量)字符的命令，比subinstr()函数好用太多
fdta _all , from("AMC")  // 替代性删除
-------------------------------------------
chinagcode  //利用百度地图获取中国地址的经纬度
-------------------------------------------
预测forecast, projection
help forecast  // a suite of commands for obtaining forecasts by solving models
               // https://thinkinator.com/2013/08/08/statas-forecast-command/
help fxbcr##03
序列填充
	tsset Year
	tsappend , add(21)
-------------------------------------------
*正态检验画图
	help diagnostic_plots
    swilk  x  // z>2.14代表x不服从正态； p<0.01代表不服从正态
	pnorm  x  // 分布偏离斜线，也不服从正态。
	gen u=rnormal(8, 3)  //检验一下正态
-------------------------------------------
Stata前缀prefix
i.  to specify indicators for each level (category) of the variable
c.  to interact a continuous variable with a factor variable, just prefix the continuous variable with c.
L.  lag  x_t-1
F.  lead x_t+1
D.  diff (x_t)-(x_t-1)
S.  diff (x_t)-(x_t-1) (seasonal)

# between two variables to create an interaction–indicators for each combination of the categories of the variables. 
## instead to specify a full factorial of the variables—main effects for each variable and an interaction. 
help fvvarlist  // factor variable
-------------------------------------------
rdd stata module：
help rd
help rdcv
help rdplot // rdbinselect, rdbwselect, rdrobust

	
-------------------------------------------

一是用R，分辨率dpi和tiff压缩随便调
 # 导出600dpi的tiff压缩图片
tiff(file = "C:/test1.tiff", res = 600, width = 4800, height = 4800, compression = "lzw")
plot(1:22, pch = 1:22, cex = 1:3, col = 1:5) #绘图命令在中间
dev.off()
二是figure画图出图终极解决方案--使用Ghostscript-gswin64c.exe：
win10环境下安装Ghostscript
	http://fgsservices.co.uk/blog/fred-knows/how-tos/install-ghostscript-windows-10/
	https://fgsservices.co.uk/blog/fred-knows/how-tos/install-ghostscript-windows-10-step-2/
 win10环境下根据下面步骤添加 C:\Program Files\gs926\bin
	https://www.architectryan.com/2018/03/17/add-to-the-path-on-windows-10/
# Stata出矢量pdf，然后Stata用 !gswin64c.exe 将pdf转tiff (也可设定dpi=r600，和压缩方式lzw)
     graph export "D:\fig1.pdf"   // 出矢量pdf
     !gswin64c.exe -dSAFER -dBATCH -dNOPAUSE -r600 -sDEVICE=tiff24nc -sCompression=lzw  -sOutputFile="D:\fig1.tiff"  "D:\fig1.pdf"
     erase "D:\fig1.pdf" 

  用自建程序 figen, fig(D:\fig1) 取代上面这段，括号中=路径和名称
  viewsource figen.ado //看ado,这个命令已定型，切勿再改
  doedit "D:\stata11\ado\myado/figen.ado"

cap prog drop figen
prog figen 
syntax,  [if] [in]  fig(str)
     graph export "`fig'.pdf"  
     !gswin64c.exe -dSAFER -dBATCH -dNOPAUSE -r600 -sDEVICE=tiff24nc -sCompression=lzw  -sOutputFile="`fig'.tiff"  "`fig'.pdf"
     erase "`fig'.pdf" 
end
-------------------------------------------
Stata & Mplus 联用调用
 -- dta格式转Mplus的dat格式：
stata2mplus using c:\data\hsb2.dta  // this creates c:\data\hsb2.dat and c:\data\hsb2.inp 
 -- Stata中运行Mplus
help runmplus  // see:  http://www.lvmworkshop.org/home/runmplus-stuff
-------------------------------------------
复制数据
expand 2 if ...     // if范围内obs翻2倍
expand n , gen(id)  // 所有obs翻n倍，同时产生id区分新旧obs
-------------------------------------------
tempfile  master  part1
// 使用
save "`master'" , replace
append using "`part1'" 
// 查看
macro list
// 清除
macro drop _all
-------------------------------------------
同时检验所有回归假设：
help regcheck
-------------------------------------------
esttab 导出latex table，需要\label{tab2}, 直接在esttab选项里 title(...\label{tab2})
-------------------------------------------

unicode convertfile：
	converts text files from one encoding to another encoding.  It is a low-level utility that will feel familiar to those of you who have used the Unix command iconv or the similar International Components for Unicode (ICU)-based command uconv.  
unicode translate：
	If you convert Stata datasets (.dta) or text files commonly used with Stata such as do-files, ado-files, help files, CSV files; 
ustrfrom() and ustrto() functions：
	If you wish to convert individual strings or string variables in your dataset, use the .
----------- 
Stata 14 使用了 Unicode（统一码、万国码）
Stata 14 的dofile只识别UTF-8编码，以前版本dofile都需要 convert to UTF-8 by Notepad++ 
------------ 
stata 14 数据库打开时会乱码，转码如下：
cd d:\对应目录
unicode analyze *.do  //或者 .dta数据文件
unicode encoding set gb18030
unicode translate *.do
-------------------------------------------
画图比较多个分组的均值和分布：
help stripplot
-------------------------------------------
今天自编gr2tex(利用texdoc) ：一输出graph为pdf保存；二将引用latex code插入draft
global path  D:\desk\Googledrive\fj_pilot_organ
cd $path 
sysuse auto
scatter price wei
gr2tex , pdf($path\draft\output\aa)  draft($path\draft\bws_organ)


----使用python语言在Stata中：
python
exit()
shellout python_plugin.pdf //详细介绍
这样用Stata可以直接操作R和Python两大语言，相当方便！
-------------------------------------------
Stata text processing文本处理思路：
excel导入到Stata数据库 → mata矩阵 → frmttable处理
-------------------------------------------
LaTeX and Stata integration: 很漂亮的表
tex3pt -- creates LaTeX documents from esttab output using the LaTeX package threeparttable.
texdoc -- write into tex file. (texdoc 用Stata14跑一直出错，只能13跑)
-------------------------------------------
Stata命令合并pdf
use command line with "pdftk" to merge the individual pdfs into a master file
!rm master_file.pdf
!pdftk g1.pdf g2.pdf cat output master_file.pdf
winexec xpdf master_file.pdf -z 300

Stata打开一个文件夹
shell explorer "G:\data\PKU_SC"

Stata打开一个网页链接
!start /max http://www.ats.ucla.edu/stat/mplus/dae/lca1.htm

Stata以keyword为字符变量，逐个代入网页，拷贝网页内容 // http://www.wxzhi.com/archives/719/w9civo4zk0dkkspa/
levelsof keyword,local(levels)
foreach c of local levels {
    copy "http://www.baidu.com/s?wd=`c'" "D:\temp.txt",replace
    infix strL v 1-200000 using "D:\temp.txt",clear
    keep if index(v," 百度为您找到相关结果约")
    replace v = ustrregexs(1) if ustrregexm(v," 约(.+?)个")
    local date = c(current_date)
    local time = c(current_time)
    post baidu ("`date'") ("`time'")("`c'") (v[1])
}
postclose baidu
use"D:\baidu.dta",clear
replace baidu = ustrregexra(baidu,",","")
destring baidu,replace
------------------------------------------
levelsof命令的含义为"Distinct levels of a variable"，对变量的不同取值进行排序
levelsof varname [if] [in] [, options]

sysuse auto
replace make=substr(make, 1, 4)
levelsof make ,clean separate(;) local(make) matcell(freq)
display "`make'"
matrix l freq
-------------------------------------------
* 读入tab_BWS_aggregate_score.csv 然后用mata转成Latex表
import delim using "d:\tab_BWS_aggregate_score.csv"  , clear
gen att_id=_n 
rename v1 att_name
order att_id , b(att_name)
* tex output :  texsave把Stata数据库中数据做成latex表格
texsave _all using "d:\tab_BWS_aggregate_score.tex" , frag replace  ///
		title(Aggregated best-worst scores)  ///
		footnote(Note: The number of respondents is xxx) 
-------------------------------------------
如何将summary矩阵表格化tabulating matrix as publication:
*****frmttable*****, 其可以利用outreg的选项，如annotate(pcts) asymbol("\%")加百分号
                   ，还可以自由改表头
-------------------------------------------
如何将estimation矩阵表格化tabulating matrix as publication:
estout  或者frmttable(outreg) - outreg太多bugs，常需要run几次才能出一个表格
estout是esttab的细节版，太麻烦不推荐。

*****esttab最推荐*****，因为esttab可以调用estout的选项，比如：
esttab  using .\draft\output\tab6_Doctors_treatment_prescriptions   ,   ///
			booktabs  replace  $tex_fmt  ///
			mgroups("Minor illness" "Major illness", pattern(1 1) ) ///
			mtit("(overtreatment)"  "(undertreatment)") ///
			title("Whether Doctors honestly prescribe treatment")  
	* esttab 后面用booktabs选项是单线条表格，用tex是双线条
        *注意：esttab  和 estimates table是两个命令
-------------------------------------------
 输出表格table命令汇总：
Summary statistics → plain text and LATEX files  with tabout (Watson 2007), outreg2, estpost(distributed with the estout)
estimation tables  → Word and LATEX tables       with outreg (which uses frmttable for formatting) 
                   → plain text and LATEX tables with outreg2 (Wada 2005), estout(Jann 2007), esttab(a wrapper for estout)
                   → formatted Excel file        with xml-tab (Lokshin and Sajaia 2008) ，选择性输出改动excel： putexcel(Stata 13)
 * 最强的(可将matrix完美输出成table)：
estimation/Summary → Word and LATEX tables       with frmttable (gallup 2012) , outtable (Baum and Azevedo 2008)
                                                 outreg(gallup 2013)是frmttable的升级包装版，outreg可用frmttable的选项

 * 教你各种表格（可自动run命令）
help tabletutorial
 * 输出后各类型文件转换、编译
help translate  //-- Print and translate logs
help texify   // 等价于 !pdflatex myoutput.tex -no-shell-escape
help ttab   // ttab is basically a wrapper for ttest and estout. 大规模ttest时用

• The "estout package" contains four commands:
esttab: User-friendly command to produce publication-style regression tables for screen display or in various export(CSV, RTF, HTML, or LaTeX)
estout: Generic program to compile regression tables (engine behind esttab)
estadd: Program to add extra results (such as beta coefficients) to e() so that they can be tabulated.
eststo: Improved version of estimates store.
-------------------------------------------
csv和rtf对比：1)rtf不要划线，csv要。 2)

table输出Excel(csv)终极解决方案：
	foreach v of varlist $covs { 
		  estpost tab `v' cl , chi2  // cl=cluster，是分层指示变量
	quiet esttab  using "$path\BWS_organ\new_survey\tab_BWS_aggregate_score.csv", cells("b(label(freq)) colpct(fmt(2))") unstack nonumber noobs append 
			} 

	esttab  CL   using 2.csv, mtitles("Conditional Logit")  nogaps pr2 scalars(ll r2_p ) nodep nonum se unstack append
	
table输出Word(rtf)终极解决方案：
	esttab urban  using 2.rtf  ,  unstack replace  nonum    ///
		mtitles("Logit model")   ///
		starlevels(* 0.10 ** 0.05 *** 0.01)   addnotes("* p<0.10, ** p<0.05, *** p<0.01")   ///
        cells(b(star fmt(%9.3f)) se(par))      ///
		stats(N ll chi2 r2_p bic, star(chi2) fmt(%9.0g %9.3f))   ///
		varlabels(edu "Higher education"  age "Age"  gender "Male"  _cons Constant) 
-------------------------------------------
选中一行代码用什么快捷键
把光标放在行的开始，按住shift+end，或把光标放在行的末尾，按住shift+home
-------------------------------------------
安装Stata dofile 的Notepad++ 接口
http://blog.sina.com.cn/s/blog_6d29073a0102uxi3.html
我设的run do-lines: ctrl + D    ;    run do-file: F3
-------------------------------------------
shell erase do_file.do  //shell (等价"!") allows you to send commands to your operating system
shell                   // or to enter DOS界面
!erase      myfile.txt  // DOS命令erase/del一样
!del        myfile.tex
!rename try15.dta   final.dta

!rmdir D:\aa\manydoc\bak.stunicode  /s /q   //多运行一遍, 删除整个文件夹

winexec notepad "d:\myfile.txt"   //Stata命令 allows you to open file by using notepad
----------------Stata输出eps图，插入Latex，再编译---------------------------
	cd d:\
	sysuse auto
* run reg
	eststo mytab: reg mpg weight length
	esttab mytab using "mytable.tex", style(tex) replace
* draw graph.eps, turn to .pdf
	scatter mpg length
	graph export mygraph.eps, replace
	!epstopdf mygraph.eps  // 将eps图片转pdf,适合在latex中插入
* compile pdf by latex
	!pdflatex myoutput.tex -no-shell-escape   /* epstopdf和pdflatex都是MiTex的功能
                                                   shell-escape是pdflatex的一个选项 */
	!pdflatex  CTang_CV.tex  -output-directory=.\output\    //定向编译
	!copy .\output\CTang_CV.pdf      .\             //再copy pdf到本文件夹

% Latex file myoutput.tex
\documentclass[11pt]{article}
\usepackage{graphicx}

\begin{document}

\section{My table}
\input{mytable.tex}

\section{My graph}
\includegraphics{mygraph.pdf}

\end{document}

---------------Stata回归、制table，插入Latex----------------------------
program main
    prepare_data
    run_regressions
    output_table
end 

program prepare_data
    use ../external/tv_potato.dta, clear 
    xtset countycode year 
    label variable log_chip_sales "Log Chip Sales" 
    label variable tv_linear "TV"
end 

program run_regressions  // 调用下面的 program setup_table
    local dep_var   "log_chip_sales"
    local tv_vars   "tv_linear"
    local vce       "vce(cluster countycode)"
    
    eststo: reg `dep_var' `tv_vars', `vce'
    setup_table, unitvar(countycode) timevar(year)
    
    eststo: xtreg `dep_var' `tv_vars', `vce'
    setup_table, unitvar(countycode) timevar(year)
    
    eststo: reg `dep_var' `tv_vars' i.year, `vce'
    setup_table, unitvar(countycode) timevar(year)
    
    eststo: xtreg `dep_var' `tv_vars' i.year, `vce'
    setup_table, unitvar(countycode) timevar(year)
end

program setup_table   // 被上面的program run_regressions调用
    syntax, unitvar(varname) timevar(varname) 
		if "`e(ivar)'" == "`unitvar'" {
			estadd local unit_fe "Yes"
		}
		else {
			estadd local unit_fe "No"
		}
    local cmdline "`e(cmdline)'"
    local cmd_substr : subinstr local cmdline "i.`timevar'" "", count(local cmd_time_fe) 
		if `cmd_time_fe' == 1 {
			estadd local time_fe "Yes"
		}
		else {
			estadd local time_fe "No"
		}
end 

program output_table 
    esttab using ../output/regressions.tex, ///
        replace drop(*.year) ///
        obslast se label nonotes nomtitles collabels(none) ///
        cells(b(star fmt(4)) se(par fmt(4)))  ///
        scalars("unit_fe County Fixed Effects" "time_fe Year Fixed Effects") ///
        mgroups("Log of Chip Sales", pattern(1) prefix(\multicolumn{@span}{c}{) ///
            suffix(}) span erepeat(\cmidrule(lr){@span})) 
end 

main  // 启动执行

-------------------------------------------
// 改scheme
help schemes

set scheme Plottig, permanently  // plottig 和 plotplain , 一个是对 Stata 的单色模板的改进，一个是仿 ggplot 风格。  https://danbischof.com/2015/02/04/stata-figure-schemes/
set scheme plotplain, permanently 
set scheme  s2mono , permanently  //s2monochrome 是我一直用的喜欢scheme

sysuse auto
histogram price, scheme(michigan) percent title("Automobile Prices")  // 非常漂亮图模
-------------------------------------------
if year==1960     //don't do this!
if year[1]==1960  // right, first observation is 1960
-------------------------------------------
mata: istmt   //for programmers,单行不要end
mata:   //if an error occurs, you are dumped from mata
    istmt   
end   
mata    //if an error occurs, still stay in mata
    istmt   
end  
---------------Stata矩阵区别于mata矩阵，得互相调用----------------------------
st_view() make Mata matrices "x" from a Stata dataset "varname"
st_data() Load copy of current Stata dataset
st_numscalar() obtain value from colsum(x) and put into r(sum)
    // mata里面用Stata的矩阵切记加双引号""
 mata: st_matrix("rr" , select(st_matrix("rr"),(1,1,1,0,0,1))) //3个mata函数，3个功能，st_matrix()将stata中的matrix转给mata
 mata: st_matrix("temp"):/st_matrix("xiaono")  //element-by-element相除， 相乘用 :*
 mata: st_matrix("JJ", st_matrix("aa"):/st_matrix("minorno"))  //JJ是Stata矩阵不是mata矩阵
-------------------------------------------
Mata最大优点：可任意自编函数 → 问题来了：很多函数如何储存？ → mata mosave tryit() 或者 mata mlib add lmylib tryit()
mata mosave 适用于少数函数
mata mlib 用于a group of functions, like library, 所以lmylib就是name of library
help mata mlib //还有子命令
-------------------------------------------
help max()      //两命令不同
help mata max()
mata query  // mata setting
-------------------------------------------
最常用两mata命令
mata describe
mata drop
mata clear
比如mata矩阵A，直接type矩阵名就可以list矩阵（不像Stata矩阵需要mat list命令）
A
end // Exiting Mata does not clear mata matrics
-------------------------------------------
mata: 
Z[., .]=X:-mean(X)  //每个ob减mean(X)就是center a variable on the mean
-------------------------------------------
mata (mata环境下命令左边是两个点colon)
viewsource diag.mata
help moremata  //see extra mata function, especially their source code
: mata stata sysuse auto //mata环境下使用Stata命令
permutation -- 交换,转置;  tolerance -- 界值,公差; 
: mata matsave  //生成 .mmat文件--save matrices
: mata mosave   //生成 .mo文件--function's compiled code
-------------------------------------------
local a: display %6.2f ln(10)  // local a: 后接命令， 类似 bysort hos: 
-------------------------------------------
dropvars list  //  for any list : capture drop X
-------------------------------------------
rreg y x2  // Robust regression 
-------------------------------------------
set seed ####   //给定初始数值，相同的初始数值生成的伪随机数列完全一致。
 uniform() is an out-of-date function as of Stata 10.1.  Now it's runiform() or rnormal(m, s)
help rnd  //random number generators -- 包括各种分布
-------------------------------------------
loop over all the observations:
   gen y=.
   forvalues i=1/`=_N' {
   replace y=x[`i'] if _n==`i'
       }
you'll get the exact same result far more quickly and easily with:
   gen y=x  
-------------------------------------------
mlexp — Maximum likelihood estimation of user-specified expressionshelp mlexp

-------------------------------------------
Stata 13 矩阵导出excel命令：
putexcel 
-------------------------------------------
Stata 处理ICD 9-10 命令族：
help icdpic   //最下面有一系列Also see

-------------------------------------------
Stata 做policy simulation：
help simex
-------------------------------------------
stata并行处理多个文件:
help parallel
https://github.com/gvegayon/parallel/blob/master/talks/20170727_stata_conference/20170727_stata_conference_handout.pdf
-------------------------------------------
sum时:
    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
 transaction |         8    2.04e+08    5.54e+07   1.38e+08   3.19e+08

*新命令fsum时:
fsum transaction  if n==600578 & date>date("2007-05-20","YMD") &  date<date("2007-05-31","YMD") ,f(11.0)  //日期

*输出所有var和var label
fsum , stats(n) label

例如将字符型日期2010-01-05 14:04:31.890 (bb)转换成数值型的05Jan2010:
gen double time=clock(bb,"YMDhms")
gen date=dofc(time)
format date=%td 
-------------+-------------------------------------------------------
 transaction |          8  203861620   55358549  137762489  319139848  
-------------------------------------------
debug:
set trace on
set trace off
-------------------------------------------
matlist  比matrix list 更方便display矩阵
-------------------------------------------
esttab  , r2 ar2 pr2  //可以调出显示model的R2，Adj-R2，Pseudo-R2
-------------------------------------------
赋值神令：
recode alt (1=1)(2=0), gen(ASC)  //不用gen就是replace；赋值规则是 gen ASC=0 if alt==2  |  ASC=1 if alt==1
-------------------------------------------
描述性分析：  
	cap !erase 2.csv // 省去手动删excel文件
	 // categorical var
	foreach v of varlist hl hisb_hc age edu gender marital $ill { 
		quiet estpost tab `v' if !mi($nomis)
		quiet esttab using 2.csv, cells(" b(label(freq)) pct(fmt(2))") unstack nonumber noobs append 
	    } 
	 // continuous var
	quiet estpost sum w if !mi($nomis)
	quiet esttab using 2.csv, cells(" mean(fmt(2)) sd(fmt(2)) ") unstack nonumber noobs append 
-------------------------------------------
直接从Stata使用SAS，SPSS数据库
usesas
usespss
-------------------------------------------
一图多线,画散点分布，回归拟合图
twoway (scatter read write) (lfit read write) (kdensity pr1)
-------------------------------------------
从字符串最后面开始删掉两个字符:
  replace county=reverse(county)
  replace county=reverse(substr(county,3,8))
-------------------------------------------
粘贴导入excel数据库时，遇到不将first row treat as var name原因：
第一行变量名有空格，
或用了long等Stata保留词
-------------------------------------------
3个命令模糊match or fuzzy merge:
reclink  2010
strgroup  2012 , 使用了merge后,针对_merge==3用strgroup
nearmrg   2012

-------------------------------------------
hot命令：
unique
bcuse
-------------------------------------------

destring var, replace   //字符转数字出现问题
出現"var contains nonnumeric characters"
解决办法:
gen byte notnumeric=real(var)==.    //real()是函数,里面放出问题的变量名
tab notnumeric
br if notnumeric==1                          //==1 where nonnumeric characters
-------------------------------------------
inlist()函数，省去大量 if 
keep if inlist(icd10,"O80.901","O82.901","700001","O80.001","H25.901","H26.901") 
-------------------------------------------
永久删除文件命令
erase xxx.dta
-------------------------------------------
encode可以完美的将字符型的factor变量 转换成 数值型的factor变量，而且带 label
-------------------------------------------
安装新命令： ssc install xxxx  ;  屏幕查找: ssc des xxxx
-------------------------------------------
今天发现fre  和 ins 命令很适合探索新变量
-------------------------------------------
>=2-level fixed effect in one model：
egen industry_firm=group(industry firm)  // or more FE var
方法一
regress y x1 x2 x3 x4  i.industry_firm
方法二
areg y x1 x2 x3 x4, absorb(industry_firm) // 交叉项产生2-level FE，8x9type=72 个dummies
方法三(可2个以上dummy变量)
aareg y x1 x2 x3 x4, absorb(industry firm) // 分开不等于交叉项， 8+9type=17 个dummies 
areg -- Linear regression with a large dummy-variable set
-------------------------------------------
tabulate province,gen(dumy)  // 就可以产生dumy1－dumy31变量，
reg y x1 x2 dumy2-dumy31   // 或者不产生，在回归的时候用xi命令
xi: reg y x1 x2 i.province
-------------------------------------------
egen用法：
egen zong=noccur(c),s(",")  //某字符在变量中出现的次数
                            //counting the number of times a string appears in a string variable
egen store_occupy_mean_price=mean(price)			  , by(store_id  occupy_id)
egen f_dropout_kids_only=count(student_id) if f_edu<12, by(school)
egen f_dropout_kids_only=tag(student_id)   if f_edu<12, by(school)  //create dummy var
-------------------------------------------
删除时间段:
drop if date2<date("01jan2010","DMY") | date2>date("30sep2011","DMY")
构造age（从单纯的年、月两个变量）
	gen birthdate=1
	gen bir=mdy(birthmonth, birthdate, birthyear) // 用原始birthmonth，缺失值少
	format bir %td
	gen age=(mdy(9,1,2014)-bir)/365.25
	drop birthdate bir	

日期
设变量x是字符型，且格式是"1-aug-02"
monthly(s1,s2[,Y])
date(s1,s2[,Y])

g m = monthly(actual_date, "MY")  //这里只能gen,不能replace,因为type mismatch
format m  %tmNN/CCYY

g d = date(x,"DM20Y")
form d  %td

//extract month and year component from a variable (dm) with %tm format（e.g.1953m1）
gen date = dofm(dm)
format date %d
gen month=month(date)
gen yr=year(date)

//一步到位牛逼的直接命令 https://blog.stata.com/2015/12/17/a-tour-of-datetime-in-stata-i/
help todate
help anythingtodate 

anythingtodate cysj ,k
 //出院时间
hist cysjc12 if cysjc12>date("2015-01-01", "YMD")

// YYYYMM date to "ym" Stata
gen ndate = 201606
gen sdate = "201606"
gen ndate2 = ym(floor(ndate/100), mod(ndate, 100))
gen sdate2 = ym(real(substr(sdate, 1, 4)), real(substr(sdate, -2,2)))
format *2 %tm
l
     +-----------------------------------+
     |  ndate    sdate   ndate2   sdate2 |
     |-----------------------------------|
  1. | 201606   201606   2016m6   2016m6 |
     +-----------------------------------+
// 
	gen  rysj2 = date(string(rysj,"%8.0f"),"YMD")
	format %td rysj2
	
-------------------------------------------
变量名称全部是英文小写
rename _all, lower

字符串变小写
replace xxx= strlower(xxx)
-------------------------------------------
显示变量不同取值两方法:
levelsof  x

egen g=group(x)
su g
l r(max)
-------------------------------------------
Durbin–Watson test 
estat dwatson : Performs Durbin-Watson test of residual autocorrelation following regress. The data must be tsset
因为自相关系数ρ的值介于-1和1之间，所以 0≤DW≤４
DW＝ O   ＜＝＞  ρ＝１　　即存在正自相关性
DW＝４   ＜＝＞  ρ＝-１　即存在负自相关性
DW＝２   ＜＝＞  ρ＝０　　即不存在（一阶）自相关性
　　因此，当DW值显著的接近于O或４时，则存在自相关性，而接近于２时，则不存在（一阶）自相关性。
-------------------------------------------
窗口查看,替代list命令
browse if oops>1   
-------------------------------------------
gen x= y + z  //合并字符
replace ctown = subinstr(ctown, "meizhou",  "putian", 1) // 替换变量ctown中的 meizhou 为 putian.
-------------------------------------------
quandl: 海量数据库网站, 数据直接使用命令
-------------------------------------------
Excel 2007 格式xlsx 输入:
import excel using sla_pop_year.xlsx, clear first
import excel using "$path\temp.xlsx", clear first cellrange(B31:C40) sheet("SALC")
-------------------------------------------
经过比较后,感觉很好的输出格式: (但, eform表示mlogit输出RRR-自然对数, tex输出Latex格式)

esttab m2 , drop(o.* 1b.* 2o.* 3o.* 4o.*)  [eform] unstack replace  [tex]  ///
            cells(b(star fmt(%9.3f)) se(par))   starlevels(* 0.10 ** 0.05 *** 0.01)   stats(N chi2 bic, star(chi2) fmt(%9.0g %9.3f))   varlabels(_cons Constant) 
-------------输出----esttab after margins?--------------------------
margins, dydx(_all) post
esttab using x.tex, label     // The key point here is the post option in margins, that tells margins to leave the results behind as if it were an estimation command.
-------------------------------------------
*中国地图 地理， 见 https://journals.sagepub.com/doi/pdf/10.1177/1536867X20976313
help cngcode //定位
help cnmapsearch //根据关键词搜索给定经纬度周边的兴趣点，返回兴趣点的名称、中文地址、距离、标签等。 
help cnaddress  //经纬度转中文地址
help cntraveltime 
-------------------------------------------
*老命令spmap（在12.0版本还可以run）已经升级为 grmap
help grmap

*Stata画地图--以spmap例子解释
 use "Italy-RegionsData.dta", clear  //打开"数据-库"
 spmap relig1 using "Italy-RegionsCoordinates.dta", id(id) //"底图库" 和 "数据-库"以id变量唯一识别link
                                                           // 原理：将"数据-库"中 relig1 变量 plot在"底图库"上面
*转地理数据into Stata库
shp2dta  -- reads a shape (.shp) and dBase (.dbf) file //栅栏文件shp和dbf都需要
mif2dta  -- converts MapInfo Interchange Format files (aka MIF files) to Stata 

*地理经纬
geocode3 -- google升级到API3了, 其利用insheetjson和libjson(json library)两包解析网页,再返回给mata
geocode3命令不认汉字, 只认拼音或汉字的utf-8编码
nearstat //计算距离distance命令
-------------------------------------------
快速列出變數有多少 missing data 缺失数据两命令:
 mdesc _all
关注缺失组和整体组的核心变量是否有显著性差异, 以此简单判断-缺失是否具有选择性:
fmiss  varlist, detail
把缺失值转换成数值，以便于数据的各种转换
mvencode _all, mv(999)    //Translate missing values in the data to 999
mvdecode _all, mv(999)    //Change 999 values back to missing values
-------------------------------------------
latex 导出sum结果: sutex
-------------------------------------------
查看返回结果:
return list      //看r()
ereturn list     //看e()
r()中的数据导入矩阵：
mat ic=nullmat(ic) \ r(wtp)
mat ic=nullmat(ic) \ r(wtp)   //column-join (\) operators 可向下连续扩展矩阵
                                row-joinn 逗号 ，
egen max=max(groupid_total)  //提取var的最大值
-------------------------------------------
重复values检测,去除: duplicates drop XXX, force
-------------------------------------------
复制创建新变量, var label和value label也一起复制过去:
clonevar newvar = varname
-------------------------------------------
cmp 命令可以处理多个probit, iv, logit,...的混合模型
-------------------------------------------
Stata 多个变量找缺失值
egen nmis=rmiss2(landval improval totval salepric saltoapr)
tab nmis   //4个obs没有缺失值, 9个obs有1个缺失值  http://www.ats.ucla.edu/stat/stata/faq/nummiss_stata.htm
-------------------------------------------
正态检验:
sktest var    // p<0.00 则var不是正态
-------------------------------------------
截取数字的个位数, 同理可退后二位,三位,四位数
gen y=mod(x,10)
-------------------------------------------
不公平计算的stata命令:
gini decomp:   "ginidesc" , "ineqdeco" ,  "ineqdec0"
各种系数计算:  "inequal"→ "inequal7"→升级→"ainequal"
-------------------------------------------
winsor & truncate 缩尾 & 截尾;  缩尾e.g.ln(1) → ln(1.01) 避免ln(1)=0
replace x=1.01            //目的是将离群值变成1%或99%分位值
-------------------------------------------
声明错误,但程序继续运行完
cap noisily reg y x
--------------------------------------------
看源程序  viewsource XXX.ado

查看系数矩阵  mat l e(b)
矩阵导出到excel
----------------Stata矩阵--------------------------------------------------
svmat  //   matrix -> variables , 注意：此命令不会抹掉existing data，而是自动列在后面
PS：svmat2 和 xsvmat 两个扩展命令
    如 svmat2 A , rnames(ym) full //可把所有rownames save into a variable
mkmat  // variables -> matrix
---------------------------------------------------------------------------
*将统计频数转入mat，再用mat转variables，再画图
tab  edu urban, matcell(aa)  // 频数直接存入矩阵aa
svmat aa
gen n=_n in 1/6
label define edu2 1"High_school" 2"SVD" 3"College" 4"Bachelor" 5"Master" 6"PhD"
label values n edu2
graph bar aa1 aa2 , over(n) ytitle(Number of physicians) b1title(Education) legend(label(1 Rural hospitals) label(2 Urban hospitals))

use "d:\我的文档\桌面\temp.dta", clear

gen a=1  //为了两年间数据均衡，删掉某一年没数据的医院
bysort hos: gen pn=sum(a)
bysort hos: egen b=max(pn)
drop if b<10
drop if regexm(hos,"漳平市妇幼保健院")
replace hos=subinstr(hos,char(10),"",.) //去除hos字符断行问题
encode hos, generate(hos1) //encode是为了下句mean的over选项

* -------方法一 倒数→哈氏乘法---------
label drop hos1
quietly: mean lfdc if year==2010,over(hos1) //over只能用numeric变量
mat lfdc1=e(b)
quietly: mean lfdc if year==2011,over(hos1)
mat lfdc2=e(b)
quietly:mean drugout if year==2010,over(hos1)
mat drug1=e(b)
quietly:mean drugout if year==2011,over(hos1)
mat drug2=e(b)

mat xx=[lfdc1\lfdc2]  // 右下斜杠是分行，逗号是并列。
mat yy=(drug1\drug2)

local aa=rowsof(yy)      //本loop将矩阵各值取倒数
local bb=colsof(yy)
forval x=1/`aa' {
forval y=1/`bb' {
mat yy[`x',`y']=1/yy[`x',`y']
}
}
mat ld=hadamard(xx,yy)   //哈氏乘法--元素*元素，且乘以倒数==相除
                       
local cn=e(over_labels)  //问题2，引用e(over_labels)赋值给ld 
mat rownames ld=2010 2011 
mat colnames ld="`cn'"
mat ldt=ld'
mat l ldt
local  : rownames ld

* -------另一种方法 tabstatmat---------
tabstat lfdc drugout if year==2010, by(hos) s(mean) save //save选项将结果存入r()
tabstatmat A  //关键命令
tabstat lfdc drugout if year==2011, by(hos) s(mean) save //save选项将结果存入r()
tabstatmat B

local cc=rowsof(A)
forval x=1/`cc'{
mat A[`x',1] = A[`x',1]/A[`x',2]
mat A[`x',2] = B[`x',1]/B[`x',2]
}
mat colnames A=2010 2011
mat l A

* -------比 tabstatmat 更好用的 statsmat ---------
   foreach x in 1 2 3{  // 先按三个病种Loop
     foreach v  of varlist day fee feeday drug drugday{  // 再每个病种的变量
	    statsmat `v' if case==`x', by(own) mat(`v'`x') s(mean sd) f(%3.2f) xpose
        }
		}
---------------------------------------------------
小数点后两位数格式：
f(%3.2f)
---------------------------------------------------
用宏控制同样的变量:
global indv "const lconsum lincome"
reg fee $indv
---------------------------------------------------
节省行数-----
#delimit; 
gen lnpergas=ln(pergas);gen lngasp=ln(gasp);
#delimit cr
---------------------------------------------------
subinstr(s1,s2,s3,n)函数的应用--在s1中剔除s2，依次替换成n个s3，e.g.
replace hos=subinstr(hos,char(10),"",.)
char(10)就是这个可恶的ASCII为10的Line Feed符号
另有妙用：
	count if length(subinstr(pattern, "1", "", .))==1  //Counting substrings within strings
---------------------------------------------------
tostring  
destring命令的后选项有个force，可用于强迫转换后对比不能转换的变量，如：
destring v17, gen(vv17) force   // 然后比较两个变量，如果没有异常则实施强制转换

截取字符函数
substr(s,2,4)    //从s的第2个字符开始截取4个字符
replace town=subinstr(town, "*" , "" , .)    //修改字符变量,删除字符中的星号* 或空格
汉字字符 Unicode string
help f_usubstr  or  usubinstr()
---------------------------------------------------
local cs 1  //while的loop好处是结果最终一起显示
while `cs' == 1 {
replace ---
local cf=0  // 归0，否则会无限循环，或者用exit
}
所以还是用 if 更好
if   `cs' ==1 {
}
---------------------------------------------------
csv后缀是excel文件输出，rtf后缀是word文件输出
import命令族里导入csv文件用 import delimit ，而不是import excel

	import excel using "$path\temp_tab.xlsx", clear sheet("医学专业招生在校毕业数52-2014") cellrange(:o45)
---------------------------------------------------
tabout--属于Stata自带基本命令，是基本统计量表格输出的好命令

tabstat的妙用：----要做多个变量按同一分组统计均数
tabstat v11-v16, by(v3) s(mean)
---------------------------------------------------
单变量--探索分布时，可用画图hist命令，非常直观
  hist fee if own==1 & icd10=="O80.901" & fee<6000 , bin(500) kden  name(a)
  hist fee if own==1 & icd10=="O80.001" & fee<6000 , bin(500) kden  name(b)
  gr combine  a b c d e f , row(3) col(2)
画kernel图更好，两个命令，第一个是官方命令：
help kdensity
help kdens
---------------------------------------------------
宝宝的项目教我使用outsheet，下面三个命令联合起来反复使用一个数据库，并输出数据
outsheet using 1.xls,replace
clear
use d:\我的文档\桌面\sum.dta 
---------------------------------------------------
开始三探索命令:  还有 fre  ， ins 命令很好用
d _all
sum _all
tab varname  

//怎么探索字符变量？
codebook  告诉missing值、有多少unique values

//获得变量的label name
describe
---------------------------------------------------
左下框内变量排位置用order和move命令--我老在ed框里面调，好傻啊：
 order varlist
---------------------------------------------------
在排序的时候可以用上两个变量，这样先name后year就不会乱了year
sort name year
而sort加选项stable可以使排序最简洁最快
sort X, stable
---------------------------------------------------
按分类求均值，如9种卫生机构，各自的pro1的均值。
tab type if num==1, sum(pro1)
---------------------------------------------------
数出每个单位有几个医生spe<4，赋值给各单位医生数变量pn。其a和b是中间产生的变量。
gen a=1 if spe<4
bysort org: replace pn=sum(a) if spe<4
bysort org: egen b=max(pn)     //egen是bysort org全部加总
bysort org:  gen b=max(pn)      //gen是逐个加总
replace pn=b
drop a b

egen abc=group(date hour shi)
Create racesex containing values 1, 2, ..., for the groups formed by race and sex and containing missing if race or sex are missing
 . egen racesex = group(race sex)
---------------------------------------------------
同一个变量前一个值赋给下一个：
forvalues var=1/7250 {
replace var=var[_n-1]  if var==.
}
drop if _n==_N //drop the last obs
---------------------------------------------------
区分： <缺失值>用.表示,比任何自然数都大，所以>60会包括缺失值, 所以一定要限制上限!!!
       <空字符>是one string missing value，程序中用""代替
---------------------------------------------------
检查<字符串变量>是否含所需字符：	
replace v=1  if regexm(id,"福建省")
replace v=3  if regexm(id,"县") | regexm(id,"区")
---------------------------------------------------
"/"和"-"的用法
一个变量内数字用1/7250，一个变量到另一个变量用pro1-pro7
---------------------------------------------------
// github拓展了ssc以外的Stata命令来源，
github install haghish/markdoc
help github  // https://github.com/haghish/github
help markdoc 
---------------------------------------------------
Stata-R语言联用
方法一: "rsource"  
	doedit "D:\aa\book_Stata_Latex_R\Stata_R_SP.do"
	已经修改profile.do文件, R-Stata联用设置 这样就可以在Stata中写R代码 调用R的功能
	global Rterm_path `"D:\R\R-4.0.3beta\bin\x64\Rterm.exe"'   //specify them in order to call R in Stata 
	global Rterm_options `"--vanilla"'
	//例子
	rsource, terminator(END_OF_R)
        library(foreign);
        rauto<-read.dta("myauto.dta", convert.f=TRUE);
        rauto;
        attributes(rauto);
        q();
    END_OF_R

方法二："rcall" 比rsource强的是有interactive模式
	从https://github.com/haghish/rcall 右上角Clone and download下载所有Stata moduler，从本机安装
	net install Rcall, replace from("d:\rcall")
	help rcall

	Stata和R的联用调用，做SP问卷输出和数据处理：
	1）问卷题目产生还是在Stata中用rsource，清晰好拷贝
	2）数据合并R比较好用
	3）数据分析Stata做得好，但复杂模型LCA借用R的BayesLCA包

	library("foreign", lib.loc="D:/R/R-Portable/App/R-Portable/library")
	data<-as.data.frame(med$alternatives$alt.1)   # med是list类型的对象, alt.1是attributes组合的对象
	write.dta(data,"d:/test.dta")
	* R里面的表格tab_BWS_aggregate_score.csv 输出，再用Stata转成Latex表
	rcall:data<-as.data.frame(scores$aggregate)   # med是list类型的对象, alt.1是attributes组合的对象
	rcall:write.csv(data,"d:/tab_BWS_aggregate_score.csv")  # 这个表待会读入Stata，然后用mata转成Latex表
	insheet using "D:\aa\CLDS\BMI\clds2016_m.csv", clear  	
	import delim using "d:\tab_BWS_aggregate_score.csv"  , clear
	texsave _all using "d:\tab_BWS_aggregate_score.tex" , frag replace  ///
			title(Aggregated best-worst scores)  ///
			footnote(Note: The number of respondents is xxx)  
	***例子：综合控制法
	rcall:data(gsynth)
	rcall:names(turnout)

	rcall:set.seed(123456)
	rcall:turnout.ub <- turnout[-c(which(turnout$abb=="WY")[1:15], sample(1:nrow(turnout),50,replace=FALSE)),]
							 
	rcall:out <- gsynth(turnout ~ policy_edr + policy_mail_in + policy_motor, ///
				  data = turnout.ub,  index = c("abb","year"), se = TRUE, inference = "parametric", r = c(0, 5),  ///
				  CV = TRUE, force = "two-way", parallel = TRUE, min.T0 = 8,  nboots = 1000, seed = 02139)

	rcall:print(out)

	rename var1 t
	tsset t
	twoway tsline att cilower ciupper,xline(0) yline(0) scheme(s2mono)

	rcall:out.mc <- gsynth(turnout ~ policy_edr + policy_mail_in + policy_motor, min.T0 = 8, ///
				  data = turnout.ub,  index = c("abb","year"), estimator = "mc", ///
				  se = TRUE, nboots = 1000, seed = 02139)
				  
	rcall:plot(out.mc, main = "Estimated ATT (MC)")
	rcall:print(out.mc)

	rename var1 t
	tsset t
	twoway tsline att cilower ciupper,xline(0) yline(0) scheme(s2mono)
	
方法三：在R语言中run Stata
library("RStata") # https://fsolt.org/blog/2018/08/15/switch-to-r.html#:~:text=Running%20R%20from%20Stata,the%20R%20output%20into%20Stata.

-------------------------------------------
Stata命令包升级：
adoupdate scat3, update   //升级单个外部命令，不加选项时检查所有待升级外部命令
   update   // 用于stata官方程序升级
---------------------------------------------------
第一次用stata做直方图，其实命令比想象中简单，开始搞复杂了，而且发现也可以跟随stata的界面操作学习命令！
直方图命令：
graph bar (count) city1, over(city, gap(20))   ytitle("卫生人员数量") b1title("各设区市") blabel(bar)
---------------------------------------------------
tab和table命令的输出格式很不一样！
---------------------------------------------------
创建鬼魂变量：--功能是实现列表的行下面再分行
gen int ghost=1
table ghost cat2 cat4, c(mean edu sd edu)
---------------------------------------------------
类似清屏的命令： display _newline(100)
   Stata 13 清屏命令：
cls
在括号前使用quiet静默执行命令，屏幕干净
qui{
xxxxx
}
---------------------------------------------------
区分Type和Format：
Format指显示格式，并不改变数据大小。（如日期也是以数字存储的，可用format改成日期，而且日期变量赋值给别的变量会变成数字，因为没有指定format）
Type指数据存储格式
-------如计算年龄age：gen age=(mdy(12,1,2009)-bir)/365.25，mdy是日期格式吗？
---------------------------------------------------
★注意：replace命令在使用时，如果赋值和原值相等，则不会计算在（？real changes made）
   PS：今天在计算1397个医院的人数时，结果只替代了1356个，就发现原来有41个医院前后人数相同。
---------------------------------------------------
按组group统计age：  by group,sort: sum age
---------------------------------------------------
编号：gen no=_n
---------------------------------------------------
