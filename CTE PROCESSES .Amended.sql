
Create view  Excutive_Healthcare_Summary 
As
--cte process 
With Patient_base as(
select
      Dense_rank() Over (order by upper(trim([name])),age,upper(Trim(gender)),Upper(Trim(blood_type))) as Patient_id, -- creading a unique ID
      [Name],
      age,
      gender,
      blood_type
From Healthcare_date
),
Hospital_record as(
Select 
      Dense_rank() Over (order by upper(trim(h.[name])),h.age,upper(Trim(h.gender)),Upper(Trim(h.blood_type))) as Patient_id,
      h.medical_condition,
      h.Date_of_admission,
      YEAR(h.Date_of_admission) admission_year,
      h.Doctor,
      h.Hospital,
      h.insurance_provider,
      h.billing_amount,
      h.Room_number,
      h.Admission_type,
      h.Discharge_date,
      h.Medication,
      h.test_results
From [dbo].[Healthcare_Date] h

),
--Select * 
--From Hospital_record
Admission_summary_table as(
Select h.Date_of_admission,
       p.Patient_id,
       p.[Name],
       p.age,
       p.gender,
       p.blood_type,
       Sum(Case When p.blood_type = 'O+' then 1 Else 0 End) as [Universal_Blood_donor_o+], 
       Sum(Case when p.blood_type = 'AB+' then 1 Else 0 End) as [Universal_blood_reciever_AB+],
       h.medical_condition,
       Case
       When h.medical_condition in ('Cancer','Asthma') then 'High_risk'
       When h.medical_condition in ('Diabetes','Hypertension') then 'medium_risk'
       when h.medical_condition in ('Arthritis','Obesity') then 'low_risk'
       Else 'normal'
       End as Patient_Risk_category,
       h.Doctor,
       h.Hospital,
       h.insurance_provider,
       h.Room_number,
       h.Admission_type,
       h.Discharge_date,
       h.Medication,
       h.test_results,
       Datediff(day, h.Date_of_Admission, h.Discharge_Date) as length_of_stay,
       Case
       when Datediff(day, h.Date_of_Admission, h.Discharge_Date) > 10 then 'LateDischarge'
       else 'Normal_discharge'
       end DischargeFlag
From Patient_base p
inner join Hospital_record h
on p.patient_id = h.patient_id
group by h.date_of_admission, p.Patient_id,
         p.[Name],
         p.age,
         p.gender,
         p.blood_type,
         h.medical_condition,
         h.Doctor,
       h.Hospital,
       h.insurance_provider,
       h.Room_number,
       h.Admission_type,
       h.Discharge_date,
       h.Medication,
       h.test_results
),
--Select *
--From Admission_summary_table
Hospital_finances as(
Select a.patient_id,
       a.admission_type,
       a.date_of_admission as date_of_service,
       a.insurance_provider,
       a.billing_amount as service_charge,
       Round(Avg(a.Billing_amount)over(),2) as Overall_avg_service_charge
From hospital_record a

),
Excutive_Healthcare_Summary as(
  select
       p.Patient_id,
       p.[Name]                as Patient_Name,
       p.age                   as Patient_Age,
       p.gender,
       p.blood_type            as Patient_Blood_Type,
       a.[Universal_Blood_donor_o+],
       a.[Universal_blood_reciever_AB+],
       h.admission_year,
       a.date_of_admission,
       a.Discharge_date,
       a.length_of_stay,
       a.DischargeFlag,
       a.Hospital              as Hospital_Name,
       a.doctor                as Patient_doctor,
       a.admission_type,
       a.Room_number,
       a.medical_condition     as patient_health_condition,
       a.Patient_Risk_category,
       a.Medication,
       a.test_results,
       f.insurance_provider,
       f.date_of_service,
       f.service_charge,
       f.Overall_avg_service_charge
From Patient_base p
inner join Hospital_record h
on p.patient_id = h.patient_id
inner join Admission_summary_table a
on a.patient_id = p.patient_id
inner join Hospital_finances f
on f.patient_id = p.patient_id
) 
select *
from Excutive_Healthcare_Summary