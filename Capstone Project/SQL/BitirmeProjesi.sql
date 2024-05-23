/*Case1: Sipariş Analizi*/

/*1-) Order_date'e göre toplam sipariş sayısını gösterme*/
select * from orders
select * from order_details

SELECT TO_CHAR(order_date, 'YYYY-MM') AS year_and_month,
       COUNT(order_id) AS order_count
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY year_and_month ASC;

/*2-)Erken teslim edilmesi gereken sipariş sayılarını analiz etme*/
/*Önceliği olan sipariş sayılarının miktarları*/
/*Sipariş önceliği (required_date-order_date) kullanılarak hesaplanabilir*/
/*Teslim süreleri 14,28,42 gün olacak şekilde belirlenmiştir.*/
/*Teslim sürelerine göre order_count sayıları belirlenmiş ve sipariş öncelikleri
'Emergency','Priority','Standard' olarak kategorize edilmiştir. */

WITH required_delivery_time_day AS
(
SELECT 
	order_id,
    order_date, 
    required_date,
    required_date - order_date AS required_delivery_time
FROM orders
)select 
	required_delivery_time,
	count(order_id) as order_count,
	CASE
		WHEN required_delivery_time = '14' THEN 'Emergency'
		WHEN required_delivery_time = '28' THEN 'Priority'
		WHEN required_delivery_time = '42' THEN 'Standard'
	END as order_priority_level
from required_delivery_time_day
group by(required_delivery_time)
order by required_delivery_time ASC


/*3-)En çok haftanın hangi günlerinde sipariş verilmiş.*/
/*Haftanın günlerine göre toplam sipariş sayısı(Sunday,monday,tuesday,wednesday,thursday,
friday,saturday*/

Select 
	TO_CHAR(order_date, 'Dy') AS day_of_week,
    COUNT(order_id) AS order_count
from orders
Group by day_of_week
ORDER BY order_count DESC

/*4-)Mevsimsel olarak sipariş sayıları nasıl değişiyor?*/
/*Spring/Summer/Autumn/Winter*/

WITH mountly_order_count AS (
select 
	TO_CHAR(order_date,'MM') AS month_of_year,
	count(order_id) as order_count
from orders
group by (month_of_year)
) SELECT 
    SUM(order_count) as sum_order,
    CASE
        WHEN month_of_year IN ('12','01','02') THEN 'Winter'
        WHEN month_of_year IN ('03','04','05') THEN 'Spring'
        WHEN month_of_year IN ('06','07','08') THEN 'Summer'
        WHEN month_of_year IN ('09','10','11') THEN 'Autumn'
    END AS season_name
FROM mountly_order_count
GROUP BY season_name
ORDER BY sum_order

/*5-)Sipariş başına ortalama ürün miktarını bulma.*/
select * from orders
select * from order_details

Select
	o.order_id,
	ROUND(AVG(od.product_id)::numeric, 2) as avg_product
FROM orders o join order_details od 
ON o.order_id = od.order_id
GROUP BY 1
ORDER BY avg_product desc

/*6-)Siparişlerin ulaştırılma durumunu (delivered on time,delayed,waiting) analiz etme.*/
/*Shiped_date NULL olanlar bekleyen kategorisnde olacak*/
/*Shiped_date required date'den büyük olanlar gecikmiş kategorisinde olacak*/
/*Shiped_date required date'e eşit olanlar gecikmiş kategorisinde olacak*/
/*Shiped_date required date'ten küçük olanlar vaktinde yola çıkmış demektir*/
Select 
	count(order_id) as order_count,
	CASE 
		WHEN shipped_date = required_date THEN 'delayed'
		WHEN shipped_date > required_date THEN 'delayed'
		WHEN shipped_date IS NULL THEN 'waiting'
		ELSE 'left on time'
	END as deliver_status
from orders
group by (deliver_status)

/*CASE2: Müşteri Analizi*/

/*1-) En çok sipariş sayısına sahip ilk 10 müşteri*/
select * from orders
select * from customers

Select 
	count(o.order_id) as order_count,
	c.customer_id,
	c.company_name
from orders o join customers c
on o.customer_id = c.customer_id
group by c.customer_id
order by order_count desc
limit 10

/*2-) Şehir, bölge ve ülkelere göre müşteri sayısını analiz etme*/
/* En çok müşteri sayısına sahip ilk 10 ülke, şehir ve bölge*/

select * from customers
/*City kırılımında müşteri sayısı*/
select 
	count(customer_id) as customer_count,
	city
from customers
group by city
order by customer_count desc
limit 10

/*Country kırılımında müşteri sayısı*/
select 
	count(customer_id) as customer_count,
	country
from customers
group by country
order by customer_count desc
limit 10

/*Region kırılımında müşteri sayısı*/
select 
	count(customer_id) as customer_count,
	region
from customers
group by region
order by customer_count desc
limit 10

/*3-) Sipariş tutarı en fazla olan ilk 10 müşteri*/
select * from orders
select * from order_details
select * from customers

SELECT 
    c.customer_id,
    c.company_name,
    ROUND(SUM(CASE WHEN od.discount = 0 THEN od.unit_price * od.quantity ELSE (od.unit_price * od.quantity) * (1 - od.discount / 100) END)::NUMERIC, 2) AS total_order_amount
FROM 
    order_details od 
JOIN 
    orders o ON od.order_id = o.order_id
JOIN 
    customers c ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, c.company_name
ORDER BY 
    total_order_amount DESC
LIMIT 10;


/*4-) Sipariş tutarı en fazla olan ilk 10 müşterinin contact_name'lerinin, telefonlarının ve 
contact_title'larının bir listesini getir*/

WITH most_order_amount_10 as 
(
SELECT 
    c.customer_id,
    c.company_name,
    ROUND(SUM(CASE WHEN od.discount = 0 THEN od.unit_price * od.quantity ELSE (od.unit_price * od.quantity) * (1 - od.discount / 100) END)::NUMERIC, 2) AS total_order_amount
FROM 
    order_details od 
JOIN 
    orders o ON od.order_id = o.order_id
JOIN 
    customers c ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, c.company_name
ORDER BY 
    total_order_amount DESC
LIMIT 10
) select 
	moa.customer_id,
	moa.company_name,
	c.contact_name,
	c.contact_title,
	c.phone
  from most_order_amount_10 moa join customers c
  ON moa.customer_id = c.customer_id

/*5-) Ürün kategorilerine göre müşteri sayılarını getir*/
select * from customers
select * from products
select * from orders
select * from order_details
select * from categories

SELECT 
    ct.category_name,
    ct.description,
    COUNT(c.customer_id) AS customer_count
FROM 
    customers c 
JOIN 
    orders o ON c.customer_id = o.customer_id
JOIN 
    order_details od ON od.order_id = o.order_id
JOIN 
    products p ON p.product_id = od.product_id
JOIN 
    categories ct ON ct.category_id = p.category_id
GROUP BY 
    ct.category_name, ct.description
ORDER BY 
    customer_count DESC;


/*CASE3: Ürün Analizi*/
select * from products
select * from order_details
select * from orders
select * from categories

/*1-) En çok sipariş edilen ilk 10 ürünü getir (Satışı devam eden ürünler baz alınmıştır)*/

select 
	count(o.order_id) as order_count,
	p.product_name
from orders o JOIN order_details od
ON o.order_id=od.order_id
JOIN products p ON p.product_id = od.product_id
WHERE p.discontinued = 0
GROUP BY p.product_name
ORDER BY order_count DESC 
LIMIT 10

/*2-) Ürünlerin kategori bazında sayılarını getir*/
select 
	c.category_id,
	c.category_name,
	count(product_id) as product_count
from products p JOIN categories c
ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY product_count DESC

/*3-) Satışı devam eden ve satışı durudurulan ürün sayısı*/
Select 
	count(product_id) as product_count,
	CASE
		WHEN discontinued = 1 THEN 'sale stopped'
		WHEN discontinued = 0 THEN 'sale continued'
	END as satis_var_yok
from products
Group by satis_var_yok



/*4-) Ürünlerin stok durumunu analiz etme*/
/*EN çok satılan ilk 10 ürünün ortalama sipariş sayıları yıllık olarak incelenmiştir*/
/*En çok satılan ilk 10 ürünün stok sayıları incelenmiştir*/
/*Bu analizin devamı python'da yapılacaktır.*/
select * from products

/*En çok sipariş edilen 10 ürünün yıllık olarak ortalama sipariş sayısı*/
WITH most_sold_10_product AS(
select 
	count(o.order_id) as order_count,
	p.product_name,
	p.product_id
from orders o JOIN order_details od
ON o.order_id=od.order_id
JOIN products p ON p.product_id = od.product_id
WHERE p.discontinued = 0
GROUP BY p.product_name, p.product_id
ORDER BY order_count DESC 
LIMIT 10
), average_orders AS (
    SELECT 
        p.product_id,
        TO_CHAR(o.order_date, 'YYYY') AS order_year,
        ROUND(AVG(COUNT(o.order_id)) OVER(PARTITION BY TO_CHAR(o.order_date, 'YYYY'), p.product_id)::Numeric,2) AS avg_order_count
    FROM 
        orders o
    JOIN 
        order_details od ON o.order_id = od.order_id
    JOIN 
        products p ON p.product_id = od.product_id
    WHERE 
        p.product_id IN (SELECT product_id FROM most_sold_10_product)
    GROUP BY 
        TO_CHAR(o.order_date, 'YYYY'), p.product_id
)
SELECT 
    asp.product_id,
    asp.product_name,
    asp.order_count,
    ao.order_year,
    ao.avg_order_count
FROM 
    most_sold_10_product asp
JOIN 
    average_orders ao ON asp.product_id = ao.product_id
ORDER BY 
    asp.order_count DESC, ao.order_year;
	
/*En çok sipariş edilen ilk 10 ürünün stok sayısı*/
WITH most_sold_10_product AS(
select 
	count(o.order_id) as order_count,
	p.product_name,
	p.product_id
from orders o JOIN order_details od
ON o.order_id=od.order_id
JOIN products p ON p.product_id = od.product_id
WHERE p.discontinued = 0
GROUP BY p.product_name, p.product_id
ORDER BY order_count DESC 
LIMIT 10
)select 
	product_id,
	product_name,
	unit_in_stock
 from products
 WHERE product_id IN (SELECT product_id from most_sold_10_product)
 group by product_id, product_name


/*5-)Hangi ürünlerin birim fiyatı artmıştır.*/
WITH cte_price AS (
SELECT
	od.product_id,
	p.product_name,
	ROUND(LEAD(od.unit_price) OVER (PARTITION BY p.product_name ORDER BY o.order_date)::NUMERIC,2) AS current_price,
	ROUND(LAG(od.unit_price) OVER (PARTITION BY p.product_name ORDER BY o.order_date)::NUMERIC,2) AS previous_unit_price
FROM products AS p
INNER JOIN order_details AS od
ON p.product_id = od.product_id
INNER JOIN orders AS o
ON od.order_id = o.order_id
)
SELECT
	c.product_name,
	c.current_price,
	c.previous_unit_price,
	ROUND(100*(c.current_price - c.previous_unit_price)/c.previous_unit_price) AS percentage_increase
FROM cte_price AS c
WHERE c.current_price != c.previous_unit_price
GROUP BY 
	c.product_name,
	c.current_price,
	c.previous_unit_price
	
/*6-)-- Ürün Ekibi, şirket fiyatlandırma stratejisine ilişkin yıllık incelemeleri şu anki ürünlerin fiyatlarını ve hangi fiyat aralığında kaç ürün olduğunu görmek istiyor.

-- Onlara yardımcı olmak için sizden aşağıdaki bilgileri içeren bir ürün listesi vermenizi istediler:
-- 1. Ürün Adı
-- 2. Birim Fiyatı
-- 3. Hangi fiyat aralığında olduğu
-- 4. İlgili fiyat aralığında kaç tane ürünümüz var
*/

WITH DATA AS (
        SELECT product_name,
               unit_price,
               CASE WHEN unit_price < 10                  THEN '0-10'
                    WHEN unit_price >= 10 AND unit_price < 20  THEN '10-20'
                    WHEN unit_price >= 20 AND unit_price < 30  THEN '20-30'
                    WHEN unit_price >= 30 AND unit_price < 40  THEN '30-40'
                    WHEN unit_price >= 40 AND unit_price < 50  THEN '40-50'
                    WHEN unit_price >= 50 AND unit_price < 60  THEN '50-60'
                    WHEN unit_price >= 60 AND unit_price < 70  THEN '60-70'
                    WHEN unit_price >= 70 AND unit_price < 80  THEN '70-80'
                    WHEN unit_price >= 80 AND unit_price < 90  THEN '80-90'
                    WHEN unit_price >= 90 AND unit_price < 100 THEN '90-100'
                    WHEN unit_price >= 100                THEN '100+'
               END AS price_segment
          FROM products
       ) 
  SELECT 
       product_name,
       unit_price,
       price_segment,
       count(product_name) OVER (PARTITION BY price_segment) AS segment_product_count
  FROM DATA ;

/*7-)Her bir ürün kategorisi için bölgesel tedarikçilerimizin stoklarının mevcut durumu nedir?*/
SELECT
	c.category_name,
	CASE
		WHEN s.country IN ('Australia', 'Singapore', 'Japan' ) THEN 'Asia-Pacific'
		WHEN s.country IN ('US', 'Brazil', 'Canada') THEN 'America'
		ELSE 'Europe'
	END AS supplier_region,
	p.unit_in_stock AS units_in_stock,
	p.unit_on_order AS units_on_order,
	p.reorder_level 
FROM suppliers AS s
INNER JOIN products AS p
ON s.supplier_id = p.supplier_id
INNER JOIN categories AS c
ON p.category_id = c.category_id
WHERE s.region IS NOT NULL
ORDER BY 
	supplier_region,
	c.category_name,
	p.unit_price;

/*CASE4: Shipper Analizi*/
select * from shippers
select * from orders

select distinct(ship_via) from orders/*orders tablosunda aktif olan sadece 3 shipper firması var*/

/*1-) Shippers 1998 yılı için hangi ülkelerde kötü performans gösteriyor?
Gönderim süresi olarak order_date ile shipped_date farkı alınmıştır
Eğer sipariş sayısı 10'un üstündeyse ve gönderim süresi 5 veya daha fazla günse
performans düşük kabul edilmiştir*/
WITH cte_avg_days AS (
	SELECT
		ship_country,
		ROUND(AVG(EXTRACT(DAY FROM (shipped_date - order_date) * INTERVAL '1 DAY'))::NUMERIC,2) AS average_days_between_order_shipping,
		COUNT(*) AS total_number_orders
	FROM orders
	WHERE EXTRACT(YEAR FROM order_date) = 1998
	GROUP BY 
		ship_country
	ORDER BY ship_country
	)
SELECT * FROM cte_avg_days
WHERE average_days_between_order_shipping >= 5
AND total_number_orders > 10;

/*2-) Nakliyeci başına toplam sipariş sayısı*/
select 
	ship_name,
	COUNT(order_id) as order_count
from orders
Group by 1
order by 2 desc

/*3-) Nakliyeci başına ortalama yük hesaplama*/
select 
	ship_name,
	ROUND(AVG(freight)::NUMERIC,2) as avg_freight
from orders
Group by 1
order by 2 desc

/*4-) Nakliyecilerin coğrafi dağılımını analiz etme*/
select * from orders

/*city kırılımında nakliyeci firma sayısı*/
select 
	o.ship_city,
	COUNT(DISTINCT s.shipper_id) as shipper_count
from shippers s join orders o
on s.shipper_id=o.ship_via
group by 1
order by 2 desc

select ship_city,ship_via from orders where ship_city='Rio de Janeiro'

/*country kırılımında nakliyeci firma sayısı*/
select 
	o.ship_country,
	COUNT(DISTINCT s.shipper_id) as shipper_count
from shippers s join orders o
on s.shipper_id=o.ship_via
group by 1
order by 2 desc

/*region kırılımında nakliyeci firma sayısı*/
select 
	o.ship_region,
	COUNT(DISTINCT s.shipper_id) as shipper_count
from shippers s join orders o
on s.shipper_id=o.ship_via
group by 1
order by 2 desc

/*Her shipper_company'de aktif olan kaç ship var*/
WITH ship_via_with_ship_count AS (
select 
	ship_via,
	COUNT(DISTINCT ship_name) as ship_count
from orders
group by 1
order by 2 desc
) select 
	s.company_name,
	sc.ship_count
from ship_via_with_ship_count sc join shippers s
on sc.ship_via = s.shipper_id

/*CASE5: Supplier Analizi*/
select * from suppliers
select * from products
select * from order_details
select * from orders

/*1-) Tedarikçilerin coğrafi dağılımlarını analiz etme*/

/*Country kırılımında tedarikçi sayısı*/
Select 
	country,
	count(supplier_id) as supplier_count
from suppliers
group by country

/*Region kırılımında tedarikçi sayısı*/
Select 
	region,
	count(supplier_id) as supplier_count
from suppliers
group by region

/*2-)Ürün kategorilerine göre tedarikçi sayısı hesabı*/

WITH categories_suppliers_count AS
(
select 
	p.category_id,
	count(p.supplier_id) as supplier_count
from
suppliers s join products p
on s.supplier_id = p.supplier_id
group by p.category_id
) select 
		csc.category_id,
		c.category_name,
		csc.supplier_count
	from 
	categories_suppliers_count csc join categories c
	ON csc.category_id = c.category_id

/*3-) En çok sipariş alan ilk 10 tedarikçiyi belirleme*/

WITH suppliers_with_ordercount AS (
select 
	s.supplier_id,
	count(o.order_id) as order_count
from suppliers s join products p
on s.supplier_id = p.supplier_id
join order_details od on od.product_id = p.product_id
join orders o on o.order_id = od.order_id
group by s.supplier_id
order by order_count desc
limit 10
) select 
	s.company_name,
	swo.order_count
from suppliers_with_ordercount swo join suppliers s
on swo.supplier_id = s.supplier_id

/*4-) Her bir kategoride en hızlı teslimat süresine sahip tedarikçileri analiz etmek*/

WITH fast_supplier AS (
select 
	s.supplier_id,
	p.category_id,
	MIN(o.shipped_date - o.order_date) AS min_delivery_days
from suppliers s join products p
on s.supplier_id = p.supplier_id
join order_details od on od.product_id = p.product_id
join orders o on o.order_id = od.order_id
WHERE o.shipped_date IS NOT NULL
group by 1, 2
order by 3
) select 
		s.company_name,
		c.category_name,
		fs.min_delivery_days
	from fast_supplier fs join suppliers s 
	on fs.supplier_id = s.supplier_id
	join categories c on c.category_id=fs.category_id
	

/*5-) Her bir tedarikçiden yapılan toplam harcamalar incelenerek işletmenin en çok para 
harcadığı tedarikçiler listelenir*/
select 
	s.supplier_id,
	s.company_name,
	ROUND(SUM(CASE WHEN od.discount = 0 THEN od.unit_price * od.quantity ELSE (od.unit_price * od.quantity) * (1 - od.discount / 100) END)::NUMERIC, 2) as amount
from suppliers s join products p
on s.supplier_id = p.supplier_id
join order_details od on od.product_id=p.product_id
Group by 1,2
order by 3 desc
limit 10


/*6-) En çok siparişe sahip ilk 10 tedarikçinin yıllık maliyet analizi*/

WITH suppliers_with_ordercount AS (
    SELECT 
        s.supplier_id,
        s.company_name,
        COUNT(o.order_id) AS order_count
    FROM 
        suppliers s 
    JOIN 
        products p ON s.supplier_id = p.supplier_id
    JOIN 
        order_details od ON od.product_id = p.product_id
    JOIN 
        orders o ON o.order_id = od.order_id
    GROUP BY 
        s.supplier_id, s.company_name
    ORDER BY 
        order_count DESC
    LIMIT 10
),supplier_sales AS (
    SELECT 
        s.company_name,
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        ROUND(SUM(CASE WHEN od.discount = 0 THEN od.unit_price * od.quantity ELSE (od.unit_price * od.quantity) * (1 - od.discount / 100) END)::NUMERIC, 2) AS total_price
    FROM 
        suppliers s 
    JOIN 
        products p ON s.supplier_id = p.supplier_id
    JOIN 
        order_details od ON od.product_id = p.product_id
    JOIN 
        orders o ON o.order_id = od.order_id
    WHERE 
        s.company_name IN (SELECT company_name FROM suppliers_with_ordercount)
    GROUP BY 
        s.company_name, order_year
)
SELECT 
    company_name,
    order_year,
    total_price
FROM 
    supplier_sales

/*CASE6: Employee Analizi*/
select * from employees
select * from employeeterritories
select * from territories
select * from orders
select * from order_details
select * from products

/*1998 yılı için bazı çalışanlara prim verilecektir. Çalışanların performansı analiz edilcektir.
Bunun için aşağıdaki metrikler değerlendirilir*/

/*1-)En çok sipariş işleyen çalışanlar*/
WITH employee_with_ordercount AS (
select 
	e.employee_id,
	count(order_id) as order_count
from employees e join orders o
on e.employee_id = o.employee_id
WHERE TO_CHAR(order_date, 'YYYY') = '1998'
group by 1
order by 2 desc
) select 
	e.first_name,
	e.last_name,
	e.title,
	eo.order_count
from employee_with_ordercount eo join employees e
on eo.employee_id = e.employee_id
order by 4 desc


/*2-)Tedarikçiden en yüksek indirim oranını alan çalışanlar*/
WITH employee_with_discount AS 
(
select 
	e.employee_id,
	ROUND(SUM(od.discount)::NUMERIC,2) as total_discount
from employees e join orders o 
on e.employee_id = o.employee_id
join order_details od on od.order_id = o.order_id
WHERE TO_CHAR(order_date, 'YYYY') = '1998'
GROUP BY 1
ORDER BY 2 DESC
) select 
	e.first_name,
	e.last_name,
	e.title,
	ed.total_discount
from employee_with_discount ed join employees e
on ed.employee_id = e.employee_id
order by 4 desc


/*3-)Her bir çalışanın kaç bölgesi var?*/
select * from employees
select * from employeeterritories

WITH employees_with_territory AS (
select 
	e.employee_id,
	count(et.territory_id) as territory_count
from 
employees e join employeeterritories et
on e.employee_id = et.employee_id
group by 1
order by 2 desc
) select 
	e.first_name,
	e.last_name,
	e.title,
	et.territory_count
from employees_with_territory et
join employees e on e.employee_id = et.employee_id
ORDER BY 4 desc

/*3-)Çalışanların kaçar müşterisi var*/
select * from employees
select * from orders

WITH employees_with_cystomercount AS (
select 
	e.employee_id,
	COUNT(o.customer_id) as customer_count
from employees e join orders o
on e.employee_id = o.employee_id
WHERE TO_CHAR(order_date, 'YYYY') = '1998'
GROUP BY 1
ORDER BY 2 desc
) select 
	e.first_name,
	e.last_name,
	e.title,
	ec.customer_count
from employees_with_cystomercount ec 
join employees e on ec.employee_id = e.employee_id
order by 4 desc

/*4-)Çalışanların 1997 yılına göre işlediği sipariş sayısı yüzde kaç artmıştır?*/
WITH employee_order_counts AS (
    SELECT 
        e.employee_id,
        TO_CHAR(o.order_date, 'YYYY') AS order_year,
        COUNT(o.order_id) AS order_count
    FROM 
        employees e
    JOIN 
        orders o ON e.employee_id = o.employee_id
    GROUP BY 
        e.employee_id, TO_CHAR(o.order_date, 'YYYY')
)
SELECT 
	e.first_name,
	e.last_name,
	e.title,
    e1.order_count AS order_count_1997,
    e2.order_count AS order_count_1998,
    ROUND(((e2.order_count - e1.order_count) / e1.order_count) * 100, 2) AS percentage_change
FROM 
    (SELECT * FROM employee_order_counts WHERE order_year = '1997') AS e1
JOIN 
    (SELECT * FROM employee_order_counts WHERE order_year = '1998') AS e2
ON 
    e1.employee_id = e2.employee_id
	join employees e on e2.employee_id=e.employee_id
ORDER BY 
    percentage_change DESC;

/*5-)Çalışanların 1996 yılına göre işlediği sipariş sayısı yüzde kaç artmıştır?*/
WITH employee_order_counts AS (
    SELECT 
        e.employee_id,
        TO_CHAR(o.order_date, 'YYYY') AS order_year,
        COUNT(o.order_id) AS order_count
    FROM 
        employees e
    JOIN 
        orders o ON e.employee_id = o.employee_id
    GROUP BY 
        e.employee_id, TO_CHAR(o.order_date, 'YYYY')
)
SELECT 
	e.first_name,
	e.last_name,
	e.title,
    e1.order_count AS order_count_1997,
    e2.order_count AS order_count_1998,
    ROUND(((e2.order_count - e1.order_count) / e1.order_count) * 100, 2) AS percentage_change
FROM 
    (SELECT * FROM employee_order_counts WHERE order_year = '1996') AS e1
JOIN 
    (SELECT * FROM employee_order_counts WHERE order_year = '1998') AS e2
ON 
    e1.employee_id = e2.employee_id
	join employees e on e2.employee_id=e.employee_id
ORDER BY 
    percentage_change DESC;
	
/*6-)En çok satış maliyetine sahip çalışanlar*/
WITH customer_with_totalprice AS (
select 
	e.employee_id,
	ROUND(SUM(CASE WHEN od.discount = 0 THEN od.unit_price * od.quantity ELSE (od.unit_price * od.quantity) * (1 - od.discount / 100) END)::NUMERIC, 2) AS total_price
from employees e join orders o
on e.employee_id = o.employee_id
join order_details od on od.order_id = o.order_id
WHERE TO_CHAR(order_date, 'YYYY') = '1998'
GROUP BY 1
ORDER BY 2 DESC
)select 
	e.first_name,
	e.last_name,
	e.title,
	ct.total_price
from customer_with_totalprice ct 
join employees e on ct.employee_id = e.employee_id
order by 4 desc

/*7-)Çalışanların kıdem sıralaması
En kıdemli "Janet Leverling"*/
select 
	first_name,
	last_name,
	title,
	hire_date
from employees
order by 4

/*8-)Çalışanların yaş sıralaması büyükten küçüğe doğru
En yaşlı "Margaret Peacock"*/
select 
	first_name,
	last_name,
	title,
	birth_date
from employees
order by 4

/*9-) Her bir çalışan kime rapor veriyor?*/
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_full_name,
	e.title AS employee_title,
	CONCAT(e2.first_name, ' ', e2.last_name) AS manager_full_name,
	e2.title AS manager_title
FROM
    employees e
INNER JOIN employees e2 
ON e2.employee_id = e.reports_to

/*CASE7:Stok Analizi*/
select * from orders
select * from order_details
select * from products
/*Yeniden sipariş seviyesinin altında kalan stock sayıları için sipariş verilmiş mi?*/
/*Verilmemişse kritik olarak kategorilendir.
Verilmiş ancak gene de reorder_level altındaysa yetersiz olarak kategorilendir
ELSE Uygun olarak kategorilendir*/
SELECT 
    product_id,
    category_id,
    unit_in_stock,
    reorder_level,
    unit_on_order,
    CASE
        WHEN unit_on_order = 0 THEN 'Kritik Durum!'
        WHEN unit_on_order + unit_in_stock < reorder_level THEN 'Yetersiz'
        ELSE 'Uygun'
    END AS stock_status
FROM 
    products
WHERE 
    unit_in_stock < reorder_level;
	
/*Stok durumu kritik ve yetersiz olan ürün adlarını ve kategori_adlarını getir.*/
WITH stock_status AS(
SELECT 
    product_name,
    category_id,
    unit_in_stock,
    reorder_level,
    unit_on_order,
    CASE
        WHEN unit_on_order = 0 THEN 'Kritik Durum!'
        WHEN unit_on_order + unit_in_stock < reorder_level THEN 'Yetersiz'
        ELSE 'Uygun'
    END AS stock_status
FROM 
    products
WHERE 
    unit_in_stock < reorder_level
)select 
	product_name,
    c.category_name,
    unit_in_stock,
    reorder_level,
    unit_on_order,
	stock_status
from stock_status ss join categories c
on ss.category_id = c.category_id
where stock_status = 'Kritik Durum!' OR stock_status = 'Yetersiz'


/*CASE 8: RFM Analizi (Bunu python'da yapalım)*/
select count(*) from orders
select distinct(customer_id) from orders


/*recency*/
WITH last_order_date AS (
select
	customer_id,
	max(order_date)::date as last_order_date
from orders
group by 1
order by 2
) select 
	customer_id,
	(select max(order_date)::date from orders)::date - last_order_date as recency
from last_order_date
where (select max(order_date)::date from orders)::date - last_order_date != 0

/*frequency*/
select 
	customer_id,
	count(order_id) as frequency
from orders
group by 1
order by 2


/*monetary*/
WITH monetary_values AS (
select 
	customer_id,
	unit_price,
	quantity
from orders o join order_details od
on o.order_id = od.order_id
order by 2
)select 
	customer_id,
	round(sum(unit_price*quantity)::numeric,2) as monetary
  from monetary_values
  group by 1
  order by 2

/*rfm birleştir*/
WITH RFM_Analyse AS (
WITH RFM_with_scores AS (
WITH recency AS (
WITH last_order_date AS (
select
	customer_id,
	max(order_date)::date as last_order_date
from orders
group by 1
order by 2
) select 
	customer_id,
	(select max(order_date)::date from orders)::date - last_order_date as recency
from last_order_date
where (select max(order_date)::date from orders)::date - last_order_date != 0
), frequency AS (
select 
	customer_id,
	count(order_id) as frequency
from orders
group by 1
order by 2
), monetary AS (
WITH monetary_values AS (
select 
	customer_id,
	unit_price,
	quantity
from orders o join order_details od
on o.order_id = od.order_id
order by 2
)select 
	customer_id,
	round(sum(unit_price*quantity)::numeric,2) as monetary
  from monetary_values
  group by 1
  order by 2
) select 
	r.customer_id,
	recency,
	CASE
		WHEN recency>=1 AND recency<26 THEN '3'
		WHEN recency>=26 AND recency<90 THEN '2'
		ELSE '1'
	END as recency_score,
	frequency,
	CASE
		WHEN frequency>=1 AND frequency<5 THEN '1'
		WHEN frequency>=5 AND frequency<12 THEN '2'
		ELSE '3'
	END as frequency_score,
	monetary,
	CASE
		WHEN monetary>=100 AND monetary<20000 THEN '1'
		WHEN monetary>=20000 AND monetary<58000 THEN '2'
		ELSE '3'
	END as monetary_score
from recency r join frequency f
on r.customer_id = f.customer_id join monetary m
on m.customer_id = f.customer_id
) select 
	customer_id,
	recency,
	recency_score,
	frequency,
	frequency_score,
	monetary,
	monetary_score,
	recency_score || ' ' || frequency_score || ' ' || monetary_score as rfm_score
	from RFM_with_scores 
) select 
	customer_id,
	recency,
	frequency,
	monetary,
	rfm_score
from RFM_Analyse









