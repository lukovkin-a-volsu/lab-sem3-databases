-- # 1. Какие гости какие комнаты снимали 

-- ## last_name, first_name, patronymic, id_room, value

select distinct personal_data.last_name, personal_data.first_name, personal_data.patronymic, room.id as id_room, status.value from personal_data, receipt, room, status, guest where (select count(*) from receipt where guest.id=receipt.id_guest and room.id=receipt.id_room) > 0 and (guest.id_personal_data=personal_data.id) and (room.id_status=status.id) order by id_room;

select distinct pd.last_name, pd.first_name, pd.patronymic, rm.id as id_room, s.value
from 
  ((((personal_data as pd 
    join guest as g on g.id_personal_data=pd.id) 
      join receipt as r on r.id_guest=g.id) 
        join room as rm on r.id_room=rm.id) 
          join status as s on rm.id_status=s.id)
  order by id_room;


-- # 2. Статусы комнаты для каждого гостя, снимающего комнату

-- ## id_guest, id_room, value

select receipt.id_guest, receipt.id_room, status.value from receipt, status where status.id=(select room.id_status from room where room.id=receipt.id_room) order by id_guest;

select distinct g.id as id_guest, rm.id as id_room, s.value
from 
  (((guest as g 
    join receipt as r on r.id_guest=g.id) 
        join room as rm on r.id_room=rm.id) 
          join status as s on rm.id_status=s.id)
  order by g.id;


-- # 3. Персональные данные и их тип (гость или администратор), сначала всех гостей, потом всех администраторов

-- ## статус, id, last_name, first_name, patronymic, mobile_num, email

select "гость" as статус, personal_data.* from personal_data, guest where guest.id_personal_data=personal_data.id union select "админ", personal_data.* from personal_data, admin where admin.id_personal_data=personal_data.id order by id;


select * from 
(select 'гость' as статус, pd.* from personal_data as pd join guest as g on g.id_personal_data=pd.id
union
select 'админ', pd.* from personal_data as pd join admin as a on a.id_personal_data=pd.id) A
order by id;


-- # 4. Всевозможные квитанции, где поля на русском языке

select distinct receipt.id as "№", pa.last_name as "Фамилия администратора", pa.first_name as "Имя администратора", pa.patronymic as "Отчество администратора", pg.last_name as "Фамилия гостя", pg.first_name as "Имя гостя", pg.patronymic as "Отчество гостя", receipt.id_room as "Комната, №", status.value as "Статус", receipt.check_in_date as "Дата заезда", receipt.check_out_date as "Дата отъезда", receipt.daily_price as "Цена за сутки", receipt.total_price as "Общая сумма" from receipt, guest, admin, room, personal_data as pg, personal_data as pa, status where (receipt.id_admin=admin.id) and (receipt.id_guest=guest.id) and (receipt.id_room=room.id) and (guest.id_personal_data=pg.id) and (admin.id_personal_data=pa.id) and (room.id_status=status.id) order by receipt.id;


select distinct r.id as "№", pa.last_name as "Фамилия администратора", pa.first_name as "Имя администратора", pa.patronymic as "Отчество администратора", pg.last_name as "Фамилия гостя", pg.first_name as "Имя гостя", pg.patronymic as "Отчество гостя", r.id_room as "Комната, №", s.value as "Статус", r.check_in_date as "Дата заезда", r.check_out_date as "Дата отъезда", r.daily_price as "Цена за сутки", r.total_price as "Общая сумма" from 
(((((receipt as r join guest as g on g.id=r.id_guest) 
  join personal_data as pa on pa.id=r.id_admin)
   join personal_data as pg on pg.id=r.id_guest)
     join room as rm on rm.id=r.id_room)
      join status as s on rm.id_status=s.id);
