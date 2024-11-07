SELECT 
    date_part('month', purchases.date) AS month, 
    SUM(purchases.amount) AS total_income
FROM purchases
GROUP BY month
ORDER BY month ASC;