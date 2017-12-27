-- VoteRange

SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;

-- You must not change this table definition.

create table q1(
year INT,
countryName VARCHAR(50),
voteRange VARCHAR(20),
partyName VARCHAR(100)
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

CREATE VIEW valid_elections AS
	SELECT extract(year from election.e_date) AS year, election.id AS election_id,
		country.name AS countryname, election.votes_valid AS votes_valid
	FROM election JOIN country ON election.country_id = country.id
	WHERE extract(year from election.e_date) >= 1996 AND extract(year from election.e_date) <= 2016;

CREATE VIEW party_results AS
	SELECT valid_elections.year AS year, election_result.party_id AS party_id, valid_elections.countryname AS countryname,
		AVG(election_result.votes / cast(valid_elections.votes_valid as float)) AS votes_percent
	FROM valid_elections, election_result
	WHERE valid_elections.election_id = election_result.election_id
	GROUP BY valid_elections.year, election_result.party_id, valid_elections.countryname;

CREATE VIEW range1 AS
	SELECT party_results.year AS year, party_results.countryname AS countryName, '(0-5]' AS voteRange, party.name_short AS partyName
	FROM party_results, party
	WHERE party_results.party_id = party.id AND party_results.votes_percent > 0 AND party_results.votes_percent <= 0.05;

CREATE VIEW range2 AS
        SELECT party_results.year AS year, party_results.countryname AS countryName, '(5-10]' AS voteRange, party.name_short AS partyName
        FROM party_results, party
        WHERE party_results.party_id = party.id AND party_results.votes_percent > 0.05 AND party_results.votes_percent <= 0.10;

CREATE VIEW range3 AS
        SELECT party_results.year AS year, party_results.countryname AS countryName, '(10-20]' AS voteRange, party.name_short AS partyName
        FROM party_results, party
        WHERE party_results.party_id = party.id AND party_results.votes_percent > 0.10 AND party_results.votes_percent <= 0.20;

CREATE VIEW range4 AS
        SELECT party_results.year AS year, party_results.countryname AS countryName, '(20-30]' AS voteRange, party.name_short AS partyName
        FROM party_results, party
        WHERE party_results.party_id = party.id AND party_results.votes_percent > 0.20 AND party_results.votes_percent <= 0.30;

CREATE VIEW range5 AS
        SELECT party_results.year AS year, party_results.countryname AS countryName, '(30-40]' AS voteRange, party.name_short AS partyName
        FROM party_results, party
        WHERE party_results.party_id = party.id AND party_results.votes_percent > 0.30 AND party_results.votes_percent <= 0.40;

CREATE VIEW range6 AS
        SELECT party_results.year AS year, party_results.countryname AS countryName, '(40-100]' AS voteRange, party.name_short AS partyName
        FROM party_results, party
        WHERE party_results.party_id = party.id AND party_results.votes_percent > 0.40 AND party_results.votes_percent <= 1.00;




-- the answer to the query 
insert into q1
	SELECT *
	FROM (SELECT * FROM range1 UNION ALL
		SELECT * FROM range2 UNION ALL
		SELECT * FROM range3 UNION ALL
		SELECT * FROM range4 UNION ALL
		SELECT * FROM range5 UNION ALL
		SELECT * FROM range6) ranges;

