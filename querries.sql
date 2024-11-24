-- Vehicles with last technical inspection older than 1 year
SELECT vehicles.id_vehicle, vehicles.type, vehicles.last_technical_inspection 
FROM vehicles
WHERE vehicles.last_technical_inspection < now() - INTERVAL '1 year' 
ORDER BY vehicles.last_technical_inspection ASC

"Sort  (cost=14.20..14.60 rows=162 width=16) (actual time=0.163..0.169 rows=163 loops=1)"
"  Sort Key: last_technical_inspection"
"  Sort Method: quicksort  Memory: 30kB"
"  ->  Seq Scan on vehicles  (cost=0.00..8.25 rows=162 width=16) (actual time=0.018..0.119 rows=163 loops=1)"
"        Filter: (last_technical_inspection < (now() - '1 year'::interval))"
"        Rows Removed by Filter: 137"
"Planning Time: 3.641 ms"
"Execution Time: 0.202 ms"

-- Unserviced vehicles
SELECT technical_issues.id_technical_issue, technical_issues.report_date, technical_issues.status, technical_issues.description, vehicles.id_vehicle
FROM technical_issues 
JOIN vehicles ON vehicles.id_vehicle = technical_issues.fk_vehicle
WHERE technical_issues.status = 'InProgress' OR technical_issues.status = 'Reported'
ORDER BY technical_issues.report_date ASC

"Sort  (cost=41.02..41.67 rows=258 width=177) (actual time=0.279..0.289 rows=258 loops=1)"
"  Sort Key: technical_issues.report_date"
"  Sort Method: quicksort  Memory: 75kB"
"  ->  Hash Join  (cost=9.75..30.69 rows=258 width=177) (actual time=0.070..0.204 rows=258 loops=1)"
"        Hash Cond: (technical_issues.fk_vehicle = vehicles.id_vehicle)"
"        ->  Seq Scan on technical_issues  (cost=0.00..20.25 rows=258 width=177) (actual time=0.016..0.110 rows=258 loops=1)"
"              Filter: (status <> 'Resolved'::technicalissuestatusenum)"
"              Rows Removed by Filter: 242"
"        ->  Hash  (cost=6.00..6.00 rows=300 width=4) (actual time=0.046..0.046 rows=300 loops=1)"
"              Buckets: 1024  Batches: 1  Memory Usage: 19kB"
"              ->  Seq Scan on vehicles  (cost=0.00..6.00 rows=300 width=4) (actual time=0.006..0.023 rows=300 loops=1)"
"Planning Time: 3.674 ms"
"Execution Time: 0.322 ms"

-- Fines issued by inspectors
SELECT ticket_inspectors.id_inspector, CONCAT(app_users.name, ' ', app_users.surname) AS "Name", count(fines.id_fine) AS "Fines_count"
FROM ticket_inspectors 
LEFT JOIN fines ON fines.fk_inspector = ticket_inspectors.id_inspector 
JOIN app_users ON app_users.id_user = ticket_inspectors.fk_user
GROUP BY ticket_inspectors.id_inspector, app_users.name, app_users.surname 
ORDER BY "Fines_count" DESC

"Sort  (cost=515.44..519.82 rows=1750 width=58) (actual time=2.260..2.265 rows=150 loops=1)"
"  Sort Key: (count(fines.id_fine)) DESC"
"  Sort Method: quicksort  Memory: 34kB"
"  ->  HashAggregate  (cost=399.30..421.18 rows=1750 width=58) (actual time=2.182..2.230 rows=150 loops=1)"
"        Group Key: ticket_inspectors.id_inspector, app_users.name, app_users.surname"
"        Batches: 1  Memory Usage: 81kB"
"        ->  Hash Right Join  (cost=323.24..381.80 rows=1750 width=22) (actual time=1.402..1.776 rows=1750 loops=1)"
"              Hash Cond: (fines.fk_inspector = ticket_inspectors.id_inspector)"
"              ->  Seq Scan on fines  (cost=0.00..34.50 rows=1750 width=8) (actual time=0.006..0.086 rows=1750 loops=1)"
"              ->  Hash  (cost=321.37..321.37 rows=150 width=18) (actual time=1.390..1.391 rows=150 loops=1)"
"                    Buckets: 1024  Batches: 1  Memory Usage: 16kB"
"                    ->  Hash Join  (cost=4.38..321.37 rows=150 width=18) (actual time=0.051..1.368 rows=150 loops=1)"
"                          Hash Cond: (app_users.id_user = ticket_inspectors.fk_user)"
"                          ->  Seq Scan on app_users  (cost=0.00..285.38 rows=12038 width=18) (actual time=0.010..0.586 rows=12028 loops=1)"
"                          ->  Hash  (cost=2.50..2.50 rows=150 width=8) (actual time=0.026..0.026 rows=150 loops=1)"
"                                Buckets: 1024  Batches: 1  Memory Usage: 14kB"
"                                ->  Seq Scan on ticket_inspectors  (cost=0.00..2.50 rows=150 width=8) (actual time=0.007..0.013 rows=150 loops=1)"
"Planning Time: 0.989 ms"
"Execution Time: 2.332 ms"


-- Inspections per line
SELECT l.number AS line_number, 
COUNT(i.id_inspection) AS inspection_count
FROM Lines l
LEFT JOIN Rides r ON l.id_line = r.fk_line
LEFT JOIN Inspections i ON i.fk_ride = r.id_ride 
AND EXTRACT(MONTH FROM i.date) = 1
AND EXTRACT(YEAR FROM i.date) = 2022
GROUP BY line_number
ORDER BY inspection_count DESC;

"Sort  (cost=190.88..191.13 rows=100 width=12) (actual time=2.177..2.182 rows=100 loops=1)"
"  Sort Key: (count(i.id_inspection)) DESC"
"  Sort Method: quicksort  Memory: 28kB"
"  ->  HashAggregate  (cost=186.55..187.55 rows=100 width=12) (actual time=2.152..2.162 rows=100 loops=1)"
"        Group Key: l.number"
"        Batches: 1  Memory Usage: 24kB"
"        ->  Hash Left Join  (cost=83.26..168.80 rows=3550 width=8) (actual time=0.562..1.660 rows=3550 loops=1)"
"              Hash Cond: (r.id_ride = i.fk_ride)"
"              ->  Hash Right Join  (cost=3.25..75.47 rows=3550 width=8) (actual time=0.044..0.830 rows=3550 loops=1)"
"                    Hash Cond: (r.fk_line = l.id_line)"
"                    ->  Seq Scan on rides r  (cost=0.00..62.50 rows=3550 width=8) (actual time=0.007..0.246 rows=3550 loops=1)"
"                    ->  Hash  (cost=2.00..2.00 rows=100 width=8) (actual time=0.029..0.029 rows=100 loops=1)"
"                          Buckets: 1024  Batches: 1  Memory Usage: 12kB"
"                          ->  Seq Scan on lines l  (cost=0.00..2.00 rows=100 width=8) (actual time=0.011..0.017 rows=100 loops=1)"
"              ->  Hash  (cost=80.00..80.00 rows=1 width=8) (actual time=0.509..0.509 rows=45 loops=1)"
"                    Buckets: 1024  Batches: 1  Memory Usage: 10kB"
"                    ->  Seq Scan on inspections i  (cost=0.00..80.00 rows=1 width=8) (actual time=0.019..0.504 rows=45 loops=1)"
"                          Filter: ((EXTRACT(month FROM date) = '1'::numeric) AND (EXTRACT(year FROM date) = '2022'::numeric))"
"                          Rows Removed by Filter: 2955"
"Planning Time: 5.269 ms"
"Execution Time: 2.239 ms"

-- Reparir cost per year
SELECT EXTRACT(YEAR FROM report_date) AS year, 
SUM(repair_cost) AS total_repair_cost
FROM Technical_Issues
GROUP BY year
ORDER BY year DESC;

"GroupAggregate  (cost=42.66..53.91 rows=500 width=64) (actual time=0.266..0.340 rows=5 loops=1)"
"  Group Key: (EXTRACT(year FROM report_date))"
"  ->  Sort  (cost=42.66..43.91 rows=500 width=35) (actual time=0.242..0.259 rows=500 loops=1)"
"        Sort Key: (EXTRACT(year FROM report_date)) DESC"
"        Sort Method: quicksort  Memory: 38kB"
"        ->  Seq Scan on technical_issues  (cost=0.00..20.25 rows=500 width=35) (actual time=0.016..0.137 rows=500 loops=1)"
"Planning Time: 0.191 ms"
"Execution Time: 0.358 ms"

-- Most bought tickets in the last 6 months
SELECT tt.name AS ticket_type, COUNT(t.id_ticket) AS number_of_tickets_sold
FROM Tickets t
JOIN Ticket_Types tt ON t.fk_ticket_type = tt.id_ticket_type
JOIN Purchases p ON t.fk_purchase = p.id_purchase
WHERE p.date >= (CURRENT_DATE - INTERVAL '6 months')
GROUP BY ticket_type
ORDER BY number_of_tickets_sold DESC;

"Sort  (cost=3317.04..3317.39 rows=140 width=524) (actual time=26.340..26.343 rows=26 loops=1)"
"  Sort Key: (count(t.id_ticket)) DESC"
"  Sort Method: quicksort  Memory: 26kB"
"  ->  HashAggregate  (cost=3310.65..3312.05 rows=140 width=524) (actual time=26.325..26.331 rows=26 loops=1)"
"        Group Key: tt.name"
"        Batches: 1  Memory Usage: 40kB"
"        ->  Hash Join  (cost=1899.00..3272.51 rows=7628 width=520) (actual time=12.375..25.253 rows=7584 loops=1)"
"              Hash Cond: (t.fk_ticket_type = tt.id_ticket_type)"
"              ->  Hash Join  (cost=1885.85..3238.74 rows=7628 width=8) (actual time=12.343..24.348 rows=7584 loops=1)"
"                    Hash Cond: (t.fk_purchase = p.id_purchase)"
"                    ->  Seq Scan on tickets t  (cost=0.00..1156.00 rows=75000 width=12) (actual time=0.276..5.581 rows=75000 loops=1)"
"                    ->  Hash  (cost=1790.50..1790.50 rows=7628 width=4) (actual time=12.040..12.040 rows=7584 loops=1)"
"                          Buckets: 8192  Batches: 1  Memory Usage: 331kB"
"                          ->  Seq Scan on purchases p  (cost=0.00..1790.50 rows=7628 width=4) (actual time=0.013..11.371 rows=7584 loops=1)"
"                                Filter: (date >= (CURRENT_DATE - '6 mons'::interval))"
"                                Rows Removed by Filter: 67416"
"              ->  Hash  (cost=11.40..11.40 rows=140 width=520) (actual time=0.024..0.024 rows=26 loops=1)"
"                    Buckets: 1024  Batches: 1  Memory Usage: 10kB"
"                    ->  Seq Scan on ticket_types tt  (cost=0.00..11.40 rows=140 width=520) (actual time=0.015..0.017 rows=26 loops=1)"
"Planning Time: 5.468 ms"
"Execution Time: 26.437 ms"

-- query users who are most overdue with their fines
SELECT app_users.name, app_users.surname, app_users.phone_number, app_users.email, fines.deadline, fines.amount
FROM app_users
JOIN passengers ON app_users.id_user = passengers.fk_user
JOIN fines ON passengers.id_passenger = fines.fk_passenger
WHERE fines.status != 'Paid' AND fines.deadline < now()
ORDER BY fines.deadline ASC;

"Sort  (cost=309.16..309.37 rows=83 width=64) (actual time=2.470..2.475 rows=82 loops=1)"
"  Sort Key: fines.deadline"
"  Sort Method: quicksort  Memory: 32kB"
"  ->  Nested Loop  (cost=48.95..306.52 rows=83 width=64) (actual time=0.225..2.436 rows=82 loops=1)"
"        ->  Hash Join  (cost=48.66..275.31 rows=83 width=17) (actual time=0.178..1.575 rows=82 loops=1)"
"              Hash Cond: (passengers.id_passenger = fines.fk_passenger)"
"              ->  Seq Scan on passengers  (cost=0.00..157.81 rows=10881 width=8) (actual time=0.021..0.650 rows=11053 loops=1)"
"              ->  Hash  (cost=47.62..47.62 rows=83 width=17) (actual time=0.145..0.145 rows=82 loops=1)"
"                    Buckets: 1024  Batches: 1  Memory Usage: 13kB"
"                    ->  Seq Scan on fines  (cost=0.00..47.62 rows=83 width=17) (actual time=0.008..0.132 rows=82 loops=1)"
"                          Filter: ((status <> 'Paid'::finestatusenum) AND (deadline < now()))"
"                          Rows Removed by Filter: 1668"
"        ->  Index Scan using app_users_pkey on app_users  (cost=0.29..0.38 rows=1 width=55) (actual time=0.010..0.010 rows=1 loops=82)"
"              Index Cond: (id_user = passengers.fk_user)"
"Planning Time: 3.555 ms"
"Execution Time: 2.500 ms"

-- vehicles with the most technical issues
SELECT 
    vehicles.id_vehicle,
    vehicles.vehicle_number,
    vehicles.production_date,
    vehicles.last_technical_inspection,
    vehicles.status,
    COUNT(technical_issues.id_technical_issue) AS count_issues
FROM vehicles
JOIN technical_issues ON vehicles.id_vehicle = technical_issues.fk_vehicle
GROUP BY vehicles.id_vehicle
ORDER BY count_issues DESC;

"Sort  (cost=47.93..48.68 rows=300 width=36) (actual time=0.455..0.464 rows=244 loops=1)"
"  Sort Key: (count(technical_issues.id_technical_issue)) DESC"
"  Sort Method: quicksort  Memory: 38kB"
"  ->  HashAggregate  (cost=32.58..35.58 rows=300 width=36) (actual time=0.387..0.424 rows=244 loops=1)"
"        Group Key: vehicles.id_vehicle"
"        Batches: 1  Memory Usage: 61kB"
"        ->  Hash Join  (cost=9.75..30.08 rows=500 width=32) (actual time=0.103..0.294 rows=500 loops=1)"
"              Hash Cond: (technical_issues.fk_vehicle = vehicles.id_vehicle)"
"              ->  Seq Scan on technical_issues  (cost=0.00..19.00 rows=500 width=8) (actual time=0.012..0.072 rows=500 loops=1)"
"              ->  Hash  (cost=6.00..6.00 rows=300 width=28) (actual time=0.082..0.082 rows=300 loops=1)"
"                    Buckets: 1024  Batches: 1  Memory Usage: 26kB"
"                    ->  Seq Scan on vehicles  (cost=0.00..6.00 rows=300 width=28) (actual time=0.008..0.040 rows=300 loops=1)"
"Planning Time: 0.227 ms"
"Execution Time: 0.517 ms"

-- query month by income, sort frow worst to best
SELECT 
    TO_CHAR(purchases.date, 'Month') AS month, 
    SUM(purchases.amount) AS income
FROM purchases
WHERE purchases.date >= (CURRENT_DATE - INTERVAL '12 months')
GROUP BY month
ORDER BY income DESC;

"Sort  (cost=3197.41..3235.64 rows=15292 width=64) (actual time=14.065..14.066 rows=12 loops=1)"
"  Sort Key: (sum(amount)) DESC"
"  Sort Method: quicksort  Memory: 25kB"
"  ->  HashAggregate  (cost=1905.20..2134.58 rows=15292 width=64) (actual time=13.998..14.054 rows=12 loops=1)"
"        Group Key: to_char(date, 'Month'::text)"
"        Batches: 1  Memory Usage: 793kB"
"        ->  Seq Scan on purchases  (cost=0.00..1828.73 rows=15293 width=38) (actual time=0.385..11.284 rows=15208 loops=1)"
"              Filter: (date >= (CURRENT_DATE - '1 year'::interval))"
"              Rows Removed by Filter: 59792"
"Planning Time: 0.119 ms"
"Execution Time: 14.527 ms"



-- drivers with expired_licenses sorted by longest expired date
SELECT app_users.name, app_users.surname,  drivers.id_driver, drivers_licenses.issued_on,drivers_licenses.expires_on
FROM app_users
JOIN drivers ON app_users.id_user = drivers.fk_user
JOIN drivers_licenses ON drivers.fk_license = drivers_licenses.id_license
WHERE drivers_licenses.expires_on <= (CURRENT_DATE + INTERVAL '12 months')
ORDER BY drivers_licenses.expires_on ASC;

"Sort  (cost=29.69..29.70 rows=1 width=34) (actual time=0.167..0.167 rows=3 loops=1)"
"  Sort Key: drivers_licenses.expires_on"
"  Sort Method: quicksort  Memory: 25kB"
"  ->  Nested Loop  (cost=0.56..29.68 rows=1 width=34) (actual time=0.121..0.159 rows=3 loops=1)"
"        ->  Nested Loop  (cost=0.28..28.31 rows=1 width=24) (actual time=0.114..0.145 rows=3 loops=1)"
"              ->  Seq Scan on drivers_licenses  (cost=0.00..20.00 rows=1 width=20) (actual time=0.105..0.106 rows=3 loops=1)"
"                    Filter: (expires_on <= (CURRENT_DATE + '1 year'::interval))"
"                    Rows Removed by Filter: 797"
"              ->  Index Scan using drivers_fk_license_key on drivers  (cost=0.28..8.29 rows=1 width=12) (actual time=0.012..0.012 rows=1 loops=3)"
"                    Index Cond: (fk_license = drivers_licenses.id_license)"
"        ->  Index Scan using app_users_pkey on app_users  (cost=0.29..1.37 rows=1 width=18) (actual time=0.004..0.004 rows=1 loops=3)"
"              Index Cond: (id_user = drivers.fk_user)"
"Planning Time: 5.036 ms"
"Execution Time: 0.188 ms"


--- sum of fines for each inspector
select ticket_inspectors.id_inspector, app_users.name, app_users.surname, coalesce(sum(fines.amount), 0)  as "fines sum"
from app_users inner join ticket_inspectors on app_users.id_user = ticket_inspectors.fk_user
left join fines on ticket_inspectors.id_inspector = fines.fk_inspector
where fines.issue_date >= (current_date - interval '1 year')
group by ticket_inspectors.id_inspector, app_users.name, app_users.surname order by "fines sum" desc;

"Sort  (cost=397.14..397.98 rows=336 width=50) (actual time=2.073..2.079 rows=129 loops=1)"
"  Sort Key: (COALESCE(sum(fines.amount), '0'::numeric)) DESC"
"  Sort Method: quicksort  Memory: 30kB"
"  ->  HashAggregate  (cost=378.85..383.05 rows=336 width=50) (actual time=2.007..2.035 rows=129 loops=1)"
"        Group Key: ticket_inspectors.id_inspector, app_users.name, app_users.surname"
"        Batches: 1  Memory Usage: 93kB"
"        ->  Hash Join  (cost=323.24..375.49 rows=336 width=23) (actual time=1.607..1.887 rows=335 loops=1)"
"              Hash Cond: (fines.fk_inspector = ticket_inspectors.id_inspector)"
"              ->  Seq Scan on fines  (cost=0.00..47.62 rows=336 width=9) (actual time=0.017..0.240 rows=335 loops=1)"
"                    Filter: (issue_date >= (CURRENT_DATE - '1 year'::interval))"
"                    Rows Removed by Filter: 1415"
"              ->  Hash  (cost=321.37..321.37 rows=150 width=18) (actual time=1.582..1.583 rows=150 loops=1)"
"                    Buckets: 1024  Batches: 1  Memory Usage: 16kB"
"                    ->  Hash Join  (cost=4.38..321.37 rows=150 width=18) (actual time=0.070..1.550 rows=150 loops=1)"
"                          Hash Cond: (app_users.id_user = ticket_inspectors.fk_user)"
"                          ->  Seq Scan on app_users  (cost=0.00..285.38 rows=12038 width=18) (actual time=0.008..0.653 rows=12028 loops=1)"
"                          ->  Hash  (cost=2.50..2.50 rows=150 width=8) (actual time=0.039..0.040 rows=150 loops=1)"
"                                Buckets: 1024  Batches: 1  Memory Usage: 14kB"
"                                ->  Seq Scan on ticket_inspectors  (cost=0.00..2.50 rows=150 width=8) (actual time=0.009..0.018 rows=150 loops=1)"
"Planning Time: 0.497 ms"
"Execution Time: 2.144 ms"

-- count of lines passing through each stop
select stops.id_stop, stops.name, count(lines.id_line) as "lines passing through"
from stops inner join path_stops on stops.id_stop = path_stops.id_stop
    inner join paths on path_stops.id_path = paths.id_path
    inner join lines on paths.id_path =  lines.fk_main_path
group by stops.id_stop, stops.name order by "lines passing through" desc;


"Sort  (cost=71.94..72.12 rows=75 width=31) (actual time=1.305..1.320 rows=409 loops=1)"
"  Sort Key: (count(lines.id_line)) DESC"
"  Sort Method: quicksort  Memory: 45kB"
"  ->  HashAggregate  (cost=68.85..69.60 rows=75 width=31) (actual time=1.205..1.248 rows=409 loops=1)"
"        Group Key: stops.id_stop"
"        Batches: 1  Memory Usage: 109kB"
"        ->  Hash Join  (cost=54.85..68.48 rows=75 width=27) (actual time=0.669..0.929 rows=2175 loops=1)"
"              Hash Cond: (stops.id_stop = path_stops.id_stop)"
"              ->  Seq Scan on stops  (cost=0.00..11.00 rows=500 width=23) (actual time=0.019..0.045 rows=500 loops=1)"
"              ->  Hash  (cost=53.91..53.91 rows=75 width=8) (actual time=0.639..0.640 rows=2175 loops=1)"
"                    Buckets: 4096 (originally 1024)  Batches: 1 (originally 1)  Memory Usage: 117kB"
"                    ->  Hash Join  (cost=32.14..53.91 rows=75 width=8) (actual time=0.141..0.460 rows=2175 loops=1)"
"                          Hash Cond: (path_stops.id_path = paths.id_path)"
"                          ->  Seq Scan on path_stops  (cost=0.00..16.93 rows=1093 width=8) (actual time=0.012..0.070 rows=1093 loops=1)"
"                          ->  Hash  (cost=30.89..30.89 rows=100 width=12) (actual time=0.115..0.116 rows=100 loops=1)"
"                                Buckets: 1024  Batches: 1  Memory Usage: 13kB"
"                                ->  Nested Loop  (cost=0.16..30.89 rows=100 width=12) (actual time=0.029..0.103 rows=100 loops=1)"
"                                      ->  Seq Scan on lines  (cost=0.00..2.00 rows=100 width=8) (actual time=0.008..0.014 rows=100 loops=1)"
"                                      ->  Memoize  (cost=0.16..0.66 rows=1 width=4) (actual time=0.001..0.001 rows=1 loops=100)"
"                                            Cache Key: lines.fk_main_path"
"                                            Cache Mode: logical"
"                                            Hits: 60  Misses: 40  Evictions: 0  Overflows: 0  Memory Usage: 5kB"
"                                            ->  Index Only Scan using paths_pkey on paths  (cost=0.15..0.65 rows=1 width=4) (actual time=0.001..0.001 rows=1 loops=40)"
"                                                  Index Cond: (id_path = lines.fk_main_path)"
"                                                  Heap Fetches: 40"
"Planning Time: 0.485 ms"
"Execution Time: 1.415 ms"


-- rides per hour for each stop
select stops.id_stop, stops.name, coalesce(sum(60/lines.avg_frequency), 0) as "rides per hour"
from stops left join path_stops on stops.id_stop = path_stops.id_stop
    left join paths on path_stops.id_path = paths.id_path
    left join lines on paths.id_path =  lines.fk_main_path
group by stops.id_stop, stops.name order by "rides per hour" desc;

"Sort  (cost=125.82..127.07 rows=500 width=31) (actual time=1.409..1.427 rows=500 loops=1)"
"  Sort Key: (COALESCE(sum((60 / lines.avg_frequency)), '0'::bigint)) DESC"
"  Sort Method: quicksort  Memory: 49kB"
"  ->  HashAggregate  (cost=98.40..103.40 rows=500 width=31) (actual time=1.281..1.340 rows=500 loops=1)"
"        Group Key: stops.id_stop"
"        Batches: 1  Memory Usage: 105kB"
"        ->  Hash Left Join  (cost=20.66..90.20 rows=1093 width=27) (actual time=0.149..0.968 rows=2440 loops=1)"
"              Hash Cond: (paths.id_path = lines.fk_main_path)"
"              ->  Nested Loop Left Join  (cost=17.41..75.27 rows=1093 width=27) (actual time=0.120..0.687 rows=1142 loops=1)"
"                    ->  Hash Right Join  (cost=17.25..37.07 rows=1093 width=27) (actual time=0.110..0.345 rows=1142 loops=1)"
"                          Hash Cond: (path_stops.id_stop = stops.id_stop)"
"                          ->  Seq Scan on path_stops  (cost=0.00..16.93 rows=1093 width=8) (actual time=0.005..0.058 rows=1093 loops=1)"
"                          ->  Hash  (cost=11.00..11.00 rows=500 width=23) (actual time=0.099..0.099 rows=500 loops=1)"
"                                Buckets: 1024  Batches: 1  Memory Usage: 36kB"
"                                ->  Seq Scan on stops  (cost=0.00..11.00 rows=500 width=23) (actual time=0.011..0.049 rows=500 loops=1)"
"                    ->  Memoize  (cost=0.16..0.22 rows=1 width=4) (actual time=0.000..0.000 rows=1 loops=1142)"
"                          Cache Key: path_stops.id_path"
"                          Cache Mode: logical"
"                          Hits: 1091  Misses: 51  Evictions: 0  Overflows: 0  Memory Usage: 6kB"
"                          ->  Index Only Scan using paths_pkey on paths  (cost=0.15..0.21 rows=1 width=4) (actual time=0.001..0.001 rows=1 loops=51)"
"                                Index Cond: (id_path = path_stops.id_path)"
"                                Heap Fetches: 50"
"              ->  Hash  (cost=2.00..2.00 rows=100 width=8) (actual time=0.022..0.022 rows=100 loops=1)"
"                    Buckets: 1024  Batches: 1  Memory Usage: 12kB"
"                    ->  Seq Scan on lines  (cost=0.00..2.00 rows=100 width=8) (actual time=0.006..0.012 rows=100 loops=1)"
"Planning Time: 0.326 ms"
"Execution Time: 1.504 ms"

-- rides per vehicle
select vehicles.id_vehicle, vehicles.vehicle_number, vehicles.type, count(rides.id_ride) as "number of rides"
from vehicles inner join rides on vehicles.id_vehicle = rides.fk_vehicle
group by vehicles.id_vehicle, vehicles.vehicle_number, vehicles.type order by "number of rides" desc;

"Sort  (cost=114.80..115.55 rows=300 width=20) (actual time=1.331..1.341 rows=300 loops=1)"
"  Sort Key: (count(rides.id_ride)) DESC"
"  Sort Method: quicksort  Memory: 36kB"
"  ->  HashAggregate  (cost=99.45..102.45 rows=300 width=20) (actual time=1.258..1.296 rows=300 loops=1)"
"        Group Key: vehicles.id_vehicle"
"        Batches: 1  Memory Usage: 61kB"
"        ->  Hash Join  (cost=9.75..81.70 rows=3550 width=16) (actual time=0.097..0.833 rows=3550 loops=1)"
"              Hash Cond: (rides.fk_vehicle = vehicles.id_vehicle)"
"              ->  Seq Scan on rides  (cost=0.00..62.50 rows=3550 width=8) (actual time=0.017..0.183 rows=3550 loops=1)"
"              ->  Hash  (cost=6.00..6.00 rows=300 width=12) (actual time=0.071..0.071 rows=300 loops=1)"
"                    Buckets: 1024  Batches: 1  Memory Usage: 21kB"
"                    ->  Seq Scan on vehicles  (cost=0.00..6.00 rows=300 width=12) (actual time=0.009..0.034 rows=300 loops=1)"
"Planning Time: 0.300 ms"
"Execution Time: 1.400 ms"

-- sum of ticket costs for each passenger
select passengers.id_passenger, app_users.name, app_users.login, sum(ticket_types.price) as "cost sum"
from app_users inner join passengers on app_users.id_user = passengers.fk_user
inner join tickets on passengers.id_passenger = tickets.fk_passenger
inner join ticket_types on tickets.fk_ticket_type = ticket_types.id_ticket_type
group by passengers.id_passenger, app_users.login, app_users.name order by "cost sum" desc;

"Sort  (cost=20180.91..20368.41 rows=75000 width=54) (actual time=95.849..96.498 rows=11019 loops=1)"
"  Sort Key: (sum(ticket_types.price)) DESC"
"  Sort Method: quicksort  Memory: 916kB"
"  ->  HashAggregate  (cost=9433.06..11542.44 rows=75000 width=54) (actual time=86.875..91.936 rows=11019 loops=1)"
"        Group Key: passengers.id_passenger, app_users.login, app_users.name"
"        Planned Partitions: 4  Batches: 1  Memory Usage: 5393kB"
"        ->  Hash Join  (cost=742.83..2495.56 rows=75000 width=38) (actual time=3.816..53.566 rows=75000 loops=1)"
"              Hash Cond: (tickets.fk_ticket_type = ticket_types.id_ticket_type)"
"              ->  Hash Join  (cost=729.68..2279.57 rows=75000 width=26) (actual time=3.794..42.904 rows=75000 loops=1)"
"                    Hash Cond: (passengers.fk_user = app_users.id_user)"
"                    ->  Hash Join  (cost=293.82..1646.78 rows=75000 width=12) (actual time=1.318..23.635 rows=75000 loops=1)"
"                          Hash Cond: (tickets.fk_passenger = passengers.id_passenger)"
"                          ->  Seq Scan on tickets  (cost=0.00..1156.00 rows=75000 width=8) (actual time=0.007..3.871 rows=75000 loops=1)"
"                          ->  Hash  (cost=157.81..157.81 rows=10881 width=8) (actual time=1.270..1.271 rows=11053 loops=1)"
"                                Buckets: 16384  Batches: 1  Memory Usage: 560kB"
"                                ->  Seq Scan on passengers  (cost=0.00..157.81 rows=10881 width=8) (actual time=0.006..0.494 rows=11053 loops=1)"
"                    ->  Hash  (cost=285.38..285.38 rows=12038 width=22) (actual time=2.436..2.437 rows=12028 loops=1)"
"                          Buckets: 16384  Batches: 1  Memory Usage: 789kB"
"                          ->  Seq Scan on app_users  (cost=0.00..285.38 rows=12038 width=22) (actual time=0.007..1.069 rows=12028 loops=1)"
"              ->  Hash  (cost=11.40..11.40 rows=140 width=20) (actual time=0.019..0.019 rows=26 loops=1)"
"                    Buckets: 1024  Batches: 1  Memory Usage: 10kB"
"                    ->  Seq Scan on ticket_types  (cost=0.00..11.40 rows=140 width=20) (actual time=0.012..0.014 rows=26 loops=1)"
"Planning Time: 0.443 ms"
"Execution Time: 97.690 ms"