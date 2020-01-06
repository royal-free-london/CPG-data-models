
drop table ##sw_op_ipdc_link2
drop table ##sw_op_appts112
drop table ##sw_admitted112

DECLARE @StartDate AS DATETIME ='01/04/2018'
DECLARE @EndDate AS DATETIME = '30/11/2019'


Select
* into ##sw_op_ipdc_link2
from (
select
ROW_NUMBER() OVER(PARTITION BY Local_Patient_ID,referral_id  ORDER by referral_id DESC) AS N,
  Outcome_of_Attendance_desc, Outcome_of_Attendance, Local_Patient_ID,Attendance_Date,Referral_ID,Specialty_Desc  from rf_performance.dbo.rf_performance_opa_main opa
where 
Attended_or_Did_Not_Attend in ('5','6','05','06')
and Administrative_Category in ('1','01')
and attendance_date between @StartDate and @EndDate
--and opa.Outcome_of_Attendance in ('1','01')
)as op_ref
where n =1

--Select
--* from ##sw_op_ipdc_link2

-------------------- 

DECLARE @StartDate AS DATETIME ='01/04/2018'
DECLARE @EndDate AS DATETIME = '30/11/2019'

select opl.Local_Patient_ID,opl.Attendance_Date as [DischargedFromOPAClinicDate],opl.Referral_ID, Attended_or_Did_Not_Attend ,
opl.specialty_Desc as Specialty_OP_Discharge,'-' as BlankColumn,opa.referral_request_received_date,opa.Attendance_Date,
opa.Specialty_Desc as Specialty_OP_Attendance, opa.Outcome_of_Attendance_desc

into ##sw_op_appts112
 from  (select * from rf_performance.dbo.rf_performance_opa_main
  where
((Appointment_Resource NOT LIKE '%POA%') And
      (Appointment_Resource NOT LIKE '%Pre Admission%') And
      (Appointment_Resource NOT LIKE '%PAC%') And
      (Appointment_Resource NOT LIKE '%Pre-op%') And
      (Appointment_Resource NOT like '%Pre-Assess%')And 
      (Appointment_Slot_Type NOT like '%Pre-Assess%') And
      (Appointment_Type NOT LIKE '%POA%') and
      (Appointment_Type NOT LIKE '%PAC%'))
	 and
	 Attended_or_Did_Not_Attend in ('5','6','05','06')
and Administrative_Category in ('1','01')
--and Outcome_of_Attendance in ('1','01')
	  
	  )
   opa

left join (select * from ##sw_op_ipdc_link2) as opl
on opl.Referral_ID = opa.Referral_ID
and opl.Local_Patient_ID = opa.Local_Patient_ID
and opl.referral_id is not null

 where 
opl.referral_id is not null
and Attended_or_Did_Not_Attend in ('5','6','05','06') and
opa.Attended_or_Did_Not_Attend in ('5','6','05','06') and
opl.attendance_date between @StartDate and @EndDate and
opa.attendance_date between @StartDate and @EndDate
--and opa.Outcome_of_Attendance in ('1','01')
--and opl.Outcome_of_Attendance in ('1','01')

order by 3,2,1,5,6 ASC


select * from ##sw_op_appts112
order by 3,2,1,5,6 ASC



------------- admitted temp table


select
Consultant_At_Episode, Consultant_Code,
left(Consultant_Code,2)+right(left(Consultant_Code,8),3)+right(left(Consultant_Code,4),3) as Anon,
financialyear,
MonthYear,
DATEADD(month, DATEDIFF(month, 0, [Discharge Date]), 0) AS SortDate,
[Month],
MRN as LOCAL_PATIENT_ID,
Site,
Decided_to_Admit_Date,
[Spell No],
[Admission Date],
[Discharge Date],
CPG_PrimaryDiagnosis,
ProcedureCategory,
[Primary Diagnosis],
[Primary Procedure],
Spells,
case when [Primary Procedure] like '%J18%' then 'Cholecystectomy Subset' else 'Others' 
end as CholecystectomyPathway,
case
WHEN [Procedure Codes] LIKE '%J021%' AND [Procedure Codes] LIKE '%J024%' THEN 'Liver'
WHEN [Procedure Codes] LIKE '%J022%' AND [Procedure Codes] LIKE '%J024%' THEN 'Liver'
WHEN [Procedure Codes] LIKE '%J021%'  THEN 'Liver'
WHEN [Procedure Codes] LIKE '%J022%' THEN 'Liver'
WHEN [Procedure Codes] LIKE '%J026%' AND [Procedure Codes] LIKE '%J024%' THEN 'Liver'
WHEN [Procedure Codes] LIKE '%J027%' AND [Procedure Codes] LIKE '%J024%' THEN 'Liver'
WHEN [Procedure Codes] LIKE '%J024%'  THEN 'Liver'
WHEN [Procedure Codes] LIKE '%J023%'  THEN 'Liver'

WHEN [Procedure Codes] LIKE '%J031%'  THEN 'Liver'

WHEN [Procedure Codes] LIKE '%J032%'  THEN 'Liver'

WHEN [Procedure Codes] LIKE '%J033%'  THEN 'Liver'

WHEN [Procedure Codes] LIKE '%J034%'  THEN 'Liver'

WHEN [Procedure Codes] LIKE '%J035%'  THEN 'Liver'

WHEN [Procedure Codes] LIKE '%J038%'  THEN 'Liver'

WHEN [Procedure Codes] LIKE '%J039%' AND [Procedure Codes] LIKE '%J071%' AND [Procedure Codes] LIKE '%Y70[3]%' THEN 'Liver'

WHEN [Procedure Codes] LIKE '%J021%'  THEN 'Liver'

WHEN [Procedure Codes] LIKE '%J022%'  THEN 'Liver'

WHEN [Procedure Codes] LIKE '%J023%'  THEN 'Liver'

WHEN [Procedure Codes] LIKE '%J024%'  THEN 'Liver'

WHEN [Procedure Codes] LIKE '%J025%'  THEN 'Liver'

WHEN [Procedure Codes] LIKE '%J026%'  THEN 'Liver'

WHEN [Procedure Codes] LIKE '%J027%'  THEN 'Liver'

WHEN [Procedure Codes] LIKE '%J028%'  THEN 'Liver'

WHEN [Procedure Codes] LIKE '%J029%'  THEN 'Liver'

WHEN [Procedure Codes] LIKE '%J551%' THEN 'Pancreas'
WHEN [Procedure Codes] LIKE '%J552%' THEN 'Pancreas'
WHEN [Procedure Codes] LIKE '%J558%' THEN 'Pancreas'
WHEN [Procedure Codes] LIKE '%J559%' THEN 'Pancreas'
WHEN [Procedure Codes] LIKE '%J561%' THEN 'Pancreas'
WHEN [Procedure Codes] LIKE '%J562%' THEN 'Pancreas'
WHEN [Procedure Codes] LIKE '%J563%' THEN 'Pancreas'
WHEN [Procedure Codes] LIKE '%J564%' THEN 'Pancreas'
WHEN [Procedure Codes] LIKE '%J568%' THEN 'Pancreas'
WHEN [Procedure Codes] LIKE '%J569%' THEN 'Pancreas'
WHEN [Procedure Codes] LIKE '%J571%' THEN 'Pancreas'
WHEN [Procedure Codes] LIKE '%J572%' THEN 'Pancreas'
WHEN [Procedure Codes] LIKE '%J573%' THEN 'Pancreas'
WHEN [Procedure Codes] LIKE '%J574%' THEN 'Pancreas'
WHEN [Procedure Codes] LIKE '%J575%' THEN 'Pancreas'
WHEN [Procedure Codes] LIKE '%J578%' THEN 'Pancreas'
WHEN [Procedure Codes] LIKE '%J579%' THEN 'Pancreas'
else 'Other' end as HPBTumoursPathway,
case when ElectiveWaitInDays = 0 then  ''  else ElectiveWaitInDays end as ElectiveWaitInDays
into ##sw_admitted112
from
[DIV_Perf].dbo.[CPG_Pathway_Analytics_Metrics_Report] cpg
where 
[Elective/Non-Elective] = 'Elective'


select * from ##sw_admitted112













---------QUERY BELOW FOR OUTPATIENT ATTENDANCES PRE INPATIENT SPELL


DROP TABLE div_perf.dbo.CPG_OPA_Attendences_Analysis




DECLARE @StartDate AS DATETIME ='01/04/2018'
DECLARE @EndDate AS DATETIME = '30/11/2019'


select j.*  
into div_perf.dbo.CPG_OPA_Attendences_Analysis
from 
( 
select
distinct
Consultant_At_Episode, Consultant_Code, Anon,
financialyear,
MonthYear,	
SortDate,
Month,	
LOCAL_PATIENT_ID,
Site,	
Decided_to_Admit_Date,
[Spell No],
[Admission Date],
[Discharge Date],
[CPG_PrimaryDiagnosis],
[ProcedureCategory],
[Primary Diagnosis],
[Primary Procedure],Spells,
CholecystectomyPathway,
HPBTumoursPathway,	
ElectiveWaitInDays,	
--a.Attendance_Date,
referral_id
,referral_request_received_date
,sum(pre) as Pre
from

(


select 
distinct
--N,
Consultant_At_Episode, Consultant_Code, Anon,
financialyear,
MonthYear,	
SortDate,
Month,	
LOCAL_PATIENT_ID,
Site,	
Decided_to_Admit_Date,
[Spell No],
[Admission Date],
[Discharge Date],
[CPG_PrimaryDiagnosis],
[ProcedureCategory],
[Primary Diagnosis],
[Primary Procedure],Spells,
CholecystectomyPathway,
HPBTumoursPathway,	
ElectiveWaitInDays,	
a.Attendance_Date,
referral_id,
(ATTENDANCES_PRE_ADMISSION) as Pre
,referral_request_received_date




from (
select distinct 
a.*,op.Attendance_Date, op.referral_id, referral_request_received_date
,(CASE WHEN op.Attendance_Date <= DATEADD(DD,1,[Admission Date]) THEN 1 ELSE 0 END) AS ATTENDANCES_PRE_ADMISSION
,CASE WHEN OP.attendance_date BETWEEN '01/04/2018' and '30/11/2018' then 1 else 0 end as [Pathway Baseline Period Flag]
,CASE WHEN OP.attendance_date BETWEEN '01/04/2018' and '30/11/2018' then 'Pathway Baseline Period'
	WHEN op.attendance_date BETWEEN '01/04/2019' and '30/11/2019'then 'Live Pathway Period' end as [Pathway Timeline]
 from ##sw_admitted112 a

left join (select *,1 as attendance from ##sw_op_appts112 where Attended_or_Did_Not_Attend in ('5','6','05','06') ) op
on a.local_patient_id = op.local_patient_id
 and op.Attendance_Date >= referral_request_received_date
and op.attendance_date <  [Admission Date]
			) as a

where 
			
a.attendance_date <  [Admission Date] 
and (referral_request_received_date BETWEEN '01/04/2018' and '31/10/2018' OR referral_request_received_date BETWEEN '01/04/2019' and '31/10/2019')
AND (a.attendance_date BETWEEN '01/04/2018' and '30/11/2018' OR a.attendance_date BETWEEN '01/04/2019' and '30/11/2019')
and (Decided_to_Admit_Date BETWEEN '01/04/2018' and '30/11/2018' OR Decided_to_Admit_Date BETWEEN '01/04/2019' and '30/11/2019')
and ([Admission Date] BETWEEN '01/04/2018' and '30/11/2018' OR [Admission Date] BETWEEN '01/04/2019' and '30/11/2019')

group by

--N,
Consultant_At_Episode, Consultant_Code, Anon,
financialyear,
MonthYear,	
SortDate,
Month,	
LOCAL_PATIENT_ID,
Site,	
Decided_to_Admit_Date,
[Spell No],
[Admission Date],
[Discharge Date],
[CPG_PrimaryDiagnosis],
[ProcedureCategory],
[Primary Diagnosis],
[Primary Procedure],Spells,
CholecystectomyPathway,
HPBTumoursPathway,	
ElectiveWaitInDays,	
a.Attendance_Date,
referral_id,
ATTENDANCES_PRE_ADMISSION,
referral_request_received_date



) as final

group by

Consultant_At_Episode, Consultant_Code, Anon,
financialyear,
MonthYear,	
SortDate,
Month,	
LOCAL_PATIENT_ID,
Site,	
Decided_to_Admit_Date,
[Spell No],
[Admission Date],
[Discharge Date],
[CPG_PrimaryDiagnosis],
[ProcedureCategory],
[Primary Diagnosis],
[Primary Procedure],Spells,
CholecystectomyPathway,
HPBTumoursPathway,	
ElectiveWaitInDays,	
referral_id
,referral_request_received_date

) as j



select * from div_perf.dbo.CPG_OPA_Attendences_Analysis
--where 
--Decided_to_Admit_Date between @StartDate and @EndDate


---------QUERY BELOW FOR OUTPATIENT ATTENDANCES POST INPATIENT SPELL


DROP TABLE div_perf.dbo.CPG_OPA_Attendences_Analysis_Post

DECLARE @StartDate AS DATETIME ='01/04/2018'
DECLARE @EndDate AS DATETIME = '30/11/2019'

select j.*  
into div_perf.dbo.CPG_OPA_Attendences_Analysis_Post
from 
( 
select
distinct
--N,
Consultant_At_Episode, Consultant_Code, Anon,
financialyear,
MonthYear,	
SortDate,
Month,	
LOCAL_PATIENT_ID,
Site,	
Decided_to_Admit_Date,
[Spell No],
[Admission Date],
[Discharge Date],
[CPG_PrimaryDiagnosis],
[ProcedureCategory],
[Primary Diagnosis],
[Primary Procedure],Spells,
CholecystectomyPathway,
HPBTumoursPathway,	
ElectiveWaitInDays,	
--a.Attendance_Date,
referral_id
,referral_request_received_date,
sum(post) as Post

from

(


select 
distinct
--N,
Consultant_At_Episode, Consultant_Code, Anon,
financialyear,
MonthYear,	
SortDate,
Month,	
LOCAL_PATIENT_ID,
Site,	
Decided_to_Admit_Date,
[Spell No],
[Admission Date],
[Discharge Date],
[CPG_PrimaryDiagnosis],
[ProcedureCategory],
[Primary Diagnosis],
[Primary Procedure],Spells,
CholecystectomyPathway,
HPBTumoursPathway,	
ElectiveWaitInDays,	
a.Attendance_Date,
referral_id,
referral_request_received_date,
(ATTENDANCES_POST_ADMISSION) as Post


from (
select distinct 
--ROW_NUMBER() OVER(PARTITION BY a.Local_Patient_ID,a.[spell no]  ORDER by a.[spell no] DESC) AS N,
a.*,op.Attendance_Date, op.referral_id, referral_request_received_date,
(CASE WHEN op.Attendance_Date >= [Discharge Date] THEN 1 ELSE 0 END) AS ATTENDANCES_POST_ADMISSION

 from ##sw_admitted112 a

left join (select *,1 as attendance from ##sw_op_appts112 where Attended_or_Did_Not_Attend in ('5','6','05','06') ) op
on a.local_patient_id = op.local_patient_id
and op.referral_request_received_date <= Decided_to_Admit_Date 
and op.Attendance_Date >= op.referral_request_received_date 
where  (referral_request_received_date BETWEEN '01/04/2018' and '31/10/2018' OR referral_request_received_date BETWEEN '01/04/2019' and '31/10/2019')
AND (op.attendance_date BETWEEN '01/04/2018' and '30/11/2018' OR op.attendance_date BETWEEN '01/04/2019' and '30/11/2019')
and (Decided_to_Admit_Date BETWEEN '01/04/2018' and '30/11/2018' OR Decided_to_Admit_Date BETWEEN '01/04/2019' and '30/11/2019')
and ([Admission Date] BETWEEN '01/04/2018' and '30/11/2018' OR [Admission Date] BETWEEN '01/04/2019' and '30/11/2019')


			) as a




group by

--N,
Consultant_At_Episode, Consultant_Code, Anon,
financialyear,
MonthYear,	
SortDate,
Month,	
LOCAL_PATIENT_ID,
Site,	
Decided_to_Admit_Date,
[Spell No],
[Admission Date],
[Discharge Date],
[CPG_PrimaryDiagnosis],
[ProcedureCategory],
[Primary Diagnosis],
[Primary Procedure],Spells,
CholecystectomyPathway,
HPBTumoursPathway,	
ElectiveWaitInDays,	
a.Attendance_Date,
referral_id,
referral_request_received_date,
ATTENDANCES_POST_ADMISSION

) as final

group by

Consultant_At_Episode, Consultant_Code, Anon,
financialyear,
MonthYear,	
SortDate,
Month,	
LOCAL_PATIENT_ID,
Site,	
Decided_to_Admit_Date,
[Spell No],
[Admission Date],
[Discharge Date],
[CPG_PrimaryDiagnosis],
[ProcedureCategory],
[Primary Diagnosis],
[Primary Procedure],Spells,
CholecystectomyPathway,
HPBTumoursPathway,	
ElectiveWaitInDays,	
referral_id,
referral_request_received_date

) as j




select * from div_perf.dbo.CPG_OPA_Attendences_Analysis_Post
Where Referral_ID is not null 







-----PRE POST JOINT 

drop table div_perf.dbo.CPG_OPA_Attendences_Analysis_Joint

DECLARE @StartDate AS DATETIME ='01/04/2018'
DECLARE @EndDate AS DATETIME = '30/11/2019'

select j.*  
into div_perf.dbo.CPG_OPA_Attendences_Analysis_Joint
from 
( 

select distinct a.* 
--,h.Pre
,CASE WHEN H.Pre IS NULL then 0
ELSE H.PRE END AS Pre
,CASE WHEN referral_request_received_date BETWEEN '01/04/2018' and '30/11/2018' then 1 else 0 end as [Pathway Baseline Period Flag]
,CASE WHEN referral_request_received_date BETWEEN '01/04/2018' and '30/11/2018' then 'Pathway Baseline Period'
	WHEN referral_request_received_date BETWEEN '01/04/2019' and '30/11/2019'then 'Live Pathway Period' end as [Pathway Timeline]

  from div_perf.dbo.CPG_OPA_Attendences_Analysis_Post a


left join(select DISTINCT Pre, referral_id from div_perf.dbo.CPG_OPA_Attendences_Analysis
where referral_id is not null 
and referral_id <> '') h
 on a.referral_id = h.referral_id
where 
--a.Decided_to_Admit_Date between @StartDate and @EndDate
and a.referral_id is not null 
and a.referral_id <> ''



 group by
Consultant_At_Episode, Consultant_Code, Anon,
financialyear,
MonthYear,	
SortDate,
Month,	
a.LOCAL_PATIENT_ID,
Site,	
Decided_to_Admit_Date,
[Spell No],
[Admission Date],
[Discharge Date],
[CPG_PrimaryDiagnosis],
[ProcedureCategory],
[Primary Diagnosis],
[Primary Procedure],Spells,
CholecystectomyPathway,
HPBTumoursPathway,	
ElectiveWaitInDays,	
a.referral_id, h.Pre, Post
, CPG_PrimaryDiagnosis
,referral_request_received_date 


) j

order by j.referral_id





select j.*, [Discharged to GP Flag] from div_perf.dbo.CPG_OPA_Attendences_Analysis_Joint j
left join (select Referral_ID, [Discharged to GP Flag]
 from ##sw_op_appts_discharged) a on a.Referral_ID = j.Referral_ID










 ----------------------Testing


select DISTINCT
[Site],
[Pathway Timeline],
Avg(Pre) as PreSurgery_Appts,
Avg(Post) as PostSurgery_Appts
,sum(post) as sumPostSurgery_Appts
,sum(pre) as sumPreSurgery_Appts

from  div_perf.dbo.CPG_OPA_Attendences_Analysis_Joint 
WHERE [CPG_PrimaryDiagnosis] = 'ElectiveKnee'

group by
[Site],
[Pathway Timeline]

union all


select DISTINCT
'All' as [Site],
[Pathway Timeline],
Avg(Pre) as PreSurgery_Appts,
Avg(Post) as PostSurgery_Appts
,sum(post) as sumPostSurgery_Appts
,sum(pre) as sumPreSurgery_Appts

from  div_perf.dbo.CPG_OPA_Attendences_Analysis_Joint 
WHERE [CPG_PrimaryDiagnosis] = 'ElectiveKnee'

group by
[Pathway Timeline] 
