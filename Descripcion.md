# Mini Curso de Uso del R para Periodismo de Datos.

El curso está orientado a aquellas personas del mundo del periodismo que necesitan regularmente hacer anàlisis cuantitativo de datos en su trabajo. La idea es que puedan explotar una parte del arsenal estadistico existente para poder responder las preguntas que sean de su interés a partir de los datos. Por ejemplo, imaginense que queremos dar respuesta a preguntas como si la temporalidad laboral en el sector público está vinculada con los períodos electorales [link](http://nadaesgratis.es/felgueroso/sobe-los-usos-y-abusos-de-la-temporalidad-en-el-sector-publico-los-periodos-electorales) o sobre si los partidos electorales hacen un uso partidista de las estadísticas laborales [link](http://nadaesgratis.es/felgueroso/sobre-la-interpretacion-interesada-de-las-estadisticas-laborales) o si queremos comparar los indicadores de desempleo de aquí con los que publican otros países [link](http://nadaesgratis.es/felgueroso/indicadores-del-paro-y-empleo-alternativos-epa-del-3o-trimestre-2015)  o si...En fin, las opciones son ilimitadas, sobre todo si tenemos capacidad de generar buenas preguntas. 
Para ver el potencial que tiene R para ayudarnos a responder este tipo de preguntas,  haremos un caso práctico con la Encuesta de Condiciones de Vida del INE, utilizando el paquete estadístico R [link](https://www.r-project.org/). Antes de seguir, admito solemnemente que esto es mucho más ambicioso de lo que parece.

## Pre Requisitos
Dado que tendremos poco tiempo (1h30m), sería **muy conveniente** que la gente venga con su laptop y traiga instalado:
* El R [link](https://www.r-project.org/). Instalarlo en general es muy fácil, tanto para Windows, OSX o Linux. Lo unico que hay que hacer es seguir las instrucciones al pie de la letra.
* En lo posible utilizaremos la versión desktop del programa RStudio [link](https://www.rstudio.com/products/RStudio/#Desktop), que nos permitirá interactuar más facilmente con el R. También es fácil de instalar (hay que tener instalado el R primero) pero no es imprescindible (aunque es muy práctico).
* Descargardos los últimos tres años de la EPA del INE. [link](http://www.ine.es/dyngs/INEbase/es/operacion.htm?c=Estadistica_C&cid=1254736176918&menu=resultados&secc=1254736030639&idp=1254735976595). Aquí podran encontrar
	+ Los ficheros de microdatos (estan en formato formato ASCII comprimido...no preocuparse por las siglas raras, simplemente download el zip file!)
	+ Diseño de registro y valores válidos [link](ftp://www.ine.es/temas/epa/disereg_epa0513.zip)
	+ Cuestionario [link](http://www.ine.es/inebaseDYN/epa30308/docs/epacues05.pdf)
* Finalmente, deberíamos instalarnos algunos de los paquetes de R que nos permitiran hacer el análisis. Estos son ggplot2, dplyr, tidyr, RColorBrewer, GGally, reshape2, data.table. Esta parte quizás es un poco más complicada para aquellos que nunca han utilizado este programa, por lo que espero que las imágenes de aquí sirvan para ilustrar.
	+ Pas 1 ![](https://cloud.githubusercontent.com/assets/9589870/14567204/5b290418-0333-11e6-8964-7a48b84418ae.png)
	+ Pas 2 ![](https://cloud.githubusercontent.com/assets/9589870/14567203/5b292434-0333-11e6-9c61-162a1e1903cb.png)
	+ Pas 3 ![](https://cloud.githubusercontent.com/assets/9589870/14567202/5b28f388-0333-11e6-9953-59d7305da74a.png)

## Qué haremos
* Aprender a cargar ficheros en R
* Entender lo **mínimo** de una encuesta representativa
* Hacer un análisis cuantitativo del desempleo en España a partir de preguntas que nos parezcan relevantes (análisis explicativo) o senzillamente para que se nos ocurran esas preguntas (análisis exploratorio). Por ejemplo:
 + Cuál es la distribución por cuartiles desempleo en España a nivel territorial? (CCAA y provincias) ?
 + Cómo se distribuye territorialmente el paro de larga durada (más de dos años)? Qué características tiene esta población?
 + Cuál es la tasa de NiNis en España? Existen diferencias dependiendo del nivel educativo de sus padres?
* Aprender un **mínimo** de programación en R
* Graficar algunos de los resultados
* Guardar los datos tratados en formatos más familiares (.xlsx o csv)

Si bien la EPA es solo uno de los ficheros de micro datos que tiene el INE a disposición, posiblemente sea uno de los más utilizados en lo relativo a cuestiones laborales. Existen otros igual de interesantes (por ejemplo Encuesta de Condiciones de Vida [link](http://www.ine.es/dyngs/INEbase/es/operacion.htm?c=Estadistica_C&cid=1254736176807&menu=resultados&secc=1254736195153&idp=1254735976608), Encuesta de Presupuesto Familiares [link](http://www.ine.es/dyngs/INEbase/es/operacion.htm?c=Estadistica_C&cid=1254736176806&menu=resultados&secc=1254736195147&idp=1254735976608)). De todas formas, el análisis que haremos es fácilmente trasladable a estos ficheros o a cualquier otro que uno quiera utilizar. Espero les sea de utilidad.

## Línea de R que utilizaremos

epa.fixed <- read.fwf("datos_t42015.txt", width = c(3,2,2,5,1,2,2,1,1,2,2,2,1,1,2,3,1,3,2,2,2,3,1,2,1,2,3,2,1,1,1,2,2,1,1,1,2,1,1,1,2,2,2,3,3,2,3,1,2,4,4,4,1,4,4,2,1,1,1,2,4,1,1,2,2,1,1,1,1,2,1,1,2,1,1,1,3,1,1,2,1,2,2,2,1,1,1,2,3,1,2,2,7))

dimnames(epa.fixed)[[2]] <- c("CICLO","CCAA","PROV","NVIVI","NIVEL","NPERS","EDAD5","RELPP1","SEXO1","NCONY","NPADRE","NMADRE","RELLMILI","ECIV1","PRONA1","REGNA1","NAC1","EXREGNA1","ANORE1","NFORMA","RELLB1","EDADEST","CURSR","NCURSR","CURSNR","NCURNR","HCURNR","RELLB2","TRAREM","AYUDFA","AUSENT","RZNOTB","VINCUL","NUEVEM","OCUP1","ACT1","SITU","SP","DUCON1","DUCON2","DUCON3","TCONTM","TCONTD","DREN","DCOM","PROEST","REGEST","PARCO1","PARCO2","HORASP","HORASH","HORASE","EXTRA","EXTPAG","EXTNPG","RZDIFH","TRAPLU","OCUPLU1","ACTPLU1","SITPLU","HORPLU","MASHOR","DISMAS","RZNDISH","HORDES","BUSOTR","BUSCA","DESEA","FOBACT","NBUSCA","ASALA","EMBUS","ITBU","DISP","RZNDIS","EMPANT","DTANT","OCUPA","ACTA","SITUA","OFEMP","SIDI1","SIDI2","SIDI3","SIDAC1","SIDAC2","MUN1","PRORE1","REPAIRE1","TRAANT","AOI","CSE","FACTOREL")
