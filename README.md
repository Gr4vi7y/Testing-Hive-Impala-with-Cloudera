# **Probando Hive/Impala con Cloudera:**

Este repositorio contiene una práctica de Apache Hive y Apache Impala. La práctica ha sido efectuada en una máquina virtual de Cloudera 5.5.0 en VMWare Workstation 14 Pro. La finalidad de esta práctica es familiarizarse con ambas tecnologias y conocer las diferencia que existen entre ambas tanto a nivel teorico como práctico.

*Para leer este documento en otros idiomas: [English](README.md) [Spanish](README.es.md)*

## **Tabla de Contenidos**
  - [1. Introducción](#1.-Introducción)
  - [2. Contenido del Repositorio](#2.-Contenido-del-Repositorio)
  - [3. Práctica Apache Hive](#3.-Práctica-Apache-Hive)
      - [3.1. Cuestiones](#3.1.-Cuestiones)
      - [3.2. Ejercicios](#3.2.-Ejercicios)
      - [3.3. Solución](#3.3.-Solución)
      - [3.4. Problemas](#3.4.-Problemas)
  - [4. Práctica Apache Impala](#4.-Práctica-Apache-Impala)
      - [4.1. Cuestiones](#4.1.-Cuestiones)
      - [4.2. Ejercicios](#4.2.-Ejercicios)
      - [4.3. Solución](#4.3.-Solución)

## **1. Introducción**

Partimos de un dataset del padrón del Ayuntamiento de Madrid con una serie de errores. Por un lado tenemos dos campos (*DESC_BARRIO, DESC_DISTRITO*) en el que se han incluido espacios vacíos innecesarios y que por lo tanto ocupan espacio en disco de forma innecesaria. Por otra parte tenemos cuatro campos (*EspanolesHombres, EspanolesMujeres, ExtranjerosHombres, ExtranjerosMujeres*) en los que para valores 0 son campos vacíos.

Si partimos del archivo original (`Rango_Edades_Seccion_202012.csv`) e intentamos leerlo, el primer problema que tendremos será que no se nos reconocerá la letra **Ñ**. Esto es debido al tipo de codificación usado. Esto no se consigue solucionar indicándole la codificación a Hive, y la única manera de solucionarlo es modificar la codificación ANSI original a UTF-8 en un archivo nuevo (`Rango_Edades_Seccion_202012v2.csv`). 

Una vez tenemos el archivo en la codificación correcta, podrá ser leído por medio de hive sin obtener errores con el carácter **Ñ**. A partir de este punto continuaremos trabajando los ejercicios propuestos.

## **2. Contenido del Repositorio**

El esquema del repositorio es el siguiente:

```
├── Dataset
    ├── Rango_Edades_Seccion_202012.csv
    └── Rango_Edades_Seccion_202012v2.csv
└── Scripts
    ├── hive.hql
    └── impala.sql
```

* dataset/ directorio. Contiene el dataset con dos codificaciones
* scripts/ directorio. Contiene los scripts de Hive e Impala.
* Rango_Edades_Seccion_202012.csv. Archivo original con datos del padrón de Madrid de 2020. Se ha obtenido de la web del ayuntamiento de Madrid (https://datos.madrid.es/egob/catalogo/200076-1-padron.csv). Tiene codificación ANSI.
* Rango_Edades_Seccion_202012v2.csv. Archivo modificado a partir del original con codificación UTF-8
* hive.hql. Script para la ejecución de los ejercicios de la práctica de Hive.
* impala.sql. Script para la ejecución de los ejercicios de la práctica de Impala.

## **3. Práctica Apache Hive**

Para efectuar esta práctica utilizaremos el asistente SQL de Databases y Data Warehouses, Apache Hue. Este asistente viene incluido con la distribución Cloudera e incluye interpretes tanto para Apache Hive como para Apache Impala, además de muchos otros extras como poder consultar la metastore y el sistema de archivos HDFS.

### **3.1. Cuestiones**

1. **¿Qué es Apache Hive?**    
    Se trata de una infraestructura de almacenamiento de datos construida sobre Hadoop para proporcionar agrupación, consulta, y análisis de datos.

2. **Cita algunas razones por las que no reemplazarías una RDBM por Hive**    
    Latencia, falta de transaccionalidad, falta de acciones como update o delete.

3. **¿Cuáles son los beneficios de Hive y Hadoop sobre DWH tradicionales?**    
    Bajo coste y alta escalabilidad.
    
4. **¿Qué datos almacena el metastore de Hive?**    
    Metadatos sobre las tablas hive.

5. **Cuando hacemos una consulta en Hive sobre una tabla, ¿dónde reside físicamente esa tabla?**    
    HDFS. Las tablas son directorios en HDFS.
    
6. **¿Qué comando se usa para cambiar el foco a otra tabla en hive?**    
    USE
    
7. **¿Cuál es el comando usado para cambiar el resultado de varias queries en un solo resultado?**    
    UNION ALL
    
8. **¿Cuál es el directorio por defecto (en linux) del warehouse de Hive?**    
    /user/hive/warehouse
    
9. **¿Dónde se almacenan las tablas particionadas en Hive?**    
    En subdirectorios.
    
10. **¿Cuál es la diferencia entre el tipo de datos SequenceFile y Parquet?**    
    Parquet almacena en columna y SequenceFile (textfile). Parquet es un formato de almacenamiento en columnas de código abierto para Hadoop.

11. **¿Cuál es la diferencia entre Arrays y Maps?**    
    A los arrays se les referencia por índice o número y a los Maps por clave o etiqueta.

12. **¿Cuál es la query más rápida en Hive?**    
    La que solo accede a metadatos, es decir, >Show tables;

13. **Investigar y entender la diferencia de incluir la palabra LOCAL en el comando LOAD DATA**    
    LOAD DATA LOCAL INPATH: mueve datos de nuestro sistema de ficheros local a la tabla.    
    LOAD DATA INPATH: mueve datos de un fichero en el sistema de archivos HDFS a la tabla.

14. **¿Qué es CTAS?**    
    Son las siglas de "Create Table As Select". Es un método de creación de tablas al vuelo por medio de select.

15. **Investigar en que consiste el formato columnar parquet y las ventajas de trabajar con este tipo de formatos.**    
    A diferencia de los formatos de archivos txt, csv, ORC... que son formatos de archivos basados en registros, Parquet se trata de un formato open-source de almacenamiento de datos de tipo columnar para Hadoop. Fue creado para poder disponer de un formato libre de compresión y codificación eficiente. Las mayores ventajas de este formato son:    
    
    -La compresión por columnas es eficiente y ahorra mucho espacio de almacenamiento.    
    -Se pueden aplicar técnicas de compresión específicas a un tipo de dato, ya que los valores de las columnas tienden a ser del mismo tipo.    
    -Las consultas que obtienen valores de una columna específica no necesita leer los datos de la fila completa, lo que mejora el rendimiento.    
    -Se pueden aplicar diferentes técnicas de codificación a diferentes columnas.    

### **3.2. Ejercicios**

1. A partir de los datos (CSV) del Padrón de Madrid (`Rango_Edades_Seccion_202012v2.csv`) llevar a cabo lo siguiente:    
    a. Crear la base de datos **datos_padron**    
    b. Crear tabla padron_txt con todos los campos del fichero CSV y cargar los datos mediante el comando *LOAD DATA LOCAL INPATH*. La tabla tendrá formato texto y tendrá como delimitador de campo el carácter **;** y los campos estarán encerrados en comillas dobles **”** , ademas se deberá omitir la cabecera del fichero de datos al crear la tabla.    
    c. Crear tabla padron_txt2 que haga trim sobre los datos de algunas columnas con la finalidad de eliminar los espacios en blanco innecesarios.
    d. Crear tabla padron_txt_reg que lea los datos correctamente por medio de expresiones regulares.
    e. Crear tabla padron_txt2_reg en formato parquet a partir de la tabla padron_txt_reg y que tenga los valores Null sustituidos por 0.

2. Trabajando con formato Parquet:    
    a. Crear tabla padron_parquet (cuyos datos serán almacenados en el formato columnar parquet) a partir de la tabla padron_txt mediante un CTAS.    
    b. Crear tabla padron_parquet2 (cuyos datos serán almacenados en el formato columnar parquet) a partir de la tabla padron_txt2 mediante un CTAS.    
    c. Comparar el tamaño de los ficheros de los datos de las tablas padron_txt (CSV) y padron_parquet (alojados en hdfs cuya ruta se puede obtener de la propiedad location de cada tabla por ejemplo haciendo SHOW CREATE TABLE)    
    d. Comparar el tamaño de los ficheros de los datos de las tablas padron_txt (CSV), padron_txt2, padron_parquet y padron_parquet2 (alojados en hdfs cuya ruta se puede obtener de la propiedad location de cada tabla por ejemplo haciendo SHOW CREATE TABLE)    
    
3. Particionamiento    
    a. Crear tabla padron_particionado particionada por los campos DESC_DISTRITO y DESC_BARRIO cuyos datos estén en formato parquet.    
    b. Insertar datos (en cada partición) dinámicamente en la tabla recién creada a partir de un select de la tabla padron_parquet.    

### **3.3. Solución**

La solución a los ejercicios prácticos de Hive se pueden encontrar en el archivo hive.hql que se encuentra en la carpeta Scripts. Este archivo puede ejecutarse por medio de la terminal o se puede ejecutar por medio de Hue, copiando los diferentes codigos HQL en él.

Para la ejecución por medio de terminal tendremos que ejecutar:

```
 hive -f /home/cloudera/hive.hql
```

Fijarse en que la ruta al archivo es correcta.

### **3.4. Problemas**

Durante el desarrollo de la práctica se han encontrado varios problemas que vamos a detallar a continuación:    

**Expresiones Regulares.**    
En el ejercicio 2d se nos pide la carga de la tabla por medio de expresiones regulares. Los detalles a tener en cuenta son:
    
&nbsp;&nbsp;&nbsp;&nbsp;i)  Debemos utilizar doble barra lateral **\\\\**, en vez de solo una **\** como suele ser habitual en las expresiones regulares.    
&nbsp;&nbsp;&nbsp;&nbsp;ii) Debemos usar la barra lateral **\** antes de **;** , ya que se trata de un carácter reservado en Hive.    
    
**Carga de datos en parquet:**    
Para la carga de datos en el formato parquet no podemos utilizar un archivo de texto plano directamente. Deberemos hacer una tabla intermedia con los datos en formato de texto plano cargados y a partir de ella, cargarlos en la tabla parquet.
    
**Configuraciones de Hive:**    
Durante la ejecución del ejercicio 3, donde se nos pide crear una tabla particionada vamos a encontrarnos con varios errores a tener en cuenta:    
    
&nbsp;&nbsp;&nbsp;&nbsp;i) Durante la creación de la tabla particionada y la carga de esta, debemos tener en cuenta efectuar las siguientes configuraciones (ya incluidas en el Script):    
    
    SET hive.exec.dynamic.partition=true;  ->  Permite la particion dinámica.    
    SET hive.exec.dynamic.partition.mode=non-strict;  ->  Por defecto desactivada para evitar sobreescritura de datos de forma accidenta.    
    SET hive.exec.max.dynamic.partitions = 10000;  ->  Configura el número de particiones máximas.    
    SET hive.exec.max.dynamic.partitions.pernode = 1000;  ->  Configura el número de particiones máximas por nodo.    
        
    SET mapreduce.map.memory.mb = 2048;  ->  Determina la RAM máxima durante el Map.    
    SET mapreduce.reduce.memory.mb = 2048;  ->  Determina la RAM máxima durante el Reduce.    
    SET mapreduce.map.java.opts=-Xmx1800m;  ->  El Map de Hadoop se trata de un proceso Java, y tiene su propia memoria RAM asignada.    
    
&nbsp;&nbsp;&nbsp;&nbsp;Por defecto Hadoop esta configurado con 1024mb de RAM para ejecutar MapReduce. En nuestro caso si no se efectúa esta configuración, nos dará error durante la ejecución del MapReduce.       

&nbsp;&nbsp;&nbsp;&nbsp;ii) En la carga de datos de forma dinámica es muy importante tener en cuenta que, el orden de las columnas seleccionadas con SELECT en la carga, sea exactamente el mismo que el orden utilizado al crear la tabla particionada. Además, los valores por los que se efectúa la partición, en nuestro caso *DESC_DISTRITO* y *DESC_BARRIO*, sean los ultimos.
    
## **4. Práctica Apache Impala**

### **4.1. Cuestiones**

1. **¿Qué es Apache Impala?**    
    Se trata de un motor de consultas SQL que corre sobre Hadoop. Permite consultas SQL de baja latencia a datos almacenados en HDFS y Apache HBase sin necesidad de movimiento o transformación de los datos. Impala está integrada con Hadoop para utilizar los mismos archivos y formato de datos, metadatos, seguridad y frameworks de gestión de recursos utilizados por MapReduce, Apache Hive, Apache Pig y otro software de Hadoop.    
2. **¿En qué se diferencia de Hive?**    
    En el caso de Impala, funciona mejor en consultas más ligeras donde prime a la velocidad respecto a la fiabilidad, ya que cualquier fallo en el nodo o el proceso obligaría a lanzar la consulta desde el principio. Por otro lado, Hive es mejor para trabajos pesados de tipo ETL (Extract, Transform and Load) donde no nos interesa tanto la velocidad como la robustez de la ejecución, ya que tiene alta tolerancia a fallos y evita relanzamientos si falla en algún punto.

3. **Comando INVALIDATE METADATA, ¿en qué consiste?**    
    Los cambios realizados en los metadatos desde fuera de Impala, en nuestro caso Hive, son desconocidos para Impala. Por esa razón existe este comando que hace una actualización de los metadatos de la caché.

### **4.2. Ejercicios**

1. Hacer invalidate metadata en Impala de Base de datos datos_padron
2. Calcular el total de EspanolesHombres, EspanolesMujeres, ExtranjerosHombres y ExtranjerosMujeres agrupado por DESC_DISTRITO y DESC_BARRIO.
    i. Llevar a cabo la consulta en Hive en las tablas padron_txt y padron_parquet. ¿Alguna conclusión?
    ii. Llevar a cabo la consulta en Impala en las tablas padron_txt y padron_parquet. ¿Alguna conclusión?
    iii. ¿Se percibe alguna diferencia de rendimiento entre Hive e Impala?
    
3. Calcular el total de EspanolesHombres, EspanolesMujeres, ExtranjerosHombres y ExtranjerosMujeres agrupado por DESC_DISTRITO y DESC_BARRIO para los distritos CENTRO, LATINA, CHAMARTIN, TETUAN, VICALVARO y BARAJAS.

4. Hacer consultas de agregación (Max, Min, Avg, Count) tal cual el ejemplo anterior con las 3 tablas (padron_txt, padron_parquet y padron_particionado) y comparar rendimientos tanto en Hive como en impala y sacar conclusiones.

### **4.3. Solución**

La solución a los ejercicios propuestos se incluye en el archivo impala.sql de la carpeta Scripts. El archivo al igual que con Hive, se puede ejecutar por medio de Hue, introduciendo los comandos SQL o por medio de la terminal. Para la ejecución por medio de la terminal deberemos ejecutar:

```
$ impala-shell -f /home/cloudera/impala.sql
```
Fijarse en que la ruta al archivo es correcta.




