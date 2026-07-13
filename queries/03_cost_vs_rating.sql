-- ============================================================
-- Question: Do more expensive restaurants get better ratings,
-- or is there no meaningful relationship?
-- ============================================================

-- 1. Bucket restaurants into cost tiers and compare average rating
SELECT
    CASE
        WHEN cost < 200  THEN '1. Under ₹200'
        WHEN cost < 400  THEN '2. ₹200–399'
        WHEN cost < 600  THEN '3. ₹400–599'
        WHEN cost < 800  THEN '4. ₹600–799'
        ELSE '5. ₹800+'
    END AS cost_tier,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(rating), 2) AS avg_rating
FROM restaurants
WHERE cost IS NOT NULL AND rating IS NOT NULL
GROUP BY cost_tier
ORDER BY cost_tier;

-- 2. Same breakdown, but filtered to restaurants with a
--    meaningful number of ratings (avoids new/low-volume
--    restaurants skewing the average)
SELECT
    CASE
        WHEN cost < 200  THEN '1. Under ₹200'
        WHEN cost < 400  THEN '2. ₹200–399'
        WHEN cost < 600  THEN '3. ₹400–599'
        WHEN cost < 800  THEN '4. ₹600–799'
        ELSE '5. ₹800+'
    END AS cost_tier,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(rating), 2) AS avg_rating
FROM restaurants
WHERE cost IS NOT NULL
  AND rating IS NOT NULL
  AND CAST(rating_count AS INTEGER) >= 50
GROUP BY cost_tier
ORDER BY cost_tier;

-- 3. City-level view: does the cost/rating relationship hold
--    across India's biggest food markets, or does it vary by city?
SELECT
    city,
    CASE
        WHEN cost < 400 THEN 'Budget (<₹400)'
        ELSE 'Premium (₹400+)'
    END AS price_segment,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(rating), 2) AS avg_rating
FROM restaurants
WHERE city IN (
    SELECT city FROM restaurants
    GROUP BY city
    ORDER BY COUNT(*) DESC
    LIMIT 10          -- top 10 cities by restaurant count
)
AND cost IS NOT NULL AND rating IS NOT NULL
GROUP BY city, price_segment
ORDER BY city, price_segment;

-- ============================================================
-- What to look for in your write-up:
-- - Is the relationship monotonic (rating rises steadily with
--   price) or flat/non-linear? Flat/non-linear is the more
--   interesting, non-obvious finding for a portfolio.
-- - Does the pattern hold in every top city, or does it break
--   down in specific markets? Exceptions make for a stronger
--   narrative than "yes, expensive = better rated."
-- ============================================================
