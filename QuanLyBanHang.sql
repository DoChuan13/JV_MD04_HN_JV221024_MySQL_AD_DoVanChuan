create database if not exists QUANLYBANHANG;

use QUANLYBANHANG;

create table if not exists QUANLYBANHANG.CUSTOMERS
(
    customer_id varchar(4) primary key not null,
    name        varchar(100)           not null,
    email       varchar(100) unique    not null,
    phone       varchar(25) unique     not null,
    address     varchar(255)           not null
);

create table if not exists QUANLYBANHANG.ORDERS
(
    order_id     varchar(4) primary key not null,
    customer_id  varchar(4)             not null,
    order_date   date                   not null,
    total_amount double                 not null,
    constraint fr_customer_id foreign key (customer_id) references CUSTOMERS (customer_id)
);

create table if not exists QUANLYBANHANG.PRODUCTS
(
    product_id  varchar(4) primary key not null,
    name        varchar(255)           not null,
    description text,
    price       double                 not null,
    status      bit(1)                 not null
);

alter table PRODUCTS
    alter column status set default 1;

create table if not exists QUANLYBANHANG.ORDER_DETAILS
(
    order_id   varchar(4) not null,
    product_id varchar(4) not null,
    quantity   int(11)    not null,
    price      double     not null,
    primary key (order_id, product_id),
    constraint fk_OD_order_id foreign key (order_id) references ORDERS (order_id),
    constraint fk_OD_product_id foreign key (product_id) references PRODUCTS (product_id)
);

# 2. Add Value
insert into CUSTOMERS (customer_id, name, email, phone, address)
values ('C001', 'Nguyễn Trung Mạnh', 'manhnt@gmail.com', '984756322', 'Cầu Giấy, Hà Nội'),
       ('C002', 'Hồ Hải Nam', 'namhh@gmail.com', '984875926', 'Ba Vì, Hà Nội'),
       ('C003', 'Tô Ngọc Vũ', 'vutn@gmail.com', '904725784', 'Mộc Châu, Sơn La'),
       ('C004', 'Phạm Ngọc Anh', 'anhpn@gmail.com', '984635365', 'Vinh, Nghệ An'),
       ('C005', 'Trương Minh Cường', 'cuongtm@gmail.com', '989735624', 'Hai Bà Trưng, Hà Nội');

insert into PRODUCTS (product_id, name, description, price)
values ('P001', 'Iphone 13 Pro Max', 'Bản 512G xanh lá', 22999999),
       ('P002', 'Dell Vostro V3510', 'Core i5, RAM 8GB', 14999999),
       ('P003', 'Macbook Pro M2', '8CPU 10GPU 8GB 256GB', 28999999),
       ('P004', 'Apple Watch Ultra', 'Titanium Alpine Loop Small', 18999999),
       ('P005', 'Airpods 2 2022', 'Spatial Audio', 409000);

insert into ORDERS (order_id, customer_id, total_amount, order_date)
values ('H001', 'C001', 52999997, '2023/2/22'),
       ('H002', 'C001', 80999997, '2023/3/11'),
       ('H003', 'C002', 54359998, '2023/1/22'),
       ('H004', 'C003', 102999995, '2023/3/14'),
       ('H005', 'C003', 80999997, '2022/3/12'),
       ('H006', 'C004', 110449994, '2023/2/1'),
       ('H007', 'C004', 79999996, '2023/3/29'),
       ('H008', 'C005', 29999998, '2023/2/14'),
       ('H009', 'C005', 28999999, '2023/1/10'),
       ('H010', 'C005', 149999994, '2023/4/1');

insert into ORDER_DETAILS (order_id, product_id, price, quantity)
values ('H001', 'P002', 14999999, 1),
       ('H001', 'P004', 18999999, 2),
       ('H002', 'P001', 22999999, 1),
       ('H002', 'P003', 28999999, 2),
       ('H003', 'P004', 18999999, 2),
       ('H003', 'P005', 4090000, 4),
       ('H004', 'P002', 14999999, 3),
       ('H004', 'P003', 28999999, 2),
       ('H005', 'P001', 22999999, 1),
       ('H005', 'P003', 28999999, 2),
       ('H006', 'P005', 4090000, 5),
       ('H006', 'P002', 14999999, 6),
       ('H007', 'P004', 18999999, 3),
       ('H007', 'P001', 22999999, 1),
       ('H008', 'P002', 14999999, 2),
       ('H009', 'P003', 28999999, 1),
       ('H010', 'P003', 28999999, 2),
       ('H010', 'P001', 22999999, 4);

# 3. Data Query
# 3.1 Show Customer Info
select name, email, phone, address
from CUSTOMERS;

# 3.2 Customer bought 3/2023
select C.name, C.phone, C.address
from CUSTOMERS C
         join QUANLYBANHANG.ORDERS O on C.customer_id = O.customer_id
where year(O.order_date) = 2023
  and month(O.order_date) = 3;

# 3.3 Income 2023 by month
select month(O.order_date) as Month, format(sum(O.total_amount), 1) as Revenue
from ORDERS O
where year(O.order_date) = 2023
group by Month;

# 3.4 Customer not buy in 2/2023
select C.name, C.address, C.email, C.phone
from CUSTOMERS C
         left join QUANLYBANHANG.ORDERS O on C.customer_id = O.customer_id
where O.order_date is null
   or (year(O.order_date) = 2023 and month(O.order_date) != 2)
group by C.customer_id;

# 3.5 Amount product bought in 3/2023
select P.product_id, P.name, sum(OD.quantity) as quantity
from PRODUCTS P
         join QUANLYBANHANG.ORDER_DETAILS OD on P.product_id = OD.product_id
         join QUANLYBANHANG.ORDERS O on O.order_id = OD.order_id
where year(O.order_date) = 2023
  and month(O.order_date) = 3
group by P.product_id;

# 3.6 Show Spent Money
select C.customer_id, C.name, sum(O.total_amount) as `Spent Money`
from CUSTOMERS C
         join QUANLYBANHANG.ORDERS O on C.customer_id = O.customer_id
where year(O.order_date) = 2023
group by C.customer_id;

# 3.7 Order have Product > 5
select C.name, sum(O.total_amount) as Total, O.order_date, sum(OD.quantity) as `QuantityProduct`
from CUSTOMERS C
         join QUANLYBANHANG.ORDERS O on C.customer_id = O.customer_id
         join QUANLYBANHANG.ORDER_DETAILS OD on O.order_id = OD.order_id
group by O.order_id
having QuantityProduct >= 5;

# 4
# 4.1 View Invoice
create view INVOICE_VIEW as
select C.name, C.phone, C.address, format(O.total_amount, 1) as Total, O.order_date
from CUSTOMERS C
         join QUANLYBANHANG.ORDERS O on C.customer_id = O.customer_id;

select *
from INVOICE_VIEW;

# 4.2 View Customer
create view CUSTOMER_VIEW as
select C.name, C.address, C.phone, count(*) as OrderNumber
from CUSTOMERS C
         join QUANLYBANHANG.ORDERS O on C.customer_id = O.customer_id
group by C.customer_id;

select *
from CUSTOMER_VIEW;

# 4.3 View Product
create view PRODUCT_VIEW as
select P.name, P.description, format(P.price, 1) as Price, sum(OD.quantity) as BoughtQuantity
from PRODUCTS P
         join QUANLYBANHANG.ORDER_DETAILS OD on P.product_id = OD.product_id
group by P.product_id;

select *
from PRODUCT_VIEW;

# 4.4 Create index for phone and email
create index idx_Cus_PE on CUSTOMERS (phone, email);

# 4.5 Create Procedure Get Customer Info
delimiter
//
-- Create the Procedure called 'GetCustomerInfo()'"
create procedure GetCustomerInfo(
    in id varchar(4)
)
begin
    -- Content for Procedure 'GetCustomerInfo()' in here
    select * from CUSTOMERS where customer_id = id;
end;
//
delimiter ;
call GetCustomerInfo('C002');

# 4.6 Create Procedure Get All Products
delimiter
//
-- Create the Procedure called 'GetAllProduct()'"
create procedure GetAllProduct()
begin
    -- Content for Procedure 'GetAllProduct()' in here
    select * from PRODUCTS;
end;
//
delimiter ;
call GetAllProduct();

# 4.7 Create Procedure Get Invoice by customer_id
delimiter
//
-- Create the Procedure called 'GetInvoiceByCustomerID()'"
create procedure GetInvoiceByCustomerID(
    in id varchar(4)
)
begin
    -- Content for Procedure 'GetInvoiceByCustomerID()' in here
    select C.name, C.phone, C.address, O.order_date, format(O.total_amount, 1) as Total
    from CUSTOMERS C
             join QUANLYBANHANG.ORDERS O on C.customer_id = O.customer_id
    where C.customer_id = id;
end;
//
delimiter ;

call GetInvoiceByCustomerID('C004');

# 4.8 Create New Order
delimiter
//
-- Create the Procedure called 'CreateNewOrder()'"
create procedure CreateNewOrder(
    in order_id varchar(4),
    customer_id varchar(4),
    total_amount double,
    order_date date
)
begin
    -- Content for Procedure 'CreateNewOrder()' in here

    insert into ORDERS (order_id, customer_id, total_amount, order_date)
    values (order_id, customer_id, total_amount, order_date);
end;
//
delimiter ;

drop procedure if exists CreateNewOrder;
call CreateNewOrder('H011', 'C005', 1200000, now());

# 4.9 Summary Amount Bought Products
delimiter
//
-- Create the Procedure called 'GetBoughtAmount()'"
create procedure GetBoughtAmount(
    in startDate date,
    endDate date
)
begin
    -- Content for Procedure 'GetBoughtAmount()' in here
    select P.name, sum(OD.quantity) as Bought
    from PRODUCTS P
             join QUANLYBANHANG.ORDER_DETAILS OD on P.product_id = OD.product_id
             join QUANLYBANHANG.ORDERS O on O.order_id = OD.order_id
    where O.order_date >= startDate
      and O.order_date <= endDate
    group by P.product_id;
end;
//
delimiter ;

call GetBoughtAmount('2023/2/1', '2023/2/2');

# 4.10 Sort Bought Product
delimiter
//
-- Create the Procedure called 'SortBoughtProduct()'"
create procedure SortBoughtProduct(
    in findMonth int,
    findYear int
)
begin
    -- Content for Procedure 'SortBoughtProduct()' in here
    select row_number() over (order by sum(OD.quantity) desc) as STT, P.name, sum(OD.quantity) as Bought
    from PRODUCTS P
             join QUANLYBANHANG.ORDER_DETAILS OD on P.product_id = OD.product_id
             join QUANLYBANHANG.ORDERS O on O.order_id = OD.order_id
    where year(O.order_date) = findYear
      and month(O.order_date) = findMonth
    group by P.product_id
    order by Bought desc;
end;
//
delimiter ;

call SortBoughtProduct(3, 2023);