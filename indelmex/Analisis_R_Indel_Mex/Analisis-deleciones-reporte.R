##Cargar los datos 
library(readr)
df <- read_delim("C:/Users/Jose Abel/OneDrive - UNIVERSIDAD NACIONAL AUTÓNOMA DE MÉXICO/Tesis_sobre_SARS-CoV-2/Tesis-BetterLab/deleciones-analisis-R/reportFinal-uniq-confi-metadatos.txt", 
                          delim = "\t", escape_double = FALSE, 
                          trim_ws = TRUE)

##Cargar librerias
library(forcats) #Libreria para poder acomodar el eje de la "x" como queramos
library(ggplot2)
library(dplyr)
library(tidyr)
library(magrittr)
pacman::p_load(pacman, installr, rio, dplyr, tidyr, ggplot2, stringr, scales, viridis, hrbrthemes, plotly, htmlwidgets)
library(vegan)
#library(tidyverse)
#data_long <- df_t %>% gather(Description, value, "1517_S349Merged":"447_S47")
#View(data_long)

#ggplot(data_long, aes(x = Description, y= value, 
#                      fill = Cantidad), xlab="") +
# geom_bar(stat="identity", width=.5, position = "stack") +
#facet_wrap(~ Cantidad)

#otro tipo de grafica
#ggplot(data=data_long, aes(x=value, y=Description, fill=Cantidad))+ 
#  geom_bar(aes(), stat="identity", position="stack")

## Plots que nos enseña los genomas que se detecaron a lo largo del año
k <- df %>%
  mutate(Mes = fct_relevel(Mes, 
                           "marzo","abril","mayo","junio","julio", "agosto", "septiembre","octubre","noviembre","diciembre")) 
mes <- ggplot(data = k, mapping = aes(x = Mes ,y = Delecion)) +
  geom_bar(stat="identity",fill="#68e5d9")+
  #facet_wrap(~ Mes)+
  labs(
    title = "Genomas con delecion en el ORF7/8",
    y="Genomas con Delecion ",
    x="Meses",
    
  )

#ggsave(filename = "Meses-delecion-final.png", plot = mes, width = 20, height = 16, dpi = 300, units = "cm")

#Grafica de linea
#color: Cuantas muestras hay con delecion, variable delecion
#eje de las Y: 
#ggplot(data = dfb, mapping = aes(x=Mes, y=valor, by=Linaje ,color=Delecion)) +
# geom_line()

#ggplot(data = gapminder, mapping = aes(x=year, y=lifeExp, by=country, color=continent)) +
 # geom_line()

#ggsave(filename = "Meses-delecion.png", plot = mes, width = 20, height = 16, dpi = 300, units = "cm")

#__________________________________________________________
##Grafico que de scatterPlot para analizar si debemos o no juntar deleciones
#Tamaño promedio de las deleciones
#Que necesito graficar?
#1.El eje de las x me debe decir el tamaño de las deleciones
  ## Pero debido a que tenemos muy pocas muestras se debe hacer por intervalos de 10-10
  ## o sea, una barra va a decirnos cuantas deleciones hay del rago del 10-20, 21-30,31-40, etc
#2. El eje de las Y nos debe decir la cantidad que hay de dicho rango
#pasos:
#1. Filtrar los datos de las deleciones que son verdaderas
Tam <- df %>% filter(Delecion_sino == "VERDADERO") %>%
  filter(Linaje_Pangolin %in% c("AY.26", "AY.20", "B.1.243","B.1.617.2","B.1.1.519"))
#2. Extraer la columna Tam_Int 
TamA <- Tam[,"Tam_Int"] #%>%

#TamB <- Tam[, c("Tam_Int", "Linaje_Pangolin")] #%>%
#  count(Tam_Int, Linaje_Pangolin)

L <- ggplot(TamB, aes(x=Tam_Int, y=n, label = TamB$Linaje_Pangolin)) + geom_point()+
#  geom_text()+
#L + xlim("0.5", "2") #Meses (valores discretos) +
scale_x_continuous(name="Tamaño de la delecion (nt)", limits=c(200, 430))+ #Elegir el intervalo del eje X
  facet_wrap(~Linaje_Pangolin)+
  labs(title = "Frecuencia en el Tamaño de deleciones en Genomas de SARS-CoV-2", 
       x = "Tamaño de la delecion (nt)", 
       y = "Frecuencia",
  )
#Guardar grafica
#ggsave(filename = "scatterplotDeleciones200-400.png", plot = L, width = 20, height = 16, dpi = 300, units = "cm")


#Ordenar Valores
nume <- as.numeric(unlist(TamA))
sort(nume)
length(nume)
max(nume)
min(nume)
rango <- range(nume) # Valores mínimo y máximo
rango
amplitud <- diff(rango) # amplitud del rango. Tambien es max(muestra) - min(muestra)
amplitud
# Fórmula : valor mínimo / intérvalos
nointervalos <- 30   # Número de intervalos que se desea
rangointervalos <- amplitud / nointervalos
# paste significa concatenar
#print(paste("Los valores de cada grupos van ..."," de ", rangointervalos, " en  ", rangointervalos, " a partir de :", min(nume)))

#3. Hacer los intervalos de 10 en 10
tabla.intervalos <- transform(table(cut(nume, breaks = 100)))
tabla.intervalos

#4. Graficar: eje de las y cantidad de intervalos; eje X los intervalos.
#plot(tabla.intervalos, main = "¿De cuál intervalo hay más y menos elementos?")
Freq <- ggplot(tabla.intervalos, aes(x = Freq, y = Var1)) + 
  geom_bar(stat = "identity", color = "black", fill = "#1B9E77") +
  labs(title = "Frecuencia por delecion\n", 
       x = "Frecuencia", 
       y = "Tamaño de la delecion")+ 
  theme_minimal()
ggsave(filename = "Frecuencia deleciones.png", plot = Freq, width = 20, height = 16, dpi = 300, units = "cm")

#____________________________
#Grafico que nos muestra la frecuencia del tamaño de la delecion
#length histogram for size delecion
dfa <- df %>% 
  # Filter data to only look at length measurements from 2014
  filter(Delecion_sino == "VERDADERO") %>%
  #filter(Mes == "julio_1") %>%
  #count(Delecion_sino, Mes, sort = FALSE)
  mutate(Mes = fct_relevel(Mes, 
                           "abril","mayo","junio","julio", "agosto", "septiembre","octubre","noviembre","diciembre"))
##class size and class interval
data_range <- max(dfa$Tam_Int) - min(dfa$Tam_Int) #First find the range of your data by getting the maximum value and subtracting it with the minimum value

class_size <- 22
class_interval <- data_range / class_size
lower_limit <- seq(min(dfa$Tam_Int), max(dfa$Tam_Int), by = class_interval)
upper_limit <- (lower_limit + class_interval) - 0.1
df_bin <- as.data.frame(cbind(lower_limit, upper_limit))
df_bin <- df_bin %>% 
  mutate(midlength = (lower_limit + upper_limit) / 2)
nrow(df_bin)

ggplot(data = dfa, aes(x = Tam_Int)) +
  geom_histogram(binwidth = class_interval + 1 ,fill = "#fa8072", color = "black") +
  scale_x_continuous(breaks = df_bin$midlength) +
  #scale_fill_manual(values = c("#FFCC66", "#669933"))+
  labs(title = "Frecuencia en el Tamaño de deleciones en Genomas de SARS-CoV-2", 
       x = "Tamaño de la delecion (nt)", 
       y = "Frecuencia",
       )

#ggsave(filename = "Tam_Del.png", plot = Tam_del, width = 20, height = 16, dpi = 300, units = "cm")

### Plot de areas apiladas

#Eje de las X son variables numericas : Mes O fecha de colecta
#Eje de las Y son variables numericas : la frecuencia de los linajes con delecion y sin delecion
#group: una variable no numerica
#Que necesito?
#1. Obtener, la fecha de collecta, delecion y linajes
#dfab <- df[, c("Delecion_sino","Mes", "Linaje_Pangolin")] %>%
dfab <- df[, c("Delecion_sino","Collection_date", "Linaje_Pangolin")] %>%
  
  #dfab <- df[, c("Delecion_sino","Collection_date", "Gender")] %>%
  #count( Delecion_sino, Mes, Linaje_Pangolin) %>%
  #count(Collection_date, Linaje_Pangolin,sort = FALSE) 
  #filter(Linaje_Pangolin %in% c("AY.20", "B.1.243","B.1.617.2","B.1.1.519")) #%>%
  filter(Linaje_Pangolin == "AY.20") #%>%
  #filter(Delecion_sino == "VERDADERO")
  #filter(Delecion_sino == "VERDADERO")

#valor <- as.numeric(unlist(dfab$n)) #%>%
valor <- dfab$Delecion_sino
#valor <- dfab$n
#mes <- dfab$Mes
mes <- as.Date(unlist(dfab$Collection_date))
#mesA <- as.character(mes, format="%Y/%m/%d")
#mesB <- format.Date(mes, format="%Y/%m/%d")
#length(mesB)
#delecion <- dfab$Delecion_sino
linaje <- dfab$Linaje_Pangolin
#linaje <- dfab$Gender
data2 <- data.frame(mes, linaje, valor)%>%
  ungroup() %>% 
  arrange(mes, linaje, valor)  
  
#Porcentaje
#table_punto <- data2 %>% group_by(mes) %>%
# mutate(percentage = valor/sum(valor)*100)
area <- ggplot(data2, aes(x=mes, fill=linaje )) + 
  
  #geom_area(stat = 'identity', aes(fill = linaje))
  geom_area(aes(y = ..count..), stat = "bin") +
  labs(title = "Deleciones en genomas de SARS-CoV-2 (ORF7/8) a lo largo del 2021", 
       x = "Mes", 
       y = "Cantidad de genomas",
       fill = "Deleciones"
  )
  
  #facet_wrap(~ linaje )
  #scale_x_continuous(name="Tamaño de la delecion (nt)", limits=c("abril", "mayo") #Elegir el intervalo del eje X
   

#ggsave(filename = "Indel-Mex-graph/Deleciones-en-genomas-de-SARS-CoV-2-ORF7_8-a-lo-largo-del-2021.png", plot = area, width = 40, height = 32, dpi = 300, units = "cm")

#__________________________________________
#Grafico de areas con deleciones de interes 
dfab <- df[, c("Delecion_sino","Collection_date", "Linaje_Pangolin")] %>%
filter(Linaje_Pangolin %in% c("AY.20", "B.1.243","B.1.617.2","B.1.1.519","AY.26","AY.3")) #%>%
valor <- dfab$Delecion_sino
mes <- as.Date(unlist(dfab$Collection_date))
linaje <- dfab$Linaje_Pangolin
data2 <- data.frame(mes, linaje, valor)%>%
  ungroup() %>% 
  arrange(mes, linaje, valor) 
area <- ggplot(data2, aes(x=mes, fill=valor )) + 
  geom_area(aes(y = ..count..), stat = "bin") +
  labs(title = "Deleciones en genomas de SARS-CoV-2 (ORF7/8) a lo largo del 2021", 
       x = "Mes", 
       y = "Cantidad de genomas",
       fill = "Deleciones"
  )+

facet_wrap(~ linaje )

ggsave(filename = "Indel-Mex-graph/Deleciones-deInteres-Area.png", plot = area, width = 40, height = 32, dpi = 300, units = "cm")


#_________________________________________
#Grafico que nos muestras todas la muestras analizadas por IndelMex 
#del año 2021 y dice de cada mes si hubo o no deleciones
dfbz <- df %>%
  #filter(Delecion_sino == "VERDADERO") %>%
  count(Delecion_sino,Linaje_Pangolin,Mes, sort = FALSE)
p <- dfbz %>%
  mutate(Mes = fct_relevel(Mes, 
                           "marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre")) %>% 
  na.omit(p) 
meses <- ggplot(p)+
  geom_col(aes(x=Mes, y=n, fill=Linaje_Pangolin, group = Linaje_Pangolin))+
  labs(
    x = "Meses",              # x axis title
    y = "Muestras",
    title = "Muestras analizadas con InDel-Mex",   # y axis title
    fill = "Delecion"       # title of legend
  )#+
  #scale_y_continuous(labels = scales::percent)
  #facet_wrap(~ Delecion_sino)

#ggsave(filename = "Meses-delecionA.png", plot = meses, width = 20, height = 16, dpi = 300, units = "cm")

#Cargar datos
dfbz <- df %>%
  filter(Delecion_sino == "VERDADERO") %>%
  count(Delecion_sino,Linaje_Pangolin,Mes, sort = FALSE)
p <- dfbz %>%
  mutate(Mes = fct_relevel(Mes, 
                           "marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre")) %>% 
  na.omit(p) 
##Plots in porcentaje
table_per <- p %>% group_by(Mes) %>%
  mutate(percentage = n/sum(n)) #%>%
  #mutate_if(is.numeric, round, digits=5) #sirve para redondear los porcentajes

table_per_plot_1 <- 
table_per %>%
  ggplot(aes(x = Mes, y = percentage, label= Linaje_Pangolin)) + 
  geom_bar(stat = "identity",aes(fill = Linaje_Pangolin), color = "black") +
  #geom_text(aes(label = sprintf("%0.2f", table_per$percentage),vjust = 0, hjust= 0.5))+
  #geom_text(aes(label = sprintf("%0.0f", p$n),vjust = 1, hjust= 0.5, angle=90))+
  #geom_text(size = 3, position = position_stack (vjust = 0.6))+
  #geom_text(aes(label = paste0(100*percentage,"%"),y=percentage),size = 3)+
  labs(
    x = "Mes",              # x axis title
    y = "n = numero de muestras",
#    title = "Muestras analizadas con InDel-Mex",   # y axis title
    fill = "Linajes"       # title of legend
  )+
  #facet_wrap(~Linaje_Pangolin)+
  #theme(legend.position="none")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  scale_y_continuous(labels = scales::percent, limits = c(0, 1))+
  theme(text = element_text(size = 20))

ggsave(filename = "Indel-Mex-graph/porcentaje_mes_stack-big.svg", plot = table_per_plot_1, width = 25, height = 21, dpi = 320, units = "cm")

#______________________________________
#Cargar datos para tamaño de la delecion
dfbz <- df %>%
  filter(Delecion_sino == "VERDADERO") %>%
  filter(Linaje_Pangolin %in% c("AY.20", "B.1.243","B.1.617.2","B.1.1.519","AY.26","AY.3"))%>% #sample de interes
  #filter(Linaje_Pangolin %in% c("AY.100", "AY.103", "AY.113", "AY.12", "AY.20", "AY.26", "AY.3", "AY.4", "B.1", "B.1.1.142"))%>% #sample primera parte
  #filter(Linaje_Pangolin %in% c("B.1.1.222","B.1.1.519","B.1.1.7","B.1.243","B.1.429","B.1.617.2","B.1.621","C.37", "P.1.15", "XB"))%>% #sample segunda parte
  
  count(Delecion_sino,Linaje_Pangolin,Mes,Type, sort = FALSE) 

#unique(dfbz$Linaje_Pangolin) #hacer uniq, para quitar los repetidos.

p <- dfbz %>%
  mutate(Mes = fct_relevel(Mes, 
                           "marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre")) %>% 
  na.omit(p) 

##Plots para el tamaño de delecion (O sea el tipo)
table_per <- p %>% group_by(Mes) %>%
  mutate(percentage = n/sum(n)) #%>%
#mutate_if(is.numeric, round, digits=5) #sirve para redondear los porcentajes

table_per_plot_1 <- 
table_per %>%
  ggplot(aes(x = Mes, y = n, label= Type)) + 
  geom_bar(stat = "identity",aes(fill = Type), color = "black") +
  #geom_text(aes(label = sprintf("%0.2f", table_per$percentage),vjust = 0, hjust= 0.5))+
  #geom_text(aes(label = sprintf("%0.0f", p$n),vjust = 1, hjust= 0.5, angle=90))+
  geom_text(size = 2, position = position_stack (vjust = 0.5))+
  #geom_text(aes(label = paste0(100*percentage,"%"),y=percentage),size = 3)+
  labs(
    x = "Mes",              # x axis title
    y = "n = numero de muestras",
#    title = "Muestras analizadas con InDel-Mex",   # y axis title
    fill = "Tipo de delecion"       # title of legend
  )+
  facet_wrap(~Linaje_Pangolin)+
  theme(legend.position="none")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  #scale_y_continuous(labels = scales::percent, limits = c(0, 1))
  theme(text = element_text(size = 20))

ggsave(filename = "Indel-Mex-graph/sample_deInteres_TalDel-big.svg", plot = table_per_plot_1, width = 25, height = 21, dpi = 320, units = "cm")

#_______________________________________
#Grafico que nos muestra la cantidad de linajes que hubo en cada mes
kz <- df %>%
  #filter(Linaje_Pangolin %in% c("AY.26", "AY.20", "B.1.243","B.1.617.2","B.1.1.519", "B.1.1.222")) %>%
  #filter(Linaje_Pangolin == "AY.20")
  count(Delecion_sino,Mes,Linaje_Pangolin, Type, sort = FALSE) %>%
  mutate(Mes = fct_relevel(Mes, 
                           "marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre")) %>%
  na.omit(Kz)

mes <- ggplot(data = kz, mapping = aes(x = Mes , y= n, fill = Linaje_Pangolin)) +
  geom_col()+
  #facet_wrap(~ Linaje_Pangolin)+
  labs(
    y="Genomas con Delecion"
  )

#ggsave(filename = "Indel-Mex-graph/Meses-delecion-all-lineage.png", plot = mes, width = 40, height = 32, dpi = 300, units = "cm")


#___________________________________________________
##Grafica de barras para el porcentajes de cada mes para los casos con deleciones positiva y negativa
stp <- df %>%
  #filter(Delecion_sino == "VERDADERO") %>%
  count(Delecion_sino,Mes, sort = TRUE) %>%
  mutate(Mes = fct_relevel(Mes, 
                           "abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre")) %>%
  na.omit(stp)
#delecionmes <- ggplot(data = stp, mapping = aes(x = Mes , y= n, fill = Delecion_sino)) +
#  geom_col()+
#  #facet_wrap(~ Linaje_Pangolin)+
#  labs(
#    y="Genomas con Delecion",
#    x="Mes",
#    fill = "Deleción",
#    title = "Genomas con delecion y el estatus del paciente",
#  )

#ggsave(filename = "Indel-Mex-graph/estatus-del-paciente.png", plot = status, width = 40, height = 32, dpi = 300, units = "cm")
##Plots en procentaje para cada mes (cuantas muestras tuvieron una delecion y cuantas no)
table_mes <- stp %>% group_by(Mes) %>%
  mutate(percentage = n/sum(n)*1)
table_mes <- table_mes[-7,]
table_mes_por <- 
table_mes %>%
  ggplot(aes(x = Mes, y = percentage, fill = Delecion_sino, label = percentage)) + 
  geom_bar(stat = "identity", aes(fill = Delecion_sino)) +
  geom_text(aes(label = sprintf("%0.2f", table_mes$percentage),vjust = 1))+
  labs(
    x = "Meses",              # x axis title
    y = "n = numero de muestras",
#    title = "Muestras analizadas con InDel-Mex",   # y axis title
    fill = "Delecion"       # title of legend
  )+
  scale_fill_manual(values = c("lightskyblue2","red2"))+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  scale_y_continuous(labels = scales::percent, limits = c(0, 1))+
  theme(text = element_text(size = 20))
ggsave(filename = "Indel-Mex-graph/Meses-porcentaje2.svg", plot = table_mes_por, width = 25, height = 21, dpi = 320, units = "cm")




#___________________________________________________
##Grafica de barras para el estatus del paciente con delecion confirmada
stp <- df %>%
  #filter(Linaje_Pangolin %in% c("AY.26", "AY.20", "B.1.243","B.1.617.2","B.1.1.519", "B.1.1.222")) %>%
  filter(Delecion_sino == "VERDADERO") %>%
  count(Delecion_sino,Mes, Patient_status, sort = FALSE) %>%
  mutate(Mes = fct_relevel(Mes, 
                           "marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre")) %>%
  na.omit(Kz)
status <- ggplot(data = stp, mapping = aes(x = Mes , y= n, fill = Patient_status)) +
  geom_col()+
  #facet_wrap(~ Linaje_Pangolin)+
  labs(
    y="Genomas con Delecion",
    x="Mes",
    fill = "Estado del Paciente",
    title = "Genomas con delecion y el estatus del paciente",
  )

#ggsave(filename = "Indel-Mex-graph/estatus-del-paciente.png", plot = status, width = 40, height = 32, dpi = 300, units = "cm")
##Plots en procentaje para pacientes
table_status <- stp %>% group_by(Mes) %>%
  mutate(percentage = n/sum(n)*100)
table_status <- table_status[,-1]
table_status_por <- table_status %>%
  ggplot(aes(x = Mes, y = percentage, fill = Patient_status, label = percentage)) + 
  geom_bar(stat = "identity", aes(fill = Patient_status)) +
  geom_text(aes(label = sprintf("%0.2f", table_status$percentage),vjust = 1))+
  labs(
    x = "Meses",              # x axis title
    y = "n = numero de muestras",
    title = "Muestras analizadas con InDel-Mex",   # y axis title
    fill = "Estatus del Paciente"       # title of legend
  )+
  scale_fill_manual(values = c("lightskyblue2","red2"))
ggsave(filename = "Indel-Mex-graph/Status-porcentaje.png", plot = table_status_por, width = 25, height = 21, dpi = 320, units = "cm")

##Grafica de barras para el estatus del paciente con delecion confirmada
#PARA MUESTRAS INTERESANTES
stp <- df %>%
  filter(Linaje_Pangolin %in% c("AY.26", "AY.20", "B.1.243","AY.3","B.1.1.519", "B.1.1.222")) %>%
  filter(Delecion_sino == "VERDADERO") %>%
  count(Delecion_sino,Mes,Linaje_Pangolin,Patient_status, sort = FALSE) %>%
  mutate(Mes = fct_relevel(Mes, 
                           "marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre")) %>%
  na.omit(Kz)
status <- ggplot(data = stp, mapping = aes(x = Mes , y= n, fill = Patient_status)) +
  geom_col()+
  facet_wrap(~ Linaje_Pangolin)+
  labs(
    y="Genomas con Delecion",
    x="Mes",
    fill = "Estado del Paciente",
    title = "Genomas con delecion y el estatus del paciente",
  )

ggsave(filename = "Indel-Mex-graph/estatus-del-paciente-muestras-interesantes.png", plot = status, width = 40, height = 32, dpi = 300, units = "cm")

#_______________________________________________________


##Grafica que nos diga que muestras tienen Co_infecciones separarado por mes
Coin <- df %>%
  #filter(Linaje_Pangolin %in% c("AY.26", "AY.20", "B.1.243","B.1.617.2","B.1.1.519", "B.1.1.222")) %>%
  filter(Linaje_Pangolin == "B.1.243") %>%
  filter(Delecion_sino == "VERDADERO") %>%
  count(Delecion_sino,Mes, Co_Variantes, sort = FALSE) %>%
  mutate(Mes = fct_relevel(Mes, 
                           "abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre")) %>%
  na.omit(Coin)
coinfec <- ggplot(Coin, aes(x="", y=n, fill=Co_Variantes)) +
  geom_bar(stat = "identity", width = 1, position = position_fill()) +
  coord_polar(theta = "y") + 
  facet_wrap( ~ Mes)+
  labs(
    y="Frecuencia",
    x="",
    fill = "Co-Infecciones",
    title = "Genomas con delecion y coinfecciones",
  )

#ggsave(filename = "Indel-Mex-graph/coinfecciones-meses.png", plot = coinfec, width = 40, height = 32, dpi = 300, units = "cm")

##________________________________________________________
##Grafica que nos diga que muestras tienen Co_infecciones Para la variante B.1.243 y B.1.1.222
Coin <- df %>%
  #filter(Linaje_Pangolin %in% c("B.1.243","B.1.1.222")) %>%
  filter(Linaje_Pangolin == "B.1.243") %>%
  filter(Delecion_sino == "VERDADERO") %>%
  #count(Delecion_sino, Mes, Co_Variantes,Linaje_Pangolin, sort = FALSE) %>%
  count(Delecion_sino, Mes, Linaje_Pangolin,Tam_Int, sort = FALSE) %>%
  mutate(Mes = fct_relevel(Mes, 
                           "abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre")) %>%
  na.omit(Coin)

coinfec <- ggplot(Coin, aes(x="", y=n, fill=Co_Variantes)) +
  geom_bar(stat = "identity", width = 1, position = position_fill()) +
  coord_polar(theta = "y") + 
  facet_wrap( ~ Mes)+
  labs(
    y="Frecuencia",
    x="",
    fill = "Co-Infecciones",
    title = "Muestras B.1.243 con delecion y coinfecciones",
  )

ggsave(filename = "Indel-Mex-graph/coinfecciones-B1243.png", plot = coinfec, width = 40, height = 32, dpi = 300, units = "cm")



##________________________________________________________
##Grafica de pastel para todos los linajes con delecion verdadera
Coin <- df %>%
  #filter(Linaje_Pangolin %in% c("AY.26", "AY.20", "B.1.243","B.1.617.2","B.1.1.519", "B.1.1.222")) %>%
  filter(Delecion_sino == "VERDADERO") %>%
  count(Delecion_sino,Linaje_Pangolin, Co_Variantes, sort = FALSE) %>%
  na.omit(Coin)

coinfec <- ggplot(Coin, aes(x="", y=n, fill=Co_Variantes)) +
  geom_bar(stat = "identity", width = 1, position = position_fill()) +
  coord_polar(theta = "y") + 
  facet_wrap( ~ Linaje_Pangolin)+
  labs(
    y="Frecuencia",
    x="",
    fill = "Co-Infecciones",
    title = "Genomas con delecion y coinfecciones",
  )

ggsave(filename = "Indel-Mex-graph/coinfecciones-delecionverdadera.png", plot = coinfec, width = 40, height = 32, dpi = 300, units = "cm")

##Grafica de pastel por cada linaje interesante ("AY.26", "AY.20", "B.1.243","B.1.617.2","B.1.1.519", "B.1.1.222")
Coin <- df %>%
  #filter(Linaje_Pangolin %in% c("AY.26", "AY.20", "B.1.243","B.1.617.2","B.1.1.519", "B.1.1.222")) %>%
  filter(Linaje_Pangolin %in% c("B.1.243","B.1.1.222")) %>%
  filter(Delecion_sino == "VERDADERO") %>%
  #count(Delecion_sino,Linaje_Pangolin, Co_Variantes, sort = FALSE) %>%
  count(muestra...1,Delecion_sino,Linaje_Pangolin, Co_Variantes, sort = FALSE) %>%
  na.omit(Coin)

coinfec <- ggplot(Coin, aes(x="", y=n, fill=Co_Variantes)) +
  geom_bar(stat = "identity", width = 1, position = position_fill()) +
  coord_polar(theta = "y") + 
  facet_wrap( ~ Linaje_Pangolin)+
  labs(
    y="Frecuencia",
    x="",
    fill = "Co-Infecciones",
    title = "Genomas con delecion y coinfecciones",
  )

ggsave(filename = "Indel-Mex-graph/coinfecciones-delecionverdadera-linaje-relevantes.png", plot = coinfec, width = 40, height = 32, dpi = 300, units = "cm")

####______Estadisticas para Linaje B.1.243

##Grafica que nos diga que muestras tienen Co_infecciones separarado por mes

B243 <- df %>% 
  filter(Linaje_Pangolin == "B.1.243") %>%
  filter(Delecion_sino == "VERDADERO") %>%
  #count(muestra...1, Delecion_sino,Mes, Linaje_Pangolin, Type, sort = FALSE) %>%
  count(muestra...1, Delecion_sino,Mes, readsencomun, Linaje_Pangolin, Type, inicio, final, Co_Variantes,readsIntodelecion, sort = FALSE) %>%
  mutate(Mes = fct_relevel(Mes, 
                           "marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre")) %>%
  na.omit(Coin)

#porcentaje
#table_status <- B243 %>% group_by(Mes) #%>%
#  mutate(percentage = n/sum(n)*100)
#table_status <- table_status[,-1]
#table_status_por <- table_status #%>%
  
table_B243 <- ggplot(data = B243, mapping = aes(x = Mes , y= n, fill= Type)) +
  geom_col()+
  #facet_wrap(~ Linaje_Pangolin)+
  labs(
    y="n = numero de muestras",
    x="Mes",
    fill = "Tamaño de deleción",
    title = "Genomas B.1.243 con delecion ",
  )

ggsave(filename = "Indel-Mex-graph/B243.png", plot = table_B243 , width = 20, height = 16, dpi = 300, units = "cm")

#_______________________________________________________
#DATOS ESTADISTICA DE FISHER TABLA

tabla.f <- df %>%
  #filter(Linaje_Pangolin %in% c("AY.26", "AY.20", "B.1.243","B.1.617.2","B.1.1.519", "B.1.1.222")) %>%
  #filter(Linaje_Pangolin %in% c("B.1.243","B.1.1.222")) %>%
  #filter(Delecion_sino == "VERDADERO") %>%
  #count(Delecion_sino,Linaje_Pangolin, Co_Variantes, sort = FALSE) %>%
  count(Delecion,Patient_status, sort = FALSE) %>%
  na.omit(Coin)

#____________________________________________________
#Obtener la profundidad de la muestras 616 y 590
#Cargar datos
all <- read_delim("C:/Users/Jose Abel/OneDrive - UNIVERSIDAD NACIONAL AUTÓNOMA DE MÉXICO/Tesis_sobre_SARS-CoV-2/Tesis-BetterLab/deleciones-analisis-R/depths/all.tsv", 
                  delim = "\t", escape_double = FALSE, 
                  col_names = TRUE, trim_ws = TRUE)

ggplot(data = all, mapping = aes(x = posicion , y= depth, fill= Muestra)) +
  geom_area()+
  facet_wrap(~ Muestra)

library(caret)
logTransformed = log(all$depth) #convertir la columna depth a log

ggplot(data = all, mapping = aes(x = posicion , y= logTransformed, fill= Muestra)) +
  geom_area()+
  facet_wrap(~ Muestra)+
  labs(
    y="Profundidad",
    x="Mes",
    fill = "Tamaño de deleción",
    title = "Genomas B.1.243 con delecion ",
  )

#Normalización Min-Max (0-1)
new <- transform(all, n = (all$depth-min(all$depth)) / (max(all$depth)-min(all$depth)))

ggplot(data = new, mapping = aes(x = posicion , y= n, fill= Muestra)) +
  geom_area()+
  facet_wrap(~ Muestra)               
#_______________________________________


##Obter las cantidades de delecion por genes
gene_dele <- df %>% 
  #filter(Linaje_Pangolin == "B.1.243") %>%
  filter(Delecion_sino == "VERDADERO") %>%
  #count(muestra...1, Delecion_sino,Mes, Linaje_Pangolin, Type, inicio, final, GENE_delete, sort = FALSE) %>%
  #count(muestra...1, Delecion_sino,Mes, Linaje_Pangolin, Type, GENE_delete, sort = FALSE) %>%
  count(Mes, GENE_delete, sort = FALSE) %>%
  #count(GENE_delete, sort = FALSE) %>%
  mutate(Mes = fct_relevel(Mes, 
                          "marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre")) %>%
  na.omit(gene_dele)

#Gráfico de los genes deletados
deletados <-
  ggplot(data = gene_dele, mapping = aes(x = Mes , y= n, fill= GENE_delete)) +
geom_col()+
#facet_wrap(~ GENE_delete)+
  labs(
    y="n = numero de muestras",
    x="Mes",
    fill = "Genes deletados",
    #title = "Genomas con delecion de los ORF7a,7b,8",
  )+
  theme(text = element_text(size = 20))+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
  

ggsave(filename = "Indel-Mex-graph/genes_deletados.svg", plot = deletados , width = 20, height = 16, dpi = 300, units = "cm")

#_____________________________________________
#Tabla para hacer heatmap (desarrollo por nelly)
Tabla_heatmap <- df %>% 
  #filter(Delecion_sino == "VERDADERO") %>%
  #count(muestra...1, Delecion_sino,Mes, Linaje_Pangolin, Type, sort = FALSE) %>%
  count(muestra...1, Delecion_sino,Mes, inicio, final, Linaje_Pangolin, sort = FALSE) %>%
  mutate(Mes = fct_relevel(Mes, 
                           "marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre")) %>%
  na.omit(Coin)

#guardar tabla
write.table(Tabla_heatmap, file="C:/Users/Jose Abel/OneDrive - UNIVERSIDAD NACIONAL AUTÓNOMA DE MÉXICO/Tesis_sobre_SARS-CoV-2/Tesis-BetterLab/deleciones-analisis-R/Tabla_heatmapV2.csv", sep = ",")
