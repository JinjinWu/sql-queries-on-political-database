-- Winners

SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

create table q2(
countryName VARCHaR(100),
partyName VARCHaR(100),
partyFamily VARCHaR(100),
wonElections INT,
mostRecentlyWonElectionId INT,
mostRecentlyWonElectionYear INT
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

CREATE VIEW election_wins AS
	SELECT election_result.election_id AS election_id, election_result.party_id AS party_id,
		winning_votes.maxVotes AS votes, election.e_date AS e_date
	FROM election_result,
		(SELECT election_result.election_id AS election_id, MAX(votes) as maxVotes
		FROM election_result
		GROUP BY election_result.election_id) winning_votes, election
	WHERE election.id = election_result.election_id AND election.id =  winning_votes.election_id AND
		election_result.votes = winning_votes.maxVotes;

CREATE VIEW party_wins1 AS
	SELECT election_wins.party_id AS party_id, count(election_wins.election_id) as numWins
	FROM election_wins
	GROUP BY election_wins.party_id;

CREATE VIEW party_wins2 AS
	SELECT party.id AS party_id, 0 AS numWins
	FROM party;

CREATE VIEW party_wins AS
	SELECT party.country_id AS country_id, wins.party_id AS party_id, SUM(wins.numWins) AS numWins
	FROM (SELECT * FROM party_wins1 UNION ALL SELECT * FROM party_wins2) wins, party
	WHERE party.id = wins.party_id
	GROUP BY wins.party_id, party.country_id;

CREATE VIEW country_avg AS
	SELECT party_wins.country_id AS country_id, AVG(party_wins.numWins) AS avg_wins
	FROM party_wins
	GROUP BY party_wins.country_id;

CREATE VIEW popular_parties AS
	SELECT party_wins.country_id AS country_id, party_wins.party_id AS party_id, party_wins.numWins AS numWins
	FROM party_wins, country_avg
	WHERE party_wins.country_id = country_avg.country_id AND party_wins.numWins > 3*country_avg.avg_wins;

CREATE VIEW winners AS
	SELECT election_wins.election_id AS election_id, election_wins.party_id AS party_id, extract(year from recent_win.e_date) AS year
	FROM (SELECT election_wins.party_id AS party_id, MAX(election_wins.e_date) AS e_date
		FROM election_wins
		GROUP BY election_wins.party_id) recent_win, election_wins
	WHERE recent_win.party_id = election_wins.party_id AND recent_win.e_date = election_wins.e_date;

CREATE VIEW popular_winners AS
	SELECT popular_parties.party_id AS party_id, country.name AS countryName, winners.election_id AS election_id,
		winners.year AS year, popular_parties.numWins AS numWins
	FROM popular_parties, winners, country
	WHERE popular_parties.party_id = winners.party_id AND popular_parties.country_id = country.id;

CREATE VIEW popular_winners2 AS
        SELECT popular_winners.party_id AS party_id, party.name AS partyName, popular_winners.countryName AS countryName,
		popular_winners.election_id AS election_id, popular_winners.year AS year, popular_winners.numWins AS numWins
        FROM popular_winners, party
        WHERE popular_winners.party_id = party.id;

-- the answer to the query 
insert into q2
	SELECT popular_winners2.countryName AS countryName, popular_winners2.partyName AS partyName, party_family.family AS partyFamily,
		popular_winners2.numWins AS wonElections, popular_winners2.election_id AS mostRecentlyWonElectionId,
		popular_winners2.year AS mostRecentlyWonElectionYear
	FROM popular_winners2 LEFT OUTER JOIN party_family
	ON popular_winners2.party_id = party_family.party_id;


