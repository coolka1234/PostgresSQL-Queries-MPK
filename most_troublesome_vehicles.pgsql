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
