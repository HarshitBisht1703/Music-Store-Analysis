use music_database;

-- Question set - 1

-- 1. Who is the senior most employee based on job title?

select *
from employee
order by levels desc
limit 1;

-- 2. Which countries have the most Invoices? 

select billing_country Most_Invoices_Country, count(customer_id) as `Count`
from invoice
group by billing_country
order by 2 desc;

-- 3. What are top 3 values of total invoice? 

select round(total,1) Total
from invoice
order by 1 desc
limit 3;

-- 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
-- 	  Write a query that returns one city that has the highest sum of invoice totals. 
--    Return both the city name & sum of all invoice totals.

select billing_city, round(sum(total),1) as Total
from invoice
group by 1
order by 2 desc
limit 1;

-- 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--    Write a query that returns the person who has spent the most money 

select i.customer_id, c.first_name, c.last_name, round(sum(i.total),1) Total_money_spent
from invoice i inner join customer c
using (customer_id)
group by 1, 2, 3
order by 4 desc
limit 1;

---------------------------------------------------------------------------------------------------------

-- Question set - 2

-- 1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
--    Return your list ordered alphabetically by email starting with A

select distinct c.email,  c.first_name, c.last_name, g.name `Genre`
from customer c 
inner join Invoice i using (customer_id)
inner join Invoice_Line il using (Invoice_ID)
inner join Track t using (track_id)
inner join Genre g using (Genre_id)
where g.name = "Rock"
order by 1;


select distinct c.email,  c.first_name, c.last_name
from customer c inner join Invoice i
using (customer_id)
inner join Invoice_line il
using (Invoice_id)
where track_id IN 
				(select track_ID
                from Track t inner join Genre g
                using (Genre_ID)
                where g.`Name` =  "Rock");

-- 2. Let's invite the artists who have written the most rock music in our dataset. 
--    Write a query that returns the Artist name and total track count of the top 5 rock bands

select a.artist_id, a.`Name`, count(a.artist_id) as `Total Track Count`
from artist a 
inner join album al using (Artist_id)
inner join Track t using (Album_id)
where genre_ID IN 
				(select genre_id
                from track t inner join genre g
                using (genre_id)
                where g.`Name` = "Rock")
group by 1, 2
order by 3 desc
limit 5;

select a.artist_id, a.name, count(a.artist_id) as Number_of_songs
from track t
inner join album al using (Album_id)
inner join artist a using (Artist_id)
inner join genre g using (genre_id)
where g.name = "Rock"
group by 1, 2
order by 3 desc
limit 5;

-- 3. Return all the track names that have a song length longer than the average song length. 
--    Return the Name and Milliseconds for each track. 
--    Order by the song length with the longest songs listed first

with cte as 
(
select round(avg(Milliseconds),0) as Track_avg_length
from Track
)
select t.`Name`, t.milliseconds
from track t inner join cte c 
where t.milliseconds > c.Track_avg_length
order by 2 desc;

---------------------------------------------------------------------------------------------------------

-- Question set - 3

-- 1. Find how much amount spent by each customer on the best selling artists? 
--    Write a query to return customer ID, customer name, artist name and total spent 

with best_selling as 
(
	select a.artist_ID, a.name, 
	round(sum(il.unit_price * il.quantity), 2) Total_Spent
	from artist a 
	inner join album al using (Artist_ID)
	inner join Track t using (Album_ID)
	inner join Invoice_line il using (Track_ID)
	group by 1, 2
	order by 3 desc
	limit 1
)
select c.customer_ID, c.first_name, c.last_name, bs.name Artist_name, 
round(sum(il.unit_price * il.quantity), 2) Amount_spent
from customer c
inner join Invoice i using (Customer_ID)
inner join Invoice_line il using (Invoice_ID)
inner join Track t using (Track_ID)
inner join Album al using (Album_ID)
inner join best_selling bs using (Artist_ID)
group by 1, 2, 3, 4
order by 5 desc;

-- 2. We want to find out the most popular music Genre for each country. 
--    We determine the most popular genre as the genre with the highest amount of purchases. 
--    Write a query that returns each country along with the top Genre. 
--    For countries where the maximum number of purchases is shared return all Genres

with cte as 
(
	select i.Billing_country, g.name, sum(il.quantity) Purchase,
	dense_rank() over (partition by i.billing_country order by sum(il.quantity) desc) as `Rank`
	from invoice i
	inner join invoice_line il using (Invoice_ID)
	inner join Track t using (Track_ID)
	inner join Genre g using (Genre_ID)
	group by 1, 2
	order by 1
)
select Billing_country, name, Purchase
from cte
where `Rank` = 1;

-- 3. Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount.

with cte as 
(
	select c.Country, c.customer_ID, c.first_name, c.last_name, round(sum(i.total),2) as Total_Spent,
	dense_rank() over (Partition by c.country order by round(sum(i.total),2) desc) as `Rank`
	from customer c
	inner join Invoice i using (Customer_ID)
	group by 1, 2, 3, 4
	order by 1
)
select Country, customer_ID, First_name, Last_name, Total_spent
from cte
where `Rank` = 1
order by 2;