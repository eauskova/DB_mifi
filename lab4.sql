-----------------------------------------------------------------------------------------
-----------
--TRIGGER
CREATE OR REPLACE FUNCTION check_st_count() RETURNS trigger AS $$
DECLARE
st_count INTEGER;
BEGIN
SELECT COUNT(*) INTO st_count FROM "Arrival_time"
WHERE route_id = NEW.route_id AND ar_time IS NOT NULL;
IF st_count >= 5 THEN
RAISE EXCEPTION 'Поезд не может останавливать больше, 
чем на 5 станциях.';
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE TRIGGER check_st_before
AFTER INSERT OR UPDATE ON "Arrival_time"
FOR EACH ROW
EXECUTE PROCEDURE check_st_count();
INSERT INTO public."Stations"(st_name, tarrif_zone_id, st_index) VALUES
('Текстильщики', 5,5);
SELECT * FROM public."Stations";
INSERT INTO public."Arrival_time"(route_id, st_id, ar_time) VALUES
(1, 13, '16:00');
select * from public."Arrival_time";
delete from public."Arrival_time" where route_id=4 and st_id =12;
delete from public."Stations" where st_id =12;
-----------------------------------------------------------------------------------------
-----------
--FUNCTION
CREATE OR REPLACE PROCEDURE price_of_ticket(first_station VARCHAR(20), last_station 
VARCHAR(20)) AS $$ 
DECLARE
cnt_transit_zone INTEGER; 
total_price INTEGER; 
prov record;
BEGIN
cnt_transit_zone := ((SELECT tarrif_zone_id FROM public."Stations" WHERE st_name =
last_station)
- (SELECT tarrif_zone_id FROM public."Stations" WHERE st_name = first_station)); 
SELECT first_st.st_name as starting_station, last_st.st_name as ending_station into
prov FROM "Routes" r
JOIN "Stations" first_st ON r.first_st_id = first_st.st_id
JOIN "Stations" last_st ON r.last_st_id = last_st.st_id
JOIN "Arrival_time" ar_tm_1 ON r.route_id = ar_tm_1.route_id
JOIN "Arrival_time" ar_tm_2 ON r.route_id = ar_tm_2.route_id
WHERE ar_tm_1.ar_time IS NOT NULL AND ar_tm_2.ar_time IS NOT NULL
AND ar_tm_1.st_id = (SELECT st_id FROM "Stations" WHERE st_name =
first_station)
AND ar_tm_2.st_id = (SELECT st_id FROM "Stations" WHERE st_name =
last_station)
AND ar_tm_1.ar_time < ar_tm_2.ar_time;
IF prov IS null THEN RAISE EXCEPTION 'Нет прямого сообщения
между станциями % и %', first_station, last_station;
END IF; 
total_price := (SELECT price FROM public."Tarrif_zone" WHERE amount_tz =
cnt_transit_zone); 
RAISE INFO 'Цена поездки = %', total_price; 
END; 
$$ LANGUAGE plpgsql;
CALL price_of_ticket('Стрешнево', 'Остафьево');
-- --------------------------------------------------------------------------------------
--------------
-- --AGGREGATE
CREATE OR REPLACE FUNCTION max_lenght_func(INTEGER[], INTEGER) RETURNS INTEGER[] AS $$ 
DECLARE
tarif_id INTEGER;
BEGIN
SELECT tarrif_zone_id INTO tarif_id FROM public."Stations" s WHERE s.st_id = $2;
IF tarif_id < $1[1] 
THEN $1[1] := tarif_id;
END IF;
IF tarif_id > $1[2]
THEN $1[2] := tarif_id;
END IF;
RETURN $1;
END; 
$$ LANGUAGE plpgsql; 
CREATE OR REPLACE AGGREGATE max_way(INTEGER) 
( 
stype = INTEGER[], 
sfunc = max_lenght_func,
finalfunc = max_lenght_final,
initcond = '{10, 0}'
);
CREATE OR REPLACE FUNCTION max_lenght_final(integer[]) RETURNS VOID AS $$
BEGIN
RAISE INFO 'Максимальное расстояние в зонах: %', ($1[2]-
$1[1]);
END;
$$ LANGUAGE plpgsql;
SELECT max_way(st_id) FROM public."Stations" where st_id in (1,3,4);
-----------------------------------------------------------------------------------------
-----------
--VIEW
CREATE OR REPLACE VIEW pro100_stations AS
SELECT st_name, st_id, tarrif_zone_id FROM public."Stations";
CREATE OR REPLACE FUNCTION update_tarrif_zone() RETURNS TRIGGER AS $$
BEGIN
UPDATE public."Stations"
SET tarrif_zone_id = new.tarrif_zone_id
WHERE st_id = new.st_id;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE TRIGGER trig
INSTEAD OF UPDATE ON pro100_stations
FOR EACH ROW
EXECUTE FUNCTION update_tarrif_zone(); 
UPDATE pro100_stations
SET tarrif_zone_id = 1212
WHERE st_id = 1;
SELECT * FROM public."Stations";
UPDATE public."Stations" SET tarrif_zone_id = 1 WHERE st_id = 1;
SELECT * FROM public."Stations" ORDER BY st_id ASC;
-----------------------------------------------------------------------------------------
-----------
--STACK
CREATE OR REPLACE PROCEDURE _stack_init(name_stack_with_scheme TEXT) AS $$
BEGIN
EXECUTE format('DROP TABLE IF EXISTS %s', name_stack_with_scheme);
EXECUTE format('CREATE TABLE IF NOT EXISTS %s (id SERIAL PRIMARY KEY, _value TEXT)', 
name_stack_with_scheme);
END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE PROCEDURE _stack_push(name_stack_with_scheme TEXT, new_value TEXT) AS
$$
BEGIN
EXECUTE format('INSERT INTO %s(_value) VALUES (%s)', name_stack_with_scheme, 
new_value);
END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION _stack_top(name_stack_with_scheme TEXT) RETURNS TEXT AS $$
DECLARE
topped_value TEXT;
BEGIN
EXECUTE (format('SELECT _value FROM %s WHERE id = (SELECT MAX(id) FROM %s)',
name_stack_with_scheme, name_stack_with_scheme)) INTO topped_value;
RETURN topped_value;
END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION _stack_pop(name_stack_with_scheme TEXT) RETURNS TEXT AS $$
DECLARE
popped_value TEXT;
BEGIN
EXECUTE (format('SELECT _value FROM %s WHERE id = (SELECT MAX(id) FROM %s)',
name_stack_with_scheme, name_stack_with_scheme)) INTO popped_value;
EXECUTE format('DELETE FROM %s WHERE id = (SELECT MAX(id) FROM %s)', 
name_stack_with_scheme, name_stack_with_scheme);
RETURN popped_value;
END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE PROCEDURE _stack_empty(name_stack_with_scheme TEXT) AS $$
BEGIN
CALL _stack_init(name_stack_with_scheme);
END;
$$ LANGUAGE plpgsql;
CALL _stack_init('public.test2');
SELECT * FROM public.test2;
CALL _stack_push('public.test2', '5');
CALL _stack_push('public.test2', '7');
CALL _stack_push('public.test2', '9');
CALL _stack_push('public.test2', '12');
SELECT * FROM public.test2;
SELECT _stack_top('public.test2');
SELECT _stack_pop('public.test2'); 
SELECT _stack_pop('public.test2'); 
SELECT _stack_pop('public.test2'); 
SELECT _stack_pop('public.test2'); 
SELECT _stack_pop('public.test2'); 
SELECT _stack_pop('public.test2');
