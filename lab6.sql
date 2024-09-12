-- TASK 0
SELECT at.route_id, STRING_AGG(s.station_name, ', ' ORDER BY at.route_id) AS
stations_sequence 
FROM arrival_time AS at JOIN routes AS r ON at.route_id = r.route_id 
JOIN "Stations" AS s ON at.station_id = s.station_id 
WHERE at.time IS NOT NULL
GROUP BY at.route_id 
ORDER BY at.route_id;
--TASK 1
WITH numbered_stops AS ( 
SELECT DISTINCT s.station_id AS station_id, s.station_name AS station_name, 
at.route_id AS route_id, COUNT() OVER (PARTITION BY s.station_id) AS
num_trains_at_station, 
COUNT() OVER (PARTITION BY at.route_id) AS num_stations_on_route, 
ROW_NUMBER() OVER (PARTITION BY s.station_id, at.route_id ORDER BY s.station_id) AS
rn 
FROM public.arrival_time at
JOIN public."Stations" s ON at.station_id = s.station_id 
JOIN public.routes r ON at.route_id = r.route_id ) 
SELECT station_name, route_id, num_trains_at_station, num_stations_on_route 
FROM numbered_stops 
WHERE rn = 1
ORDER BY station_name, route_id
