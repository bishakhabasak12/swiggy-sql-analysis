"""
clean_data.py
Cleans the raw Swiggy restaurants CSV so it's ready to load into SQLite.

Fixes:
- rating: '--' -> empty (NULL)
- rating_count: 'Too Few Ratings' -> empty, '50+ ratings' -> 50, '100+ ratings' -> 100, etc.
- cost: strips any non-numeric characters just in case (currency symbols, text)

Run with:
    python clean_data.py
"""

import pandas as pd
import re

INPUT_FILE = "data/swiggy.csv"
OUTPUT_FILE = "data/swiggy_clean.csv"


def clean_rating(value):
    """'--' or blank -> None, otherwise keep the numeric rating."""
    if pd.isna(value):
        return None
    value = str(value).strip()
    if value == "--" or value == "":
        return None
    try:
        return float(value)
    except ValueError:
        return None


def clean_rating_count(value):
    """
    'Too Few Ratings' -> None
    '50+ ratings'      -> 50
    '100+ ratings'     -> 100
    '1K+ ratings'      -> 1000
    already-numeric     -> unchanged
    """
    if pd.isna(value):
        return None
    value = str(value).strip()

    if "too few" in value.lower():
        return None

    # Grab the leading number, handle 'K' for thousands (e.g. "1K+")
    match = re.search(r"([\d.]+)\s*(K)?", value, re.IGNORECASE)
    if not match:
        return None

    number = float(match.group(1))
    if match.group(2):  # 'K' present
        number *= 1000

    return int(number)


def clean_cost(value):
    """Strip out anything that isn't a digit or decimal point."""
    if pd.isna(value):
        return None
    value = str(value)
    cleaned = re.sub(r"[^\d.]", "", value)
    if cleaned == "":
        return None
    try:
        return float(cleaned)
    except ValueError:
        return None


def main():
    print(f"Reading {INPUT_FILE} ...")
    df = pd.read_csv(INPUT_FILE)

    print("Original row count:", len(df))
    print("Columns found:", list(df.columns))

    if "rating" in df.columns:
        df["rating"] = df["rating"].apply(clean_rating)

    if "rating_count" in df.columns:
        df["rating_count"] = df["rating_count"].apply(clean_rating_count)

    if "cost" in df.columns:
        df["cost"] = df["cost"].apply(clean_cost)

    # Drop exact duplicate rows, if any
    before = len(df)
    df = df.drop_duplicates()
    after = len(df)
    print(f"Dropped {before - after} duplicate rows")

    df.to_csv(OUTPUT_FILE, index=False)
    print(f"Cleaned file saved to {OUTPUT_FILE}")
    print("Done. Sample of cleaned data:")
    print(df.head(5).to_string())


if __name__ == "__main__":
    main()
