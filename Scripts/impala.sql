INVALIDATE METADATA;

SELECT desc_distrito, desc_barrio, sum(espanoleshombres), sum(espanolesmujeres), sum(extranjeroshombres), sum(extranjerosmujeres)
FROM datos_padron.padron_parquet2 
GROUP BY desc_distrito, desc_barrio;


SELECT desc_distrito, desc_barrio, ((sum(espanolesmujeres) + sum(extranjerosmujeres)) / (sum(espanoleshombres) + sum(extranjeroshombres))) MujeresEntreHombres, 
(sum(espanolesmujeres) / sum(extranjerosmujeres)) EspañolasEntreExtranjeras
FROM datos_padron.padron_parquet2 
GROUP BY desc_distrito, desc_barrio;
SELECT desc_distrito, desc_barrio, sum(espanoleshombres), sum(espanolesmujeres), sum(extranjeroshombres), sum(extranjerosmujeres)
FROM datos_padron.padron_particionado 
GROUP BY desc_distrito, desc_barrio 
HAVING desc_distrito=("CENTRO") OR desc_distrito=("LATINA")
    OR desc_distrito=("CHAMARTIN") OR desc_distrito=("TETUAN")
    OR desc_distrito=("VICALVARO") OR desc_distrito=("BARAJAS");


SELECT desc_distrito, desc_barrio, sum(espanoleshombres), sum(espanolesmujeres), sum(extranjeroshombres), sum(extranjerosmujeres)
FROM datos_padron.padron_particionado
WHERE desc_distrito IN ("CENTRO", "LATINA", "CHAMARTIN", "TETUAN", "VICALVARO", "BARAJAS")
GROUP BY desc_distrito, desc_barrio;


SELECT desc_distrito, desc_barrio, max(espanoleshombres), min(espanolesmujeres), avg(extranjeroshombres), sum(extranjerosmujeres), count(desc_barrio)
FROM datos_padron.padron_particionado
WHERE desc_distrito IN ("CENTRO", "LATINA", "CHAMARTIN", "TETUAN", "VICALVARO", "BARAJAS")
GROUP BY desc_distrito, desc_barrio;


