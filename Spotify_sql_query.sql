-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);



--EDA
SELECT COUNT(*) FROM spotify;

SELECT DISTINCT album_type FROM spotify;

SELECT * FROM spotify
WHERE duration_min = 0

DELETE FROM spotify
WHERE duration_min = 0;

SELECT DISTINCT most_played_on FROM spotify;

SELECT AVG(duration_min) FROM spotify;


--------------------------
--Data Analysis
--------------------------
/*
Retrieve the names of all tracks that have more than 1 billion streams.
List all albums along with their respective artists.
Get the total number of comments for tracks where licensed = TRUE.
Find all tracks that belong to the album type single.
Count the total number of tracks by each artist.
*/


--Q1. Retrieve the names of all tracks that have more than 1 billion streams.

SELECT * FROM spotify
WHERE stream > 1000000000


--List all albums along with their respective artists.

SELECT 
	album, artist
FROM spotify
ORDER BY 1


SELECT 
	DISTINCT album
FROM spotify
ORDER BY 1


--Get the total number of comments for tracks where licensed = TRUE.

SELECT SUM(comments) as total_comments
FROM spotify
WHERE licensed = 'true'


--Find all tracks that belong to the album type single.

SELECT * FROM spotify
WHERE album_type = 'single'


--Count the total number of tracks by each artist.

SELECT artist,
COUNT(track) 
FROM spotify
GROUP BY artist
ORDER BY 2 


/*
Calculate the average danceability of tracks in each album.
Find the top 5 tracks with the highest energy values.
List all tracks along with their views and likes where official_video = TRUE.
For each album, calculate the total views of all associated tracks.
Retrieve the track names that have been streamed on Spotify more than YouTube.
*/


--Calculate the average danceability of tracks in each album.

SELECT 
	album,
	AVG(danceability) as avg_danceability
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;


--Find the top 5 tracks with the highest energy values.

SELECT
	 track,
	 MAX(energy)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;


--List all tracks along with their views and likes where official_video = TRUE.


SELECT
	 track,
	 SUM(views) as total_views,
	 SUM(likes) as total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;



--For each album, calculate the total views of all associated tracks.

SELECT
	album,
	track,
	SUM(views)
FROM spotify
GROUP BY 1, 2
ORDER BY 3 DESC;


--Retrieve the track names that have been streamed on Spotify more than YouTube.

SELECT * FROM
(SELECT
	track,
	--most_played_on,
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END), 0) as stream_on_youtube,
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END), 0) as stream_on_spotify
FROM spotify
GROUP BY 1) AS t1
WHERE 
	stream_on_spotify>stream_on_youtube
	AND stream_on_youtube <> 0;



-------------------------
--Advanced problems
-------------------------
/*
Find the top 3 most-viewed tracks for each artist using window functions.
Write a query to find tracks where the liveness score is above the average.
Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
*/


--Find the top 3 most-viewed tracks for each artist using window functions.


WITH ranking_artist AS
(SELECT
	artist,
	track,
	SUM(views) AS total_views,
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS rank
FROM spotify
GROUP BY 1, 2
ORDER BY 1, 3 DESC)
SELECT * FROM ranking_artist
WHERE rank <=3;


--Write a query to find tracks where the liveness score is above the average.

SELECT 
	track,
	artist,
	liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness)
FROM spotify);



--Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.


WITH cte AS
(SELECT
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energy
FROM spotify
GROUP BY 1)
SELECT 
	album,
	highest_energy - lowest_energy as energy_diff
FROM cte
ORDER BY 2 DESC;



--Query optimization

EXPLAIN ANALYZE --et = 6.749 ms and pt = 0.111 ms
SELECT 
	artist,
	track,
	views
FROM spotify
WHERE artist = 'Gorillaz'
	AND most_played_on = 'Youtube'
ORDER BY stream DESC
LIMIT 250

CREATE INDEX artist_index ON spotify(artist)
