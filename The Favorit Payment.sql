-- Favorite Payment type
select
	payment_type,
	count(1) as jumlah
from order_payments_dataset
group by 1
order by 2 desc;


-- Detail Payment Type
select
	payment_type,
	sum (case when Year = 2016 then jumlah else 0 end) as total_2016,
	sum (case when Year = 2017 then jumlah else 0 end) as total_2017,
	sum (case when Year = 2018 then jumlah else 0 end) as total_2018,
	sum (jumlah) as Total
	from
(	
	select 
	extract (year from od.order_purchase_timestamp) as Year,
	od.order_status,
	opd.payment_type,
	count(*) as jumlah
from orders_dataset od
join order_payments_dataset opd on od.order_id = opd.order_id
group by 1,2,3
order by 4 desc) tmp
group by 1 
order by 1


