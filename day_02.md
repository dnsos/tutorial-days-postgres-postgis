# Day 2: Migrations and PostGIS queries

## The (failed) data migration of the 50 free toilets

My plan was to perform a data migration to update the `price` column on my `toilets` table if a toilet was included in the [dataset of 50 free-of-charge toilets](/assets/data/anlage_standorte-fuer-die-entgeltlose-benutzung-von-50-berliner-toiletten.csv). **I'm skipping this for now.**

The reason is that the dataset does not contain toilet ID's. I've made an attempt to pattern match via my `toilets.address` column with the _Standort_ column in the dataset. However, the _Standort_ entries match the `address` column only very irregularly, so my attempt of doing pattern matching in [`03-migrate-free-toilets.sql`](/sql/03-migrate-free-toilets.sql) was not successfull. In an ideal scenario, the toilet ID's would be provided. I might come back to the pattern matching approach at a later point (just for the exercise), but it is no priority.

## Ideas for today

- [ ] ~~data migration of free-of-charge toilets~~ (skipped for now)
- [ ] understand [app-driven vs. database-driven schemas](https://databaseci.com/docs/migra/deploy-usage)
- [ ] explore different PostGIS queries
