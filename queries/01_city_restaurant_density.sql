-- ============================================================
-- Question: Which cities have the most restaurants listed on
-- Swiggy, and how concentrated is the market?
-- ============================================================

-- 1. Top 15 cities by number of restaurants listed
SELECT
    city,
    COUNT(*) AS restaurant_count
FROM restaurants
GROUP BY city
ORDER BY restaurant_count DESC
LIMIT 15;

-- 2. Cities with only a handful of restaurants (underserved / niche markets)
-- Useful for a "market gap" angle in your write-up
SELECT
    city,
    COUNT(*) AS restaurant_count
FROM restaurants
GROUP BY city
HAVING COUNT(*) <= 3
ORDER BY restaurant_count DESC;

-- 3. Market concentration: what % of all restaurants live in the top 10 cities?
WITH city_counts AS (
    SELECT city, COUNT(*) AS cnt
    FROM restaurants
    GROUP BY city
),
ranked AS (
    SELECT city, cnt,
           RANK() OVER (ORDER BY cnt DESC) AS rnk
    FROM city_counts
)
SELECT
    SUM(CASE WHEN rnk <= 10 THEN cnt ELSE 0 END) AS top10_city_restaurants,
    (SELECT SUM(cnt) FROM city_counts) AS total_restaurants,
    ROUND(
        100.0 * SUM(CASE WHEN rnk <= 10 THEN cnt ELSE 0 END)
        / (SELECT SUM(cnt) FROM city_counts), 1
    ) AS pct_in_top10
FROM ranked;

-- ============================================================
-- Extension idea (to make this stand out vs. other Swiggy
-- SQL projects): join in a small reference table of city
-- population (manually sourced from Census/Wikipedia for your
-- top 20-30 cities) to compute "restaurants per 100k population"
-- — that reframes raw counts into a genuine market-gap insight.
-- ============================================================
