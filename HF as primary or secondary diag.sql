



drop table ##SW_HeartFailure_PrimSecDiag
drop table ##SW_HeartFailure_PrimSecDiag2
drop table ##SW_HeartFailure_PrimSecDiag_Report

select
distinct
FinancialYear,
FinancialQuarter,
DATENAME(mm,[Discharge_Date_(Hospital_Provider_Spell)]) as [Month],
Hospital_provider_spell_number,
Local_Patient_ID
,NHS_Number
,AgeOnAdmission
,apc.specialty_desc
,[Admission_Method_(Hospital_Provider_Spell)]
,[Admission_Method_(Hospital_Provider_Spell)_Desc]
,Patient_Classification_Desc
,DATEDIFF(DD,[Start_Date_(Hospital_Provider_Spell)],[Discharge_Date_(Hospital_Provider_Spell)]) AS LOS,

CASE 
WHEN APC.patient_classification in ('2','02') then 0
else DATEDIFF(D,APC.[Start_Date_(Hospital_Provider_Spell)],APC.[Discharge_Date_(Hospital_Provider_Spell)]) END AS 'Length of stay numerator',
CASE 
WHEN APC.patient_classification in ('1','01') then 1
else 0 END AS 'Length of stay denominator',

case
when datediff(dd, [Start_DateTime_(Hospital_Provider_Spell)],[Discharge_DateTime_(Hospital_Provider_Spell)]) <1  then 1 else 0 end as 'Zero Night Stay Numerator',
case
when APC.patient_classification in ('1','01','2','02') then 1 else 0 end as 'Zero Night Stay Denominator',

case
when datediff(minute, [Start_DateTime_(Hospital_Provider_Spell)],[Discharge_DateTime_(Hospital_Provider_Spell)])/60 <24  then 1 else 0 end as '23hr Stay Numerator',
case
when APC.patient_classification in ('1','01','2','02') then 1 else 0 end as '23hr Stay Denominator',

CASE WHEN APC.[Elective/Non-Elective] = 'Elective' THEN 1 ELSE 0 END AS 'Day Case Rate Denominator',
CASE WHEN APC.[Elective/Non-Elective] = 'Elective' AND Patient_Classification in ('2','02') THEN 1 ELSE 0 END AS 'Day Case Rate Numerator',	
case
	when DATEDIFF(DD,[Start_Date_(Hospital_Provider_Spell)],[Discharge_Date_(Hospital_Provider_Spell)]) =0 then 'No overnight stay'
	when DATEDIFF(DD,[Start_Date_(Hospital_Provider_Spell)],[Discharge_Date_(Hospital_Provider_Spell)]) =1 then 'One night stay'
	when DATEDIFF(DD,[Start_Date_(Hospital_Provider_Spell)],[Discharge_Date_(Hospital_Provider_Spell)]) =2 then 'Two night stay'
	when DATEDIFF(DD,[Start_Date_(Hospital_Provider_Spell)],[Discharge_Date_(Hospital_Provider_Spell)]) =3 then 'Three night stay'
	when DATEDIFF(DD,[Start_Date_(Hospital_Provider_Spell)],[Discharge_Date_(Hospital_Provider_Spell)]) =4 then 'Four night stay'
	when DATEDIFF(DD,[Start_Date_(Hospital_Provider_Spell)],[Discharge_Date_(Hospital_Provider_Spell)]) =5 then 'Five night stay'
	when DATEDIFF(DD,[Start_Date_(Hospital_Provider_Spell)],[Discharge_Date_(Hospital_Provider_Spell)]) =6 then 'Six night stay'
	when DATEDIFF(DD,[Start_Date_(Hospital_Provider_Spell)],[Discharge_Date_(Hospital_Provider_Spell)]) =7 then 'Seven night stay'
	when DATEDIFF(DD,[Start_Date_(Hospital_Provider_Spell)],[Discharge_Date_(Hospital_Provider_Spell)]) >=21 then 'Over 21 night stay'
else '8 to 20 day stay inclusive' end as Nights_In_Hospital,	
[Start_Date_(Hospital_Provider_Spell)]
,[Discharge_Date_(Hospital_Provider_Spell)]
,[GP_Practice_(registered)]
,[General_Medical_Practitioner_(registered)]
,[Site_Code_(of_Treatment)_(at_start_of_episode)]
,
case when [Discharge_Method_(Hospital_Provider_Spell)] in ('4','4','5','05') then 'Died'
else 'Alive' end as DischargeStatus
,case 
when [Site_Code_(of_Treatment)_(at_End_of_episode)] = 'RAL01' then 'Royal Free Hospital'
when [Site_Code_(of_Treatment)_(at_End_of_episode)] IN ('RAL26', 'RVL01') then 'Barnet Hospital'
when [Site_Code_(of_Treatment)_(at_End_of_episode)] IN ('RALC7', 'RVLC7') then 'Chase Farm Hospital'
else 'Other' end as [Site_Code_(of_Treatment)_(at_End_of_episode)]
,case 
when [Primary_Diagnosis_(ICD)] in ('I500','I501','I509','I110','I420','I255','I429') then 'Primary'
else 'Secondary' end as 'Primary/Secondary Diagnosis',

left([Primary_Diagnosis_(ICD)],3)+':'+icd3.description as [Primary Diagnosis 3d],

left([Secondary_Diagnosis_(ICD)_1],3)+':'+icd3s.description as [Secondary Diagnosis 1st 3d],
--coalesce(ICD10_4.description,[Primary_Diagnosis_(ICD)]+':'+ICD10_4x.description) AS [Primary Diagnosis 4d],

left(APC.[Primary_Procedure_(OPCS)],3) as PrimaryProcedureCode,
ISNULL(OPCS4.[Description],'N/A') as 'Primary Procedure',
Coalesce ([ICD10_L3_s2].Description, ' ')+' / '+Coalesce ([ICD10_L3_s3].Description, ' ')+' / '+Coalesce ([ICD10_L3_s4].Description, ' ')+' / '+Coalesce ([ICD10_L3_s5].Description, ' ')
+' / ' +Coalesce ([ICD10_L3_s6].Description, ' / ')+Coalesce ([ICD10_L3_s7].Description, ' / ')+Coalesce ([ICD10_L3_s8].Description, ' / ')+Coalesce ([ICD10_L3_s9].Description, ' / ')+Coalesce ([ICD10_L3_s10].Description, ' / ') as [SecondaryDiagnosis1-9],

Coalesce ([OPCS4_L3_s1].Description, ' ')+' / '+Coalesce ([OPCS4_L3_s2].Description, ' ')+' / '+Coalesce ([OPCS4_L3_s3].Description, ' ')+' / '+Coalesce ([OPCS4_L3_s4].Description, ' ')
+' / ' +Coalesce ([OPCS4_L3_s5].Description, ' / ')+Coalesce ([OPCS4_L3_s6].Description, ' / ')+Coalesce ([OPCS4_L3_s7].Description, ' / ')+Coalesce ([OPCS4_L3_s8].Description, ' / ')+Coalesce ([OPCS4_L3_s9].Description, ' / ') as [SecondaryProcedures1-9]
,
[Primary_Diagnosis_(ICD)]
,[Secondary_Diagnosis_(ICD)_1]
,[Secondary_Diagnosis_(ICD)_2]
,[Secondary_Diagnosis_(ICD)_3]
,[Secondary_Diagnosis_(ICD)_4]
,[Secondary_Diagnosis_(ICD)_5]
,[Secondary_Diagnosis_(ICD)_6]
,[Secondary_Diagnosis_(ICD)_7]
,[Secondary_Diagnosis_(ICD)_8]
,[Secondary_Diagnosis_(ICD)_9]
,[Secondary_Diagnosis_(ICD)_10]
,[Secondary_Diagnosis_(ICD)_11]
,[Secondary_Diagnosis_(ICD)_12]
,[Secondary_Diagnosis_ICD_13_to_50],
[Primary_Procedure_(OPCS)],
	case
	WHEN CONS.Consultant_Code = 'N9999998' THEN 'Nurse'
WHEN CONS.Consultant_Code = 'M9999998' THEN 'Midwife'
WHEN CONS.Consultant_Code = 'H9999998' THEN CONS.[First Name] + ' ' + CONS.[Last Name]
WHEN CONS.[Last Name] = 'Consultant' AND CONS.[First Name] = 'Unknown' THEN 'Unknown Consultant'
WHEN CONS.[Last Name] IN ('NOT YET DEFINED','Unknown') THEN 'Unknown Consultant'
WHEN CONS.[Last Name] IS NULL THEN 'Unknown Consultant'
WHEN CONS.[Last Name] LIKE ' %' THEN REPLACE(CONS.[Last Name],' ','') + ', ' + CONS.[First Name]
ELSE CONS.[Last Name] + ', ' + CONS.[First Name]
END AS [Consultant_At_Discharge],
Case
when DATEDIFF(DD,[Start_Date_(Hospital_Provider_Spell)],[Discharge_Date_(Hospital_Provider_Spell)]) <> 0  then 'Exclude zero Night Stay' else '' end as Exclude_ZeroNightStay,
Case
when left([Admission_Method_(Hospital_Provider_Spell)],1)  in ('2')  then 'Exclude Non Emergency' else '' end as Exclude_NonEmergency
,	--start looking at 1st secondary code (deliberately excludes main diagnosis when viewing co-morbidities)
	case
	when LEFT([Secondary_Diagnosis_(ICD)_1],3) in ('I21', 'I22', 'I23') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_1],4) in ('I252', 'I258') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_1],4) in ('G450', 'G451', 'G452', 'G454', 'G458', 'G459') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_1],3) in ('G46') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_1],3) in ('I60','I61','I62','I63','I64','I65','I66','I67','I68','I69') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_1],3) ='I50' then 'Congestive heart failure'
	when LEFT([Secondary_Diagnosis_(ICD)_1],3) in ('M05', 'M32', 'M34') then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_1],4) in ('M060', 'M063', 'M069', 'M332','M353')then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_1],3) in  ('F00', 'F01', 'F02', 'F03') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_1],4) IN ('F051') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_1],4) in ('E101', 'E105', 'E106', 'E108', 'E109', 'E111', 'E115', 'E116', 'E118', 'E119', 'E131', 'E131', 'E136', 'E138', 'E139', 'E141','E145', 'E146', 'E148','E149') then 'Diabetes'
	when LEFT([Secondary_Diagnosis_(ICD)_1],4) in ('K702', 'K703', 'K717') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_1],3) in ('K73', 'K74') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_1],3) in  ('K25', 'K26', 'K27', 'K28') then 'Peptic ulcer'
	when LEFT([Secondary_Diagnosis_(ICD)_1],3) in ('I71', 'R02') then 'Peripheral vascular disease'
	when LEFT([Secondary_Diagnosis_(ICD)_1],4) in ('I739', 'I790', 'Z958', 'Z959') then 'Peripheral vascular disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_1],3) >= 'J40' and LEFT([Secondary_Diagnosis_(ICD)_1],3) <= 'J47') or
	(LEFT([Secondary_Diagnosis_(ICD)_1],3) >= 'J60' and LEFT([Secondary_Diagnosis_(ICD)_1],3) <= 'J67') then 'Pulmonary disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_1],3) >= 'C00' and LEFT([Secondary_Diagnosis_(ICD)_1],3) <= 'C76')or
	(LEFT([Secondary_Diagnosis_(ICD)_1],3) >= 'C80' and LEFT([Secondary_Diagnosis_(ICD)_1],3) <= 'C97') then 'Cancer'

	when LEFT([Secondary_Diagnosis_(ICD)_1],4) in ('E102', 'E103', 'E104', 'E107', 'E112', 'E113', 'E114', 'E117','E132', 'E133', 'E134', 'E137', 'E142', 'E143', 'E144', 'E147') then 'Diabetes complications'
	when LEFT([Secondary_Diagnosis_(ICD)_1],4) in ('G041', 'G820', 'G821', 'G822') or  LEFT([Secondary_Diagnosis_(ICD)_1],3) in ('G81') then 'Paraplegia'
	when LEFT([Secondary_Diagnosis_(ICD)_1],3) in ('I12', 'I13', 'N01', 'N03', 'N18','N19','N25') then 'Renal disease'

	when (LEFT([Secondary_Diagnosis_(ICD)_1],4) >= 'N052' and LEFT([Secondary_Diagnosis_(ICD)_1],3) <='N056') then 'Renal disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_1],4) >= 'N072' and LEFT([Secondary_Diagnosis_(ICD)_1],3) <='N074') then 'Renal disease'
	when LEFT([Secondary_Diagnosis_(ICD)_1],3) in ('C77', 'C78', 'C79') then 'Metastatic cancer'
	when LEFT([Secondary_Diagnosis_(ICD)_1],4) in  ('K721', 'K729', 'K766', 'K767') then 'Severe liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_1],3) in ('B20', 'B21', 'B22', 'B23', 'B24') then 'HIV'

	--start looking at 2nd secondary code
	when LEFT([Secondary_Diagnosis_(ICD)_2],3) in ('I21', 'I22', 'I23') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_2],4) in ('I252', 'I258') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_2],4) in ('G450', 'G451', 'G452', 'G454', 'G458', 'G459') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_2],3) in ('G46') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_2],3) in ('I60','I61','I62','I63','I64','I65','I66','I67','I68','I69') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_2],3) ='I50' then 'Congestive heart failure'
	when LEFT([Secondary_Diagnosis_(ICD)_2],3) in ('M05', 'M32', 'M34') then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_2],4) in ('M060', 'M063', 'M069', 'M332','M353')then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_2],3) in  ('F00', 'F01', 'F02', 'F03') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_2],4) IN ('F051') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_2],4) in ('E101', 'E105', 'E106', 'E108', 'E109', 'E111', 'E115', 'E116', 'E118', 'E119', 'E131', 'E131', 'E136', 'E138', 'E139', 'E141','E145', 'E146', 'E148','E149') then 'Diabetes'
	when LEFT([Secondary_Diagnosis_(ICD)_2],4) in ('K702', 'K703', 'K717') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_2],3) in ('K73', 'K74') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_2],3) in  ('K25', 'K26', 'K27', 'K28') then 'Peptic ulcer'
	when LEFT([Secondary_Diagnosis_(ICD)_2],3) in ('I71', 'R02') then 'Peripheral vascular disease'
	when LEFT([Secondary_Diagnosis_(ICD)_2],4) in ('I739', 'I790', 'Z958', 'Z959') then 'Peripheral vascular disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_2],3) >= 'J40' and LEFT([Secondary_Diagnosis_(ICD)_2],3) <= 'J47') or
	(LEFT([Secondary_Diagnosis_(ICD)_2],3) >= 'J60' and LEFT([Secondary_Diagnosis_(ICD)_2],3) <= 'J67') then 'Pulmonary disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_2],3) >= 'C00' and LEFT([Secondary_Diagnosis_(ICD)_2],3) <= 'C76')or
	(LEFT([Secondary_Diagnosis_(ICD)_2],3) >= 'C80' and LEFT([Secondary_Diagnosis_(ICD)_2],3) <= 'C97') then 'Cancer'

	when LEFT([Secondary_Diagnosis_(ICD)_2],4) in ('E102', 'E103', 'E104', 'E107', 'E112', 'E113', 'E114', 'E117','E132', 'E133', 'E134', 'E137', 'E142', 'E143', 'E144', 'E147') then 'Diabetes complications'
	when LEFT([Secondary_Diagnosis_(ICD)_2],4) in ('G041', 'G820', 'G821', 'G822') or  LEFT([Secondary_Diagnosis_(ICD)_2],3) in ('G81') then 'Paraplegia'
	when LEFT([Secondary_Diagnosis_(ICD)_2],3) in ('I12', 'I13', 'N01', 'N03', 'N18','N19','N25') then 'Renal disease'

	when (LEFT([Secondary_Diagnosis_(ICD)_2],4) >= 'N052' and LEFT([Secondary_Diagnosis_(ICD)_2],3) <='N056') then 'Renal disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_2],4) >= 'N072' and LEFT([Secondary_Diagnosis_(ICD)_2],3) <='N074') then 'Renal disease'
	when LEFT([Secondary_Diagnosis_(ICD)_2],3) in ('C77', 'C78', 'C79') then 'Metastatic cancer'
	when LEFT([Secondary_Diagnosis_(ICD)_2],4) in  ('K721', 'K729', 'K766', 'K767') then 'Severe liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_2],3) in ('B20', 'B21', 'B22', 'B23', 'B24') then 'HIV'

	--start looking at 3rd secondary code
	when LEFT([Secondary_Diagnosis_(ICD)_3],3) in ('I21', 'I22', 'I23') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_3],4) in ('I252', 'I258') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_3],4) in ('G450', 'G451', 'G452', 'G454', 'G458', 'G459') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_3],3) in ('G46') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_3],3) in ('I60','I61','I62','I63','I64','I65','I66','I67','I68','I69') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_3],3) in ('I50') then 'Congestive heart failure'
	when LEFT([Secondary_Diagnosis_(ICD)_3],3) in ('M05', 'M32', 'M34') then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_3],4) in ('M060', 'M063', 'M069', 'M332','M353')then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_3],3) in  ('F00', 'F01', 'F02', 'F03') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_3],4) IN ('F051') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_3],4) in ('E101', 'E105', 'E106', 'E108', 'E109', 'E111', 'E115', 'E116', 'E118', 'E119', 'E131', 'E131', 'E136', 'E138', 'E139', 'E141','E145', 'E146', 'E148','E149') then 'Diabetes'
	when LEFT([Secondary_Diagnosis_(ICD)_3],4) in ('K702', 'K703', 'K717') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_3],3) in ('K73', 'K74') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_3],3) in  ('K25', 'K26', 'K27', 'K28') then 'Peptic ulcer'
	when LEFT([Secondary_Diagnosis_(ICD)_3],3) in ('I71', 'R02') then 'Peripheral vascular disease'
	when LEFT([Secondary_Diagnosis_(ICD)_3],4) in ('I739', 'I790', 'Z958', 'Z959') then 'Peripheral vascular disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_3],3) >= 'J40' and LEFT([Secondary_Diagnosis_(ICD)_3],3) <= 'J47')or
	(LEFT([Secondary_Diagnosis_(ICD)_3],3) >= 'J60' and LEFT([Secondary_Diagnosis_(ICD)_3],3) <= 'J67') then 'Pulmonary disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_3],3) >= 'C00' and LEFT([Secondary_Diagnosis_(ICD)_3],3) <= 'C76')or
	(LEFT([Secondary_Diagnosis_(ICD)_3],3) >= 'C80' and LEFT([Secondary_Diagnosis_(ICD)_3],3) <= 'C97') then 'Cancer'

	when LEFT([Secondary_Diagnosis_(ICD)_3],4) in ('E102', 'E103', 'E104', 'E107', 'E112', 'E113', 'E114', 'E117','E132', 'E133', 'E134', 'E137', 'E142', 'E143', 'E144', 'E147') then 'Diabetes complications'
	when LEFT([Secondary_Diagnosis_(ICD)_3],4) in ('G041', 'G820', 'G821', 'G822') or  LEFT([Secondary_Diagnosis_(ICD)_3],3) in ('G81') then 'Paraplegia'
	when LEFT([Secondary_Diagnosis_(ICD)_3],3) in ('I12', 'I13', 'N01', 'N03', 'N18','N19','N25') then 'Renal disease'

	when (LEFT([Secondary_Diagnosis_(ICD)_3],4) >= 'N052' and LEFT([Secondary_Diagnosis_(ICD)_3],3) <='N056') then 'Renal disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_3],4) >= 'N072' and LEFT([Secondary_Diagnosis_(ICD)_3],3) <='N074') then 'Renal disease'
	when LEFT([Secondary_Diagnosis_(ICD)_3],3) in ('C77', 'C78', 'C79') then 'Metastatic cancer'
	when LEFT([Secondary_Diagnosis_(ICD)_3],4) in  ('K721', 'K729', 'K766', 'K767') then 'Severe liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_3],3) in ('B20', 'B21', 'B22', 'B23', 'B24') then 'HIV'

	--start looking at 4th secondary code
	when LEFT([Secondary_Diagnosis_(ICD)_4],3) in ('I21', 'I22', 'I23') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_4],4) in ('I252', 'I258') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_4],4) in ('G450', 'G451', 'G452', 'G454', 'G458', 'G459') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_4],3) in ('G46') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_4],3) in ('I60','I61','I62','I63','I64','I65','I66','I67','I68','I69') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_4],3) in ('I50') then 'Congestive heart failure'
	when LEFT([Secondary_Diagnosis_(ICD)_4],3) in ('M05', 'M32', 'M34') then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_4],4) in ('M060', 'M063', 'M069', 'M332','M353')then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_4],3) in  ('F00', 'F01', 'F02', 'F03') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_4],4) IN ('F051') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_4],4) in ('E101', 'E105', 'E106', 'E108', 'E109', 'E111', 'E115', 'E116', 'E118', 'E119', 'E131', 'E131', 'E136', 'E138', 'E139', 'E141','E145', 'E146', 'E148','E149') then 'Diabetes'
	when LEFT([Secondary_Diagnosis_(ICD)_4],4) in ('K702', 'K703', 'K717') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_4],3) in ('K73', 'K74') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_4],3) in  ('K25', 'K26', 'K27', 'K28') then 'Peptic ulcer'
	when LEFT([Secondary_Diagnosis_(ICD)_4],3) in ('I71', 'R02') then 'Peripheral vascular disease'
	when LEFT([Secondary_Diagnosis_(ICD)_4],4) in ('I739', 'I790', 'Z958', 'Z959') then 'Peripheral vascular disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_4],3) >= 'J40' and LEFT([Secondary_Diagnosis_(ICD)_4],3) <= 'J47')or
	(LEFT([Secondary_Diagnosis_(ICD)_4],3) >= 'J60' and LEFT([Secondary_Diagnosis_(ICD)_4],3) <= 'J67') then 'Pulmonary disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_4],3) >= 'C00' and LEFT([Secondary_Diagnosis_(ICD)_4],3) <= 'C76')or
	(LEFT([Secondary_Diagnosis_(ICD)_4],3) >= 'C80' and LEFT([Secondary_Diagnosis_(ICD)_4],3) <= 'C97') then 'Cancer'

	when LEFT([Secondary_Diagnosis_(ICD)_4],4) in ('E102', 'E103', 'E104', 'E107', 'E112', 'E113', 'E114', 'E117','E132', 'E133', 'E134', 'E137', 'E142', 'E143', 'E144', 'E147') then 'Diabetes complications'
	when LEFT([Secondary_Diagnosis_(ICD)_4],4) in ('G041', 'G820', 'G821', 'G822') or  LEFT([Secondary_Diagnosis_(ICD)_4],3) in ('G81') then 'Paraplegia'
	when LEFT([Secondary_Diagnosis_(ICD)_4],3) in ('I12', 'I13', 'N01', 'N03', 'N18','N19','N25') then 'Renal disease'

	when (LEFT([Secondary_Diagnosis_(ICD)_4],4) >= 'N052' and LEFT([Secondary_Diagnosis_(ICD)_4],3) <='N056') then 'Renal disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_4],4) >= 'N072' and LEFT([Secondary_Diagnosis_(ICD)_4],3) <='N074') then 'Renal disease'
	when LEFT([Secondary_Diagnosis_(ICD)_4],3) in ('C77', 'C78', 'C79') then 'Metastatic cancer'
	when LEFT([Secondary_Diagnosis_(ICD)_4],4) in  ('K721', 'K729', 'K766', 'K767') then 'Severe liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_4],3) in ('B20', 'B21', 'B22', 'B23', 'B24') then 'HIV'

	--start looking at 5h secondary code
	when LEFT([Secondary_Diagnosis_(ICD)_5],3) in ('I21', 'I22', 'I23') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_5],4) in ('I252', 'I258') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_5],4) in ('G450', 'G451', 'G452', 'G454', 'G458', 'G459') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_5],3) in ('G46') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_5],3) in ('I60','I61','I62','I63','I64','I65','I66','I67','I68','I69') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_5],3) in ('I50') then 'Congestive heart failure'
	when LEFT([Secondary_Diagnosis_(ICD)_5],3) in ('M05', 'M32', 'M34') then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_5],4) in ('M060', 'M063', 'M069', 'M332','M353')then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_5],3) in  ('F00', 'F01', 'F02', 'F03') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_5],4) IN ('F051') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_5],4) in ('E101', 'E105', 'E106', 'E108', 'E109', 'E111', 'E115', 'E116', 'E118', 'E119', 'E131', 'E131', 'E136', 'E138', 'E139', 'E141','E145', 'E146', 'E148','E149') then 'Diabetes'
	when LEFT([Secondary_Diagnosis_(ICD)_5],4) in ('K702', 'K703', 'K717') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_5],3) in ('K73', 'K74') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_5],3) in  ('K25', 'K26', 'K27', 'K28') then 'Peptic ulcer'
	when LEFT([Secondary_Diagnosis_(ICD)_5],3) in ('I71', 'R02') then 'Peripheral vascular disease'
	when LEFT([Secondary_Diagnosis_(ICD)_5],4) in ('I739', 'I790', 'Z958', 'Z959') then 'Peripheral vascular disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_5],3) >= 'J40' and LEFT([Secondary_Diagnosis_(ICD)_5],3) <= 'J47')or
	(LEFT([Secondary_Diagnosis_(ICD)_5],3) >= 'J60' and LEFT([Secondary_Diagnosis_(ICD)_5],3) <= 'J67') then 'Pulmonary disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_5],3) >= 'C00' and LEFT([Secondary_Diagnosis_(ICD)_5],3) <= 'C76')or
	(LEFT([Secondary_Diagnosis_(ICD)_5],3) >= 'C80' and LEFT([Secondary_Diagnosis_(ICD)_5],3) <= 'C97') then 'Cancer'

	when LEFT([Secondary_Diagnosis_(ICD)_5],4) in ('E102', 'E103', 'E104', 'E107', 'E112', 'E113', 'E114', 'E117','E132', 'E133', 'E134', 'E137', 'E142', 'E143', 'E144', 'E147') then 'Diabetes complications'
	when LEFT([Secondary_Diagnosis_(ICD)_5],4) in ('G041', 'G820', 'G821', 'G822') or  LEFT([Secondary_Diagnosis_(ICD)_5],3) in ('G81') then 'Paraplegia'
	when LEFT([Secondary_Diagnosis_(ICD)_5],3) in ('I12', 'I13', 'N01', 'N03', 'N18','N19','N25') then 'Renal disease'

	when (LEFT([Secondary_Diagnosis_(ICD)_5],4) >= 'N052' and LEFT([Secondary_Diagnosis_(ICD)_5],3) <='N056') then 'Renal disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_5],4) >= 'N072' and LEFT([Secondary_Diagnosis_(ICD)_5],3) <='N074') then 'Renal disease'
	when LEFT([Secondary_Diagnosis_(ICD)_5],3) in ('C77', 'C78', 'C79') then 'Metastatic cancer'
	when LEFT([Secondary_Diagnosis_(ICD)_5],4) in  ('K721', 'K729', 'K766', 'K767') then 'Severe liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_5],3) in ('B20', 'B21', 'B22', 'B23', 'B24') then 'HIV'

	--start looking at 6th secondary code
	when LEFT([Secondary_Diagnosis_(ICD)_6],3) in ('I21', 'I22', 'I23') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_6],4) in ('I252', 'I258') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_6],4) in ('G450', 'G451', 'G452', 'G454', 'G458', 'G459') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_6],3) in ('G46') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_6],3) in ('I60','I61','I62','I63','I64','I65','I66','I67','I68','I69') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_6],3) in ('I50') then 'Congestive heart failure'
	when LEFT([Secondary_Diagnosis_(ICD)_6],3) in ('M05', 'M32', 'M34') then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_6],4) in ('M060', 'M063', 'M069', 'M332','M353')then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_6],3) in  ('F00', 'F01', 'F02', 'F03') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_6],4) IN ('F051') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_6],4) in ('E101', 'E105', 'E106', 'E108', 'E109', 'E111', 'E115', 'E116', 'E118', 'E119', 'E131', 'E131', 'E136', 'E138', 'E139', 'E141','E145', 'E146', 'E148','E149') then 'Diabetes'
	when LEFT([Secondary_Diagnosis_(ICD)_6],4) in ('K702', 'K703', 'K717') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_6],3) in ('K73', 'K74') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_6],3) in  ('K25', 'K26', 'K27', 'K28') then 'Peptic ulcer'
	when LEFT([Secondary_Diagnosis_(ICD)_6],3) in ('I71', 'R02') then 'Peripheral vascular disease'
	when LEFT([Secondary_Diagnosis_(ICD)_6],4) in ('I739', 'I790', 'Z958', 'Z959') then 'Peripheral vascular disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_6],3) >= 'J40' and LEFT([Secondary_Diagnosis_(ICD)_6],3) <= 'J47')or
	(LEFT([Secondary_Diagnosis_(ICD)_6],3) >= 'J60' and LEFT([Secondary_Diagnosis_(ICD)_6],3) <= 'J67') then 'Pulmonary disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_6],3) >= 'C00' and LEFT([Secondary_Diagnosis_(ICD)_6],3) <= 'C76')or
	(LEFT([Secondary_Diagnosis_(ICD)_6],3) >= 'C80' and LEFT([Secondary_Diagnosis_(ICD)_6],3) <= 'C97') then 'Cancer'

	when LEFT([Secondary_Diagnosis_(ICD)_6],4) in ('E102', 'E103', 'E104', 'E107', 'E112', 'E113', 'E114', 'E117','E132', 'E133', 'E134', 'E137', 'E142', 'E143', 'E144', 'E147') then 'Diabetes complications'
	when LEFT([Secondary_Diagnosis_(ICD)_6],4) in ('G041', 'G820', 'G821', 'G822') or  LEFt([Secondary_Diagnosis_(ICD)_6],3) in ('G81') then 'Paraplegia'
	when LEFT([Secondary_Diagnosis_(ICD)_6],3) in ('I12', 'I13', 'N01', 'N03', 'N18','N19','N25') then 'Renal disease'

	when (LEFT([Secondary_Diagnosis_(ICD)_6],4) >= 'N052' and LEFT([Secondary_Diagnosis_(ICD)_6],3) <='N056') then 'Renal disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_6],4) >= 'N072' and LEFT([Secondary_Diagnosis_(ICD)_6],3) <='N074') then 'Renal disease'
	when LEFT([Secondary_Diagnosis_(ICD)_6],3) in ('C77', 'C78', 'C79') then 'Metastatic cancer'
	when LEFT([Secondary_Diagnosis_(ICD)_6],4) in  ('K721', 'K729', 'K766', 'K767') then 'Severe liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_6],3) in ('B20', 'B21', 'B22', 'B23', 'B24') then 'HIV'

		--start looking at 7th secondary code
	when LEFT([Secondary_Diagnosis_(ICD)_7],3) in ('I21', 'I22', 'I23') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_7],4) in ('I252', 'I258') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_7],4) in ('G450', 'G451', 'G452', 'G454', 'G458', 'G459') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_7],3) in ('G46') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_7],3) in ('I60','I61','I62','I63','I64','I65','I66','I67','I68','I69') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_7],3) in ('I50') then 'Congestive heart failure'
	when LEFT([Secondary_Diagnosis_(ICD)_7],3) in ('M05', 'M32', 'M34') then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_7],4) in ('M060', 'M063', 'M069', 'M332','M353')then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_7],3) in  ('F00', 'F01', 'F02', 'F03') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_7],4) IN ('F051') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_7],4) in ('E101', 'E105', 'E106', 'E108', 'E109', 'E111', 'E115', 'E116', 'E118', 'E119', 'E131', 'E131', 'E136', 'E138', 'E139', 'E141','E145', 'E146', 'E148','E149') then 'Diabetes'
	when LEFT([Secondary_Diagnosis_(ICD)_7],4) in ('K702', 'K703', 'K717') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_7],3) in ('K73', 'K74') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_7],3) in  ('K25', 'K26', 'K27', 'K28') then 'Peptic ulcer'
	when LEFT([Secondary_Diagnosis_(ICD)_7],3) in ('I71', 'R02') then 'Peripheral vascular disease'
	when LEFT([Secondary_Diagnosis_(ICD)_7],4) in ('I739', 'I790', 'Z958', 'Z959') then 'Peripheral vascular disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_7],3) >= 'J40' and LEFT([Secondary_Diagnosis_(ICD)_7],3) <= 'J47')or
	(LEFT([Secondary_Diagnosis_(ICD)_7],3) >= 'J60' and LEFT([Secondary_Diagnosis_(ICD)_7],3) <= 'J67') then 'Pulmonary disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_7],3) >= 'C00' and LEFT([Secondary_Diagnosis_(ICD)_7],3) <= 'C76')or
	(LEFT([Secondary_Diagnosis_(ICD)_7],3) >= 'C80' and LEFT([Secondary_Diagnosis_(ICD)_7],3) <= 'C97') then 'Cancer'

	when LEFT([Secondary_Diagnosis_(ICD)_7],4) in ('E102', 'E103', 'E104', 'E107', 'E112', 'E113', 'E114', 'E117','E132', 'E133', 'E134', 'E137', 'E142', 'E143', 'E144', 'E147') then 'Diabetes complications'
	when LEFT([Secondary_Diagnosis_(ICD)_7],4) in ('G041', 'G820', 'G821', 'G822') or LEFT([Secondary_Diagnosis_(ICD)_7],3) in ('G81') then 'Paraplegia'
	when LEFT([Secondary_Diagnosis_(ICD)_7],3) in ('I12', 'I13', 'N01', 'N03', 'N18','N19','N25') then 'Renal disease'

	when (LEFT([Secondary_Diagnosis_(ICD)_7],4) >= 'N052' and LEFT([Secondary_Diagnosis_(ICD)_7],3) <='N056') then 'Renal disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_7],4) >= 'N072' and LEFT([Secondary_Diagnosis_(ICD)_7],3) <='N074') then 'Renal disease'
	when LEFT([Secondary_Diagnosis_(ICD)_7],3) in ('C77', 'C78', 'C79') then 'Metastatic cancer'
	when LEFT([Secondary_Diagnosis_(ICD)_7],4) in  ('K721', 'K729', 'K766', 'K767') then 'Severe liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_7],3) in ('B20', 'B21', 'B22', 'B23', 'B24') then 'HIV'



	--start looking at 8th secondary code
	when LEFT([Secondary_Diagnosis_(ICD)_8],3) in ('I21', 'I22', 'I23') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_8],4) in ('I252', 'I258') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_8],4) in ('G450', 'G451', 'G452', 'G454', 'G458', 'G459') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_8],3) in ('G46') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_8],3) in ('I60','I61','I62','I63','I64','I65','I66','I67','I68','I69') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_8],3) in ('I50') then 'Congestive heart failure'
	when LEFT([Secondary_Diagnosis_(ICD)_8],3) in ('M05', 'M32', 'M34') then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_8],4) in ('M060', 'M063', 'M069', 'M332','M353')then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_8],3) in  ('F00', 'F01', 'F02', 'F03') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_8],4) IN ('F051') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_8],4) in ('E101', 'E105', 'E106', 'E108', 'E109', 'E111', 'E115', 'E116', 'E118', 'E119', 'E131', 'E131', 'E136', 'E138', 'E139', 'E141','E145', 'E146', 'E148','E149') then 'Diabetes'
	when LEFT([Secondary_Diagnosis_(ICD)_8],4) in ('K702', 'K703', 'K717') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_8],3) in ('K73', 'K74') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_8],3) in  ('K25', 'K26', 'K27', 'K28') then 'Peptic ulcer'
	when LEFT([Secondary_Diagnosis_(ICD)_8],3) in ('I71', 'R02') then 'Peripheral vascular disease'
	when LEFT([Secondary_Diagnosis_(ICD)_8],4) in ('I739', 'I790', 'Z958', 'Z959') then 'Peripheral vascular disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_8],3) >= 'J40' and LEFT([Secondary_Diagnosis_(ICD)_8],3) <= 'J47')or
	(LEFT([Secondary_Diagnosis_(ICD)_8],3) >= 'J60' and LEFT([Secondary_Diagnosis_(ICD)_8],3) <= 'J67') then 'Pulmonary disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_8],3) >= 'C00' and LEFT([Secondary_Diagnosis_(ICD)_8],3) <= 'C76')or
	(LEFT([Secondary_Diagnosis_(ICD)_8],3) >= 'C80' and LEFT([Secondary_Diagnosis_(ICD)_8],3) <= 'C97') then 'Cancer'

	when LEFT([Secondary_Diagnosis_(ICD)_8],4) in ('E102', 'E103', 'E104', 'E107', 'E112', 'E113', 'E114', 'E117','E132', 'E133', 'E134', 'E137', 'E142', 'E143', 'E144', 'E147') then 'Diabetes complications'
	when LEFT([Secondary_Diagnosis_(ICD)_8],4) in ('G041', 'G820', 'G821', 'G822') or LEFT([Secondary_Diagnosis_(ICD)_8],3) in ('G81') then 'Paraplegia'
	when LEFT([Secondary_Diagnosis_(ICD)_8],3) in ('I12', 'I13', 'N01', 'N03', 'N18','N19','N25') then 'Renal disease'

	when (LEFT([Secondary_Diagnosis_(ICD)_8],4) >= 'N052' and LEFT([Secondary_Diagnosis_(ICD)_8],3) <='N056') then 'Renal disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_8],4) >= 'N072' and LEFT([Secondary_Diagnosis_(ICD)_8],3) <='N074') then 'Renal disease'
	when LEFT([Secondary_Diagnosis_(ICD)_8],3) in ('C77', 'C78', 'C79') then 'Metastatic cancer'
	when LEFT([Secondary_Diagnosis_(ICD)_8],4) in  ('K721', 'K729', 'K766', 'K767') then 'Severe liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_8],3) in ('B20', 'B21', 'B22', 'B23', 'B24') then 'HIV'

	--start looking at 9th secondary code

	when LEFT([Secondary_Diagnosis_(ICD)_9],3) in ('I21', 'I22', 'I23') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_9],4) in ('I252', 'I258') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_9],4) in ('G450', 'G451', 'G452', 'G454', 'G458', 'G459') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_9],3) in ('G46') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_9],3) in ('I60','I61','I62','I63','I64','I65','I66','I67','I68','I69') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_9],3) in ('I50') then 'Congestive heart failure'
	when LEFT([Secondary_Diagnosis_(ICD)_9],3) in ('M05', 'M32', 'M34') then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_9],4) in ('M060', 'M063', 'M069', 'M332','M353')then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_9],3) in  ('F00', 'F01', 'F02', 'F03') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_9],4) IN ('F051') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_9],4) in ('E101', 'E105', 'E106', 'E108', 'E109', 'E111', 'E115', 'E116', 'E118', 'E119', 'E131', 'E131', 'E136', 'E138', 'E139', 'E141','E145', 'E146', 'E148','E149') then 'Diabetes'
	when LEFT([Secondary_Diagnosis_(ICD)_9],4) in ('K702', 'K703', 'K717') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_9],3) in ('K73', 'K74') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_9],3) in  ('K25', 'K26', 'K27', 'K28') then 'Peptic ulcer'
	when LEFT([Secondary_Diagnosis_(ICD)_9],3) in ('I71', 'R02') then 'Peripheral vascular disease'
	when LEFT([Secondary_Diagnosis_(ICD)_9],4) in ('I739', 'I790', 'Z958', 'Z959') then 'Peripheral vascular disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_9],3) >= 'J40' and LEFT([Secondary_Diagnosis_(ICD)_9],3) <= 'J47')or
	(LEFT([Secondary_Diagnosis_(ICD)_9],3) >= 'J60' and LEFT([Secondary_Diagnosis_(ICD)_9],3) <= 'J67') then 'Pulmonary disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_9],3) >= 'C00' and LEFT([Secondary_Diagnosis_(ICD)_9],3) <= 'C76')or
	(LEFT([Secondary_Diagnosis_(ICD)_9],3) >= 'C80' and LEFT([Secondary_Diagnosis_(ICD)_9],3) <= 'C97') then 'Cancer'

	when LEFT([Secondary_Diagnosis_(ICD)_9],4) in ('E102', 'E103', 'E104', 'E107', 'E112', 'E113', 'E114', 'E117','E132', 'E133', 'E134', 'E137', 'E142', 'E143', 'E144', 'E147') then 'Diabetes complications'
	when LEFT([Secondary_Diagnosis_(ICD)_9],4) in ('G041', 'G820', 'G821', 'G822') or LEFT([Secondary_Diagnosis_(ICD)_9],3) in ('G81') then 'Paraplegia'
	when LEFT([Secondary_Diagnosis_(ICD)_9],3) in ('I12', 'I13', 'N01', 'N03', 'N18','N19','N25') then 'Renal disease'

	when (LEFT([Secondary_Diagnosis_(ICD)_9],4) >= 'N052' and LEFT([Secondary_Diagnosis_(ICD)_9],3) <='N056') then 'Renal disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_9],4) >= 'N072' and LEFT([Secondary_Diagnosis_(ICD)_9],3) <='N074') then 'Renal disease'
	when LEFT([Secondary_Diagnosis_(ICD)_9],3) in ('C77', 'C78', 'C79') then 'Metastatic cancer'
	when LEFT([Secondary_Diagnosis_(ICD)_9],4) in  ('K721', 'K729', 'K766', 'K767') then 'Severe liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_9],3) in ('B20', 'B21', 'B22', 'B23', 'B24') then 'HIV'

		--start looking at 10th secondary code

	when LEFT([Secondary_Diagnosis_(ICD)_10],3) in ('I21', 'I22', 'I23') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_10],4) in ('I252', 'I258') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_10],4) in ('G450', 'G451', 'G452', 'G454', 'G458', 'G459') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_10],3) in ('G46') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_10],3) in ('I60','I61','I62','I63','I64','I65','I66','I67','I68','I69') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_10],3) in ('I50') then 'Congestive heart failure'
	when LEFT([Secondary_Diagnosis_(ICD)_10],3) in ('M05', 'M32', 'M34') then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_10],4) in ('M060', 'M063', 'M069', 'M332','M353')then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_10],3) in  ('F00', 'F01', 'F02', 'F03') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_10],4) IN ('F051') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_10],4) in ('E101', 'E105', 'E106', 'E108', 'E109', 'E111', 'E115', 'E116', 'E118', 'E119', 'E131', 'E131', 'E136', 'E138', 'E139', 'E141','E145', 'E146', 'E148','E149') then 'Diabetes'
	when LEFT([Secondary_Diagnosis_(ICD)_10],4) in ('K702', 'K703', 'K717') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_10],3) in ('K73', 'K74') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_10],3) in  ('K25', 'K26', 'K27', 'K28') then 'Peptic ulcer'
	when LEFT([Secondary_Diagnosis_(ICD)_10],3) in ('I71', 'R02') then 'Peripheral vascular disease'
	when LEFT([Secondary_Diagnosis_(ICD)_10],4) in ('I739', 'I790', 'Z958', 'Z959') then 'Peripheral vascular disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_10],3) >= 'J40' and LEFT([Secondary_Diagnosis_(ICD)_10],3) <= 'J47')or
	(LEFT([Secondary_Diagnosis_(ICD)_10],3) >= 'J60' and LEFT([Secondary_Diagnosis_(ICD)_10],3) <= 'J67') then 'Pulmonary disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_10],3) >= 'C00' and LEFT([Secondary_Diagnosis_(ICD)_10],3) <= 'C76')or
	(LEFT([Secondary_Diagnosis_(ICD)_10],3) >= 'C80' and LEFT([Secondary_Diagnosis_(ICD)_10],3) <= 'C97') then 'Cancer'

	when LEFT([Secondary_Diagnosis_(ICD)_10],4) in ('E102', 'E103', 'E104', 'E107', 'E112', 'E113', 'E114', 'E117','E132', 'E133', 'E134', 'E137', 'E142', 'E143', 'E144', 'E147') then 'Diabetes complications'
	when LEFT([Secondary_Diagnosis_(ICD)_10],4) in ('G041', 'G820', 'G821', 'G822') or LEFT([Secondary_Diagnosis_(ICD)_10],3) in ('G81') then 'Paraplegia'
	when LEFT([Secondary_Diagnosis_(ICD)_10],3) in ('I12', 'I13', 'N01', 'N03', 'N18','N19','N25') then 'Renal disease'

	when (LEFT([Secondary_Diagnosis_(ICD)_10],4) >= 'N052' and LEFT([Secondary_Diagnosis_(ICD)_10],3) <='N056') then 'Renal disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_10],4) >= 'N072' and LEFT([Secondary_Diagnosis_(ICD)_10],3) <='N074') then 'Renal disease'
	when LEFT([Secondary_Diagnosis_(ICD)_10],3) in ('C77', 'C78', 'C79') then 'Metastatic cancer'
	when LEFT([Secondary_Diagnosis_(ICD)_10],4) in  ('K721', 'K729', 'K766', 'K767') then 'Severe liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_10],3) in ('B20', 'B21', 'B22', 'B23', 'B24') then 'HIV'

	--start looking at 11th secondary code

	when LEFT([Secondary_Diagnosis_(ICD)_11],3) in ('I21', 'I22', 'I23') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_11],4) in ('I252', 'I258') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_11],4) in ('G450', 'G451', 'G452', 'G454', 'G458', 'G459') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_11],3) in ('G46') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_11],3) in ('I60','I61','I62','I63','I64','I65','I66','I67','I68','I69') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_11],3) in ('I50') then 'Congestive heart failure'
	when LEFT([Secondary_Diagnosis_(ICD)_11],3) in ('M05', 'M32', 'M34') then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_11],4) in ('M060', 'M063', 'M069', 'M332','M353')then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_11],3) in  ('F00', 'F01', 'F02', 'F03') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_11],4) IN ('F051') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_11],4) in ('E101', 'E105', 'E106', 'E108', 'E109', 'E111', 'E115', 'E116', 'E118', 'E119', 'E131', 'E131', 'E136', 'E138', 'E139', 'E141','E145', 'E146', 'E148','E149') then 'Diabetes'
	when LEFT([Secondary_Diagnosis_(ICD)_11],4) in ('K702', 'K703', 'K717') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_11],3) in ('K73', 'K74') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_11],3) in  ('K25', 'K26', 'K27', 'K28') then 'Peptic ulcer'
	when LEFT([Secondary_Diagnosis_(ICD)_11],3) in ('I71', 'R02') then 'Peripheral vascular disease'
	when LEFT([Secondary_Diagnosis_(ICD)_11],4) in ('I739', 'I790', 'Z958', 'Z959') then 'Peripheral vascular disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_11],3) >= 'J40' and LEFT([Secondary_Diagnosis_(ICD)_11],3) <= 'J47')or
	(LEFT([Secondary_Diagnosis_(ICD)_11],3) >= 'J60' and LEFT([Secondary_Diagnosis_(ICD)_11],3) <= 'J67') then 'Pulmonary disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_11],3) >= 'C00' and LEFT([Secondary_Diagnosis_(ICD)_11],3) <= 'C76')or
	(LEFT([Secondary_Diagnosis_(ICD)_11],3) >= 'C80' and LEFT([Secondary_Diagnosis_(ICD)_11],3) <= 'C97') then 'Cancer'

	when LEFT([Secondary_Diagnosis_(ICD)_11],4) in ('E102', 'E103', 'E104', 'E107', 'E112', 'E113', 'E114', 'E117','E132', 'E133', 'E134', 'E137', 'E142', 'E143', 'E144', 'E147') then 'Diabetes complications'
	when LEFT([Secondary_Diagnosis_(ICD)_11],4) in ('G041', 'G820', 'G821', 'G822') or LEFT([Secondary_Diagnosis_(ICD)_11],3) in ('G81') then 'Paraplegia'
	when LEFT([Secondary_Diagnosis_(ICD)_11],3) in ('I12', 'I13', 'N01', 'N03', 'N18','N19','N25') then 'Renal disease'

	when (LEFT([Secondary_Diagnosis_(ICD)_11],4) >= 'N052' and LEFT([Secondary_Diagnosis_(ICD)_11],3) <='N056') then 'Renal disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_11],4) >= 'N072' and LEFT([Secondary_Diagnosis_(ICD)_11],3) <='N074') then 'Renal disease'
	when LEFT([Secondary_Diagnosis_(ICD)_11],3) in ('C77', 'C78', 'C79') then 'Metastatic cancer'
	when LEFT([Secondary_Diagnosis_(ICD)_11],4) in  ('K721', 'K729', 'K766', 'K767') then 'Severe liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_11],3) in ('B20', 'B21', 'B22', 'B23', 'B24') then 'HIV'

	--start looking at 12th secondary code

	when LEFT([Secondary_Diagnosis_(ICD)_12],3) in ('I21', 'I22', 'I23') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_12],4) in ('I252', 'I258') then 'Acute myocardial infarction'
	when LEFT([Secondary_Diagnosis_(ICD)_12],4) in ('G450', 'G451', 'G452', 'G454', 'G458', 'G459') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_12],3) in ('G46') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_12],3) in ('I60','I61','I62','I63','I64','I65','I66','I67','I68','I69') then 'Cerebral vascular accident'
	when LEFT([Secondary_Diagnosis_(ICD)_12],3) in ('I50') then 'Congestive heart failure'
	when LEFT([Secondary_Diagnosis_(ICD)_12],3) in ('M05', 'M32', 'M34') then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_12],4) in ('M060', 'M063', 'M069', 'M332','M353')then 'Connective tissue disorder'
	when LEFT([Secondary_Diagnosis_(ICD)_12],3) in  ('F00', 'F01', 'F02', 'F03') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_12],4) IN ('F051') then 'Dementia'
	when LEFT([Secondary_Diagnosis_(ICD)_12],4) in ('E101', 'E105', 'E106', 'E108', 'E109', 'E111', 'E115', 'E116', 'E118', 'E119', 'E131', 'E131', 'E136', 'E138', 'E139', 'E141','E145', 'E146', 'E148','E149') then 'Diabetes'
	when LEFT([Secondary_Diagnosis_(ICD)_12],4) in ('K702', 'K703', 'K717') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_12],3) in ('K73', 'K74') then 'Liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_12],3) in  ('K25', 'K26', 'K27', 'K28') then 'Peptic ulcer'
	when LEFT([Secondary_Diagnosis_(ICD)_12],3) in ('I71', 'R02') then 'Peripheral vascular disease'
	when LEFT([Secondary_Diagnosis_(ICD)_12],4) in ('I739', 'I790', 'Z958', 'Z959') then 'Peripheral vascular disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_12],3) >= 'J40' and LEFT([Secondary_Diagnosis_(ICD)_12],3) <= 'J47')or
	(LEFT([Secondary_Diagnosis_(ICD)_12],3) >= 'J60' and LEFT([Secondary_Diagnosis_(ICD)_12],3) <= 'J67') then 'Pulmonary disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_12],3) >= 'C00' and LEFT([Secondary_Diagnosis_(ICD)_12],3) <= 'C76')or
	(LEFT([Secondary_Diagnosis_(ICD)_12],3) >= 'C80' and LEFT([Secondary_Diagnosis_(ICD)_12],3) <= 'C97') then 'Cancer'

	when LEFT([Secondary_Diagnosis_(ICD)_12],4) in ('E102', 'E103', 'E104', 'E107', 'E112', 'E113', 'E114', 'E117','E132', 'E133', 'E134', 'E137', 'E142', 'E143', 'E144', 'E147') then 'Diabetes complications'
	when LEFT([Secondary_Diagnosis_(ICD)_12],4) in ('G041', 'G820', 'G821', 'G822') or LEFT([Secondary_Diagnosis_(ICD)_12],3) in ('G81') then 'Paraplegia'
	when LEFT([Secondary_Diagnosis_(ICD)_12],3) in ('I12', 'I13', 'N01', 'N03', 'N18','N19','N25') then 'Renal disease'

	when (LEFT([Secondary_Diagnosis_(ICD)_12],4) >= 'N052' and LEFT([Secondary_Diagnosis_(ICD)_12],3) <='N056') then 'Renal disease'
	when (LEFT([Secondary_Diagnosis_(ICD)_12],4) >= 'N072' and LEFT([Secondary_Diagnosis_(ICD)_12],3) <='N074') then 'Renal disease'
	when LEFT([Secondary_Diagnosis_(ICD)_12],3) in ('C77', 'C78', 'C79') then 'Metastatic cancer'
	when LEFT([Secondary_Diagnosis_(ICD)_12],4) in  ('K721', 'K729', 'K766', 'K767') then 'Severe liver disease'
	when LEFT([Secondary_Diagnosis_(ICD)_12],3) in ('B20', 'B21', 'B22', 'B23', 'B24') then 'HIV'
	else '** No Charleson Comorbidity casemix **'
	end as CharlsonCC_Ind,
	[Avg Charlson]
,1 as Spell	

into ##SW_HeartFailure_PrimSecDiag

from RF_Performance.dbo.RF_Performance_APC_Main apc

 LEFT OUTER JOIN
Ardentia_Healthware_64_Reference.dbo.RF_CRT_Consultants AS CONS
ON apc.Consultant_Code = CONS.Consultant_Code

LEFT JOIN [RF_Reference].[ICD10].[ICD10_L3] icd3
on LEFT(APC.[Primary_Diagnosis_(ICD)],3)=  icd3.code

LEFT JOIN [RF_Reference].[ICD10].[ICD10_L3] icd3s
on LEFT(APC.[Secondary_Diagnosis_(ICD)_1],3)=  icd3s.code

--LEFT  JOIN 
--[div_perf].[dbo].[ICD10_SW_List] ICD10_4x
--on LEFT(APC.[Primary_Diagnosis_(ICD)],4)=  left(ICD10_4x.Code_4d,4)

--LEFT OUTER JOIN
--Ardentia_Healthware_64_Reference.dbo.ICD10_V4_L4 AS ICD10_4
--ON REPLACE(LEFT(APC.[Primary_Diagnosis_(ICD)],4),'X','') = ICD10_4.Code

LEFT OUTER JOIN
Ardentia_Healthware_64_Reference.dbo.ICD10_V4_L4 AS ICD10_43
ON REPLACE(LEFT(APC.[Primary_Diagnosis_(ICD)],3),'X','') = ICD10_43.Code

LEFT OUTER JOIN
Ardentia_Healthware_64_Reference.dbo.OPCS4_L3 AS OPCS4
--ON REPLACE(left(APC.[Primary_Procedure_(OPCS)],3),'.','') = OPCS4.Code
ON left(APC.[Primary_Procedure_(OPCS)],3) = OPCS4.Code


left join [Ardentia_Healthware_64_Reference].[dbo].[ICD10_L3] as [ICD10_L3_s2]
on left(apc.[Secondary_Diagnosis_(ICD)_1],3)=[ICD10_L3_s2].Code

left join [Ardentia_Healthware_64_Reference].[dbo].[ICD10_L3] as [ICD10_L3_s3]
on left(apc.[Secondary_Diagnosis_(ICD)_2],3)=[ICD10_L3_s3].Code

left join [Ardentia_Healthware_64_Reference].[dbo].[ICD10_L3] as [ICD10_L3_s4]
on left(apc.[Secondary_Diagnosis_(ICD)_3],3)=[ICD10_L3_s4].Code
	
left join [Ardentia_Healthware_64_Reference].[dbo].[ICD10_L3] as [ICD10_L3_s5]
on left(apc.[Secondary_Diagnosis_(ICD)_4],3)=[ICD10_L3_s5].Code

left join [Ardentia_Healthware_64_Reference].[dbo].[ICD10_L3] as [ICD10_L3_s6]
on left(apc.[Secondary_Diagnosis_(ICD)_5],3)=[ICD10_L3_s6].Code

left join [Ardentia_Healthware_64_Reference].[dbo].[ICD10_L3] as [ICD10_L3_s7]
on left(apc.[Secondary_Diagnosis_(ICD)_6],3)=[ICD10_L3_s7].Code

left join [Ardentia_Healthware_64_Reference].[dbo].[ICD10_L3] as [ICD10_L3_s8]
on left(apc.[Secondary_Diagnosis_(ICD)_7],3)=[ICD10_L3_s8].Code

left join [Ardentia_Healthware_64_Reference].[dbo].[ICD10_L3] as [ICD10_L3_s9]
on left(apc.[Secondary_Diagnosis_(ICD)_8],3)=[ICD10_L3_s9].Code

left join [Ardentia_Healthware_64_Reference].[dbo].[ICD10_L3] as [ICD10_L3_s10]
on left(apc.[Secondary_Diagnosis_(ICD)_9],3)=[ICD10_L3_s10].Code

left join [Ardentia_Healthware_64_Reference].[dbo].[OPCS4_L3] as [OPCS4_L3_s1]
on left(apc.[Procedure_(OPCS)_1],3)=[OPCS4_L3_s1].Code

left join [Ardentia_Healthware_64_Reference].[dbo].[OPCS4_L3] as [OPCS4_L3_s2]
on left(apc.[Procedure_(OPCS)_2],3)=[OPCS4_L3_s2].Code

left join [Ardentia_Healthware_64_Reference].[dbo].[OPCS4_L3] as [OPCS4_L3_s3]
on left(apc.[Procedure_(OPCS)_3],3)=[OPCS4_L3_s3].Code
	
left join [Ardentia_Healthware_64_Reference].[dbo].[OPCS4_L3] as [OPCS4_L3_s4]
on left(apc.[Procedure_(OPCS)_4],3)=[OPCS4_L3_s4].Code

left join [Ardentia_Healthware_64_Reference].[dbo].[OPCS4_L3] as [OPCS4_L3_s5]
on left(apc.[Procedure_(OPCS)_5],3)=[OPCS4_L3_s5].Code

left join [Ardentia_Healthware_64_Reference].[dbo].[OPCS4_L3] as [OPCS4_L3_s6]
on left(apc.[Procedure_(OPCS)_6],3)=[OPCS4_L3_s6].Code

left join [Ardentia_Healthware_64_Reference].[dbo].[OPCS4_L3] as [OPCS4_L3_s7]
on left(apc.[Procedure_(OPCS)_7],3)=[OPCS4_L3_s7].Code

left join [Ardentia_Healthware_64_Reference].[dbo].[OPCS4_L3] as [OPCS4_L3_s8]
on left(apc.[Procedure_(OPCS)_8],3)=[OPCS4_L3_s8].Code

left join [Ardentia_Healthware_64_Reference].[dbo].[OPCS4_L3] as [OPCS4_L3_s9]
on left(apc.[Procedure_(OPCS)_9],3)=[OPCS4_L3_s9].Code

left outer join (
	select
	APCJoinKey,
	AVG(
	RFH_AdhocEnvironment.dbo.fn_STH_Charlson(AgeOnAdmission --Note: setting age to 0 prevents any age adjustments being made
	 ,[Secondary_Diagnosis_(ICD)_1]
	 ,[Secondary_Diagnosis_(ICD)_2]
	 ,[Secondary_Diagnosis_(ICD)_3]
	 ,[Secondary_Diagnosis_(ICD)_4]
	 ,[Secondary_Diagnosis_(ICD)_5]
	 ,[Secondary_Diagnosis_(ICD)_6]
	 ,[Secondary_Diagnosis_(ICD)_7]
	 ,[Secondary_Diagnosis_(ICD)_8]
	 ,[Secondary_Diagnosis_(ICD)_9]
	 ,[Secondary_Diagnosis_(ICD)_10]
	 ,[Secondary_Diagnosis_(ICD)_11]
	 ,[Secondary_Diagnosis_(ICD)_12]
	 )) AS [Avg Charlson]
	FROM RF_Performance.DBO.RF_Performance_APC_Main m
	group by
	apcjoinkey) as charlson
	on charlson.apcjoinkey = apc.apcjoinkey
	
where 
([Discharge_Date_(Hospital_Provider_Spell)] >= cast('01-Apr-2016' as date)
and
[Discharge_Date_(Hospital_Provider_Spell)] <=  cast('30-Nov-2019' as date))
and
Last_Episode_in_Spell_Indicator in ('1','01')
and
CDS_Update_Type = 9
and
([Primary_Diagnosis_(ICD)] IN ('I500','I501','I509','I110','I420','I255','I429') OR
	[Secondary_Diagnosis_(ICD)_1] IN ('I500','I501','I509','I110','I420','I255','I429')  OR
	[Secondary_Diagnosis_(ICD)_2] IN ('I500','I501','I509','I110','I420','I255','I429')  OR
	[Secondary_Diagnosis_(ICD)_3] IN ('I500','I501','I509','I110','I420','I255','I429')  OR
	[Secondary_Diagnosis_(ICD)_4] IN ('I500','I501','I509','I110','I420','I255','I429')  OR
	[Secondary_Diagnosis_(ICD)_5] IN ('I500','I501','I509','I110','I420','I255','I429')  OR
	[Secondary_Diagnosis_(ICD)_6] IN ('I500','I501','I509','I110','I420','I255','I429')  OR
	[Secondary_Diagnosis_(ICD)_7] IN ('I500','I501','I509','I110','I420','I255','I429')  OR
	[Secondary_Diagnosis_(ICD)_8] IN ('I500','I501','I509','I110','I420','I255','I429') OR
	[Secondary_Diagnosis_(ICD)_9] IN ('I500','I501','I509','I110','I420','I255','I429') OR
	[Secondary_Diagnosis_(ICD)_10] IN ('I500','I501','I509','I110','I420','I255','I429')  OR
	[Secondary_Diagnosis_(ICD)_11] IN ('I500','I501','I509','I110','I420','I255','I429')  OR
	[Secondary_Diagnosis_(ICD)_12] IN ('I500','I501','I509','I110','I420','I255','I429')  OR
	[Secondary_Diagnosis_ICD_13_to_50] IN ('I500','I501','I509','I110','I420','I255','I429')    )
		
------------------------------------------------------------------------------------------------------------------

SELECT FinancialYear,count(*)  FROM RF_Performance.dbo.RF_Performance_APC_Main

where 
([Discharge_Date_(Hospital_Provider_Spell)] >= cast('01-Apr-2016' as date)
and
[Discharge_Date_(Hospital_Provider_Spell)] <=  cast('30-Sep-2019' as date))
and
Last_Episode_in_Spell_Indicator in ('1','01')
and
CDS_Update_Type = 9
and
([Primary_Diagnosis_(ICD)] IN ('I500','I501','I509','I110','I420','I255','I429') OR
	[Secondary_Diagnosis_(ICD)_1] IN ('I500','I501','I509','I110','I420','I255','I429')  OR
	[Secondary_Diagnosis_(ICD)_2] IN ('I500','I501','I509','I110','I420','I255','I429')  OR
	[Secondary_Diagnosis_(ICD)_3] IN ('I500','I501','I509','I110','I420','I255','I429')  OR
	[Secondary_Diagnosis_(ICD)_4] IN ('I500','I501','I509','I110','I420','I255','I429')  OR
	[Secondary_Diagnosis_(ICD)_5] IN ('I500','I501','I509','I110','I420','I255','I429')  OR
	[Secondary_Diagnosis_(ICD)_6] IN ('I500','I501','I509','I110','I420','I255','I429')  OR
	[Secondary_Diagnosis_(ICD)_7] IN ('I500','I501','I509','I110','I420','I255','I429')  OR
	[Secondary_Diagnosis_(ICD)_8] IN ('I500','I501','I509','I110','I420','I255','I429') OR
	[Secondary_Diagnosis_(ICD)_9] IN ('I500','I501','I509','I110','I420','I255','I429') OR
	[Secondary_Diagnosis_(ICD)_10] IN ('I500','I501','I509','I110','I420','I255','I429')  OR
	[Secondary_Diagnosis_(ICD)_11] IN ('I500','I501','I509','I110','I420','I255','I429')  OR
	[Secondary_Diagnosis_(ICD)_12] IN ('I500','I501','I509','I110','I420','I255','I429')  OR
	[Secondary_Diagnosis_ICD_13_to_50] IN ('I500','I501','I509','I110','I420','I255','I429')    )

	group by FinancialYear

--------------------------------------------------------------------------------------------------------------------------------------------
	--Create a table containing the alphabet. this will be used for the ICD10 codes grouping
-------------------------------------------------------------------------------------------------------
	DECLARE @Alphabet TABLE(ID INT,Letters VARCHAR(1))
	DECLARE @asciiCode INT= 65 
	WHILE @asciiCode <= 90 
	BEGIN
		INSERT into @Alphabet VALUES (@asciiCode-64, CHAR(@asciiCode) ) 
		SELECT  @asciiCode = @asciiCode + 1
	END
	
	
	select distinct m.*,
	[ICD10_Levels].ICD10_Lv1_Description,
	[ICD10_Levels].ICD10_Lv2_Description,
	apc.[Ward_Code_at_End_Episode] as Ward_at_discharge,
	case when DischargeStatus = 'Died' then 1 else 0 end as DiedFlag,
		
CASE
	WHEN DATEDIFF(DD,Date_of_Birth,m.[Start_Date_(Hospital_Provider_Spell)])/365.25 BETWEEN 0 AND 4.99999 THEN '00-04'
	WHEN DATEDIFF(DD,Date_of_Birth,m.[Start_Date_(Hospital_Provider_Spell)])/365.25 BETWEEN 5 AND 9.99999 THEN '05-09'
	
	WHEN DATEDIFF(DD,Date_of_Birth,m.[Start_Date_(Hospital_Provider_Spell)])/365.25 BETWEEN 10 AND 14.99999 THEN '10-14'
	WHEN DATEDIFF(DD,Date_of_Birth,m.[Start_Date_(Hospital_Provider_Spell)])/365.25 BETWEEN 15 AND 19.99999 THEN '15-19'
	
	WHEN DATEDIFF(DD,Date_of_Birth,m.[Start_Date_(Hospital_Provider_Spell)])/365.25 BETWEEN 20 AND 24.99999 THEN '20-24'
	WHEN DATEDIFF(DD,Date_of_Birth,m.[Start_Date_(Hospital_Provider_Spell)])/365.25 BETWEEN 25 AND 29.99999 THEN '25-29'

	WHEN DATEDIFF(DD,Date_of_Birth,m.[Start_Date_(Hospital_Provider_Spell)])/365.25 BETWEEN 30 AND 34.99999 THEN '30-34'
	WHEN DATEDIFF(DD,Date_of_Birth,m.[Start_Date_(Hospital_Provider_Spell)])/365.25 BETWEEN 35 AND 39.99999 THEN '35-39'	

	WHEN DATEDIFF(DD,Date_of_Birth,m.[Start_Date_(Hospital_Provider_Spell)])/365.25 BETWEEN 40 AND 44.99999 THEN '40-44'
	WHEN DATEDIFF(DD,Date_of_Birth,m.[Start_Date_(Hospital_Provider_Spell)])/365.25 BETWEEN 45 AND 49.99999 THEN '45-49'	
		
	WHEN DATEDIFF(DD,Date_of_Birth,m.[Start_Date_(Hospital_Provider_Spell)])/365.25 BETWEEN 50 AND 54.99999 THEN '50-54'
	WHEN DATEDIFF(DD,Date_of_Birth,m.[Start_Date_(Hospital_Provider_Spell)])/365.25 BETWEEN 55 AND 59.99999 THEN '55-59'	
		
	WHEN DATEDIFF(DD,Date_of_Birth,m.[Start_Date_(Hospital_Provider_Spell)])/365.25 BETWEEN 60 AND 64.99999 THEN '60-64'
	WHEN DATEDIFF(DD,Date_of_Birth,m.[Start_Date_(Hospital_Provider_Spell)])/365.25 BETWEEN 65 AND 69.99999 THEN '65-69'	
		
	WHEN DATEDIFF(DD,Date_of_Birth,m.[Start_Date_(Hospital_Provider_Spell)])/365.25 BETWEEN 70 AND 74.99999 THEN '70-74'
	WHEN DATEDIFF(DD,Date_of_Birth,m.[Start_Date_(Hospital_Provider_Spell)])/365.25 BETWEEN 75 AND 79.99999 THEN '75-79'	
	
	WHEN DATEDIFF(DD,Date_of_Birth,m.[Start_Date_(Hospital_Provider_Spell)])/365.25 BETWEEN 80 AND 84.99999 THEN '80-84'
	WHEN DATEDIFF(DD,Date_of_Birth,m.[Start_Date_(Hospital_Provider_Spell)])/365.25 BETWEEN 85 AND 89.99999 THEN '85-89'	
	
	WHEN DATEDIFF(DD,Date_of_Birth,m.[Start_Date_(Hospital_Provider_Spell)])/365.25 BETWEEN 90 AND 94.99999 THEN '90-94'

	WHEN DATEDIFF(DD,Date_of_Birth,m.[Start_Date_(Hospital_Provider_Spell)])/365.25 >= 95 THEN '95+' 
ELSE '' END AS 'Age_Band_Detailed'
	into ##SW_HeartFailure_PrimSecDiag2
	from ##SW_HeartFailure_PrimSecDiag m

	--create chapters for the ICD10 codes and then join it to the discharge data.
	left join (
		select
		[ICD10_L3].[Code]
		,[ICD10_L3].[Description] as [ICD10_Lv3_Descriprion]
		,ICD_Lv2.[Description] as [ICD10_Lv2_Description]
		,ICD_Lv1.[Description] as [ICD10_Lv1_Description]
		FROM [Ardentia_Healthware_64_Reference].[dbo].[ICD10_L3] as [ICD10_L3]
		left join (SELECT * FROM @Alphabet) as AlphabetS
		on LEFT(ltrim(rtrim([Code])),1)=AlphabetS.Letters
		left join (SELECT * FROM @Alphabet) as AlphabetE
		on left(RIGHT(ltrim(rtrim([Code])),3),1)=AlphabetE.Letters

			left join (
					select
					[Code]
					,(cast(AlphabetS.ID as varchar(2))+RIGHT(LEFT(ltrim(rtrim([Code])),3),2))*1 as [Lv2_Start]
					,(cast(AlphabetE.ID as varchar(2))+RIGHT(ltrim(rtrim([Code])),2))*1 as [Lv2_End]
					,[Description]
					FROM [Ardentia_Healthware_64_Reference].[dbo].[ICD10_L2] as [ICD10_L2]
					left join (SELECT * FROM @Alphabet) as AlphabetS
					on LEFT(ltrim(rtrim([Code])),1)=AlphabetS.Letters
					left join (SELECT * FROM @Alphabet) as AlphabetE
					on left(RIGHT(ltrim(rtrim([Code])),3),1)=AlphabetE.Letters
					where 
					right(LEFT(ltrim(rtrim([Code])),3),2) not like '%[^0-9]%'
					AND RIGHT(ltrim(rtrim([Code])),2) not like '%[^0-9]%'
						) as ICD_Lv2
			on ((cast(AlphabetE.ID as varchar(2))+RIGHT(ltrim(rtrim([ICD10_L3].[Code])),2))*1>=ICD_Lv2.Lv2_Start
			and (cast(AlphabetE.ID as varchar(2))+RIGHT(ltrim(rtrim([ICD10_L3].[Code])),2))*1<=ICD_Lv2.Lv2_End)

			left join (
						select
						[Code]
						,(cast(AlphabetS.ID as varchar(2))+RIGHT(LEFT(ltrim(rtrim([Code])),3),2))*1 as [Lv1_Start]
						,(cast(AlphabetE.ID as varchar(2))+RIGHT(ltrim(rtrim([Code])),2))*1 as [Lv1_End]
						,[Description]
						FROM [Ardentia_Healthware_64_Reference].[dbo].[ICD10_L1] as [ICD10_L1]
						left join (SELECT * FROM @Alphabet) as AlphabetS
						on LEFT(ltrim(rtrim([Code])),1)=AlphabetS.Letters
						left join (SELECT * FROM @Alphabet) as AlphabetE
						on left(RIGHT(ltrim(rtrim([Code])),3),1)=AlphabetE.Letters
						where 
						right(LEFT(ltrim(rtrim([Code])),3),2) not like '%[^0-9]%'
						AND RIGHT(ltrim(rtrim([Code])),2) not like '%[^0-9]%'
						) ICD_Lv1
			on ((cast(AlphabetE.ID as varchar(2))+RIGHT(ltrim(rtrim([ICD10_L3].[Code])),2))*1>=ICD_Lv1.Lv1_Start
			and (cast(AlphabetE.ID as varchar(2))+RIGHT(ltrim(rtrim([ICD10_L3].[Code])),2))*1<=ICD_Lv1.Lv1_End)

			where 
			right(LEFT(ltrim(rtrim([ICD10_L3].[Code])),3),2) not like '%[^0-9]%'
			AND RIGHT(ltrim(rtrim([ICD10_L3].[Code])),2) not like '%[^0-9]%'
	) as [ICD10_Levels]
	on left([Primary_Diagnosis_(ICD)],3)=[ICD10_Levels].Code

	left join rf_performance.dbo.rf_performance_apc_main apc
	on apc.Hospital_Provider_Spell_Number= m.Hospital_Provider_Spell_Number
	and apc.Last_Episode_in_Spell_Indicator in ('1','01')
	
		
--25720


select distinct *

 

into ##SW_HeartFailure_PrimSecDiag_Report

from (
select p.*,' -- ' as Filler,
ROW_NUMBER() OVER(PARTITION BY p.local_patient_id,p.Hospital_Provider_Spell_Number ORDER BY readm.[Start_Date_(Hospital_Provider_Spell)]) AS N,
	READM.Local_Patient_ID as Readm_Local_Patient_ID,
READM.Hospital_Provider_Spell_Number as Readm_Hospital_Provider_Spell_Number,
READM.[Start_Date_(Hospital_Provider_Spell)] as [Readm_Start_Date_(Hospital_Provider_Spell)],
READM.[Discharge_Date_(Hospital_Provider_Spell)] AS [Readm_[Discharge_Date_(Hospital_Provider_Spell)],
READM.Consultant_At_Discharge as [Consultant_At_Readmission],
READM.Specialty_Desc as [Specialty_Desc_At_Readmission],
READM.[Primary Diagnosis 3d] as Primary_Diagnosis_At_Readmission,
READM.[Primary Procedure] as Primary_Procedure_At_Readmission,
case when READM.Hospital_Provider_Spell_Number is not null then 1 else 0 end as Readmission_Numerator,
datediff(dd,p.[Discharge_Date_(Hospital_Provider_Spell)],READM.[Start_Date_(Hospital_Provider_Spell)] ) as Readmission_Period,
case when datediff(dd,p.[Discharge_Date_(Hospital_Provider_Spell)],READM.[Start_Date_(Hospital_Provider_Spell)] ) <7 then 1 else 0 end as Readmission7d,
case when datediff(dd,p.[Discharge_Date_(Hospital_Provider_Spell)],READM.[Start_Date_(Hospital_Provider_Spell)] ) <30 then 1 else 0 end as Readmission30d,
case when datediff(dd,p.[Discharge_Date_(Hospital_Provider_Spell)],READM.[Start_Date_(Hospital_Provider_Spell)] ) <60 then 1 else 0 end as Readmission60d,
case when datediff(dd,p.[Discharge_Date_(Hospital_Provider_Spell)],READM.[Start_Date_(Hospital_Provider_Spell)] ) <90 then 1 else 0 end as Readmission90d

 from ##SW_HeartFailure_PrimSecDiag2 p

 left outer join  (select * from ##SW_HeartFailure_PrimSecDiag2
 
where
left([Admission_Method_(Hospital_Provider_Spell)],1) = '2' 
 ) as readm
 on readm.[local_patient_id] = P.[local_patient_id]
 and readm.Hospital_Provider_Spell_Number <> P.Hospital_Provider_Spell_Number
 and readm.[Start_Date_(Hospital_Provider_Spell)] >= P.[Discharge_Date_(Hospital_Provider_Spell)]
) as final_r
where n = 1 and 
([Discharge_Date_(Hospital_Provider_Spell)] >= cast('01-Apr-2016' as date)
and
[Discharge_Date_(Hospital_Provider_Spell)] <=  cast('30-Sep-2019' as date))


