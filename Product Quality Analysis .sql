-- Pendapatan perusahaan 
create table company_revenues as(
	select 
		extract(Year from o.order_purchase_timestamp) as Year,
		sum(price + freight_value) as com_revenue
	from orders_dataset o 
	join order_items_dataset oi 
	on oi.order_id = o.order_id
	where order_status ='delivered'
	group by 1
	order by 1,2
);

-- Total cancel pertahun
create table cancel_peryear as(
	select 
			extract(Year from o.order_approved_at) as Year,
			count(order_status) as total_cancel_peryear
		from orders_dataset o 
			join order_items_dataset oi 
			on oi.order_id = o.order_id
		where order_status ='canceled'
		group by 1
		order by 1
);

-- Kategori terbaik (rank)
create table the_best_kategori as(
select 
	 Year,
	 product_terbaik,
	 revenue_top_product,
	 top_rank 
from (
		select 
				extract (year from shipping_limit_date) as Year,
						product_category_name as product_terbaik,
					sum (price + freight_value) as revenue_top_product, 
				RANK() OVER (PARTITION BY EXTRACT(YEAR FROM shipping_limit_date) 
							 ORDER BY SUM(price + freight_value)desc) AS top_rank
		from product_dataset pd
			join order_items_dataset oi
				on pd.product_id = oi.product_id
			join orders_dataset o 
				on oi.order_id = o.order_id
			where order_status ='delivered'
				group by 1,2
				order by 1,2) as tmp
	where top_rank =1
	order by 1, 4 asc
);
-- Kategori terburuk (rank)
create table the_bad_categori as(
select 
	Year,
	kategori_produk,
	total_cancel,
	rank_cancel
from 
  (
	select 
			EXTRACT(YEAR FROM od.order_approved_at) as Year, 
					pd.product_category_name as kategori_produk,
					count(order_status) as total_cancel,
				rank() over (PARTITION BY EXTRACT(YEAR FROM od.order_approved_at) 
						 ORDER BY count(order_status)desc) AS rank_cancel
			from orders_dataset od
				join order_items_dataset oi
					on od.order_id = oi.order_id
				join product_dataset pd
					on oi.product_id = pd.product_id
				where order_status = 'canceled'
				group by 1,2
				order by 1
) as tmp
				where rank_cancel = 1
);

		
-- mengabungkan insight dari semua tabel 
select 
	tbk.Year,
	cr.com_revenue,
	cp.total_cancel_peryear,
	tbk.product_terbaik,
	tbk.revenue_top_product,
	tbc.kategori_produk,
	tbc.total_cancel
from company_revenues cr
FULL JOIN cancel_peryear cp ON cr.Year = cp.Year
FULL JOIN the_best_kategori tbk ON cp.Year = tbk.Year
FULL JOIN the_bad_categori tbc ON tbk.Year = tbc.Year;




