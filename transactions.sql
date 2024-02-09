-- Уровни изоляции
-- serializable
-- repeatable read
-- read committed
-- read uncommitted

delimiter //
create procedure if not exists resetTestData() 
begin
call receiptUpdate('Green', 'Alex', 'William', '89999999999', 'alex.green@yahoo.com',
					'BOGOMOLOV', 'David', 'William', '89999999994', 'david.jones@gmail.com',
                    5, 5, 2, '2023-10-20', '2023-10-21', 7000.00,
                    'Фамилия гостя', 'Jones');
end//
delimiter ;

-- Повторяющееся чтение
-- read committed
-- read uncomitted
-- -------------------------------------
-- Транзакция 1
-- 1
set transaction isolation level serializable;
start transaction;
call receiptRead();
call receiptUpdate('Green', 'Alex', 'William', '89999999999', 'alex.green@yahoo.com',
					'Jones', 'David', 'William', '89999999994', 'david.jones@gmail.com',
                    5, 5, 2, '2023-10-20', '2023-10-21', 7000.00,
                    'Фамилия гостя', 'BOGOMOLOV');
call receiptCreate('Green', 'Alex', 'William', '89999999999', 'alex.green@yahoo.com',
					'Jones', 'David', 'William', '89999999994', 'david.jones@gmail.com',
                    5, 5, 2, '2023-10-20', '2023-10-21', 7000.00);
-- 3
rollback;
-- Транзакция 2
-- 2
set transaction isolation level serializable;
start transaction;
call receiptRead();
commit;
-- -------------------------------------

-- Потерянное обновление
-- -------------------------------------
-- Транзакция 1
-- 1
set transaction isolation level serializable;
start transaction;
call receiptRead();
-- 3
call receiptUpdate('Green', 'Alex', 'William', '89999999999', 'alex.green@yahoo.com',
					'Jones', 'David', 'William', '89999999994', 'david.jones@gmail.com',
                    5, 5, 2, '2023-10-20', '2023-10-21', 7000.00,
                    'Фамилия гостя', 'BOGOMOLOV');
commit;
-- Транзакция 2
-- 2
set transaction isolation level serializable;
start transaction;
call receiptRead();
-- 4
call receiptRead();
call receiptUpdate('Green', 'Alex', 'William', '89999999999', 'alex.green@yahoo.com',
					'Jones', 'David', 'William', '89999999994', 'david.jones@gmail.com',
                    5, 5, 2, '2023-10-20', '2023-10-21', 7000.00,
                    'Фамилия гостя', 'BOGOMOLOV');
commit;
-- -------------------------------------

-- Фантомная вставка
-- -------------------------------------
-- Транзакция 1
-- 1
set transaction isolation level repeatable read;
start transaction;
call receiptRead();
-- 3
call receiptCreate('SAVINOV', 'Alex', 'William', '89999999999', 'alex.green@yahoo.com', 'Ivanov', 'Ivan', 'Ivanovich', '89990001234', 'ivanovich@rambler.ru', 6, 5, 1, '2020-10-21', '2020-10-22', 5000);
commit;
-- Транзакция 2
-- 2
set transaction isolation level repeatable read;
start transaction;
call receiptRead();
-- 4
call receiptRead();
commit;
-- -------------------------------------

-- Точки остановки
-- -------------------------------------
-- Транзакция
start transaction;
call receiptRead();
call receiptCreate('GURIN', 'Alex', 'William', '89999999999', 'alex.green@yahoo.com', 'Ivanov', 'Ivan', 'Ivanovich', '89990001234', 'ivanovich@rambler.ru', 6, 5, 1, '2020-10-21', '2020-10-22', 5000);
savepoint before_change;
call receiptCreate('SAVINOV', 'Alex', 'William', '89999999999', 'alex.green@yahoo.com', 'Ivanov', 'Ivan', 'Ivanovich', '89990001234', 'ivanovich@rambler.ru', 6, 5, 1, '2020-10-21', '2020-10-22', 5000);
call receiptRead();
rollback to before_change;
commit;
-- -------------------------------------

-- SAVEPOINT
-- -------------------------------------
-- savepoint before_change;
-- rollback to before_change;

drop procedure if exists testTransaction;
delimiter //
create procedure testTransaction()
begin
    declare exit handler for sqlexception
    begin
        rollback;
        select 'The error has caught';
    end;
    
    start transaction;
        insert room(id_status, capacity, daily_price) values(1, 5, 'a');
    commit;
end//
delimiter ;
 