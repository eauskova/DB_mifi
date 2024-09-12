--TASK 1
create table people(
id integer primary key,
last_name varchar(32) not NULL,
first_name varchar(32) not NULL,
second_name varchar(32),
sex char not NULL check (sex in ('м','ж')),
birthday date,
death_date date,
mother_id integer,
father_id integer,
foreign key (mother_id) references people(id),
foreign key (father_id) references people(id)
);
--TASK 2
create sequence people_id_seq start with -2 increment by -1;
insert into people values
(nextval('people_id_seq'),'Романов', 
'Николай','Павлович','м','17.07.1796','14.03.1855',null,null),
(nextval('people_id_seq'),'Романова', 
'Александра','Федоровна','ж','13.07.1798','01.11.1860',null,null);
insert into people values
(nextval('people_id_seq'),'Романов', 
'Александр','Николаевич','м','29.04.1818','13.03.1881', 
(select id from people where(first_name = 'Александра')), 
(select id from people where(first_name = 'Николай')));
insert into people values
(nextval('people_id_seq'),'Романова','Мария','Александровна
','ж','08.08.1824','03.06.1880',null,null);
insert into people values
(nextval('people_id_seq'),'Романов','Александр','Александро
вич','м','10.03.1845','01.11.1894',
(select id from people where(first_name = 'Мария')),
(select id from people where(second_name = 'Николаевич')));
select * from people;
--TASK 3
select f.last_name, f.first_name, f.second_name, s.last_name, s.first_name, s.second_name 
from people f 
left join people s on f.id=s.father_id where f.sex='м';
--TASK 4
update people set birthday = birthday + interval '3 months'; 
update people set death_date = death_date + interval '3 months';
--TASK 5
create or replace procedure long_livers(age integer) as $$
declare
i integer;
j record;
begin
i := 0;
for j in (select * from people where extract(year from age(death_date, birthday))>age)
loop
i := i + 1;
raise info '% % %', j.first_name, j.second_name, j.last_name;
end loop;
raise info 'Общее число: %', i;
raise info 'Максимальный возраст: %', (select max(extract(year from
age(death_date, birthday))) from people
where extract(year from age(death_date, 
birthday))>age);
raise info 'Минимальный возраст: %', (select min(extract(year from
age(death_date, birthday))) from people
where extract(year from age(death_date, 
birthday))>age);
raise info 'Средний возраст: %', (select round(avg(extract(year from
age(death_date, birthday))),2) from people
where extract(year from age(death_date, birthday))>age);
end
$$
language plpgsql;
call long_livers(70);
--TASK 6
with recursive length(id, mother_id) as (
select id, mother_id from people where id = -3
union all
select p.id, p.mother_id from people p join length l on l.id = p.mother_id)
select count(*) from length;
