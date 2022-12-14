# More PostGIS queries and other stuff

## First things first: projections

After I have ignored the fact the LOR dataset uses a different projection (25833) and transforming it on the fly in my queries, I have now realized that storing geometries with different projections in the same database is a rather bad practice.

So after dropping the tabel with `DROP TABLE lors;` I changed my GeoJSON import via _ogr2ogr_ to the following which converts the SRID before importing the data.

```bash
ogr2ogr -f "PostgreSQL" PG:"dbname=berlin_toilets_app user=<me>" /path/to/repo/assets/data/lor_planungsraeume_2021.geojson -nln lors -lco geometry_name=geometry -t_srs EPSG:4326
```

(Note that I also changed the column name of the column holding the geometry.)

Now I can change my toilets-in-LOR-finder query to this:

```sql
SELECT lors.plr_name, COUNT(toilets.*), lors.geometry
FROM lors
JOIN toilets ON ST_Contains(lors.geometry, toilets.geometry::geometry)
GROUP BY lors.plr_name, lors.geometry
ORDER BY COUNT(toilets.*) DESC
LIMIT 10;
```

This makes the query so much faster even without an index. I guess this is because we don't have to change the projection on the fly anymore.

### Introducing a spatial index

The query from the previous section takes about 110 ms to complete. Let's add a spatial index to see if we can improve this.

```sql
CREATE INDEX lors_geometry_idx
  ON lors
  USING GIST (geometry);
```

With this index in place, the query takes only about 60 ms to complete, almost half of the previous time!

We could improve this even more by creating an index on `toilets.geometry` as well. But for this we would have to remove th casting in the JOIN (`toilets.geometry::geometry`), otherwise the index would never be used. Something for later, maybe.

## More PostGIS queries

### How many toilets can be found in a 1km radius around place x (e.g. Alexanderplatz)?

Finding all toilets around Alexanderplatz is simple:

```sql
-- We have to create a buffer around our location. The second argument of ST_Buffer is the radius (in meters) around the point.
-- We have to do a lot of casting between geography and geometry because some functions in PostGIS only accept one or the other.
SELECT *
FROM toilets
WHERE ST_Contains(ST_Buffer(
	ST_MakePoint(13.412775, 52.521978)::geography,
	1000, 'quad_segs=8')::geometry, geometry::geometry);
```

![Toilets found in a km radius of the fountain in Alexanderplatz](/assets/images/toilets_around_alex.png)

---

> Continuing on day 4.
> 