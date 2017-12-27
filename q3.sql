-- Participate

SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

create table q3(
        countryName varchar(50),
        year int,
        participationRatio real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW participation AS
	SELECT country_id, extract(year from e_date) AS year, AVG(votes_cast / cast(electorate as float)) AS ratio
	FROM election
	GROUP BY country_id, extract(year from e_date)
	HAVING extract(year from e_date) >= 2001 AND extract(year from e_date) <= 2016;

CREATE VIEW violators AS
	SELECT p1.country_id
	FROM participation p1, participation p2
	WHERE p1.country_id = p2.country_id AND p1.year < p2.year AND p1.ratio > p2.ratio;

CREATE VIEW valid AS
	SELECT name, year, ratio
	FROM participation, country
	WHERE country_id = id AND country_id NOT IN (SELECT * FROM violators);

-- the answer to the query 
insert into q3 
	SELECT name AS countryName, year, ratio AS participationRatio
	FROM valid;


