-- https://dev.mysql.com/doc/refman/8.0/en/create-user.html
-- https://dev.mysql.com/doc/refman/8.0/en/grant.html
-- https://dev.mysql.com/doc/refman/8.0/en/roles.html

-- Вывести права пользователя
-- show grants for 'root'@'localhost';

-- Вывод пользователя от которого происходит работа
-- select user();

-- Забрать права пользователя
-- revoke role 'crud-user' from 'default'@'localhost';
-- revoke execute on hotel.* to 'default'@'localhost';

-- Выдать права пользователю
-- grant execute on procedure ... to ...;

-- Удалить пользователя
-- drop user 'wo'@'localhost';

-- Обновить права 
-- flush privileges;

-- Выдать права на функции, без роли
-- grant execute on procedure hotel.receiptCreate to 'worker'@'localhost';
-- grant execute on procedure hotel.receiptRead to 'worker'@'localhost';
-- grant execute on procedure hotel.receiptUpdate to 'worker'@'localhost';
-- grant execute on procedure hotel.receiptDelete to 'worker'@'localhost';

-- Создать роль
-- create role roleName;

-- Дать права роли
-- grant ... to roleName;

-- Выдать роль 
-- grant roleName to 'userName'@'localhost';

-- Сделать роль активной по умолчанию
-- set default role crudUser to 'userName'@'localhost';

-- Посмотреть текущую роль
-- select current_role();

-- Установить текущую роль (Within a session, a user can execute SET ROLE to change the set of active roles)
-- set role roleName;
-- set role none;

-- Удалить роль
-- drop role roleName;

create role crudUser;
grant execute on procedure hotel.receiptCreate to crudUser;
grant execute on procedure hotel.receiptRead to crudUser;
grant execute on procedure hotel.receiptUpdate to crudUser;
grant execute on procedure hotel.receiptDelete to crudUser;
-- grant select on hotel.* to crudUser;
-- drop role crudUser;

-- Вывод существующих пользователей
select user, host from mysql.user;

create user if not exists 'worker'@'localhost' identified by 'password';
grant crudUser to 'worker'@'localhost';
set default role crudUser to 'worker'@'localhost';
flush privileges;

-- select user, host from mysql.user;
-- grant all on *.* to 'master'@'localhost' with grant option;
-- flush privileges;
-- select user, host from mysql.user;
-- ------------------------------------------------------------
-- mysql -u master -p