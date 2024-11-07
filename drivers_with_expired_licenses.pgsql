SELECT app_users.name, app_users.surname,  drivers.id_driver, drivers_licenses.issued_on,drivers_licenses.expires_on
FROM app_users
JOIN drivers ON app_users.id_user = drivers.fk_user
JOIN drivers_licenses ON drivers.fk_license = drivers_licenses.id_license
WHERE drivers_licenses.expires_on < now()
ORDER BY drivers_licenses.expires_on ASC;