-- 11.	প্রতিটি vehicle_type অনুযায়ী কয়টা গাড়ি চুরি হয়েছে তা বের করো।
SELECT 
    vehicle_type, COUNT(vehicle_id) total_vehicles
FROM
    stolen_vehicles
WHERE
    vehicle_type IS NOT NULL
GROUP BY vehicle_type
ORDER BY total_vehicles DESC;

-- 12.	color অনুযায়ী গাড়ির সংখ্যা বের করো এবং descending order এ সাজাও।
SELECT 
    color, COUNT(vehicle_id) total_vehicles
FROM
    stolen_vehicles
WHERE
    color IS NOT NULL
GROUP BY color
ORDER BY total_vehicles DESC;

-- 13.	কোন বছরে সবচেয়ে বেশি গাড়ি চুরি হয়েছে (model_year অনুযায়ী count)?
SELECT 
    YEAR(date_stolen) stolen_year, COUNT(model_year) model_year
FROM
    stolen_vehicles
GROUP BY stolen_year
ORDER BY model_year DESC
LIMIT 1;

-- 14.	কোন কোন make_id এর গাড়ি সবচেয়ে বেশি চুরি হয়েছে?
SELECT 
    make_id, COUNT(vehicle_id) total_stolen
FROM
    stolen_vehicles
WHERE
    make_id IS NOT NULL
GROUP BY make_id
ORDER BY total_stolen DESC
LIMIT 1;

-- 15.	locations টেবিল join করে প্রতিটি region অনুযায়ী কয়টা গাড়ি চুরি হয়েছে বের করো।
SELECT 
    l.region, COUNT(sv.vehicle_id) total_stolen
FROM
    locations l
        JOIN
    stolen_vehicles sv ON l.location_id = sv.location_id
GROUP BY l.region
ORDER BY total_stolen DESC;

-- 16.	make_details join করে প্রতিটি make_name অনুযায়ী চুরি হওয়া গাড়ির সংখ্যা বের করো।
SELECT 
    md.make_name, COUNT(sv.vehicle_id) total_stolen
FROM
    make_details md
        JOIN
    stolen_vehicles sv ON md.make_id = sv.make_id
GROUP BY md.make_name
ORDER BY total_stolen DESC;

-- 17.	প্রতিটি region এর গড় population দেখাও।
SELECT 
    region, ROUND(AVG(population), 2) avg_population
FROM
    locations
GROUP BY region
ORDER BY avg_population DESC ;

-- 18.	কোন country থেকে সবচেয়ে বেশি গাড়ি চুরি হয়েছে বের করো।\
SELECT 
    l.country, COUNT(sv.vehicle_id) total_stolen
FROM
    locations l
        JOIN
    stolen_vehicles sv ON l.location_id = sv.location_id
GROUP BY l.country
ORDER BY total_stolen DESC
LIMIT 1;

-- 19.	২০২২ সালের ফেব্রুয়ারিতে চুরি হওয়া সব গাড়ি দেখাও।

SELECT 
    *
FROM
    stolen_vehicles
WHERE
    YEAR(date_stolen) = 2022
        AND MONTH(date_stolen) = 2;

-- 20.	গাড়ির রঙ অনুযায়ী গড় model_year বের করো।

SELECT 
    color, ROUND(AVG(model_year), 2) avg_model_year
FROM
    stolen_vehicles
    where color is not null
GROUP BY color;

-- 21.	কোন make_name এর গাড়ি সবচেয়ে বেশি চুরি হয়েছে (join সহ)?
SELECT 
    md.make_name, COUNT(sv.vehicle_id) total_stolen
FROM
    make_details md
        JOIN
    stolen_vehicles sv ON md.make_id = sv.make_id
GROUP BY md.make_name
ORDER BY total_stolen DESC;

-- 22.	প্রতিটি বছরে (model_year) কোন vehicle_type সবচেয়ে বেশি চুরি হয়েছে তা বের করো।

select model_year, vehicle_type, total_stolen
from (
		select model_year,vehicle_type,
				count(vehicle_id) total_stolen,
                rank() over(partition by model_year order by count(vehicle_id) desc) rnk
		from stolen_vehicles
                where vehicle_type is not null
        group by model_year,vehicle_type) asd
where rnk = 1 
order by total_stolen desc;

-- 23.	প্রতিটি region এ সবচেয়ে বেশি চুরি হওয়া color বের করো।

select region,color,total_stolen from (
select l.region,sv.color,count(sv.vehicle_id) total_stolen,
rank() over(partition by l.region order by count(sv.vehicle_id) desc) rnk
from locations l join stolen_vehicles sv 
on l.location_id = sv.location_id
group by l.region,sv.color ) a 
where rnk = 1 
order by total_stolen desc ;

-- 24.	CTE ব্যবহার করে ২০২২ সালের চুরি হওয়া গাড়ির মোট সংখ্যা বের করো।

with a as (
			select date_stolen stolen_year, vehicle_id
            from stolen_vehicles
            where year(date_stolen) = 2022
		)
select count(vehicle_id) total_stolen from a ;

-- 27.	এমন গাড়িগুলোর তালিকা দেখাও যাদের model_year > 2005 এবং color = 'Silver'।

SELECT DISTINCT
    md.make_name
FROM
    stolen_vehicles sv
        JOIN
    make_details md ON md.make_id = sv.make_id
WHERE
    sv.model_year > 2015
        AND sv.color = 'Silver'
;

-- 28.	প্রতিটি region অনুযায়ী ৩টি সবচেয়ে বেশি চুরি হওয়া make_name বের করো (RANK() ব্যবহার করে)

with a as (
	select md.make_name,l.region,count(sv.vehicle_id) totala_stolen,
		rank() over(partition by l.region order by count(sv.vehicle_id) desc) rnk 
	from make_details md join stolen_vehicles sv 
		on md.make_id = sv.make_id
	join locations l
		on l.location_id = sv.location_id 
	group by md.make_name,l.region
)
select make_name,region,rnk from a 
where rnk <= 3
;
-- 29.	গাড়ির color distribution percentage বের করো (total এর শতাংশ হিসেবে)।

select color,
		concat(round((count(vehicle_id) / 
			(select count(vehicle_id) from stolen_vehicles)*100),2),'%') dis_percent
from stolen_vehicles
where color is not null
group by color
order by dis_percent desc ;

-- 30.	location_id অনুযায়ী average model_year বের করো এবং শুধু সেগুলো দেখাও যেখানে গড় < 2010।

with a as (
select l.location_id, round(avg(sv.model_year)) avg_model_year
from locations l join stolen_vehicles sv
on l.location_id = sv.location_id
group by l.location_id )

select location_id,avg_model_year from a
where avg_model_year < 2010
order by avg_model_year desc
;







