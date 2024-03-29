## Fazendo o desafio de predi��o do pre�o de casas do kaggle
# https://www.kaggle.com/c/house-prices-advanced-regression-techniques

## Livrarias utilizadas
#################################
library(data.table)
library(ggplot2)
library(randomForest)
library(dplyr)
library(corrplot)
library(knitr)
library(kableExtra)
#################################

## Importa��o e limpeza dos Dados
#################################
# importando o dataset
test <- fread("C:/Users/Lucas/Desktop/ds project 1/test.csv", sep = ",", stringsAsFactors = F, data.table = F)
train <- fread("C:/Users/Lucas/Desktop/ds project 1/train.csv", sep = ",", stringsAsFactors = F, data.table = F)

# Fazendo o bind e nomeando os datasets
df_junto <- rbind(train[,-81], test)
df_junto <- cbind(df_junto, Set = c(rep("Train", times = dim(train)[1]),
                                rep("Test", times = dim(test)[1])))
# Limpando os dados:
# procurando os valores faltantes
x <- colSums(sapply(df_junto, is.na))

# Definindo uma tabela com os Na's
x <- data.frame(Variables = names(x), NA.Count = x); rownames(x) <- c()

# Removendo as vari�veis que n�o tem valores faltantes
x <- x %>%
  filter(NA.Count > 0)

kable(x, "html") %>%
  kable_styling(full_width = F)

# Para lidar com os NA's, vou seguir as instru��es do walkthrough que eu vi
# 1.Substituindo valores faltantes por 0
y <- c("LotFrontage", "MasVnrArea", "BsmtFinSF2", "BsmtUnfSF", "TotalBsmtSF", "BsmtFullBath", "BsmtHalfBath")
df_junto[,y] <- apply(df_junto[,y], 2, 
                    function(x) {
                      replace(x, is.na(x), 0)
                    }
)
# 2. Substituindo por "none"
y <- c("Alley", "BsmtQual", "BsmtExposure", "BsmtFinType1", "BsmtFinType2", "FireplaceQu", "PoolQC", "Fence", "MiscFeature", "GarageType", "GarageFinish", "GarageQual", "GarageCond", "BsmtCond")
df_junto[,y] <- apply(df_junto[,y], 2, 
                    function(x) {
                      replace(x, is.na(x), "None")
                    }
)
# 3. Substitui-los pela moda(valor que mais vezes se repete):
y <- c("MSZoning", "Utilities", "Exterior1st", "Exterior2nd", "MasVnrType", "Electrical", "KitchenQual", "Functional", "SaleType")
df_junto[,y] <- apply(df_junto[,y], 2, 
                    function(x) {
                      replace(x, is.na(x), names(which.max(table(x))))
                    }
)
# 4. Substituindo pela mediana
y <- c("GarageCars", "GarageArea", "BsmtFinSF1")
df_junto[,y] <- apply(df_junto[,y], 2, 
                    function(x) {
                      replace(x, is.na(x), median(x, na.rm = T))
                    }
)
#Obs: the missing values is GarageYrBlt. If there is a missing value in the GarageYrBlt variable, 
# we assume that the garage was built the same year as the house.
df_junto$GarageYrBlt[is.na(df_junto$GarageYrBlt)] <- df_junto$YearBuilt[is.na(df_junto$GarageYrBlt)]

table(sapply(df_junto, class))

# Coletando as vari�veis que s�o char
class.list <- sapply(df_junto, class)
class.list.character <- names(class.list[which(class.list=="character")])

# Convertendo pra fator
df_junto[class.list.character] <- lapply(df_junto[class.list.character], factor)

# consertando a classe MSSubClass 
df_junto$MSSubClass <- factor(df_junto$MSSubClass)
#################################

## Engenharia das Features
#################################
# Criando uma vari�vel "total area" 
# que � soma da basement area e ground living area
df_junto$TotalArea <- df_junto$GrLivArea + df_junto$TotalBsmtSF

# Criando uma vari�vel "total number of baths"  
# somando todas as features sobre banheiro
df_junto$TotalBaths <- df_junto$BsmtFullBath + 
  df_junto$BsmtHalfBath +
  df_junto$FullBath + 
  df_junto$HalfBath

# Criando uma vari�vel "area aboveground"
# Somando as �reas do primeiro e segundo andar
df_junto$AreaAbvground <- df_junto$`1stFlrSF` + df_junto$`2ndFlrSF`

# Agora selecionando as features entre as vari�veis num�ricas
# Fazendo um subset do conjunto "train"
# Adicionando a vari�vel "SalePrice" 
df_junto.num.train <- df_junto %>% filter(Set == "Train") %>% 
  select(which(sapply(.,is.integer)), which(sapply(., is.numeric))) %>%
  mutate(SalePrice = train$SalePrice) 

# Quero escolher as vari�veis com maior correla��o com SalesPrice
# essa s�o as mais poderosas na hora de fazer a previs�o
correlation <- round(cor(df_junto.num.train),2)

corrplot(correlation, method = "circle")


# Determinando uma tabela com as correla��es de "SalePrice" 
x <- data.frame(Variables = rownames(correlation), 
                Cor = correlation[, "SalePrice"])

# Ordenando por correla��o
x <- x[order(x$Cor, decreasing = T),]

# Escolhendo as que tem correla��o positiva forte e correla��o negativa 
x <- x[which(x$Cor > 0.5 | x$Cor < -0.5),]
rownames(x) <- c()

kable(x, "html") %>%
  kable_styling(full_width = F)
# As vari�veis criadas tem boa correla��o com saleprice, estamos no caminho certo
# Por isso, elas ser�o usadas no modelo, ao inv�s das originais
kable(x[c(2,3,4,7,10,13),], "html") %>%
  kable_styling(full_width = F)

# Para selecionar as vari�veis categ�ricas, usei um algoritmo de random forest
# pra escolher as mais importantes pro modelo. depois as ordenei

# Definindo um subset com as vari�veis categ�ricas do conjunto test
# Adicionando a vari�vel SalePrice 
df.fac.train <- df_junto %>% filter(Set == "Train") %>%
  select(Id, which(sapply(., is.factor))) %>%
  mutate(SalePrice = train$SalePrice) 

df.fac.test <- df_junto %>% filter(Set == "Test") %>%
  select(Id, which(sapply(., is.factor)))

# Aplicando o algoritmo RF nas categ�ricas 
rf <- randomForest(SalePrice ~ ., data = df.fac.train, importance = T)

# Criando uma tabela ordenando os resultados por importancia
importance.table <- data.frame(Names = rownames(importance(rf)), '%IncMSE' = importance(rf)[,1])

importance.table <- importance.table[order(importance.table[,2], decreasing = T),]
rownames(importance.table) <- c()

# Subset dos primeiros 10 valores
kable(importance.table[1:10,], "html") %>%
  kable_styling(full_width = F)


# Aplicando log na vari�vel SalePrice pra lidar com a heteroscedasticidade e linearidade entre as vari�veis
df_junto.num.train$SalePrice <- log(df_junto.num.train$SalePrice)
df.fac.train$SalePrice <- log(df.fac.train$SalePrice)
#################################

## Aplica��o do modelo
#################################
# Fazendo um subset com as colunas do train e features feitas
# Com a transforma��o de log
df.train <- df_junto %>% filter(Set == "Train") %>%
  select("Id", "OverallQual", "TotalArea", "AreaAbvground", "GarageArea", "TotalBaths", "YearBuilt", 
         "Neighborhood", "MSSubClass", "FireplaceQu", "ExterQual", "KitchenQual", "BsmtQual", "HouseStyle") %>%
  mutate(SalePrice = log(train$SalePrice)) 

# Fazendo o mesmo pras features do test
df.test <- df_junto %>% filter(Set == "Test") %>%
  select("Id", "OverallQual", "TotalArea", "AreaAbvground", "GarageArea", "TotalBaths", "YearBuilt", 
         "Neighborhood", "MSSubClass", "FireplaceQu", "ExterQual", "KitchenQual", "BsmtQual", "HouseStyle")

# Modelo Random Forest 
fit <- randomForest(SalePrice ~ ., data = df.train, importance = T)
# Usando o modelo pra prever os valores de SalePrice no conjunto test
pred <- exp(predict(fit , newdata = df.test))

# Exportando o  resultado
write.csv(x = data.frame(Id = test$Id, SalePrice = pred), row.names = F, file = "./submission.csv")
#################################