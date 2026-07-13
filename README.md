# Swiggy Restaurants Analysis (SQL)

## Problem
Swiggy lists 148,000+ restaurants across India. This project uses SQL to
answer three business questions a growth/ops team at a food delivery
company would actually care about:

1. Where is the restaurant market concentrated, and where are the gaps?
2. Which cuisines and restaurant chains perform best, and are chain-scale
   and quality correlated?
3. Does price predict rating — and does that relationship hold across
   different price tiers?

## Data
- Source: [Swiggy Restaurants Dataset, Kaggle](https://www.kaggle.com/datasets/ashishjangra27/swiggy-restaurants-dataset)
- 148,541 restaurant records across 700+ Indian cities/localities
- Fields: id, name, city, rating, rating_count, cost, cuisine, lic_no, link, address

## Setup
1. Download the CSV from Kaggle and place it in a `data/` folder (not committed — add to `.gitignore`)
2. Run `clean_data.py` to clean the raw fields:
   - `rating`: `'--'` converted to NULL
   - `rating_count`: `'50+ ratings'` -> `50`, `'Too Few Ratings'` -> NULL, etc.
   - `cost`: stripped to a plain numeric value
3. Load into SQLite using `schema.sql`
4. Run the queries in `/queries` in order

## Findings

**1. The restaurant market is far more spread out than expected — it is not concentrated in a few big cities.**
The top 10 city/locality entries account for only 8% of all 148,541 listed restaurants (11,938 restaurants). Restaurant supply on Swiggy is spread thin across hundreds of localities rather than piled into a handful of metros.

**2. Bikaner — a Tier-2 city, not a metro — has more restaurants listed than any single neighborhood in Delhi, Mumbai, or Bangalore.**
Bikaner leads with 1,666 restaurants, ahead of Noida-1 (1,428) and Indirapuram, Delhi (1,279). Note: Swiggy's `city` field is often a specific delivery locality rather than a true city (e.g. "Koramangala,Bangalore," "Indiranagar,Bangalore"), so major metros likely dominate once their listings are aggregated back up to the true city level — Delhi alone shows up 4 times in the top 15 under different locality names.

**3. North Indian and Chinese cuisine dominate, but "Other" is the single largest bucket — cuisine tags are highly fragmented.**
North Indian (32,537) and Chinese (25,888) restaurants together make up ~39% of listings. However, "Other" is the largest single bucket at 36% (53,799 restaurants), meaning a huge share of restaurants serve cuisines outside the six major categories (Mughlai, Biryani, Continental, regional cuisines, etc.) — a real limitation of simple keyword-based cuisine bucketing on this dataset.

**4. Specialty dessert/bakery/ice-cream chains earn noticeably higher ratings than typical full-service restaurant chains.**
The highest-rated chains with 5+ branches are almost all dessert or bakery brands — Corner House Ice Cream (4.58), Mama Mia! Italian Ice Creams (4.55), Apsara Ice Creams (4.53), Theobroma (4.46) — outperforming the average full-service restaurant chain.

**5. Cost and rating are weakly, but consistently, correlated — and the biggest price segment is also the lowest-rated one.**
| Cost tier | Restaurant count | Avg rating |
|---|---|---|
| Under ₹200 | 9,117 | 3.88 |
| ₹200–399 | 38,944 | 3.86 |
| ₹400–599 | 9,738 | 3.98 |
| ₹600–799 | 1,967 | 4.07 |
| ₹800+ | 1,659 | 4.17 |

Rating rises steadily with price (3.86 → 4.17), but the effect is modest — a ~4x price increase only moves average rating by 0.3 points. More importantly, the ₹200–399 tier is both the **largest segment by far** (38,944 restaurants, ~26% of the dataset) and the **lowest-rated tier** — meaning most of what customers actually order from is also where quality is weakest on average.

## Recommendation
If advising Swiggy's ops/quality team, I'd prioritize quality-improvement programs (onboarding standards, hygiene audits, review-response nudges) specifically in the ₹200–399 price tier, since it is simultaneously the largest segment of the marketplace and the one dragging down the platform's average rating the most — improving it would have outsized impact on overall customer satisfaction compared to focusing on the smaller premium tiers, which are already performing well.

## Limitations
- The `city` field mixes true cities with specific localities/neighborhoods, which affects any city-level ranking (see Finding 2).
- Cuisine bucketing relies on simple keyword matching against a fixed list; more precise category mapping would reduce the size of the "Other" bucket.
- Ratings and rating counts reflect a single point-in-time scrape, not a time series — no trend analysis is possible with this dataset alone.

## What I'd extend next
- Normalize the `city` field to true city level (strip locality suffixes) and re-run the concentration/ranking analysis
- Join in city population data to compute restaurants-per-capita (true market-gap analysis)
- Compare against the Zomato dataset for a head-to-head city-by-city view
- Move this into Power BI/Tableau for an interactive version
