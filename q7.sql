-- Alliances

SET SEARCH_PATH TO parlgov;
drop table if exists q7 cascade;

-- You must not change this table definition.

DROP TABLE IF EXISTS q7 CASCADE;
CREATE TABLE q7(
        countryId INT, 
        alliedPartyId1 INT, 
        alliedPartyId2 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.
CREATE VIEW allies AS
	SELECT e1.party_id AS id1, e2.party_id AS id2, e1.election_id
	FROM election_result e1, election_result e2
	WHERE (e1.alliance_id = e2.id OR e1.alliance_id = e2.alliance_id OR e1.id = e2.alliance_id) AND e1.election_id = e2.election_id
		 AND e1.party_id < e2.party_id;

CREATE VIEW num_elections AS
	SELECT country_id, COUNT(id) AS num
	FROM election
	GROUP BY country_id;

CREATE VIEW num_allies AS
	SELECT id1, id2, COUNT(distinct election.id) AS num_allied_elections
	FROM allies, election
	WHERE allies.election_id = election.id
	GROUP BY id1, id2;

CREATE VIEW good_allies AS
	SELECT num_elections.country_id, id1, id2
	FROM num_allies, num_elections, party
	WHERE num_allies.id1 = party.id AND num_elections.country_id = party.country_id AND (num_allied_elections/num::float) >= 0.3;

-- the answer to the query 
insert into q7
	SELECT country_id AS countryId, id1 AS alliedPartyId1, id2 AS alliedPartyId2
	FROM good_allies;
