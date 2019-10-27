create table month(
    number integer primary key,
    name text
);

insert into month
select  1, 'January' union
select  2, 'February' union
select  3, 'March' union
select  4, 'April' union
select  5, 'May' union
select  6, 'June' union
select  7, 'July' union
select  8, 'August' union
select  9, 'September' union
select 10, 'October' union
select 11, 'November' union
select 12, 'December';