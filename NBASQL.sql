-- %%
-- NBA Data exploration using data set from https://www.basketball-reference.com/
-- Skills used: Joins, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
-- %%


-- Cleaning DATA

UPDATE nba_players_birthdays
Set YRS = 10
WHERE player = 'C.J. Watson'

UPDATE nba_players_birthdays
Set YRS = 1
WHERE player = 'Randy Stoll'

UPDATE nba_players_birthdays
Set YRS = 1
WHERE player = 'Duck Williams'

UPDATE nba_players_birthdays
Set date = '1984-04-17 00:00:00'
WHERE player = 'C.J. Watson'

UPDATE nba_players_birthdays
Set date = '1945-01-01 00:00:00'
WHERE player = 'Randy Stoll'

UPDATE nba_players_birthdays
Set date = '1956-08-02 00:00:00'
WHERE player = 'Duck Williams'

DESC nba_players_birthdays

ALTER TABLE nba_players_birthdays
MODIFY date DATETIME


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

SELECT CAST(date as YEAR) AS 'Year', SUM(column_3P) AS 3PM, sum(column_3P)*3 AS PointsFromThrees
FROM nba_players_birthdays
WHERE column_3p IS NOT NULL && 'Year' IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC



-- Amount of points scored from 3s from each birthyear
-- Using Partition by to calculate points from three pointers for each birthyear

SELECT CAST(date as YEAR) AS 'Year', player, SUM(column_3P) AS 3PM, sum(column_3P)*3 AS PointsFromThrees,
Sum(column_3P) OVER (Partition by (CAST(date as YEAR)) ORDER BY '3PM')*3 AS RollingPointFrom3s
FROM nba_players_birthdays
WHERE column_3p IS NOT NULL && 'Year' IS NOT NULL && column_3p > 0
GROUP BY 1, 2
ORDER BY 1 



-- % of Points from threes vs Total Points for each player and birthyear (BY)

SELECT CAST(date as YEAR) AS 'Year', player, SUM(column_3P) AS 3PM, sum(column_3P)*3 AS PointsFromThrees,
Sum(column_3P) OVER (Partition by (CAST(date as YEAR)) ORDER BY '3PM')*3 AS RollingPointFrom3s, pts, 
Sum(pts) OVER (Partition by (CAST(date as YEAR)) ORDER BY '3PM') AS RollingTotalPoints,
Sum(column_3P)*3/(pts)*100 AS 'Player%PtsAre3',
(Sum(column_3P) OVER (Partition by (CAST(date as YEAR)) ORDER BY '3PM')*3)/Sum(pts) OVER (Partition by (CAST(date as YEAR)) ORDER BY '3PM')*100 AS 'RollingBY%PtsAre3'
FROM nba_players_birthdays
WHERE column_3p IS NOT NULL && 'Year' IS NOT NULL && column_3p > 0
GROUP BY 1, player
ORDER BY 1 

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE if exists 3PointersvTotalPoints
CREATE TABLE 3PointersvTotalPoints(
date DATETIME ,
player VARCHAR(100) ,
3PM INT ,
PointsFromThrees INT ,
RollingPointFrom3s INT,
points INT,
RollingTotalPoints INT
)

-- DESC 3PointersvTotalPoints

INSERT INTO 3PointersvTotalPoints
SELECT CAST(date as DATETIME) AS 'date', player, SUM(column_3P) AS 3PM, sum(column_3P)*3 AS PointsFromThrees,
Sum(column_3P) OVER (Partition by (CAST(date as YEAR)) ORDER BY '3PM')*3 AS RollingPointFrom3s, pts, 
Sum(pts) OVER (Partition by (CAST(date as YEAR)) ORDER BY '3PM') AS RollingTotalPoints
-- Sum(column_3P)*3/(pts)*100 AS 'Player%PtsAre3',
-- (Sum(column_3P) OVER (Partition by (CAST(date as YEAR)) ORDER BY '3PM')*3)/Sum(pts) OVER (Partition by (CAST(date as YEAR)) ORDER BY '3PM')*100 AS 'RollingBY%PtsAre3'
FROM nba_players_birthdays
WHERE column_3p IS NOT NULL && 'Year' IS NOT NULL && column_3p > 0
GROUP BY 1, player
ORDER BY 1 

SELECT *, (3PM/points)*100 AS 'Player%PtsAre3', (RollingPointFrom3s/RollingTotalPoints)*100 AS 'RollingBY%PtsAre3'
FROM 3PointersvTotalPoints


-- Creating views for Tableau Dashboard

-- Countries with the highest average NBA lifespan

SELECT country, AVG(yrs) AS Lifespan, Count(RK) AS Players, AVG(pts), AVG(ast), AVG(trb)
FROM nba_players_birthdays
GROUP BY 1
ORDER BY 2 DESC


-- USA States with the highest average NBA lifespan

SELECT state, AVG(yrs) AS Lifespan, Count(RK) AS Players, AVG(pts), AVG(ast), AVG(trb)
FROM nba_players_birthdays
WHERE state IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC



-- The best 3 Point Shooting USA States
SELECT state, SUM(Column_3P) as '3PM', SUM(Column_3PA) as '3PA', SUM(Column_3P)/SUM(Column_3PA) AS '3P%', Count(RK) AS Players
FROM nba_players_birthdays
WHERE state IS NOT NULL
GROUP BY 1
ORDER BY '3PM' DESC

