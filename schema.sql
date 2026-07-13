-- ============================================================
-- Swiggy Restaurants Dataset — Schema
-- Source: Kaggle "Swiggy Restaurants Dataset" (ashishjangra27)
--         or the fuller "Swiggy Restaurant and Item Full Dataset" (lokeshparab)
-- ============================================================
-- NOTE: Column names below are based on the commonly published
-- version of this dataset. Before running, open your downloaded
-- CSV and confirm/adjust column names — Kaggle dataset versions
-- vary slightly (e.g. "cost" vs "cost_for_two", "cuisine" vs
-- "cuisines"). Update this file to match your actual headers.
-- ============================================================

DROP TABLE IF EXISTS restaurants;

CREATE TABLE restaurants (
    id              INTEGER PRIMARY KEY,   -- unique restaurant id
    name            TEXT,                  -- restaurant name
    city            TEXT,                  -- city listed on Swiggy
    rating          REAL,                  -- average rating (NULL/'--' in raw data — clean before load)
    rating_count    TEXT,                  -- number of ratings (raw data often has "100+", "1K+" etc. — clean to numeric)
    cost             REAL,                  -- approx cost for two (raw data has currency text — strip to numeric)
    cuisine         TEXT,                  -- comma-separated cuisine list, e.g. "North Indian, Chinese"
    lic_no          TEXT,                  -- FSSAI license number
    address         TEXT,                  -- restaurant address
    link            TEXT                   -- Swiggy restaurant page URL
);

-- ------------------------------------------------------------
-- OPTIONAL: only needed if you use the FULLER dataset
-- (lokeshparab version) which includes menu-level detail.
-- If you're using the smaller restaurant-only dataset, skip this.
-- ------------------------------------------------------------

DROP TABLE IF EXISTS menu_items;

CREATE TABLE menu_items (
    item_id         INTEGER PRIMARY KEY,
    restaurant_id   INTEGER,               -- FK -> restaurants.id
    item_name       TEXT,
    item_category   TEXT,                  -- e.g. "Starters", "Main Course", "Desserts"
    price           REAL,
    is_veg          INTEGER,               -- 1 = veg, 0 = non-veg (derive if not present)
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id)
);

-- ------------------------------------------------------------
-- Basic sanity checks to run right after loading data
-- ------------------------------------------------------------
-- SELECT COUNT(*) FROM restaurants;
-- SELECT COUNT(*) FROM restaurants WHERE rating IS NULL;
-- SELECT DISTINCT city FROM restaurants LIMIT 20;
