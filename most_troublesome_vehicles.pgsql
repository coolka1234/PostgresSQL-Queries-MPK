SELECT vehicles.* FROM vehicles
JOIN technical_issues ON vehicles.id_vehicle = technical_issues.fk_vehicle
GROUP BY vehicles.id_vehicle
