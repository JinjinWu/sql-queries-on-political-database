-- Sequences

SET SEARCH_PATH TO parlgov;
drop table if exists q6 cascade;

-- You must not change this table definition.

CREATE TABLE q6(
        countryName VARCHAR(50),
        cabinetId INT, 
        startDate DATE,
        endDate DATE,
        pmParty VARCHAR(100)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW periods AS
	SELECT c1.country_id, c1.id AS cabinet_id, c1.start_date, c2.start_date AS end_date
	FROM cabinet c1 LEFT OUTER JOIN cabinet c2
	ON c1.id = c2.previous_cabinet_id;

CREATE VIEW periods_pm AS
	SELECT periods.country_id, periods.cabinet_id, start_date, end_date, party_id
	FROM periods LEFT OUTER JOIN cabinet_party
	ON periods.cabinet_id = cabinet_party.cabinet_id AND pm = TRUE;


-- the answer to the query 
insert into q6
	SELECT country.name AS countryName, cabinet_id AS cabinetId, start_date AS startDate,
		end_date AS endDate, party.name AS pmParty
	FROM periods_pm, country, party
	WHERE periods_pm.country_id = country.id AND periods_pm.party_id = party.id;
