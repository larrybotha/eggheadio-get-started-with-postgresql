CREATE TABLE movies (
   id SERIAL PRIMARY KEY,
   title VARCHAR(200),
   year integer,
   length integer,
   budget float,
   rating float,
   votes float,
   r1 float,
   r2 float,
   r3 float,
   r4 float,
   r5 float,
   r6 float,
   r7 float,
   r8 float,
   r9 float,
   r10 float,
   mpaa varchar(200),
   action boolean,
   animation boolean,
   comedy boolean,
   drama boolean,
   documentary boolean,
   romance boolean,
   short boolean
);
