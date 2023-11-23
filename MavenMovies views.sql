USE [Project 3]

--How many customers are currently active in the system ?
SELECT COUNT(*) AS Total_customers_active_in_system FROM [dbo].[Customer_lookup]
WHERE active='1'

--How many staff members are registered ?
SELECT COUNT(*) AS Total_Staff_registered FROM [dbo].[Staff_lookup] 
WHERE active='1'

--What are the most popular film categories based on the number of rentals ?
SELECT film_category, COUNT(rental_id) AS Rental_count
FROM [dbo].[Product_lookup] 
INNER JOIN [dbo].[Payments] ON [dbo].[Product_lookup].[product_id] = [dbo].[Payments].[product_id]
INNER JOIN [dbo].[Customer_lookup] ON [dbo].[Payments].[customer_id] = [dbo].[Customer_lookup].[customer_id]
INNER JOIN [dbo].[Rental_lookup] ON [dbo].[Customer_lookup].[customer_id] = [dbo].[Rental_lookup].[customer_id]
GROUP BY film_category
ORDER BY Rental_count DESC;

--Which films and top costumers that have the highest revenue generated ?
SELECT film_title ,first_name ,last_name ,revenue
FROM [dbo].[Product_lookup]
INNER JOIN [dbo].[Payments] 
ON [dbo].[Product_lookup].[product_id] = [dbo].[Payments].[product_id]
INNER JOIN [dbo].[Customer_lookup] 
ON [dbo].[Customer_lookup].[customer_id] = [dbo].[Payments].[customer_id]
WHERE revenue = (SELECT MAX(revenue) FROM [dbo].[Payments])

--What is the total revenue generated by the rental business ?
SELECT SUM(revenue) AS Total_revenue
FROM [dbo].[Payments] 

--How does revenue vary across different film categories ?
SELECT film_category ,SUM(revenue) AS revenue
FROM [dbo].[Product_lookup]
INNER JOIN [dbo].[Payments] 
ON [dbo].[Product_lookup].[product_id] = [dbo].[Payments].[product_id]
GROUP BY film_category

--How many films are currently in inventory ?
SELECT COUNT(inventory_id) AS Number_of_films_in_inventory
FROM [dbo].[Product_lookup]
WHERE inventory_id<>'NULL'

--Which films are frequently rented out ?
SELECT TOP 8 film_title, COUNT(rental_id) AS Movies_frequently_rented_out
FROM [dbo].[Product_lookup]
INNER JOIN [dbo].[Payments] ON [dbo].[Product_lookup].[product_id] = [dbo].[Payments].[product_id]
INNER JOIN [dbo].[Customer_lookup] ON [dbo].[Customer_lookup].[customer_id] = [dbo].[Payments].[customer_id]
INNER JOIN [dbo].[Rental_lookup] ON [dbo].[Rental_lookup].[customer_id] = [dbo].[Customer_lookup].[customer_id]
GROUP BY film_title
ORDER BY Movies_frequently_rented_out DESC;

--What is the trend in payments over time ?
SELECT SUM(revenue) AS Total_payment ,CAST(payment_date AS DATE) AS Payment_date
FROM [dbo].[Payments] 
GROUP BY CAST(payment_date AS DATE)

--What is the average duration of film rentals?
SELECT film_title ,
CAST(MIN(rental_date) AS DATE) AS rental_date ,CAST(MAX(return_date) AS DATE) AS return_date ,
AVG(DATEDIFF(day ,rental_date ,return_date)) AS average_duration
FROM [dbo].[Product_lookup]
INNER JOIN [dbo].[Payments] ON [dbo].[Product_lookup].[product_id] = [dbo].[Payments].[product_id]
INNER JOIN [dbo].[Customer_lookup] ON [dbo].[Customer_lookup].[customer_id] = [dbo].[Payments].[customer_id]
INNER JOIN [dbo].[Rental_lookup] ON [dbo].[Rental_lookup].[customer_id] = [dbo].[Customer_lookup].[customer_id]
GROUP BY film_title

--Which staff members have processed the most rentals ?
SELECT TOP 1 first_name ,last_name ,COUNT(rental_id) AS Num_most_processed_rentals
FROM [dbo].[Staff_lookup]
INNER JOIN [dbo].[Rental_lookup] ON [dbo].[Staff_lookup].[staff_id] = [dbo].[Rental_lookup].[staff_id]
GROUP BY first_name ,last_name 
ORDER BY Num_most_processed_rentals DESC

--How does the staff's performance impact revenue ?
SELECT first_name ,last_name ,COUNT(active) AS performance_count ,SUM(revenue) AS total_revenue
FROM [dbo].[Payments]
INNER JOIN [dbo].[Staff_lookup] ON [dbo].[Staff_lookup].[staff_id] = [dbo].[Payments].[staff_id]
GROUP BY first_name ,last_name ,active

--What are the most popular film categories in each city?
SELECT COUNT(film_category) AS category_frequency ,city
FROM [dbo].[Product_lookup]
INNER JOIN [dbo].[Payments] ON [dbo].[Product_lookup].[product_id] = [dbo].[Payments].[product_id]
INNER JOIN [dbo].[Customer_lookup] ON [dbo].[Customer_lookup].[customer_id] = [dbo].[Payments].[customer_id]
GROUP BY city
ORDER BY category_frequency DESC

--How does revenue vary across different districts ?
WITH Revenue_sum_over_district AS (
SELECT SUM(revenue) AS revenue_sum ,district 
FROM [dbo].[Payments]
INNER JOIN [dbo].[Customer_lookup] 
ON [dbo].[Customer_lookup].[customer_id] = [dbo].[Payments].[customer_id]
GROUP BY district
)
SELECT * FROM Revenue_sum_over_district WHERE district <> ''