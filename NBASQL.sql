-- NBA Data exploration using data set from https://www.basketball-reference.com/
-- Skills used: Joins, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types



-- Select Data that we are going to be starting with


SELECT player, YRS, city, state, country, pts, ast, trb, date 
FROM nba_players_birthdays
WHERE country LIKE '%USA%'



-- TOP NBA Scorers born in each decade since 1910
-- Top 10 Scorers each decade

SELECT player, YRS, city, state, country, pts, ast, trb, date 
FROM nba_players_birthdays
WHERE date BETWEEN 1910 AND 1919
-- WHERE date BETWEEN 1920 AND 1929
-- WHERE date BETWEEN 1930 AND 1939
-- WHERE date BETWEEN 1940 AND 1949
-- WHERE date BETWEEN 1950 AND 1959
-- WHERE date BETWEEN 1960 AND 1969
-- WHERE date BETWEEN 1970 AND 1979
-- WHERE date BETWEEN 1980 AND 1989
-- WHERE date BETWEEN 1990 AND 1999
-- WHERE date BETWEEN 2000 AND 2009
-- WHERE country LIKE 'USA'
ORDER BY pts DESC
LIMIT 10 


-- TOP NBA Scorers born outside the United States
-- Country with most total points



SELECT player, yrs, country, pts, date
FROM nba_players_birthdays
WHERE country NOT LIKE 'USA'
ORDER BY pts DESC



-- Countries with most total points, assists, and rebounds outside the US

SELECT country, sum(yrs) as TotalYearsPlayed, sum(pts) as points, sum(ast) as assists, sum(trb) as rebounds
FROM nba_players_birthdays
WHERE country NOT LIKE 'USA'
GROUP BY 1
-- ORDER BY points DESC
ORDER BY assists DESC
-- ORDER BY rebounds DESC



-- Countries with the highest average points, assists, and rebounds per game
-- With at least 5 years played

SELECT country, COUNT(player) as '#ofPlayers', AVG(pts_1) as avgpoints, AVG(ast_1) as avgassists, AVG(trb_1) as avgrebounds
FROM nba_players_birthdays
WHERE YRS >= 5
GROUP BY 1
ORDER BY avgpoints DESC
-- ORDER BY avgassists DESC
-- ORDER BY avgrebounds DESC



-- Highest Birthyear performers for NBA Players

SELECT DATE_FORMAT(date, '%Y') AS 'Year', COUNT(player) as '#ofPlayers', sum(pts) as points, sum(ast) as assists, sum(trb) as rebounds
FROM nba_players_birthdays
GROUP BY 1
-- ORDER BY points DESC
ORDER BY assists DESC
-- ORDER BY rebounds DESC



-- Best 3 point Shooters of all time

SELECT player, column_3P, pts
FROM nba_players_birthdays
WHERE column_3p IS NOT NULL
ORDER BY 2 DESC



-- Best 3 point Shooting by birthyear of all time

SELECT DATE_FORMAT(date, '%Y') AS 'Year', sum(column_3P) AS 3PM, sum(column_3P)*3 AS PointsFromThrees
FROM nba_players_birthdays
WHERE column_3p IS NOT NULL && 'Year' IS NOT NULL
GROUP BY 1
ORDER BY 1