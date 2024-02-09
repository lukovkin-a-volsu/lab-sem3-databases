-- View

-- CREATE
--     [OR REPLACE]
--     [ALGORITHM = {UNDEFINED | MERGE | TEMPTABLE}]
--     [DEFINER = user]
--     [SQL SECURITY { DEFINER | INVOKER }]
--     VIEW view_name [(column_list)]
--     AS select_statement
--     [WITH [CASCADED | LOCAL] CHECK OPTION]


-- View
create view v_read (`Фамилия администратора`, `Имя администратора`, `Отчество администратора`, `Мобильный номер администратора`, `Эл. почта администратора`,
					`Фамилия гостя`, `Имя гостя`, `Отчество гостя`, `Мобильный номер гостя`, `Эл. почта гостя`,
                    `Комната, №`, `Вместимость`, `Статус`, `Дата заезда`, `Дата отъезда`, `Цена за сутки`, `Общая сумма`) as 
	select
	pa.last_name, pa.first_name, pa.patronymic, pa.mobile_num, pa.email,
    pg.last_name, pg.first_name, pg.patronymic, pg.mobile_num, pg.email,
    r.id_room, rm.capacity, s.value, r.check_in_date, r.check_out_date, r.daily_price, r.total_price 
    from (((((receipt as r join guest as g on g.id=r.id_guest)
	join admin as a on a.id=r.id_admin)
	  join personal_data as pa on pa.id=a.id_personal_data)
	   join personal_data as pg on pg.id=g.id_personal_data)
		 join room as rm on rm.id=r.id_room)
		  join status as s on rm.id_status=s.id;

select * from v_read;
-- -- -- -- -- -- -- -- -- -- --

-- Расширяемая форма
alter table room add column (test1 int not null);

create view v_room as
  select * from room;

insert v_room(id_status, capacity, daily_price, test1) values (1, 2, 1000, 1);
select * from room;
alter table room drop column test1;
-- -- -- -- -- -- -- -- -- -- --

-- Постоянная форма
create view v_pg as 
	select pg.last_name, pg.first_name, pg.patronymic
    from personal_data as pg join guest as g on g.id_personal_data=pg.id;

select * from v_pg;
-- -- -- -- -- -- -- -- -- -- --

-- RESTRICT и CASCADE
alter table guest add column (test int not null);

create view v_guest as
	select * from guest;

-- alter table guest drop column test restrict; -- ограничит если есть ссылка в представлении
alter table guest drop column test cascade; -- удаление будет происходить каскадно

-- select * from v_guest;
-- -- -- -- -- -- -- -- -- -- --

-- С опциями
create or replace view v_room as
	select * from room as rm where rm.daily_price < 6000 and capacity = 1;

create view v_room1 as
	select * from v_room as v_rm where v_rm.daily_price < 4000
    with cascaded check option;
    
-- по умолчанию local check option
-- Ошибка, так как условия проверяются каскадно и при добавлении в представление
-- что имеет в подзапросе другое представление, его условие должно выполняться
-- insert into v_room1 (id_status, capacity, daily_price) values (1, 2, 3000);
    
select * from room;
select * from v_room;
select * from v_room1;

-- -- -- -- -- -- -- -- -- -- --