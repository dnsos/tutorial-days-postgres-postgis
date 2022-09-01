# Day 4: More queries and ...

## Refining the toilets-within-radius finder

Yesterday I already managed to find all toilets within a certain radius around a point location.

Today I would like to refine this query, so that only toilets are returned that satisfy certain conditions (e.g. only toilets which are "barrierefrei" _and_ have a "Wickeltisch" or only only toilets that accept NFC payment).

This seems rather complex. I will document a few queries on the way here.

Selecting all toilets and their features as an array (this excludes toilets without any of the features):

```sql
-- Luckily we can use aggregation functions even though they are not included in the GROUP BY query:
SELECT toilet_features.toilet_id, array_agg(features.name)
-- We have to start from the toilet_features:
FROM toilet_features
JOIN features ON features.id = toilet_features.feature_id
-- We want distinct toilets, so we group by toilet_id:
GROUP BY toilet_features.toilet_id;
```

Next step, I managed to get the individual toilets with a list of their features:

```sql
SELECT toilets.id, toilets.address, toilets_feature_list.features, toilets.geometry
FROM toilets
-- We join the toilets.id on the toilet_id of our feature aggregation list (toilets_feature_list):
JOIN (
  -- This inner query is the same as the one above:
	SELECT toilet_features.toilet_id, array_agg(features.name) AS features
	FROM toilet_features
	JOIN features ON features.id = toilet_features.feature_id
	GROUP BY toilet_features.toilet_id
-- The alias is important here, so that we can make use of the results in the outer SELECT (toilets_feature_list.features):
) AS toilets_feature_list ON toilets_feature_list.toilet_id = toilets.id;
```

(I think this only includes toilets that have at leat one feature...)

WIP query:

```sql
SELECT toilet_id, COUNT(*) FROM toilet_features GROUP BY toilet_id HAVING COUNT(*) >= 2 ORDER BY COUNT(*) DESC;
```
