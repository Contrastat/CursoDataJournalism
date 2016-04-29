library(ggplot2)
library(tidyr)
library(dplyr)
library(RColorBrewer)
library(GGally)
library(scales)
library(memisc)
library(gridExtra)
library(reshape2)
library(data.table)

select <- dplyr::select 
setwd('')

epa.fixed <- read.fwf("datos_t42015.txt", width = c(3,2,2,5,1,2,2,1,1,2,2,2,1,1,2,3,1,3,2,2,2,3,1,2,1,2,3,2,1,1,1,2,2,1,1,1,2,1,1,1,2,2,2,3,3,2,3,1,2,4,4,4,1,4,4,2,1,1,1,2,4,1,1,2,2,1,1,1,1,2,1,1,2,1,1,1,3,1,1,2,1,2,2,2,1,1,1,2,3,1,2,2,7))
dimnames(epa.fixed)[[2]] <- c("CICLO","CCAA","PROV","NVIVI","NIVEL","NPERS","EDAD5","RELPP1","SEXO1","NCONY","NPADRE","NMADRE","RELLMILI","ECIV1","PRONA1","REGNA1","NAC1","EXREGNA1","ANORE1","NFORMA","RELLB1","EDADEST","CURSR","NCURSR","CURSNR","NCURNR","HCURNR","RELLB2","TRAREM","AYUDFA","AUSENT","RZNOTB","VINCUL","NUEVEM","OCUP1","ACT1","SITU","SP","DUCON1","DUCON2","DUCON3","TCONTM","TCONTD","DREN","DCOM","PROEST","REGEST","PARCO1","PARCO2","HORASP","HORASH","HORASE","EXTRA","EXTPAG","EXTNPG","RZDIFH","TRAPLU","OCUPLU1","ACTPLU1","SITPLU","HORPLU","MASHOR","DISMAS","RZNDISH","HORDES","BUSOTR","BUSCA","DESEA","FOBACT","NBUSCA","ASALA","EMBUS","ITBU","DISP","RZNDIS","EMPANT","DTANT","OCUPA","ACTA","SITUA","OFEMP","SIDI1","SIDI2","SIDI3","SIDAC1","SIDAC2","MUN1","PRORE1","REPAIRE1","TRAANT","AOI","CSE","FACTOREL")


dim(epa.fixed)
names(epa.fixed)
str(epa.fixed)

epa.fixed$provincia <- factor(epa.fixed$PROV)


#Demosle un valor a una nueva variable llamada year
epa.fixed$year <- 2015
#Un individuo es hombre si la variable SEXO es 1
epa.fixed$home <- ifelse((epa.fixed$SEXO == 1),1,0)
#Una persona es activa si su valor de AOI esta entre las categorias 3,4,5 o 6
epa.fixed$actiu <- ifelse((epa.fixed$AOI == 3) | (epa.fixed$AOI == 4) | (epa.fixed$AOI == 5) | (epa.fixed$AOI == 6), 1,0)
#Una persona es desempleada si AOI es 5 o 6 (no confundir con no trabajar)
epa.fixed$aturat <- ifelse((epa.fixed$AOI == 5) | (epa.fixed$AOI == 6),1,0)
#Una persona es desempleada de larga duracion si ha estado un anyo o mas desempleado; de muy larga si son dos o mas y de muy muy larga si son cuatro o mas
epa.fixed$aturllarg <- ifelse(epa.fixed$aturat == 1 & (epa.fixed$ITBU == 5 | epa.fixed$ITBU == 6 | epa.fixed$ITBU == 7 | epa.fixed$ITBU == 8),1,0)

epa.fixed$aturvllarg <- ifelse(epa.fixed$aturat == 1 & (epa.fixed$ITBU == 7 | epa.fixed$ITBU == 8),1,0)
epa.fixed$aturmvllarg <- ifelse(epa.fixed$aturat == 1 & (epa.fixed$ITBU == 8),1,0)
#Nivel educativo ESO o menos
epa.fixed$Educ1 <- ifelse((epa.fixed$NFORMA == "AN") | (epa.fixed$NFORMA == "P1") | (epa.fixed$NFORMA == "P2") | (epa.fixed$NFORMA == "S1"), 1, 0)
#Nivel educativo secundaria completa
epa.fixed$Educ2 <- ifelse((epa.fixed$NFORMA == "SG") | (epa.fixed$NFORMA == "SP"), 1, 0)
#Nivel educativo superior
epa.fixed$Educ3 <- ifelse((epa.fixed$NFORMA == "SU"), 1, 0)
#Persona joven
epa.fixed$jove <- ifelse((epa.fixed$EDAD5 == 16 | epa.fixed$EDAD5 == 20 | epa.fixed$EDAD5 == 25),1,0)
#Persona grande
epa.fixed$gran <- ifelse((epa.fixed$EDAD5 == 45 | epa.fixed$EDAD5 == 50 | epa.fixed$EDAD5 == 55 | epa.fixed$EDAD5 == 60),1,0)
#Jovenes que no trabaja, no estudian y no se forman
epa.fixed$noef <- ifelse((epa.fixed$CURSR == 3 & epa.fixed$CURSNR == 3 & (epa.fixed$AOI == 5 | epa.fixed$AOI == 6 | epa.fixed$AOI == 7 | epa.fixed$AOI == 8 | epa.fixed$AOI == 9) & (epa.fixed$EDAD5 == 16 | epa.fixed$EDAD5 == 20 | epa.fixed$EDAD5 == 25)),1,0)
#Jovenes que no trabajan, no estudian y no se forman con bajo nivel educativo (Noefs vulnerables)
epa.fixed$noefvul <- ifelse((epa.fixed$noef == 1 & epa.fixed$Educ1 == 1),1,0)
#Personas ocupadas
epa.fixed$ocupado <- ifelse((epa.fixed$AOI == 3 | epa.fixed$AOI == 4),1,0)
#Personas contrato temporal
epa.fixed$emptemporal <- ifelse((epa.fixed$ocupado == 1 & epa.fixed$DUCON1 == 6),1,0)
#Empleados publicos
epa.fixed$emppub <- ifelse((epa.fixed$ocupado == 1 & epa.fixed$SITU == 8),1,0)
#Empleados construccion
epa.fixed$empconstr <- ifelse((epa.fixed$ocupado == 1 & epa.fixed$ACT == 4),1,0)

desocupats.prov <- epa.fixed %>%
  filter(!is.na(AOI)) %>%
  mutate(atureso = aturat * Educ1,
         aturvllteso = aturvllarg * Educ1,
         aturllteso = aturllarg * Educ1,
         aturuniv = aturat * Educ3,
         aturvlltuniv = aturvllarg * Educ3,
         aturlltuniv = aturllarg * Educ3,
         esoactiu = Educ1 * actiu,
         postactiu = Educ2 * actiu,
         univactiu = Educ3 * actiu,)%>%
  group_by(provincia) %>%
  summarise(year = mean(year),
            Actius = sum(actiu * FACTOREL/100),
            Aturats = sum(aturat * FACTOREL/100),
            AturatsLlT = sum(aturllarg * FACTOREL/100),
            AturatsVLlT = sum(aturvllarg * FACTOREL/100),
            AturatsMVLlT = sum(aturmvllarg * FACTOREL/100),
            Joves = sum(jove * FACTOREL/100),
            Aturat.Eso = sum(atureso * FACTOREL/100),
            Aturat.Univ = sum(aturuniv * FACTOREL/100),
            AturatLLT.Eso = sum(aturllteso * FACTOREL/100),
            AturatLLT.Univ = sum(aturlltuniv * FACTOREL/100),
            AturatVLLT.Eso = sum(aturvllteso * FACTOREL/100),
            AturatVLLT.Univ = sum(aturvlltuniv * FACTOREL/100),
            EsoMenys = sum(esoactiu * FACTOREL/100),
            PostObl = sum(postactiu * FACTOREL/100),
            Univ = sum(univactiu * FACTOREL/100),
            Noefs = sum(noef * FACTOREL/100),
            Noefs.Vul = sum(noefvul * FACTOREL/100),
            Ocupados = sum(ocupado * FACTOREL/100),
            Emp.publicos = sum(emppub * FACTOREL/100)
            Emp.constr = sum(empconstr * FACTOREL/100)
            Emp.temp = sum(emptemporal * FACTOREL/100),
            obs = sum(FACTOREL/100),
            n = n())%>%
  mutate(tasa.atur = Aturats/Actius * 100,
         tasa.aturllt = AturatsLlT/Actius * 100,
         tasa.aturvllt = AturatsVLlT/Actius * 100,
         tasa.aturmvllt = AturatsMVLlT/Actius * 100,
         tasa.atureso = Aturat.Eso / EsoMenys * 100,
         tasa.aturllteso = AturatLLT.Eso / EsoMenys * 100,
         tasa.aturuniv = Aturat.Univ / Univ * 100,
         tasa.aturlltuniv = aturlltuniv / Univ * 100,
         tasa.noefs = Noefs / Joves * 100,
         tasa.noefsvul = Noefs.Vul / Joves * 100,
         tasa.constr = Emp.constr / Ocupados * 100,
         tasa.temp = Emp.temp / Ocupados * 100,
         tasa.publico = Emp.publicos / Ocupados * 100) %>%
  arrange(provincia)


desocupats.prov$provincia <- factor(desocupats.prov$provincia,
                                    levels = c(seq(1,52)),
                                    labels = c("Alava", "Albacete", "Alicante", "Almeria", "Avila", "Badajoz", "Baleares", "Barcelona", "Burgos", "Caceres", "Cadiz", "Castellon", "Ciudad Real", "Cordoba", "La Coruna", "Cuenca", "Girona", "Granada", "Guadalajara", "Guipuzcoa", "Huelva", "Huesca", "Jaen", "Leon", "Lleida", "La Rioja", "Lugo", "Madrid", "Malaga", "Murcia", "Navarra", "Orense", "Asturias", "Palencia", "Las Palmas", "Pontevedra", "Salamanca", "Santa Cruz de Tenerife", "Cantabria", "Segovia", "Sevilla", "Soria", "Tarragona", "Teruel", "Toledo", "Valencia", "Valladolid", "Vizcaya", "Zamora", "Zaragoza", "Ceuta",  "Melilla"))

desocupats.prov$auxprov <- as.numeric(desocupats.prov$prov)

write.csv(desocupats.prov, file = "aturProv-2015.csv")
