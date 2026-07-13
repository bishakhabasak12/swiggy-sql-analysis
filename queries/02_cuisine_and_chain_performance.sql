-- ============================================================
-- Question: What are the most popular cuisines, and which
-- restaurant chains perform best (by ratings, filtered for
-- statistical relevance)?
-- ============================================================

-- NOTE: `cuisine` is often a comma-separated string like
-- "North Indian, Chinese, Mughlai". SQLite doesn't have a
-- clean built-in split; the recommended path is to explode
-- this into a separate cuisine_lookup table during data
-- cleaning (in Python/pandas) before loading here. The query
-- below assumes such a table exists. If you keep cuisine as
-- a raw string instead, use LIKE-based matching (slower, less
-- exact — shown as a fallback further down).

-- ------------------------------------------------------------
-- 1. Most popular cuisines (requires exploded cuisine_lookup table:
--    columns: restaurant_id, cuisine)
-- ------------------------------------------------------------
-- SELECT
--     cuisine,
--     COUNT(DISTINCT restaurant_id) AS restaurant_count
-- FROM cuisine_lookup
-- GROUP BY cuisine
-- ORDER BY restaurant_count DESC
-- LIMIT 15;

-- Fallback if cuisine is left as a raw comma-separated string:
SELECT
    CASE
        WHEN cuisine LIKE '%North Indian%' THEN 'North Indian'
        WHEN cuisine LIKE '%South Indian%' THEN 'South Indian'
        WHEN cuisine LIKE '%Chinese%'      THEN 'Chinese'
        WHEN cuisine LIKE '%Fast Food%'    THEN 'Fast Food'
        WHEN cuisine LIKE '%Bakery%'       THEN 'Bakery'
        WHEN cuisine LIKE '%Desserts%'     THEN 'Desserts'
        ELSE 'Other'
    END AS cuisine_bucket,
    COUNT(*) AS restaurant_count
FROM restaurants
GROUP BY cuisine_bucket
ORDER BY restaurant_count DESC;

-- ------------------------------------------------------------
-- 2. Top restaurant chains by branch count, with average rating
--    (only chains with a meaningful branch count are shown)
-- ------------------------------------------------------------
SELECT
    name,
    COUNT(*) AS branch_count,
    ROUND(AVG(rating), 2) AS avg_rating,
    SUM(CAST(rating_count AS INTEGER)) AS total_ratings   -- adjust cast once rating_count is cleaned to numeric
FROM restaurants
WHERE rating IS NOT NULL
GROUP BY name
HAVING COUNT(*) >= 10
ORDER BY branch_count DESC
LIMIT 20;

-- ------------------------------------------------------------
-- 3. Best-rated chains, filtered for statistical relevance
--    (rating_count >= 100 avoids single-review outliers skewing results)
-- ------------------------------------------------------------
SELECT
    name,
    COUNT(*) AS branch_count,
    ROUND(AVG(rating), 2) AS avg_rating
FROM restaurants
WHERE rating IS NOT NULL
  AND CAST(rating_count AS INTEGER) >= 100
GROUP BY name
HAVING COUNT(*) >= 5
ORDER BY avg_rating DESC
LIMIT 20;
