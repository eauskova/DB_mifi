--- TASK 0
SELECT first_st.st_name as starting_station, last_st.st_name as ending_station FROM
"Routes" r
JOIN "Stations" first_st ON r.first_st_id = first_st.st_id
JOIN "Stations" last_st ON r.last_st_id = last_st.st_id
JOIN "Arrival_time" ar_tm_1 ON r.route_id = ar_tm_1.route_id
JOIN "Arrival_time" ar_tm_2 ON r.route_id = ar_tm_2.route_id
WHERE ar_tm_1.ar_time IS NOT NULL AND ar_tm_2.ar_time IS NOT NULL
AND ar_tm_1.st_id = (SELECT st_id FROM "Stations" WHERE st_name =
'Царицыно')
AND ar_tm_2.st_id = (SELECT st_id FROM "Stations" WHERE st_name = 'МоскваКурская')
AND ar_tm_1.ar_time < ar_tm_2.ar_time;
--- TASK 1
WITH st_count AS (SELECT s.st_name, COUNT(ar_tm.ar_time) as train_count FROM "Stations" s
JOIN "Arrival_time" ar_tm ON s.st_id = ar_tm.st_id WHERE ar_tm.ar_time IS NOT NULL
GROUP BY s.st_name),
max_count AS (SELECT MAX(train_count) AS max_train_count FROM st_count)
SELECT st_name FROM st_count WHERE train_count = (SELECT max_train_count FROM max_count);
--- TASK 2
WITH day_count AS (SELECT d.day_name, COUNT(w_d.day_id) AS dday_count FROM "Days" d
JOIN "Working_days" w_d ON d.day_id = w_d.day_id
GROUP BY d.day_name),
min_count AS (SELECT MIN(dday_count) AS min_dday_count FROM day_count)
SELECT day_name FROM day_count WHERE dday_count = (SELECT min_dday_count FROM
min_count);
--- TASK 3 
DELETE FROM "Stations"
WHERE st_id NOT IN (SELECT st_id FROM "Arrival_time" WHERE ar_time IS NOT NULL);
--- TASK 4
WITH st AS (SELECT st_id FROM "Stations" WHERE st_name = 'Яуза'),
new_first_st AS (UPDATE "Routes"
SET first_st_id = ((SELECT st_id FROM st) + 1) WHERE first_st_id = (SELECT
st_id FROM st)),
new_last_st as (UPDATE "Routes"
SET last_st_id = ((SELECT st_id FROM st) - 1) WHERE last_st_id = (SELECT st_id 
FROM st))
UPDATE "Arrival_time"
SET ar_time = NULL WHERE st_id = (SELECT st_id FROM st);
SELECT * FROM "Stations";
SELECT * FROM "Arrival_time";
--- TASK 5
ALTER TABLE public."Routes"
ADD COLUMN platform_number INTEGER;
UPDATE public."Routes"
SET platform_number = 1
WHERE public."Routes"."route_id" = 2;
SELECT * FROM public."Routes";
--- TASK 6
ALTER TABLE "Tarrif_zone"
ADD CONSTRAINT higher_price CHECK (price <= 2000.00);
