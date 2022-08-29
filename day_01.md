# Day 1: Designing a schema and setting up the database

First, I took a look at the [open dataset of Berlin's public toilets](https://daten.berlin.de/datensaetze/standorte-der-%C3%B6ffentlichen-toiletten). I then opened the tool [DrawSQL](https://drawsql.app) for designing the database schema based on the dataset. (DrawSQl has a free tier with limited tables and some other restrictions, however enough for my purpose here.)

In order to make the tutorial days a bit more challenging, I decided to split the one-table dataset into a more database-y representation:

![Schema for the Berlin public toilets database](/images/public_toilets_schema.png)

> _Learning_: in order to establish a many-to-many relationship, we need an extra association table.

---

## Open to-do's

- [ ] setup database
- [ ] install Postgis
- [ ] import file (and split information into respective tables)