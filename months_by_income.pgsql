SELECT purchases.*, extract(month from purchases.date) as month
FROM purchases
ORDER BY month ASC;