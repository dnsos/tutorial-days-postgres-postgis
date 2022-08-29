# Day 1: Designing a schema and setting up the database

First, I took a look at the [open dataset of Berlin's public toilets](https://daten.berlin.de/datensaetze/standorte-der-%C3%B6ffentlichen-toiletten). I then opened the tool [DrawSQL](https://drawsql.app) for designing the database schema based on the dataset. (DrawSQl has a free tier with limited tables and some other restrictions, however enough for my purpose here.)

In order to make the tutorial days a bit more challenging, I decided to split the one-table dataset into a more database-y representation

## Database schema

![Schema for the Berlin public toilets database](/assets/images/public_toilets_schema.png)

> _Learning_: in order to establish a many-to-many relationship, we need an extra association table.

> _Question_: what is a good tool for creating database schemas? I've tried DrawSQL for the first time and it felf very intuitive from the first moment. It is a commercial product, however. Are there open source solutions that offer a good UX?

### DrawSQL exports

Interesting find: DrawSQL is able to export a `.sql` [file](/assets/others/drawSQL-pgsql-export-2022-08-29.sql) that can create the database schema.

---

## Open to-do's

- [ ] setup database
- [ ] install Postgis
- [ ] import file (and split information into respective tables)