--STASTICAL QUERIES----

---1. The list of water sensors measured by type of it by month---------------
SELECT d.DETERMINANDLABEL as SENSOR_TYPE,f.RESULT as MEASUREMENT,t.MONTH FROM fact_watersensor f,dim_time t,dim_determinand d  
where f.time_id = t.time_id and f.DETERMINANDNOTATION = d.DETERMINANDNOTATION order by d.DETERMINANDLABEL 


---2. The number of sensor measurements collected by type of sensor by week

SELECT d.DETERMINANDLABEL as sensor_type,t.WEEK,COUNT(f.RESULT) as No_of_sensor_measurements_by_week  FROM fact_watersensor f,dim_time t,dim_determinand d  
where f.time_id = t.time_id and f.DETERMINANDNOTATION = d.DETERMINANDNOTATION group by t.WEEK,d.DETERMINANDLABEL order by t.WEEK,d.DETERMINANDLABEL; 

---3. The number of measurements made by location by month

SELECT COUNT(f.RESULT) as sensor_measurement_COUNT ,s.SAMPLESAMPLINGPOINTLABEL as LOCATION,t.month FROM fact_watersensor f,dim_time t,dim_sample s  
where f.time_id = t.time_id and f.sample_id = s.sample_id group by t.month,s.SAMPLESAMPLINGPOINTLABEL order by s.SAMPLESAMPLINGPOINTLABEL; 

---4. The average number of measurements covered for PH by year

with ph_total as(
SELECT t.YEAR,COUNT(f.RESULT) as yearly_average   FROM fact_watersensor f,dim_time t,dim_determinand d 
where f.time_id = t.time_id and f.DETERMINANDNOTATION = d.DETERMINANDNOTATION and d.DETERMINANDLABEL = 'pH'  
group by t.YEAR),
overall as(SELECT t.YEAR,COUNT(f.RESULT) as yearly_average   FROM fact_watersensor f,dim_time t,dim_determinand d 
where f.time_id = t.time_id and f.DETERMINANDNOTATION = d.DETERMINANDNOTATION  
group by t.year)
select ph_total.year,ph_total.yearly_average as PH_COUNT,overall.yearly_average as REST_SENSOR_COUNT,round(((ph_total.yearly_average/overall.yearly_average)*100),2) as ph_sensor_avg from ph_total
join overall on ph_total.year=overall.year order by year;

---5. The average value of Nitrate measurements by locations by year

SELECT d.DETERMINANDLABEL as SENSOR_TYPE,s.SAMPLESAMPLINGPOINTLABEL as LOCATION,t.YEAR ,round(AVG(f.RESULT),2) as yearly_average  FROM fact_watersensor f,dim_time t,dim_sample s,dim_determinand d 
where f.time_id = t.time_id and f.sample_id = s.sample_id  and f.DETERMINANDNOTATION = d.DETERMINANDNOTATION and d.DETERMINANDLABEL = 'Nitrite-N'  
group by s.SAMPLESAMPLINGPOINTLABEL,t.year,d.DETERMINANDLABEL order by t.year;
