# Get Started With PostgreSQL

Notes and annotations from Egghead.io's Get Started With PostgreSQL course: Get Started With PostgreSQL

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Running a local db](#running-a-local-db)
- [1. Create a Postgres Table](#1-create-a-postgres-table)
- [2. Insert Data into Postgres Tables](#2-insert-data-into-postgres-tables)
  - [Constraints, errors and caveats](#constraints-errors-and-caveats)
- [3. Filter Data in a Postgres Table with Query Statements](#3-filter-data-in-a-postgres-table-with-query-statements)
  - [Selecting specific columns](#selecting-specific-columns)
  - [Renaming columns in the query using `AS`](#renaming-columns-in-the-query-using-as)
  - [Filtering results in the query using `WHERE`](#filtering-results-in-the-query-using-where)
  - [Aggregations](#aggregations)
    - [`COUNT`](#count)
    - [`SUM`](#sum)
    - [`AVG`](#avg)
  - [Adding columns to the temporary table](#adding-columns-to-the-temporary-table)
    - [Casting column values to different types](#casting-column-values-to-different-types)
- [4. Update Data in Postgres](#4-update-data-in-postgres)
  - [Evaluating the affected rows before running an update](#evaluating-the-affected-rows-before-running-an-update)
- [5. Delete Postgres Records](#5-delete-postgres-records)
- [6. Group and Aggregate Data in Postgres](#6-group-and-aggregate-data-in-postgres)
  - [Using `LIMIT` to reduce overhead on queries](#using-limit-to-reduce-overhead-on-queries)
  - [Using `GROUP BY` to aggregate results](#using-group-by-to-aggregate-results)
  - [Using `ORDER BY` to order the results of a query](#using-order-by-to-order-the-results-of-a-query)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Running a local db

1. Install Docker
2. Run `docker-compose`
3. Connect to the `psql` process running inside the container

```bash
# start the container
$ docker-compose up

# connect to the psql instance
$ docker-compose exec sql_fundamentals psql -U postgres
```

If you're looking for a PostgreSQL client, [SQL Pro](https://macpostgresclient.com/)
may be useful.

## 1. Create a Postgres Table

Let's create a `directors` table:

```sql
CREATE TABLE directors (
  id SERIAL PRIMARY KEY,
  --  [1]       [2]
  name VARCHAR(200)
  --       [3]
);

-- [1] SERIAL indicates that the column is auto incrementing integer
-- [2] make the id field the primary key for this table
-- [3] set the name column to have a type that is a strong with a maximum of 200
--     characters
```

We can evaluate the creation of our table:


```sql
SELECT * FROM directors;

 id | name
----+------
(0 rows)
```

Let's create a `movies` table, too:

```sql
CREATE TABLE movies (
  id SERIAL PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  --                   [1]
  release_date DATE,
  --            [2]
  count_stars INTEGER,
  director_id INTEGER
  -- [3]
);

-- [1] ensure that a title is always provided when a movie is inserted
-- [2] set release_date to expect a DATE type
-- [3] add a director_id column to reference a director in our directors table

-- confirm the creation of our table
SELECT * FROM movies;

 id | title | release_date | count_stars | director_id
----+-------+--------------+-------------+-------------
(0 rows)
```

Let's insert some data into our tables:

```sql
INSERT INTO directors (name)
  VALUES
    ('Quentin Tarantino'), ('Judd Apatow');

INSERT INTO movies (title, release_date, count_stars, director_id)
  VALUES
    ('Kill Bill', '10-10-2003', 3, 1),
    ('Funny people', '07-20-2009', 5, 2);

-- get all rows from our directors table
SELECT * FROM directors;

 id |       name
----+-------------------
  1 | Quentin Tarantino
  2 | Judd Apatow
(2 rows)

-- get all rows from our movies table
SELECT * FROM movies;
 id |    title     | release_date | count_stars | director_id
----+--------------+--------------+-------------+-------------
  1 | Kill Bill    | 2003-10-10   |           3 |           1
  2 | Funny people | 2009-07-20   |           5 |           2
(2 rows)
```

## 2. Insert Data into Postgres Tables

Let's clear our previous data before entering new data:

```sql
TRUNCATE movies;
TRUNCATE directors;
```

Let's insert the same record a number of times:

```sql
INSERT INTO directors (name) VALUES ('Quentin Tarantino');
INSERT INTO directors (name) VALUES ('Quentin Tarantino');
INSERT INTO directors (name) VALUES ('Quentin Tarantino');
INSERT INTO directors (name) VALUES ('Quentin Tarantino');
INSERT INTO directors (name) VALUES ('Quentin Tarantino');
INSERT INTO directors (name) VALUES ('Quentin Tarantino');
INSERT INTO directors (name) VALUES ('Quentin Tarantino');

SELECT * FROM directors;

 id |       name
----+-------------------
  1 | Quentin Tarantino
  2 | Quentin Tarantino
  3 | Quentin Tarantino
  4 | Quentin Tarantino
  5 | Quentin Tarantino
  6 | Quentin Tarantino
  7 | Quentin Tarantino
(7 rows)
```

Multiple values can be inserted:

```sql
INSERT INTO directors (name)
  VALUES ('Judd Apatow'), ('Mel Brooks');

SELECT * FROM directors;

 id |       name
----+-------------------
  1 | Quentin Tarantino
  2 | Quentin Tarantino
  3 | Quentin Tarantino
  4 | Quentin Tarantino
  5 | Quentin Tarantino
  6 | Quentin Tarantino
  7 | Quentin Tarantino
  8 | Judd Apatow
  9 | Mel Brooks
(9 rows)
```

### Constraints, errors and caveats

We can't insert null values for name because of the table definition:

```sql
INSERT INTO directors (name) VALUES (NULL);

ERROR:  null value in column "name" violates not-null constraint
DETAIL:  Failing row contains (10, null).
```

We can manually set the id, despite it being an autoincrementing field:

```sql
INSERT INTO directors (id, name) VALUES (200, 'Some director');

SELECT * FROM directors;

 id  |       name
-----+-------------------
   1 | Quentin Tarantino
   2 | Quentin Tarantino
   3 | Quentin Tarantino
   4 | Quentin Tarantino
   5 | Quentin Tarantino
   6 | Quentin Tarantino
   7 | Quentin Tarantino
   8 | Judd Apatow
   9 | Mel Brooks
 200 | Some director
(10 rows)
```

But at some point we're going to get an error when a record is entered after
record 199, and the database attempts to create a record with an existing id.

Don't set values on auto-incrementing columns;

```sql
DELETE FROM directors WHERE id = 200;
```

Postgres will notify us when attempting to insert incorrect values:

```sql
-- insert an invalid date value
INSERT INTO movies (release_date, title, count_stars, director_id)
  VALUES ('111-11-2011', 'My little pony', 4, 1);

ERROR:  date/time field value out of range: "111-11-2011"
LINE 2:   VALUES ('111-11-2011', 'My little pony', 4, 1);
                  ^
HINT:  Perhaps you need a different "datestyle" setting.
```

Attempting to insert an invalid type into a field for which the type is
parseable may not result in an error. e.g. inserting a number into a string
field:

```sql
INSERT INTO movies (release_date, title, count_stars, director_id)
  -- insert a number for title, instead of string
  VALUES ('11-11-2011', 1, 3, 1);

INSERT 0 1
```

## 3. Filter Data in a Postgres Table with Query Statements

Let's start with a fresh db by dropping our `directors` and `movies` tables and
recreating them before inserting data:

```sql
INSERT INTO directors (name)
  VALUES
    ('Quention Tarantino'), ('Judd Apatow'), ('Mel Brooks');

INSERT INTO movies (title, release_date, count_stars, director_id)
  VALUES
    ('Kill Bill', '2003-10-10', 3, 1),
    ('Funny People', '2009-07-20', 5, 2),
    ('Blazing Saddles', '1974-02-07', 5, 3);
```

### Selecting specific columns

We can select specific columns from a table:

```sql
SELECT title, release_date FROM movies;

      title      | release_date
-----------------+--------------
 Kill Bill       | 2003-10-10
 Funny People    | 2009-07-20
 Blazing Saddles | 1974-02-07
(3 rows)
```

This is a new table we're creating that's available only for the duration of the
query; a temporary table.

### Renaming columns in the query using `AS`

We can rename columns in the temporary table, too:

```sql
SELECT title, release_date AS release FROM movies;

      title      |  release
-----------------+------------
 Kill Bill       | 2003-10-10
 Funny People    | 2009-07-20
 Blazing Saddles | 1974-02-07
(3 rows)
```

### Filtering results in the query using `WHERE`

We can filter rows to be returned in the query by using the `WHERE` statement to
provide conditions under which rows should be returned:

```sql
SELECT title, release_date AS release FROM movies
  WHERE release_date > '01-01-1975';

    title     |  release
--------------+------------
 Kill Bill    | 2003-10-10
 Funny People | 2009-07-20
(2 rows)
```

Conditions can be combined with conjunctions and disjunctions:

```sql
-- conjunction
SELECT title, release_date AS release FROM movies
  WHERE release_date > '01-01-1975'
    AND count_stars = 3;

    title     |  release
--------------+------------
 Funny People | 2009-07-20
(1 row)

-- disjunction
SELECT title, release_date AS release FROM movies
  WHERE release_date > '01-01-1975'
    OR count_stars = 3;

    title     |  release
--------------+------------
 Kill Bill    | 2003-10-10
 Funny People | 2009-07-20
(2 rows)
```

### Aggregations

We have a few aggregations available to us:

#### `COUNT`

Count the number of rows in a table:

```sql
SELECT COUNT(*) FROM movies;

 count
-------
     3
(1 row)
```

#### `SUM`

Get the total for a specific column:

```sql
SELECT SUM(count_stars) FROM movies;

 sum
-----
  13
(1 row)
```

####  `AVG`

Retrieve the average for a specific column:

```sql
SELECT AVG(count_stars) FROM movies;

        avg
--------------------
 4.3333333333333333
(1 row)
```

### Adding columns to the temporary table

We can create a temporary table that has columns in it that don't exist in the
queried table or tables:

```sql
SELECT *, count_stars / 5 AS rotten_tomatoes_score FROM movies;

 id |      title      | release_date | count_stars | director_id | rotten_tomatoes_score
----+-----------------+--------------+-------------+-------------+-----------------------
  1 | Kill Bill       | 2003-10-10   |           3 |           1 |                     0
  2 | Funny People    | 2009-07-20   |           5 |           2 |                     1
  3 | Blazing Saddles | 1974-02-07   |           5 |           3 |                     1
(3 rows)
```

#### Casting column values to different types

The value in the `rotten_tomatoes_score` columns isn't too valuable here, as
Postgres has rounded the result of `count_stars / 5`. To fix this, we can cast
the column being operated on to a floating-point number:

```sql
-- use the :: operator to cast a column to a desired type
SELECT *, (count_stars::float / 5) AS rotten_tomatoes_score FROM movies;

 id |      title      | release_date | count_stars | director_id | rotten_tomatoes_score
----+-----------------+--------------+-------------+-------------+-----------------------
  1 | Kill Bill       | 2003-10-10   |           3 |           1 |                   0.6
  2 | Funny People    | 2009-07-20   |           5 |           2 |                     1
  3 | Blazing Saddles | 1974-02-07   |           5 |           3 |                     1
(3 rows)
```

The `::` syntax is specific to Postgres. There is a `CAST` syntax that conforms
to the SQL standard, too:

```sql
SELECT *, CAST (count_stars AS float) / 5 AS rotten_tomatoes_score FROM movies;

 id |      title      | release_date | count_stars | director_id | rotten_tomatoes_score
----+-----------------+--------------+-------------+-------------+-----------------------
  1 | Kill Bill       | 2003-10-10   |           3 |           1 |                   0.6
  2 | Funny People    | 2009-07-20   |           5 |           2 |                     1
  3 | Blazing Saddles | 1974-02-07   |           5 |           3 |                     1
(3 rows)
```

## 4. Update Data in Postgres

Let's say we want to update `count_stars` in our `movies` table:

```sql
UPDATE movies SET count_stars = 1;
-- [1]  [2]   [3]            [4]

-- [1] indicate using the UPDATE command that we're going to update a table
-- [2] provide the name of the table we're updating
-- [3] use the SET command to indicate we're beginning the expression that will
--     update something
-- [4] provide the column to update, and the value to update it to

SELECT * FROM movies;

 id |      title      | release_date | count_stars | director_id
----+-----------------+--------------+-------------+-------------
  1 | Kill Bill       | 2003-10-10   |           1 |           1
  2 | Funny People    | 2009-07-20   |           1 |           2
  3 | Blazing Saddles | 1974-02-07   |           1 |           3
(3 rows)
```

This query update every row's `count_stars` value to 1. This is because
`UPDATE`, like `SELECT` operates like a loop on all of the rows in the specified
table.

To limit updates to specific rows, we need to add a `WHERE` statement. We can
target one of our movies:

```sql
UPDATE movies SET count_stars = 5
  WHERE title = 'Kill Bill';

SELECT * FROM movies;

-- only Kill Bill was updated
 id |      title      | release_date | count_stars | director_id
----+-----------------+--------------+-------------+-------------
  2 | Funny People    | 2009-07-20   |           1 |           2
  3 | Blazing Saddles | 1974-02-07   |           1 |           3
  1 | Kill Bill       | 2003-10-10   |           5 |           1
(3 rows)
```

We can also update a subset of our movies

```sql
UPDATE movies SET count_stars = 5
  WHERE count_stars = 1;

SELECT * FROM movies;

-- movies that had count_stars = 1 are updated
 id |      title      | release_date | count_stars | director_id
----+-----------------+--------------+-------------+-------------
  2 | Funny People    | 2009-07-20   |           3 |           2
  3 | Blazing Saddles | 1974-02-07   |           3 |           3
  1 | Kill Bill       | 2003-10-10   |           5 |           1
(3 rows)
```

### Evaluating the affected rows before running an update

It's useful to determine which rows will be affected before running the `UPDATE`
on the rows.

Make it a habit to inspect rows that will be updated before updating them.

## 5. Delete Postgres Records

Let's add a few dummy records to delete:

```sql
INSERT INTO movies (title, release_date, count_stars)
  VALUES
    ('Kill Bill 1', '1999-01-01', 91),
    ('Kill Bill 2', '1999-01-01', 92),
    ('Kill Bill 3', '1999-01-01', 93),
    ('Kill Bill 4', '1999-01-01', 94);
```

Before we delete anything from our db, let's check what we're going to delete.
In this case, let's delete rows where `count_stars` is greater than 90. We
expect to have 4 records:

```sql
-- check that we get what we expect for the query we'll use to delete the rows
SELECT COUNT(*) FROM movies WHERE count_stars > 90;

 count
-------
     4
(1 row)

DELETE FROM movies WHERE count_stars > 90;
DELETE 4
```

We can now check that we only have our original Kill Bill row:

```sql
SELECT * FROM movies WHERE title LIKE '%Kill';

 id |   title   | release_date | count_stars | director_id
----+-----------+--------------+-------------+-------------
  1 | Kill Bill | 2003-10-10   |           5 |           1
(1 row)
```

`DELETE` is idempotent, too:

```sql
DELETE FROM movies WHERE count_stars > 90;

SELECT * FROM movies WHERE title LIKE '%Kill';

 id |   title   | release_date | count_stars | director_id
----+-----------+--------------+-------------+-------------
  1 | Kill Bill | 2003-10-10   |           5 |           1
(1 row)
```

Like `SELECT` and `UPDATE`, `DELETE` operates by looping over all records in a
table. If no conditions are provided, all rows in the specified table will be
deleted.

## 6. Group and Aggregate Data in Postgres

Postgres has command line executables for creating and dropping databases:

```bash
# drop a specific database
$ dropdb [db_name]

# create a new database
$ createdb [db_name]
```

We'll need to add more data to evaluate grouping and aggregrating effectively:

```bash
# connect to the container
$ docker-compose exec get_started_with_postgresql bash

# cd into the data folder
cd /var/lib/postgresql/data/lesson-06

# create a sql file with a command to copy the data
$ echo "COPY movies FROM '`pwd`/movies.csv' DELIMITER ',' CSV NULL 'NA' HEADER;" > ./movies.sql

# create a database for aggregration
$ createdb aggregate -U postgres -f create.sql
CREATE TABLE

# insert movies data into the table
$ psql -d aggregate -U postgres -f movies.sql
COPY 58788

# connect to the new database
$ psql -U postgres
$ \c aggregate
You are now connected to database "aggregate" as user "postgres".

$ \d

              List of relations
 Schema |     Name      |   Type   |  Owner
--------+---------------+----------+----------
 public | movies        | table    | postgres
 public | movies_id_seq | sequence | postgres
(2 rows)
```

We've now got 58788 rows in our `movies` table in our new `aggregate` database.

We can see all the count of the records we inserted:

```sql
SELECT COUNT(*) FROM movies;

 count
-------
 58788
(1 row)
```

### Using `LIMIT` to reduce overhead on queries

We can select a subset of the records so as to increase the speed of a query:

```sql
SELECT * FROM movies
  LIMIT 10;

 id |          title           | year | length | budget | rating | votes |  r1  |  r2  | r3  |  r4  |  r5  |  r6  |  r7  |  r8  |  r9  | r10  | mpaa | action | animation | comedy | drama | documentary | romance | short
----+--------------------------+------+--------+--------+--------+-------+------+------+-----+------+------+------+------+------+------+------+------+--------+-----------+--------+-------+-------------+---------+-------
  1 | $                        | 1971 |    121 |        |    6.4 |   348 |  4.5 |  4.5 | 4.5 |  4.5 | 14.5 | 24.5 | 24.5 | 14.5 |  4.5 |  4.5 |      | f      | f         | t      | t     | f           | f       | f
  2 | $1000 a Touchdown        | 1939 |     71 |        |      6 |    20 |    0 | 14.5 | 4.5 | 24.5 | 14.5 | 14.5 | 14.5 |  4.5 |  4.5 | 14.5 |      | f      | f         | t      | f     | f           | f       | f
  3 | $21 a Day Once a Month   | 1941 |      7 |        |    8.2 |     5 |    0 |    0 |   0 |    0 |    0 | 24.5 |    0 | 44.5 | 24.5 | 24.5 |      | f      | t         | f      | f     | f           | f       | t
  4 | $40,000                  | 1996 |     70 |        |    8.2 |     6 | 14.5 |    0 |   0 |    0 |    0 |    0 |    0 |    0 | 34.5 | 45.5 |      | f      | f         | t      | f     | f           | f       | f
  5 | $50,000 Climax Show, The | 1975 |     71 |        |    3.4 |    17 | 24.5 |  4.5 |   0 | 14.5 | 14.5 |  4.5 |    0 |    0 |    0 | 24.5 |      | f      | f         | f      | f     | f           | f       | f
  6 | $pent                    | 2000 |     91 |        |    4.3 |    45 |  4.5 |  4.5 | 4.5 | 14.5 | 14.5 | 14.5 |  4.5 |  4.5 | 14.5 | 14.5 |      | f      | f         | f      | t     | f           | f       | f
  7 | $windle                  | 2002 |     93 |        |    5.3 |   200 |  4.5 |    0 | 4.5 |  4.5 | 24.5 | 24.5 | 14.5 |  4.5 |  4.5 | 14.5 | R    | t      | f         | f      | t     | f           | f       | f
  8 | '15'                     | 2002 |     25 |        |    6.7 |    24 |  4.5 |  4.5 | 4.5 |  4.5 |  4.5 | 14.5 | 14.5 | 14.5 |  4.5 | 14.5 |      | f      | f         | f      | f     | t           | f       | t
  9 | '38                      | 1987 |     97 |        |    6.6 |    18 |  4.5 |  4.5 | 4.5 |    0 |    0 |    0 | 34.5 | 14.5 |  4.5 | 24.5 |      | f      | f         | f      | t     | f           | f       | f
 10 | '49-'17                  | 1917 |     61 |        |      6 |    51 |  4.5 |    0 | 4.5 |  4.5 |  4.5 | 44.5 | 14.5 |  4.5 |  4.5 |  4.5 |      | f      | f         | f      | f     | f           | f       | f
(10 rows)
```

### Using `GROUP BY` to aggregate results

Aggregation is performed by using `GROUP BY`.

```sql
-- an invalid GROUP BY query
SELECT * FROM movies
  GROUP BY rating;

ERROR:  column "movies.id" must appear in the GROUP BY clause or be used in an aggregate function
LINE 1: SELECT * FROM movies GROUP BY rating;
```

The problem here is that we're grouping by `rating`, but we're attempting to
retrieve all columns in the query. Because many, if not all, rows will have
unique values, `GROUP BY` throws an error, because it can't group rows that have
a common `rating` value, but have differing other columns.

To address this we need the column we're grouping by in our `SELECT` statement's
columns:

```sql
SELECT rating FROM movies
  GROUP BY rating;

 rating
--------
    5.6
    7.5
    8.8
    ...
    9.2
    6.5
    1.8
(91 rows)
```

### Using `ORDER BY` to order the results of a query

The above example is in no discernable order. This can be corrected by using
`ORDER BY`:

```sql
SELECT rating FROM movies
  GROUP BY rating
  ORDER BY rating;

 rating
--------
      1
    1.1
    1.2
    ...
    9.8
    9.9
     10
(91 rows)
```

We could also specify the number of the column in the `SELECT` statement's
columns to determine which columnd to order the results by:

```sql
SELECT rating FROM movies
  GROUP BY rating
  ORDER BY 1;

 rating
--------
      1
    1.1
    1.2
    ...
    9.8
    9.9
     10
(91 rows)
```

In this query, 1 represents `rating`.
