-- Queries


-- ‫‪1‬‬‫)‬‫لیست‬ ‫راننده‬ ‫هایی‬ ‫که‬ ‫ماشین‬ ‫پراید‬ ‫با‬ ‫رنگ‬ ‫آبی‬ ‫دارند‬
SELECT CAR.Color, V.Name, D.* 
FROM CAR, VEHICHLE V, Driver D
WHERE CAR.Color = 'آبی' AND V.Name = 'پراید' AND V.Plaque = CAR.Plaque AND  D.ID = V.Driver_ID ;

-- ‫‪2‬‬‫)‬‫لیست‬ ‫راننده‬ ‫های‬ ‫خانم‬ ‫باالتر‬ ‫از‬ ‫‪30‬‬ ‫سال‬ ‫که‬ ‫ماشین‬ ‫سواری‬ ‫آبی‬ ‫رنگ‬ ‫دارند‬
SELECT CAR.Color, V.Name, D.* 
FROM CAR, VEHICHLE V, Driver D
WHERE CAR.Color = 'آبی' AND V.Plaque = CAR.Plaque AND  D.ID = V.Driver_ID AND D.Age > 30 AND D.Sex = 'f' ;


-- ‫‪3‬‬‫)‬‫نام‬ ‫همه‬ ‫راننده‬ ‫وانت‬ ‫ها‬ ‫به‬ ‫همراه‬ ‫تاریخ‬ ‫تایید‬ ‫و‬ ‫شماره‬ ‫گواهی‬ ‫برای‬ ‫گواهینامه‬ ‫و‬ ‫سوء‌پیشینه‬ ‫آن‬
-- ‫ها‬‫که‬ ‫در‬ ‫صورت‬ ‫وجود‬ ‫تایید‬ ‫شده‬ ‫اند‪.‬‬
SELECT D.L_name, D.F_name, D.Approval_date, D.Certificateـnumber, CH.Criminal_Record
FROM CHECK_INF CH, Driver D, VEHICHLE V
WHERE V.Name LIKE '%وانت%' AND V.Driver_ID = D.ID AND CH.Driver_ID = D.ID AND CH.ChechForCriminal_Record = TRUE;



-- ‫‪4‬‬‫)‬‫اطالعات‬ ‫کاربرانی‬ ‫که‬ ‫موجودی‬ ‫آن‬ ‫ها‬ ‫بیشتر‬ ‫از‬ ‫‪50‬‬ ‫هزار‬ ‫تومان‬ ‫است‬ ‫و‬ ‫حداقل‬ ‫‪2‬‬ ‫آدرس‬ ‫منتخب‬
-- ‫ثبت‬‫کرده‬ ‫اند‪.‬‬
SELECT PA.ID, PA.F_name, PA.L_name, PA.Sex, PA.Phone_number, PA.Age, PA.Reg_date, PA.Email
FROM PASSENGER PA JOIN ADDRESS AD ON PA.ID = AD.User_ID JOIN User_Wallet U ON U.ID = PA.ID
WHERE U.Balance > 50000
GROUP BY PA.ID, PA.F_name, PA.L_name, PA.Sex, PA.Phone_number, PA.Age, PA.Reg_date, PA.Email
HAVING COUNT(AD) >= 2;


-- ‫‪5‬‬‫)‬‫تاریخ‬ ‫روزی‬ ‫که‬ ‫کمترین‬ ‫تعداد‬ ‫درخواست‬ ‫سفر‬ ‫رفت‬ ‫و‬ ‫برگشت‬ ‫از‬ ‫سوی‬ ‫کاربران‬ ‫نوجوان‬ ‫را‬ ‫داشته‬
-- ‫است‬‫(کاربران‬ ‫نوجوان‬ ‫بین‬ ‫‪15‬‬ ‫تا‬ ‫‪18‬‬ ‫سال‬ ‫سن‬ ‫دارند)‬
SELECT TR.Trip_Date
FROM trip TR JOIN destination D ON TR.Trip_ID = D.T_ID JOIN passenger pa ON TR.User_ID = pa.ID
WHERE D.Destination = TR.Start_location
  AND pa.Age >= 15
  AND pa.Age <= 18
GROUP BY TR.Trip_Date
HAVING COUNT(TR.Trip_ID) > 0
ORDER BY COUNT(TR.Trip_ID) ASC LIMIT 1;




-- ‫‪6‬‬‫)‬‫مجموع‬ ‫مبالغ‬ ‫کیف‬ ‫پول‬ ‫به‬ ‫همراه‬ ‫نام‬ ‫راننده‬ ‫هایی‬ ‫که‬ ‫حداقل‬ ‫‪2‬‬ ‫سفر‬ ‫در‬ ‫تاریخ‬ ‫‪2024/01/01‬‬
-- ‫داشته‬‫اند‪.‬‬
SELECT D.F_name || ' ' || D.L_name AS Driver_Name, SUM(UW.Balance) AS Total_Wallet_Amount
FROM Driver D JOIN Driver_Wallet UW ON D.ID = UW.ID
WHERE D.ID IN (
        SELECT Tr.Driver_ID
        FROM TRIP Tr JOIN DRIVER D ON D.ID = Tr.Driver_ID
        WHERE Tr.Trip_Date = '2024-01-01'
        GROUP BY Tr.Driver_ID
        HAVING
            COUNT(Tr.Trip_ID) >= 2
    )
GROUP BY D.ID, D.F_name, D.L_name;


-- ‫‪7‬‬‫)‬‫جمع‬ ‫مسافتی‬ ‫که‬ ‫هر‬ ‫مسافر‬ ‫برای‬ ‫سفر‌هایی‬ ‫طی‬ ‫کرده‬ ‫است‬ ‫که‬ ‫در‬ ‫یک‬ ‫هفته‬ ‫اخیر‬ ‫بیشتر‬ ‫از‬ ‫دو‬
-- ‫ساعت‬‫به‬ ‫طول‬ ‫انجامیده‬ ‫اند‬ ‫به‬ ‫همراه‬ ‫نام‬ ‫آن‬ ‫مسافران‪.‬‬
SELECT pa.F_name || ' ' || pa.L_name AS Passenger_Name, SUM(tr.Distance) AS Total_Kilometers
FROM TRIP tr JOIN PASSENGER pa ON tr.User_ID = pa.ID
WHERE tr.Time_end - tr.Time_start > INTERVAL '2 hours' AND tr.Trip_Date >= CURRENT_DATE - INTERVAL '1 weeks'
GROUP BY pa.F_name, pa.L_name;


-- ‫‪8‬‬‫)‬‫نام‬ ‫و‬ ‫سن‬ ‫رانندگان‬ ‫وانت‬ ‫گازسوزی‬ ‫که‬ ‫ناشنوا‬ ‫اند‬ ‫و‬ ‫از‬ ‫میانگین‬ ‫سنی‬ ‫تمام‬ ‫راننده‬ ‫ها‬ ‫باالتراند‬ ‫و‬
-- ‫تعداد‬‫سفرهایی‬ ‫که‬ ‫داشته‬ ‫اند‬ ‫از‬ ‫تعداد‬ ‫سفرهای‬ ‫رانندگان‬ ‫ماشین‬ ‫با‬ ‫ظرفیت‬ ‫حداقل‬ ‫‪4‬‬ ‫نفر‬ ‫باالتر‬ ‫بوده‬
-- ‫است‪.‬‬
CREATE VIEW MAX_car_trips AS  
SELECT COUNT(Trip_ID) AS Trips_num 
FROM Driver D JOIN VEHICHLE V ON D.ID = V.Driver_ID JOIN car TR ON TR.Plaque = V.Plaque join Trip on Trip.Driver_ID = D.ID
WHERE V.capacity >= 4 
GROUP BY D.ID
ORDER BY COUNT(Trip_ID) DESC
LIMIT 1;


CREATE VIEW VANET_TRIPS AS  
SELECT D.ID AS DRIVER_ID, COUNT(Trip_ID) AS Trips_num 
FROM Driver D JOIN VEHICHLE V ON D.ID = V.Driver_ID JOIN TRUCK TR ON TR.Plaque = V.Plaque join Trip on Trip.Driver_ID = D.ID
GROUP BY D.ID
ORDER BY COUNT(Trip_ID) DESC;

CREATE VIEW DRIVER_AVG_AGE AS
SELECT AVG(D.Age) AS avg_age
FROM Driver D;

SELECT D.F_name, D.L_name, D.Age
FROM Driver D JOIN VEHICHLE V ON D.ID = V.Driver_ID JOIN TRUCK TR ON TR.Plaque = V.Plaque JOIN VANET_TRIPS ON VANET_TRIPS.DRIVER_ID = D.ID, MAX_car_trips, DRIVER_AVG_AGE
WHERE D.Disability LIKE '%ناشنوا%' AND V.Name LIKE '%وانت%' AND TR.Type_Fuel = 'GAS' AND DRIVER_AVG_AGE.avg_age < D.Age AND MAX_car_trips.Trips_num  < VANET_TRIPS.Trips_num;


-- ‫‪9‬‬‫)‬‫پالک‬ ‫وسیله‬ ‫نقلیه‬ ‫هایی‬ ‫که‬ ‫سفری‬ ‫با‬ ‫سرویس‬ ‫بکسی‬ ‫بار‬ ‫با‬ ‫بار‬ ‫شکستنی‬ ‫با‬ ‫ارزش‬ ‫حداکثر‬ ‫‪50‬‬
-- ‫میلیون‬‫تومان‬ ‫داشته‬ ‫اند‬ ‫را‬ ‫به‬ ‫همراه‬ ‫نام‬ ‫راننده‬ ‫بنویسید‪.‬‬
SELECT d.f_name, d.L_name, v.plaque
FROM trip_load tl join trip tr on tr.Trip_ID = tl.Trip_ID join driver d on d.id = tr.Driver_id join vehichle v on v.Driver_ID = d.id 
WHERE tl.Breakable = true and tl.StuffـValue <= 50000000;



-- ‫‪10‬‬‫)‬‫نام‬ ‫خانوادگی‬ ‫و‬ ‫شماره‬ ‫تلفن‬ ‫و‬ ‫ایمیل‬ ‫مسافران‬ ‫مردی‬ ‫که‬ ‫بیشترین‬ ‫درخواست‬ ‫سفر‬ ‫آن‬ ‫ها‬ ‫در‬ ‫یک‬
-- ‫روز‬‫از‬ ‫تاریخ‬ ‫‪2024/01/01‬‬ ‫تا‬ ‫‪2024/02/21‬‬ ‫از‬ ‫بیشترین‬ ‫درخواست‬ ‫سفرهای‬ ‫با‬ ‫چندین‬ ‫مقصد‬ ‫(دو‬
-- ‫مقصد)‬‫بیشتر‬ ‫باشد‬ ‫و‬ ‫نام‬ ‫آن‬ ‫ها‬ ‫شامل‬ ‫نام‬ ‫“‬ ‫‪Piotr‬‬‫”‬‫باشد‬
create view counttrips as
select pa.id pass_id, tr.trip_date as trip_date, count(trip_date) countbydate
from passenger pa, trip tr 
where tr.user_id = pa.id and tr.Trip_Date BETWEEN '2024-01-01' AND '2024-02-21' and pa.sex = 'm' and pa.f_name like 'Piotr'
group by Trip_Date, pa.id;


create view counttripsdists as
select count(tr) as countbydest
from passenger pa, trip tr, trip_person dest
where tr.user_id = pa.id and dest.trip_id = tr.trip_id
group by pa.id having count(dest) >1
order by count(tr) desc
limit 1;


select pa.Phone_number, pa.l_name, pa.Email
from passenger pa join counttrips on pa.id = counttrips.pass_id, counttripsdists
where counttrips.countbydate > counttripsdists.countbydest;


-- ‫‪11‬‬‫)‬‫مسافرانی‬ ‫که‬ ‫حداکثر‬ ‫‪2‬‬ ‫سفر‬ ‫حداقل‬ ‫‪1‬‬ ‫ساعته‬ ‫داشته‬ ‫اند‬ ‫و‬ ‫تا‬ ‫به‬ ‫حال‬ ‫در‬ ‫مجموع‬ ‫بیشتر‬ ‫از‬ ‫‪100‬‬
-- ‫هزار‬‫تومان‬ ‫کیف‬ ‫پولشون‬ ‫رو‬ ‫شارژ‬ ‫کردند‪.‬‬
create view charged_more100000 as
select pa.ID AS PASS_ID
from passenger pa, User_Transaction ut
where ut.user_id = pa.id 
group by pa.id having sum(ut.amount) >100000;


create view longtriper as
SELECT User_ID AS PASS_ID
FROM TRIP
GROUP BY User_ID
HAVING COUNT(Trip_ID) <= 2 AND SUM(EXTRACT(HOUR FROM (Time_end - Time_start))) >= 1;

SELECT PA.*
FROM longtriper LT JOIN charged_more100000 CM ON LT.PASS_ID = CM.PASS_ID JOIN PASSENGER PA ON PA.ID = CM.PASS_ID;


-- ‫‪12‬‬‫)‬‫نسبت‬ ‫گزارش‬ ‫های‬ ‫تخلف‬ ‫پیگیری‬ ‫شده‬ ‫به‬ ‫کل‬ ‫گزارشات‬ ‫چند‬ ‫درصد‬ ‫است؟‬
select ((count(v1) / (count(v))) / 100) as followed_violations
from violation v, violation v1
where v1.Follow_up = 'FOLLOWED';


-- ‫‪13‬‬‫)‬‫تعداد‬ ‫کارمندانی‬ ‫که‬ ‫مدرک‬ ‫کارشناسی‬ ‫و‬ ‫یا‬ ‫باالتر‬ ‫دارند‬ ‫و‬ ‫بیش‬ ‫از‬ ‫‪۵‬‬ ‫میلیون‬ ‫تومان‬ ‫حقوق‬ ‫می‬ ‫گیرند‬
-- ‫و‬‫حداقل‬ ‫‪۱‬‬ ‫سال‬ ‫در‬ ‫بکسی‬ ‫سابقه‬ ‫کار‬ ‫دارند‬ ‫چند‬ ‫عدد‬ ‫است؟‬ ‫(به‬ ‫جز‬ ‫مدیران‬ ‫دپارتمان)‬
SELECT COUNT(e1.ID)
FROM EMPLOYEE e1
WHERE (e1.Education LIKE '%کارشناسی%'
   OR e1.Education LIKE '%کارشناسی ارشد%'
   OR e1.Education LIKE '%دکترا%'
   OR e1.Education LIKE '%فوق دکترا%'
   OR e1.Education LIKE '%لیسانس%'
   OR e1.Education LIKE '%فوق لیسانس%') and e1.salary > 5000000 and e1.Position_dept <> 'MANAGER' and
   EXTRACT(YEAR FROM AGE(CURRENT_DATE, e1.Start_date)) >= 1
   ;
   

-- ‫‪14‬‬‫)‬‫‪3‬‬ ‫تا‬ ‫از‬ ‫راننده‬ ‫های‬ ‫ماشین‬ ‫فرسوده‬ ‫که‬ ‫کمترین‬ ‫تعداد‬ ‫سفر‬ ‫با‬ ‫پرداخت‬ ‫نقدی‬ ‫را‬ ‫داشته‬ ‫اند‬ ‫را‬ ‫در‬
-- ‫نظر‬‫بگیرید‪.‬‬ ‫مطلوب‬ ‫است‬ ‫مجموع‬ ‫آن‬ ‫مبالغ‬ ‫‪،‬‬ ‫نام‬ ‫راننده‬ ‫و‬ ‫نام‬ ‫ماشین‪.‬‬ ‫(ماشین‬ ‫های‬ ‫فرسوده‬ ‫تاریخ‬
-- ‫تولید‬‫آن‬ ‫ها‬ ‫قبل‬ ‫از‬ ‫سال‬ ‫‪2009‬‬ ‫میالدی‬ ‫هست)‬
select sum(udt.amount) as total_amount, v.name, dr.f_name, dr.l_name
from vehichle v, trip tr, UserToDriverTransaction udt, driver dr
where (v.Year - 2009) < 0 and tr.trip_id = udt.trip_id and udt.Pay_type = 'CASH' and v.driver_id = tr.driver_id and tr.driver_id = dr.id
group by dr.id, v.name, dr.f_name, dr.l_name
order by count(tr) asc
limit 3;



-- ‫‪15‬‬‫)‬‫نسبت‬ ‫تعداد‬ ‫سفر‬ ‫های‬ ‫لغو‬ ‫شده‬ ‫(بکسی‬ ‫و‬ ‫بکسی‬ ‫بانوان)‬ ‫در‬ ‫محله‬ ‫شهرری‬ ‫تهران‬ ‫به‬ ‫سفر‬ ‫های‬
-- ‫موفق‬‫در‬ ‫این‬ ‫محله‬ ‫چقدر‬ ‫است؟‬
create view notcanceled_trips as
select count(tr.trip_id) as trip_id
from trip tr, Trip_person tp, trip_person dest, DRIVER dr
where dr.id = tr.driver_id and tp.trip_id = tr.trip_id and dest.Trip_ID = tp.Trip_ID and ( (dest.Destination like '%تهران%شهر ری%') or (tr.Start_location like '%تهران%شهر ری%' )) and tr.Canceled = false and (dr.service_type = 'BAXI' or dr.service_type='B_WOMEN') ;

create view canceled_trips as
select count(tr.trip_id) as trip_id
from trip tr, Trip_person tp, trip_person dest, driver dr
where dr.id = tr.driver_id and tp.trip_id = tr.trip_id and dest.Trip_ID = tp.Trip_ID and ( (dest.Destination like '%تهران%شهر ری%') or (tr.Start_location like '%تهران%شهر ری%' )) and tr.Canceled = true and (dr.service_type = 'BAXI' or dr.service_type='B_WOMEN');


select (count(canceled_trips) / (count(notcanceled_trips)+1)) / 100 as successful_trips
from notcanceled_trips, canceled_trips;


-- ‫‪16‬‬‫)‬‫‪۱۰‬‬ ‫سریع‬ ‫ترین‬ ‫پیک‬ ‫موتور‬ ‫بکسی‬ ‫را‬ ‫برای‬ ‫دریافت‬ ‫جایزه‬ ‫‪۱۰‬‬ ‫میلیونی‬ ‫لیست‬ ‫کنید‪.‬‬ ‫(راهنمایی‪‌:‬‬
-- ‫نسبت‬‫به‬ ‫زمان‬ ‫پیش‬ ‫بینی‬ ‫شده‬ ‫سریع‬ ‫تر‬ ‫به‬ ‫مقصد‬ ‫رسیده‬ ‫اند)‬
SELECT
    tr.Trip_ID AS tripid,
    tr.Distance,
    Time_start,
    Time_end,
    SUM(Distance / EXTRACT(EPOCH FROM (Time_end - Time_start))) AS Speed
FROM
    TRIP tr
JOIN
    driver dr ON dr.id = tr.trip_id
GROUP BY
    tr.Trip_ID, 
    tr.Distance,
    Time_start,
    Time_end
ORDER BY
    SUM(Distance / EXTRACT(EPOCH FROM (Time_end - Time_start))) DESC
limit 10;



-- ‫‪17‬‬‫)‬‫میزان‬ ‫سود‬ ‫بکسی‬ ‫از‬ ‫جمع‬ ‫مبالغ‬ ‫همه‬ ‫سرویس‬ ‫هایی‬ ‫که‬ ‫در‬ ‫ماهی‬ ‫که‬ ‫بیشترین‬ ‫میزان‬ ‫ثبت‬ ‫نام‬
-- ‫کاربر‬‫عادی‬ ‫در‬ ‫اپلیکیشن‬ ‫بکسی‬ ‫صورت‬ ‫گرفته‬ ‫است‬ ‫چقدر‬ ‫از‬ ‫میزان‬ ‫سودی‬ ‫که‬ ‫از‬ ‫جمع‬ ‫مبالغ‬ ‫همه‬
-- ‫سرویس‬‫ها‬ ‫در‬ ‫ماه‬ ‫اول‬ ‫فعالیت‬ ‫خود‬ ‫داشته‬ ‫بیشتر‬ ‫است؟‬
CREATE VIEW MOST_SIGNUP AS
SELECT EXTRACT(YEAR FROM Reg_date) AS syear,
       EXTRACT(MONTH FROM Reg_date) AS smonth,
       COUNT(*) AS approval_count
FROM PASSENGER
GROUP BY syear, smonth
ORDER BY approval_count DESC
LIMIT 1;


CREATE VIEW fmonth_profit as
SELECT
    EXTRACT(YEAR FROM T_Date) AS fyear,
    EXTRACT(MONTH FROM T_Date) AS fmonth,
    SUM(Amount) AS total_profit
FROM Baxi_Wallet
GROUP BY fyear, fmonth
ORDER BY fyear ASC, fmonth ASC
LIMIT 1;

CREATE VIEW most_SIGNUP_PROFIT AS
SELECT SUM(ba.Amount) AS total_profit
FROM 
	MOST_SIGNUP ms, Baxi_Wallet ba
WHERE  
	ms.syear = EXTRACT(YEAR FROM ba.T_Date) AND
	ms.smonth = EXTRACT(MONTH FROM ba.T_Date)
GROUP BY 
	ms.syear, ms.smonth;
	
	

SELECT (mp.total_profit - fp.total_profit) AS profit_diff 
FROM most_SIGNUP_PROFIT mp, fmonth_profit fp;


-- ‫‪18‬‬‫)‬‫لیست‬ ‫همه‬ ‫ماشین‬ ‫هایی‬ ‫که‬ ‫راننده‬ ‫آن‬ ‫ها‬ ‫خانم‬ ‫است‬ ‫و‬ ‫در‬ ‫شعاع‬ ‫دو‬ ‫کیلومتری‬ ‫نقطه‬
-- ‫‪lng:51.3749‬‬‫‪lat:35.7819,‬‬ ‫قرار‬ ‫دارند‬ ‫و‬ ‫به‬ ‫بکسی‬ ‫بدهکاری‬ ‫ندارند‬ ‫و‬ ‫ظرفیت‬ ‫ماشین‬ ‫آن‬ ‫ها‬ ‫‪3‬‬ ‫و‬ ‫یا‬
-- ‫بیشتر‬‫است‬ ‫و‬ ‫آماده‬ ‫دریافت‬ ‫سرویس‬ ‫بکسی‬ ‫بانوان‬ ‫هستند‬ ‫را‬ ‫برگردانید‪.‬‬
CREATE VIEW CARS_WITH_3CAP AS
SELECT V.Driver_ID AS driver_id
FROM CAR CA JOIN VEHICHLE V ON V.PLAQUE = CA.PLAQUE
WHERE V.Capacity >= 3;


SELECT dr.ID, dr.F_name, dr.L_name, dr.Latitude, dr.Longitude
FROM Driver dr, driver_wallet dw JOIN Trip tr ON tr.driver_id = dw.id, CARS_WITH_3CAP car3
WHERE
    6371 * ACOS(
        COS(RADIANS(35.7819)) * COS(RADIANS(dr.Latitude)) *
        COS(RADIANS(dr.Longitude) - RADIANS(51.3749)) +
        SIN(RADIANS(35.7819)) * SIN(RADIANS(dr.Latitude))
    ) <= 2 AND 
	dr.sex = 'f' AND dr.id = dw.id AND dw.Balance >= 0 AND
	tr.Trip_Date = CURRENT_DATE AND tr.Time_end <> NULL AND car3.driver_id = dr.id;


-- ‫‪19‬‬‫)‬‫لیست‬ ‫خانم‬ ‫هایی‬ ‫که‬ ‫در‬ ‫همه‬ ‫روزها‬ ‫به‬ ‫غیر‬ ‫از‬ ‫روز‬ ‫های‬ ‫زوج‬ ‫هفته‬ ‫اخیر‬ ‫یا‬ ‫از‬ ‫سرویس‬ ‫بکسی‬
-- ‫بانوان‬‫یا‬ ‫بکسی‬ ‫(سفر‬ ‫معمولی)‬ ‫استفاده‬ ‫کرده‬ ‫اند‬ ‫و‬ ‫حداقل‬ ‫‪1‬‬ ‫سفر‬ ‫داشته‬ ‫اند‬ ‫که‬ ‫راننده‬ ‫آن‬ ‫در‬ ‫مجموع‬
-- ‫بیشتر‬‫از‬ ‫‪100‬‬ ‫هزار‬ ‫تومان‬ ‫از‬ ‫کیف‬ ‫پول‬ ‫خود‬ ‫برداشت‬ ‫کرده‬ ‫است‪.‬‬
create view picked_more100000 as
select dt.Driver_ID as driver_id
from Driver_Transaction dt
where dt.Transaction_Type = 'WITHDRAW'
group by dt.Driver_ID having sum(dt.amount) > 100000;

create view sunday_trips as 
SELECT tr.Trip_ID, pa.ID as user_id
FROM TRIP tr, passenger pa
WHERE EXTRACT(DOW FROM Trip_Date) = 0 AND Trip_Date BETWEEN (CURRENT_DATE - INTERVAL '1 week') AND CURRENT_DATE;

create view wednesday_trips as 
SELECT tr.Trip_ID, pa.ID as user_id
FROM TRIP tr, passenger pa
WHERE EXTRACT(DOW FROM Trip_Date) = 3 AND Trip_Date BETWEEN (CURRENT_DATE - INTERVAL '1 week') AND CURRENT_DATE;

create view monday_trips as 
SELECT tr.Trip_ID, pa.ID as user_id
FROM TRIP tr, passenger pa
WHERE EXTRACT(DOW FROM Trip_Date) = 1 AND Trip_Date BETWEEN (CURRENT_DATE - INTERVAL '1 week') AND CURRENT_DATE;

create view friday_trips as 
SELECT tr.Trip_ID, pa.ID as user_id
FROM TRIP tr, passenger pa
WHERE EXTRACT(DOW FROM Trip_Date) = 1 AND Trip_Date BETWEEN (CURRENT_DATE - INTERVAL '1 week') AND CURRENT_DATE;


select pa
from passenger pa join trip tr on tr.User_ID = pa.ID , sunday_trips st, wednesday_trips wt, monday_trips mt, friday_trips ft, picked_more100000 pm
where pa.sex = 'f' and tr.Trip_ID in (st.Trip_ID) and
	tr.Trip_ID in (wt.Trip_ID) and tr.Trip_ID in (mt.Trip_ID) and 
	tr.Trip_ID in (ft.Trip_ID) 
group by pa having count(pm.driver_id = tr.driver_id) >= 1;
	