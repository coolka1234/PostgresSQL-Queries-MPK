SELECT app_users.*, fines.deadline
FROM app_users
JOIN passengers ON app_users.id_user = passengers.fk_user
JOIN fines ON passengers.id_passenger = fines.fk_passenger
WHERE fines.deadline < now()
ORDER BY fines.deadline ASC;