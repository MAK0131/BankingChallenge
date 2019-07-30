; with CTE1
as
(
select
	 account_id
	,yearly_outstanding_balance
	,dense_rank() over (partition by account_id order by yearly_outstanding_balance asc) as worst_year
	,loan_year

from dbo.MaxDebt
)
, CTE2
as
(
select
	 account_id
	,yearly_outstanding_balance
	,loan_year as MaxDebtYear
from CTE1
where worst_year = 1 and yearly_outstanding_balance < 0
)
, CTE3
as
(
select
	 dbo. client.client_id
	,CTE2.account_id
	,CTE2.MaxDebtYear
	,CTE2.MaxDebtYear - datepart(yy,DOB) as Debt_Age
	,CTE2.yearly_outstanding_balance
from CTE2
join dbo.disp
	on CTE2.account_id = dbo.disp.account_id
join dbo.client
	on dbo.disp.client_id = dbo.client.client_id
)
, CTE4
as
(
select
	 client_id
	,account_id
	,yearly_outstanding_balance
	,MaxDebtYear
	,Debt_Age
	,case
		when Debt_Age < 10 then '0-9'
		when Debt_Age < 20 then '10-19'
		when Debt_Age < 30 then '20-29'
		when Debt_Age < 40 then '30-39'
		when Debt_Age < 50 then '40-49'
		when Debt_Age < 60 then '50-59'
		when Debt_Age < 70 then '60-69'
		when Debt_Age < 80 then '70-79'
		when Debt_Age < 90 then '80-89'
		when Debt_Age < 100 then '90-99'
		when Debt_Age < 110 then '100-109'
		else '110+'
	 end as Age_bin
from CTE3
)
select
	 avg(yearly_outstanding_balance) as Average_max_debt
	,Age_bin
from CTE4
group by Age_bin
order by Average_max_debt asc