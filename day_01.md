# Day 1: Designing a schema and setting up the database

First, I took a look at the [open dataset of Berlin's public toilets](https://daten.berlin.de/datensaetze/standorte-der-%C3%B6ffentlichen-toiletten). I then opened the tool [DrawSQL](https://drawsql.app) for designing the database schema based on the dataset. (DrawSQl has a free tier with limited tables and some other restrictions, however enough for my purpose here.)

In order to make the tutorial days a bit more challenging, I decided to split the one-table dataset into a more database-y representation

## Database schema

![Schema for the Berlin public toilets database](/assets/images/public_toilets_schema.png)

> _Learning_: in order to establish a many-to-many relationship, we need an extra association table.

> _Question_: what is a good tool for creating database schemas? I've tried DrawSQL for the first time and it felf very intuitive from the first moment. It is a commercial product, however. Are there open source solutions that offer a good UX?

### DrawSQL exports

Interesting find: DrawSQL is able to export a `.sql` [file](/assets/others/drawSQL-pgsql-export-2022-08-29.sql) that can create the database schema.

## Creating the database

In order to refresh my memory, I rewatched parts of the [Udemy course on PostgreSQL and SQL](https://www.udemy.com/course/sql-and-postgresql) (especially part 169 onwards.)

I have decided to create the database from within pgAdmin. TUsing the UI creates the database with the following SQL:

```sql
CREATE DATABASE berlin_toilets_app
    WITH
    OWNER = <me>
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;
```

Showing the current PostgreSQL version is possible with:

```sql
SELECT version();
-- Returns: PostgreSQL 14.2 [...]
```

Showing the database timezone is possible with:

```sql
SHOW timezone;
```

> _Question_: Should the database always be UTC time? Or does it make sense for a strictly "local" database to use a different timezone (such as Europe/Berlin in this case)?

Installing PostGIS is as easy as:

```sql
CREATE EXTENSION postgis;
```

In pgAdmin's UI we can inspect the installed extensions through the sidebar under `DB Name -> Extensions -> List of extensions`.

## Creating the tables

In [this SQL file](/sql/01-create-tables.sql) we can find all the SQL used to generate the schema.

### Useful resources for this section

We can list all tables belonging to a database with this query:

```sql
SELECT *
FROM pg_catalog.pg_tables
WHERE schemaname != 'pg_catalog' AND 
    schemaname != 'information_schema';
```

(The `WHERE` clause makes sure to exclude system tables.)

Alternatively, we can use PSQL to view information about tables.

First, connect to the database:

```bash
psql -U <me> -d berlin_toilets_app
```

(`-U` defines the user, `-d` the database to connect to.)

Then, we can get detailed information about the available tables via:

```psql
\dt+
```

## Importing the data

The original dataset comes in an XLSX format. In order to make importing it a bit easier, I have exported the file to a [CSV](/assets/data/berliner-toiletten-standorte.csv) that is more compatible for import into a PostgreSQL database. 

> I have had to make one manual change because the file still had a first row with just the information about the updated-at date, which makes machine-readability harder -> the first row should usually be a header row.

### A temporary table

We don't want to import the original dataset as-is. Instead we need to split the columns and insert them into different tables in different ways.

That's why we can't simply use the [`COPY` statement](https://www.postgresql.org/docs/current/sql-copy.html). Actually we will use it, but with a step in between.

What we'll do it is create a [temporary table](https://www.postgresql.org/docs/14/sql-createtable.html) into which we will copy the CSV contents pretty much as-is. We will then use this temporary table to populate the other tables.

Follow the next steps in [`02-import-data.sql`](/sql/02-import-data.sql).

---

## Open to-do's

- [x] setup database (+ install Postgis)
- [ ] import file (and split information into respective tables)
- [ ] add indexes? Where is it necessary? Where does it make sense?
