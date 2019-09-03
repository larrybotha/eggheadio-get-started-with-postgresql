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
  - [Using `ROUND` to get estimates](#using-round-to-get-estimates)
  - [Aggregating on multiple fields using `CASE ... WHEN ... THEN ... ELSE ... END`](#aggregating-on-multiple-fields-using-case--when--then--else--end)
  - [Simplifying queries by using `WITH` to create temporary tables](#simplifying-queries-by-using-with-to-create-temporary-tables)
- [7. Sort Postgres Tables](#7-sort-postgres-tables)
  - [Ascending vs descending sort](#ascending-vs-descending-sort)
  - [Sorting within sorted results](#sorting-within-sorted-results)
- [8. Ensure Uniqueness in Postgres](#8-ensure-uniqueness-in-postgres)
  - [Adding a uniqueness constraint](#adding-a-uniqueness-constraint)
  - [Adding a constraint on table creation](#adding-a-constraint-on-table-creation)
  - [Adding a constraint that is a combination of columns](#adding-a-constraint-that-is-a-combination-of-columns)
- [9. Use Foreign Keys to Ensure Data Integrity in Postgres](#9-use-foreign-keys-to-ensure-data-integrity-in-postgres)

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
    ('Quentin Tarantino'), ('Judd Apatow'), ('Mel Brooks');

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
  -- '1' is equivalent to `rating`

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

`ORDER BY` limits rows to explicit values.

We can now see how many movies there are for each rating:

```sql
SELECT rating, COUNT(*) FROM movies
  GROUP BY rating
  ORDER BY 1;

 rating | count
--------+-------
      1 |   106
    1.1 |    44
    1.2 |    36
    ...
    9.8 |    63
    9.9 |    20
     10 |     3
(91 rows)
```

This is still a lot of information.

### Using `ROUND` to get estimates

Instead of viewing every decimal rating from 0 to 10, we can use the `ROUND`
function to estimate the values, and return a more histogram-like result:

```sql
SELECT ROUND(rating), COUNT(*) FROM movies
  GROUP BY ROUND(rating)
  ORDER BY 1;

 round | count
-------+-------
     1 |   272
     2 |  1298
     3 |  2685
     4 |  6309
     5 |  9509
     6 | 17233
     7 | 12506
     8 |  6993
     9 |  1689
    10 |   294
(10 rows)
```

As a convenience we can also using the column index in our `GROUP BY` statement:

```sql
SELECT ROUND(rating), COUNT(*) FROM movies
  GROUP BY 1
  ORDER BY 1;

 round | count
-------+-------
     1 |   272
     2 |  1298
     3 |  2685
     4 |  6309
     5 |  9509
     6 | 17233
     7 | 12506
     8 |  6993
     9 |  1689
    10 |   294
(10 rows)
```

We can see that 272 movies have an approximate 1 star rating, 1298 have 2 stars,
etc.

Aggregations allow us to ask questions about specific fields and evaluate the
underlying data.

### Aggregating on multiple fields using `CASE ... WHEN ... THEN ... ELSE ... END`

The kind of aggregation done up until this point has been easy because we've
only been evaluating a single field. `GROUP BY` is great for aggregating on a
single column, but it's not going to cut should we aggregate on multiple
columns.

In our movies table, we have a number of genres with boolean types:

- action
- animation
- comedy
- drama
- documentary
- romance
- short

An alterntive to `GROUP BY` is the `CASE ... WHEN ... THEN` statement. `CASE`
forms part of the `SELECT` statement's column declarations:

```sql
SELECT title,
  CASE
    WHEN action = true THEN 'action'
    ELSE 'other'
    END
  FROM movies
  LIMIT 10;

          title           |  case
--------------------------+--------
 $                        | other
 $1000 a Touchdown        | other
 $21 a Day Once a Month   | other
 $40,000                  | other
 $50,000 Climax Show, The | other
 $pent                    | other
 $windle                  | action
 '15'                     | other
 '38                      | other
 '49-'17                  | other
(10 rows)
```

We can add the remaining genres to get a better picture of our movies:


```sql
SELECT title,
  CASE
    WHEN action = true THEN 'action'
    WHEN animation = true THEN 'animation'
    WHEN comedy = true THEN 'comedy'
    WHEN drama = true THEN 'drama'
    WHEN documentary = true THEN 'documentary'
    WHEN romance = true THEN 'romance'
    WHEN short = true THEN 'short'
    ELSE 'other'
    END
  FROM movies
  LIMIT 10;

          title           |    case
--------------------------+-------------
 $                        | comedy
 $1000 a Touchdown        | comedy
 $21 a Day Once a Month   | animation
 $40,000                  | comedy
 $50,000 Climax Show, The | other
 $pent                    | drama
 $windle                  | action
 '15'                     | documentary
 '38                      | drama
 '49-'17                  | other
(10 rows)
```

We have a `case` column which isn't too meaningful, so we can rename it:

```sql
SELECT title,
  CASE
    WHEN action = true THEN 'action'
    WHEN animation = true THEN 'animation'
    WHEN comedy = true THEN 'comedy'
    WHEN drama = true THEN 'drama'
    WHEN documentary = true THEN 'documentary'
    WHEN romance = true THEN 'romance'
    WHEN short = true THEN 'short'
    ELSE 'other'
    END AS genre
  FROM movies
  LIMIT 10;

          title           |    genre
--------------------------+-------------
 $                        | comedy
 $1000 a Touchdown        | comedy
 $21 a Day Once a Month   | animation
 $40,000                  | comedy
 $50,000 Climax Show, The | other
 $pent                    | drama
 $windle                  | action
 '15'                     | documentary
 '38                      | drama
 '49-'17                  | other
(10 rows)
```

### Simplifying queries by using `WITH` to create temporary tables

The query above is becoming quite unwieldy, so we can leverage SQL's `WITH`
statement to break our query down into discrete temporary tables. A temporary
table created using a `With` statement may also be referred to as a **Common
Table Expression** or CTE.

We can separate the `genre` aspect of our query into its own query:

```sql
-- create a temporary table called genres
WITH genres AS (
  SELECT title,
    CASE
      WHEN action = true THEN 'action'
      WHEN animation = true THEN 'animation'
      WHEN comedy = true THEN 'comedy'
      WHEN drama = true THEN 'drama'
      WHEN documentary = true THEN 'documentary'
      WHEN romance = true THEN 'romance'
      WHEN short = true THEN 'short'
      ELSE 'other'
      END AS genre
    FROM movies
)

-- query against our temporary genres table
SELECT genre, COUNT(*) FROM genres
  GROUP BY genre -- or alterntively, 1
  ORDER BY 1;

    genre    | count
-------------+-------
 action      |  4688
 animation   |  3606
 comedy      | 14269
 documentary |  3183
 drama       | 16952
 other       | 12786
 romance     |   580
 short       |  2724
(8 rows)
```

## 7. Sort Postgres Tables

Let's start with a new database:

```bash
# connect to docker container
$ docker-compose exec get_started_with_postgresql bash

$ createdb sort -U postgres
$ psql -U posgres
> \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------+----------+----------+------------+------------+-----------------------
 ...
 sort      | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 ...

>\c sort
You are now connected to database "sort" as user "postgres".
```

And let's create a `friends` table and insert data:

```sql
CREATE TABLE friends (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  friend_count INT NOT NULL
);

INSERT INTO friends (name, friend_count)
  VALUES
  ('Corey', 553),
  ('Tag', 3149),
  ('Sean', 234),
  ('Crowe', 123),
  ('Cambria', 23100),
  ('Sophia', 2131),
  ('Andrew', 2131);

SELECT * FROM friends;

 id |  name   | friend_count
----+---------+--------------
  1 | Corey   |          553
  2 | Tag     |         3149
  3 | Sean    |          234
  4 | Crowe   |          123
  5 | Cambria |        23100
  6 | Sophia  |         2131
  7 | Andrew  |         2131
(7 rows)
```

### Ascending vs descending sort

We know how to order by a specific columns now:

```sql
SELECT * FROM friends
  ORDER BY friend_count;

 id |  name   | friend_count
----+---------+--------------
  4 | Crowe   |          123
  3 | Sean    |          234
  1 | Corey   |          553
  6 | Sophia  |         2131
  7 | Andrew  |         2131
  2 | Tag     |         3149
  5 | Cambria |        23100
(7 rows)
```

This is ascending by default, which is the equivalent of the following explicit
ascneding sort:

```sql
SELECT * FROM friends
  ORDER BY friend_count ASC;

 id |  name   | friend_count
----+---------+--------------
  4 | Crowe   |          123
  3 | Sean    |          234
  1 | Corey   |          553
  6 | Sophia  |         2131
  7 | Andrew  |         2131
  2 | Tag     |         3149
  5 | Cambria |        23100
(7 rows)
```

We can sort in descending order using the `DESC` keyword:

```sql
SELECT * FROM friends
  ORDER BY friend_count DESC;

 id |  name   | friend_count
----+---------+--------------
  5 | Cambria |        23100
  2 | Tag     |         3149
  7 | Andrew  |         2131
  6 | Sophia  |         2131
  1 | Corey   |          553
  3 | Sean    |          234
  4 | Crowe   |          123
(7 rows)
```

### Sorting within sorted results

In our first query  we get _Sophia_ followed by _Andrew_. To sort multiple columns,
we can specify multiple columns:

```sql
SELECT * FROM friends
  ORDER BY friend_count, name;

 id |  name   | friend_count
----+---------+--------------
  4 | Crowe   |          123
  3 | Sean    |          234
  1 | Corey   |          553
  7 | Andrew  |         2131
  6 | Sophia  |         2131
  2 | Tag     |         3149
  5 | Cambria |        23100
(7 rows)
```
 and we get _Andrew_ before _Sophia_.

 We can go a step further and order each column either `ASC` or `DESC`:

 ```sql
SELECT * FROM friends
  ORDER BY friend_count DESC, name DESC;

 id |  name   | friend_count
----+---------+--------------
  5 | Cambria |        23100
  2 | Tag     |         3149
  6 | Sophia  |         2131
  7 | Andrew  |         2131
  1 | Corey   |          553
  3 | Sean    |          234
  4 | Crowe   |          123
(7 rows)
 ```

## 8. Ensure Uniqueness in Postgres

In our movies table we currently don't have anything preventing us from adding
the same director:

```sql
INSERT INTO directors (name) VALUES ('Quentin Tarantino');

SELECT * FROM directors;

 id |       name
----+-------------------
  1 | Quentin Tarantino
  2 | Judd Apatow
  3 | Mel Brooks
  4 | Quentin Tarantino
(4 rows)
```

### Adding a uniqueness constraint

We can enforce uniqueness by enforcing it as a constraint on a column:

```sql
ALTER TABLE directors
-- [        1        ]
  ADD CONSTRAINT directors_name_unique UNIQUE(name);
--  [2]                 [3]             [4]    [5]

-- [1] we want to alter the directors table
-- [2] by adding a constraint
-- [3] with a name of directors_name_unique
-- [4] with a UNIQUE constraint
-- [5] on the name column

ERROR:  could not create unique index "directors_unique_name"
DETAIL:  Key (name)=(Quentin Tarantino) is duplicated.
```

We got an error here because we already have a row that violates the constraint.
We need to first ensure our table meets the constraints before adding the
constraints:

```sql
DELETE FROM directors WHERE id = 4;

ALTER TABLE directors
  ADD CONSTRAINT directors_name_unique UNIQUE(name);
```

We can now evaluate that the condition holds:

```sql
INSERT INTO directors (name) VALUES ('Quentin Tarantino');

ERROR:  duplicate key value violates unique constraint "directors_unique_name"
DETAIL:  Key (name)=(Quentin Tarantino) already exists.
```

We now get the error we expect when attempting to add a new row that violates
the uniqueness constraint on the `name` column.

### Adding a constraint on table creation

Let's drop our `directors` db, and then add the constraint on creation:

```sql
-- drop directors
DROP TABLE directors;

-- create directors with the uniqueness constraint on name
CREATE TABLE directors (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE
);

-- seed our table
INSERT INTO directors (name)
  VALUES
    ('Quentin Tarantino'), ('Judd Apatow'), ('Mel Brooks');
```

Now we can evaluate adding a row that violates uniqueness again:

```sql
INSERT INTO directors (name) VALUES ('Quentin Tarantino');

ERROR:  duplicate key value violates unique constraint "directors_name_key"
DETAIL:  Key (name)=(Quentin Tarantino) already exists.
```

### Adding a constraint that is a combination of columns

In our movies table it wouldn't be so useful to constrain uniqueness to titles
only, since movies are often remade.

Instead, we can add both the title and release date to the same constraint:

```sql
ALTER TABLE movies
  ADD CONSTRAINT unique_title_and_release UNIQUE(title, release_date);

SELECT * FROM movies;

 id |      title      | release_date | count_stars | director_id
----+-----------------+--------------+-------------+-------------
  2 | Funny People    | 2009-07-20   |           1 |           2
  3 | Blazing Saddles | 1974-02-07   |           1 |           3
  1 | Kill Bill       | 2003-10-10   |           5 |           1
(3 rows)
```

If we now attempt to add another `Kill Bill` with the same release date, we'll
get an error:

```sql
INSERT INTO movies (title, release_date, count_stars, director_id)
  VALUES
    ('Kill Bill', '2003-10-10', 5, 1);

ERROR:  duplicate key value violates unique constraint "unique_title_and_release"
DETAIL:  Key (title, release_date)=(Kill Bill, 2003-10-10) already exists.
```

## 9. Use Foreign Keys to Ensure Data Integrity in Postgres

Up until now we've been providing ids for directors in our movies table, but we
don't have a real association with the rows in the directors table.

To increase integrity of our data, we can use SQL's `REFERENCES` keyword to
create a relation. The `REFERENCES` keyword creates a foreign key on the table,
creating a relation between the table in which the key resides, and the table
the key references.

Let's drop our movies table, and recreate it with a foreign key constraint for
the `director_id` column:

````sql
DROP TABLE moviesl

CREATE TABLE movies (
  id SERIAL PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  release_date DATE,
  count_stars INTEGER,
  director_id INTEGER REFERENCES directors(id)
);
```

We can now add data to the table:

```sql
INSERT INTO movies (title, release_date, count_stars, director_id)
  VALUES
    ('Kill Bill', '10-10-2003', 3, 1),
    ('Funny people', '07-20-2009', 5, 2)
    ('Barton Fink', '09-21-1991', 5, 4);

ERROR:  insert or update on table "movies" violates foreign key constraint "movies_director_id_fkey"
DETAIL:  Key (director_id)=(4) is not present in table "directors".
```

Because we attempted to add a movie that references an id of a director that
doesn't exist in the directors table, we get an error.

To address this, we can add another row to our directors table, and then insert
our movies:

```sql
INSERT INTO directors (name)
  VALUES ('Coen Brothers');

INSERT INTO movies (title, release_date, count_stars, director_id)
  VALUES
    ('Kill Bill', '10-10-2003', 3, 1),
    ('Funny people', '07-20-2009', 5, 2)
    ('Barton Fink', '09-21-1991', 5, 4);

SELECT * FROM directors;

 id |       name
----+-------------------
  1 | Quentin Tarantino
  2 | Judd Apatow
  3 | Mel Brooks
  4 | Coen Brothers
(4 rows)
```
