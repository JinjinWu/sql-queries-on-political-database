SET search_path TO parlgov;

SELECT *
FROM q5
ORDER BY countryName, partyName, stateMarket DESC;
