/* ----------------------------------------
Code exported from SAS Enterprise Guide
DATE: Tuesday, June 28, 2016     TIME: 10:52:31 AM
PROJECT: ForwardLine_Score_20160510_v1
PROJECT PATH: 
P:\offshore_office\frankji\forwardline\ForwardLine_Score_20160510_v1.egp
---------------------------------------- */

/* ---------------------------------- */
/* MACRO: enterpriseguide             */
/* PURPOSE: define a macro variable   */
/*   that contains the file system    */
/*   path of the WORK library on the  */
/*   server.  Note that different     */
/*   logic is needed depending on the */
/*   server type.                     */
/* ---------------------------------- */
%macro enterpriseguide;
%global sasworklocation;
%if &sysscp=OS %then %do; /* MVS Server */
	%if %sysfunc(getoption(filesystem))=MVS %then %do;
        /* By default, physical file name will be considered a classic MVS data 
set. */
	    /* Construct dsn that will be unique for each concurrent session under a 
particular account: */
		filename egtemp '&egtemp' disp=(new,delete); /* create a temporary data set */
 		%let tempdsn=%sysfunc(pathname(egtemp)); /* get dsn */
		filename egtemp clear; /* get rid of data set - we only wanted its name */
		%let unique_dsn=".EGTEMP.%substr(&tempdsn, 1, 16).PDSE"; 
		filename egtmpdir &unique_dsn
			disp=(new,delete,delete) space=(cyl,(5,5,50))
			dsorg=po dsntype=library recfm=vb
			lrecl=8000 blksize=8004 ;
		options fileext=ignore ;
	%end; 
 	%else %do; 
        /* 
		By default, physical file name will be considered an HFS 
		(hierarchical file system) file. 
		Note:  This does NOT support users who do not have an HFS home directory.
		It also may not support multiple simultaneous sessions under the same account.
		*/
		filename egtmpdir './';                          
	%end; 
	%let path=%sysfunc(pathname(egtmpdir));
        %let sasworklocation=%sysfunc(quote(&path));  
%end; /* MVS Server */
%else %do;
	%let sasworklocation = "%sysfunc(getoption(work))/";
%end;
%if &sysscp=VMS_AXP %then %do; /* Alpha VMS server */
	%let sasworklocation = "%sysfunc(getoption(work))";                         
%end;
%if &sysscp=CMS %then %do; 
	%let path = %sysfunc(getoption(work));                         
	%let sasworklocation = "%substr(&path, %index(&path,%str( )))";
%end;
%mend enterpriseguide;

%enterpriseguide

ODS PROCTITLE;
OPTIONS DEV=ACTIVEX;
GOPTIONS XPIXELS=0 YPIXELS=0;
FILENAME EGSRX TEMP;
ODS tagsets.sasreport12(ID=EGSRX) FILE=EGSRX STYLE=Analysis STYLESHEET=(URL=
"file:///C:/Program%20Files/SASHome/x86/SASEnterpriseGuide/4.3/Styles/Analysis.css"
) NOGTITLE NOGFOOTNOTE GPATH=&sasworklocation ENCODING=UTF8 options(rolap="on");




/*   START OF NODE: 01_setup   */
%LET _CLIENTTASKLABEL='01_setup';
%LET _CLIENTPROJECTPATH=
'P:\offshore_office\frankji\forwardline\ForwardLine_Score_20160510_v1.egp';
%LET _CLIENTPROJECTNAME='ForwardLine_Score_20160510_v1.egp';
%LET _SASPROGRAMFILE=;

GOPTIONS ACCESSIBLE;

*********************Project 
location*******************************************;
%let proj=/mnt/projects/locked/forwardline/scoring_201604/;

***************SAS code location*****************************;

libname  tar "&proj.sasdata";

****************************Old BizAgg 
file**************************************;
%let old_vs=Feb16; /*BizAgg version*/

%let old_name=BizAgg_Feb; /*BizAgg SAS dataset name*/

%let 
old_raw=/mnt/projects/locked/forwardline/scoring_201604/rawdata/602965.FWLINE.BIZAGGS.FEB16_20160320003947.CSV;/*raw 
data*/

****************************Recent BizAgg 
file**************************************;
%let New_vs=Mar16; /*BizAgg version*/ 

%let New_name=BizAgg_Mar;/*BizAgg SAS dataset name*/

%let 
New_raw=/mnt/projects/locked/forwardline/scoring_201604/rawdata/604436.FWLINE.BIZAGGS.MAR16.CSV;/*raw 
data*/

******************Pre Merge 
File***********************************************************;

%let 
Pre_file1=/mnt/projects/locked/forwardline/scoring_201604/rawdata/Pre_Merge_ProspectDB/p509019a_fline_afinal_20160318205225_forQMG.txt;/*raw 
data*/

%let file1_name=Pre_merge_file1; /*Pre Merge SAS dataset name*/

%let 
Pre_file2=/mnt/projects/locked/forwardline/scoring_201604/rawdata/Pre_Merge_ProspectDB/b509019a_fline_bcfinal_with_BIN_forQMG.txt;/*raw 
data*/

%let file2_name=Pre_merge_file2;/*Pre Merge SAS dataset name*/

*****************Post Merge 
File**************************************************;

%let 
Post_file=/mnt/projects/public/offshore_office/qtang/ForwardLine/rawdata/Live_FWL_POSTMP01_APR16; 
/*raw data*/

**********************Mcounter 
file************************************************;

%let Mcount_file=mail_counter_unlocked; /*raw data*/

*****************************Old Score and 
Decile**************************************;

%let 
old_score=/mnt/projects/locked/forwardline/scoring_201604/rawdata/listabc_09-2015_and_04-2016_scores_v2.CSV;/*raw 
data*/

*******************************Scoring data target 
file***********************************************************;

%let out=tar.FWL_Score_Cut_20160422; /*Post merge records with all the needed 
fields */
%let final_out=tar.final_out_20160422; /*Post merge records with some selected 
records by client, this may chage each time*/
%let select=selected_target_20160426; /*Dataset contains the selected records 
with the select instruction from Client*/
%let 
select_out=/mnt/projects/locked/forwardline/scoring_201604/Deliver/FWL_selected_target_20160426.txt; 
/*target out location*/












GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;


/*   START OF NODE: 02_BizAgg_Macro   */
%LET _CLIENTTASKLABEL='02_BizAgg_Macro';
%LET _CLIENTPROJECTPATH=
'P:\offshore_office\frankji\forwardline\ForwardLine_Score_20160510_v1.egp';
%LET _CLIENTPROJECTNAME='ForwardLine_Score_20160510_v1.egp';
%LET _SASPROGRAMFILE=;

GOPTIONS ACCESSIBLE;

%macro rename(class,suffix);
	%let k=1;

	%do %while(%scan(&class.,&k.) ne %str());
		%let var=%scan(&class., &k);	
		rename &var=&var.&suffix.;
		%let k = %eval(&k + 1);
	%end;
%mend;


%macro BizAgg_read(input,ouput,version);

data tar.&output.;
  INFILE "&input."
        LRECL=5000
        ENCODING="LATIN1"
        TERMSTR=CRLF
        DLM='2C'x
        truncover
        DSD 
		firstobs=2
/*		obs=4116876*/
;
    INPUT
      AMS_USER_TRACKINGID	:	$CHAR50.
BIN	:	$20.
SEQUENCE_NUMBER	:	$20.
FILLER01	:	8.
ATC032	:	8.
ATB019	:	8.
ATD034	:	8.
ATD035	:	8.
ACC001	:	8.
ACC002	:	8.
ATB001	:	8.
ATB002	:	8.
ATB003	:	8.
ATB004	:	8.
ATB005	:	8.
ATB006	:	8.
ATB007	:	8.
ATB008	:	8.
ATB009	:	8.
ATB010	:	8.
ATB011	:	8.
ATB012	:	8.
ATB013	:	8.
ATB014	:	8.
ATB015	:	8.
ATB016	:	8.
ATB017	:	8.
ATB018	:	8.
ATC020	:	8.
ATC021	:	8.
ATC022	:	8.
ATC023	:	8.
ATC024	:	8.
ATC025	:	8.
ATC026	:	8.
ATC027	:	8.
ATC028	:	8.
ATC029	:	8.
ATC030	:	8.
ATC031	:	8.
ATP036	:	8.
ATP037	:	8.
ATP038	:	8.
BRC010	:	8.
BRC011	:	8.
BRC012	:	8.
BRO015	:	8.
BRO016	:	8.
BRO017	:	8.
BRC013	:	8.
BRC014	:	8.
BRB005	:	8.
BRB006	:	8.
BRB007	:	8.
BRB001	:	8.
BRB002	:	8.
BRB003	:	8.
BRB004	:	8.
BRC008	:	8.
BRC009	:	8.
BRP018	:	8.
BRP019	:	8.
BRP020	:	8.
BRP021	:	8.
BRP022	:	8.
BRP023	:	8.
BKC006	:	8.
BKC007	:	8.
BKC008	:	8.
BKO009	:	8.
BKB001	:	8.
BKB002	:	8.
BKB003	:	8.
BKO010	:	8.
BKO011	:	8.
BKC004	:	8.
BKC005	:	8.
DMO003	:	$CHAR10.
CLB001	:	8.
CLC010	:	8.
CLC011	:	8.
CLC012	:	8.
CLC013	:	8.
CLB002	:	8.
CLB003	:	8.
CLB004	:	8.
CLB005	:	8.
CLC006	:	8.
CLC007	:	8.
CLC008	:	8.
CLC009	:	8.
CLO014	:	8.
CLO015	:	8.
CLP016	:	8.
CLP017	:	8.
CLP018	:	8.
CLP019	:	8.
CTC033	:	8.
CTC034	:	8.
CTC035	:	8.
CTC036	:	8.
FILLER02	:	8.
CTD038	:	8.
CTB001	:	8.
CTB002	:	8.
CTB003	:	8.
CTB004	:	8.
CTB005	:	8.
CTB006	:	8.
CTB007	:	8.
CTB008	:	8.
CTB009	:	8.
CTB010	:	8.
CTB011	:	8.
CTB012	:	8.
CTB013	:	8.
CTB014	:	8.
CTB015	:	8.
CTB016	:	8.
CTB017	:	8.
CTB018	:	8.
CTC021	:	8.
CTC022	:	8.
CTC023	:	8.
CTC024	:	8.
CTC025	:	8.
CTC026	:	8.
CTC027	:	8.
CTC028	:	8.
CTC029	:	8.
CTC030	:	8.
CTC031	:	8.
CTC032	:	8.
CTP039	:	8.
CTP040	:	8.
CTP041	:	8.
DMO004	:	$CHAR10.
DMO009	:	8.
ACC003	:	8.
ACC004	:	8.
ACC005	:	8.
ACC006	:	8.
IQC001	:	8.
IQC002	:	8.
IQC003	:	8.
JDC010	:	8.
JDC011	:	8.
JDC012	:	8.
JDB004	:	8.
JDB005	:	8.
JDB006	:	8.
JDO013	:	8.
JDO014	:	8.
JDB001	:	8.
JDB002	:	8.
JDB003	:	8.
JDC007	:	8.
FILLER03	:	8.
JDC009	:	8.
JDP015	:	8.
JDP016	:	8.
JDP017	:	8.
LGC004	:	8.
LGC002	:	8.
LGC003	:	8.
LSC010	:	8.
LSC011	:	8.
LSC012	:	8.
LSC013	:	8.
LSC014	:	8.
LSC015	:	8.
LSC016	:	8.
LSC017	:	8.
LSC018	:	8.
LSC019	:	8.
LSC020	:	8.
LSC021	:	8.
LSC022	:	8.
LSC023	:	8.
LSC024	:	8.
LSC025	:	8.
LSC026	:	8.
LSC027	:	8.
LSC028	:	8.
LSC029	:	8.
LSC030	:	8.
LSB001	:	8.
LSB002	:	8.
LSB003	:	8.
LSB004	:	8.
LSB005	:	8.
LSC031	:	8.
LSC032	:	8.
LSC033	:	8.
LSB006	:	8.
LSB007	:	8.
LSB008	:	8.
LSB009	:	8.
LSP034	:	8.
LSP035	:	8.
FILLER04	:	8.
FILLER05	:	8.
NTD034	:	8.
NTD035	:	8.
NTP039	:	8.
NTB001	:	8.
NTB002	:	8.
NTB003	:	8.
NTB004	:	8.
NTB005	:	8.
NTB006	:	8.
NTB007	:	8.
NTB008	:	8.
NTB009	:	8.
NTB010	:	8.
NTB011	:	8.
NTB012	:	8.
NTB013	:	8.
NTB014	:	8.
NTB015	:	8.
NTB016	:	8.
NTB017	:	8.
NTB018	:	8.
NTC020	:	8.
NTC021	:	8.
NTC022	:	8.
NTC023	:	8.
NTC024	:	8.
NTC025	:	8.
NTC026	:	8.
NTC027	:	8.
NTC028	:	8.
NTC029	:	8.
NTC030	:	8.
NTC031	:	8.
NTP036	:	8.
NTP037	:	8.
NTP038	:	8.
OTC010	:	8.
OTC011	:	8.
OTB005	:	8.
OTD012	:	8.
OTD013	:	8.
TTP079	:	8.
FILLER06	:	8.
OTB002	:	8.
OTB003	:	8.
OTB004	:	8.
FILLER07	:	8.
OTC007	:	8.
OTC008	:	8.
OTC009	:	8.
OTP014	:	8.
OTP015	:	8.
OTP016	:	8.
OTP017	:	8.
OTP018	:	8.
OTP019	:	8.
OTP020	:	8.
OTP021	:	8.
DMO013	:	8.
TTP080	:	8.
DMO014	:	$CHAR10.
PRO001	:	8.
PRO002	:	8.
PRO003	:	8.
RTB001	:	8.
RTB002	:	8.
RTB003	:	8.
RTB004	:	8.
RTB005	:	8.
RTB006	:	8.
RTB007	:	8.
RTB008	:	8.
RTB009	:	8.
RTB010	:	8.
RTB011	:	8.
RTB012	:	8.
RTB013	:	8.
RTB014	:	8.
RTB015	:	8.
RTB016	:	8.
RTB017	:	8.
RTB018	:	8.
RTC036	:	8.
RTC037	:	8.
RTC038	:	8.
RTC039	:	8.
RTC040	:	8.
RTC041	:	8.
RTC042	:	8.
RTC043	:	8.
RTC044	:	8.
RTC045	:	8.
RTC046	:	8.
RTC047	:	8.
RTP081	:	8.
RTP082	:	8.
RTP083	:	8.
FILLER08	:	8.
FILLER09	:	8.
RTB020	:	8.
RTB021	:	8.
RTB022	:	$10.
RTB023	:	8.
RTB024	:	8.
RTB025	:	8.
RTB026	:	8.
RTB027	:	8.
RTB028	:	8.
RTB029	:	8.
RTB030	:	8.
RTB031	:	8.
RTB032	:	8.
RTB033	:	8.
RTB034	:	8.
RTB035	:	8.
RTD059	:	8.
RTD060	:	8.
RTD061	:	8.
RTD062	:	8.
RTD063	:	8.
RTD064	:	8.
RTD065	:	8.
RTD067	:	8.
RTD068	:	8.
RTD069	:	8.
RTD070	:	8.
RTD071	:	8.
RTD072	:	8.
RTC049	:	8.
RTC050	:	8.
RTC051	:	8.
RTC052	:	8.
RTC053	:	8.
RTC054	:	8.
RTO077	:	8.
FILLER10	:	$CHAR10.
RTO079	:	8.
FILLER11	:	$CHAR10.
RTP086	:	8.
TTC035	:	8.
TTB001	:	8.
TTC036	:	8.
TTB002	:	8.
TTC037	:	8.
FILLER12	:	8.
TTC051	:	8.
TTC052	:	8.
TTC053	:	8.
TTC054	:	8.
TTC055	:	8.
TTC056	:	8.
TTO074	:	8.
TTO075	:	8.
TTO076	:	8.
TTC057	:	8.
TTC058	:	8.
TTC059	:	8.
TTC060	:	8.
TTC038	:	8.
TTC039	:	8.
TTC040	:	8.
TTC041	:	8.
TTC042	:	8.
TTC043	:	8.
TTC044	:	8.
TTC045	:	8.
TTC046	:	8.
TTC047	:	8.
TTC048	:	8.
TTC049	:	8.
TTB003	:	8.
TTB004	:	8.
TTB005	:	8.
TTB006	:	8.
TTB007	:	8.
TTB008	:	8.
TTB009	:	8.
TTB010	:	8.
TTB011	:	8.
TTB012	:	8.
TTB013	:	8.
TTB014	:	8.
TTB015	:	8.
TTB016	:	8.
TTB017	:	8.
TTB018	:	8.
TTB019	:	8.
TTB020	:	8.
TTP084	:	8.
FILLER13	:	8.
FILLER14	:	8.
FILLER15	:	8.
FILLER16	:	8.
TTB023	:	8.
TTB024	:	8.
TTB025	:	8.
TTB026	:	8.
TTB027	:	8.
FILLER17	:	8.
FILLER18	:	8.
FILLER19	:	8.
FILLER20	:	8.
FILLER21	:	8.
TTO077	:	8.
TTB033	:	8.
TTC061	:	8.
TTC063	:	8.
TTC064	:	8.
TTC065	:	8.
TTC066	:	8.
TTC067	:	8.
TTC068	:	8.
TTC069	:	8.
TTC070	:	8.
TXC010	:	8.
TXC011	:	8.
TXC012	:	8.
TXB004	:	8.
FILLER22	:	8.
TXB006	:	8.
TXO013	:	8.
TXO014	:	8.
TXB001	:	8.
TXB002	:	8.
TXB003	:	8.
TXC007	:	8.
FILLER23	:	8.
TXC009	:	8.
TXP015	:	8.
TXP016	:	8.
TXP017	:	8.
ACC007	:	8.
ACC008	:	8.
UCC001	:	8.
UCC002	:	8.
UCC003	:	8.
UCC004	:	8.
UCC005	:	8.
UCC006	:	8.
UCC007	:	8.
UCC008	:	8.
UCC009	:	8.
UCC010	:	8.
UCC011	:	8.
UCC012	:	8.
UCC013	:	8.
UCC014	:	8.
UCC015	:	8.
UCC016	:	8.
FILLER24	:	$CHAR10.
;


File_ind="&version.";

RUN;
/*5,580,220*/


/*Check the dup keys*/
proc sort data=tar.&output. out=test nodupkey;
by bin;
run;
/*147,953 dup*/

proc sql;
	create table test_bin_dup as 
	select *, sum(1) as cnt
	from tar.&output.
	group by bin
	having cnt>1
	;
quit;
/*269,529*/

data test;
	set test_bin_dup;
	drop AMS_USER_TRACKINGID SEQUENCE_NUMBER;
run;

proc sort data=test out=test1 nodupkey;
by bin;
run;
/*121,576*/

proc sql;
	create table test2 as
	select distinct *
	from test
/*	group by **/
	;
quit;
/*121,576*/

proc sort data=tar.&output. out=test nodupkey;
by SEQUENCE_NUMBER;
run;
%mend;

GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;


/*   START OF NODE: 03_Pre_Post_merge data   */
%LET _CLIENTTASKLABEL='03_Pre_Post_merge data';
%LET _CLIENTPROJECTPATH=
'P:\offshore_office\frankji\forwardline\ForwardLine_Score_20160510_v1.egp';
%LET _CLIENTPROJECTNAME='ForwardLine_Score_20160510_v1.egp';
%LET _SASPROGRAMFILE=;

GOPTIONS ACCESSIBLE;



*********************************Read in the BIN file for List 
A***********************;
data tar.&file1_name.;
	infile "&Pre_file1." 
		 LRECL=5000
        ENCODING="LATIN1"
        TERMSTR=CRLF
		truncover 
/*		obs=1000*/
;

input 
List	$	1	-	5
Sequence_Number	$	6	-	14
BIN	$	15	-	23
Company_Name	$	24	-	58
Street_Address	$	59	-	93
City	$	94	-	113
State	$	114	-	115
Zip_Code	$	116	-	124
Street_Number	$	125	-	134
Street_Pre_Direction	$	135	-	136
Street_Name	$	137	-	161
Street_Suffix	$	162	-	165
Street_Post_Direction	$	166	-	167
Unit_Type	$	168	-	173
Unit_Number	$	174	-	179
PO_Box	$	180	-	189
Phone_Number	$	190	-	199
State_County_Code	$	200	-	204
MSA_Code	$	205	-	208
MSA_Description	$	209	-	258
GEO_Code_Latitude	$	259	-	268
GEO_Code_Latitude_Direction	$	269	-	269
GEO_Code_Longitude	$	270	-	279
GEO_Code_Longitude_Direction	$	280	-	280
Census_Block_Group	$	281	-	281
Filler11	$	282	-	284
Address_Type_Code	$	285	-	285
Census_Tract_Code	$	286	-	291
Home_Based_Business_ID	$	292	-	292
Cottage_Indicator	$	293	-	293
Filler22	$	294	-	294
Square_Footage	$	295	-	305
COA_Indicator	$	306	-	306
Filler33	$	307	-	341
Location_Code	$	342	-	342
Contact_Name_1	$	343	-	438
Contact_First_Name_1	$	439	-	470
Contact_Middle_Name_1	$	471	-	502
Contact_Last_Name_1	$	503	-	534
Contact_Title_1	$	535	-	554
Contact_Ethnicity_1	$	555	-	557
Contact_Name_2	$	558	-	653
Contact_First_Name_2	$	654	-	685
Contact_Middle_Name_2	$	686	-	717
Contact_Last_Name_2	$	718	-	749
Contact_Title_2	$	750	-	769
Contact_Ethnicity_2	$	770	-	772
Filler1	$	773	-	822
Establish_Date	$	823	-	830
Years_in_File	$	831	-	832
Year_Business_Started	$	833	-	836
Estimated_Number_of_Employees	$	837	-	843
Employee_Size_Code	$	844	-	844
Estimated_Annual_Sales_Amt	$	845	-	852
Annual_Sales_Size_Code	$	853	-	853
Business_Type	$	854	-	854
Filler2	$	855	-	855
SIC_Code	$	856	-	856
Primary_SIC_Code_4_Digit	$	857	-	860
Primary_SIC_Code_8_digit	$	861	-	868
Second_SIC_Code	$	869	-	876
Third_SIC_Code	$	877	-	884
Fourth_SIC_Code	$	885	-	892
Fifth_SIC_Code	$	893	-	900
Sixth_SIC_Code	$	901	-	908
Primary_NAICS_Code	$	909	-	914
Second_NAICS_code	$	915	-	920
Third_NAICS_code	$	921	-	926
Fourth_NAICS_code	$	927	-	932
Non_Profit_Indicator	$	933	-	933
Filler3	$	934	-	934
Woman_Owned_Ind	$	935	-	935
Minority_Owned_Ind	$	936	-	936
SBA_Ind	$	937	-	937
Filler4	$	938	-	938
Intelliscore_Plus	$	939	-	946
DBT_Combined_Trade_Totals	$	947	-	949
Number_of_Legal_Items	$	950	-	952
IPV2_Score		953	-	960
Approval_Score		961	-	963
Response_Score		964	-	966
Approval_Group	$	967	-	970
Response_Group	$	971	-	974
Client_Code	$	975	-	977
Jacket	$	978	-	983
LIST1	$	984	-	984
TSG_Sequence_Number	$	985	-	992
;
run;
/*4,356,061*/

***************************Read in the BIN file for List B and 
C***************************;
data tar.&file2_name.;
	infile "&Pre_file2." 
		 LRECL=5000
        ENCODING="LATIN1"
        TERMSTR=CRLF
		truncover 
/*		obs=1000*/
;

input 
First	$	1	-	30
Middle	$	31	-	45
Last	$	46	-	75
Title	$	76	-	105
Prospect_I	$	106	-	125
Company	$	126	-	175
Address	$	176	-	225
City	$	226	-	255
State	$	256	-	257
Zip	$	258	-	267
Phone1	$	268	-	282
List	$	283	-	287
Sequence_Number	$	288	-	296
BIN	$	297	-	305
Company_Name	$	306	-	340
Street_Address	$	341	-	375
City1	$	376	-	395
State1	$	396	-	397
Zip_Code	$	398	-	406
Street_Number	$	407	-	416
Street_Pre_Direction	$	417	-	418
Street_Name	$	419	-	443
Street_Suffix	$	444	-	447
Street_Post_Direction	$	448	-	449
Unit_Type	$	450	-	455
Unit_Number	$	456	-	461
PO_Box	$	462	-	471
Phone_Number	$	472	-	481
State_County_Code	$	482	-	486
MSA_Code	$	487	-	490
MSA_Description	$	491	-	540
GEO_Code_Latitude	$	541	-	550
GEO_Code_Latitude_Direction	$	551	-	551
GEO_Code_Longitude	$	552	-	561
GEO_Code_Longitude_Direction	$	562	-	562
Census_Block_Group	$	563	-	563
Filler1	$	564	-	566
Address_Type_Code	$	567	-	567
Census_Tract_Code	$	568	-	573
Home_Based_Business_ID	$	574	-	574
Cottage_Indicator	$	575	-	575
Filler2	$	576	-	576
Square_Footage	$	577	-	587
COA_Indicator	$	588	-	588
Filler3	$	589	-	623
Location_Code	$	624	-	624
Contact_Name_1	$	625	-	720
Contact_First_Name_1	$	721	-	752
Contact_Middle_Name_1	$	753	-	784
Contact_Last_Name_1	$	785	-	816
Contact_Title_1	$	817	-	836
Contact_Ethnicity_1	$	837	-	839
Contact_Name_2	$	840	-	935
Contact_First_Name_2	$	936	-	967
Contact_Middle_Name_2	$	968	-	999
Contact_Last_Name_2	$	1000	-	1031
Contact_Title_2	$	1032	-	1051
Contact_Ethnicity_2	$	1052	-	1054
Filler4	$	1055	-	1104
Establish_Date	$	1105	-	1112
Years_in_File	$	1113	-	1114
Year_Business_Started	$	1115	-	1118
Estimated_Number_of_Employees	$	1119	-	1125
Employee_Size_Code	$	1126	-	1126
Estimated_Annual_Sales_Amt	$	1127	-	1134
Annual_Sales_Size_Code	$	1135	-	1135
Business_Type	$	1136	-	1136
Filler5	$	1137	-	1137
SIC_Code	$	1138	-	1138
Primary_SIC_Code_4_Digit	$	1139	-	1142
Primary_SIC_Code_8_digit	$	1143	-	1150
Second_SIC_Code	$	1151	-	1158
Third_SIC_Code	$	1159	-	1166
Fourth_SIC_Code	$	1167	-	1174
Fifth_SIC_Code	$	1175	-	1182
Sixth_SIC_Code	$	1183	-	1190
Primary_NAICS_Code	$	1191	-	1196
Second_NAICS_code	$	1197	-	1202
Third_NAICS_code	$	1203	-	1208
Fourth_NAICS_code	$	1209	-	1214
Non_Profit_Indicator	$	1215	-	1215
Filler6	$	1216	-	1216
Woman_Owned_Ind	$	1217	-	1217
Minority_Owned_Ind	$	1218	-	1218
SBA_Ind	$	1219	-	1219
Filler7	$	1220	-	1220
Intelliscore_Plus	$	1221	-	1228
DBT_of_Combined_Trade_Totals	$	1229	-	1231
Number_of_Legal_Items	$	1232	-	1234
IPV2_Score		1235	-	1242
Approval_Score		1243	-	1245
Response_Score		1246	-	1248
Approval_Group	$	1249	-	1252
Response_Group	$	1253	-	1256
Client_Code	$	1257	-	1259
Jacket	$	1260	-	1265
LIST1	$	1266	-	1266
TSG_Sequence_Number	$	1267	-	1274
;
run;
/*1130598*/

/*Check the dup keys whithin List*/
proc sort data=tar.&file1_name. out=&file1_name. nodupkey;
by TSG_Sequence_Number;
run;
/*no dup */

proc sort data=tar.&file2_name. out=&file2_name. nodupkey;
by TSG_Sequence_Number;
run;
/*no dup*/

proc sort data=tar.&file1_name. out=&file1_name. nodupkey;
by bin;
run;
/*no dup */

proc sort data=tar.&file2_name. out=&file2_name. nodupkey;
by bin;
run;
/*66,581 dup*/

/*Check the merge result by bin*/
data test;	
merge &file1_name.(in=a) &file2_name.(in=b) ;
by bin;
merge_flag=compress(a||b);
run;

title "Check the merge result by bin for pre merge file";
proc freq data=test;
table merge_flag/missing;
run;

***********************Post Merge file*****************************;

*****************Readin the post_merge file*******************;
data tar.Live_post_merge;
  INFILE "&Post_file."
        LRECL=5000
        ENCODING="LATIN1"
        TERMSTR=CRLF
/*        DLM='2C'x*/
        truncover
        DSD 
/*		firstobs=2*/
/*		obs=1000*/
;
    INPUT

KEYCODE	$	001	-	010
BIN	$	011	-	019
Full_ID	$	020	-	034
MCOUNT	$	035	-	042
Distance_0	$	043	-	050
Distance_1	$	051	-	058
Distance_2	$	059	-	066
Distance_3	$	067	-	074
Distance_4	$	075	-	082
Distance_5	$	083	-	090
Distance_6	$	091	-	098
Distance_7	$	099	-	106
Distance_8	$	107	-	114
Distance_9	$	115	-	122
Distance_10	$	123	-	130
Distance_11	$	131	-	138
Last_Mail_Drop_Date	$	139	-	146
;
run;
/*3295712*/

/*Merge the post_merge with pre_merge*/
proc sort data=tar.Live_post_merge out=Live_post_merge nodupkey;
by full_id;
run;
/*no dup 3,295,712*/

***********************Append the HOME_BASED_BUSINESS_ID and 
ANNUAL_SALES_SIZE_CODE from pre merge file*****************;

/*Pre_merge file*/
data Pre_merge;
length full_id $15.;
	set tar.&file1_name.
		tar.&file2_name.
;
rename bin=pre_bin;
full_id=compress(Jacket||LIST1||TSG_Sequence_Number);
keep Jacket
LIST1
TSG_Sequence_Number
bin
full_id
HOME_BASED_BUSINESS_ID
ANNUAL_SALES_SIZE_CODE
state
  ;
run;
/*5486659*/

Title "freq for Pre merge file";
proc freq data=Pre_merge;
table Jacket list1/missing;
run;

proc sort data=Pre_merge out=Pre_merge_1 nodupkey;
by full_id;
run;
/*no dup*/

data List_for_score;
	merge Pre_merge_1(in=a) Live_post_merge(in=b where=(full_id^='') keep=full_id 
bin KEYCODE);
	by full_id;
/*	if b;*/
	merge_flag=compress(a||b);
run;
/*3295711*/

Title "Pre merge fiel and Post Merge file merge result";
proc freq data=List_for_score;
table merge_flag/missing;
run;

data test;
	set List_for_score;
	where pre_bin^=bin and merge_flag='11';
run;

data tar.List_for_score;
	set List_for_score;
	where merge_flag in ('01','11');
run;

proc sort data= tar.List_for_score out= test1 nodupkey;
by bin;
run;
/*no dup*/

Title "Freq for Post Merge file";
proc freq data=tar.List_for_score;;
table list1 
HOME_BASED_BUSINESS_ID
ANNUAL_SALES_SIZE_CODE/missing;
run;




GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;


/*   START OF NODE: 01a_old_score_setup   */
%LET _CLIENTTASKLABEL='01a_old_score_setup';
%LET _CLIENTPROJECTPATH=
'P:\offshore_office\frankji\forwardline\ForwardLine_Score_20160510_v1.egp';
%LET _CLIENTPROJECTNAME='ForwardLine_Score_20160510_v1.egp';
%LET _SASPROGRAMFILE=;

GOPTIONS ACCESSIBLE;

**********************Readin old score***************************;
data old_score;
   
    INFILE "&old_score."
        LRECL=5000
        ENCODING="LATIN1"
        TERMSTR=CRLF
        DLM='2C'x
        truncover
        DSD 
		firstobs=2
/*		obs=10000*/
;
    INPUT
       BIN : $20.
        LIST             : $CHAR5.
        SEP_APPROVAL_SCORE   : $8.
        SEP_RESPONSE_SCORE : $8.
        SEP_APPROVAL_GROUP : $10.
        SEP_RESPONSE_GROUP : $10.
        FEB_APPROVAL_SCORE : $8.
        FEB_RESPONSE_SCORE : $8.
        FEB_APPROVAL_GROUP : $10.
        FEB_RESPONSE_GROUP : $10. ;

		list=substr(list,5,1);
/*		if list  in ("A","B","C");*/
RUN;
/*5486659*/

data tar.old_score;
	set old_score;
/*where length(BIN)>9;*/
	where list in ("A","B","C");
 SEP_APPROVAL_SCORE_1=input(SEP_APPROVAL_SCORE,best.);
  SEP_RESPONSE_SCORE_1=input(SEP_RESPONSE_SCORE,best.);
    FEB_APPROVAL_SCORE_1=input(FEB_APPROVAL_SCORE,best.);
  FEB_RESPONSE_SCORE_1=input(FEB_RESPONSE_SCORE,best.);
         
run;
/*5486654*/

Title "Freq of old score groups";
proc freq data=tar.old_score;
table LIST SEP_APPROVAL_GROUP SEP_RESPONSE_GROUP FEB_APPROVAL_GROUP 
FEB_RESPONSE_GROUP/missing;
run;

**************************Check the 
scores*******************************************;

Title "Proc means of old scores";
proc means data=tar.old_score n nmiss mean min p25 p50 p75 max;
var SEP_APPROVAL_SCORE_1 SEP_RESPONSE_SCORE_1 FEB_APPROVAL_SCORE_1 
FEB_RESPONSE_SCORE_1;
run;



GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;


/*   START OF NODE: 04_Score Data Prepare   */
%LET _CLIENTTASKLABEL='04_Score Data Prepare';
%LET _CLIENTPROJECTPATH=
'P:\offshore_office\frankji\forwardline\ForwardLine_Score_20160510_v1.egp';
%LET _CLIENTPROJECTNAME='ForwardLine_Score_20160510_v1.egp';
%LET _SASPROGRAMFILE=;

GOPTIONS ACCESSIBLE;

*********readin the BizAgg file*********************************;

%BizAgg_read(&old_raw.,&old_name.,&old_vs.);

%BizAgg_read(&New_raw.,&New_name.,&New_vs.);


proc sort data=tar.&old_name. out=&old_name. nodupkey;
by bin;
run;
/*5430492*/
proc sort data=tar.&New_name. out=&New_name. nodupkey;
by bin;
run;
/*4113710*/

%include 
"/mnt/projects/locked/forwardline/scoring_201604/rawdata/BizAgg_var_list.txt";

data &old_name._2;
	set &old_name.;
	%rename(&var_list.,_2);
run;

data &New_name._1;
	set &New_name.;
	%rename(&var_list.,_1);
run;

data tar.BizAgg_renamed_all;
	merge &old_name._2(in=a) &New_name._1(in=b);
	by bin;
	combine_ind=compress(File_ind_2||" "||File_ind_1);
run;

Title "The Match result for Old and New BizAgg files" ;
proc freq data=tar.BizAgg_renamed_all;
table combine_ind/missing;
run;

********************************Match with the BizAgg 
file*******************************;

proc sort data=tar.List_for_score out= List_for_score_1(drop=pre_bin) nodupkey;
by bin;
run;

proc sort data=tar.BizAgg_renamed_all out=BizAgg_renamed_all nodupkey;
by bin;
run;

data BizAgg_renamed_all;
	set BizAgg_renamed_all;
	bin=left(bin);
run;

data List_with_BizAgg;
	merge List_for_score_1(in=a) BizAgg_renamed_all(in=b);
	by bin;
	if a ;
/*	if combine_ind="Feb16Mar16";*/
run;

proc freq data=List_with_BizAgg;
table list1*combine_ind/missing list;
run;

data tar.List_with_BizAgg;
	set List_with_BizAgg;
	where combine_ind=compress("&old_vs."||"&New_vs.");
run;

*************************Match with the MCounter 
file****************************************************;

/**/
/*data tar.mail_counter_unlocked;*/
/*length bin1 $9.;*/
/*	set tar.mail_counter(pw=Jf64YvP);*/
/*	bin1=put(bin, best9.);*/
/*run;*/
/*1762480*/

proc sort data=tar.&Mcount_file. out=mail_counter(keep=BIN1 MCount) nodupkey;
by bin1;
run;

data tar.List_BizAgg_Mcount;
	merge tar.List_with_BizAgg(in=a) mail_counter(in=b rename=(BIn1=bin 
MCount=Orig_MCount));
	by bin;
	if a;
	if b then MCount_match_flag=1;
	else MCount_match_flag=0;
/*	if MCount_match_flag=0 then MCount=0;*/
/*	else if MCount_match_flag=1 then MCount=Orig_MCount;*/
run;

proc freq data=tar.List_BizAgg_Mcount;
table MCount_match_flag Orig_MCount/missing;
run;

data test;	
	set tar.List_BizAgg_Mcount;
	where MCount_match_flag=0;
	keep full_id	Home_Based_Business_ID	Annual_Sales_Size_Code	Jacket	LIST1	
TSG_Sequence_Number	KEYCODE	BIN	combine_ind	
;
run;

data test11;
	set test(obs=100);
run;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;


/*   START OF NODE: 05_Scoring and Cut   */
%LET _CLIENTTASKLABEL='05_Scoring and Cut';
%LET _CLIENTPROJECTPATH=
'P:\offshore_office\frankji\forwardline\ForwardLine_Score_20160510_v1.egp';
%LET _CLIENTPROJECTNAME='ForwardLine_Score_20160510_v1.egp';
%LET _SASPROGRAMFILE=;

GOPTIONS ACCESSIBLE;

%let input=tar.List_BizAgg_Mcount;

data qual_all_var ;
set &input. ;
 o_LGC004_1=(LGC004_1=0);
                                     o_TTC057_2=(TTC057_2=0);
                                     l_CLO014_1=log(CLO014_1+1);
                                     l_TTB009_1=log(TTB009_1+1);
                                     l_TTB014_1=log(TTB014_1+1);
                                     l_CTB012_1=log(CTB012_1+1);
                                     o_CTB007_1=(CTB007_1=0);
                                     l_TTP084_2=log(TTP084_2+1);
                                     l_RTC037_1=log(RTC037_1+1);
                                     l_TTO077_1=log(TTO077_1+1);
                                     l_RTD072_1=log(RTD072_1+1);
                                     l_RTC049_2=log(RTC049_2+1);
                                     l_CLP016_1=log(CLP016_1+1);
                                     l_TTP079_1=log(TTP079_1+1);
 if l_CLO014_1=. then l_CLO014_1=0;
                                  if l_TTB009_1=. then l_TTB009_1=0;
                                  if l_TTB014_1=. then l_TTB014_1=0;
                                  if l_CTB012_1=. then l_CTB012_1=0;

                                  if l_TTP084_2=. then l_TTP084_2=0;
                                  if l_RTC037_1=. then l_RTC037_1=0;
                                  if l_TTO077_1=. then l_TTO077_1=0;
                                  if l_RTD072_1=. then l_RTD072_1=0;
                                  if l_RTC049_2=. then l_RTC049_2=0;
                                  if l_CLP016_1=. then l_CLP016_1=0;
                                  if l_TTP079_1=. then l_TTP079_1=0;




 if dmo013_1=. then lnp=0.46089625;
else if dmo013_1=100 then lnp=0.663740038;
else if dmo013_1=115 then lnp=0.6660143864;
else if dmo013_1=131 then lnp=0.6644979699;
else if dmo013_1=139 then lnp=0.663740038;
else if dmo013_1=161 then lnp=0.6644979699;
else if dmo013_1=172 then lnp=0.6579079412;
else if dmo013_1=181 then lnp=0.663027317;
else if dmo013_1=191 then lnp=0.6707486313;
else if dmo013_1=200 then lnp=0.663740038;
else if dmo013_1=212 then lnp=0.6644979699;
else if dmo013_1=241 then lnp=0.6644979699;
else if dmo013_1=273 then lnp=0.663740038;
else if dmo013_1=279 then lnp=0.6622697418;
else if dmo013_1=291 then lnp=0.6652560859;
else if dmo013_1=700 then lnp=0.6585745356;
else if dmo013_1=711 then lnp=0.6615123499;
else if dmo013_1=721 then lnp=0.663740038;
else if dmo013_1=722 then lnp=0.663740038;
else if dmo013_1=723 then lnp=0.6623147586;
else if dmo013_1=740 then lnp=0.663740038;
else if dmo013_1=742 then lnp=0.6594211685;
else if dmo013_1=750 then lnp=0.6615123499;
else if dmo013_1=751 then lnp=0.6615123499;
else if dmo013_1=752 then lnp=0.6664651239;
else if dmo013_1=761 then lnp=0.663027317;
else if dmo013_1=762 then lnp=0.663740038;
else if dmo013_1=781 then lnp=0.671417976;
else if dmo013_1=782 then lnp=0.6826614663;
else if dmo013_1=783 then lnp=0.6698989185;
else if dmo013_1=851 then lnp=0.6644979699;
else if dmo013_1=971 then lnp=0.6660143864;
else if dmo013_1=1311 then lnp=0.663740038;
else if dmo013_1=1381 then lnp=0.6644979699;
else if dmo013_1=1382 then lnp=0.663740038;
else if dmo013_1=1389 then lnp=0.6652560859;
else if dmo013_1=1411 then lnp=0.663740038;
else if dmo013_1=1423 then lnp=0.6615123499;
else if dmo013_1=1442 then lnp=0.663740038;
else if dmo013_1=1499 then lnp=0.6637850759;
else if dmo013_1=1500 then lnp=0.6661045287;
else if dmo013_1=1521 then lnp=0.7257860502;
else if dmo013_1=1522 then lnp=0.6690494389;
else if dmo013_1=1531 then lnp=0.6682903976;
else if dmo013_1=1541 then lnp=0.6623147586;
else if dmo013_1=1542 then lnp=0.6701696918;
else if dmo013_1=1600 then lnp=0.6637850759;
else if dmo013_1=1610 then lnp=0.663740038;
else if dmo013_1=1611 then lnp=0.6699440458;
else if dmo013_1=1622 then lnp=0.663027317;
else if dmo013_1=1623 then lnp=0.6667728717;
else if dmo013_1=1629 then lnp=0.662359776;
else if dmo013_1=1700 then lnp=0.6622697418;
else if dmo013_1=1711 then lnp=0.7799909572;
else if dmo013_1=1721 then lnp=0.7026968406;
else if dmo013_1=1731 then lnp=0.6823068151;
else if dmo013_1=1741 then lnp=0.6676217283;
else if dmo013_1=1742 then lnp=0.6653462062;
else if dmo013_1=1743 then lnp=0.6677119171;
else if dmo013_1=1751 then lnp=0.6897588968;
else if dmo013_1=1752 then lnp=0.6665102012;
else if dmo013_1=1761 then lnp=0.680329525;
else if dmo013_1=1770 then lnp=0.663740038;
else if dmo013_1=1771 then lnp=0.6736979639;
else if dmo013_1=1781 then lnp=0.6608451317;
else if dmo013_1=1790 then lnp=0.6652560859;
else if dmo013_1=1791 then lnp=0.6645430187;
else if dmo013_1=1793 then lnp=0.6637850759;
else if dmo013_1=1794 then lnp=0.6661045287;
else if dmo013_1=1795 then lnp=0.6667728717;
else if dmo013_1=1796 then lnp=0.663027317;
else if dmo013_1=1799 then lnp=0.6841415243;
else if dmo013_1=2011 then lnp=0.6600430991;
else if dmo013_1=2015 then lnp=0.6615123499;
else if dmo013_1=2024 then lnp=0.663740038;
else if dmo013_1=2026 then lnp=0.6615123499;
else if dmo013_1=2033 then lnp=0.663740038;
else if dmo013_1=2035 then lnp=0.663740038;
else if dmo013_1=2051 then lnp=0.663027317;
else if dmo013_1=2052 then lnp=0.663740038;
else if dmo013_1=2064 then lnp=0.6622697418;
else if dmo013_1=2082 then lnp=0.6615123499;
else if dmo013_1=2084 then lnp=0.6615573557;
else if dmo013_1=2086 then lnp=0.663740038;
else if dmo013_1=2095 then lnp=0.663740038;
else if dmo013_1=2097 then lnp=0.663740038;
else if dmo013_1=2099 then lnp=0.6652560859;
else if dmo013_1=2100 then lnp=0.6644979699;
else if dmo013_1=2121 then lnp=0.6615123499;
else if dmo013_1=2200 then lnp=0.6615123499;
else if dmo013_1=2253 then lnp=0.663740038;
else if dmo013_1=2295 then lnp=0.663740038;
else if dmo013_1=2299 then lnp=0.663740038;
else if dmo013_1=2300 then lnp=0.6637850759;
else if dmo013_1=2329 then lnp=0.663740038;
else if dmo013_1=2331 then lnp=0.6622697418;
else if dmo013_1=2339 then lnp=0.6630723447;
else if dmo013_1=2391 then lnp=0.6652560859;
else if dmo013_1=2392 then lnp=0.6615123499;
else if dmo013_1=2394 then lnp=0.6622697418;
else if dmo013_1=2395 then lnp=0.6644979699;
else if dmo013_1=2396 then lnp=0.6615573557;
else if dmo013_1=2399 then lnp=0.6601330693;
else if dmo013_1=2411 then lnp=0.6652560859;
else if dmo013_1=2431 then lnp=0.6660143864;
else if dmo013_1=2434 then lnp=0.6616023623;
else if dmo013_1=2441 then lnp=0.663740038;
else if dmo013_1=2451 then lnp=0.6644979699;
else if dmo013_1=2452 then lnp=0.663740038;
else if dmo013_1=2499 then lnp=0.6637850759;
else if dmo013_1=2510 then lnp=0.660800136;
else if dmo013_1=2517 then lnp=0.663740038;
else if dmo013_1=2521 then lnp=0.663740038;
else if dmo013_1=2591 then lnp=0.663740038;
else if dmo013_1=2599 then lnp=0.6600430991;
else if dmo013_1=2656 then lnp=0.6615123499;
else if dmo013_1=2671 then lnp=0.663740038;
else if dmo013_1=2673 then lnp=0.6644979699;
else if dmo013_1=2678 then lnp=0.663740038;
else if dmo013_1=2711 then lnp=0.6615123499;
else if dmo013_1=2721 then lnp=0.6637850759;
else if dmo013_1=2731 then lnp=0.667531542;
else if dmo013_1=2741 then lnp=0.6616023623;
else if dmo013_1=2750 then lnp=0.6644979699;
else if dmo013_1=2752 then lnp=0.6700343022;
else if dmo013_1=2759 then lnp=0.6590242024;
else if dmo013_1=2790 then lnp=0.6600430991;
else if dmo013_1=2791 then lnp=0.663740038;
else if dmo013_1=2796 then lnp=0.6585745356;
else if dmo013_1=2834 then lnp=0.6615123499;
else if dmo013_1=2841 then lnp=0.6644979699;
else if dmo013_1=2851 then lnp=0.663740038;
else if dmo013_1=2891 then lnp=0.6615123499;
else if dmo013_1=2892 then lnp=0.6644979699;
else if dmo013_1=2899 then lnp=0.6615123499;
else if dmo013_1=2911 then lnp=0.663740038;
else if dmo013_1=3069 then lnp=0.6615123499;
else if dmo013_1=3080 then lnp=0.6644979699;
else if dmo013_1=3089 then lnp=0.6644979699;
else if dmo013_1=3199 then lnp=0.6600430991;
else if dmo013_1=3231 then lnp=0.6600430991;
else if dmo013_1=3260 then lnp=0.6615123499;
else if dmo013_1=3269 then lnp=0.663740038;
else if dmo013_1=3272 then lnp=0.6616023623;
else if dmo013_1=3281 then lnp=0.6682903976;
else if dmo013_1=3295 then lnp=0.663740038;
else if dmo013_1=3296 then lnp=0.663740038;
else if dmo013_1=3299 then lnp=0.663740038;
else if dmo013_1=3310 then lnp=0.663740038;
else if dmo013_1=3316 then lnp=0.6615123499;
else if dmo013_1=3366 then lnp=0.6644979699;
else if dmo013_1=3399 then lnp=0.663740038;
else if dmo013_1=3420 then lnp=0.663740038;
else if dmo013_1=3425 then lnp=0.663740038;
else if dmo013_1=3433 then lnp=0.663740038;
else if dmo013_1=3441 then lnp=0.6660594572;
else if dmo013_1=3444 then lnp=0.6622697418;
else if dmo013_1=3446 then lnp=0.6637850759;
else if dmo013_1=3448 then lnp=0.663740038;
else if dmo013_1=3462 then lnp=0.6615123499;
else if dmo013_1=3471 then lnp=0.6637850759;
else if dmo013_1=3479 then lnp=0.662404794;
else if dmo013_1=3496 then lnp=0.663740038;
else if dmo013_1=3499 then lnp=0.6615123499;
else if dmo013_1=3511 then lnp=0.663740038;
else if dmo013_1=3519 then lnp=0.6644979699;
else if dmo013_1=3523 then lnp=0.6615123499;
else if dmo013_1=3531 then lnp=0.6622697418;
else if dmo013_1=3534 then lnp=0.6622697418;
else if dmo013_1=3536 then lnp=0.6622697418;
else if dmo013_1=3542 then lnp=0.663740038;
else if dmo013_1=3544 then lnp=0.663027317;
else if dmo013_1=3545 then lnp=0.6644979699;
else if dmo013_1=3552 then lnp=0.663740038;
else if dmo013_1=3553 then lnp=0.663740038;
else if dmo013_1=3556 then lnp=0.663740038;
else if dmo013_1=3559 then lnp=0.6593312186;
else if dmo013_1=3561 then lnp=0.6644979699;
else if dmo013_1=3564 then lnp=0.663740038;
else if dmo013_1=3567 then lnp=0.663740038;
else if dmo013_1=3569 then lnp=0.6644979699;
else if dmo013_1=3575 then lnp=0.6615123499;
else if dmo013_1=3578 then lnp=0.6615123499;
else if dmo013_1=3585 then lnp=0.660800136;
else if dmo013_1=3589 then lnp=0.663740038;
else if dmo013_1=3599 then lnp=0.657466218;
else if dmo013_1=3613 then lnp=0.663740038;
else if dmo013_1=3621 then lnp=0.663740038;
else if dmo013_1=3633 then lnp=0.6615123499;
else if dmo013_1=3634 then lnp=0.663740038;
else if dmo013_1=3635 then lnp=0.663740038;
else if dmo013_1=3639 then lnp=0.663740038;
else if dmo013_1=3641 then lnp=0.663740038;
else if dmo013_1=3645 then lnp=0.6600430991;
else if dmo013_1=3646 then lnp=0.663740038;
else if dmo013_1=3648 then lnp=0.6622697418;
else if dmo013_1=3651 then lnp=0.663740038;
else if dmo013_1=3652 then lnp=0.6644979699;
else if dmo013_1=3663 then lnp=0.663740038;
else if dmo013_1=3669 then lnp=0.6660143864;
else if dmo013_1=3674 then lnp=0.663740038;
else if dmo013_1=3679 then lnp=0.6615123499;
else if dmo013_1=3695 then lnp=0.6600430991;
else if dmo013_1=3699 then lnp=0.6600880839;
else if dmo013_1=3711 then lnp=0.6593312186;
else if dmo013_1=3713 then lnp=0.663740038;
else if dmo013_1=3714 then lnp=0.6645880683;
else if dmo013_1=3715 then lnp=0.663740038;
else if dmo013_1=3720 then lnp=0.663740038;
else if dmo013_1=3728 then lnp=0.6615123499;
else if dmo013_1=3731 then lnp=0.663740038;
else if dmo013_1=3732 then lnp=0.663740038;
else if dmo013_1=3751 then lnp=0.6622697418;
else if dmo013_1=3799 then lnp=0.6622697418;
else if dmo013_1=3800 then lnp=0.663740038;
else if dmo013_1=3812 then lnp=0.663740038;
else if dmo013_1=3822 then lnp=0.663740038;
else if dmo013_1=3823 then lnp=0.663740038;
else if dmo013_1=3824 then lnp=0.663740038;
else if dmo013_1=3829 then lnp=0.663740038;
else if dmo013_1=3841 then lnp=0.660800136;
else if dmo013_1=3842 then lnp=0.663740038;
else if dmo013_1=3845 then lnp=0.663740038;
else if dmo013_1=3910 then lnp=0.663740038;
else if dmo013_1=3911 then lnp=0.6645430187;
else if dmo013_1=3914 then lnp=0.6644979699;
else if dmo013_1=3915 then lnp=0.6644979699;
else if dmo013_1=3949 then lnp=0.663027317;
else if dmo013_1=3953 then lnp=0.663740038;
else if dmo013_1=3993 then lnp=0.6641454029;
else if dmo013_1=3999 then lnp=0.6676217283;
else if dmo013_1=4011 then lnp=0.6622697418;
else if dmo013_1=4111 then lnp=0.6660594572;
else if dmo013_1=4119 then lnp=0.6650385994;
else if dmo013_1=4121 then lnp=0.6623147586;
else if dmo013_1=4131 then lnp=0.663740038;
else if dmo013_1=4142 then lnp=0.6637850759;
else if dmo013_1=4151 then lnp=0.6660143864;
else if dmo013_1=4173 then lnp=0.663740038;
else if dmo013_1=4210 then lnp=0.6653011457;
else if dmo013_1=4212 then lnp=0.6701245613;
else if dmo013_1=4213 then lnp=0.6840961876;
else if dmo013_1=4214 then lnp=0.6668179535;
else if dmo013_1=4215 then lnp=0.6600880839;
else if dmo013_1=4222 then lnp=0.6644979699;
else if dmo013_1=4225 then lnp=0.6559539294;
else if dmo013_1=4226 then lnp=0.6615123499;
else if dmo013_1=4300 then lnp=0.663740038;
else if dmo013_1=4412 then lnp=0.6615123499;
else if dmo013_1=4449 then lnp=0.660800136;
else if dmo013_1=4489 then lnp=0.6615123499;
else if dmo013_1=4492 then lnp=0.6622697418;
else if dmo013_1=4493 then lnp=0.6654363292;
else if dmo013_1=4499 then lnp=0.6652560859;
else if dmo013_1=4512 then lnp=0.6622697418;
else if dmo013_1=4513 then lnp=0.663740038;
else if dmo013_1=4522 then lnp=0.6600430991;
else if dmo013_1=4581 then lnp=0.6653011457;
else if dmo013_1=4600 then lnp=0.6615123499;
else if dmo013_1=4724 then lnp=0.6136893165;
else if dmo013_1=4725 then lnp=0.6637850759;
else if dmo013_1=4729 then lnp=0.660800136;
else if dmo013_1=4731 then lnp=0.6617373857;
else if dmo013_1=4783 then lnp=0.6660143864;
else if dmo013_1=4785 then lnp=0.663740038;
else if dmo013_1=4789 then lnp=0.6676217283;
else if dmo013_1=4810 then lnp=0.6644979699;
else if dmo013_1=4812 then lnp=0.6535072827;
else if dmo013_1=4813 then lnp=0.6645430187;
else if dmo013_1=4822 then lnp=0.663740038;
else if dmo013_1=4832 then lnp=0.660800136;
else if dmo013_1=4833 then lnp=0.6615123499;
else if dmo013_1=4841 then lnp=0.663740038;
else if dmo013_1=4899 then lnp=0.6616023623;
else if dmo013_1=4911 then lnp=0.663027317;
else if dmo013_1=4925 then lnp=0.6622697418;
else if dmo013_1=4939 then lnp=0.6615123499;
else if dmo013_1=4941 then lnp=0.6586194994;
else if dmo013_1=4952 then lnp=0.6615123499;
else if dmo013_1=4953 then lnp=0.6630723447;
else if dmo013_1=4959 then lnp=0.663027317;
else if dmo013_1=5012 then lnp=0.663117373;
else if dmo013_1=5013 then lnp=0.6653912674;
else if dmo013_1=5014 then lnp=0.6683355015;
else if dmo013_1=5015 then lnp=0.6627199386;
else if dmo013_1=5021 then lnp=0.6608451317;
else if dmo013_1=5023 then lnp=0.6638301145;
else if dmo013_1=5031 then lnp=0.6667728717;
else if dmo013_1=5032 then lnp=0.6683355015;
else if dmo013_1=5039 then lnp=0.6654363292;
else if dmo013_1=5044 then lnp=0.6616023623;
else if dmo013_1=5045 then lnp=0.6645430187;
else if dmo013_1=5046 then lnp=0.6668179535;
else if dmo013_1=5047 then lnp=0.6632524619;
else if dmo013_1=5048 then lnp=0.6615123499;
else if dmo013_1=5051 then lnp=0.6660594572;
else if dmo013_1=5063 then lnp=0.6737431467;
else if dmo013_1=5064 then lnp=0.6615573557;
else if dmo013_1=5065 then lnp=0.663027317;
else if dmo013_1=5072 then lnp=0.6637850759;
else if dmo013_1=5074 then lnp=0.6571066574;
else if dmo013_1=5075 then lnp=0.6638301145;
else if dmo013_1=5078 then lnp=0.6638301145;
else if dmo013_1=5082 then lnp=0.6622697418;
else if dmo013_1=5083 then lnp=0.6616473694;
else if dmo013_1=5084 then lnp=0.6633425244;
else if dmo013_1=5085 then lnp=0.6586644638;
else if dmo013_1=5087 then lnp=0.6609351249;
else if dmo013_1=5088 then lnp=0.6585745356;
else if dmo013_1=5091 then lnp=0.6586194994;
else if dmo013_1=5092 then lnp=0.6601330693;
else if dmo013_1=5093 then lnp=0.6682903976;
else if dmo013_1=5094 then lnp=0.6713276791;
else if dmo013_1=5099 then lnp=0.657466218;
else if dmo013_1=5100 then lnp=0.6615123499;
else if dmo013_1=5111 then lnp=0.6615123499;
else if dmo013_1=5112 then lnp=0.6644979699;
else if dmo013_1=5113 then lnp=0.6637850759;
else if dmo013_1=5122 then lnp=0.6645880683;
else if dmo013_1=5131 then lnp=0.6623147586;
else if dmo013_1=5136 then lnp=0.6608451317;
else if dmo013_1=5137 then lnp=0.662359776;
else if dmo013_1=5139 then lnp=0.660800136;
else if dmo013_1=5141 then lnp=0.6654363292;
else if dmo013_1=5142 then lnp=0.663740038;
else if dmo013_1=5145 then lnp=0.6615123499;
else if dmo013_1=5146 then lnp=0.6644979699;
else if dmo013_1=5147 then lnp=0.6593312186;
else if dmo013_1=5148 then lnp=0.6660594572;
else if dmo013_1=5149 then lnp=0.6655264547;
else if dmo013_1=5159 then lnp=0.6644979699;
else if dmo013_1=5162 then lnp=0.663740038;
else if dmo013_1=5169 then lnp=0.6594211685;
else if dmo013_1=5172 then lnp=0.6616473694;
else if dmo013_1=5182 then lnp=0.6585745356;
else if dmo013_1=5191 then lnp=0.6630723447;
else if dmo013_1=5193 then lnp=0.6645880683;
else if dmo013_1=5194 then lnp=0.6644979699;
else if dmo013_1=5198 then lnp=0.6615123499;
else if dmo013_1=5199 then lnp=0.6698989185;
else if dmo013_1=5200 then lnp=0.6615123499;
else if dmo013_1=5211 then lnp=0.6861666629;
else if dmo013_1=5231 then lnp=0.6637928757;
else if dmo013_1=5251 then lnp=0.6595111209;
else if dmo013_1=5261 then lnp=0.661520144;
else if dmo013_1=5271 then lnp=0.663740038;
else if dmo013_1=5311 then lnp=0.666239747;
else if dmo013_1=5331 then lnp=0.6616473694;
else if dmo013_1=5399 then lnp=0.6590691726;
else if dmo013_1=5411 then lnp=0.6574230276;
else if dmo013_1=5421 then lnp=0.6634325895;
else if dmo013_1=5431 then lnp=0.6590242024;
else if dmo013_1=5441 then lnp=0.666239747;
else if dmo013_1=5451 then lnp=0.6638301145;
else if dmo013_1=5461 then lnp=0.6584552212;
else if dmo013_1=5499 then lnp=0.652318762;
else if dmo013_1=5511 then lnp=0.5543999531;
else if dmo013_1=5521 then lnp=0.649911992;
else if dmo013_1=5531 then lnp=0.6470081954;
else if dmo013_1=5541 then lnp=0.6245607588;
else if dmo013_1=5551 then lnp=0.6668630359;
else if dmo013_1=5561 then lnp=0.6600880839;
else if dmo013_1=5571 then lnp=0.6616473694;
else if dmo013_1=5599 then lnp=0.6625398521;
else if dmo013_1=5600 then lnp=0.6652560859;
else if dmo013_1=5611 then lnp=0.6577808671;
else if dmo013_1=5621 then lnp=0.6865374808;
else if dmo013_1=5632 then lnp=0.6579528955;
else if dmo013_1=5641 then lnp=0.6624948321;
else if dmo013_1=5651 then lnp=0.6668708435;
else if dmo013_1=5661 then lnp=0.6659771215;
else if dmo013_1=5699 then lnp=0.6769902201;
else if dmo013_1=5700 then lnp=0.6615123499;
else if dmo013_1=5712 then lnp=0.6467471658;
else if dmo013_1=5713 then lnp=0.6700950627;
else if dmo013_1=5714 then lnp=0.6590691726;
else if dmo013_1=5719 then lnp=0.6602758206;
else if dmo013_1=5722 then lnp=0.6512048656;
else if dmo013_1=5730 then lnp=0.6595111209;
else if dmo013_1=5731 then lnp=0.6762509486;
else if dmo013_1=5734 then lnp=0.6691023669;
else if dmo013_1=5735 then lnp=0.660890128;
else if dmo013_1=5736 then lnp=0.6590691726;
else if dmo013_1=5800 then lnp=0.660800136;
else if dmo013_1=5812 then lnp=0.6980939682;
else if dmo013_1=5813 then lnp=0.6634481873;
else if dmo013_1=5900 then lnp=0.6637850759;
else if dmo013_1=5912 then lnp=0.6552878886;
else if dmo013_1=5921 then lnp=0.6604635685;
else if dmo013_1=5932 then lnp=0.6334152901;
else if dmo013_1=5941 then lnp=0.6586878251;
else if dmo013_1=5942 then lnp=0.6509357242;
else if dmo013_1=5943 then lnp=0.666239747;
else if dmo013_1=5944 then lnp=0.6538448632;
else if dmo013_1=5945 then lnp=0.6497852384;
else if dmo013_1=5946 then lnp=0.6593312186;
else if dmo013_1=5947 then lnp=0.636873657;
else if dmo013_1=5948 then lnp=0.662359776;
else if dmo013_1=5949 then lnp=0.6598259747;
else if dmo013_1=5961 then lnp=0.6638301145;
else if dmo013_1=5962 then lnp=0.6602230422;
else if dmo013_1=5963 then lnp=0.6565751754;
else if dmo013_1=5980 then lnp=0.663740038;
else if dmo013_1=5984 then lnp=0.6615123499;
else if dmo013_1=5989 then lnp=0.663740038;
else if dmo013_1=5992 then lnp=0.6541142514;
else if dmo013_1=5993 then lnp=0.6532008324;
else if dmo013_1=5994 then lnp=0.660800136;
else if dmo013_1=5995 then lnp=0.6430467389;
else if dmo013_1=5999 then lnp=0.6600232446;
else if dmo013_1=6000 then lnp=0.6615123499;
else if dmo013_1=6020 then lnp=0.6600430991;
else if dmo013_1=6021 then lnp=0.6615573557;
else if dmo013_1=6061 then lnp=0.6585745356;
else if dmo013_1=6062 then lnp=0.6615123499;
else if dmo013_1=6099 then lnp=0.6622697418;
else if dmo013_1=6141 then lnp=0.6571965437;
else if dmo013_1=6160 then lnp=0.660800136;
else if dmo013_1=6162 then lnp=0.6398130098;
else if dmo013_1=6163 then lnp=0.6645880683;
else if dmo013_1=6211 then lnp=0.6580877621;
else if dmo013_1=6282 then lnp=0.6432257219;
else if dmo013_1=6289 then lnp=0.6615123499;
else if dmo013_1=6331 then lnp=0.6615123499;
else if dmo013_1=6351 then lnp=0.6439262513;
else if dmo013_1=6361 then lnp=0.6600430991;
else if dmo013_1=6371 then lnp=0.6660143864;
else if dmo013_1=6399 then lnp=0.663740038;
else if dmo013_1=6411 then lnp=0.6271927738;
else if dmo013_1=6500 then lnp=0.6615123499;
else if dmo013_1=6510 then lnp=0.6593761933;
else if dmo013_1=6512 then lnp=0.663117373;
else if dmo013_1=6513 then lnp=0.6507563093;
else if dmo013_1=6515 then lnp=0.6600880839;
else if dmo013_1=6531 then lnp=0.6286624942;
else if dmo013_1=6541 then lnp=0.6653912674;
else if dmo013_1=6552 then lnp=0.6616023623;
else if dmo013_1=6553 then lnp=0.6563954408;
else if dmo013_1=6719 then lnp=0.6600430991;
else if dmo013_1=6726 then lnp=0.6600880839;
else if dmo013_1=6790 then lnp=0.6615123499;
else if dmo013_1=6794 then lnp=0.663740038;
else if dmo013_1=6798 then lnp=0.6615123499;
else if dmo013_1=6799 then lnp=0.6600880839;
else if dmo013_1=7000 then lnp=0.663740038;
else if dmo013_1=7011 then lnp=0.6389870456;
else if dmo013_1=7032 then lnp=0.660800136;
else if dmo013_1=7033 then lnp=0.6684257111;
else if dmo013_1=7210 then lnp=0.6585745356;
else if dmo013_1=7211 then lnp=0.6638301145;
else if dmo013_1=7212 then lnp=0.672065769;
else if dmo013_1=7213 then lnp=0.663740038;
else if dmo013_1=7215 then lnp=0.6589792328;
else if dmo013_1=7216 then lnp=0.660800136;
else if dmo013_1=7217 then lnp=0.6884576925;
else if dmo013_1=7218 then lnp=0.663740038;
else if dmo013_1=7219 then lnp=0.6600880839;
else if dmo013_1=7221 then lnp=0.6641532036;
else if dmo013_1=7231 then lnp=0.7895564553;
else if dmo013_1=7241 then lnp=0.690841336;
else if dmo013_1=7251 then lnp=0.6685610304;
else if dmo013_1=7261 then lnp=0.676168341;
else if dmo013_1=7291 then lnp=0.6816586262;
else if dmo013_1=7299 then lnp=0.6707799006;
else if dmo013_1=7300 then lnp=0.6622697418;
else if dmo013_1=7311 then lnp=0.6683806059;
else if dmo013_1=7312 then lnp=0.663740038;
else if dmo013_1=7313 then lnp=0.663740038;
else if dmo013_1=7319 then lnp=0.6677119171;
else if dmo013_1=7322 then lnp=0.6615573557;
else if dmo013_1=7323 then lnp=0.663740038;
else if dmo013_1=7331 then lnp=0.6594661444;
else if dmo013_1=7334 then lnp=0.6637850759;
else if dmo013_1=7335 then lnp=0.6571516003;
else if dmo013_1=7336 then lnp=0.6690945537;
else if dmo013_1=7338 then lnp=0.6645430187;
else if dmo013_1=7340 then lnp=0.663740038;
else if dmo013_1=7342 then lnp=0.6703207197;
else if dmo013_1=7349 then lnp=0.7181051646;
else if dmo013_1=7350 then lnp=0.6652560859;
else if dmo013_1=7352 then lnp=0.6615123499;
else if dmo013_1=7353 then lnp=0.663740038;
else if dmo013_1=7359 then lnp=0.6729377806;
else if dmo013_1=7361 then lnp=0.6683806059;
else if dmo013_1=7363 then lnp=0.6615123499;
else if dmo013_1=7371 then lnp=0.6514213983;
else if dmo013_1=7372 then lnp=0.663740038;
else if dmo013_1=7373 then lnp=0.6668179535;
else if dmo013_1=7374 then lnp=0.663117373;
else if dmo013_1=7376 then lnp=0.6615123499;
else if dmo013_1=7377 then lnp=0.6615123499;
else if dmo013_1=7378 then lnp=0.6601858463;
else if dmo013_1=7379 then lnp=0.6633425244;
else if dmo013_1=7381 then lnp=0.6669982872;
else if dmo013_1=7382 then lnp=0.6616023623;
else if dmo013_1=7384 then lnp=0.6615123499;
else if dmo013_1=7389 then lnp=0.6442878246;
else if dmo013_1=7500 then lnp=0.6690494389;
else if dmo013_1=7513 then lnp=0.6622697418;
else if dmo013_1=7514 then lnp=0.6564853068;
else if dmo013_1=7519 then lnp=0.663740038;
else if dmo013_1=7521 then lnp=0.6652560859;
else if dmo013_1=7530 then lnp=0.663740038;
else if dmo013_1=7532 then lnp=0.7473170868;
else if dmo013_1=7533 then lnp=0.667088458;
else if dmo013_1=7534 then lnp=0.6675766348;
else if dmo013_1=7536 then lnp=0.6700343022;
else if dmo013_1=7537 then lnp=0.6639279938;
else if dmo013_1=7538 then lnp=0.6814827435;
else if dmo013_1=7539 then lnp=0.654936354;
else if dmo013_1=7542 then lnp=0.6655342589;
else if dmo013_1=7549 then lnp=0.6931516731;
else if dmo013_1=7620 then lnp=0.6675766348;
else if dmo013_1=7622 then lnp=0.6722229453;
else if dmo013_1=7623 then lnp=0.6745939186;
else if dmo013_1=7629 then lnp=0.6556101001;
else if dmo013_1=7631 then lnp=0.657376324;
else if dmo013_1=7641 then lnp=0.6721934266;
else if dmo013_1=7690 then lnp=0.6645430187;
else if dmo013_1=7692 then lnp=0.6714709445;
else if dmo013_1=7699 then lnp=0.6870523416;
else if dmo013_1=7812 then lnp=0.6706132163;
else if dmo013_1=7819 then lnp=0.6622697418;
else if dmo013_1=7820 then lnp=0.6615123499;
else if dmo013_1=7841 then lnp=0.6616023623;
else if dmo013_1=7900 then lnp=0.6622697418;
else if dmo013_1=7911 then lnp=0.6643706284;
else if dmo013_1=7922 then lnp=0.6564853068;
else if dmo013_1=7929 then lnp=0.6609801225;
else if dmo013_1=7933 then lnp=0.6624948321;
else if dmo013_1=7941 then lnp=0.663740038;
else if dmo013_1=7948 then lnp=0.6615123499;
else if dmo013_1=7990 then lnp=0.663027317;
else if dmo013_1=7991 then lnp=0.6839148477;
else if dmo013_1=7992 then lnp=0.663117373;
else if dmo013_1=7993 then lnp=0.6615123499;
else if dmo013_1=7996 then lnp=0.6637850759;
else if dmo013_1=7997 then lnp=0.6571965437;
else if dmo013_1=7999 then lnp=0.6594895116;
else if dmo013_1=8010 then lnp=0.6600880839;
else if dmo013_1=8011 then lnp=0.6424436193;
else if dmo013_1=8021 then lnp=0.6053369721;
else if dmo013_1=8031 then lnp=0.663740038;
else if dmo013_1=8041 then lnp=0.668621762;
else if dmo013_1=8042 then lnp=0.6470745202;
else if dmo013_1=8043 then lnp=0.658799361;
else if dmo013_1=8049 then lnp=0.6439340024;
else if dmo013_1=8051 then lnp=0.663027317;
else if dmo013_1=8059 then lnp=0.6646331185;
else if dmo013_1=8062 then lnp=0.6556843843;
else if dmo013_1=8063 then lnp=0.6615573557;
else if dmo013_1=8071 then lnp=0.6638751538;
else if dmo013_1=8072 then lnp=0.6632074316;
else if dmo013_1=8082 then lnp=0.6754901344;
else if dmo013_1=8093 then lnp=0.660800136;
else if dmo013_1=8099 then lnp=0.6603208087;
else if dmo013_1=8100 then lnp=0.6622697418;
else if dmo013_1=8111 then lnp=0.6724088902;
else if dmo013_1=8210 then lnp=0.663740038;
else if dmo013_1=8211 then lnp=0.6472537281;
else if dmo013_1=8221 then lnp=0.663740038;
else if dmo013_1=8222 then lnp=0.6622697418;
else if dmo013_1=8231 then lnp=0.6600430991;
else if dmo013_1=8244 then lnp=0.6644979699;
else if dmo013_1=8249 then lnp=0.6645430187;
else if dmo013_1=8299 then lnp=0.6619174261;
else if dmo013_1=8322 then lnp=0.6439340024;
else if dmo013_1=8331 then lnp=0.6638301145;
else if dmo013_1=8351 then lnp=0.6625554455;
else if dmo013_1=8361 then lnp=0.6508908695;
else if dmo013_1=8399 then lnp=0.6551082273;
else if dmo013_1=8400 then lnp=0.6615123499;
else if dmo013_1=8412 then lnp=0.6586194994;
else if dmo013_1=8422 then lnp=0.6637850759;
else if dmo013_1=8611 then lnp=0.6447689889;
else if dmo013_1=8621 then lnp=0.6660143864;
else if dmo013_1=8631 then lnp=0.6556843843;
else if dmo013_1=8641 then lnp=0.655819154;
else if dmo013_1=8661 then lnp=0.6186136751;
else if dmo013_1=8699 then lnp=0.6593761933;
else if dmo013_1=8700 then lnp=0.663740038;
else if dmo013_1=8711 then lnp=0.6669532028;
else if dmo013_1=8712 then lnp=0.6693201379;
else if dmo013_1=8713 then lnp=0.6624498127;
else if dmo013_1=8721 then lnp=0.7090129447;
else if dmo013_1=8730 then lnp=0.660800136;
else if dmo013_1=8731 then lnp=0.660890128;
else if dmo013_1=8732 then lnp=0.6616023623;
else if dmo013_1=8733 then lnp=0.6593761933;
else if dmo013_1=8734 then lnp=0.6645880683;
else if dmo013_1=8741 then lnp=0.663162402;
else if dmo013_1=8742 then lnp=0.6675844441;
else if dmo013_1=8743 then lnp=0.6616023623;
else if dmo013_1=8744 then lnp=0.663740038;
else if dmo013_1=8748 then lnp=0.676070074;
else if dmo013_1=8999 then lnp=0.6608529242;
else if dmo013_1=9111 then lnp=0.6615123499;
else if dmo013_1=9121 then lnp=0.6549285761;
else if dmo013_1=9199 then lnp=0.663740038;
else if dmo013_1=9221 then lnp=0.6600430991;
else if dmo013_1=9224 then lnp=0.6585745356;
else if dmo013_1=9311 then lnp=0.6615123499;
else if dmo013_1=9431 then lnp=0.6615123499;
else if dmo013_1=9441 then lnp=0.6600430991;
else if dmo013_1=9512 then lnp=0.6622697418;
else if dmo013_1=9611 then lnp=0.663740038;
else if dmo013_1=9621 then lnp=0.6615123499;
else if dmo013_1=9641 then lnp=0.6615123499;
else if dmo013_1=9700 then lnp=0.663740038;
else if dmo013_1=9711 then lnp=0.6615123499;
else lnp=log(.65993/(1-.65993));
 qual_raw_Score= 0.1796893111;
                               qual_raw_Score=qual_raw_Score+lnp       
*-2.755619085;
                                 
qual_raw_Score=qual_raw_Score+o_LGC004_1*0.2651101376;
                                 
qual_raw_Score=qual_raw_Score+o_TTC057_2*0.0867496749;;
                                 
qual_raw_Score=qual_raw_Score+l_CLO014_1*-0.033759789;
                                 
qual_raw_Score=qual_raw_Score+l_TTB009_1*0.3156251555;
                                 qual_raw_Score=qual_raw_Score+l_TTB014_1* 
-0.27883828;
                                 
qual_raw_Score=qual_raw_Score+l_CTB012_1*-0.100998838;
                                 
qual_raw_Score=qual_raw_Score+o_CTB007_1*-0.527823703;
                                 
qual_raw_Score=qual_raw_Score+l_TTP084_2*-0.026084433;
                                 
qual_raw_Score=qual_raw_Score+l_RTC037_1*0.1639734829;
                                 
qual_raw_Score=qual_raw_Score+l_TTO077_1*0.2287419121;
                                 
qual_raw_Score=qual_raw_Score+l_RTD072_1*-0.051117624;
                                 
qual_raw_Score=qual_raw_Score+l_RTC049_2*0.0968053758;
                                 
qual_raw_Score=qual_raw_Score+l_CLP016_1*-0.042371009;
                                 
qual_raw_Score=qual_raw_Score+l_TTP079_1*-0.075303832;


;
qual_prob=1-(exp(qual_raw_Score)/(1+exp(qual_raw_Score)));
run;



data decline_all_var;
set qual_all_Var;
 l_LGC004_1=log(LGC004_1+1); 
l_TTB009_2=log(TTB009_2+1); 
l_TXB002_2=log(TXB002_2+1); 
l_CLC010_1=log(CLC010_1+1); 
o_TTB008_2=(TTB008_2=0); 
l_TTC068_1=log(TTC068_1+1); 
o_PRO001_2=(PRO001_2=0); 
l_TTB013_1=log(TTB013_1+1); 
o_TTB007_2=(TTB007_2=0); 
l_TTB020_1=log(TTB020_1+1); 
o_TTB033_2=(TTB033_2=0); 
l_TXC012_2=log(TXC012_2+1); 
if l_LGC004_1=. then l_LGC004_1=0; 
if l_TTB009_2=. then l_TTB009_2=0; 
if l_TXB002_2=. then l_TXB002_2=0; 
if l_CLC010_1=. then l_CLC010_1=0; 
  
if l_TTC068_1=. then l_TTC068_1=0; 
  
if l_TTB013_1=. then l_TTB013_1=0; 
  
if l_TTB020_1=. then l_TTB020_1=0; 
  
if l_TXC012_2=. then l_TXC012_2=0; 


;

decline_raw_score= 0.5021178331 ;
decline_raw_score=decline_raw_score+l_LGC004_1*-0.889087897 ;
decline_raw_score=decline_raw_score+l_TTB009_2*0.0648377324 ;
decline_raw_score=decline_raw_score+l_TXB002_2*-0.118499196 ;
decline_raw_score=decline_raw_score+l_CLC010_1*-0.647361832 ;
decline_raw_score=decline_raw_score+o_TTB008_2*0.3248450747 ;
decline_raw_score=decline_raw_score+l_TTC068_1*0.4491355799 ;
decline_raw_score=decline_raw_score+o_PRO001_2*-0.632159673 ;
decline_raw_score=decline_raw_score+l_TTB013_1*-0.174841128 ;
decline_raw_score=decline_raw_score+o_TTB007_2*-0.771834189 ;
decline_raw_score=decline_raw_score+l_TTB020_1*0.1227369292 ;
decline_raw_score=decline_raw_score+o_TTB033_2*0.8098060842 ;
decline_raw_score=decline_raw_score+l_TXC012_2*0.5468726644 ;




decline_prob=1-(exp(decline_raw_score)/(1+exp(decline_raw_score)));
run;



data response_all_var;
set decline_all_Var;
CLO014_d    =     CLO014_1    -     CLO014_2    ;
clo014_C1=(clo014_d=1);
sc=DMO013_1+0;
intercept=1;
LOGTTO077_1 =     log(  TTO077_1    +     1);
  if LOGTTO077_1 ne . then M_LOGTTO077_1=LOGTTO077_1;
  else  m_LOGTTO077_1=0;
miss_otp017_1=(otp017_1=.);
  if otp017_1 ne . then m_otp017_1=otp017_1;
  else m_otp017_1=0;
  cottage=(HOME_BASED_BUSINESS_ID='Y');

ttc039_2_z=(ttc039_2=0);

if TTC060_2 ne . then m_TTC060_2=TTC060_2;
else m_TTC060_2=0;

clp017_1_z=(clp017_1=0);
lgc004_1_z=(lgc004_1=0);
ttp084_1_z=(ttp084_1=0);
rtd071_2_z=(rtd071_2=0);

if ttc063_1 ne . then   m_ttc063_1=ttc063_1;
else m_ttc063_1=0;
  if ttp084_1 ne . then  m_ttp084_1=ttp084_1;
  else m_ttp084_1=0;
  /*Size Code*/

if DMO004_1=''  then esizelg=   0.26008;
else if DMO004_1='A' then  esizelg=   0.10933;
else if DMO004_1='B' then  esizelg=  -0.21636;
else if DMO004_1='C' then  esizelg=  -0.54410;
  else if DMO004_1='D' then  esizelg= -0.79982;
else esizelg=  -1.40442;
/*Sales Code*/

if ANNUAL_SALES_SIZE_CODE='' then saleslg=  0.14786;
  else if ANNUAL_SALES_SIZE_CODE='A' then saleslg=-0.02826;
  else if ANNUAL_SALES_SIZE_CODE='B' then saleslg=-0.20834;
else saleslg=-0.46628;

/*SIC Code*/
if   100   <=    sc    <=    999   then sic_trans   =     -0.14660    ;
else  if    1000  <=    sc    <=    1499  then sic_trans   =     -0.34805    ;
else  if    1500  <=    sc    <=    1799  then sic_trans   =     0.09516     ;
else  if    2000  <=    sc    <=    3999  then sic_trans   =     -0.34805    ;
else  if    4000  <=    sc    <=    4999  then sic_trans   =     0.24613     ;
else  if    5000  <=    sc    <=    5199  then sic_trans   =     -0.06351    ;
else  if    5200  <=    sc    <=    5999  then sic_trans   =     -0.24407    ;
else  if    6000  <=    sc    <=    6799  then sic_trans   =     0.31015     ;
else  if    7000  <=    sc    <=    8999  then sic_trans   =     0.02665     ;
else                    sic_trans         =     0.30827     ;

******Recoding Mcount*****************************;
if Orig_MCount=. then Mcount=0;
else Mcount=Orig_MCount+1;

;
response_raw_Score=1.3398990109-4.32309;

  response_raw_score=response_raw_score+ttc039_2_z   *0.2957291452;
                                
response_raw_score=response_raw_score+m_TTC060_2   *0.2611529925;
                                
response_raw_score=response_raw_score+M_LOGTTO077_1*-0.200795648;
                                
response_raw_score=response_raw_score+clp017_1_z   *-0.171314138;
                                
response_raw_score=response_raw_score+lgc004_1_z   *-0.344584066;
                                
response_raw_score=response_raw_score+miss_otp017_1* -1.72412823;
                                
response_raw_score=response_raw_score+m_otp017_1   *0.0079569604;
                                
response_raw_score=response_raw_score+ttp084_1_z   *0.2456620984;
                                
response_raw_score=response_raw_score+m_ttp084_1   *0.0047357727;
                                
response_raw_score=response_raw_score+cottage      *0.2930471443;
                                
response_raw_score=response_raw_score+m_ttc063_1   * -0.08569703;
                                
response_raw_score=response_raw_score+saleslg      *0.5004850209;
                                
response_raw_score=response_raw_score+esizelg      *0.6653114912;
                                
response_raw_score=response_raw_score+rtd071_2_z   *-0.151207095;
                                
response_raw_score=response_raw_score+clo014_C1    *0.3920668112;
                                
response_raw_score=response_raw_score+MCOUNT       *-0.230356262;
                                
response_raw_score=response_raw_score+sic_trans    *0.5139656658;



response_prob=(exp(response_raw_score)/(1+exp(response_raw_score)));
run;

Title "MCount after recoding";
proc freq data=response_all_var ;
table Mcount*Orig_MCount/missing list;
run;


************************hard cut deciles*************************;
data Post_merge_decile;
	set response_all_var;

if qual_prob<=0.5406977018 then qpgroup=1;
else if qual_prob<=0.572374111  then qpgroup=2;
else if qual_prob<=0.595836318  then qpgroup=3;
else if qual_prob<=0.6164075986 then qpgroup=4;
else if qual_prob<=0.6360189407 then qpgroup=5;
else if qual_prob<=0.6558059825 then qpgroup=6;
else if qual_prob<=0.6771334534 then qpgroup=7;
else if qual_prob<=0.7021996838 then qpgroup=8;
else if qual_prob<=0.7368202669 then qpgroup=9;
else qpgroup=10;

if response_prob<=0.0049744756270 then rpgroup=1;
else if response_prob<=0.0066411036943 then rpgroup=2;
else if response_prob<=0.0080719509939 then rpgroup=3;
else if response_prob<=0.0094531315186 then rpgroup=4;
else if response_prob<=0.0108833662509 then rpgroup=5;
else if response_prob<=0.0124604996689 then rpgroup=6;
else if response_prob<=0.0143512081264 then rpgroup=7;
else if response_prob<=0.0169017998880 then rpgroup=8;
else if response_prob<=0.0214028343414 then rpgroup=9;
else  rpgroup=10;

if decline_prob<=0.1752952418 then dpgroup=1;
else if decline_prob<=0.2133672624 then dpgroup=2;
else if decline_prob<=0.2480171089 then dpgroup=3;
else if decline_prob<=0.2846928994 then dpgroup=4;
else if decline_prob<=0.3268713354 then dpgroup=5;
else if decline_prob<=0.3745549731 then dpgroup=6;
else if decline_prob<=0.4288401599 then dpgroup=7;
else if decline_prob<=0.4691773095 then dpgroup=8;
else if decline_prob<=0.539418503  then dpgroup=9;
else  dpgroup=10;

run;
/*3260335*/

Title "Decile distribution";
proc freq data=Post_merge_decile;
table  rpgroup qpgroup dpgroup/missing;
run;

GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;


/*   START OF NODE: 06_Final_file   */
%LET _CLIENTTASKLABEL='06_Final_file';
%LET _CLIENTPROJECTPATH=
'P:\offshore_office\frankji\forwardline\ForwardLine_Score_20160510_v1.egp';
%LET _CLIENTPROJECTNAME='ForwardLine_Score_20160510_v1.egp';
%LET _SASPROGRAMFILE=;

GOPTIONS ACCESSIBLE;

********************Append old 
scores*************************************************;

proc sort data=Post_merge_decile nodupkey;
by bin list1;
run;

proc sort data=tar.old_score out=old_score nodupkey;
by bin list;
run;

data &out.;
	merge Post_merge_decile(in=a) old_score(in=b rename=(list=list1));
	by bin list1;
	if a;
	merge_flag=compress(a||b);
run;

Title "Match result with old score file";
proc freq data=&out.;
table merge_flag/missing;
run;


data &final_out.;
	set &out.(drop=Mcount);
	rename orig_Mcount=Mcount;
	rename list1=List;

	keep bin qual_prob response_prob decline_prob qpgroup rpgroup dpgroup 
orig_Mcount list1 
LGC004_1
TTC057_2
CLO014_1
TTB009_1
TTB014_1
CTB012_1
CTB007_1
TTP084_2
RTC037_1
TTO077_1
RTD072_1
RTC049_2
CLP016_1
TTP079_1
dmo013_1
TTB009_2
TXB002_2
CLC010_1
TTB008_2
TTC068_1
PRO001_2
TTB013_1
TTB007_2
TTB020_1
TTB033_2
TXC012_2
CLO014_2
otp017_1
HOME_BASED_BUSINESS_ID
ttc039_2
TTC060_2
clp017_1
ttp084_1
rtd071_2
ttc063_1
DMO004_1
ANNUAL_SALES_SIZE_CODE
SEP_APPROVAL_SCORE 
SEP_RESPONSE_SCORE
SEP_APPROVAL_GROUP
SEP_RESPONSE_GROUP 
FEB_APPROVAL_SCORE
FEB_RESPONSE_SCORE
FEB_APPROVAL_GROUP 
FEB_RESPONSE_GROUP

;
run;



GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;


/*   START OF NODE: 07_report_raw   */
%LET _CLIENTTASKLABEL='07_report_raw';
%LET _CLIENTPROJECTPATH=
'P:\offshore_office\frankji\forwardline\ForwardLine_Score_20160510_v1.egp';
%LET _CLIENTPROJECTNAME='ForwardLine_Score_20160510_v1.egp';
%LET _SASPROGRAMFILE=;

GOPTIONS ACCESSIBLE;


/*Response model recoding variable check*/
Title "Response model recoding variable check";
proc means data=&out. n nmiss mean min p25 p50 p75 max;
var ttc039_2_z
m_TTC060_2
M_LOGTTO077_1
clp017_1_z
lgc004_1_z
miss_otp017_1
m_otp017_1
ttp084_1_z
m_ttp084_1
cottage
m_ttc063_1
saleslg
esizelg
rtd071_2_z
clo014_C1
MCOUNT
sic_trans
;
run;


/*Qual model recoding variable check*/
Title "Qual model recoding variable check";
proc means data=&out. n nmiss mean min p25 p50 p75 max;
var lnp
o_LGC004_1
o_TTC057_2
l_CLO014_1
l_TTB009_1
l_TTB014_1
l_CTB012_1
o_CTB007_1
l_TTP084_2
l_RTC037_1
l_TTO077_1
l_RTD072_1
l_RTC049_2
l_CLP016_1
l_TTP079_1

;
run;

/*Decline model recoding variable check*/
Title "Decline model recoding variable check";
proc means data=&out. n nmiss mean min p25 p50 p75 max;
var l_LGC004_1
l_TTB009_2
l_TXB002_2
l_CLC010_1
o_TTB008_2
l_TTC068_1
o_PRO001_2
l_TTB013_1
o_TTB007_2
l_TTB020_1
o_TTB033_2
l_TXC012_2
;
run;


/*Response model original variable check*/
Title "Response model original variable check";
proc means data=&out. n nmiss mean min p25 p50 p75 max;
var 
ttc039_2
TTC060_2
TTO077_1
clp017_1
lgc004_1
otp017_1
otp017_1
ttp084_1
ttp084_1
/*HOME_BASED_BUSINESS_ID*/
ttc063_1
/*ANNUAL_SALES_SIZE_CODE*/
/*DMO004_1*/
rtd071_2
CLO014_1
CLO014_2
Orig_Mcount
DMO013_1
;
run;

proc freq data=&out.;
table HOME_BASED_BUSINESS_ID ANNUAL_SALES_SIZE_CODE DMO004_1 /missing;
run;

/*Qualified Responder model original variable check*/
Title "Qualified Responder model original variable check";
proc means data=&out. n nmiss mean min p25 p50 p75 max;
var 
dmo013_1
LGC004_1
TTC057_2
CLO014_1
TTB009_1
TTB014_1
CTB012_1
CTB007_1
TTP084_2
RTC037_1
TTO077_1
RTD072_1
RTC049_2
CLP016_1
TTP079_1
;
run;

/*Decline model original variable check*/
Title "Decline model original variable check";
proc means data=&out. n nmiss mean min p25 p50 p75 max;
var 
LGC004_1
TTB009_2
TXB002_2
CLC010_1
TTB008_2
TTC068_1
PRO001_2
TTB013_1
TTB007_2
TTB020_1
TTB033_2
TXC012_2
;
run;



Title "response model distribution";

proc tabulate data=&out. noseps missing;
class rpgroup list1;
table rpgroup, list1/box="appointed-licensed" indent=3;
run;

Title "qual model distribution";
proc tabulate data=&out. noseps missing;
class qpgroup list1;
table qpgroup, list1/box="appointed-licensed" indent=3;
run;

Title "Decline model distribution";
proc tabulate data=&out. noseps missing;
class dpgroup list1;
table dpgroup, list1/box="appointed-licensed" indent=3;
run;


*****************NxN report******************************************;

data tar.NXN_report_raw;
	set &out.;
	response_group=compress("RG"||put(rpgroup,z2.));
	Approval_Group=compress("AG"||put(qpgroup,z2.));
	Compiled_Score=response_group||" "||Approval_Group;
	if	Compiled_Score=	"RG10 AG10"	then 	Model_Priority=	1	;
else if	Compiled_Score=	"RG10 AG09"	then 	Model_Priority=	2	;
else if	Compiled_Score=	"RG09 AG10"	then 	Model_Priority=	3	;
else if	Compiled_Score=	"RG10 AG08"	then 	Model_Priority=	4	;
else if	Compiled_Score=	"RG10 AG07"	then 	Model_Priority=	5	;
else if	Compiled_Score=	"RG08 AG10"	then 	Model_Priority=	6	;
else if	Compiled_Score=	"RG09 AG09"	then 	Model_Priority=	7	;
else if	Compiled_Score=	"RG10 AG06"	then 	Model_Priority=	8	;
else if	Compiled_Score=	"RG09 AG08"	then 	Model_Priority=	9	;
else if	Compiled_Score=	"RG10 AG05"	then 	Model_Priority=	10	;
else if	Compiled_Score=	"RG07 AG10"	then 	Model_Priority=	11	;
else if	Compiled_Score=	"RG08 AG09"	then 	Model_Priority=	12	;
else if	Compiled_Score=	"RG10 AG04"	then 	Model_Priority=	13	;
else if	Compiled_Score=	"RG09 AG07"	then 	Model_Priority=	14	;
else if	Compiled_Score=	"RG06 AG10"	then 	Model_Priority=	15	;
else if	Compiled_Score=	"RG08 AG08"	then 	Model_Priority=	16	;
else if	Compiled_Score=	"RG07 AG09"	then 	Model_Priority=	17	;
else if	Compiled_Score=	"RG09 AG06"	then 	Model_Priority=	18	;
else if	Compiled_Score=	"RG10 AG03"	then 	Model_Priority=	19	;
else if	Compiled_Score=	"RG08 AG07"	then 	Model_Priority=	20	;
else if	Compiled_Score=	"RG05 AG10"	then 	Model_Priority=	21	;
else if	Compiled_Score=	"RG09 AG05"	then 	Model_Priority=	22	;
else if	Compiled_Score=	"RG07 AG08"	then 	Model_Priority=	23	;
else if	Compiled_Score=	"RG06 AG09"	then 	Model_Priority=	24	;
else if	Compiled_Score=	"RG08 AG06"	then 	Model_Priority=	25	;
else if	Compiled_Score=	"RG10 AG02"	then 	Model_Priority=	26	;
else if	Compiled_Score=	"RG07 AG07"	then 	Model_Priority=	27	;
else if	Compiled_Score=	"RG09 AG04"	then 	Model_Priority=	28	;
else if	Compiled_Score=	"RG04 AG10"	then 	Model_Priority=	29	;
else if	Compiled_Score=	"RG06 AG08"	then 	Model_Priority=	30	;
else if	Compiled_Score=	"RG05 AG09"	then 	Model_Priority=	31	;
else if	Compiled_Score=	"RG08 AG05"	then 	Model_Priority=	32	;
else if	Compiled_Score=	"RG07 AG06"	then 	Model_Priority=	33	;
else if	Compiled_Score=	"RG09 AG03"	then 	Model_Priority=	34	;
else if	Compiled_Score=	"RG06 AG07"	then 	Model_Priority=	35	;
else if	Compiled_Score=	"RG05 AG08"	then 	Model_Priority=	36	;
else if	Compiled_Score=	"RG08 AG04"	then 	Model_Priority=	37	;
else if	Compiled_Score=	"RG03 AG10"	then 	Model_Priority=	38	;
else if	Compiled_Score=	"RG04 AG09"	then 	Model_Priority=	39	;
else if	Compiled_Score=	"RG07 AG05"	then 	Model_Priority=	40	;
else if	Compiled_Score=	"RG06 AG06"	then 	Model_Priority=	41	;
else if	Compiled_Score=	"RG05 AG07"	then 	Model_Priority=	42	;
else if	Compiled_Score=	"RG02 AG10"	then 	Model_Priority=	43	;
else if	Compiled_Score=	"RG07 AG04"	then 	Model_Priority=	44	;
else if	Compiled_Score=	"RG04 AG08"	then 	Model_Priority=	45	;
else if	Compiled_Score=	"RG08 AG03"	then 	Model_Priority=	46	;
else if	Compiled_Score=	"RG03 AG09"	then 	Model_Priority=	47	;
else if	Compiled_Score=	"RG06 AG05"	then 	Model_Priority=	48	;
else if	Compiled_Score=	"RG09 AG02"	then 	Model_Priority=	49	;
else if	Compiled_Score=	"RG05 AG06"	then 	Model_Priority=	50	;
else if	Compiled_Score=	"RG04 AG07"	then 	Model_Priority=	51	;
else if	Compiled_Score=	"RG10 AG01"	then 	Model_Priority=	52	;
else if	Compiled_Score=	"RG07 AG03"	then 	Model_Priority=	53	;
else if	Compiled_Score=	"RG06 AG04"	then 	Model_Priority=	54	;
else if	Compiled_Score=	"RG03 AG08"	then 	Model_Priority=	55	;
else if	Compiled_Score=	"RG05 AG05"	then 	Model_Priority=	56	;
else if	Compiled_Score=	"RG04 AG06"	then 	Model_Priority=	57	;
else if	Compiled_Score=	"RG02 AG09"	then 	Model_Priority=	58	;
else if	Compiled_Score=	"RG03 AG07"	then 	Model_Priority=	59	;
else if	Compiled_Score=	"RG08 AG02"	then 	Model_Priority=	60	;
else if	Compiled_Score=	"RG05 AG04"	then 	Model_Priority=	61	;
else if	Compiled_Score=	"RG04 AG05"	then 	Model_Priority=	62	;
else if	Compiled_Score=	"RG03 AG06"	then 	Model_Priority=	63	;
else if	Compiled_Score=	"RG06 AG03"	then 	Model_Priority=	64	;
else if	Compiled_Score=	"RG02 AG08"	then 	Model_Priority=	65	;
else if	Compiled_Score=	"RG07 AG02"	then 	Model_Priority=	66	;
else if	Compiled_Score=	"RG01 AG10"	then 	Model_Priority=	67	;
else if	Compiled_Score=	"RG04 AG04"	then 	Model_Priority=	68	;
else if	Compiled_Score=	"RG05 AG03"	then 	Model_Priority=	69	;
else if	Compiled_Score=	"RG02 AG07"	then 	Model_Priority=	70	;
else if	Compiled_Score=	"RG03 AG05"	then 	Model_Priority=	71	;
else if	Compiled_Score=	"RG06 AG02"	then 	Model_Priority=	72	;
else if	Compiled_Score=	"RG09 AG01"	then 	Model_Priority=	73	;
else if	Compiled_Score=	"RG01 AG09"	then 	Model_Priority=	74	;
else if	Compiled_Score=	"RG02 AG06"	then 	Model_Priority=	75	;
else if	Compiled_Score=	"RG03 AG04"	then 	Model_Priority=	76	;
else if	Compiled_Score=	"RG04 AG03"	then 	Model_Priority=	77	;
else if	Compiled_Score=	"RG01 AG08"	then 	Model_Priority=	78	;
else if	Compiled_Score=	"RG02 AG05"	then 	Model_Priority=	79	;
else if	Compiled_Score=	"RG05 AG02"	then 	Model_Priority=	80	;
else if	Compiled_Score=	"RG08 AG01"	then 	Model_Priority=	81	;
else if	Compiled_Score=	"RG02 AG04"	then 	Model_Priority=	82	;
else if	Compiled_Score=	"RG03 AG03"	then 	Model_Priority=	83	;
else if	Compiled_Score=	"RG01 AG07"	then 	Model_Priority=	84	;
else if	Compiled_Score=	"RG01 AG06"	then 	Model_Priority=	85	;
else if	Compiled_Score=	"RG04 AG02"	then 	Model_Priority=	86	;
else if	Compiled_Score=	"RG02 AG03"	then 	Model_Priority=	87	;
else if	Compiled_Score=	"RG07 AG01"	then 	Model_Priority=	88	;
else if	Compiled_Score=	"RG03 AG02"	then 	Model_Priority=	89	;
else if	Compiled_Score=	"RG06 AG01"	then 	Model_Priority=	90	;
else if	Compiled_Score=	"RG01 AG05"	then 	Model_Priority=	91	;
else if	Compiled_Score=	"RG01 AG04"	then 	Model_Priority=	92	;
else if	Compiled_Score=	"RG02 AG02"	then 	Model_Priority=	93	;
else if	Compiled_Score=	"RG01 AG03"	then 	Model_Priority=	94	;
else if	Compiled_Score=	"RG04 AG01"	then 	Model_Priority=	95	;
else if	Compiled_Score=	"RG05 AG01"	then 	Model_Priority=	96	;
else if	Compiled_Score=	"RG01 AG02"	then 	Model_Priority=	97	;
else if	Compiled_Score=	"RG03 AG01"	then 	Model_Priority=	98	;
else if	Compiled_Score=	"RG02 AG01"	then 	Model_Priority=	99	;
else if	Compiled_Score=	"RG01 AG01"	then 	Model_Priority=	100	;

run;


title "Check the translate for Model Priority";
proc freq data=tar.NXN_report_raw;
table response_group*rpgroup
	Approval_Group*qpgroup
	Compiled_Score*response_group*Approval_Group
	Compiled_Score*Model_Priority/missing list;
run;

proc sql;
	create table NXN_report_raw_out as
	select distinct dpgroup, Model_Priority as id, response_group, 
Approval_Group,Compiled_Score,
		sum(case when list1="A" then 1 else 0 end) as ListA_count,
 		sum(case when list1="B" then 1 else 0 end) as ListB_count,
		sum(case when list1="C" then 1 else 0 end) as ListC_count,
		sum(1) as Total_count
	from tar.NXN_report_raw
	group by dpgroup, Model_Priority
	order by dpgroup, Model_Priority
	;
quit;
/*1000*/

GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;


/*   START OF NODE: 08_Selection_setup   */
%LET _CLIENTTASKLABEL='08_Selection_setup';
%LET _CLIENTPROJECTPATH=
'P:\offshore_office\frankji\forwardline\ForwardLine_Score_20160510_v1.egp';
%LET _CLIENTPROJECTNAME='ForwardLine_Score_20160510_v1.egp';
%LET _SASPROGRAMFILE=;

GOPTIONS ACCESSIBLE;

*********************************Readin the Mail suppresion 
file************************;

data tar.Mail_suppr;
	
    INFILE 
"/mnt/projects/locked/forwardline/scoring_201604/rawdata/160425_mailed_supp_160324_to_160422.csv"
        LRECL=5000
        ENCODING="LATIN1"
        TERMSTR=CRLF
        DLM='2C'x
        truncover
        DSD 
		firstobs=2
;
    INPUT
        BIN : $CHAR9.
        Member_ID     : $CHAR15.
        Campaign_Name : $CHAR35.
        DM_Drop_Date :  MMDDYY9.
        F5               : $CHAR1.
        F6               : $CHAR1.
        F7               : $CHAR1.
        F8               : $CHAR1.
        F9               : $CHAR1.
        F10              : $CHAR1. ;
		format DM_Drop_Date mmddyy10.;
RUN;
/*269,692*/

data test;
	set tar.Mail_suppr;
	where bin^='';
run;
/*259626*/

*********************Select targets based on the instructions from 
Client********************; 

data FWL_Score_Cut;
	set &out.;
	 where dpgroup^=10;  /* drop all the records in dpgroup 10*/
	run;
/*3013109*/

proc sort data=tar.Mail_suppr out=Mail_suppr nodupkey;
by bin;
run;
/*259618*/
proc sort data=FWL_Score_Cut nodupkey;
by bin;
run;

data post_merge_suppressed;
	merge FWL_Score_Cut(in=a) Mail_suppr(in=b keep=bin);
	by bin;
	if a and not b;
/*	merge_Flag=compress(a||b);*/
run;
/*2899545 , 113564 has been supppressed*/

/*proc freq data=post_merge_suppressed;*/
/*table merge_Flag/missing;*/
/*run;*/

data post_merge_suppressed_1;
	set post_merge_suppressed;

	if rpgroup=10 and qpgroup=10 then Model_Priority=1;
	else if rpgroup=10 and qpgroup=9 then Model_Priority=2;
	else if rpgroup=10 and qpgroup=8 then Model_Priority=3;
	else if rpgroup=9 and qpgroup=10 then Model_Priority=4;
	else if rpgroup=9 and qpgroup=9 then Model_Priority=5;
	else if rpgroup=9 and qpgroup=8 then Model_Priority=6;
run;

Title "Check the model priority";

proc freq data=post_merge_suppressed_1;
table Model_Priority*rpgroup*qpgroup/missing list;
run;

Title "double Check the model priority";
proc freq data=post_merge_suppressed_1(where=(Model_Priority>0));
table Model_Priority*rpgroup*qpgroup/missing list;
run;

proc sort data=post_merge_suppressed_1(where=(Model_Priority=3)) 
out=post_merge_suppressed_3;
by bin descending response_prob descending qual_prob;
run;
/*128226*/

data selected_target;
	set post_merge_suppressed_1(where=(Model_Priority in (1,2)))
		post_merge_suppressed_3(obs= 76742);
run;
/*249455*/

proc freq data=selected_target;
table Model_Priority*rpgroup*qpgroup/missing list;
run;

data selected_target_1;
	set selected_target;
	x=ranuni(1009);
run;

proc sort data=selected_target_1;
by x;
run;

data tar.&select.;
	set selected_target_1;
	
	number=_n_;
	if _n_<=58250 then mail_drop=1;
	else if _n_>58250 and _n_<=116500 then mail_drop=2;
	else if _n_>116500 and _n_<=160750 then mail_drop=3;
	else if _n_>160750 and _n_<=206000 then mail_drop=4;
	else mail_drop=5;
run;

title "Check the random var for mail drop";

proc means data=tar.&select. n nmiss mean min p25 p50 p75 max;
class mail_drop;
var x;
run;


title "cross table for mail drop and list source";

proc tabulate data=tar.&select.  noseps missing;
class mail_drop list1;
table mail_drop, list1/box="appointed-licensed" indent=3;
run;


title "cross table for mail drop and list source";
proc tabulate data=tar.&select.  noseps missing;
class mail_drop Model_Priority;
table mail_drop, Model_Priority/box="appointed-licensed" indent=3;
run;

title "cross table for mail drop and state";
proc tabulate data=tar.&select.  noseps missing;
class state mail_drop ;
table state, mail_drop/box="appointed-licensed" indent=3;
run;

title "cross table for mail drop and Decline decile";

proc tabulate data=tar.&select.  noseps missing;
class dpgroup mail_drop ;
table dpgroup, mail_drop/box="appointed-licensed" indent=3;
run;

data _null_;
	file "&select_out." dlm="|" ;
	set tar.&select. ;
	if _N_=1 then 
	put 
"BIN"	"|"
"qpgroup"	"|"
"rpgroup"	"|"
"dpgroup"	"|"
"decline_prob"	"|"
"response_prob"	"|"
"qual_prob"	"|"
"Model_Priority"	"|"
"TSG_Sequence_Number"	"|"
"Jacket"	"|"
"LIST"	"|"
"mail_drop"
;
put 
BIN
qpgroup
rpgroup
dpgroup
decline_prob
response_prob
qual_prob
Model_Priority
TSG_Sequence_Number
Jacket
LIST1
mail_drop
;
run;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;


/*   START OF NODE: Other_output   */
%LET _CLIENTTASKLABEL='Other_output';
%LET _CLIENTPROJECTPATH=
'P:\offshore_office\frankji\forwardline\ForwardLine_Score_20160510_v1.egp';
%LET _CLIENTPROJECTNAME='ForwardLine_Score_20160510_v1.egp';
%LET _SASPROGRAMFILE=;

GOPTIONS ACCESSIBLE;


************************Pull out the remaining of priority 3 
records**********************;

data post_merge_suppressed_remain;
	set post_merge_suppressed_3(firstobs=76743);
run;
/*51,484*/

data post_merge_suppressed_remain_1;
	set post_merge_suppressed_remain;
	x=ranuni(1009);
run;

proc sort data=post_merge_suppressed_remain_1;
by x;
run;

data tar.post_merge_suppressed_remain;
	set post_merge_suppressed_remain_1;
	
	number=_n_;
	if _n_<=12022 then mail_drop=1;
	else if _n_>12022 and _n_<=24044 then mail_drop=2;
	else if _n_>24044 and _n_<=33177 then mail_drop=3;
	else if _n_>33177 and _n_<=42516 then mail_drop=4;
	else mail_drop=5;
run;

proc means data=tar.post_merge_suppressed_remain n nmiss mean min p25 p50 p75 
max;
class mail_drop;
var x;
run;

proc tabulate data=tar.post_merge_suppressed_remain noseps missing;
class mail_drop list1;
table mail_drop, list1/box="appointed-licensed" indent=3;
run;

proc tabulate data=tar.post_merge_suppressed_remain noseps missing;
class mail_drop Model_Priority;
table mail_drop, Model_Priority/box="appointed-licensed" indent=3;
run;

proc tabulate data=tar.post_merge_suppressed_remain noseps missing;
class dpgroup mail_drop ;
table dpgroup, mail_drop/box="appointed-licensed" indent=3;
run;

proc freq data=tar.post_merge_suppressed_remain;
table Model_Priority*qpgroup*rpgroup/missing list;
run;

data _null_;
	file 
"/mnt/projects/locked/forwardline/scoring_201604/Deliver/FWL_remain_Prio3_20160503.txt" 
dlm="|" ;
	set tar.post_merge_suppressed_remain;
	if _N_=1 then 
	put 
"BIN"	"|"
"qpgroup"	"|"
"rpgroup"	"|"
"dpgroup"	"|"
"decline_prob"	"|"
"response_prob"	"|"
"qual_prob"	"|"
"Model_Priority"	"|"
"TSG_Sequence_Number"	"|"
"Jacket"	"|"
"LIST"	"|"
"mail_drop"
;
put 
BIN
qpgroup
rpgroup
dpgroup
decline_prob
response_prob
qual_prob
Model_Priority
TSG_Sequence_Number
Jacket
LIST1
mail_drop
;
run;

/*test the remaind has no overlap with selected ~250K targets*/

proc sort data=tar.&select. out=test1 nodupkey;
by bin;
run;

proc sort data=tar.post_merge_suppressed_remain out=test2 nodupkey;
by bin;
run;

data test3;
	merge test1(in=a) test2(in=b);
	by bin;
	merge_flag=compress(a||b);
run;

proc freq data=test3;
table merge_flag/missing;
run;


**********************Pull out the facebook 
list***************************************;

data post_merge_suppressed_Prio;
	set tar.post_merge_suppressed;

	if rpgroup=10 and qpgroup=10 then Model_Priority=1;
	else if rpgroup=10 and qpgroup=9 then Model_Priority=2;
	else if rpgroup=10 and qpgroup=8 then Model_Priority=3;
	else if rpgroup=9 and qpgroup=10 then Model_Priority=4;
	else if rpgroup=9 and qpgroup=9 then Model_Priority=5;
	else if rpgroup=9 and qpgroup=8 then Model_Priority=6;
run;

proc freq data=post_merge_suppressed_Prio;
table Model_Priority*rpgroup*qpgroup/missing list;
run;

data tar.facebook_list_20160503;
	set post_merge_suppressed_Prio;
	where Model_Priority in (4,5);
run;

proc freq data=tar.facebook_list_20160503;
table Model_Priority*rpgroup*qpgroup/missing list;
run;

data _null_;
	file 
"/mnt/projects/locked/forwardline/scoring_201604/Deliver/FWL_facebook_Prio4_20160503.txt" 
dlm="|" ;
	set tar.facebook_list_20160503(where=(Model_Priority=4));
	if _N_=1 then 
	put 
"BIN"	"|"
"TSG_Sequence_Number"	"|"
"Jacket"	"|"
"LIST"
;
put 
BIN
TSG_Sequence_Number
Jacket
LIST1
;
run;
/*38,189*/

data _null_;
	file 
"/mnt/projects/locked/forwardline/scoring_201604/Deliver/FWL_facebook_Prio5_20160503.txt" 
dlm="|" ;
	set tar.facebook_list_20160503(where=(Model_Priority=5));
	if _N_=1 then 
	put 
"BIN"	"|"
"TSG_Sequence_Number"	"|"
"Jacket"	"|"
"LIST"	
;
put 
BIN
TSG_Sequence_Number
Jacket
LIST1
;
run;
/*87,787*/

proc freq data=tar.facebook_list_20160503(where=(Model_Priority=4));
table LIST1/missing;
run;

proc freq data=tar.facebook_list_20160503(where=(Model_Priority=5));
table LIST1/missing;
run;

************************************Output Campaign history 
file*****************************;

data FWL_Post_all;	
set &out.;
keep BIN
qpgroup
rpgroup
dpgroup
decline_prob
response_prob
qual_prob
Model_Priority
TSG_Sequence_Number
Jacket
LIST1
;

if rpgroup=10 and qpgroup=10 then Model_Priority=1;
	else if rpgroup=10 and qpgroup=9 then Model_Priority=2;
	else if rpgroup=10 and qpgroup=8 then Model_Priority=3;
	else if rpgroup=9 and qpgroup=10 then Model_Priority=4;
	else if rpgroup=9 and qpgroup=9 then Model_Priority=5;
	else if rpgroup=9 and qpgroup=8 then Model_Priority=6;

run;

proc freq data=FWL_Post_all;
table Model_Priority*rpgroup*qpgroup/missing list;
run;

proc sort data=FWL_Post_all nodupkey;
by bin;
run;

proc sort data=tar.&select. out=selected_target(keep=bin) nodupkey;
by bin;
run;

data FWL_Post_all_1;
	merge FWL_Post_all(in=a) selected_target(in=b);
	by bin;
/*	merge_Flag=compress(a||b);*/
	if b then target_flag="Y";
	else target_flag="N"; 
run;

proc freq data=FWL_Post_all_1;
table target_flag/missing;
run;


data tar.history_20160428;
	merge FWL_Post_all_1(in=a) tar.BizAgg_renamed_all(in=b);
	by bin;
	if a;
	drop combine_ind File_ind_2 File_ind_1 FILLER:;
	rename List1=list;
/*	merge_flag=compress(a||b);*/

run;

proc contents data=tar.history_20160428 order=varnum;
run;

proc export data=tar.history_20160428 file=
"/mnt/projects/locked/forwardline/scoring_201604/Deliver/Universe_history_20140428.txt" 
dbms=dlm replace; 
delimiter="|";
run;
/*3260336*/

proc freq data=tar.history_20160428;
table qpgroup
rpgroup
dpgroup
Model_Priority
Jacket
LIST
target_Flag
/missing;
run;


**********************Output Decline Decile 10 
records******************************;


data FWL_Score_d10;
	set  &out.;
	 where dpgroup=10;  /* drop all the records in dpgroup 10*/
	run;
/*247226*/

proc sort data=FWL_Score_d10 nodupkey;
by bin;
run;

data FWL_Score_d10_1;
	set FWL_Score_d10;

	if rpgroup=10 and qpgroup=10 then Model_Priority=1;
	else if rpgroup=10 and qpgroup=9 then Model_Priority=2;
	else if rpgroup=10 and qpgroup=8 then Model_Priority=3;
	else if rpgroup=9 and qpgroup=10 then Model_Priority=4;
	else if rpgroup=9 and qpgroup=9 then Model_Priority=5;
	else if rpgroup=9 and qpgroup=8 then Model_Priority=6;
	mail_drop=99;
run;

proc freq data=FWL_Score_d10_1;
table Model_Priority*rpgroup*qpgroup/missing list;
run;

proc freq data=FWL_Score_d10_1(where=(Model_Priority>0));
table Model_Priority*rpgroup*qpgroup/missing list;
run;

proc tabulate data=FWL_Score_d10_1 noseps missing;
class mail_drop list1;
table mail_drop, list1/box="appointed-licensed" indent=3;
run;

/*proc freq data=test;*/
/*table merge_Flag/missing;*/
/*run;*/

proc tabulate data=FWL_Score_d10_1 noseps missing;
class dpgroup mail_drop ;
table dpgroup, mail_drop/box="appointed-licensed" indent=3;
run;

data _null_;
	file 
"/mnt/projects/locked/forwardline/scoring_201604/Deliver/FWL_Score_d10_output_20160427.txt" 
dlm="|" ;
	set FWL_Score_d10_1;
	if _N_=1 then 
	put 
"BIN"	"|"
"qpgroup"	"|"
"rpgroup"	"|"
"dpgroup"	"|"
"decline_prob"	"|"
"response_prob"	"|"
"qual_prob"	"|"
"Model_Priority"	"|"
"TSG_Sequence_Number"	"|"
"Jacket"	"|"
"LIST"	"|"
"mail_drop"

;
put 
BIN
qpgroup
rpgroup
dpgroup
decline_prob
response_prob
qual_prob
Model_Priority
TSG_Sequence_Number
Jacket
LIST1
mail_drop
;
run;

****************************Additional list**********************************;

data FWL_Score_Cut;
	set &out.;
	 where dpgroup^=10;  /* drop all the records in dpgroup 10*/
	run;
/*3013109*/

proc sort data=tar.Mail_suppr out=Mail_suppr nodupkey;
by bin;
run;
/*259618*/
proc sort data=FWL_Score_Cut nodupkey;
by bin;
run;

data post_merge_suppressed;
	merge FWL_Score_Cut(in=a) Mail_suppr(in=b keep=bin);
	by bin;
	if a and not b;
/*	merge_Flag=compress(a||b);*/
run;
/*2899545 , 113564 has been supppressed*/

/*proc freq data=post_merge_suppressed;*/
/*table merge_Flag/missing;*/
/*run;*/

data post_merge_suppressed_1;
	set post_merge_suppressed;

	if rpgroup=10 and qpgroup=10 then Model_Priority=1;
	else if rpgroup=10 and qpgroup=9 then Model_Priority=2;
	else if rpgroup=10 and qpgroup=8 then Model_Priority=3;
	else if rpgroup=9 and qpgroup=10 then Model_Priority=4;
	else if rpgroup=9 and qpgroup=9 then Model_Priority=5;
	else if rpgroup=9 and qpgroup=8 then Model_Priority=6;
run;

/*Pre_merge file*/
data Pre_merge;
length full_id $15.;
	set tar.&file1_name.
		tar.&file2_name.
;
rename bin=pre_bin;
full_id=compress(Jacket||LIST1||TSG_Sequence_Number);
keep Jacket
LIST1
TSG_Sequence_Number
bin
full_id
HOME_BASED_BUSINESS_ID
 
state
  ;
run;








GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;


/*   START OF NODE: P25_Sample   */
%LET _CLIENTTASKLABEL='P25_Sample';
%LET _CLIENTPROJECTPATH=
'P:\offshore_office\frankji\forwardline\ForwardLine_Score_20160510_v1.egp';
%LET _CLIENTPROJECTNAME='ForwardLine_Score_20160510_v1.egp';
%LET _SASPROGRAMFILE=;

GOPTIONS ACCESSIBLE;

proc surveyselect data=&final_out.  out=FWL_Score_Cut_p25_Sample samprate=0.25 
seed=52231 method=srs;
run;
/*815,084*/

proc export data=FWL_Score_Cut_p25_Sample file=
"/mnt/projects/public/offshore_office/qtang/ForwardLine/docs/FWL_score_Sample_20160419.csv" 
dbms=csv replace ;
run;

/*Response model recoding variable check*/
Title "Response model recoding variable check";
proc means data=FWL_Score_Cut_p25_Sample n nmiss mean min p25 p50 p75 max;
var ttc039_2_z
m_TTC060_2
M_LOGTTO077_1
clp017_1_z
lgc004_1_z
miss_otp017_1
m_otp017_1
ttp084_1_z
m_ttp084_1
cottage
m_ttc063_1
saleslg
esizelg
rtd071_2_z
clo014_C1
MCOUNT
sic_trans
;
run;


/*Qual model recoding variable check*/
Title "Qual model recoding variable check";
proc means data=FWL_Score_Cut_p25_Sample n nmiss mean min p25 p50 p75 max;
var lnp
o_LGC004_1
o_TTC057_2
l_CLO014_1
l_TTB009_1
l_TTB014_1
l_CTB012_1
o_CTB007_1
l_TTP084_2
l_RTC037_1
l_TTO077_1
l_RTD072_1
l_RTC049_2
l_CLP016_1
l_TTP079_1

;
run;

/*Decline model recoding variable check*/
Title "Decline model recoding variable check";
proc means data=FWL_Score_Cut_p25_Sample n nmiss mean min p25 p50 p75 max;
var l_LGC004_1
l_TTB009_2
l_TXB002_2
l_CLC010_1
o_TTB008_2
l_TTC068_1
o_PRO001_2
l_TTB013_1
o_TTB007_2
l_TTB020_1
o_TTB033_2
l_TXC012_2
;
run;


/*Response model original variable check*/
Title "Response model original variable check";
proc means data=FWL_Score_Cut_p25_Sample n nmiss mean min p25 p50 p75 max;
var 
ttc039_2
TTC060_2
TTO077_1
clp017_1
lgc004_1
otp017_1
otp017_1
ttp084_1
ttp084_1
/*HOME_BASED_BUSINESS_ID*/
ttc063_1
/*ANNUAL_SALES_SIZE_CODE*/
/*DMO004_1*/
rtd071_2
CLO014_1
CLO014_2
Orig_Mcount
DMO013_1
;
run;

proc freq data=FWL_Score_Cut_p25_Sample;
table HOME_BASED_BUSINESS_ID ANNUAL_SALES_SIZE_CODE DMO004_1 /missing;
run;

/*Qualified Responder model original variable check*/
Title "Qualified Responder model original variable check";
proc means data=FWL_Score_Cut_p25_Sample n nmiss mean min p25 p50 p75 max;
var 
dmo013_1
LGC004_1
TTC057_2
CLO014_1
TTB009_1
TTB014_1
CTB012_1
CTB007_1
TTP084_2
RTC037_1
TTO077_1
RTD072_1
RTC049_2
CLP016_1
TTP079_1
;
run;

/*Decline model original variable check*/
Title "Decline model original variable check";
proc means data=FWL_Score_Cut_p25_Sample n nmiss mean min p25 p50 p75 max;
var 
LGC004_1
TTB009_2
TXB002_2
CLC010_1
TTB008_2
TTC068_1
PRO001_2
TTB013_1
TTB007_2
TTB020_1
TTB033_2
TXC012_2
;
run;



Title "response model distribution";

proc tabulate data=FWL_Score_Cut_p25_Sample noseps missing;
class rpgroup list1;
table rpgroup, list1/box="appointed-licensed" indent=3;
run;

Title "qual model distribution";
proc tabulate data=FWL_Score_Cut_p25_Sample noseps missing;
class qpgroup list1;
table qpgroup, list1/box="appointed-licensed" indent=3;
run;

Title "Decline model distribution";
proc tabulate data=FWL_Score_Cut_p25_Sample noseps missing;
class dpgroup list1;
table dpgroup, list1/box="appointed-licensed" indent=3;
run;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;

;*';*";*/;quit;run;
ODS _ALL_ CLOSE;
