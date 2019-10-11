declare @start datetime = '20190401 00:00:00'
declare @end datetime   = '20190831 23:59:59'

DROP TABLE DIV_Perf.dbo.CPG_SDEC_Performance


SELECT  *
INTO 
DIV_Perf.dbo.CPG_SDEC_Performance

 from (

SELECT 
ROW_NUMBER()over(partition by LocalPatientIdentifierExtended order by EmergencyCareArrivalDateTime desc) as AE_N,


DT.FinancialYear																			AS 'Financial Year'
,DT.MonthName																				AS 'Month'
,LocalPatientIdentifierExtended																AS 'MRN'
,[EmergencyCareArrivalDateTime]																AS 'Arrival DateTime'								
,CASE 
WHEN [OrganisationSiteIdentifierOfTreatment] = 'RAL01' THEN 'Royal Free'
WHEN [OrganisationSiteIdentifierOfTreatment] = 'RAL26' THEN 'Barnet'
WHEN [OrganisationSiteIdentifierOfTreatment] = 'RALC7' THEN 'Chase Farm'
ELSE 'Unknown'  END																			AS 'Hospital'
,AM.[PreferredTerm]																			AS 'Arrival Mode'


,DATEDIFF([MI],[EmergencyCareArrivalDateTime],[EmergencyCareDepartureDateTime])				AS 'MinutesInAE'
,CASE
WHEN DATEDIFF([MI],[EmergencyCareArrivalDateTime],[EmergencyCareDepartureDateTime]) >= '240' THEN '1'
ELSE '0'  END																				AS 'Breach Flag'
,[EmergencyCareAttendanceCategory]   AS 'Attendance Category'

,Diag.[PreferredTerm] AS 'Diagnosis'
,[EmergencyCareDiagnosisSnomedCt01],
sno.ECDS_Description,sno.SNOMED,
left(ICD10,4) as ICD10,
left(ICD10,4)+' '+ECDS_Description AS SNOMED_Diagnosis
,PersonBirthDate
,datediff(dd,PersonBirthDate,[EmergencyCareArrivalDate])/365.25 as Age
,case when datediff(dd,PersonBirthDate,[EmergencyCareArrivalDate])/365.25 < 65 then '0-64' else '65+' end as [65+ Flag]
,case when datediff(dd,PersonBirthDate,[EmergencyCareArrivalDate])/365.25 < 75 then '0-74' else '75+' end as [75+ Flag],
case when datediff(dd,PersonBirthDate,[EmergencyCareArrivalDate])/365.25 < 80 then '0-79' else '80+' end as [80+ Flag]

,1 as Arrival
,FrailtyDiagnosisScore
, case when SNO.SNOMED IS NOT NULL then 1 else 0
end as [SDEC Diagnosis AE]


,op.Attendance_Date
,CASE 
WHEN 
op.Attendance_Date between [EmergencyCareArrivalDateTime] and [EmergencyCareArrivalDateTime]+7 THEN 1 Else 0 
end as [OP Follow Up Within 7 Days]
, OP.Specialty_Desc as [OP Specialty]
,Appointment_Slot_Type
,[Diagniosis 1]AS [OP Diagnosis]
,[SDEC Code Flag] as [IP SDEC Code Flag]
,[Start_Date_(Hospital_Provider_Spell)] 
,LoS, [LoS_Base_Hours]
, [Sub 23hr Stay Flag]
,SameDayN, SameDayD, 23hrStayN, 23hrStayD
,[Age Detailed],
 Age_Band_Grouped, 
 Gender, AgeOnAdmission, 
[Age 65 Flag],
[Age 75 Flag],
[Age 80 Flag],
 CharlesonCC_Ind,
 [Avg Charlson],
 n.Specialty_Desc as [IP Specialty],
 ward_at_discharge, [Description], Code_Description,
 primary_procedure, ICD10_Lv1_Description, ICD10_Lv2_Description,
 Readmission7d, Readmission30d




FROM rf_performance.dbo.RF_Performance_ECDS ECDS

LEFT JOIN [Ardentia_Healthware_64_Reference].[dbo].[RF_Dates] DT
ON cast(ECDS.EmergencyCareArrivalDateTime as date) = cast(DT.Date as date)

LEFT JOIN [ECDS].[sno].[Emergency_Care_Discharge_Status] DISST
ON ECDS.[EmergencyCareDischargeStatusSnomedCt] = DISST.[ReferenceComponentID]

LEFT JOIN [ECDS].[sno].[Emergency_Care_Discharge_Follow_Up] DISFU
ON ECDS.[EmergencyCareDischargeFollowUp_SnomedCt] = DISFU.[ReferenceComponentID]

LEFT JOIN [ECDS].[sno].[Emergency_Care_Discharge_Destination] DISDE
ON ECDS.[EmergencyCareDischargeFollowUp_SnomedCt] = DISDE.[ReferenceComponentID]

LEFT JOIN [ECDS].[sno].[Emergency_Care_Arrival_Mode] AM
ON ECDS.EmergencyCareArrivalModeSnomedCt = AM.ReferenceComponentID

LEFT JOIN [ECDS].[sno].[Emergency_Care_Diagnosis] DIAG
ON ECDS.[EmergencyCareDiagnosisSnomedCt01] = DIAG.ReferenceComponentID

LEFT JOIN [DIV_PERF].[dbo].[SDEC_SNOMED_Codes] SNO
ON ECDS.[EmergencyCareDiagnosisSnomedCt01] = SNO.SNOMED 

left join
 (
SELECT 
local_patient_id, Attendance_Date,
p.FinancialYear
,Month
,MONTH + '-' + SUBSTRING(p.CalendarYear,3,2) AS MonYY
,CAST(MonthBeginning AS DATE) AS Monyyy
,DATEADD(DD, -(DATEPART(DW,[Attendance_Date])-1),[Attendance_Date]) AS 'Week_Beginning'
,Appointment_Slot_Type
,appointment_type
,First_Attendance_Desc
,Outcome_of_Attendance_Desc
,[Organisation_Code_(Code_of_Commissioner)_Desc]
,[Site_Code_(of_Treatment)_Desc]
,Specialty_Desc
,Attended_or_Did_Not_Attend_Desc
, CASE 
	WHEN Appointment_Slot_Type LIKE '%AEC%' THEN 'AEC' 
	WHEN Appointment_Slot_Type LIKE '%DVT%' THEN 'DVT'
	ELSE 'Other'   END AS 'Clinic Group' 
,Diag1.Description AS 'Diagniosis 1'	
 ,Diag2.Description AS 'Diagniosis 2'
,COUNT(*)  AS 'Count'


FROM [RF_Performance].[dbo].[RF_Performance_OPA_Main] p


left join Ardentia_Healthware_64_Reference.dbo.ICD10_V4_L4 Diag1 
on	p.[Primary_Diagnosis_(ICD)]			=	Diag1.Code


left join Ardentia_Healthware_64_Reference.dbo.ICD10_V4_L4 Diag2 
on	p.[Primary_Diagnosis_(ICD)]			=	Diag2.Code

WHERE 

  (
  Appointment_Slot_Type LIKE ('%AEC%') OR
  Appointment_Slot_Type LIKE ('%DVT%') OR
  Appointment_Slot_Type LIKE ('%ae cellu%') OR
  Appointment_Slot_Type LIKE ('%ral01 ae%') OR
  Appointment_Slot_Type LIKE ('%RAL01 AE Ureteric Colic New 30%') OR
  Appointment_Slot_Type LIKE ('%ambulatory pe%') OR
  Appointment_Slot_Type LIKE ('%RVL01 COE TIA NEW 30%') OR
  Appointment_Slot_Type LIKE ('%RVL01 Neurology RACP New 10%')

  )
  AND Administrative_Category = '01'

GROUP BY
  p.FinancialYear, local_patient_id, Attendance_Date
,Month
,DATEADD(DD, -(DATEPART(DW,[Attendance_Date])-1),[Attendance_Date])
,substring(Month,1,3) 
,appointment_type
,Appointment_Slot_Type
,month + '-' + SUBSTRING(p.CalendarYear,3,2)
,CAST(MonthBeginning AS date)
,Appointment_Slot_Type
,First_Attendance_Desc
,Outcome_of_Attendance_Desc
,[Organisation_Code_(Code_of_Commissioner)_Desc]
,[Site_Code_(of_Treatment)_Desc]
,Specialty_Desc
,Attended_or_Did_Not_Attend_Desc
, CASE 
	WHEN Appointment_Slot_Type LIKE '%AEC%' THEN 'AEC' 
	WHEN Appointment_Slot_Type LIKE '%DVT%' THEN 'DVT'
	ELSE 'Other'   END
,Diag1.Description
,Diag2.Description

) as op 
on LocalPatientIdentifierExtended = op.local_patient_id
AND Attendance_Date between [EmergencyCareArrivalDateTime]and [EmergencyCareArrivalDateTime]+7

left join 
(SELECT local_patient_id ,
Gender, AgeOnAdmission, 
case when AgeOnAdmission < 65 then '0-64' else '65+' end as [Age 65 Flag],
case when AgeOnAdmission < 75 then '0-74' else '75+' end as [Age 75 Flag],
case when AgeOnAdmission < 80 then '0-79' else '80+' end as [Age 80 Flag],
Specialty_Desc,  CharlesonCC_Ind,
[Avg Charlson], LoS, LOS_BASE_HOURS, 
SameDayN, SameDayD, 23hrStayN, 23hrStayD, [Description], Code_Description, [SDEC Code Flag],
[Sub 23hr Stay Flag],
 [Same Day Flag],
 [Age Detailed],
  Age_Band_Grouped,
ward_at_discharge, 
primary_procedure, 
ICD10_Lv1_Description, 
ICD10_Lv2_Description,
  Readmission7d, Readmission30d, Readmission60d, [Start_Date_(Hospital_Provider_Spell)],
 [Discharge_Date_(Hospital_Provider_Spell)]
 FROM [DIV_Perf].dbo.SDEC) as N
ON LocalPatientIdentifierExtended = n.local_patient_id 
AND [Start_Date_(Hospital_Provider_Spell)] BETWEEN [EmergencyCareArrivalDateTime] AND [EmergencyCareArrivalDateTime]+1

left join
(
 select distinct *
from ##sw_frailty_last2years_score
) as j on LocalPatientIdentifierExtended = j.local_patient_id 


WHERE 
 datediff(dd,PersonBirthDate,[EmergencyCareArrivalDate])/365.25 >=18
 and [EmergencyCareArrivalDateTime] between @start and @end
 --and 
 --SNO.SNOMED IS NOT NULL

 ) as data

 where 
 [SDEC Diagnosis AE] =1
 OR 
 [OP Follow Up Within 7 Days] = 1
 OR 
 [IP SDEC Code Flag] = 1






 SELECT * FROM DIV_Perf.dbo.CPG_SDEC_Performance








 ---------------------- inpatient SDEC table -----

 --select *  from [DIV_Perf].dbo.SDEC
