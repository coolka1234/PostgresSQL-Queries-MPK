-- query users who are most overdue with their fines
SELECT app_users.name, app_users.surname, app_users.phone_number, app_users.email, fines.deadline, fines.amount
FROM app_users
JOIN passengers ON app_users.id_user = passengers.fk_user
JOIN fines ON passengers.id_passenger = fines.fk_passenger
WHERE fines.deadline < now()
ORDER BY fines.deadline ASC;