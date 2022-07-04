
-- Airbnb DATA EXPLORATION


-- DATA CLEANING


SELECT * FROM listings;
SELECT * FROM reviews;


-- Standardize Date Format


SELECT CONVERT(Date,date)
FROM reviews;

ALTER TABLE reviews
ADD DateConverted Date;

UPDATE reviews
SET DateConverted = CONVERT(Date,date)

ALTER TABLE reviews
DROP COLUMN date;



-- Changing the columns name to avoid confusions


EXEC sp_rename 'listings.id','listing_id','COLUMN';

EXEC sp_rename 'listings.review_scores_rating','rating','COLUMN';

EXEC sp_rename 'reviews.id','review_id','COLUMN';



-- SETTING rating to 0 Where rating is null


SELECT * FROM listings
WHERE rating is Null;

UPDATE listings 
SET rating = 0 
WHERE rating IS NULL;



-- Converting rating 'out of 100' to 'out of 10'

UPDATE listings 
SET rating = rating/10;



-- Converting the data type of price column from nvarchar to float


UPDATE listings
SET price = RIGHT(price,len(price)-1)

ALTER TABLE listings
ADD PriceConverted float;

UPDATE listings
SET PriceConverted = TRY_CONVERT(float,price)

ALTER TABLE listings
DROP COLUMN price;




-- DATA EXPLORATION 


-- Number of reviews that is given for each property


SELECT number_of_reviews, COUNT(listing_id) AS Review_counts
FROM listings
GROUP BY number_of_reviews
ORDER BY COUNT(listing_id) DESC;



-- Overall Satisfaction Count by each rating


SELECT rating, SUM(number_of_reviews) AS os_count
FROM listings
WHERE rating <> 0
GROUP BY rating
ORDER BY rating;



-- Count of each accomodation value to understand where is the most availability


SELECT listing_id, name,neighbourhood_cleansed, accommodates
FROM listings
ORDER BY accommodates DESC



-- On which price, most of the properties are available?


SELECT PriceConverted, COUNT(listing_id) 
FROM listings
GROUP BY PriceConverted
ORDER BY COUNT(listing_id) DESC;



-- Costliest property under each neighbourhood


SELECT neighbourhood_cleansed, MAX(PriceConverted) as max_price
FROM listings
GROUP BY neighbourhood_cleansed
ORDER BY MAX(PriceConverted) DESC;



-- Who reviewed maximum times for same house (visited same house maximum times) and what is the price of that house


SELECT TOP 1 l.listing_id,l.PriceConverted,l.name,r.reviewer_id, COUNT(r.reviewer_id) AS No_of_times_reviewed , r.reviewer_name 
FROM reviews r
INNER JOIN listings l
ON r.listing_id = l.listing_id
GROUP BY l.listing_id,l.PriceConverted,l.name,r.reviewer_id,r.reviewer_name
ORDER BY COUNT(r.reviewer_id) DESC;



-- Count of bedrooms listings 


SELECT bedrooms, COUNT(listing_id) AS Bedrooms_count
FROM listings
WHERE bedrooms <> 0 AND bedrooms IS NOT NULL 
GROUP BY bedrooms
ORDER BY COUNT(listing_id) DESC;



-- What are the top 10 neighbourhoods with the most reviews


SELECT TOP 10 neighbourhood_cleansed, COUNT(number_of_reviews) as neighbourhood_review_count
FROM listings
GROUP BY neighbourhood_cleansed
ORDER BY COUNT(number_of_reviews) DESC;



-- What is the average price and Which properties having price is greater than average price


SELECT AVG(PriceConverted) FROM listings;

SELECT listing_id, name, property_type, room_type, PriceConverted
FROM listings
WHERE PriceConverted >= (SELECT AVG(PriceConverted) FROM listings)



--What is the most common room type in every neighbourhood


WITH neighbourhood AS 
(
SELECT neighbourhood_cleansed, room_type, COUNT(room_type) AS room_count
FROM listings 
GROUP BY neighbourhood_cleansed,room_type)

SELECT a.neighbourhood_cleansed, room_type, room_count
FROM neighbourhood a
INNER JOIN (SELECT neighbourhood_cleansed,MAX(COUNT(room_type)) OVER(PARTITION BY neighbourhood_cleansed) AS max_room_count FROM listings GROUP BY neighbourhood_cleansed,room_type) b
ON a.room_count = b.max_room_count
AND a.neighbourhood_cleansed = b.neighbourhood_cleansed
GROUP BY a.neighbourhood_cleansed, room_type, room_count










