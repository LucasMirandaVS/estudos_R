# Importando as livrarias, importando os dados e primeira etapa da limpeza dos dados

library(tidyverse)
library(plm)

ideologia_df <- read.csv("C:/Users/Lucas/Desktop/csv do banco.csv")%>%
  filter(year >= 2000 & countryname %in% c("Australia", "Belgium", "Canada", 
                                           "Czech Rep.", "FRG/Germany", "Denmark",
                                           "Spain", "Estonia", "Finland", "France", "UK",
                                           "Hungary", "Ireland", "Iceland", "Israel",
                                           "Italy", "Japan", "Luxembourg", "Mexico", 
                                           "Netherlands", "Norway", "New Zealand", "Poland", 
                                           "Portugal", "Slovakia", "Sweden", "USA")) %>%
  filter(year <= 2018) %>%
  arrange(countryname) %>%
  select(-finittrm) %>%
  mutate(reelect = factor(reelect, levels = c("1", "0"), labels = c("Yes", "No"))) %>%
  mutate(countryname = recode(countryname, "FRG/Germany" = "Germany")) %>%
  dplyr::na_if(-999) %>%
  dplyr::na_if(0) %>%
  dplyr::na_if("") 

## Agora fazendo uma an�lise preliminar dos dados
hist(as.numeric(ideologia_df$execrlc))
plot(x = as.numeric(ideologia_df$execrlc), y = ideologia_df$yrsoffc)
plot(x= ideologia_df$yrsoffc, y = as.numeric(ideologia_df$execrlc))

## Importando a tabela com os dados do WorldBank e unindo as duas num data frame de painel
Dados.Verdes <- read.csv("C:/Users/Lucas/Desktop/Dados Verdes.csv") %>%
  arrange(country) %>%
  mutate(country = recode(country, "United States" = "USA",
                          "United Kingdom" = "UK", "Czech Republic" = "Czech Rep.",
                          "Slovak Republic" = "Slovakia"))%>%
  mutate(CO2PC = co2/gdppc)

df_juntos <- pdata.frame(c(ideologia_df, Dados.Verdes), index = c("countryname", "year")) %>%
  select(c(-1,-2, -7, -8))  

summary(df_juntos)
head(df_juntos)

plot(df_juntos$co2, main = "CO2 emissions (metric tons per capita) 2000 - 2018")
plot(df_juntos$yrsoffc, main = "Dura��o dos governos nos pa�ses")
plot(df_juntos$greenh, main = "CO2 emissions (metric tons per capita) 2000 - 2018")
plot(df_juntos$gdpg, main = "GDP growth (annual %) 2000 - 2018")
plot(df_juntos$execrlc, main = "Posicionamento ideol�gico dos partidos 2000 - 2018")
plot(df_juntos$desemp, main = "Taxa de Desemprego 2000 - 2018")
plot(df_juntos$CO2PC, main = "Emiss�es de CO2 por unidade de PIB(pc) 2000 - 2018")
plot(df_juntos$gdppc, main = "GDP per capita, PPP (constant 2017 international $) 2000 - 2018")
plot(df_juntos$urb, main = "Urban population growth (annual %) 2000 - 2018")

#Agora pras regress�es e testes
#Esses gr�ficos n�o est�o bonitos de ver, mas atrav�s deles ja deu pra perceber que os pa�ses tem um comportamento bem heterogeneo em rela��o a dura��o dos governos, emiss�o de gases poluentes e sistemas de governo
#Vari�veis dependentes em potencial:
##co2 : CO2 emissions (metric tons per capita) 2000 - 2018
##greenh : CO2 emissions (metric tons per capita) 2000 - 2018
##CO2PC : Emiss�es de CO2 por unidade de PIB(pc) 2000 - 2018

# Vari�veis independentes e de controle:
##execrlc : Vari�vel categ�rica de ideologia pol�tica que eu quero investigar
##yrsoffc : Dura��o dos mandatos (Vari�vel independente)
##desemp: Taxa de desemprego (vari�vel independente)
##gdpg : Crescimento do PIB (% anual)
##urb : Urban population growth (annual %)

teste.com.fator <- pggls(log(CO2PC)~factor(execrlc)+log(urb)+log(desemp)+log(gdpg)+log(yrsoffc), 
                         data = df_juntos, 
                         model = "pooling")
summary(teste.com.fator)

teste.com.fator1 <- pggls(log(co2)~factor(execrlc)+log(urb)+log(desemp)+log(gdpg)+log(yrsoffc), 
                          data = df_juntos, 
                          model = "pooling")
summary(teste.com.fator1) ## Esse aqui � o bom

teste.com.fator2 <- pggls(log(greenh)~factor(execrlc)+log(urb)+log(desemp)+log(gdpg)+log(yrsoffc), 
                          data = df_juntos, 
                          model = "pooling")
summary(teste.com.fator2)

phtest(teste.com.fator, teste.com.fator1, teste.com.fator2)
pcdtest(teste.com.fator)
pcdtest(teste.com.fator1)
pcdtest(teste.com.fator2)

