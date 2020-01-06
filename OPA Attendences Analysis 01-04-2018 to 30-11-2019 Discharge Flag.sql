
drop table ##sw_op_ipdc_link23
drop table ##sw_op_appts_discharged


DECLARE @StartDate AS DATETIME ='01/04/2018'
DECLARE @EndDate AS DATETIME = '30/11/2019'


Select
* into ##sw_op_ipdc_link23
from (
select
ROW_NUMBER() OVER(PARTITION BY Local_Patient_ID,referral_id  ORDER by referral_id DESC) AS N,
  Outcome_of_Attendance_desc, Outcome_of_Attendance, Local_Patient_ID,Attendance_Date,Referral_ID,Specialty_Desc  from rf_performance.dbo.rf_performance_opa_main opa
where 
Attended_or_Did_Not_Attend in ('5','6','05','06')
and Administrative_Category in ('1','01')
and attendance_date between @StartDate and @EndDate
and opa.Outcome_of_Attendance in ('1','01')
AND (referral_request_received_date BETWEEN '01/04/2018' and '31/10/2018' OR referral_request_received_date BETWEEN '01/04/2019' and '31/10/2019')
)as op_ref
where n =1

--Select
--* from ##sw_op_ipdc_link23

-------------------- 

DECLARE @StartDate AS DATETIME ='01/04/2018'
DECLARE @EndDate AS DATETIME = '30/11/2019'

select opl.Local_Patient_ID,opl.Attendance_Date as [DischargedFromOPAClinicDate],opl.Referral_ID, Attended_or_Did_Not_Attend ,
opl.specialty_Desc as Specialty_OP_Discharge,'-' as BlankColumn,opa.referral_request_received_date,opa.Attendance_Date,
opa.Specialty_Desc as Specialty_OP_Attendance, opa.Outcome_of_Attendance_desc
, CASE WHEN opa.Outcome_of_Attendance = 1 THEN 1 ELSE 0 end as [Discharged to GP Flag]

into ##sw_op_appts_discharged
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
and Outcome_of_Attendance in ('1','01')
	  
	  )
   opa

left join (select * from ##sw_op_ipdc_link23) as opl
on opl.Referral_ID = opa.Referral_ID
and opl.Local_Patient_ID = opa.Local_Patient_ID
and opl.referral_id is not null

 where 
opl.referral_id is not null
and Attended_or_Did_Not_Attend in ('5','6','05','06') and
opa.Attended_or_Did_Not_Attend in ('5','6','05','06') and
opl.attendance_date between @StartDate and @EndDate and
opa.attendance_date between @StartDate and @EndDate
and opa.Outcome_of_Attendance in ('1','01')
and opl.Outcome_of_Attendance in ('1','01')
AND (referral_request_received_date BETWEEN '01/04/2018' and '31/10/2018' OR referral_request_received_date BETWEEN '01/04/2019' and '31/10/2019')
AND (opL.attendance_date BETWEEN '01/04/2018' and '30/11/2018' OR opL.attendance_date BETWEEN '01/04/2019' and '30/11/2019')
AND (opA.attendance_date BETWEEN '01/04/2018' and '30/11/2018' OR opA.attendance_date BETWEEN '01/04/2019' and '30/11/2019')






order by 3,2,1,5,6 ASC


select * from ##sw_op_appts_discharged
order by 3,2,1,5,6 ASC


select Referral_ID, [Discharged to GP Flag]
 from ##sw_op_appts_discharged

