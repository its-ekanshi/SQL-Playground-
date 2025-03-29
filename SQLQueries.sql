CREATE DATABASE Practice;

--1st Question
Create table  Trips (id int, client_id int, driver_id int, city_id int, status varchar(50), request_at varchar(50));
Create table Users (users_id int, banned varchar(50), role varchar(50));
--Trips
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('1', '1', '10', '1', 'completed', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('2', '2', '11', '1', 'cancelled_by_driver', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('3', '3', '12', '6', 'completed', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('4', '4', '13', '6', 'cancelled_by_client', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('5', '1', '10', '1', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('6', '2', '11', '6', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('7', '3', '12', '6', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('8', '2', '12', '12', 'completed', '2013-10-03');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('9', '3', '10', '12', 'completed', '2013-10-03');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('10', '4', '13', '12', 'cancelled_by_driver', '2013-10-03');
--Users
insert into Users (users_id, banned, role) values ('1', 'No', 'client');
insert into Users (users_id, banned, role) values ('2', 'Yes', 'client');
insert into Users (users_id, banned, role) values ('3', 'No', 'client');
insert into Users (users_id, banned, role) values ('4', 'No', 'client');
insert into Users (users_id, banned, role) values ('10', 'No', 'driver');
insert into Users (users_id, banned, role) values ('11', 'No', 'driver');
insert into Users (users_id, banned, role) values ('12', 'No', 'driver');
insert into Users (users_id, banned, role) values ('13', 'No', 'driver');
select * from Trips;
select * from Users;
--Solution
with cte as(
select T.id, T.client_id, T.driver_id, T.city_id, T.status, T.request_at, c.banned, 
count(*) over (partition by request_at) as cnt,
count(case when status ='cancelled_by_client' or status = 'cancelled_by_driver' then 1 else null end) over(partition by request_at) as flag
from Trips T
inner join Users C on T.client_id = C.users_id and C.banned = 'No'
inner join Users D on T.client_id = D.users_id and D.banned = 'No')
select request_at, round((flag*1.0/cnt),2) as cancellation_rate 
from cte 
group by request_at, cnt, flag

--2nd Question
create table UserActivity
(
username      varchar(20) ,
activity      varchar(20),
startDate     Date   ,
endDate      Date
);
insert into UserActivity values 
('Alice','Travel','2020-02-12','2020-02-20')
,('Alice','Dancing','2020-02-21','2020-02-23')
,('Alice','Travel','2020-02-24','2020-02-28')
,('Bob','Travel','2020-02-11','2020-02-18');
select * from UserActivity;
--Get the Second most Recent Activity
select username, activity, startDate, endDate from
(select *,
rank() over (partition by username order by startDate) as rn,
count(*) over (partition by username) as cnt
from UserActivity) A
where rn = 2 or cnt = 1 

--3rd Question
create table stadium (
id int,
visit_date date,
no_of_people int
);
insert into stadium
values (1,'2017-07-01',10)
,(2,'2017-07-02',109)
,(3,'2017-07-03',150)
,(4,'2017-07-04',99)
,(5,'2017-07-05',145)
,(6,'2017-07-06',1455)
,(7,'2017-07-07',199)
,(8,'2017-07-08',188);
select * from stadium;
--write a query to display the records which have 3 or more consecutive rows
--with the amount of people more than 100(inclusive) each day
with cte as
(select *,
row_number() over (order by visit_date) as rn,
(id-row_number() over (order by visit_date)) as diff
from 
stadium
where no_of_people >= 100) 
, Qualify as(
select id, visit_date, no_of_people,
count(*) over(partition by diff) as total
from cte)
select id, visit_date, no_of_people from Qualify 
where total >= 4;

--4th Question
create table icc_world_cup
(
Team_1 Varchar(20),
Team_2 Varchar(20),
Winner Varchar(20)
);
INSERT INTO icc_world_cup values('India','SL','India');
INSERT INTO icc_world_cup values('SL','Aus','Aus');
INSERT INTO icc_world_cup values('SA','Eng','Eng');
INSERT INTO icc_world_cup values('Eng','NZ','NZ');
INSERT INTO icc_world_cup values('Aus','India','India');
select * from icc_world_cup;
--Write a query to find out Team_Name, Matches_played, win & loss
select Team_Name, count(1) as Matches_played, sum(win_flag) as no_of_matches_won, (count(1)-sum(win_flag)) as no_of_matches_loss from(
select Team_1 as Team_Name, case when Team_1 = Winner then 1 else 0 end as win_flag from icc_world_cup
union all
select Team_2 as Team_Name, case when Team_2 = Winner then 1 else 0 end as win_flag from icc_world_cup) A
group by Team_Name
order by no_of_matches_won desc

--5th Question
create table customer_orders (
order_id integer,
customer_id integer,
order_date date,
order_amount integer
);
insert into customer_orders values(1,100,cast('2022-01-01' as date),2000),(2,200,cast('2022-01-01' as date),2500),(3,300,cast('2022-01-01' as date),2100)
,(4,100,cast('2022-01-02' as date),2000),(5,400,cast('2022-01-02' as date),2200),(6,500,cast('2022-01-02' as date),2700)
,(7,100,cast('2022-01-03' as date),3000),(8,400,cast('2022-01-03' as date),1000),(9,600,cast('2022-01-03' as date),3000)
;
select * from customer_orders
--Write a SQL query to find order_date, new_customer_count, repeat_customer_count
with cte as(
select *,
first_value(order_date) over (partition by customer_id order by order_date) as fv
from customer_orders)
--order by order_id)
, cte2 as(
select *,
case when order_date = fv then 1 else null end as flag
from cte)
select order_date, count(flag) as new_customer_count, (count(customer_id)-count(flag)) as repeat_customer_count
from cte2 
group by order_date

--6th Question
create table entries ( 
name varchar(20),
address varchar(20),
email varchar(20),
floor int,
resources varchar(10));
insert into entries 
values ('A','Bangalore','A@gmail.com',1,'CPU'),('A','Bangalore','A1@gmail.com',1,'CPU'),('A','Bangalore','A2@gmail.com',2,'DESKTOP')
,('B','Bangalore','B@gmail.com',2,'DESKTOP'),('B','Bangalore','B1@gmail.com',2,'DESKTOP'),('B','Bangalore','B2@gmail.com',1,'MONITOR')
select * from entries;
--Write a SQL query to get name, total_visits, most_visited_floor, resources_used
with distinct_resources as(select distinct name, resources from entries)
,agg_resources as(select name, string_agg(resources, ',') as used_resources from distinct_resources group by name)
--select * from agg_resources
,total_visits as(
select name, count(1) as total_visits, string_agg(resources, ',') as resources_used from entries 
group by name)
,floor_visit as(
select name, floor, count(1) as no_of_floor_visit,
rank() over(partition by name order by count(1) desc) as rn
from entries
group by name, floor)
select fv.name, fv.floor as most_visited_floor , tv.total_visits, ar.used_resources 
from floor_visit as fv 
inner join total_visits tv on fv.name = tv.name
inner join agg_resources ar on fv.name = ar.name
where rn = 1

--7th Question
create table person(
PersonID int,
Name varchar(20),
Email varchar(50),
Score int
);
insert into person 
values
(1, 'Alice', 'alice2018@hotmail.com', 88),
(2, 'Bob', 'bob2018@hotmail.com', 11),
(3, 'Davis', 'davis2018@hotmail.com', 27),
(4, 'Tara', 'tara2018@hotmail.com', 45),
(5, 'John', 'john2018@hotmail.com', 63);
create table friend(
PersonID int,
FriendID int
);
insert into friend
values
(1,2),
(1,3),
(2,1),
(2,3),
(3,5),
(4,2),
(4,3),
(4,5);
select * from person;
select * from friend;
--write a query to find PersonID, Name, number of friends, sum of marks
--of person who have friends with total score greater than 100
with score_details as(
select f.personid, sum(score) as total_friend_score, count(1) as no_of_friends from friend f
inner join person p on f.friendid = p.personid
group by f.personid
having  sum(score) > 100
)
select s.*, p.name as person_name 
from person p
inner join score_details s on p.personid = s.personid

--8th Question
create table players
(player_id int,
group_id int)
;
insert into players values (15,1);
insert into players values (25,1);
insert into players values (30,1);
insert into players values (45,1);
insert into players values (10,2);
insert into players values (35,2);
insert into players values (50,2);
insert into players values (20,3);
insert into players values (40,3);
create table matches
(
match_id int,
first_player int,
second_player int,
first_score int,
second_score int)
insert into matches values (1,15,45,3,0);
insert into matches values (2,30,25,1,2);
insert into matches values (3,30,15,2,0);
insert into matches values (4,40,20,5,2);
insert into matches values (5,35,50,1,1);
select * from players;
select * from matches;
--write a SQL query to find the winner in each group 
--The winner in each group is the player who scored the maximum total points within the group. In case of tie,
--the lowest player_wins.
select min(player) as player, total_score, group_id from(
select player, sum(score) as total_score, p.group_id,
rank() over(partition by group_id order by sum(score) desc) rn
from 
(select first_player as player, sum(first_score) as score from matches group by first_player
union all 
select second_player as player, sum(second_score) as score from matches group by second_player) as A
inner join players p on A.player = p.player_id
group by player, p.group_id
) A
where rn = 1
group by total_score, group_id

--9th Question
create table userss (
user_id         int     ,
 join_date       date    ,
 favorite_brand  varchar(50));
 create table orderss (
 order_id       int     ,
 order_date     date    ,
 item_id        int     ,
 buyer_id       int     ,
 seller_id      int 
 );
 create table itemss
 (
 item_id        int     ,
 item_brand     varchar(50)
 );
insert into userss values (1,'2019-01-01','Lenovo'),(2,'2019-02-09','Samsung'),(3,'2019-01-19','LG'),(4,'2019-05-21','HP');
insert into itemss values (1,'Samsung'),(2,'Lenovo'),(3,'LG'),(4,'HP');
insert into orderss values (1,'2019-08-01',4,1,2),(2,'2019-08-02',2,1,3),(3,'2019-08-03',3,2,3),(4,'2019-08-04',1,4,2)
 ,(5,'2019-08-04',1,3,4),(6,'2019-08-05',2,2,4);
select * from orderss;
select * from userss;
select * from itemss;
--MARKET ANALYSIS :- write a SQL to find for find each seller, whether the brand of the second item (by date) they sold is their favourite brand. 
--If a seller sold less than two items then report the answer for that seller as no. o/p
with cte as(
select order_id, order_date, i.item_id, buyer_id, seller_id, i.item_brand from(
select *, 
rank() over(partition by seller_id order by order_date) as rn
from orderss) A
Right join itemss i on A.item_id = i.item_id 
where rn = 2)
select u.user_id, --u.favorite_brand, c.item_brand,
case when u.favorite_brand =  c.item_brand then 'Yes'
     when u.favorite_brand !=  c.item_brand then 'No'
	 else 'No'
	 end as flag
from userss u 
left join cte c
on u.user_id = c.seller_id

--10th Question
create table tasks(
date_value date,
state varchar(10)
);
insert into tasks
values('2019-01-01', 'success'),
('2019-01-02', 'success'),
('2019-01-03', 'success'),
('2019-01-04', 'fail'),
('2019-01-05', 'fail'),
('2019-01-06', 'success');
select * from tasks;
with all_dates as(
select *,
row_number() over (partition by state order by date_value) rn,
dateadd(day, -1*row_number() over (partition by state order by date_value), date_value) as group_date
from tasks)
--order by date_value;
select min(date_value)as start_date,max(date_value)as end_date, state
from all_dates
group by group_date, state
order by start_date;

--11th Question
create table spending 
(
user_id int,
spend_date date,
platform varchar(10),
amount int
);
insert into spending values(1,'2019-07-01','mobile',100),(1,'2019-07-01','desktop',100),(2,'2019-07-01','mobile',100)
,(2,'2019-07-02','mobile',100),(3,'2019-07-01','desktop',100),(3,'2019-07-02','desktop',100);
/* User purchase platform.
-- The table logs the spendings history of users that make purchases from an online shopping website which has a desktop 
and a mobile application.
-- Write an SQL query to find the total number of users and the total amount spent using mobile only, desktop only 
and both mobile and desktop together for each date.
*/
select * from spending;
with all_spend as(
select spend_date, user_id, max(platform) as platform, sum(amount) as amount
from spending
group by spend_date, user_id
having count(distinct platform)=1
union all
select spend_date, user_id, 'both' as platform, sum(amount) as amount
from spending
group by spend_date, user_id
having count(distinct platform) = 2
union all
select distinct spend_date, null as user_id, 'both' as platform, 0 as amount
from spending
)
select spend_date, platform, sum(amount) as total_amount, count(distinct user_id) as total_users
from all_spend
group by spend_date, platform
order by spend_date, platform desc;

--12th Question
create table orders
(
order_id int,
customer_id int,
product_id int,
);
insert into orders VALUES 
(1, 1, 1),
(1, 1, 2),
(1, 1, 3),
(2, 2, 1),
(2, 2, 2),
(2, 2, 4),
(3, 1, 5);
create table products (
id int,
name varchar(10)
);
insert into products VALUES 
(1, 'A'),
(2, 'B'),
(3, 'C'),
(4, 'D'),
(5, 'E');
select * from orders;
select * from products;
--recommendation system based on - product pairs most commonly purchased together
select concat(pr1.name,  pr2.name) as pair, count(1) as purchase_freq from orders o1
inner join orders o2 on o1.order_id = o2.order_id
inner join products pr1 on pr1.id = o1.product_id
inner join products pr2 on pr2.id = o2.product_id
where o1.product_id < o2.product_id
group by o1.product_id, o2.product_id, pr1.name, pr2.name 

--13th Question
create table usersss
(
user_id integer,
name varchar(20),
join_date date
);
insert into usersss
values (1, 'Jon', CAST('2-14-20' AS date)), 
(2, 'Jane', CAST('2-14-20' AS date)), 
(3, 'Jill', CAST('2-15-20' AS date)), 
(4, 'Josh', CAST('2-15-20' AS date)), 
(5, 'Jean', CAST('2-16-20' AS date)), 
(6, 'Justin', CAST('2-17-20' AS date)),
(7, 'Jeremy', CAST('2-18-20' AS date));
create table events
(
user_id integer,
type varchar(10),
access_date date
);

insert into events values
(1, 'Pay', CAST('3-1-20' AS date)), 
(2, 'Music', CAST('3-2-20' AS date)), 
(2, 'P', CAST('3-12-20' AS date)),
(3, 'Music', CAST('3-15-20' AS date)), 
(4, 'Music', CAST('3-15-20' AS date)), 
(1, 'P', CAST('3-16-20' AS date)), 
(3, 'P', CAST('3-22-20' AS date));
--prime subscription rate by product action
--given the following two tables, return the fraction of users, rounded to two decimal places,
--who accessed amazon music and upgraded to prime membership within the first 30 days of signing up.
select * from usersss;
select * from events;
with cte1 as(
select count(user_id) as qualify from (
select u.user_id, u.join_date, e.type, e.access_date, datediff(day, join_date, access_date) as diff, 
count(type) over (partition by u.user_id) as cnt,
count(case when type = 'Music' then 1 end) over (partition by u.user_id) as flag
from usersss u
inner join events e
on u.user_id = e.user_id) A
where type = 'P' and diff < 30 and cnt = 2 and flag = 1)
, cte2 as
(select count(*) as total from usersss)
select round((cte1.qualify*1.0/cte2.total),2) as answer from cte1, cte2 

--14th Question
create table transactions(
order_id int,
cust_id int,
order_date date,
amount int
);
insert into transactions values 
(1,1,'2020-01-15',150)
,(2,1,'2020-02-10',150)
,(3,2,'2020-01-16',150)
,(4,2,'2020-02-25',150)
,(5,3,'2020-01-10',150)
,(6,3,'2020-02-20',150)
,(7,4,'2020-01-20',150)
,(8,5,'2020-02-20',150)
;
select * from transactions;
--customer retention and customer churn metrics
select month(this_month.order_date) as month_date, count(distinct last_month.cust_id) from transactions this_month
left join transactions last_month
on this_month.cust_id = last_month.cust_id and datediff(month, last_month.order_date, this_month.order_date) = 1
group by month(this_month.order_date)

--15th Question
create table UserActivityy
(
username      varchar(20) ,
activity      varchar(20),
startDate     Date   ,
endDate      Date
);
insert into UserActivityy values 
('Alice','Travel','2020-02-12','2020-02-20')
,('Alice','Dancing','2020-02-21','2020-02-23')
,('Alice','Travel','2020-02-24','2020-02-28')
,('Bob','Travel','2020-02-11','2020-02-18');
select * from UserActivityy;
--Get the second most recent activity
select username, activity,startDate, endDate from(
select *, 
count(1) over (partition by username) as cnt ,
row_number() over(partition by username order by startDate) as rn
from UserActivityy) A
where (rn = 2 and cnt > 1) or cnt = 1

--16th Question
create table billings 
(
emp_name varchar(10),
bill_date date,
bill_rate int
);
insert into billings values
('Sachin','01-JAN-1990',25)
,('Sehwag' ,'01-JAN-1989', 15)
,('Dhoni' ,'01-JAN-1989', 20)
,('Sachin' ,'05-Feb-1991', 30)
;
create table HoursWorked 
(
emp_name varchar(20),
work_date date,
bill_hrs int
);
insert into HoursWorked values
('Sachin', '01-JUL-1990' ,3)
,('Sachin', '01-AUG-1990', 5)
,('Sehwag','01-JUL-1990', 2)
,('Sachin','01-JUL-1991', 4)
select * from billings;
select * from HoursWorked;
--total charges as per billing rate
select emp_name, sum(r) as total from (
select emp_name, (bill_hrs*bill_rate) as r from (
select H.emp_name, H.work_date, H.bill_hrs, B.bill_date, B.bill_rate,
max(B.bill_date) over (partition by H.emp_name order by bill_date rows between unbounded preceding and unbounded following) as max_date
from HoursWorked H
inner join billings B
on H.emp_name = B.emp_name ) A
where bill_date = max_date) B
GROUP BY emp_name;

--17th Question
--Activity table shows the app-installed and app-purchase activities for spotify app along with country details
CREATE table activity
(
user_id varchar(20),
event_name varchar(20),
event_date date,
country varchar(20)
);
insert into activity values (1,'app-installed','2022-01-01','India')
,(1,'app-purchase','2022-01-02','India')
,(2,'app-installed','2022-01-01','USA')
,(3,'app-installed','2022-01-01','USA')
,(3,'app-purchase','2022-01-03','USA')
,(4,'app-installed','2022-01-03','India')
,(4,'app-purchase','2022-01-03','India')
,(5,'app-installed','2022-01-03','SL')
,(5,'app-purchase','2022-01-03','SL')
,(6,'app-installed','2022-01-04','Pakistan')
,(6,'app-purchase','2022-01-04','Pakistan');
select * from activity;
/*question1: find total active users each day 
event_date  total_active_users
2022-01-01   3
2022-01-02   1
2022-01-03   3
2022-01-04   1
*/
select event_date, count(distinct user_id) as total_active_users
from activity
group by event_date;
/*question2: find total active users each week
week number  total_active_users
1              3
2              5
*/
select DATEPART(WEEK, event_date) as week_number, count(distinct user_id) as total_active_users
from activity
GROUP BY DATEPART(WEEK, event_date)
/*question3: date wise total no of users who made the purchase at same day they installed the app */
select event_date, count(new_user) as no_of_users from (
select user_id, event_date, 
case when count(distinct event_name) = 2 then user_id else null end as new_user,
count(distinct event_name) as no_of_events from activity
group by user_id, event_date) A
--having count(distinct event_name) = 2) A
group by event_date
/*question4: percentage of paid users in India, USA and any other country should be tagged as others country percentage_users*/
select flag as country, ((cnt*100)/total) as percentage from(
select *,
count(user_id) over(partition by flag) as cnt from(
select *,
case when country = 'India' then 'India' 
     when country = 'Pakistan' then 'Pakistan'
	 when country = 'SL' then 'Others'
	 when country = 'USA' then 'Others'
	 end as flag,
count(user_id) over() as total
from activity 
where event_name = 'app-purchase') A) B
group  by Flag, (cnt*100)/total
order by flag
/*question5: Among all the users who installed the app on a given day, how many did in purchased on the very next day*/
select * from activity;
select event_date, Datediff(day, lg, event_date) as diff from(
select *, 
lag(event_date, 1, event_date) over (partition by user_id order by event_date) as lg
from Activity) A
where Datediff(day, lg, event_date) = 1

--18th Question
create table bms (seat_no int ,is_empty varchar(10));
insert into bms values
(1,'N')
,(2,'Y')
,(3,'N')
,(4,'Y')
,(5,'Y')
,(6,'Y')
,(7,'N')
,(8,'Y')
,(9,'Y')
,(10,'Y')
,(11,'Y')
,(12,'N')
,(13,'Y')
,(14,'Y');
select * from bms;
--3 or more consecutive empty seats
select seat_no from (
select seat_no, count(*) over (partition by diff) as cnt from (
select seat_no, (seat_no-rn) as diff from (
select *,
row_number() over (order by seat_no) as rn
from bms
where is_empty = 'Y') A) B) C
where cnt >= 3;

--19th Question
CREATE TABLE STORES (
Store varchar(10),
Quarter varchar(10),
Amount int);
INSERT INTO STORES (Store, Quarter, Amount)
VALUES ('S1', 'Q1', 200),
('S1', 'Q2', 300),
('S1', 'Q4', 400),
('S2', 'Q1', 500),
('S2', 'Q3', 600),
('S2', 'Q4', 700),
('S3', 'Q1', 800),
('S3', 'Q2', 750),
('S3', 'Q3', 900);
select * from stores;
--Find missing Quarter
select store, concat(Q, missing_num) as missing_quarter from (
select store, Q, 10-(sum(cast (num as int)) over (partition by store order by store)) as missing_num from(
select store, left(Quarter,1) as Q, right(Quarter, 1) as num 
from Stores) A) B
group by B.store, B.Q, B.missing_num;

--20th Question
create table exams (student_id int, subject varchar(20), marks int);
insert into exams values (1,'Chemistry',91),(1,'Physics',91)
,(2,'Chemistry',80),(2,'Physics',90)
,(3,'Chemistry',80)
,(4,'Chemistry',71),(4,'Physics',54);
select * from exams;
--find students with same marks in physics & chemistry 
select * from exams
select student_id
from exams
where subject in ('Chemistry', 'Physics')
group by student_id
having count(distinct subject) = 2 and count(distinct marks) = 1

--21th Question 
create table covid(city varchar(50),days date,cases int);
insert into covid values('DELHI','2022-01-01',100);
insert into covid values('DELHI','2022-01-02',200);
insert into covid values('DELHI','2022-01-03',300);
insert into covid values('MUMBAI','2022-01-01',100);
insert into covid values('MUMBAI','2022-01-02',100);
insert into covid values('MUMBAI','2022-01-03',300);
insert into covid values('CHENNAI','2022-01-01',100);
insert into covid values('CHENNAI','2022-01-02',200);
insert into covid values('CHENNAI','2022-01-03',150);
insert into covid values('BANGALORE','2022-01-01',100);
insert into covid values('BANGALORE','2022-01-02',300);
insert into covid values('BANGALORE','2022-01-03',200);
insert into covid values('BANGALORE','2022-01-04',400);
select * from covid;
--find the cities where covid cases are increasily rapidly
select city from (
select *, count(*) over (partition by city) as cnt, count(case when d = rn then 1 else null end) over (partition by city) as flag from
(select *,
datepart(day, days) as d,
rank() over (partition by city order by cases) as rn
from covid) as A ) B
where cnt = flag
group by city;

--22th Question
create table company_users 
(
company_id int,
user_id int,
language varchar(20)
);
insert into company_users values (1,1,'English')
,(1,1,'German')
,(1,2,'English')
,(1,3,'German')
,(1,3,'English')
,(1,4,'English')
,(2,5,'English')
,(2,5,'German')
,(2,5,'Spanish')
,(2,6,'German')
,(2,6,'Spanish')
,(2,7,'English');
select * from company_users;
--find companies who have atleast 2 users who speaks English & German both the languages.
select company_id from(
select company_id, user_id, cnt from(
select *,
count(*) over (partition by company_id, user_id) as cnt
from company_users
where language in ('English', 'German')) A
where cnt = 2) B
GROUP BY COMPANY_ID
HAVING COUNT(DISTINCT USER_ID) >= 2

--23th Question
create table productss
(
product_id varchar(20) ,
cost int
);
insert into productss values ('P1',200),('P2',300),('P3',500),('P4',800);
create table customer_budget
(
customer_id int,
budget int
);

insert into customer_budget values (100,400),(200,800),(300,1500);
select * from productss;
select * from customer_budget;
--find how many products fall into customer budget along with list of products
--In case of clash choose the less costly product 
with cte as(
select *,
sum(cost) over(order by product_id) as running_sum
from productss)
select cb.customer_id, cb.budget, count(*) over (partition by customer_id) as no_of_products, string_agg(product_id, ',')
from customer_budget cb
join cte c 
on c.running_sum < cb.budget
group by cb.customer_id, cb.budget
order by customer_id;

--24th Question
CREATE TABLE subscriber (
 sms_date date ,
 sender varchar(20) ,
 receiver varchar(20) ,
 sms_no int
);
INSERT INTO subscriber VALUES ('2020-4-1', 'Avinash', 'Vibhor',10);
INSERT INTO subscriber VALUES ('2020-4-1', 'Vibhor', 'Avinash',20);
INSERT INTO subscriber VALUES ('2020-4-1', 'Avinash', 'Pawan',30);
INSERT INTO subscriber VALUES ('2020-4-1', 'Pawan', 'Avinash',20);
INSERT INTO subscriber VALUES ('2020-4-1', 'Vibhor', 'Pawan',5);
INSERT INTO subscriber VALUES ('2020-4-1', 'Pawan', 'Vibhor',8);
INSERT INTO subscriber VALUES ('2020-4-1', 'Vibhor', 'Deepak',50);
select * from subscriber;
select sms_date, p1, p2, sum(sms_no) as total_sms from(
select sms_date,
case when sender < receiver then sender else receiver end as p1,
case when sender > receiver then sender else receiver end as p2,
sms_no
from subscriber) A
group by sms_date, p1, p2

--25th Question
CREATE TABLE [students](
 [studentid] [int] NULL,
 [studentname] [nvarchar](255) NULL,
 [subject] [nvarchar](255) NULL,
 [marks] [int] NULL,
 [testid] [int] NULL,
 [testdate] [date] NULL
)
insert into students values (2,'Max Ruin','Subject1',63,1,'2022-01-02');
insert into students values (3,'Arnold','Subject1',95,1,'2022-01-02');
insert into students values (4,'Krish Star','Subject1',61,1,'2022-01-02');
insert into students values (5,'John Mike','Subject1',91,1,'2022-01-02');
insert into students values (4,'Krish Star','Subject2',71,1,'2022-01-02');
insert into students values (3,'Arnold','Subject2',32,1,'2022-01-02');
insert into students values (5,'John Mike','Subject2',61,2,'2022-11-02');
insert into students values (1,'John Deo','Subject2',60,1,'2022-01-02');
insert into students values (2,'Max Ruin','Subject2',84,1,'2022-01-02');
insert into students values (2,'Max Ruin','Subject3',29,3,'2022-01-03');
insert into students values (5,'John Mike','Subject3',98,2,'2022-11-02');
select * from students
order by studentid, marks;
--Write a sql query to get the list of students who scored above the average marks in each subjects
select studentname from(
select *,
avg(marks) over (partition by subject) as avg_marks
from students) A
where marks> avg_marks;
--Write a sql query to get the percentage of students who scored more than 90 in any subject among the total students
select round(count(flag)*1.0/count(distinct studentname), 2) as percentage from (
select *,
case when marks > 90 then 1 else null end as flag
from students ) A 

--26th Question
CREATE TABLE [dbo].[int_orders](
 [order_number] [int] NOT NULL,
 [order_date] [date] NOT NULL,
 [cust_id] [int] NOT NULL,
 [salesperson_id] [int] NOT NULL,
 [amount] [float] NOT NULL
) ON [PRIMARY];
INSERT INTO [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (30, CAST('1995-07-14' AS Date), 9, 1, 460);
INSERT into [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (10, CAST('1996-08-02' AS Date), 4, 2, 540);
INSERT INTO [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (40, CAST('1998-01-29' AS Date), 7, 2, 2400);
INSERT INTO [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (50, CAST('1998-02-03' AS Date), 6, 7, 600);
INSERT into [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (60, CAST('1998-03-02' AS Date), 6, 7, 720);
INSERT into [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (70, CAST('1998-05-06' AS Date), 9, 7, 150);
INSERT into [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (20, CAST('1999-01-30' AS Date), 4, 8, 1800);
select * from [int_orders];
--Find the largest order by value for each salesperson and display order details
--Get the result without using subquery, cte, window function, temp tables.
select a.order_number, a.order_date, a.cust_id, a.salesperson_id, a.amount from [int_orders] a
left join [int_orders] b on a.salesperson_id = b.salesperson_id 
group by a.order_number, a.order_date, a.cust_id, a.salesperson_id, a.amount 
having a.amount >= max(b.amount)

--27th Question
create table event_status
(
event_time varchar(10),
status varchar(10)
);
insert into event_status 
values
('10:01','on'),('10:02','on'),('10:03','on'),('10:04','off'),('10:07','on'),('10:08','on'),('10:09','off')
,('10:11','on'),('10:12','off');
select * from event_status;
with xxx as(
select*,
sum(case when status = 'on' and prev_status = 'off' then 1 else 0 end) over (order by event_time) as group_key
from(
select *,
lag(status, 1, status) over (order by event_time asc) as prev_status
from event_status) A)
select min(event_time) as login , max(event_time) as logout, (count(1)-1) as on_count
from xxx
group by group_key

--28th Question
create table players_location
(
name varchar(20),
city varchar(20)
);
insert into players_location
values ('Sachin','Mumbai'),('Virat','Delhi') , ('Rahul','Bangalore'),('Rohit','Mumbai'),('Mayank','Bangalore');
select * from players_location
select 
max(case when city = 'Bangalore' then name end) as Bangalore,
max(case when city = 'Mumbai' then name end) as Mumbai,
max(case when city = 'Delhi' then name end) as Delhi
from(
select *,
row_number() over (partition by city order by name asc) as player_groups
from players_location) A
group by player_groups
order by player_groups

--29th Question
create table employee 
(
emp_id int,
company varchar(10),
salary int
);

insert into employee values (1,'A',2341)
insert into employee values (2,'A',341)
insert into employee values (3,'A',15)
insert into employee values (4,'A',15314)
insert into employee values (5,'A',451)
insert into employee values (6,'A',513)
insert into employee values (7,'B',15)
insert into employee values (8,'B',13)
insert into employee values (9,'B',1154)
insert into employee values (10,'B',1345)
insert into employee values (11,'B',1221)
insert into employee values (12,'B',234)
insert into employee values (13,'C',2345)
insert into employee values (14,'C',2645)
insert into employee values (15,'C',2645)
insert into employee values (16,'C',2652)
insert into employee values (17,'C',65);
select * from employee;
--write a SQL Query to find the median salary of each company.
--Bonus points if you can solve it without using any built-in function.
select company, avg(salary)
from(
select *,
row_number() over (partition by company order by salary) as rn,
count(1) over (partition by company) as total_cnt
from employee) A
where rn between total_cnt*1.0/2 and total_cnt*1.0/2 + 1
group by Company 

--30th Question
CREATE TABLE [emp](
 [emp_id] [int] NULL,
 [emp_name] [varchar](50) NULL,
 [salary] [int] NULL,
 [manager_id] [int] NULL,
 [emp_age] [int] NULL,
 [dep_id] [int] NULL,
 [dep_name] [varchar](20) NULL,
 [gender] [varchar](10) NULL
) ;
insert into emp values(1,'Ankit',14300,4,39,100,'Analytics','Female')
insert into emp values(2,'Mohit',14000,5,48,200,'IT','Male')
insert into emp values(3,'Vikas',12100,4,37,100,'Analytics','Female')
insert into emp values(4,'Rohit',7260,2,16,100,'Analytics','Female')
insert into emp values(5,'Mudit',15000,6,55,200,'IT','Male')
insert into emp values(6,'Agam',15600,2,14,200,'IT','Male')
insert into emp values(7,'Sanjay',12000,2,13,200,'IT','Male')
insert into emp values(8,'Ashish',7200,2,12,200,'IT','Male')
insert into emp values(9,'Mukesh',7000,6,51,300,'HR','Male')
insert into emp values(10,'Rakesh',8000,6,50,300,'HR','Male')
insert into emp values(11,'Akhil',4000,1,31,500,'Ops','Male')
select * from emp;
--write an SQL to find details of employees with 3rd highest salary in each department
--in case there are less than 3 employees in a department then return employee details with lowest salary in that dep.
select emp_id, emp_name, salary, dep_id, dep_name from (
select *,
count(1) over (partition by dep_id) as cnt,
rank() over (partition by dep_id order by salary desc) as rn
from emp) A
where rn = 3 or (cnt < 3 and rn = cnt)

--31th Question
create table stadiumm (
id int,
visit_date date,
no_of_people int
);
insert into stadiumm
values (1,'2017-07-01',10)
,(2,'2017-07-02',109)
,(3,'2017-07-03',150)
,(4,'2017-07-04',99)
,(5,'2017-07-05',145)
,(6,'2017-07-06',1455)
,(7,'2017-07-07',199)
,(8,'2017-07-08',188);
select * from stadiumm;
--Write a Query to display the records which have 3 or more consecutive rows
--with the amount of people more than 100(inclusive) each day
select id, visit_date, no_of_people from(
select *, count(1) over (partition by diff) as cnt from(
select *, 
row_number() over (order by visit_date) as rn,
(id-row_number() over (order by visit_date)) as diff
from stadiumm
where no_of_people > 100) A) B
where cnt >= 3;

--32th Question
create table business_city (
business_date date,
city_id int
);
insert into business_city
values(cast('2020-01-02' as date),3),(cast('2020-07-01' as date),7),(cast('2021-01-01' as date),3),(cast('2021-02-03' as date),19)
,(cast('2022-12-01' as date),3),(cast('2022-12-15' as date),3),(cast('2022-02-28' as date),12);
select * from business_city; 
--business_city table has data from the day udaaan has started operation 
--write a sql to identify yearwise count of new cities where udaan started their operations
with cte as (
select Datepart(year, business_date) as bus_year, city_id
from business_city )
select c1.bus_year, count(case when c2.city_id is null then c1.city_id end) as no_of_new_cities
from cte c1
left join cte c2 on c1.bus_year > c2.bus_year and c1.city_id = c2.city_id
group by c1.bus_year

--33th Question
create table movie(
seat varchar(50),occupancy int
);
insert into movie values('a1',1),('a2',1),('a3',0),('a4',0),('a5',0),('a6',0),('a7',1),('a8',1),('a9',0),('a10',0),
('b1',0),('b2',0),('b3',0),('b4',1),('b5',1),('b6',1),('b7',1),('b8',0),('b9',0),('b10',0),
('c1',0),('c2',1),('c3',0),('c4',1),('c5',1),('c6',0),('c7',1),('c8',0),('c9',0),('c10',1);
select * from movie;
--there are three rows in a movie hall each with 10 seats in each row
--write a SQL to find 4 consecutive empty seats
WITH CTE AS(
SELECT *, COUNT(DIFF) OVER (PARTITION BY DIFF) AS CNT FROM(
select *, row_number() over (partition by row_id order by seat_id) as rn, 
(seat_id-row_number() over (partition by row_id order by seat_id)) as diff
from (
select *,
left(seat,1) as row_id, cast(substring(seat,2,2) as int) as seat_id
from movie
where occupancy = 0) A ) B)
SELECT SEAT FROM CTE 
WHERE CNT = 4 AND DIFF != 0

--34th Question
create table call_details  (
call_type varchar(10),
call_number varchar(12),
call_duration int
);
insert into call_details
values ('OUT','181868',13),('OUT','2159010',8)
,('OUT','2159010',178),('SMS','4153810',1),('OUT','2159010',152),('OUT','9140152',18),('SMS','4162672',1)
,('SMS','9168204',1),('OUT','9168204',576),('INC','2159010',5),('INC','2159010',4),('SMS','2159010',1)
,('SMS','4535614',1),('OUT','181868',20),('INC','181868',54),('INC','218748',20),('INC','2159010',9)
,('INC','197432',66),('SMS','2159010',1),('SMS','4535614',1);
select * from call_details;
/*write a sql to determine phone numbers that satisfied below conditions:
1- the numbers have both incoming and outgoing calls.
2- the sum of duration of outgoing calls should be greater than sum of duration of incoming calls */
with cte as (
select call_number,
sum(case when call_type = 'OUT' then call_duration else null end) as out_duration,
sum(case when call_type = 'INC' then call_duration else null end) as inc_duration
from call_details
group by call_number)
select call_number from cte 
where out_duration > inc_duration 

--35th Question
create table student
(
student_id int,
student_name varchar(20)
);
insert into student values
(1,'Daniel'),(2,'Jade'),(3,'Stella'),(4,'Jonathan'),(5,'Will');
create table exam
(
exam_id int,
student_id int,
score int);

insert into exam values
(10,1,70),(10,2,80),(10,3,90),(20,1,80),(30,1,70),(30,3,80),(30,4,90),(40,1,60)
,(40,2,70),(40,4,80);
select * from student;
select * from exam;
--write a sql query to report the students (student_id, student_name) being quiet in all exams.
--A quite student is one who took atlest one exam and didn't score neihter the high score nor the low score in any of the exams.
--Don't return the student who have never taken any exam. Return the result table ordered by student_id.
with all_scores as(
select exam_id, min(score) as min_score, max(score) as max_score 
from exam
group by exam_id)
select exam.student_id,
max(case when score = min_score or score = max_score then 1 else 0 end) as red_flag
from exam
inner join all_scores on exam.exam_id = all_scores.exam_id
group by student_id
having max(case when score = min_score or score = max_score then 1 else 0 end) = 0

--36th Question
create table phonelog(
    Callerid int, 
    Recipientid int,
    Datecalled datetime
);
insert into phonelog(Callerid, Recipientid, Datecalled)
values(1, 2, '2019-01-01 09:00:00.000'),
       (1, 3, '2019-01-01 17:00:00.000'),
       (1, 4, '2019-01-01 23:00:00.000'),
       (2, 5, '2019-07-05 09:00:00.000'),
       (2, 3, '2019-07-05 17:00:00.000'),
       (2, 3, '2019-07-05 17:20:00.000'),
       (2, 5, '2019-07-05 23:00:00.000'),
       (2, 3, '2019-08-01 09:00:00.000'),
       (2, 3, '2019-08-01 17:00:00.000'),
       (2, 5, '2019-08-01 19:30:00.000'),
       (2, 4, '2019-08-02 09:00:00.000'),
       (2, 5, '2019-08-02 10:00:00.000'),
       (2, 5, '2019-08-02 10:45:00.000'),
       (2, 4, '2019-08-02 11:00:00.000');
select * from phonelog;
/*there is a phonelog table that has information about callers' call history.
write a SQL to find out callers whose first and last call was to same person on a given day*/
with calls as(
select Callerid, cast(Datecalled as date) as called_date, min(datecalled) as first_call, max(datecalled) as last_call
from phonelog
group by Callerid, cast(Datecalled as date))
select c.*, p1.recipientid from calls c
inner join phonelog p1 on c.callerid = p1.callerid and c.first_call = p1.datecalled
inner join phonelog p2 on c.callerid = p2.callerid and c.last_call = p2.datecalled
where p1.recipientid = p2.recipientid

--37th Question
create table candidates (
emp_id int,
experience varchar(20),
salary int
);
insert into candidates values
(1,'Junior',10000),(2,'Junior',15000),(3,'Junior',40000),(4,'Senior',16000),(5,'Senior',20000),(6,'Senior',50000);
select * from candidates;
/*A Company wants to hire new employees. The budget of the company for the salaries is $70000.The Company's criteria for hiring are:
Keep hiring the senior with the smallest salary until you cannot hire any more seniors.
Use the remaining budget to hire the junior with the smallest salary.
Keep hiring the junior with the smallest salary until you cannot hire any more juniors.
write an SQL query to find the seniors & juniors hired under the mentioned criteria*/
with run_sum as(
select *,
sum(salary) over (partition by experience order by salary) as running_sum
from candidates)
,senior_cte as(
select * from run_sum
where experience = 'senior' and running_sum <= 70000)
select * from run_sum
where experience = 'junior' and running_sum <= 70000-(select sum(salary) from senior_cte)
union
select * from senior_cte;

--38th Question
create table empp(
emp_id int,
emp_name varchar(20),
department_id int,
salary int,
manager_id int,
emp_age int);
insert into empp
values
(1, 'Ankit', 100,10000, 4, 39);
insert into empp
values (2, 'Mohit', 100, 15000, 5, 48);
insert into empp
values (3, 'Vikas', 100, 12000,4,37);
insert into empp
values (4, 'Rohit', 100, 14000, 2, 16);
insert into empp
values (5, 'Mudit', 200, 20000, 6,55);
insert into empp
values (6, 'Agam', 200, 12000,2, 14);
insert into empp
values (7, 'Sanjay', 200, 9000, 2,13);
insert into empp
values (8, 'Ashish', 200,5000,2,12);
insert into empp
values (9, 'Mukesh',300,6000,6,51);
insert into empp
values (10, 'Rakesh',500,7000,6,50);
select * from empp;
--write a SQL to list emp name along with their manager and the senior manager name.
--senior manager is manager's manager.
select e.emp_name as emp_name, m.emp_name as manager_name, sm.emp_name as senior_manager_name
from empp e
join empp m on e.manager_id = m.emp_id
join empp sm on m.manager_id = sm.emp_id
order by emp_name;
























































































































































































































































































































 







































































































































































































































































































































































































































































































































































































































































































































