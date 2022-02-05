# InsightsScraper

This is a scraper that fetches data from the Santiment Crypto API and stores it in CSV files.
The CSV files can be read by `pandas.csv_read(file)` without any extra processing.

## Prerequistites

Some of the data fetched is behind a paywall. At the time of writing this, the paywalled crypto news insights are
around 200.
In order to fetch these insights, obtain a PRO apikey and set it as the environment variable SANTIMENT_API_KEY.

## Crypto news data

This scraper can fetch and export crypto-related news articles that are called insights in the API.
There are around 1100 insights. This data can be combined with an external dataset like http://qwone.com/~jason/20Newsgroups/
to write a text classifier. This external dataset contains 20000 news articles across 20 categories,
which on average amounts to 1000 news articles per category - the same as our crypto related data.