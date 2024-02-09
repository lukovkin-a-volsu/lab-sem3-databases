drop database if exists hotel;
create database hotel;

use hotel;

create table personal_data (
  id int primary key auto_increment,
  last_name varchar(255) not null,
  first_name varchar(255) not null,
  patronymic varchar(255),
  mobile_num char(11) not null,
  email varchar(255) not null
);

create table admin (
  id int primary key auto_increment,
  id_personal_data int not null,
  salary decimal(8, 2) not null,
  foreign key (id_personal_data) references personal_data(id)
);

create table status (
  id int primary key auto_increment,
  value varchar(255) not null
);

create table room (
  id int primary key auto_increment,
  id_status int not null,
  capacity smallint not null,
  daily_price decimal(7, 2) not null, 
  foreign key (id_status) references status(id)
);

create table guest (
  id int primary key auto_increment,
  id_personal_data int not null,
  foreign key (id_personal_data) references personal_data(id)
);

create table receipt (
  id int primary key auto_increment,
  id_admin int not null,
  id_guest int not null,
  id_room int not null,
  check_in_date date not null,
  check_out_date date not null,
  daily_price decimal(7, 2) not null,
  total_price decimal(10, 2) not null,
  foreign key (id_admin) references admin(id),
  foreign key (id_guest) references guest(id),
  foreign key (id_room) references room(id)
);

insert status(value) values ('Available'), ('Partially occupied'), ('Occupied');

insert personal_data(last_name, first_name, patronymic, mobile_num, email) values
('Green', 'Alex', 'William', '89999999999', 'alex.green@yahoo.com'), -- admin
('Smith', 'John', 'David', '89999999998', 'john.smith@gmail.com'), -- 2
('Johnson', 'Mary', 'Elizabeth', '89999999997', 'mary.johnson@gmail.com'),
('Williams', 'Peter', 'Michael', '89999999996', 'peter.williams@gmail.com'),
('Brown', 'Susan', 'Jane', '89999999995', 'susan.brown@gmail.com'),
('Jones', 'David', 'William', '89999999994', 'david.jones@gmail.com'),
('Williamson', 'Mary', 'Anne', '89999999993', 'mary.williamson@gmail.com'),
('Taylor', 'John', 'Michael', '89999999992', 'john.taylor@gmail.com'),
('Anderson', 'Susan', 'Jane', '89999999991', 'susan.anderson@gmail.com'),
('Thomas', 'David', 'William', '89999999990', 'david.thomas@gmail.com'),
('Jackson', 'Mary', 'Anne', '89999999989', 'mary.jackson@gmail.com'),
('Petrov', 'Ivan', 'Ivanovich', '89999999988', 'ivan.petrov@yandex.ru'), -- ru
('Sidorov', 'Petr', 'Petrovich', '89999999987', 'petr.sidorov@yandex.ru'),
('Ivanov', 'Ivan', 'Vladimirovich', '89999999985', 'ivan.ivanov@yandex.ru'),
('Kuznetsov', 'Petr', 'Ivanovich', '89999999984', 'petr.kuznetsov@yandex.ru'),
('Smirnov', 'Ivan', 'Vladimirovich', '89999999983', 'ivan.smirnov@yandex.ru'),
('Popov', 'Petr', 'Ivanovich', '89999999982', 'petr.popov@yandex.ru'),
('Vladimirov', 'Ivan', 'Vladimirovich', '89999999981', 'ivan.vladimirov@yandex.ru'),
('Fedorov', 'Petr', 'Ivanovich', '89999999980', 'petr.fedorovich@yandex.ru'),
('Alexandrov', 'Ivan', 'Vladimirovich', '89999999979', 'ivan.alexandrov@yandex.ru'),
('Morozov', 'Nikita', 'Sergeevich', '89999999978', 'morozov.nikita@yandex.ru'), -- 21
('Sergeev', 'Ivan', 'Ivanovich', '89999999976', 'ivan.sergeev@yandex.ru'), -- admin optional
('Ivanova', 'Anna', 'Vladimirovna', '89999999975', 'anna.ivanova@yandex.ru'),
('Kuznetsov', 'Petr', 'Petrovich', '89999999974', 'petr.kuznetsov@yandex.ru'),
('Smirnov', 'Ivan', 'Vladimirovich', '89999999973', 'ivan.smirnov@yandex.ru'),
('Popov', 'Petr', 'Ivanovich', '89999999972', 'petr.popov@yandex.ru'),
('Vladimirov', 'Ivan', 'Vladimirovich', '89999999971', 'ivan.vladimirov@yandex.ru'),
('Fedorov', 'Petr', 'Ivanovich', '89999999970', 'petr.fedorovich@yandex.ru'),
('Alexandrov', 'Ivan', 'Vladimirovich', '89999999969', 'ivan.alexandrov@yandex.ru'),
('Morozova', 'Anna', 'Sergeevna', '89999999968', 'anna.morozova@yandex.ru'); -- 30 admin end

insert guest(id_personal_data) values 
(2),
(3),
(4),
(5),
(6),
(7),
(8),
(9),
(10),
(11),
(12),
(13),
(14),
(15),
(16),
(17),
(18),
(19),
(20);

insert admin(id_personal_data, salary) values 
(1, 500000),
(22, 50000),
(23, 45000),
(24, 45000),
(25, 45000),
(26, 40000),
(27, 40000),
(28, 40000),
(29, 30000),
(30, 30000);

insert room(id_status, capacity, daily_price) values
(1, 1, 3000), -- 1
(3, 2, 4000), -- occupied 2/2
(3, 3, 5000), -- occupied 3/3
(3, 4, 6000), -- occupied 4/4
(2, 5, 7000), -- partially occupied 3/5
(2, 6, 8000), -- partially occupied 3/6
(1, 1, 4000),
(1, 2, 8000),
(1, 3, 12000),
(1, 4, 16000),
(1, 5, 20000),
(1, 6, 24000),
(1, 1, 5000),
(1, 2, 10000),
(1, 3, 15000),
(1, 4, 20000),
(1, 5, 25000),
(1, 6, 30000),
(1, 1, 6000),
(1, 2, 12000),
(1, 3, 18000),
(1, 4, 24000),
(2, 5, 30000), -- partially occupied 4/5
(1, 6, 30000); -- 24

insert receipt(id_admin, id_guest, id_room, check_in_date, check_out_date, daily_price, total_price) values
(1, 2, 2, '2023-10-20', '2023-10-21', 4000, 4000), -- room 2
(1, 8, 2, '2023-10-20', '2023-10-22', 4000, 8000),
(1, 3, 3, '2023-10-20', '2023-10-21', 5000, 5000), -- room 3
(1, 9, 3, '2023-10-20', '2023-10-22', 5000, 10000),
(1, 15, 3, '2023-10-20', '2023-10-23', 5000, 15000),
(1, 4, 4, '2023-10-20', '2023-10-21', 6000, 6000), -- room 4
(1, 14, 4, '2023-10-20', '2023-10-23', 6000, 18000),
(1, 10, 4, '2023-10-20', '2023-10-22', 6000, 12000),
(1, 16, 4, '2023-10-20', '2023-10-23', 6000, 18000),
(1, 5, 5, '2023-10-20', '2023-10-21', 7000, 7000), -- room 5
(1, 11, 5, '2023-10-20', '2023-10-22', 7000, 14000),
(1, 17, 5, '2023-10-20', '2023-10-23', 7000, 21000),
(1, 6, 6, '2023-10-20', '2023-10-21', 8000, 8000), -- room 6
(1, 12, 6, '2023-10-20', '2023-10-22', 8000, 16000),
(1, 18, 6, '2023-10-20', '2023-10-23', 8000, 24000),
(1, 1, 23, '2023-10-20', '2023-10-21', 30000, 30000), -- room 23
(1, 19, 23, '2023-10-20', '2023-10-24', 30000, 120000),
(1, 13, 23, '2023-10-20', '2023-10-23', 30000, 90000),
(1, 7, 23, '2023-10-20', '2023-10-22', 30000, 60000);