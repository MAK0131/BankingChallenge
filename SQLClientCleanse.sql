if object_id('[client]') is not null
begin 
	drop table [client]
end

;with CTE1
as
(
select
	 client_id
	,birth_number
	,left(birth_number,2) as [year]
	,substring(birth_number,3,2) as [month]
	,case
		when substring(birth_number,3,2) > 50 then (substring(birth_number,3,2) - 50)
		else substring(birth_number,3,2)
	 end as [month_converted]
	,right(birth_number,2) as [day]
	,CONCAT(left(birth_number,2)
	,case
		when substring(birth_number,3,2) > 50 then (substring(birth_number,3,2) - 50)
		else substring(birth_number,3,2)
	 end
		,right(birth_number,2)) as [date_of_birth]
	,district_id
	,case
		when substring(birth_number,3,2) > 50 then 'Female'
		else 'Male'
	end as [Gender]

from dbo.client_stage
)
, CTE2
as
(
select
	 client_id
	,birth_number
	,cast(case
		when len(date_of_birth) < 6 then concat(19, left(date_of_birth, 2), 0, right(date_of_birth, 3))
		else concat(19, date_of_birth)
	 end as date) as [DOB]
	,district_id
	,cast(gender as varchar(10)) as gender

from CTE1
)
select
	 client_id
	,birth_number
	,DOB
	,datediff(yy, DOB, getdate()) as Age
	,case
		when datediff(yy, DOB, getdate()) < 10 then '0-9'
		when datediff(yy, DOB, getdate()) < 20 then '10-19'
		when datediff(yy, DOB, getdate()) < 30 then '20-29'
		when datediff(yy, DOB, getdate()) < 40 then '30-39'
		when datediff(yy, DOB, getdate()) < 50 then '40-49'
		when datediff(yy, DOB, getdate()) < 60 then '50-59'
		when datediff(yy, DOB, getdate()) < 70 then '60-69'
		when datediff(yy, DOB, getdate()) < 80 then '70-79'
		when datediff(yy, DOB, getdate()) < 90 then '80-89'
		when datediff(yy, DOB, getdate()) < 100 then '90-99'
		when datediff(yy, DOB, getdate()) < 110 then '100-109'
		else '110+'
	 end as Age_bin
	,district_id
	,gender

into dbo.client

from CTE2