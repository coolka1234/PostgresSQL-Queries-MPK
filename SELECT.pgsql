SELECT app_users.*
FROM app_users
JOIN drivers ON app_users.id_user = drivers.fk_user
JOIN drivers_licenses ON drivers.fk_license = drivers_licenses.id_license
WHERE drivers_licenses.expires_on < now();