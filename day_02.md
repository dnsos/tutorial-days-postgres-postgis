# Day 2: Migrations and PostGIS queries

## The (failed) data migration of the 50 free toilets

My plan was to perform a data migration to update the `price` column on my `toilets` table if a toilet was included in the [dataset of 50 free-of-charge toilets](/assets/data/anlage_standorte-fuer-die-entgeltlose-benutzung-von-50-berliner-toiletten.csv). **I'm skipping this for now.**

The reason is that the dataset does not contain toilet ID's. I've made an attempt to pattern match via my `toilets.address` column with the _Standort_ column in the dataset. However, the _Standort_ entries match the `address` column only very irregularly, so my attempt of doing pattern matching in [`03-migrate-free-toilets.sql`](/sql/03-migrate-free-toilets.sql) was not successfull. In an ideal scenario, the toilet ID's would be provided. I might come back to the pattern matching approach at a later point (just for the exercise), but it is no priority.

## Migrations and schemas - some notes

The _migra_ tool has a little [explainer about the differences between these two approaches](https://databaseci.com/docs/migra/deploy-usage) for the source of truth of the database schema.

My learning from this is that (for my context) I find it preferrable to leave the schema truth with the app. I would usually not manage a database without an application that uses it, so the two would be very intertwined anyways.

A, for me, typical application would be a [Rails](https://rubyonrails.org/) app that has a very simple and mature ORM (_Active Record_) for handling migrations and the schema.

> Another interesting tool for handling schemas is the built-in [Schema Diff tool of pgAdmin](https://www.pgadmin.org/docs/pgadmin4/development/schema_diff.html).

## PostGIS exercises

Next, we want to take a look at the capabilities of PostGIS. PostGIS's website has a nice [section of spatial exercises that demonstrates different functions](https://postgis.net/workshops/postgis-intro/geometries_exercises.html). For the next part I will take inspiration from there.

Here are some questions I would like to answer using PostGIS:

> Thinking about these exercises and going through the PostGIS examples, I am realizing that I need more tables with spatial data, so that the exercises become more interesting.

In order to make some more interesting queries, we are first going to import some more data. I chose to use part of the [LOR data of Berlin](https://daten.odis-berlin.de/de/dataset/lor_planungsgraeume_2021/) (for compliance with the CC-BY-3.0 licence: The data originates from _Amt für Statistik Berlin-Brandenburg_). I have chosen this dataset for no particular reason, it's just to have some polygons in my PostGIS database. The data is available as a GeoJSON, so this will be another challenge: How can we import data from a GeoJSON into a PostGIS table?

### Importing the LOR GeoJSON

Okay, I thought this would be harder. It's not!

There is a command line tool called [ogr2ogr](https://gdal.org/programs/ogr2ogr.html) which (if run on the same server as the PostGIS database) is able to seamlessly import a GeoJSON file into a PostGIS table.

I have used the following query to import the file's contents:

```bash
ogr2ogr -f "PostgreSQL" PG:"dbname=berlin_toilets_app user=<me>" /path/to/repo/assets/data/lor_planungsraeume_2021.geojson -nln lors
```

> `-nln` is the table name that should be created for the data.

Now, this imported the data with some not-so-ideal column names, but for the purpose of this exploration I'm going to ignore this. (The type detection by the _ogr2ogr_ is great, by the way.)

### The challenge of different projections

PostGIS has a great [documentation on the different types of map projections](https://postgis.net/workshops/postgis-intro/projection.html). If we inspect our spatial data, we will notice an issue with our projection(s):

```sql
SELECT ST_SRID(geometry) FROM toilets LIMIT 1;
-- Returns: 4326
```

```sql
SELECT ST_SRID(wkb_geometry) FROM lors LIMIT 1;
-- Returns: 25833
```

Or LOR data does not use the same projection as our toilet data. How can we deal with that issue?

Actually PostGIS gives us a [`ST_Transform` function](https://postgis.net/docs/ST_Transform.html) which allows us to transform a geometry from one projection to the other.

We are not gonna touch the original projection in the `lors` table, instead we're going to transform the projection on the fly:

```sql
-- Note that I'm using ST_Transform here so that pgAdmin is able to map the results onto their standard 4326 projection map
SELECT lors.plr_name, COUNT(toilets.*), ST_Transform(lors.wkb_geometry,4326)
FROM lors
JOIN toilets ON ST_Contains(ST_Transform(lors.wkb_geometry,4326), toilets.geometry::geometry)
GROUP BY lors.plr_name, lors.wkb_geometry
ORDER BY COUNT(toilets.*) DESC
LIMIT 10;

-- "Olympiagelände"          13
-- "Großer Tiergarten"        6
-- "Krumme Lanke"             5
-- "Carl-Schurz-Straße"       5
-- "Nikolassee"               5
-- "Wannsee"                  5
-- "Reichenberger Straße Ost" 5
-- "Alt-Tegel"                5
-- "Barnimkiez"               4
-- "Grünau"                   4
```

![Berlin LOR's with the highest toilet counts](/assets/images/lor_toilet_density_map.png)

With this query we can see that the LOR _Olympiagelände_ has by far the most toilets.

Also intersting that the south-western LORs have high toilet counts as well.

> Notice that this is a rather expensive query and takes a while to complete. Is there a way that we can speed this up (e.g. with an index)?

This changes the projection to 4326.

### How many toilets can be found in a 1km radius around place x (e.g. Alexanderplatz)?

...

#### Not PostGIS-related but: How can I filter deeper? Say I want only toilets with a certain payment method or a certain feature?

...

### Which Berlin district has the highest density of toilets (relative to the size)?

...

### How can I return a GeoJSON representation of my PostGIS records?

...

## Ideas for today

- [ ] ~~data migration of free-of-charge toilets~~ (skipped for now)
- [x] understand [app-driven vs. database-driven schemas](https://databaseci.com/docs/migra/deploy-usage)
- [ ] explore different PostGIS queries
