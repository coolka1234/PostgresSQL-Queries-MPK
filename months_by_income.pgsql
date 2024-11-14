-- query month by income, sort frow worst to best
SELECT 
    date_part('month', purchases.date) AS month, 
    SUM(purchases.amount) AS total_income_per_month
FROM purchases
GROUP BY month
ORDER BY month ASC;