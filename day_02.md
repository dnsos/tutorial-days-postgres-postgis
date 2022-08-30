# Day 2: Migrations and PostGIS queries

## The (failed) data migration of the 50 free toilets

My plan was to perform a data migration to update the `price` column on my `toilets` table if a toilet was included in the [dataset of 50 free-of-charge toilets](/assets/data/anlage_standorte-fuer-die-entgeltlose-benutzung-von-50-berliner-toiletten.csv). **I'm skipping this for now.**

The reason is that the dataset does not contain toilet ID's. I've made an attempt to pattern match via my `toilets.address` column with the _Standort_ column in the dataset. However, the _Standort_ entries match the `address` column only very irregularly, so my attempt of doing pattern matching in [`03-migrate-free-toilets.sql`](/sql/03-migrate-free-toilets.sql) was not successfull. In an ideal scenario, the toilet ID's would be provided. I might come back to the pattern matching approach at a later point (just for the exercise), but it is no priority.

## Migrations and schemas - some notes

The _migra_ tool has a little [explainer about the differences between these two approaches](https://databaseci.com/docs/migra/deploy-usage) for the source of truth of the database schema.

My learning from this is that (for my context) I find it preferrable to leave the schema truth with the app. I would usually not manage a database without an application that uses it, so the two would be very intertwined anyways.

A, for me, typical application would be a [Rails](https://rubyonrails.org/) app that has a very simple and mature ORM (_Active Record_) for handling migrations and the schema.

> Another interesting tool for handling schemas is the built-in [Schema Diff tool of pgAdmin](https://www.pgadmin.org/docs/pgadmin4/development/schema_diff.html).


## Ideas for today

- [ ] ~~data migration of free-of-charge toilets~~ (skipped for now)
- [x] understand [app-driven vs. database-driven schemas](https://databaseci.com/docs/migra/deploy-usage)
- [ ] explore different PostGIS queries
