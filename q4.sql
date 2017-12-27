-- Left-right

SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

-- You must not change this table definition.


CREATE TABLE q4(
        countryName VARCHAR(50),
        r0_2 INT,
        r2_4 INT,
        r4_6 INT,
        r6_8 INT,
        r8_10 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

CREATE VIEW country_parties AS
	SELECT country_id, party_id, left_right
	FROM party_position, party
	WHERE party_id = id;

CREATE VIEW all_country_parties AS
	SELECT id AS country_id, party_id, left_right
	FROM country_parties RIGHT OUTER JOIN country
	ON country_id = id;

CREATE VIEW r1 AS
	SELECT country_id, count(left_right) AS r0_2
	FROM all_country_parties
	WHERE left_right >= 0 AND left_right < 2
	GROUP BY country_id;

CREATE VIEW r2 AS
        SELECT country_id, count(left_right) AS r2_4
        FROM all_country_parties
        WHERE left_right >= 2 AND left_right < 4
        GROUP BY country_id;

CREATE VIEW r3 AS
        SELECT country_id, count(left_right) AS r4_6
        FROM all_country_parties
        WHERE left_right >= 4 AND left_right < 6
        GROUP BY country_id;

CREATE VIEW r4 AS
        SELECT country_id, count(left_right) AS r6_8
        FROM all_country_parties
        WHERE left_right >= 6 AND left_right < 8
        GROUP BY country_id;

CREATE VIEW r5 AS
        SELECT country_id, count(left_right) AS r8_10
        FROM all_country_parties
        WHERE left_right >= 8 AND left_right <= 10
        GROUP BY country_id;

CREATE VIEW ranges AS
	SELECT r1.country_id, r1.r0_2, r2.r2_4, r3.r4_6, r4.r6_8, r5.r8_10
	FROM r1, r2, r3, r4, r5
	WHERE r1.country_id = r2.country_id AND r1.country_id = r3.country_id AND r1.country_id = r4.country_id
		AND r1.country_id = r5.country_id;


-- the answer to the query 
INSERT INTO q4
	SELECT name, r0_2, r2_4, r4_6, r6_8, r8_10
	FROM ranges, country
	WHERE country_id = id;

