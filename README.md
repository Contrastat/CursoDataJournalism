# CursoDataJournalism

Estos son los ficheros para el mini taller que hicimos en Hack Hackers BCN. Tiene el fichero de las slides, el codigo del programa (simplereader.R) y un código un poco más complicado (EpaReader.R)

El script de R simplereader.R sirve para cargar los datos de la EPA, crear variables, agregar la información a nivel de una variable (por ejemplo desempleo a  nivel de provincia) y guardar el resultado en un fichero de csv. 

Primero hay que ir a la pagina del INE y descargar el .zip de la EPA del cuarto trimestre de 2015 que tiene los microdatos. Para usar el script tal y como esta, habría que cambiarle el nombre al fichero descomprimido por datos_t42015.txt y cambiar el directorio de trabajo donde lo hayamos guardado. Hay que tener en cuenta que las barritas separadoras son estas / y no las de un pc \ (por ejemplo C:/Documents/EPA y no C:\Documents\EPA).

Para usar el EpaReader.R hay bajarse mas trimestres de la EPA (desde 2005 a 2015).

Evidentemente se puede modificar el script para usarlo de otra manera (cargar otro año y hacer que el loop sea mas corto o hacer que el loop sea mas largo e incluya mas trimestres y no solamente el cuarto).

También está el código utilizado para hacer las slides en R (DesempleoEPA.Rpres)
