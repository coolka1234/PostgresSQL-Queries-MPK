-- Vehicles with last technical inspection older than 1 year
SELECT vehicles.id_vehicle, vehicles.type, vehicles.last_technical_inspection 
FROM vehicles
WHERE vehicles.last_technical_inspection < now() - INTERVAL '1 year' ORDER BY vehicles.last_technical_inspection ASC

-- Unserviced vehicles
SELECT technical_issues.id_technical_issue, technical_issues.report_date, technical_issues.status, technical_issues.description, vehicles.id_vehicle
FROM technical_issues JOIN vehicles ON vehicles.id_vehicle = technical_issues.fk_vehicle
WHERE technical_issues.status != 'Resolved' ORDER BY technical_issues.report_date ASC

-- Fines issued by inspectors
SELECT ticket_inspectors.id_inspector, CONCAT(app_users.name, ' ', app_users.surname) AS "Name", count(fines.id_fine) AS "Fines_count"
FROM ticket_inspectors LEFT JOIN fines ON fines.fk_inspector = ticket_inspectors.id_inspector JOIN app_users ON app_users.id_user = ticket_inspectors.fk_user
GROUP BY ticket_inspectors.id_inspector, app_users.name, app_users.surname ORDER BY "Fines_count" DESC


-- Inspections per line
SELECT l.number AS line_number, 
COUNT(i.id_inspection) AS inspection_count
FROM Lines l
LEFT JOIN Rides r ON l.id_line = r.fk_line
LEFT JOIN Inspections i ON i.fk_ride = r.id_ride 
AND EXTRACT(MONTH FROM i.date) = 2 
AND EXTRACT(YEAR FROM i.date) = 2023
GROUP BY line_number
ORDER BY inspection_count DESC;

-- Reparir cost per year
SELECT EXTRACT(YEAR FROM report_date) AS year, 
SUM(repair_cost) AS total_repair_cost
FROM Technical_Issues
GROUP BY year
ORDER BY year DESC;

-- Most bought tickets in the last 6 months
SELECT tt.name AS ticket_type, COUNT(t.id_ticket) AS number_of_tickets_sold
FROM Tickets t
JOIN Ticket_Types tt ON t.fk_ticket_type = tt.id_ticket_type
JOIN Purchases p ON t.fk_purchase = p.id_purchase
WHERE p.date >= (CURRENT_DATE - INTERVAL '6 months')
GROUP BY ticket_type
ORDER BY number_of_tickets_sold DESC;

-- query users who are most overdue with their fines
SELECT app_users.name, app_users.surname, app_users.phone_number, app_users.email, fines.deadline, fines.amount
FROM app_users
JOIN passengers ON app_users.id_user = passengers.fk_user
JOIN fines ON passengers.id_passenger = fines.fk_passenger
WHERE fines.status != 'Paid' AND fines.deadline < now()
ORDER BY fines.deadline ASC;

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

-- query month by income, sort frow worst to best
SELECT 
    TO_CHAR(purchases.date, 'Month') AS month, 
    SUM(purchases.amount) AS income
FROM purchases
WHERE purchases.date >= (CURRENT_DATE - INTERVAL '12 months')
GROUP BY month
ORDER BY income DESC;


-- drivers with expired_licenses sorted by longest expired date
SELECT app_users.name, app_users.surname,  drivers.id_driver, drivers_licenses.issued_on,drivers_licenses.expires_on
FROM app_users
JOIN drivers ON app_users.id_user = drivers.fk_user
JOIN drivers_licenses ON drivers.fk_license = drivers_licenses.id_license
WHERE drivers_licenses.expires_on < now()
ORDER BY drivers_licenses.expires_on ASC;

--- sum of fines for each inspector
select ticket_inspectors.id_inspector, app_users.name, app_users.surname, coalesce(sum(fines.amount), 0)  as "fines sum"
from app_users inner join ticket_inspectors on app_users.id_user = ticket_inspectors.fk_user
left join fines on ticket_inspectors.id_inspector = fines.fk_inspector
where fines.issue_date >= current_date - interval '1 year'
group by ticket_inspectors.id_inspector, app_users.name, app_users.surname order by "fines sum" desc;

-- count of lines passing through each stop
select stops.id_stop, stops.name, count(lines.id_line) as "lines passing through"
from stops inner join path_stops on stops.id_stop = path_stops.id_stop
    inner join paths on path_stops.id_path = paths.id_path
    inner join lines on paths.id_path =  lines.fk_main_path
group by stops.id_stop, stops.name order by "lines passing through" desc;

-- rides per hour for each stop
select stops.id_stop, stops.name, coalesce(sum(60/lines.avg_frequency), 0) as "rides per hour"
from stops left join path_stops on stops.id_stop = path_stops.id_stop
    left join paths on path_stops.id_path = paths.id_path
    left join lines on paths.id_path =  lines.fk_main_path
group by stops.id_stop, stops.name order by "rides per hour" desc;

-- rides per vehicle
select vehicles.id_vehicle, vehicles.vehicle_number, vehicles.type, count(rides.id_ride) as "number of rides"
from vehicles inner join rides on vehicles.id_vehicle = rides.fk_vehicle
group by vehicles.id_vehicle, vehicles.vehicle_number, vehicles.type order by "number of rides" desc;

-- sum of ticket costs for each passenger
select passengers.id_passenger, app_users.name, app_users.login, sum(ticket_types.price) as "cost sum"
from app_users inner join passengers on app_users.id_user = passengers.fk_user
inner join tickets on passengers.id_passenger = tickets.fk_passenger
inner join ticket_types on tickets.fk_ticket_type = ticket_types.id_ticket_type
group by passengers.id_passenger, app_users.login, app_users.name order by "cost sum" desc;