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

After executing all the SQL, we've got the data successfully imported:

![Zoomed-out map of Berlin's public toilets](/assets/images/berlin_toilets_map.png)

> This is a nice feature of pgAdmin: if your query returns a geometry column, you can view the results on a map using the _Geometry Viewer_ tab of the results section.

### Querying the imported data

We can then use some SQL to query the toilets.

If we want to see the features for one particular toilet, we could use:

```sql
SELECT features.name FROM toilet_features JOIN features ON features.id = toilet_features.feature_id WHERE toilet_id = 1432;
```

Or the possible payment methods:

```sql
SELECT payment_methods.name FROM toilet_payment_methods JOIN payment_methods ON payment_methods.id = toilet_payment_methods.payment_method_id WHERE toilet_id = 1432;
```

Or simply the owner of a toilet:

```sql
SELECT toilets.description, toilets.address, toilet_owners.name FROM toilets JOIN toilet_owners ON toilet_owners.id = toilets.toilet_owner_id WHERE toilets.id = 1432;
```

## Data migration: Berlin's pilot project of making 50 toilets free of charge

### Context

In July 2022, [the city of Berlin has announced](https://www.berlin.de/sen/uvk/verkehr/infrastruktur/oeffentliche-toiletten/) that, as part of an experimental concept, 50 of Berlin's public toilets would become free of charge for a limited amount of time. Additionally, payment in the remaining public toilets will only be possible digitally. This makes it impossible to pay for the toilets with cash.

As an excercise I want to migrate my database, so that at least the price for the now-free toilets is updated. (If there is time, I'm going to update the payment methods as well.)

The city has released [an XLSX file with the 50 toilets that are part of the project](https://www.berlin.de/sen/uvk/verkehr/infrastruktur/oeffentliche-toiletten/download/). It's not directly possible to connect the toilets from this dataset to the original dataset of all toilets (mostly because of a lack of an ID column in the 50 toilet dataset.)

But, the _Standort_ column actually contains the content that we have imported into our `address` column. Unfortunately, they have appended text such as "hinter Mittelweg" or "ggü. Schöneicher Str.". This helps humans contextualize the location, but makes it less machine-processable. It's now harder for us to connect the toilet to our own `toilets` table.

Let's see if we can manage the update anyway!

### Migration

...
