# Day 4: More queries

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

Okay, I've found a way to filter the previous query so that it only returns toilets that have a specific set of features:

```sql
SELECT toilets.id, toilets.address, toilets_feature_list.features, toilets.geometry
FROM toilets
JOIN (
  -- We added the ORDER BY here, so that later we can query for an array of features that we have sorted alphabetically:
  SELECT toilet_features.toilet_id, array_agg(features.name ORDER BY features.name) AS features
  FROM toilet_features
  JOIN features
    ON features.id = toilet_features.feature_id
  GROUP BY toilet_features.toilet_id
) AS toilets_feature_list
    ON toilets_feature_list.toilet_id = toilets.id
    -- The important part is this JOIN matcher.
    -- We have to cast the features list to a text array, because otherwise PostgreSQL doesn't know what it's dealing with.
    -- We then need to compare the array of features with an array of our desired features.
    -- Note that for PostgreSQL an array is equal when it's contents are equal.
    -- This is not ideal, because it relies on the order (alphabetical) of desired features that we pass.
    -- E.g. searching for ARRAY['Urinal','Wickeltisch'] will not yield any results.
    AND toilets_feature_list.features::TEXT[] = ARRAY['Barrierefrei','Urinal','Wickeltisch'];
```

**Oookay, the above queries have a flaw.** They check if the feature arrays are equal. However we want to check if the `toilets_feature_list.features` array contains our constructed array of e.g. `ARRAY['Barrierefrei','Wickeltisch']`. `toilets_feature_list.features` may have more features than what we have queried for, as long as our queried features are contained, we want to see that result anyways.

We can use the "contains operator" for that. I haven't found documentation besides StackOverflow, so I can not link to the docs. Basically the operator works like this:

```sql
ARRAY['array','with','required','values','and','maybe','more'] @> ARRAY['array','with','required','values']
```

If the right-side array is contained in the left-side array (no matter the order), we get `TRUE`.

We can now fix our query and additionally add the possibility to query for payment methods as well:

```sql
SELECT toilets.id, toilets.address, toilets_feature_list.features, toilets.geometry, tpm.payment_methods
FROM toilets
-- First JOIN with toilet_id + feature array:
JOIN (
  SELECT toilet_features.toilet_id, array_agg(features.name ORDER BY features.name) AS features
  FROM toilet_features
  JOIN features
    ON features.id = toilet_features.feature_id
  GROUP BY toilet_features.toilet_id
) AS toilets_feature_list
    ON toilets_feature_list.toilet_id = toilets.id
    -- Match all rows that contain at least 'Barrierefrei' and 'Wickeltisch':
    AND toilets_feature_list.features::TEXT[] @> ARRAY['Barrierefrei','Wickeltisch']
-- Second JOIN with toilet_id + payment method array:
JOIN (
  SELECT toilet_payment_methods.toilet_id, array_agg(payment_methods.name ORDER BY payment_methods.name) AS payment_methods
  FROM toilet_payment_methods
  JOIN payment_methods
    ON payment_methods.id = toilet_payment_methods.payment_method_id
  GROUP BY toilet_payment_methods.toilet_id
) AS tpm
    ON tpm.toilet_id = toilets.id
    -- Match all rows that contain at least 'NFC':
    AND tpm.payment_methods::TEXT[] @> ARRAY['NFC'];
```

As a smaller, additional query, we could e.g. search which toilets provide a _Wickeltisch_ and are free-of-charge:

```sql
SELECT toilets.id, toilets.address, toilets_feature_list.features, toilets.geometry
FROM toilets
JOIN (
  SELECT toilet_features.toilet_id, array_agg(features.name ORDER BY features.name) AS features
  FROM toilet_features
  JOIN features
    ON features.id = toilet_features.feature_id
  GROUP BY toilet_features.toilet_id
) AS toilets_feature_list
    ON toilets_feature_list.toilet_id = toilets.id
    AND toilets_feature_list.features::TEXT[] @> ARRAY['Wickeltisch']
WHERE toilets.price = 0;
```

**No toilets found**. If we increase the price threshold to e.g. 0.5, we start finding toilets.

> Note that this does not take into account the pilot project of making 50 toilets free-of-charge. I haven't updated the price yet (see [Day 2](/day_02.md)).

## Getting back to the list of free toilets

I want to taake another look at this. First I'll add the free toilet dataset to a regular table:

```sql
CREATE TABLE "free_toilets_of_pilot"(
  "location" VARCHAR(255),
  "district" VARCHAR(255),
  "type" VARCHAR(255),
  "opened_at" VARCHAR(255)
);

COPY "free_toilets_of_pilot"("location", "district", "type", "opened_at")
FROM '/path/to/repo/assets/data/anlage_standorte-fuer-die-entgeltlose-benutzung-von-50-berliner-toiletten.csv'
DELIMITER ';'
CSV HEADER;
```

I would then use the `location` column to try to match it with the `toilets.address` column. This is tricky because both have (differing) additions to the actual address, most of the time.

Some examples that I collected manually and that I would need to match programmatically:

<table>
  <thead>
    <tr>
      <th>Value in toilets dataset</th>
      <th>Value in <i>free</i> toilets dataset</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>An der Wuhle ggü. 56 (0-24 Uhr)</td>
      <td>An der Wuhle ggü. 56 vor Ulmenstr.</td>
    </tr>
    <tr>
      <td>Elsterwerdaer Platz 1-3 (0-24 Uhr)</td>
      <td>Elsterwerdaer Platz 1-3 vor U-Bahnhof Elsterwerdaer Platz</td>
    </tr>
    <tr>
      <td>Mariannenplatz 2-3 (0-24 Uhr)</td>
      <td>Mariannenplatz 2-3</td>
    </tr>
  </tbody>
</table>

Not sure how these can be matched.
