## Instalando os pacotes

library(stats)
library(ggplot2)
library(dplyr)
library(ggfortify)

## Carregando a base de dados
View(iris)

mydata = select(iris, c(1,2,3,4))

## Fun��o que calcula o n�merod e k-m�dias
wssplot <- function(data, nc = 15, seed = 1234)
{
  wss <- nrow((data) -1)*sum(apply(data,2,var))
  for (i in 2:nc){
    set.seed(seed)
    wss[i] <- sum(kmeans(data, centers = i)$withinss)}
  plot(1:nc, wss, type = "b", xlab = "N�mero de clusters",
       ylab = "Soma dos quadrados entre grupos")
}

wssplot(mydata)
# o n�mero �timo de clusters � 2

## Aplicando o kmeans 

kmedias <- kmeans(mydata, 2)

## Plotando os clusters

autoplot(kmedias, mydata, frame = TRUE)
# os grupos s�o distitnos e n�o se encontram. A clusteriza��o foi um sucesso

## Agora olhando os centros dos clusters:
kmedias$centers

# os centros dos clusters tem valores diferentes e n�o se intercalam.

## Agora aplicando cluster no mtcars

dataf <- (mtcars)

wssplot(dataf)

# A fun�o apontou 2 como o npuero �tim de clusters

km <- kmeans(dataf, 2)

## Avaliando o plot e os centros
autoplot(km, dataf, frame = TRUE)
km$centers

# os centros dos clusters tem valores diferentes e n�o se intercalam.

