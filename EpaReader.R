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

#setwd('C:/Users/federico/Documents/Potencials Avaluacions/Blog/EPA/')
setwd('/Volumes/KINGSTON/D3JS/Unemployment/')



inicio = 2005
fin = 2015

#Fase uno: generamos los valores para cada anyo

for (j in seq(inicio,fin)){
  epa.fixed <- read.fwf(paste(paste("datos_t4", toString(j), sep = ""), ".txt", sep = ""), width = c(3,2,2,5,1,2,2,1,1,2,2,2,1,1,2,3,1,3,2,2,2,3,1,2,1,2,3,2,1,1,1,2,2,1,1,1,2,1,1,1,2,2,2,3,3,2,3,1,2,4,4,4,1,4,4,2,1,1,1,2,4,1,1,2,2,1,1,1,1,2,1,1,2,1,1,1,3,1,1,2,1,2,2,2,1,1,1,2,3,1,2,2,7))
  
  dimnames(epa.fixed)[[2]] <- c("CICLO","CCAA","PROV","NVIVI","NIVEL","NPERS","EDAD5","RELPP1","SEXO1","NCONY","NPADRE","NMADRE","RELLMILI","ECIV1","PRONA1","REGNA1","NAC1","EXREGNA1","ANORE1","NFORMA","RELLB1","EDADEST","CURSR","NCURSR","CURSNR","NCURNR","HCURNR","RELLB2","TRAREM","AYUDFA","AUSENT","RZNOTB","VINCUL","NUEVEM","OCUP1","ACT1","SITU","SP","DUCON1","DUCON2","DUCON3","TCONTM","TCONTD","DREN","DCOM","PROEST","REGEST","PARCO1","PARCO2","HORASP","HORASH","HORASE","EXTRA","EXTPAG","EXTNPG","RZDIFH","TRAPLU","OCUPLU1","ACTPLU1","SITPLU","HORPLU","MASHOR","DISMAS","RZNDISH","HORDES","BUSOTR","BUSCA","DESEA","FOBACT","NBUSCA","ASALA","EMBUS","ITBU","DISP","RZNDIS","EMPANT","DTANT","OCUPA","ACTA","SITUA","OFEMP","SIDI1","SIDI2","SIDI3","SIDAC1","SIDAC2","MUN1","PRORE1","REPAIRE1","TRAANT","AOI","CSE","FACTOREL")
  
  dim(epa.fixed)
  names(epa.fixed)
  str(epa.fixed)
#  table(epa.fixed$EDAD5)
  
  
  epa.fixed$provincia <- factor(epa.fixed$PROV)
  epa.fixed$ccaa <- factor(epa.fixed$CCAA)
  #Atur
  epa.fixed$actiu <- ifelse((epa.fixed$AOI == 3) | (epa.fixed$AOI == 4) | (epa.fixed$AOI == 5) | (epa.fixed$AOI == 6), 1,0)
  epa.fixed$aturat <- ifelse((epa.fixed$AOI == 5) | (epa.fixed$AOI == 6),1,0)
  
  epa.fixed$actiu2 <- ifelse((epa.fixed$AOI == 3) | (epa.fixed$AOI == 4) | (epa.fixed$AOI == 5) | (epa.fixed$AOI == 6) | (epa.fixed$AOI == 7), 1,0)
  epa.fixed$aturat2 <- ifelse((epa.fixed$AOI == 5) | (epa.fixed$AOI == 6) | (epa.fixed$AOI == 7),1,0)
  
  epa.fixed$aturvllarg <- ifelse(epa.fixed$aturat == 1 & (epa.fixed$ITBU == 7 | epa.fixed$ITBU == 8),1,0)
  epa.fixed$aturllarg <- ifelse((epa.fixed$aturat == 1) & ((epa.fixed$ITBU == 7) | (epa.fixed$ITBU == 8) | (epa.fixed$ITBU == 5) | (epa.fixed$ITBU == 6)),1,0)
  
  epa.fixed$home <- ifelse((epa.fixed$SEXO == 1),1,0)
  
  epa.fixed$Educ1 <- ifelse((epa.fixed$NFORMA == "AN") | (epa.fixed$NFORMA == "P1") | (epa.fixed$NFORMA == "P2") | (epa.fixed$NFORMA == "S1"), 1, 0)
  epa.fixed$Educ2 <- ifelse((epa.fixed$NFORMA == "SG") | (epa.fixed$NFORMA == "SP"), 1, 0)
  epa.fixed$Educ3 <- ifelse((epa.fixed$NFORMA == "SU"), 1, 0)
  
  
  epa.fixed$jove <- ifelse((epa.fixed$EDAD5 == 16 | epa.fixed$EDAD5 == 20 | epa.fixed$EDAD5 == 25),1,0)
  epa.fixed$gran <- ifelse((epa.fixed$EDAD5 == 45 | epa.fixed$EDAD5 == 50 | epa.fixed$EDAD5 == 55 | epa.fixed$EDAD5 == 60),1,0)
  
  epa.fixed$noef <- ifelse((epa.fixed$CURSR == 3 & epa.fixed$CURSNR == 3 & (epa.fixed$AOI == 5 | epa.fixed$AOI == 6 | epa.fixed$AOI == 7 | epa.fixed$AOI == 8 | epa.fixed$AOI == 9) & (epa.fixed$EDAD5 == 16 | epa.fixed$EDAD5 == 20 | epa.fixed$EDAD5 == 25)),1,0)
  epa.fixed$noefvul <- ifelse((epa.fixed$noef == 1 & epa.fixed$Educ1 == 1),1,0)
  
  epa.fixed$ocupado <- ifelse((epa.fixed$AOI == 3 | epa.fixed$AOI == 4),1,0)
  epa.fixed$emppub <- ifelse((epa.fixed$ocupado == 1 & epa.fixed$SITU == 8),1,0)
  
  y = 2005
  for (i in  seq(133, 173, 4)){
    if (epa.fixed$CICLO == i){
      epa.fixed$year <- y
    }
    y = y + 1
  }
  
  desocupats.prov <- epa.fixed %>%
    filter(!is.na(AOI)) %>%
    mutate(aturjove = aturat * jove,
           aturgran = aturat * gran,
           atureso = aturat * Educ1,
           aturpost = aturat * Educ2,
           aturuniv = aturat * Educ3,
           aturhome = aturat * home,
           joveactiu = jove * actiu,
           homeactiu = home * actiu,
           donaactiu = (1-home) * actiu,
           esoactiu = Educ1 * actiu,
           postactiu = Educ2 * actiu,
           univactiu = Educ3 * actiu,
           aturdona = aturat * (1-home))%>%
    group_by(provincia) %>%
    summarise(year = mean(year),
              Actius = sum(actiu * FACTOREL/100),
              Aturats = sum(aturat * FACTOREL/100),
              AturatsLlT = sum(aturllarg * FACTOREL/100),
              AturatsVLlT = sum(aturvllarg * FACTOREL/100),
              Joves = sum(joveactiu * FACTOREL/100),
              Joves2 = sum(jove * FACTOREL/100),
              Grans = sum(gran * FACTOREL/100),
              Homes = sum(homeactiu * FACTOREL/100),
              Dones = sum(donaactiu * FACTOREL/100),
              Aturat.Joves = sum(aturjove * FACTOREL/100),
              Aturat.Grans = sum(aturgran * FACTOREL/100),
              Aturat.Eso = sum(atureso * FACTOREL/100),
              Aturat.Post = sum(aturpost * FACTOREL/100),
              Aturat.Univ = sum(aturuniv * FACTOREL/100),
              Aturat.Homes = sum(aturhome * FACTOREL/100),
              Aturat.Dones = sum(aturdona * FACTOREL/100),
              EsoMenys = sum(esoactiu * FACTOREL/100),
              PostObl = sum(postactiu * FACTOREL/100),
              Univ = sum(univactiu * FACTOREL/100),
              Noefs = sum(noef * FACTOREL/100),
              Noefs.Vul = sum(noefvul * FACTOREL/100),
              Ocupados = sum(ocupado * FACTOREL/100),
              Emp.publicos = sum(emppub * FACTOREL/100),
              obs = sum(FACTOREL/100),
              n = n())%>%
    mutate(tasa.atur = Aturats/Actius * 100,
           tasa.aturvlt = AturatsVLlT/Actius * 100,
           tasa.aturjove = Aturat.Joves / Joves * 100,
           tasa.jovesaturats = Aturat.Joves / Aturats * 100,
           tasa.aturgran = Aturat.Grans / Grans * 100,
           tasa.gransaturats = Aturat.Grans / Aturats * 100,
           tasa.atureso = Aturat.Eso / EsoMenys * 100,
           tasa.esoaturats = Aturat.Eso / Aturats * 100,
           tasa.aturpost = Aturat.Post / PostObl * 100,
           tasa.postaturats = Aturat.Post / Aturats * 100,
           tasa.aturuniv = Aturat.Univ / Univ * 100,
           tasa.univaturats = Aturat.Univ / Aturats * 100,
           tasa.aturdona = Aturat.Dones / Dones * 100,
           tasa.donaaturtats = Aturat.Dones / Aturats * 100,
           tasa.aturhome = Aturat.Dones / Homes * 100,
           tasa.homeaturats = Aturat.Homes / Aturats * 100,
           tasa.noefs = Noefs / Joves2 * 100,
           tasa.noefsvul = Noefs.Vul / Joves2 * 100,
           tasa.publico = Emp.publicos / Ocupados * 100) %>%
    arrange(provincia)
  
  desocupats.ccaa <- epa.fixed %>%
    filter(!is.na(AOI)) %>%
    mutate(aturjove = aturat * jove,
           aturgran = aturat * gran,
           atureso = aturat * Educ1,
           aturpost = aturat * Educ2,
           aturuniv = aturat * Educ3,
           aturhome = aturat * home,
           joveactiu = jove * actiu,
           homeactiu = home * actiu,
           donaactiu = (1-home) * actiu,
           esoactiu = Educ1 * actiu,
           postactiu = Educ2 * actiu,
           univactiu = Educ3 * actiu,
           aturdona = aturat * (1-home))%>%
    group_by(ccaa) %>%
    summarise(year = mean(year),
              Actius = sum(actiu * FACTOREL/100),
              Aturats = sum(aturat * FACTOREL/100),
              AturatsLlT = sum(aturllarg * FACTOREL/100),
              AturatsVLlT = sum(aturvllarg * FACTOREL/100),
              Joves = sum(joveactiu * FACTOREL/100),
              Joves2 = sum(jove * FACTOREL/100),
              Grans = sum(gran * FACTOREL/100),
              Homes = sum(homeactiu * FACTOREL/100),
              Dones = sum(donaactiu * FACTOREL/100),
              Aturat.Joves = sum(aturjove * FACTOREL/100),
              Aturat.Grans = sum(aturgran * FACTOREL/100),
              Aturat.Eso = sum(atureso * FACTOREL/100),
              Aturat.Post = sum(aturpost * FACTOREL/100),
              Aturat.Univ = sum(aturuniv * FACTOREL/100),
              Aturat.Homes = sum(aturhome * FACTOREL/100),
              Aturat.Dones = sum(aturdona * FACTOREL/100),
              EsoMenys = sum(esoactiu * FACTOREL/100),
              PostObl = sum(postactiu * FACTOREL/100),
              Univ = sum(univactiu * FACTOREL/100),
              Noefs = sum(noef * FACTOREL/100),
              Noefs.Vul = sum(noefvul * FACTOREL/100),
              Ocupados = sum(ocupado * FACTOREL/100),
              Emp.publicos = sum(emppub * FACTOREL/100),
              obs = sum(FACTOREL/100),
              n = n())%>%
    mutate(tasa.atur = Aturats/Actius * 100,
           tasa.aturvlt = AturatsVLlT/Actius * 100,
           tasa.aturjove = Aturat.Joves / Joves * 100,
           tasa.jovesaturats = Aturat.Joves / Aturats * 100,
           tasa.aturgran = Aturat.Grans / Grans * 100,
           tasa.gransaturats = Aturat.Grans / Aturats * 100,
           tasa.atureso = Aturat.Eso / EsoMenys * 100,
           tasa.esoaturats = Aturat.Eso / Aturats * 100,
           tasa.aturpost = Aturat.Post / PostObl * 100,
           tasa.postaturats = Aturat.Post / Aturats * 100,
           tasa.aturuniv = Aturat.Univ / Univ * 100,
           tasa.univaturats = Aturat.Univ / Aturats * 100,
           tasa.aturdona = Aturat.Dones / Dones * 100,
           tasa.donaaturtats = Aturat.Dones / Aturats * 100,
           tasa.aturhome = Aturat.Dones / Homes * 100,
           tasa.homeaturats = Aturat.Homes / Aturats * 100,
           tasa.noefs = Noefs / Joves2 * 100,
           tasa.noefsvul = Noefs.Vul / Joves2 * 100,
           tasa.publico = Emp.publicos / Ocupados * 100) %>%
    arrange(ccaa)

  
  
  
  desocupats.nac <- epa.fixed %>%
    filter(!is.na(AOI)) %>%
    mutate(aturjove = aturat * jove,
           aturgran = aturat * gran,
           atureso = aturat * Educ1,
           aturpost = aturat * Educ2,
           aturuniv = aturat * Educ3,
           aturhome = aturat * home,
           joveactiu = jove * actiu,
           homeactiu = home * actiu,
           donaactiu = (1-home) * actiu,
           esoactiu = Educ1 * actiu,
           postactiu = Educ2 * actiu,
           univactiu = Educ3 * actiu,
           aturdona = aturat * (1-home))%>%
    summarise(year = mean(year),
              Actius = sum(actiu * FACTOREL/100),
              Aturats = sum(aturat * FACTOREL/100),
              AturatsLlT = sum(aturllarg * FACTOREL/100),
              AturatsVLlT = sum(aturvllarg * FACTOREL/100),
              Joves = sum(joveactiu * FACTOREL/100),
              Joves2 = sum(jove * FACTOREL/100),
              Grans = sum(gran * FACTOREL/100),
              Homes = sum(homeactiu * FACTOREL/100),
              Dones = sum(donaactiu * FACTOREL/100),
              Aturat.Joves = sum(aturjove * FACTOREL/100),
              Aturat.Grans = sum(aturgran * FACTOREL/100),
              Aturat.Eso = sum(atureso * FACTOREL/100),
              Aturat.Post = sum(aturpost * FACTOREL/100),
              Aturat.Univ = sum(aturuniv * FACTOREL/100),
              Aturat.Homes = sum(aturhome * FACTOREL/100),
              Aturat.Dones = sum(aturdona * FACTOREL/100),
              EsoMenys = sum(esoactiu * FACTOREL/100),
              PostObl = sum(postactiu * FACTOREL/100),
              Univ = sum(univactiu * FACTOREL/100),
              Noefs = sum(noef * FACTOREL/100),
              Noefs.Vul = sum(noefvul * FACTOREL/100),
              Ocupados = sum(ocupado * FACTOREL/100),
              Emp.publicos = sum(emppub * FACTOREL/100),
              obs = sum(FACTOREL/100),
              n = n())%>%
    mutate(tasa.atur = Aturats/Actius * 100,
           tasa.aturvlt = AturatsVLlT/Actius * 100,
           tasa.aturjove = Aturat.Joves / Joves * 100,
           tasa.jovesaturats = Aturat.Joves / Aturats * 100,
           tasa.aturgran = Aturat.Grans / Grans * 100,
           tasa.gransaturats = Aturat.Grans / Aturats * 100,
           tasa.atureso = Aturat.Eso / EsoMenys * 100,
           tasa.esoaturats = Aturat.Eso / Aturats * 100,
           tasa.aturpost = Aturat.Post / PostObl * 100,
           tasa.postaturats = Aturat.Post / Aturats * 100,
           tasa.aturuniv = Aturat.Univ / Univ * 100,
           tasa.univaturats = Aturat.Univ / Aturats * 100,
           tasa.aturdona = Aturat.Dones / Dones * 100,
           tasa.donaaturtats = Aturat.Dones / Aturats * 100,
           tasa.aturhome = Aturat.Dones / Homes * 100,
           tasa.homeaturats = Aturat.Homes / Aturats * 100,
           tasa.noefs = Noefs / Joves2 * 100,
           tasa.noefsvul = Noefs.Vul / Joves2 * 100,
           tasa.publico = Emp.publicos / Ocupados * 100)
  
  desocupats.nac$ccaa = factor("Agregado")
  desocupats.ccaa = rbind(desocupats.ccaa, desocupats.nac)
  drops <- c("ccaa")
  desocupats.nac <- desocupats.nac[,!(names(desocupats.nac) %in% drops)]
  
  desocupats.nac$provincia = factor("Agregado")
  desocupats.prov = rbind(desocupats.prov, desocupats.nac)
  drops <- c("provincia")
  desocupats.nac <- desocupats.nac[,!(names(desocupats.nac) %in% drops)]
  
  
  desocupats.ccaa$ccaa <- factor(desocupats.ccaa$ccaa,
                                 levels = c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,51,52,"Agregado"),
                                 labels = c("Andalucia", "Aragon", "Asturias", "Baleares", "Canarias", "Cantabria", "Castilla-Leon", "Castilla-La Mancha", "Catalunya", "Comunitat Valenciana", "Extremadura", "Galicia", "Madrid", "Murcia", "Navarra", "Pais Vasco", "La Rioja", "Ceuta", "Melilla", "Espanya"))
  
  desocupats.ccaa$auxccaa <- as.numeric(desocupats.ccaa$ccaa)
  
  desocupats.ccaa$id2[desocupats.ccaa$auxccaa==1] <- 1
  desocupats.ccaa$id2[desocupats.ccaa$auxccaa==2]<-2
  desocupats.ccaa$id2[desocupats.ccaa$auxccaa==6]<-3
  desocupats.ccaa$id2[desocupats.ccaa$auxccaa==8]<-4
  desocupats.ccaa$id2[desocupats.ccaa$auxccaa==7]<-5
  desocupats.ccaa$id2[desocupats.ccaa$auxccaa==9]<-6
  desocupats.ccaa$id2[desocupats.ccaa$auxccaa==18]<-7
  desocupats.ccaa$id2[desocupats.ccaa$auxccaa==13]<-8
  desocupats.ccaa$id2[desocupats.ccaa$auxccaa==15]<-9
  desocupats.ccaa$id2[desocupats.ccaa$auxccaa==10]<-10
  desocupats.ccaa$id2[desocupats.ccaa$auxccaa==11]<-11
  desocupats.ccaa$id2[desocupats.ccaa$auxccaa==12]<-12
  desocupats.ccaa$id2[desocupats.ccaa$auxccaa==4]<-13
  desocupats.ccaa$id2[desocupats.ccaa$auxccaa==5]<-14
  desocupats.ccaa$id2[desocupats.ccaa$auxccaa==17]<-15
  desocupats.ccaa$id2[desocupats.ccaa$auxccaa==16]<-16
  desocupats.ccaa$id2[desocupats.ccaa$auxccaa==3]<-17
  desocupats.ccaa$id2[desocupats.ccaa$auxccaa==14]<-18
  desocupats.ccaa$id2[desocupats.ccaa$auxccaa==20]<-20
  
  
  desocupats.prov$provincia <- factor(desocupats.prov$provincia,
                                      levels = c(seq(1,52),"Agregado"),
                                      labels = c("Alava", "Albacete", "Alicante", "Almeria", "Avila", "Badajoz", "Baleares", "Barcelona", "Burgos", "Caceres", "Cadiz", "Castellon", "Ciudad Real", "Cordoba", "La Coruna", "Cuenca", "Girona", "Granada", "Guadalajara", "Guipuzcoa", "Huelva", "Huesca", "Jaen", "Leon", "Lleida", "La Rioja", "Lugo", "Madrid", "Malaga", "Murcia", "Navarra", "Orense", "Asturias", "Palencia", "Las Palmas", "Pontevedra", "Salamanca", "Santa Cruz de Tenerife", "Cantabria", "Segovia", "Sevilla", "Soria", "Tarragona", "Teruel", "Toledo", "Valencia", "Valladolid", "Vizcaya", "Zamora", "Zaragoza", "Ceuta",  "Melilla", "Espanya"))
  
  desocupats.prov$auxprov <- as.numeric(desocupats.prov$prov)
  
  desocupats.prov$id2[desocupats.prov$auxprov==15]<-40
  desocupats.prov$id2[desocupats.prov$auxprov==1]<-48
  desocupats.prov$id2[desocupats.prov$auxprov==2]<-13
  desocupats.prov$id2[desocupats.prov$auxprov==3]<-35
  desocupats.prov$id2[desocupats.prov$auxprov==4]<-1
  desocupats.prov$id2[desocupats.prov$auxprov==33]<-51
  desocupats.prov$id2[desocupats.prov$auxprov==5]<-18
  desocupats.prov$id2[desocupats.prov$auxprov==6]<-38
  desocupats.prov$id2[desocupats.prov$auxprov==7]<-44
  desocupats.prov$id2[desocupats.prov$auxprov==8]<-27
  desocupats.prov$id2[desocupats.prov$auxprov==9]<-19
  desocupats.prov$id2[desocupats.prov$auxprov==10]<-39
  desocupats.prov$id2[desocupats.prov$auxprov==11]<-2
  desocupats.prov$id2[desocupats.prov$auxprov==39]<-12
  desocupats.prov$id2[desocupats.prov$auxprov==12]<-36
  desocupats.prov$id2[desocupats.prov$auxprov==51]<-31
  desocupats.prov$id2[desocupats.prov$auxprov==13]<-14
  desocupats.prov$id2[desocupats.prov$auxprov==14]<-3
  desocupats.prov$id2[desocupats.prov$auxprov==16]<-15
  desocupats.prov$id2[desocupats.prov$auxprov==17]<-28
  desocupats.prov$id2[desocupats.prov$auxprov==18]<-4
  desocupats.prov$id2[desocupats.prov$auxprov==19]<-16
  desocupats.prov$id2[desocupats.prov$auxprov==20]<-49
  desocupats.prov$id2[desocupats.prov$auxprov==21]<-5
  desocupats.prov$id2[desocupats.prov$auxprov==22]<-9
  desocupats.prov$id2[desocupats.prov$auxprov==23]<-6
  desocupats.prov$id2[desocupats.prov$auxprov==26]<-47
  desocupats.prov$id2[desocupats.prov$auxprov==35]<-45
  desocupats.prov$id2[desocupats.prov$auxprov==24]<-20
  desocupats.prov$id2[desocupats.prov$auxprov==25]<-29
  desocupats.prov$id2[desocupats.prov$auxprov==27]<-41
  desocupats.prov$id2[desocupats.prov$auxprov==28]<-33
  desocupats.prov$id2[desocupats.prov$auxprov==29]<-7
  desocupats.prov$id2[desocupats.prov$auxprov==52]<-32
  desocupats.prov$id2[desocupats.prov$auxprov==30]<-52
  desocupats.prov$id2[desocupats.prov$auxprov==31]<-34
  desocupats.prov$id2[desocupats.prov$auxprov==32]<-42
  desocupats.prov$id2[desocupats.prov$auxprov==34]<-21
  desocupats.prov$id2[desocupats.prov$auxprov==36]<-43
  desocupats.prov$id2[desocupats.prov$auxprov==37]<-22
  desocupats.prov$id2[desocupats.prov$auxprov==38]<-46
  desocupats.prov$id2[desocupats.prov$auxprov==40]<-23
  desocupats.prov$id2[desocupats.prov$auxprov==41]<-8
  desocupats.prov$id2[desocupats.prov$auxprov==42]<-24
  desocupats.prov$id2[desocupats.prov$auxprov==43]<-30
  desocupats.prov$id2[desocupats.prov$auxprov==44]<-10
  desocupats.prov$id2[desocupats.prov$auxprov==45]<-17
  desocupats.prov$id2[desocupats.prov$auxprov==46]<-37
  desocupats.prov$id2[desocupats.prov$auxprov==47]<-25
  desocupats.prov$id2[desocupats.prov$auxprov==48]<-50
  desocupats.prov$id2[desocupats.prov$auxprov==49]<-26
  desocupats.prov$id2[desocupats.prov$auxprov==50]<-11
  desocupats.prov$id2[desocupats.prov$auxprov==53]<-53
  
  
  write.csv(desocupats.ccaa, file = paste(paste("aturCCAA-",toString(j),sep = ""), ".csv", sep = ""))
  write.csv(desocupats.prov, file = paste(paste("aturProv-",toString(j),sep = ""), ".csv", sep = ""))
}

##Fase dos: Agarramos las tablas de cada anyo y las juntamos
aux <- lapply(Sys.glob("aturCCAA-*.csv"), read.csv)

aturCCAA <-aux[[1]]
for (j in seq(2,(fin - inicio + 1))){
  aturCCAA <- rbind(aturCCAA, aux[[j]])
}
write.csv(aturCCAA, file = "aturCCAA.csv")


aux <- lapply(Sys.glob("aturProv-*.csv"), read.csv)

aturProv <-aux[[1]]
for (j in seq(2,fin - inicio + 1)){
  aturProv <- rbind(aturProv, aux[[j]])
}
write.csv(aturProv, file = "aturProv.csv")

###Leemos el csv y con spread lo transformamos para que sea utilizable con las barras.

aturCCAA <- read.csv("aturCCAA.csv", header = TRUE, sep = ",", quote = "\"",
         dec = ".", fill = TRUE, comment.char = "")

#sels <- c("year", "ccaa", "tasa.atur")
#aturCCAA <- aturCCAA[,(names(aturCCAA) %in% sels)]

tasa.aturCCAA <- aturCCAA %>%
  select(ccaa, year, tasa.atur) %>%
  spread(year, tasa.atur)

write.csv(tasa.aturCCAA, file = "tasaaturCCAA.csv")

aturProv <- read.csv("aturProv.csv", header = TRUE, sep = ",", quote = "\"",
                     dec = ".", fill = TRUE, comment.char = "")

#sels <- c("year", "ccaa", "tasa.atur")
#aturCCAA <- aturCCAA[,(names(aturCCAA) %in% sels)]

tasa.aturProv <- aturProv %>%
  select(provincia, year, tasa.atur) %>%
  spread(year, tasa.atur)

write.csv(tasa.aturProv, file = "tasaaturProv.csv")