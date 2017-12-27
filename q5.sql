-- Committed

SET SEARCH_PATH TO parlgov;
drop table if exists q5 cascade;

-- You must not change this table definition.

CREATE TABLE q5(
        countryName VARCHAR(50),
        partyName VARCHAR(100),
        partyFamily VARCHAR(50),
        stateMarket REAL
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW cabinets20 AS
	SELECT country_id, cabinet_id, party_id
	FROM cabinet, cabinet_party
	WHERE extract(year from start_date) >= 1996 AND extract(year from start_date) <= 2016
		AND cabinet_id = cabinet.id;

CREATE VIEW required AS
	SELECT party.country_id, cabinet_id, party.id AS party_id
	FROM party, (SELECT country_id, cabinet_id FROM cabinets20) country_cabinets
	WHERE party.country_id = country_cabinets.country_id;


CREATE VIEW missing AS
	(SELECT * FROM required)
	EXCEPT
	(SELECT * FROM cabinets20);

CREATE VIEW commited AS
	(SELECT * FROM cabinets20)
	EXCEPT
	(SELECT * FROM missing);

CREATE VIEW commited2 AS
	SELECT commited.country_id, party.name, commited.party_id
	FROM commited, party
	WHERE commited.party_id = party.id;

CREATE VIEW commited3 AS
	SELECT country_id, name, commited2.party_id, family
	FROM commited2 LEFT OUTER JOIN party_family
	ON commited2.party_id = party_family.party_id;

CREATE VIEW commited4 AS
	SELECT country_id, name, family, state_market
	FROM commited3 LEFT OUTER JOIN party_position
	ON commited3.party_id = party_position.party_id;


-- the answer to the query 
insert into q5
	SELECT DISTINCT country.name AS countryName, commited4.name AS partyName, family AS partyFamily, state_market AS stateMarket
	FROM commited4, country
	WHERE commited4.country_id = country.id;
