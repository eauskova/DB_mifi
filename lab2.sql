BEGIN;
-- DROP TABLE IF EXISTS public."Stations";
-- DROP TABLE IF EXISTS public."Routes";
-- DROP TABLE IF EXISTS public."Ticket_price";
-- DROP TABLE IF EXISTS public."Days";
-- DROP TABLE IF EXISTS public."Working_days";
-- DROP TABLE IF EXISTS public."Arrival_time";
-- DROP TABLE IF EXISTS public."Tarrif_zone";
CREATE TABLE IF NOT EXISTS public."Stations"
(
st_id serial,
st_name character varying(60) NOT NULL,
tarrif_zone_id integer NOT NULL,
st_index integer NOT NULL,
PRIMARY KEY (st_id),
CONSTRAINT unique_station UNIQUE (st_name)
);
CREATE TABLE IF NOT EXISTS public."Routes"
(
route_id serial,
first_st_id integer NOT NULL,
last_st_id integer NOT NULL CHECK (first_st_id <> last_st_id),
PRIMARY KEY (route_id)
);
CREATE TABLE IF NOT EXISTS public."Ticket_price"
(
ticket_id serial,
amount_tz integer NOT NULL,
PRIMARY KEY (ticket_id)
);
CREATE TABLE IF NOT EXISTS public."Days"
(
day_id serial,
day_name character varying(2) NOT NULL CHECK (day_name IN ('ПН', 'ВТ', 'СР', 
'ЧТ', 'ПТ', 'СБ', 'ВС')),
PRIMARY KEY (day_id)
);
CREATE TABLE IF NOT EXISTS public."Working_days"
(
route_id integer,
day_id integer,
PRIMARY KEY (route_id, day_id)
);
CREATE TABLE IF NOT EXISTS public."Arrival_time"
(
route_id integer,
st_id integer,
ar_time time with time zone,
PRIMARY KEY (route_id, st_id)
);
CREATE TABLE IF NOT EXISTS public."Tarrif_zone"
(
amount_tz serial,
price numeric(6, 2) NOT NULL,
PRIMARY KEY (amount_tz)
);
ALTER TABLE IF EXISTS public."Routes"
ADD FOREIGN KEY (first_st_id)
REFERENCES public."Stations" (st_id) MATCH SIMPLE
ON UPDATE NO ACTION
ON DELETE NO ACTION
NOT VALID;
ALTER TABLE IF EXISTS public."Routes"
ADD FOREIGN KEY (last_st_id)
REFERENCES public."Stations" (st_id) MATCH SIMPLE
ON UPDATE NO ACTION
ON DELETE NO ACTION
NOT VALID;
ALTER TABLE IF EXISTS public."Ticket_price"
ADD FOREIGN KEY (amount_tz)
REFERENCES public."Tarrif_zone" (amount_tz) MATCH SIMPLE
ON UPDATE NO ACTION
ON DELETE NO ACTION
NOT VALID;
ALTER TABLE IF EXISTS public."Working_days"
ADD FOREIGN KEY (day_id)
REFERENCES public."Days" (day_id) MATCH SIMPLE
ON UPDATE NO ACTION
ON DELETE NO ACTION
NOT VALID;
ALTER TABLE IF EXISTS public."Working_days"
ADD FOREIGN KEY (route_id)
REFERENCES public."Routes" (route_id) MATCH SIMPLE
ON UPDATE NO ACTION
ON DELETE NO ACTION
NOT VALID;
ALTER TABLE IF EXISTS public."Arrival_time"
ADD FOREIGN KEY (route_id)
REFERENCES public."Routes" (route_id) MATCH SIMPLE
ON UPDATE NO ACTION
ON DELETE NO ACTION
NOT VALID;
ALTER TABLE IF EXISTS public."Arrival_time"
ADD FOREIGN KEY (st_id)
REFERENCES public."Stations" (st_id) MATCH SIMPLE
ON UPDATE NO ACTION
ON DELETE NO ACTION
NOT VALID;
END;
