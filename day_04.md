# Day 4: More queries and ...

## Refining the toilets-within-radius finder

Yesterday I already managed to find all toilets within a certain radius around a point location.

Today I would like to refine this query, so that only toilets are returned that satisfy certain conditions (e.g. only toilets which are "barrierefrei" _and_ have a "Wickeltisch" or only only toilets that accept NFC payment).

WIP query:

```sql
SELECT toilet_id, COUNT(*) FROM toilet_features GROUP BY toilet_id HAVING COUNT(*) >= 2 ORDER BY COUNT(*) DESC;
```
