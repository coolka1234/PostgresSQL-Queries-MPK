SELECT 
    vehicles.*, 
    COUNT(technical_issues.id_technical_issue) AS count_issues
FROM vehicles
JOIN technical_issues ON vehicles.id_vehicle = technical_issues.fk_vehicle
GROUP BY vehicles.id_vehicle
ORDER BY count_issues DESC;
