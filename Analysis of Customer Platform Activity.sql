-- rata-rata jumlah customer aktif perbulan setiap tahun
select
	Year,
	floor(AVG(Active_customer)) as average_customer
	from
( 
	select 
		extract ( Year from o.order_purchase_timestamp) as Year,
		extract ( Month from o.order_purchase_timestamp ) as Month,
		count(distinct cd.customer_id) as Active_Customer
	from orders_dataset o
	join customers_dataset cd 
	on o.customer_id = cd.customer_id
		group by 1,2
		order by 1,2
) tmp
group by 1

-- jumlah customer baru pertahun
select 
	Year,
	count(customer_unique_id) as total_purchases
	from
(
	select 
		cd.customer_unique_id,
		extract ( Year from Min (o.order_purchase_timestamp)) as Year
	from orders_dataset o
	join customers_dataset cd
	on o.customer_id = cd.customer_id
		group by 1
) tmp
group by 1;


--jumlah customer yang melakukan pembelian lebih dari satu kali
select 
	Year,
	count(customer_unique_id) as Total
from
(
	select 
		extract(Year from o.order_purchase_timestamp) as Year,
		cd.customer_unique_id,
		count(o.order_id) as repeat_order
	from orders_dataset o
	join customers_dataset cd
	on o.customer_id = cd.customer_id
		group by 1,2
		having count(o.order_id) >1
) tmp
group by 1

-- Menampilkan rata-rata jumlah order yang dilakukan customer untuk masing-masing tahun
select 
	Year,
	avg (jumlah_order) as avg_order
from
(
	select 
		extract (Year from o.order_purchase_timestamp) as Year,
		count(o.order_id) as jumlah_order,
		cd.customer_unique_id
	from orders_dataset o
	join customers_dataset cd
	on o.customer_id = cd.customer_id
		group by 1,3
		order by 1,3
)tmp
group by 1



--Menggabungkan keempat metrik yang telah berhasil ditampilkan menjadi satu tampilan tabel
WITH rjc AS (
    SELECT
        Year,
        FLOOR(AVG(Active_customer)) AS average_customer
    FROM
        (
            SELECT
                EXTRACT(YEAR FROM o.order_purchase_timestamp) AS Year,
                EXTRACT(MONTH FROM o.order_purchase_timestamp) AS Month,
                COUNT(DISTINCT cd.customer_id) AS Active_Customer
            FROM
                orders_dataset o
            JOIN
                customers_dataset cd ON o.customer_id = cd.customer_id
            GROUP BY
                1, 2
            ORDER BY
                1, 2
        ) tmp
    GROUP BY
        1
),
jcb AS (
    SELECT
        Year,
        COUNT(customer_unique_id) AS total_purchases
    FROM
        (
            SELECT
                cd.customer_unique_id,
                EXTRACT(YEAR FROM MIN(o.order_purchase_timestamp)) AS Year
            FROM
                orders_dataset o
            JOIN
                customers_dataset cd ON o.customer_id = cd.customer_id
            GROUP BY
                1
        ) tmp
    GROUP BY
        1
),
jcp AS (
    SELECT
        Year,
        COUNT(customer_unique_id) AS Total
    FROM
        (
            SELECT
                EXTRACT(YEAR FROM o.order_purchase_timestamp) AS Year,
                cd.customer_unique_id,
                COUNT(o.order_id) AS repeat_order
            FROM
                orders_dataset o
            JOIN
                customers_dataset cd ON o.customer_id = cd.customer_id
            GROUP BY
                1, 2
            HAVING
                COUNT(o.order_id) > 1
        ) tmp
    GROUP BY
        1
),
rjo AS (
    SELECT
        Year,
        AVG(jumlah_order) AS avg_order
    FROM
        (
            SELECT
                EXTRACT(YEAR FROM o.order_purchase_timestamp) AS Year,
                COUNT(o.order_id) AS jumlah_order,
                cd.customer_unique_id
            FROM
                orders_dataset o
            JOIN
                customers_dataset cd ON o.customer_id = cd.customer_id
            GROUP BY
                1, 3
            ORDER BY
                1, 3
        ) tmp
    GROUP BY
        1
)
SELECT
    rjc.Year AS Year,
    rjc.average_customer AS Monthly_Active_User,
    jcb.total_purchases AS Customer_Baru_Pertahun,
    jcp.Total AS Total_Repeat_Order_pertahun,
    rjo.avg_order AS Frekuensi_Order_Pertahun
FROM
    rjc
JOIN
    jcb ON rjc.year = jcb.year
JOIN
    jcp ON jcb.year = jcp.year
JOIN
    rjo ON jcp.year = rjo.year;


SELECT usename AS username, client_addr AS host, client_port AS port, datname AS database_name
FROM pg_stat_activity
WHERE pid = pg_backend_pid();

ALTER USER postgres WITH PASSWORD '123457';




