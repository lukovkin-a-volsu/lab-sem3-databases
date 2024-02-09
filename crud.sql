use hotel;

-- CRUD

delimiter //
create procedure receiptRead()
begin
    declare exit handler for sqlexception
    begin
        rollback;
        select 'Ошибка вывода';
    end;
	start transaction;
	select distinct 
	pa.last_name as "Фамилия администратора", 
	pa.first_name as "Имя администратора", 
	pa.patronymic as "Отчество администратора", 
    pa.mobile_num as "Мобильный номер администратора",
    pa.email as "Эл. почта администратора",
	pg.last_name as "Фамилия гостя", 
	pg.first_name as "Имя гостя", 
	pg.patronymic as "Отчество гостя", 
	pg.mobile_num as "Мобильный номер гостя",
    pg.email as "Эл. почта гостя",
    r.id_room as "Комната, №", 
    rm.capacity as "Вместимость",
    s.value as "Статус", 
	r.check_in_date as "Дата заезда", 
	r.check_out_date as "Дата отъезда", 
	r.daily_price as "Цена за сутки", 
	r.total_price as "Общая сумма" 
    from 
	(((((receipt as r join guest as g on g.id=r.id_guest)
	join admin as a on a.id=r.id_admin)
	  join personal_data as pa on pa.id=a.id_personal_data)
	   join personal_data as pg on pg.id=g.id_personal_data)
		 join room as rm on rm.id=r.id_room)
		  join status as s on rm.id_status=s.id;
	commit;
end//
delimiter ;

delimiter //
create procedure receiptCreate(
in in_admin_last_name varchar(255), 
in in_admin_first_name varchar(255),
in in_admin_patronymic varchar(255),
in in_admin_mobile_num char(11),
in in_admin_email varchar(255),
in in_guest_last_name varchar(255),
in in_guest_first_name varchar(255),
in in_guest_patronymic varchar(255),
in in_guest_mobile_num char(11),
in in_guest_email varchar(255),
in in_room_id int,
in in_room_capacity int,
in in_room_status int,
in in_check_in_date date,
in in_check_out_date date,
in in_daily_price decimal(7, 2)
)
proc_start: begin
	declare days_count int default null;    
	declare found_admin_id int default null;
	declare found_guest_id int default null;
    declare found_room_id int default null;
	declare found_room_daily_price int default null;
    declare temp_id int default null;
    declare default_admin_salary decimal(8, 2) default 50000;
	declare exit handler for sqlexception
    begin
        rollback;
        select 'Ошибка создания';
    end;
	
    set days_count = datediff(in_check_out_date, in_check_in_date);
    
    if (days_count < 0) then
		select 'Бронирование должно быть хотя бы на один день!' as 'Информация';
        leave proc_start;
	end if;
 
    -- Поиск айди администратора по фио, номеру и почте
    set found_admin_id = (select a.id from admin as a join personal_data as pd on a.id_personal_data=pd.id and pd.last_name=in_admin_last_name and pd.first_name=in_admin_first_name and pd.patronymic=in_admin_patronymic and pd.mobile_num=in_admin_mobile_num and pd.email=in_admin_email);
	-- Поиск айди гостя по фио, номеру и почте
    set found_guest_id = (select g.id from guest as g join personal_data as pd on g.id_personal_data=pd.id and pd.last_name=in_guest_last_name and pd.first_name=in_guest_first_name and pd.patronymic=in_guest_patronymic and pd.mobile_num=in_guest_mobile_num and pd.email=in_guest_email);
    -- Поиск айди комнаты по номеру комнаты
    set found_room_id = (select rm.id from room as rm where rm.id=in_room_id);
        
    if found_admin_id is not null then
		select 'Администратор был найден.' as 'Информация' union select 'Последующее добавление будет относиться к нему.';
	else
		(select 'Администратор не найден ' as 'Информация' union select 'Создан новый администратор.') union select 'Последующее добавление будет относиться к нему';
		insert personal_data(last_name, first_name, patronymic, mobile_num, email) values (in_admin_last_name, in_admin_first_name, in_admin_patronymic, in_admin_mobile_num, in_admin_email);
        -- personal_data id
        set temp_id = (select max(id) from personal_data);
        insert admin(id_personal_data, salary) values (temp_id, default_admin_salary);
        set found_admin_id = (select max(id) from admin);
		-- set found_admin_id = (select a.id from admin as a join personal_data as pd on pd.last_name=in_admin_last_name and pd.first_name=in_admin_first_name and pd.patronymic=in_admin_patronymic and pd.mobile_num=in_admin_mobile_num and pd.email=in_admin_email);
    end if;
    
	if found_guest_id is not null then
		select 'Гость был найден.' as 'Информация' union select 'Последующее добавление будет относиться к нему.';
	else
		(select 'Гость не найден ' as 'Информация' union select 'Создан новый гость.') union select 'Последующее добавление будет относиться к нему';
        insert personal_data(last_name, first_name, patronymic, mobile_num, email) values (in_guest_last_name, in_guest_first_name, in_guest_patronymic, in_guest_mobile_num, in_guest_email);
		-- personal_data id
        set temp_id = (select max(id) from personal_data);
        insert guest(id_personal_data) values (temp_id);
        set found_guest_id = (select max(id) from guest);
        -- set found_guest_id = (select g.id from guest as g join personal_data as pd on pd.last_name=in_guest_last_name and pd.first_name=in_guest_first_name and pd.patronymic=in_guest_patronymic and pd.mobile_num=in_guest_mobile_num and pd.email=in_guest_email);
    end if;
    
	if found_room_id is not null then
		select 'Комната была найдена.' as 'Информация' union select 'Последующее добавление будет относиться к нему.';
	else
		(select 'Комната не найдена' as 'Информация' union select 'Создана новая комната.') union select 'Последующее добавление будет относиться к нему';
        -- TODO: ифы по комнате, чтобы не номер вводить, а строку
        insert room(id_status, capacity, daily_price) values(in_room_status, in_room_capacity, in_daily_price);
		set found_room_id = (select max(id) from room);
    end if;
    
    insert receipt(id_admin, id_guest, id_room, check_in_date, check_out_date, daily_price, total_price) values 
        (found_admin_id, found_guest_id, found_room_id, in_check_in_date, in_check_out_date, in_daily_price, in_daily_price * days_count);
    
	/* Замечания
    * Поиск комнаты осуществляется по ее номеру. В случае заданных данных приоритет отдается комнате найденной по номеру
    */
    commit;
end//
delimiter ;

delimiter //
create procedure receiptDelete(
in in_admin_last_name varchar(255), 
in in_admin_first_name varchar(255),
in in_admin_patronymic varchar(255),
in in_admin_mobile_num char(11),
in in_admin_email varchar(255),
in in_guest_last_name varchar(255),
in in_guest_first_name varchar(255),
in in_guest_patronymic varchar(255),
in in_guest_mobile_num char(11),
in in_guest_email varchar(255),
in in_room_id int,
in in_check_in_date date,
in in_check_out_date date,
in in_daily_price decimal(7, 2)
)
begin
	declare receipt_id int default null;
	declare admin_count int default null;
    declare guest_count int default null;
    declare room_count int default null;
    declare temp_id int default null;
	declare temp_personal_data_id int default null;
	declare personal_data_count int default null;
	declare exit handler for sqlexception
    begin
        rollback;
        select 'Ошибка удаления';
    end;
	start transaction;  
    
	set receipt_id = (select distinct r.id from 
	(((((receipt as r join guest as g on g.id=r.id_guest)
	join admin as a on a.id=r.id_admin)
	  join personal_data as pa on pa.id=a.id_personal_data and pa.last_name=in_admin_last_name and pa.first_name=in_admin_first_name and pa.patronymic=in_admin_patronymic and pa.mobile_num=in_admin_mobile_num and pa.email=in_admin_email)
	   join personal_data as pg on pg.id=g.id_personal_data and pg.last_name=in_guest_last_name and pg.first_name=in_guest_first_name and pg.patronymic=in_guest_patronymic and pg.mobile_num=in_guest_mobile_num and pg.email=in_guest_email)
		 join room as rm on rm.id=r.id_room and rm.id=in_room_id)
		  join status as s on rm.id_status=s.id
			where r.check_in_date=in_check_in_date and r.check_out_date=in_check_out_date and r.daily_price=in_daily_price);	
	
	set admin_count = (select distinct count(*) from 
	((receipt as r join admin as a on a.id=r.id_admin)
	  join personal_data as pa on pa.id=a.id_personal_data and pa.last_name=in_admin_last_name and pa.first_name=in_admin_first_name and pa.patronymic=in_admin_patronymic and pa.mobile_num=in_admin_mobile_num and pa.email=in_admin_email)
	);	
	
    set guest_count = (select distinct count(*) from 
	((receipt as r join guest as g on g.id=r.id_guest)
	   join personal_data as pg on pg.id=g.id_personal_data and pg.last_name=in_guest_last_name and pg.first_name=in_guest_first_name and pg.patronymic=in_guest_patronymic and pg.mobile_num=in_guest_mobile_num and pg.email=in_guest_email)
	);
    
    set room_count = (select distinct count(*) from 
	receipt as r join room on room.id=in_room_id);
    
	delete from receipt as r where r.id=receipt_id;
	if receipt_id is not null then
		select 'Удаление записи произошло успешно.' as 'Информация';
	else
		select 'Записи не существует.' as 'Информация';
	end if;
    
    if (admin_count <= 1) then
		set temp_id = (select distinct a.id from 
		((receipt as r join admin as a on a.id=r.id_admin)
		  join personal_data as pa on pa.id=a.id_personal_data and pa.last_name=in_admin_last_name and pa.first_name=in_admin_first_name and pa.patronymic=in_admin_patronymic and pa.mobile_num=in_admin_mobile_num and pa.email=in_admin_email)
		);
        set personal_data_count = (select distinct count(*) from personal_data as pa where pa.last_name=in_admin_last_name and pa.first_name=in_admin_first_name and pa.patronymic=in_admin_patronymic and pa.mobile_num=in_admin_mobile_num and pa.email=in_admin_email);
        
		set temp_personal_data_id = (select id_personal_data from admin as a where a.id=temp_id);
		delete from admin as a where a.id=temp_id;
		select 'Произошло удаление администратора.' as 'Информация';
        
		if (personal_data_count <= 1) then
			delete from personal_data as pa where pa.id=temp_personal_data_id;
			select 'Персональные данные администратора удалены.' as 'Информация';
        else
			select 'Персональные данные администратора не удалены т.к. содержатся в других записях.' as 'Информация';
        end if;
	else
		select 'Найдены записи с администратором, он остается.' as 'Информация';
    end if;
    
	if (guest_count <= 1) then
		set temp_id = (select distinct count(*) from 
		((receipt as r join guest as g on g.id=r.id_guest)
	   join personal_data as pg on pg.id=g.id_personal_data and pg.last_name=in_guest_last_name and pg.first_name=in_guest_first_name and pg.patronymic=in_guest_patronymic and pg.mobile_num=in_guest_mobile_num and pg.email=in_guest_email)
		);
        
        set temp_personal_data_id = (select id_personal_data from guest as g where g.id=temp_id);
		delete from guest as g where g.id=temp_id;
		select 'Произошло удаление гостя.' as 'Информация';
			
		if (personal_data_count <= 1) then
			delete from personal_data as pg where pg.id=temp_personal_data_id;
			select 'Персональные данные гостя удалены.' as 'Информация';
        else
			select 'Персональные данные гостя не удалены т.к. содержатся в других записях.' as 'Информация';
        end if;
	else
		select 'Найдены записи с гостем, он остается.' as 'Информация';
    end if;
    
    if (room_count <= 1) then
		set temp_id = (select distinct count(*) from 
		(receipt as r join room as rm on rm.id=in_room_id));
		delete from guest as a where a.id=temp_id;
		select 'Произошло удаление комнаты.' as 'Информация';
	else
		select 'Найдены записи с комнатой, она остается.' as 'Информация';
    end if;
    commit;
end//
delimiter ;

delimiter //
create procedure receiptUpdate(
in in_admin_last_name varchar(255), 
in in_admin_first_name varchar(255),
in in_admin_patronymic varchar(255),
in in_admin_mobile_num char(11),
in in_admin_email varchar(255),
in in_guest_last_name varchar(255),
in in_guest_first_name varchar(255),
in in_guest_patronymic varchar(255),
in in_guest_mobile_num char(11),
in in_guest_email varchar(255),
in in_room_id int,
in in_room_capacity int,
in in_room_status int,
in in_check_in_date date,
in in_check_out_date date,
in in_daily_price decimal(7, 2),
in in_field_name varchar(255),
in in_value varchar(255)
)
begin
	declare found_admin_id int default null;
	declare found_guest_id int default null;
	declare found_admin_personal_data_id int default null;
	declare found_guest_personal_data_id int default null;
	declare found_room_id int default null;
	declare found_receipt_id int default null;
    declare found_temp_id int default null;
    declare default_admin_salary decimal(8, 2) default 50000;
	declare exit handler for sqlexception
    begin
        rollback;
        select 'Ошибка изменения';
    end;
    start transaction;
    
	-- поиск квитанции по всем данным
    set found_receipt_id = (select r.id from 
	(((((receipt as r join guest as g on g.id=r.id_guest) 
	join admin as a on a.id=r.id_admin)
	  join personal_data as pa on pa.id=a.id_personal_data and pa.last_name=in_admin_last_name and pa.first_name=in_admin_first_name and pa.patronymic=in_admin_patronymic and pa.mobile_num=in_admin_mobile_num and pa.email=in_admin_email)
	   join personal_data as pg on pg.id=g.id_personal_data and pg.last_name=in_guest_last_name and pg.first_name=in_guest_first_name and pg.patronymic=in_guest_patronymic and pg.mobile_num=in_guest_mobile_num and pg.email=in_guest_email)
		 join room as rm on rm.id=r.id_room and r.id_room=in_room_id)
		  join status as s on rm.id_status=s.id);
          
	set found_admin_personal_data_id = (select pa.id from personal_data as pa 
		join admin as a on a.id_personal_data=pa.id 
		join receipt as r on r.id_admin=a.id and r.id=found_receipt_id);
        
	set found_guest_personal_data_id = (select pg.id from personal_data as pg 
		join guest as g on g.id_personal_data=pg.id 
		join receipt as r on r.id_guest=g.id and r.id=found_receipt_id);
        
	set found_guest_personal_data_id = (select r.id_room from receipt as r where r.id=found_receipt_id);

	if in_field_name='Фамилия администратора' then
		set found_temp_id = (select pd.id from personal_data as pd where pd.last_name=in_value and pd.first_name=in_admin_first_name and pd.patronymic=in_admin_patronymic and pd.mobile_num=in_admin_mobile_num and pd.email=in_admin_email);
        
        # если мы нашли администратора с такими данными, перевешиваем на него всю квитанцию, не нашли -- создаем и перевешиваем
        if found_temp_id is null then
			insert personal_data(last_name, first_name, patronymic, mobile_num, email) values
			(in_value, in_admin_first_name, in_admin_patronymic, in_admin_mobile_num, in_admin_email);
            set found_temp_id = (select max(id) from personal_data);
            insert admin(id_personal_data, salary) values (found_temp_id, default_admin_salary);
            set found_temp_id = (select max(id) from admin);
		else
			set found_temp_id = (select a.id from admin as a where a.id_personal_data=found_temp_id);
        end if;
        update receipt as r set id_admin = found_temp_id where r.id=found_receipt_id;
	elseif in_field_name='Имя администратора' then
		set found_temp_id = (select pd.id from personal_data as pd where pd.last_name=in_admin_last_name and pd.first_name=in_value and pd.patronymic=in_admin_patronymic and pd.mobile_num=in_admin_mobile_num and pd.email=in_admin_email);
        if found_temp_id is null then
			insert personal_data(last_name, first_name, patronymic, mobile_num, email) values
			(in_admin_last_name, in_value, in_admin_patronymic, in_admin_mobile_num, in_admin_email);
            set found_temp_id = (select max(id) from personal_data);
            insert admin(id_personal_data, salary) values (found_temp_id, default_admin_salary);
            set found_temp_id = (select max(id) from admin);
		else
			set found_temp_id = (select a.id from admin as a where a.id_personal_data=found_temp_id);
        end if;
        update receipt as r set id_admin = found_temp_id where r.id=found_receipt_id;
	elseif in_field_name='Отчество администратора' then
		set found_temp_id = (select pd.id from personal_data as pd where pd.last_name=in_admin_last_name and pd.first_name=in_admin_first_name and pd.patronymic=in_value and pd.mobile_num=in_admin_mobile_num and pd.email=in_admin_email);
        if found_temp_id is null then
			insert personal_data(last_name, first_name, patronymic, mobile_num, email) values
			(in_admin_last_name, in_admin_first_name, in_value, in_admin_mobile_num, in_admin_email);
            set found_temp_id = (select max(id) from personal_data);
			insert admin(id_personal_data, salary) values (found_temp_id, default_admin_salary);
            set found_temp_id = (select max(id) from admin);
		else
			set found_temp_id = (select a.id from admin as a where a.id_personal_data=found_temp_id);
        end if;
        update receipt as r set id_admin = found_temp_id where r.id=found_receipt_id;
	elseif in_field_name='Мобильный номер администратора' then
		set found_temp_id = (select pd.id from personal_data as pd where pd.last_name=in_admin_last_name and pd.first_name=in_admin_first_name and pd.patronymic=in_admin_patronymic and pd.mobile_num=in_value and pd.email=in_admin_email);
        if found_temp_id is null then
			insert personal_data(last_name, first_name, patronymic, mobile_num, email) values
			(in_admin_last_name, in_admin_first_name, in_admin_patronymic, in_value, in_admin_email);
            set found_temp_id = (select max(id) from personal_data);
			insert admin(id_personal_data, salary) values (found_temp_id, default_admin_salary);
            set found_temp_id = (select max(id) from admin);
		else
			set found_temp_id = (select a.id from admin as a where a.id_personal_data=found_temp_id);
        end if;
        update receipt as r set id_admin = found_temp_id where r.id=found_receipt_id;
	elseif in_field_name='Эл. почта администратора' then
		set found_temp_id = (select pd.id from personal_data as pd where pd.last_name=in_admin_last_name and pd.first_name=in_admin_first_name and pd.patronymic=in_admin_patronymic and pd.mobile_num=in_admin_mobile_num and pd.email=in_value);
        if found_temp_id is null then
			insert personal_data(last_name, first_name, patronymic, mobile_num, email) values
			(in_admin_last_name, in_admin_first_name, in_admin_patronymic, in_admin_mobile_num, in_value);
            set found_temp_id = (select max(id) from personal_data);
			insert admin(id_personal_data, salary) values (found_temp_id, default_admin_salary);
            set found_temp_id = (select max(id) from admin);
		else
			set found_temp_id = (select a.id from admin as a where a.id_personal_data=found_temp_id);
        end if;
        update receipt as r set id_admin = found_temp_id where r.id=found_receipt_id;
	elseif in_field_name='Фамилия гостя' then
		set found_temp_id = (select pd.id from personal_data as pd where pd.last_name=in_value and pd.first_name=in_guest_first_name and pd.patronymic=in_guest_patronymic and pd.mobile_num=in_guest_mobile_num and pd.email=in_guest_email);
        if found_temp_id is null then
			insert personal_data(last_name, first_name, patronymic, mobile_num, email) values
			(in_value, in_guest_first_name, in_guest_patronymic, in_guest_mobile_num, in_guest_email);
            set found_temp_id = (select max(id) from personal_data);
			insert guest(id_personal_data) values (found_temp_id);
            set found_temp_id = (select max(id) from guest);
		else
			set found_temp_id = (select g.id from guest as g where g.id_personal_data=found_temp_id);
        end if;
        update receipt as r set id_guest = found_temp_id where r.id=found_receipt_id;
	elseif in_field_name='Имя гостя' then
		set found_temp_id = (select pd.id from personal_data as pd where pd.last_name=in_guest_last_name and pd.first_name=in_value and pd.patronymic=in_guest_patronymic and pd.mobile_num=in_guest_mobile_num and pd.email=in_guest_email);
        if found_temp_id is null then
			insert personal_data(last_name, first_name, patronymic, mobile_num, email) values
			(in_guest_last_name, in_value, in_guest_patronymic, in_guest_mobile_num, in_guest_email);
            set found_temp_id = (select max(id) from personal_data);
			insert guest(id_personal_data) values (found_temp_id);
            set found_temp_id = (select max(id) from guest);
		else
			set found_temp_id = (select g.id from guest as g where g.id_personal_data=found_temp_id);
        end if;
        update receipt as r set id_guest = found_temp_id where r.id=found_receipt_id;
	elseif in_field='Отчество гостя' then
		set found_temp_id = (select pd.id from personal_data as pd where pd.last_name=in_guest_last_name and pd.first_name=in_guest_first_name and pd.patronymic=in_value and pd.mobile_num=in_guest_mobile_num and pd.email=in_guest_email);
        if found_temp_id is null then
			insert personal_data(last_name, first_name, patronymic, mobile_num, email) values
			(in_guest_last_name, in_guest_first_name, in_value, in_guest_mobile_num, in_guest_email);
            set found_temp_id = (select max(id) from personal_data);
			insert guest(id_personal_data) values (found_temp_id);
            set found_temp_id = (select max(id) from guest);
		else
			set found_temp_id = (select g.id from guest as g where g.id_personal_data=found_temp_id);
        end if;
        update receipt as r set id_guest = found_temp_id where r.id=found_receipt_id;
	elseif in_field='Мобильный номер гостя' then
		set found_temp_id = (select pd.id from personal_data as pd where pd.last_name=in_guest_last_name and pd.first_name=in_guest_first_name and pd.patronymic=in_guest_patronymic and pd.mobile_num=in_value and pd.email=in_guest_email);
        if found_temp_id is null then
			insert personal_data(last_name, first_name, patronymic, mobile_num, email) values
			(in_guest_last_name, in_guest_first_name, in_guest_patronymic, in_value, in_guest_email);
            set found_temp_id = (select max(id) from personal_data);
			insert guest(id_personal_data) values (found_temp_id);
            set found_temp_id = (select max(id) from guest);
		else
			set found_temp_id = (select g.id from guest as g where g.id_personal_data=found_temp_id);
        end if;
        update receipt as r set id_guest = found_temp_id where r.id=found_receipt_id;
	elseif in_field='Эл. почта гостя' then
		set found_temp_id = (select pd.id from personal_data as pd where pd.last_name=in_guest_last_name and pd.first_name=in_guest_first_name and pd.patronymic=in_guest_patronymic and pd.mobile_num=in_guest_mobile_num and pd.email=in_value);
        if found_temp_id is null then
			insert personal_data(last_name, first_name, patronymic, mobile_num, email) values
			(in_guest_last_name, in_guest_first_name, in_guest_patronymic, in_guest_mobile_num, in_value);
            set found_temp_id = (select max(id) from personal_data);
			insert guest(id_personal_data) values (found_temp_id);
            set found_temp_id = (select max(id) from guest);
		else
			set found_temp_id = (select g.id from guest as g where g.id_personal_data=found_temp_id);
        end if;
        update receipt as r set id_guest = found_temp_id where r.id=found_receipt_id;
	elseif in_field='Комната, №' then
		update receipt set id_room = cast(in_value as signed) where id=found_receipt_id;
	elseif in_field='Вместимость' then
		update room set capacity = cast(in_value as signed) where id=found_room_id;
	elseif in_field='Статус' then
		update room set id_status = cast(in_value as signed) where id=found_room_id;
	elseif in_field='Дата заезда' then
		update receipt set check_in_date = cast(in_value as date) where id=found_receipt_id;
	elseif in_field='Дата отъезда' then
		update receipt set check_out_date = cast(in_value as date) where id=found_receipt_id;
	elseif in_field='Цена за сутки' then
		update room set daily_price = cast(in_value as signed) where id=found_room_id;
    else
		select 'Поля не существует.' as 'Информация';
	end if;
	/* Замечания
    * Необязательно вводить поля для комнаты чтобы идентифицировать запись, ведь есть номер комнаты
    */
    commit;
end//
delimiter ;


-- фамилия администратора, имя администратора, отчество администратора, моб. номер администратора, эл. почта администратора, фамилия гостя, имя гостя, отчество гостя, мобильный номер гостя, эл. почта гостя, номер комнаты, вместимость комнаты, статус комнаты (1,2,3), дата заезда, дата отъезда, цена за сутки
-- receiptCreate
-- фамилия администратора, имя администратора, отчество администратора, моб. номер администратора, эл. почта администратора, фамилия гостя, имя гостя, отчество гостя, мобильный номер гостя, эл. почта гостя, номер комнаты, вместимость комнаты, статус комнаты (1,2,3), дата заезда, дата отъезда, цена за сутки, поле, значение
-- receiptUpdate
-- фамилия администратора, имя администратора, отчество администратора, моб. номер администратора, эл. почта администратора, фамилия гостя, имя гостя, отчество гостя, мобильный номер гостя, эл. почта гостя, номер комнаты, дата заезда, дата отъезда, цена за сутки, поле, значение
-- receiptDelete

-- TEST 1, админ найден, комната найдена
-- call receiptRead();
-- call receiptCreate('Green', 'Alex', 'William', '89999999999', 'alex.green@yahoo.com', 'Ivanov', 'Ivan', 'Ivanovich', '89990001234', 'ivanovich@rambler.ru', 6, 5, 1, '2020-10-21', '2020-10-22', 5000);
-- call receiptRead();
-- call receiptUpdate('Green', 'Alex', 'William', '89999999999', 'alex.green@yahoo.com', 'Ivanov', 'Ivan', 'Ivanovich', '89990001234', 'ivanovich@rambler.ru', 6, 5, 1, '2020-10-21', '2020-10-22', 5000, 'Фамилия администратора', 'Bersenev');
-- call receiptRead();
-- call receiptDelete('Bersenev', 'Alex', 'William', '89999999999', 'alex.green@yahoo.com', 'Ivanov', 'Ivan', 'Ivanovich', '89990001234', 'ivanovich@rambler.ru', 6, '2020-10-21', '2020-10-22', 5000);

-- TEST 2, комната найдена
call receiptRead();
call receiptCreate('Lukovkin', 'Arkady', 'Sergeevich', '89610819690', 'lukovkin.a@gmail.com', 'Ivanov', 'Ivan', 'Ivanovich', '89990001234', 'ivanovich@rambler.ru', 8, 5, 1, '2020-10-21', '2020-10-23', 4000);
call receiptRead();
call receiptUpdate('Lukovkin', 'Arkady', 'Sergeevich', '89610819690', 'lukovkin.a@gmail.com', 'Ivanov', 'Ivan', 'Ivanovich', '89990001234', 'ivanovich@rambler.ru', 8, 5, 1, '2020-10-21', '2020-10-23', 4000, 'Имя гостя', 'Nikita');
call receiptRead();
call receiptDelete('Lukovkin', 'Arkady', 'Sergeevich', '89610819690', 'lukovkin.a@gmail.com', 'Ivanov', 'Nikita', 'Ivanovich', '89990001234', 'ivanovich@rambler.ru', 8, '2020-10-21', '2020-10-23', 4000);
call receiptRead();

 -- call receiptCreate('Lukovkin', 'Arkady', 'Sergeevich', '89610819690', 'lukovkin.a@gmail.com', 'Ivanov', 'Ivan', 'Ivanovich', '89990001234', 'ivanovich@rambler.ru', 8, 5, 1, '2020-10-21', '2020-10-22', 4000);