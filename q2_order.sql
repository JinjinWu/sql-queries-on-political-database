SET search_path TO parlgov;

SELECT *
FROM q2
ORDER BY countryName, wonElections, partyName DESC;
