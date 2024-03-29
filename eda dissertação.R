# Realizando a an�lise explorat�ria dos dados da disserta��o
library(readr)
library(plm)
library(data.table)
library(tidyverse)
library(corrplot)
library(corrgram)
library(ExPanDaR)
## Importando os dados e definindo o painel com os estados
P.ANUAL <- read_csv(file.choose())

data_panel<-pdata.frame(P.ANUAL, index=c('UF',"ANO")) %>%
  arrange(UF) %>%
  select(-7)

## As visualiza��es e an�lise explorat�rio em cima do painel servir�o 
## para visualizar os n�veis das vari�veis quantitativas nos estados.

## Resumo dos dados:
head(data_panel)
str(data_panel)
str(P.ANUAL[c('QE', 'OE')])

#verificando se o painel e balanceado
pdim(data_panel)

#verificando a variacao das variaveis no tempo e individuos
pvar(data_panel)

## Medidas de Tendencia Central
summary(data_panel)
  
# vari�veis explicativas
summary(data_panel[c('QE', 'OE')])

## Explorando variaveis numericas
quantile(data_panel$Y, probs = c(0.01, 0.09))
quantile(data_panel$QE, seq(from = 0, to = 1, by = 0.20))
quantile(data_panel$OE, seq(from = 0, to = 1, by = 0.20))

## Boxplot
# Leitura de Baixo para Cima - Q1, Q2 (Mediana) e Q3
boxplot(data_panel$QE, main = "Boxplot para o consumo de etanol nos estados", ylab = "Barris de etanol")
boxplot(data_panel$OE, main = "Boxplot para a produ��o de etanol nos estados", ylab = "Barris de etanol")
boxplot(data_panel$Y, main = "Boxplot para o n�vel de renda nos estados", ylab = "PIB pc")
boxplot(data_panel$TxF, main = "Boxplot para o tamanho da frota de carros nos estados", ylab = "milhares de carros")
boxplot(data_panel$PEC, main = "Boxplot para o pre�o do etanol para o consumidor nos estados", ylab = "Reais(R$)")
boxplot(data_panel$PEP, main = "Boxplot para o pre�o do etanol para produtor nos estados", ylab = "Reais(R$)")
boxplot(data_panel$PGP, main = "Boxplot para o pre�o da gasolina para produtor nos estados", ylab = "Reais(R$)")
boxplot(data_panel$PGC, main = "Boxplot para o pre�o da gasolina para consumidor nos estados", ylab = "Reais(R$)")
boxplot(data_panel$CEAN, main = "Boxplot para  consumo de etabol anidro", ylab = "Em barris de etanol")

## Histograma
# Indicam a frequencia de valores dentro de cada bin (classe de valores)
hist(data_panel$Y, main = "Histograma para o n�vel de renda nos estados", xlab = "Em milhares de reais (R$)")
hist(data_panel$PEC, main = "Histograma para o pre�o do etanol para o consumidor nos estados", xlab = "R$")
hist(data_panel$PEP, main = "Histograma para o pre�o do etanol para o produtor nos estados", xlab = "R$")
hist(data_panel$PGC, main = "Histograma para o pre�o da gasolina para o consumidor nos estados", xlab = "R$")
hist(data_panel$PGP, main = "Histograma para o pre�o da gasolina para o produtor nos estados", xlab = "R$")

## Analisando a evolu��o das vari�veis quantitativas ao longo do tempo
plot(data_panel$Y, main = "PIB pc nos estados")
plot(data_panel$QE, main = "Consumo de etanol por estado") 
plot(data_panel$OE, main = "Produ��o de etanol por estado")
plot(data_panel$CEAN, main = "Consumo de etanol anidro por estado")
plot(data_panel$TxF, main = "Frota de ve�culos Otto por estado")
plot(data_panel$PEC, main = "Pre�o do etanol para o consumidor, por estado")
plot(data_panel$PEP, main = "Pre�o do etanol ao produtor, por estado")
plot(data_panel$PGC, main = "Pre�o da gasolina ao consumidor, por estado")
plot(data_panel$PGP, main = "Pre�o da gasolina ao revendedor, por estado")
# D� pra identificar que o outlier em QE � o estado de SP
# os plots evidenciam como essa amostra � heterogenea

## Analisando a correla��o entre as vari�veis
# entre o n�vel de renda e o consumo de etanol, espera-se um sinal positivo
cor.test(data_panel$Y, data_panel$QE, method = c("pearson", "kendall", "spearman"))
# entre o pre�o pro consumidor e o consumo de etanol, espera-se um sinal negativo
cor.test(data_panel$PEC, data_panel$QE, method = c("pearson", "kendall", "spearman"))
# entre o tamanho da frota otto e o consumo de etanol, espera-se um sinal positivo
cor.test(data_panel$TxF, data_panel$QE, method = c('pearson', 'kendall', 'spearman'))
# entre o pre�o da gasolina pro consumidor e o consumo de etanol, espera-se um sinal negativo
cor.test(data_panel$PGC, data_panel$QE, method = c('pearson', 'kendall', 'spearman'))
# entre o pre�o do etanol pro produtor e o consumo de etanol, espera-se um sinal negativo
cor.test(data_panel$PEP, data_panel$QE, method = c('pearson', 'kendall', 'spearman'))
# entre o o consumo de etanol anidro e o tamanho da frota otto, sinal positivo
cor.test(data_panel$TxF, data_panel$CEAN, method = c('pearson', 'kendall', 'spearman'))
# entre o pre�o do etanol pro produtor e a oferta de etanol, espera-se um sinal negativo
cor.test(data_panel$PEP, data_panel$OE, method = c('pearson', 'kendall', 'spearman'))
# entre os y, espera-se um sinal positivo
cor.test(data_panel$QE, data_panel$OE, method = c('pearson', 'kendall', 'spearman'))
# todas as estimativas s�o significativas a 1%

# Obtendo apenas as colunas numericas
colunas_numericas <- sapply(data_panel, is.numeric)
colunas_numericas 

# Filtrando as colunas numericas para correlacao
data_cor <- cor(data_panel[,colunas_numericas]) 
data_cor
head(data_cor)

# Criando um corrplot
corrplot(data_cor, method = 'color')

# Criando um corrgram
corrgram(data_cor)
corrgram(data_cor, order = TRUE, lower.panel = panel.shade,
         upper.panel = panel.pie, text.panel = panel.txt)

## Avaliando a normalidade da distribui��o 
# PIBpc
shapiro.test(data_panel$Y)
ggqqplot(data_panel$Y, ylab = "PIB pc") #n�o segue uma normal
#TxF
shapiro.test(data_panel$TxF)
ggqqplot(data_panel$TxF, ylab = "Frota Otto") #n�o segue uma normal
# PEC
shapiro.test(data_panel$PEC)
ggqqplot(data_panel$PEC, ylab = "Pre�o do etanol pro consumidor") #segue uma norma
# PEP
shapiro.test(data_panel$PEP)
ggqqplot(data_panel$PEP, ylab = "Pre�o do etanol para o produtor") #n�o segue uma normal
#PGC
shapiro.test(data_panel$PGC)
ggqqplot(data_panel$PGC, ylab = "Pre�o da gasolina pro consumidor") #n�o segue uma normal
#PGP
shapiro.test(data_panel$PGP)
ggqqplot(data_panel$PGP, ylab = "PRe�o de distribui��o da gasolina") #nao 
# QE
shapiro.test(data_panel$QE)
ggqqplot(data_panel$QE, ylab = "Consumo de etanol") #n�o
# OE
shapiro.test(data_panel$OE)
ggqqplot(data_panel$OE, ylab = "Produ��o de etanol") #n�o
#CEAN
shapiro.test(data_panel$CEAN)
ggqqplot(data_panel$CEAN, ylab = "Consumo de etanol anidro") #n�o

## Agora fazendo uma EDA mais completa com o auxilio desse pacote
ExPanD(data_panel, cs_id = "UF", ts_id = "ANO")
