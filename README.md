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
