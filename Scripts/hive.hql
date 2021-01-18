CREATE DATABASE datos_padron;


CREATE TABLE datos_padron.padron_txt(COD_DISTRITO STRING,  DESC_DISTRITO STRING,
					COD_DIST_BARRIO STRING, DESC_BARRIO STRING,
					COD_BARRIO STRING, COD_DIST_SECCION STRING,
					COD_SECCION STRING, COD_EDAD_INT STRING,
					EspanolesHombres STRING, EspanolesMujeres STRING,
					ExtranjerosHombres STRING, ExtranjerosMujeres STRING)

ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
		
WITH SERDEPROPERTIES ("separatorChar"="\;", "quoteChar"="\"") 

STORED AS TEXTFILE
        
TBLPROPERTIES("skip.header.line.count" = "1");

LOAD DATA LOCAL INPATH '/home/cloudera/Rango_Edades_Seccion_202012v2.csv' INTO TABLE datos_padron.padron_txt;



CREATE TABLE datos_padron.padron_txt2 as 
		
SELECT rtrim(desc_distrito) desc_distrito,
	   rtrim(desc_barrio) desc_barrio,
	   cod_distrito, cod_dist_barrio,
	   cod_barrio, cod_dist_seccion, 
	   cod_seccion, cod_edad_int,
	   cast(CASE WHEN (LENGTH(espanoleshombres) = 0) then 0 else espanoleshombres end as int) espanoleshombres,
	   cast(CASE WHEN (LENGTH(espanolesmujeres) = 0) then 0 else espanolesmujeres end as int) espanolesmujeres,
	   cast(CASE WHEN (LENGTH(extranjeroshombres) = 0) then 0 else extranjeroshombres end as int) extranjeroshombres,
	   cast(CASE WHEN (LENGTH(extranjerosmujeres) = 0) then 0 else extranjerosmujeres end as int) extranjerosmujeres

FROM datos_padron.padron_txt;


CREATE TABLE datos_padron.padron_txt_reg (COD_DISTRITO INT,  DESC_DISTRITO STRING,
COD_DIST_BARRIO INT, DESC_BARRIO STRING,
COD_BARRIO INT, COD_DIST_SECCION INT,
COD_SECCION INT, COD_EDAD_INT INT,
EspanolesHombres INT, EspanolesMujeres INT,
ExtranjerosHombres INT, ExtranjerosMujeres INT)

ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'

WITH SERDEPROPERTIES ("input.regex"='"(\\d*)"\;"(.*?)\\s*"\;"(\\d*)"\;"(.*?)\\s*"\;"(\\d*)"\;"(\\d*)"\;"(\\d*)"\;"(\\d*)"\;"(\\d*)"\;"(\\d*)"\;"(\\d*)"\;"(\\d*)"' , "serialization.encoding"="UTF-8")

STORED AS TEXTFILE

TBLPROPERTIES("skip.header.line.count" = "1");

LOAD DATA LOCAL INPATH '/home/cloudera/Rango_Edades_Seccion_202012v2.csv' INTO TABLE `datos_padron`.`padron_txt_reg`;


CREATE TABLE datos_padron.padron_txt2_reg stored as Parquet as
SELECT 
  cod_distrito,
  desc_distrito,
  cod_dist_barrio,
  desc_barrio,
  cod_barrio,
  cod_dist_seccion,
  cod_seccion,
  cod_edad_int,
  coalesce(espanoleshombres, 0) espanoleshombres,
  coalesce(espanolesmujeres, 0) espanolesmujeres,
  coalesce(extranjeroshombres, 0) extranjeroshombres,
  coalesce(extranjerosmujeres, 0) extranjerosmujeres
  
FROM datos_padron.padron_txt_reg;


CREATE TABLE datos_padron.padron_parquet 
STORED AS Parquet AS
SELECT *    
FROM datos_padron.padron_txt;


CREATE TABLE datos_padron.padron_parquet2 
STORED AS Parquet AS
SELECT *    
FROM datos_padron.padron_txt2;


CREATE TABLE datos_padron.padron_particionado(COD_DISTRITO INT, COD_DIST_BARRIO INT, 
                                 COD_BARRIO INT, COD_DIST_SECCION INT,
                                 COD_SECCION INT, COD_EDAD_INT INT,
                                 EspanolesHombres INT, EspanolesMujeres INT,
                                 ExtranjerosHombres INT, ExtranjerosMujeres INT)

PARTITIONED BY(DESC_DISTRITO STRING, DESC_BARRIO STRING)

STORED AS PARQUET;


SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=non-strict;
SET hive.exec.max.dynamic.partitions = 10000;
SET hive.exec.max.dynamic.partitions.pernode = 1000;

SET mapreduce.map.memory.mb = 2048;
SET mapreduce.reduce.memory.mb = 2048;
SET mapreduce.map.java.opts=-Xmx1800m;


FROM datos_padron.padron_parquet2

INSERT OVERWRITE TABLE datos_padron.padron_particionado

PARTITION(DESC_DISTRITO, DESC_BARRIO)

SELECT COD_DISTRITO, COD_DIST_BARRIO, COD_BARRIO, COD_DIST_SECCION, COD_SECCION, COD_EDAD_INT, 
       EspanolesHombres,EspanolesMujeres, ExtranjerosHombres,ExtranjerosMujeres, DESC_DISTRITO, DESC_BARRIO;
