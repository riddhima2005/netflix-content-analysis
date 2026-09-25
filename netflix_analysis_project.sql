-- ============================================
-- NETFLIX CONTENT ANALYSIS
-- Database: netflix_analysis
-- ============================================


-- Check the total number of records
SELECT COUNT(*) AS total_records
FROM netflix_titles;


-- Check the distribution of Movies and TV Shows
SELECT type, COUNT(*) AS total_titles
FROM netflix_titles
GROUP BY type;

-- View the structure and data types of the dataset
DESCRIBE netflix_titles;

-- Check for missing values in key columns
SELECT
    COUNT(*) AS total_records,
    SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS missing_titles,
    SUM(CASE WHEN director IS NULL THEN 1 ELSE 0 END) AS missing_directors,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS missing_countries,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS missing_ratings,
    SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS missing_duration
FROM netflix_titles;

-- Check for duplicate records based on show ID
SELECT show_id, COUNT(*) AS duplicate_count
FROM netflix_titles
GROUP BY show_id
HAVING COUNT(*) > 1;

-- ============================================
-- EXPLORATORY DATA ANALYSIS (EDA)
-- ============================================

-- 1. Analyze the distribution of Movies and TV Shows
SELECT
    type,
    COUNT(*) AS total_titles
FROM netflix_titles
GROUP BY type
ORDER BY total_titles DESC;

-- 2. Identify the most common content ratings available on Netflix
SELECT
    rating,
    COUNT(*) AS total_titles
FROM netflix_titles
GROUP BY rating
ORDER BY total_titles DESC;

-- 3. Analyze the number of Netflix titles released each year
SELECT
    release_year,
    COUNT(*) AS total_titles
FROM netflix_titles
GROUP BY release_year
ORDER BY total_titles DESC;

-- 4. Identify the countries with the highest number of Netflix titles
SELECT
    country,
    COUNT(*) AS total_titles
FROM netflix_titles
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_titles DESC
LIMIT 10;

-- 5. Identify the most common content genres on Netflix
SELECT
    listed_in AS genre,
    COUNT(*) AS total_titles
FROM netflix_titles
GROUP BY listed_in
ORDER BY total_titles DESC
LIMIT 10;

-- 6. Calculate the average duration of Netflix movies
SELECT
    AVG(CAST(REPLACE(duration, ' min', '') AS UNSIGNED)) AS average_movie_duration
FROM netflix_titles
WHERE type = 'Movie'
  AND duration LIKE '%min%';
  
  -- 7. Identify directors with the highest number of titles on Netflix
SELECT
    director,
    COUNT(*) AS total_titles
FROM netflix_titles
WHERE director IS NOT NULL
GROUP BY director
ORDER BY total_titles DESC
LIMIT 10;

-- 8. Analyze how the number of titles added to Netflix has changed over time
SELECT
    YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS year_added,
    COUNT(*) AS total_titles
FROM netflix_titles
WHERE date_added IS NOT NULL
GROUP BY year_added
ORDER BY year_added;

-- 9. Compare the most common genres across Movies and TV Shows
SELECT
    type,
    listed_in AS genre,
    COUNT(*) AS total_titles
FROM netflix_titles
GROUP BY type, listed_in
ORDER BY type, total_titles DESC;

-- 10. Identify directors who have released more titles than the average number of titles per director
WITH director_counts AS (
    SELECT
        director,
        COUNT(*) AS total_titles
    FROM netflix_titles
    WHERE director IS NOT NULL
    GROUP BY director
)
SELECT
    director,
    total_titles
FROM director_counts
WHERE total_titles > (
    SELECT AVG(total_titles)
    FROM director_counts
)
ORDER BY total_titles DESC;


-- 11. Identify titles containing "Love" in the title
SELECT
    title,
    type,
    release_year,
    rating
FROM netflix_titles
WHERE title LIKE '%Love%'
ORDER BY release_year DESC;

-- 12. Compare the average release year of Movies and TV Shows
SELECT
    type,
    AVG(release_year) AS average_release_year
FROM netflix_titles
GROUP BY type
ORDER BY average_release_year DESC;

-- 13. Find the oldest and newest titles available on Netflix
SELECT
    MIN(release_year) AS oldest_release_year,
    MAX(release_year) AS newest_release_year
FROM netflix_titles;

-- 14. Compare the number of Movies and TV Shows added to Netflix each year
SELECT
    YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS year_added,
    type,
    COUNT(*) AS total_titles
FROM netflix_titles
WHERE date_added IS NOT NULL
GROUP BY year_added, type
ORDER BY year_added, type;

-- 15. Identify years in which Netflix added more than 500 titles
SELECT
    YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS year_added,
    COUNT(*) AS total_titles
FROM netflix_titles
WHERE date_added IS NOT NULL
GROUP BY year_added
HAVING COUNT(*) > 500
ORDER BY total_titles DESC;

-- 16. Find the percentage of Netflix content represented by Movies and TV Shows
SELECT
    type,
    COUNT(*) AS total_titles,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix_titles), 2) AS percentage_of_catalog
FROM netflix_titles
GROUP BY type
ORDER BY percentage_of_catalog DESC;


-- 17. Identify the most frequently occurring content ratings in Movies and TV Shows
SELECT
    type,
    rating,
    COUNT(*) AS total_titles
FROM netflix_titles
WHERE rating IS NOT NULL
GROUP BY type, rating
ORDER BY type, total_titles DESC;


-- 18. Identify the most common ratings for TV Shows
SELECT
    rating,
    COUNT(*) AS total_shows
FROM netflix_titles
WHERE type = 'TV Show'
GROUP BY rating
ORDER BY total_shows DESC
LIMIT 5;


-- 19. Compare the average movie duration by rating
SELECT
    rating,
    ROUND(AVG(CAST(REPLACE(duration, ' min', '') AS UNSIGNED)), 2) AS average_duration
FROM netflix_titles
WHERE type = 'Movie'
  AND duration LIKE '%min%'
GROUP BY rating
ORDER BY average_duration DESC;

-- 20. Identify the most recent titles added to Netflix
SELECT
    title,
    type,
    date_added,
    release_year
FROM netflix_titles
WHERE date_added IS NOT NULL
ORDER BY STR_TO_DATE(date_added, '%M %d, %Y') DESC
LIMIT 10;

-- ============================================
-- SQL CONCEPTS DEMONSTRATION
-- ============================================

-- 1. CASE: Categorize content by maturity level
SELECT
    title,
    rating,
    CASE
        WHEN rating IN ('TV-MA', 'R', 'NC-17') THEN 'Mature'
        WHEN rating IN ('TV-14', 'PG-13') THEN 'Teen'
        ELSE 'Family'
    END AS audience_category
FROM netflix_titles
LIMIT 20;


-- 2. CTE: Find the top 10 countries by title count
WITH country_counts AS (
    SELECT
        country,
        COUNT(*) AS total_titles
    FROM netflix_titles
    WHERE country IS NOT NULL
    GROUP BY country
)
SELECT
    country,
    total_titles
FROM country_counts
ORDER BY total_titles DESC
LIMIT 10;


-- 3. Subquery: Find titles released after the average release year
SELECT
    title,
    type,
    release_year
FROM netflix_titles
WHERE release_year > (
    SELECT AVG(release_year)
    FROM netflix_titles
)
ORDER BY release_year DESC;


-- 4. JOIN: Compare Movie and TV Show counts using derived tables
SELECT
    m.total_movies,
    t.total_shows
FROM (
    SELECT COUNT(*) AS total_movies
    FROM netflix_titles
    WHERE type = 'Movie'
) AS m
JOIN (
    SELECT COUNT(*) AS total_shows
    FROM netflix_titles
    WHERE type = 'TV Show'
) AS t
ON 1 = 1;


-- ============================================
-- FINAL PROJECT INSIGHTS
-- ============================================

-- • Movies make up 69.62% of the Netflix catalog.
-- • TV-MA and TV-14 are the most common ratings.
-- • 2018 had the most releases (1,147 titles).
-- • The US contributed the most titles, followed by India.
-- • Dramas and International Movies are the most common genre combination.
-- • Average movie duration is about 100 minutes.
-- • Rajiv Chilaka has the most titles among named directors (19).
-- • 2019 had the most Netflix additions (2,016 titles).
-- • TV Shows have a newer average release year than Movies.
-- • The dataset includes titles released from 1925 to 2021.

