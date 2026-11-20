-- EDA

SELECT 
	table_name,
	column_name,
	constraint_name 
FROM information_schema.key_column_usage kcu 
WHERE table_schema = 'afisha'
ORDER BY table_name

/* City table:
 * city_id is a primary key for the 'city' table.
 * region_id is the foreign key from the 'regions' table.
 * 
 * Events table
 * event_id is a primary key for the 'events' table.
 * venue_id and city_id are foreign keys from 'venues' and 'city'. 
 * 
 * Purchases table:
 * order_id is a primary key
 * event_id is a foreign key, it has 2 different names, that can indicate error
 * 
 * Regions table:
 * region_id is a primary key 
 * 
 * venues table:
 * venue_id is a primary key
 * 
 * result: all relations are 1:N. */


-- A check of content of the tables
SELECT *
FROM afisha.city c 
ORDER BY city_id
LIMIT 20;
-- Some data are missing, for example the city_ids 1 and 3

SELECT *
FROM afisha.events e 
ORDER BY event_id
LIMIT 20;
-- some rows in event_id are missing

SELECT *
FROM afisha.purchases p 
ORDER BY order_id 
LIMIT 20;
-- some rows in order_id are missing. Some orders have a total and revenue of 0

SELECT *
FROM afisha.regions r 
ORDER BY r.region_id 
LIMIT 20;
-- some rows in region_id are missing. 

SELECT *
FROM afisha.venues v  
ORDER BY v.venue_id 
LIMIT 20;
-- some rows in venue_id are missing.

--result: ids (primary keys) aren't continious in any tables.

-- Data volume 
SELECT COUNT(*)
FROM afisha.city c;
-- 353

SELECT COUNT(*)
FROM afisha.events e;
-- 22 484

SELECT COUNT(*)
FROM afisha.purchases p;
-- 292 034

SELECT 
	COUNT(DISTINCT user_id) AS count_users
FROM afisha.purchases p;

SELECT COUNT(*)
FROM afisha.regions r;
-- 81 

SELECT COUNT(*)
FROM afisha.venues v;
-- 3 228

-- Data correctness

-- 1) Missing values in the data
SELECT
	SUM(CASE WHEN city_name IS NULL THEN 1 ELSE 0 END) AS miss_city_name,
	SUM(CASE WHEN region_id IS NULL THEN 1 ELSE 0 END) AS miss_region_id
FROM afisha.city;

SELECT
	SUM(CASE WHEN event_name_code IS NULL THEN 1 ELSE 0 END) AS miss_event_name_code,
	SUM(CASE WHEN event_type_description IS NULL THEN 1 ELSE 0 END) AS miss_event_type_description,
	SUM(CASE WHEN event_type_main IS NULL THEN 1 ELSE 0 END) AS miss_event_type_main,
	SUM(CASE WHEN organizers IS NULL THEN 1 ELSE 0 END) AS miss_organizers,
	SUM(CASE WHEN city_id IS NULL THEN 1 ELSE 0 END) AS miss_city_id,
	SUM(CASE WHEN venue_id IS NULL THEN 1 ELSE 0 END) AS miss_venue_id
FROM afisha.events e ;

SELECT
	SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS miss_user_id,
	SUM(CASE WHEN created_dt_msk IS NULL THEN 1 ELSE 0 END) AS miss_created_dt_msk,
	SUM(CASE WHEN created_ts_msk IS NULL THEN 1 ELSE 0 END) AS miss_created_ts_msk,
	SUM(CASE WHEN event_id IS NULL THEN 1 ELSE 0 END) AS miss_event_id,
	SUM(CASE WHEN cinema_circuit IS NULL THEN 1 ELSE 0 END) AS miss_cinema_circuit,
	SUM(CASE WHEN age_limit IS NULL THEN 1 ELSE 0 END) AS miss_age_limit,
	SUM(CASE WHEN currency_code IS NULL THEN 1 ELSE 0 END) AS miss_currency_code,
	SUM(CASE WHEN device_type_canonical IS NULL THEN 1 ELSE 0 END) AS miss_device_type_canonical,
	SUM(CASE WHEN revenue IS NULL THEN 1 ELSE 0 END) AS miss_revenue,
	SUM(CASE WHEN service_name IS NULL THEN 1 ELSE 0 END) AS miss_service_name,
	SUM(CASE WHEN tickets_count IS NULL THEN 1 ELSE 0 END) AS miss_tickets_count,
	SUM(CASE WHEN total IS NULL THEN 1 ELSE 0 END) AS miss_total
FROM afisha.purchases p ;

SELECT
	SUM(CASE WHEN region_name IS NULL THEN 1 ELSE 0 END) AS miss_region_name
FROM afisha.regions r;

SELECT
	SUM(CASE WHEN venue_name IS NULL THEN 1 ELSE 0 END) AS miss_venue_name,
	SUM(CASE WHEN address IS NULL THEN 1 ELSE 0 END) AS miss_address	
FROM afisha.venues v ;

-- Result: No missing values in any table

-- 2) Categorical data check

SELECT
	cinema_circuit
FROM afisha.purchases p 
GROUP BY cinema_circuit;
-- Data looks correct. Values:
/* 
- Другое
- КиноСити
- Киномакс
- Москино
- ЦентрФильм
- нет
 */

SELECT
	currency_code
FROM afisha.purchases p 
GROUP BY currency_code;
-- Data looks correct. Values:
/* 
- kzt
- rub
 */

SELECT
	device_type_canonical
FROM afisha.purchases p 
GROUP BY device_type_canonical;
-- Data looks correct. Values:
/* 
- desktop
- mobile
- other
- tablet
- tv
 */

SELECT
	service_name
FROM afisha.purchases p 
GROUP BY service_name;
-- Data looks correct. There are 36 different service names.

SELECT
	event_type_main
FROM afisha.events e 
GROUP BY event_type_main;
-- Data looks correct. Values:
/* 
- концерты
- театр
- выставки
- ёлки
- фильм
- другое
- спорт
- стендап
 */

SELECT
	event_type_description
FROM afisha.events e 
GROUP BY event_type_description;
-- Some values may be incorrect, for example: событие, подарок, снегурочка.

SELECT
	COUNT(*)
FROM afisha.events e 
WHERE event_type_description = 'событие'
	OR event_type_description = 'подарок'
	OR event_type_description = 'снегурочка';
-- Total 4 536 events with incorrect description

SELECT
	c.city_name 
FROM afisha.city c 
GROUP BY c.city_name
ORDER BY c.city_name;
-- Data looks correct. There are 352 different city names,which means one town might be a duplicate.

SELECT
	r.region_name  
FROM afisha.regions r  
GROUP BY r.region_name
ORDER BY r.region_name;
-- Data looks correct. There are 81 different service names.

-- Checking the popular and unpopular events

SELECT
	event_type_description AS event_type,
	COUNT(p.order_id) AS orders_count,
	SUM(tickets_count) AS total_tickets
FROM afisha.events e 
LEFT JOIN afisha.purchases p
	USING(event_id)
GROUP BY e.event_type_description
ORDER BY orders_count DESC;
/*
 * The most popular event type is концерт ( 112 405 orders and 299 364 sold tickets).
 * It is almost twice as many as событие (58 813 and 160 174).
 * The third most popular type is спектакль (50 937 and 140 831).
 * Also there are categories with fewer than one thousand orders and fewer than 3.5 thousand tickets.
 * Category type, order count and total tickets:
	- ёлка 947 - 3255
	- фильм	238 - 632
	- музыкальный спектакль	140 - 493
	- кукольный спектакль	13 - 44
	- экскурсия	8 - 19
	- оперетта 7 - 19
	- подарок 4 - 8
	- снегурочка 3 - 6	
	- рок-мюзикл 1 - 4
	
	There are 2 categories with the same meaning: 'спорт' and 'спортивное мероприятие'
 */

-- Popular check devices 
SELECT 
	p.device_type_canonical,
	COUNT(order_id) AS orders_count
FROM afisha.purchases p 
GROUP BY device_type_canonical
ORDER BY orders_count DESC;
/* 
 * Device type and order count:
 * - mobile	- 232679 
 * - desktop - 58170
 * - tablet	- 1180
 * - tv	- 3
 * - other - 2
 * 
 * Result: Mobile and Desktop are the most popular devices for making an order. 
 */

-- Popular cinema:
SELECT 
	p.cinema_circuit,
	COUNT(order_id) AS orders_count
FROM afisha.purchases p 
GROUP BY cinema_circuit
ORDER BY orders_count DESC;
/*
 * Cinema and order count:
 * - нет - 290632 
 * - Другое	- 1263
 * - КиноСити - 124
 * - Киномакс - 7
 * - Москино - 7
 * - ЦентрФильм	- 1
 * 
 * The cinema circuit isn't indicated in 290 632 rows that is 99% of data.
 */

-- Popular age limit:
SELECT 
	p.age_limit,
	COUNT(order_id) AS orders_count,
	SUM(tickets_count) AS total_tickets
FROM afisha.purchases p 
GROUP BY age_limit
ORDER BY orders_count DESC;
/*
	age orders  tickets 
	
	16	78864	200951
	12	62861	169719
	0	61731	183476
	6	52403	147732
	18	36175	102532

The most popular age limit is 16. The least popular age limit is 18.
 */

-- Popular currency:
SELECT 
	p.currency_code,
	COUNT(order_id) AS orders_count
FROM afisha.purchases p 
GROUP BY p.currency_code 
ORDER BY orders_count DESC;
/* Currency and order count:
 * - rub - 286961
 * - kzt - 5073
 * 
 * 98% of orders were paid in rub.
 */

-- Popular service_name:
SELECT 
	p.service_name,
	COUNT(order_id) AS orders_count
FROM afisha.purchases p 
GROUP BY p.service_name 
ORDER BY orders_count DESC;
/*
 * The most popular service names are: Билеты без проблем (63 932), Лови билет!(41 338), Билеты в руки(40 500).
 * The least popular services are: Лимоны (8), Зе Бест!(5), Билеты в интернете(4).
 */

-- Anomaly check in tickets_count in every event_type 
SELECT
	e.event_type_description,
	COUNT(order_id) AS orders_count,
	SUM(tickets_count) AS total_tickets,
	MIN(tickets_count) AS tickets_min_count_per_order, 
	MAX(tickets_count) AS tickets_max_count_per_order,
	ROUND(AVG(tickets_count), 2) AS tickets_avg_count_per_order,
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY tickets_count) AS median_amount,
	MODE() WITHIN GROUP(ORDER BY tickets_count) AS mode_amount,
	ROUND(STDDEV(tickets_count), 2) AS std_dev_amount
FROM afisha.events e 	
LEFT JOIN afisha.purchases p
	USING(event_id)
GROUP BY e.event_type_description
ORDER BY orders_count DESC;
--Result: No anomalies found.

-- Anomaly check in revenue in every event_type 
SELECT
	e.event_type_description,
	SUM(revenue::NUMERIC) AS total_revenue,
	MIN(revenue) AS min_revenue, 
	MAX(revenue) AS max_revenue,
	ROUND(AVG(revenue::NUMERIC), 2) AS avg_revenue,
	ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY revenue)::NUMERIC,2) AS median_amount,
	MODE() WITHIN GROUP(ORDER BY revenue) AS mode_amount,
	ROUND(STDDEV(revenue::NUMERIC), 2) AS std_dev_amount
FROM afisha.events e 	
LEFT JOIN afisha.purchases p
	USING(event_id)
GROUP BY e.event_type_description
ORDER BY total_revenue DESC;
--Result: Anomalies found. Some event types have negative or zero values in min_revenue. Types:
/*
	- концерт: -5.7
	- спектакль: 0.0
	- событие: -17.94
	- шоу: 0.0
	- спортивное мероприятие: -90.76
	- спорт: -8.53
	- выставка: -5.17
	- фильм: 0.0
 */
-- Perhaps negative values are returns. 
-- Some types have a zero mode.:
/*
	- концерт
	- спектакль
	- событие
	- фильм
 */
-- Finally, 'рок-мюзикл' doesn't have a standard deviation.
-- Note: 'фильм' also has a zero median amount.

-- An anomaly check of revenue by currency 
SELECT
	p.currency_code,
	SUM(revenue::NUMERIC) AS total_revenue,
	MIN(revenue) AS min_revenue, 
	MAX(revenue) AS max_revenue,
	ROUND(AVG(revenue::NUMERIC), 2) AS avg_revenue,
	ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY revenue)::NUMERIC,2) AS median_amount,
	MODE() WITHIN GROUP(ORDER BY revenue) AS mode_amount,
	ROUND(STDDEV(revenue::NUMERIC), 2) AS std_dev_amount
FROM afisha.events e 	
LEFT JOIN afisha.purchases p
	USING(event_id)
GROUP BY p.currency_code
ORDER BY total_revenue DESC;
-- Anomalies found. Values:
/* rub:
 *     min_revenue: -90.76
 *     mode_amount: 0.0
 * kzt:
 *     min_revenue: 0.0
 * 
 * NOTE: Perhaps negative values are returns.
 * Median and mode in kzt are the same ( 3698.83 ) that may be due to small sample size.
 */

-- Anomaly check in total in every event_type 
SELECT
	e.event_type_description,
	SUM(total::NUMERIC) AS total_sum,
	MIN(total) AS min_total, 
	MAX(total) AS max_total,
	ROUND(AVG(total::NUMERIC), 2) AS avg_total,
	ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY total)::NUMERIC,2) AS median_amount,
	MODE() WITHIN GROUP(ORDER BY total) AS mode_amount,
	ROUND(STDDEV(total::NUMERIC), 2) AS std_dev_amount
FROM afisha.events e 	
LEFT JOIN afisha.purchases p
	USING(event_id)
GROUP BY e.event_type_description
ORDER BY total_sum DESC;
-- The conclusion is similar to the previous one.
-- Some event types have negative or zero values in min_total. Types:
/*
	- концерт: -71.24
	- спектакль: 0.0
	- событие: -358.85
	- шоу: 0.0
	- спортивное мероприятие: -122.65
	- спорт: -213.36
	- выставка: -129.36
	- фильм: 0.0
 */
--  Perhaps these are returns.. 
-- Some types have a zero mode.:
/*
	- концерт
	- спектакль
	- событие
	- фильм
 */
-- Finally, 'рок-мюзикл' doesn't have a standard deviation.
-- Note: 'фильм' also has a zero median amount.

-- Time range of the data:
SELECT
	MIN(p.created_ts_msk) AS datetime_first_order,
	MAX(p.created_ts_msk) AS datetime_last_order
FROM afisha.purchases p;
-- The data covers 2024-06-01 00:00:42.000 to 2024-10-31 23:59:54.000

-- Cheсking the season activity 
SELECT
	DATE_TRUNC('month', p.created_dt_msk) AS month,
	count(order_id)
FROM afisha.purchases p 
GROUP BY month;

/*
  The data covers only 5 months (June–October 2024). There is a clear upward trend in the number of orders,
  with a peak in October ( 100 600 orders ). However, it is impossible to draw conclusions about full-year seasonality
  because winter and spring months are missing.
 */

-- Data Mart
SELECT
	user_id,
	device_type_canonical,
	order_id,
	created_dt_msk AS order_dt,
	created_ts_msk AS order_ts,
	currency_code,
	revenue,
	tickets_count,
  	EXTRACT(DAY FROM created_dt_msk - LAG(created_dt_msk) OVER(PARTITION BY user_id ORDER BY created_dt_msk)) AS days_since_prev,
  	event_id,
  	event_name_code AS event_name,
  	event_type_main,
  	service_name,
  	region_name,
  	city_name
FROM purchases p
JOIN events
    USING(event_id)
JOIN city
    USING(city_id)
JOIN regions
    USING(region_id)  
WHERE (p.device_type_canonical = 'mobile'
OR p.device_type_canonical = 'desktop')
AND event_type_main <> 'фильм'
ORDER BY user_id;














