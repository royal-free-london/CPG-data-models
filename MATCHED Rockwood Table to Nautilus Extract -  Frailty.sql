SELECT *,
case when pdet.Local_Patient_Identifier = f.[Local Patient ID] then 1 else 0 end as [Rockwood-Nautilus Match]
,case when f.[Local Patient ID]  is NOT NULL then 1 else 0 end as [RockwoodTBL Record]
,pdet.Local_Patient_Identifier AS [Local Patient Identifier] 
,Floor(DATEDIFF(DD,DATEADD(day, DATEDIFF(day, 0, pdet.Patient_birth_date), 0),timg.ARRIVAL_DATE_TIME)/365.25) as Age
,CASE WHEN DATEDIFF(DD,DATEADD(day, DATEDIFF(day, 0, pdet.Patient_birth_date), 0),timg.ARRIVAL_DATE_TIME)/365.25 Between 0 And 17.999999 Then '00-17'
WHEN DATEDIFF(DD,DATEADD(day, DATEDIFF(day, 0, pdet.Patient_birth_date), 0),timg.ARRIVAL_DATE_TIME)/365.25 Between 18 And 64.999999 Then '18-64'
WHEN DATEDIFF(DD,DATEADD(day, DATEDIFF(day, 0, pdet.Patient_birth_date), 0),timg.ARRIVAL_DATE_TIME)/365.25 Between 65 And 79.999999 Then '65-79'
WHEN DATEDIFF(DD,DATEADD(day, DATEDIFF(day, 0, pdet.Patient_birth_date), 0),timg.ARRIVAL_DATE_TIME)/365.25 >= 80 Then '80+'
ELSE '' END AS Age_Group
,CONVERT(Varchar, f.[A&E Arrival Date Time], 103) as [A&E Arrival Date]
,CONVERT(Varchar, f.[A&E Arrival Date Time], 8) as [A&E Arrival Time]
,CONVERT(Varchar, p.form_dt_tm, 103) as [Form Date]
,CONVERT(Varchar, p.form_dt_tm, 8) as [Form Time]
,DATEDIFF(Minute,CONVERT(Varchar, f.[A&E Arrival Date Time], 8), CONVERT(Varchar, p.form_dt_tm, 8)) as [Arrival to AssessmentForm]
,admn.Site_Code_of_Treatment_Name AS [Hospital Site]    
,CASE WHEN admn.Discharge_Method IN ('Admitted as inpatient','Admitted as IP - Same Trust','Admitted same Trust for CDU observation')  THEN 1 
      WHEN admn.Outcome IN ('Coronary Care Unit (level 2)', 'High Dependency Unit (level 2)','Intensive Care Unit (level 3)','Neonatal Intensive Care Unit (level 3)',
                           'Short stay ward managed by ED' , 'Ward - physical ward bed outside ED')  
                                            THEN 1 ELSE 0 END AS 'Admitted/Discharged'

FROM [RFLCFVM186-82].[TRANS_RFL835].[PF].[ALL_Data] p

LEFT JOIN
[RFLCFVM186-82].[TRANS_RFL835].[ED].[PATIENT_DETAIL] pdet
ON p.PERSON_ID = pdet.PERSON_ID

LEFT JOIN
[RFLCFVM186-82].[TRANS_RFL835].[ED].[ADMIN] admn
ON P.ENCNTR_ID = admn.ENCNTR_ID

LEFT JOIN
[RFLCFVM186-82].[TRANS_RFL835].[ED].[TIMING] timg
ON p.ENCNTR_ID = timg.ENCNTR_ID

FULL OUTER JOIN
(
select * from (
select
ROW_NUMBER()over(partition by [A&E Attendance Number] order by [Request Date Time] desc) as orderby
,[Local Patient ID]
,[A&E Attendance Number]
,[A&E Arrival Date Time]
,[Request Date Time]
,[Onset Date Time]
,[Event Display]
from
[DIV_Perf].[dbo].[Rockwood_Data]
) x
where
orderby = 1
) as f
on pdet.Local_Patient_Identifier  = f.[Local Patient ID]
and CONVERT(Varchar, p.form_dt_tm, 103)  = CONVERT(Varchar, f.[A&E Arrival Date Time], 103)


where
--PF_QUESTION like '%Frailty%'
--and p.form_dt_tm between '01/11/2019' and getdate()-2

 p.form_dt_tm <= '01/04/2019'


