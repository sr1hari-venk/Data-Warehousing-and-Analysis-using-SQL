---CREATE tables (Dimensions & fact):

CREATE TABLE dim_time
(
	time_id NUMBER(4) GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1,
	sample_date DATE NOT NULL,
	time VARCHAR2(10) NOT NULL,
	week NUMBER(4) NOT NULL,
	month VARCHAR2(10) NOT NULL,
	year NUMBER(5) NOT NULL,
	PRIMARY KEY (time_id)
);

CREATE TABLE dim_determinand
(
	determinandnotation NUMBER(20),
	determinandlabel VARCHAR2(40),
	determinanddefinition VARCHAR2(80),
	determinandunitlabel VARCHAR2(10),
	PRIMARY KEY (determinandnotation)
);

CREATE TABLE dim_sample
(
	sample_id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1,
	samplevalid VARCHAR2(200),
	samplesamplingpoint VARCHAR2(200),
	samplesamplingpointnotation VARCHAR2(200),
	samplesamplingpointlabel VARCHAR2(50),
	sampleiscompliancesample VARCHAR2(6),
	samplepurposelabel VARCHAR2(60),
	samplesamplingpointeasting NUMBER(10),
	samplesamplingpointnorthing NUMBER(10),
	PRIMARY KEY (sample_id)
);

CREATE TABLE fact_watersensor
(
	id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1,
	sample_id NUMBER, 
	time_id NUMBER,
	determinandnotation NUMBER(20),
	samplesampledmaterialtypelabel VARCHAR2(60),
	result Number,
	PRIMARY KEY (id),
	FOREIGN KEY (sample_id) references dim_sample(sample_id) on delete CASCADE,
	FOREIGN KEY (time_id) references dim_time(time_id) on delete CASCADE,
	FOREIGN KEY (determinandnotation) references dim_determinand(determinandnotation) on delete CASCADE
);

---Transfer data from Dataset to tables:
---Sample Dimension
declare
Cursor cr is
Select "@id","samplesamplingPoint","samplesamplingPointnotation","samplesamplingPointlabel",
"sampleisComplianceSample","samplepurposelabel","samplesamplingPointeasting",
"samplesamplingPointnorthing" from "water_quality";
begin
for citer in cr loop
insert into DIM_SAMPLE(SAMPLEVALID,SAMPLESAMPLINGPOINT,SAMPLESAMPLINGPOINTNOTATION,SAMPLESAMPLINGPOINTLABEL,
SAMPLEISCOMPLIANCESAMPLE,SAMPLEPURPOSELABEL,SAMPLESAMPLINGPOINTEASTING,SAMPLESAMPLINGPOINTNORTHING)
values (citer."@id",citer."samplesamplingPoint",citer."samplesamplingPointnotation",citer."samplesamplingPointlabel",
DECODE(citer."sampleisComplianceSample",'0', 'FALSE', '1', 'TRUE'),
citer."samplepurposelabel",citer."samplesamplingPointeasting",citer."samplesamplingPointnorthing");
end loop;
end;
---Determinand Dimension
declare
Cursor cr is
Select distinct "determinandnotation","determinandlabel","determinanddefinition","determinandunitlabel" from "water_quality";
begin
for citer in cr loop
insert into DIM_DETERMINAND(DETERMINANDNOTATION,DETERMINANDLABEL,DETERMINANDDEFINITION,DETERMINANDUNITLABEL)
values (citer."determinandnotation",citer."determinandlabel",citer."determinanddefinition",citer."determinandunitlabel");
end loop;
end;
---Time Dimension
declare
Cursor cr is
select "samplesampleDateTime"
from "water_quality";
Dates DATE;
begin
for citer in cr loop
Dates:=TO_DATE(citer."samplesampleDateTime",'YYYY-MM-DD"T"HH24:MI:SS"Z"');
insert into DIM_TIME(SAMPLE_DATE, TIME, WEEK, MONTH, YEAR)
values(Dates,TO_CHAR(Dates,'HH24:MI:SS'),To_NUMBER(TO_CHAR(Dates, 'WW')),
TO_CHAR(Dates,'Month'),TO_CHAR(Dates,'YYYY'));
end loop;
end;

---Fact Table
Fact Table: 

declare
Cursor cr is
select "ID",SAMPLE_ID,TIME_ID,DETERMINANDNOTATION,"samplesampledMaterialTypelabel","result" FROM "water_quality" wq,DIM_SAMPLE s,DIM_TIME t,DIM_DETERMINAND d
WHERE WQ."ID" = S.SAMPLE_ID AND WQ."ID" = T.TIME_ID AND WQ."determinandnotation" = D.DETERMINANDNOTATION;
begin
for citer in cr loop
insert into FACT_WATERSENSOR(SAMPLE_ID,TIME_ID,DETERMINANDNOTATION,SAMPLESAMPLEDMATERIALTYPELABEL,RESULT)
values(citer.SAMPLE_ID,citer.TIME_ID,citer.DETERMINANDNOTATION,citer."samplesampledMaterialTypelabel",citer."result");
end loop;
end;
---Altering surrogate key columns for dimension tables
ALTER TABLE FACT_WATERSENSOR MODIFY ID NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1);
ALTER TABLE DIM_TIME MODIFY TIME_ID NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1);
ALTER TABLE DIM_SAMPLE MODIFY SAMPLE_ID NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1);

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