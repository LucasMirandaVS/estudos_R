################### Importando dados diretos de sites

library(Quandl)
library(dygraphs)

################# base de dados BCB  - pacote "Quandl"
####              gerenciador de s�ries do BACEN


# Coletar o dado do IPCA. Observe que adicionamos BCB/ ao c�digo da s�rie temporal. Sempre usaremos BCB/ 
# para coletar dados do BACEN por meio do Quandl. Ele tem o significado de determinar de qual banco de 
# dados o Quandl deve buscar pela s�rie que o n�mero definido. Como padr�o o Quandl coletar� os dados na
# periodicidade divulgada pelo BACEN.
ipca = Quandl('BCB/433')
# Coletar a mesma informa��o para um per�odo espec�fico
ipca = Quandl('BCB/433', start_date = "1996-01-01", end_date = "2017-12-31")
# Coletar definindo apenas a data inicial 
ipca = Quandl('BCB/433', start_date = "1996-01-01")
# Coletar definindo a periodicidade de interesse
# Op��es: daily, weekly, monthly, quarterly, annual
ipca = Quandl("BCB/433", collapse = "quarterly", start_date = "1996-01-01")
# Coletar fazendo altera��es nos dados. Transforma��es nos dados permitidas pelo Quandl:
# - diff: z[t] = y[t] - y[t-1] (diferen�a)
# - rdiff: z[t] = (y[t] - y[t-1]) / y[t-1] (diferen�a %)
# - rdiff_from: z[t] = (y[latest] - y[t]) / y[t] (incremento % em rela��o � �ltima observa��o)
# - cumul:  z[t] = y[0] + y[1] + . + y[t] (soma acumulativa)
# - normalize: z[t] = y[t] � y[0] * 100 (s�rie iniciar em 100)
ipca = Quandl("BCB/433", transform = "diff", start_date = "1996-01-01")
# Coletar definido o tipo de dado que queremos no R
# - ts: s�rie temporal
# - zoo: objeto zoo 
# - xts: no formato xts
# Detalhes sobre a diferen�a entre os tipos no link abaixo
# https://stackoverflow.com/questions/33714660/what-is-the-difference-the-zoo-object-and-ts-object-in-r
ipca = Quandl("BCB/433", start_date = "1996-01-01", type = "xts")
# Alterar o nome da coluna do objeto para IPCA
colnames(ipca)="IPCA"
############## salvando como s�rie temporal
ipca2 = Quandl("BCB/433", start_date = "1996-01-01", type = "ts")
# Visualizar os dados usando o pacote dygraphs. Mais detalhes em
# https://rstudio.github.io/dygraphs/
dygraphs::dygraph(ipca2, main = "�ndice Nacional de Pre�os ao Consumidor-Amplo (IPCA)") %>% dyRangeSelector()





########################## dados financeiros - yahoo e google finan�as e FRED: Federal Reserve Bank of St. Louis - pacote quantmod" 
############## link para compreender as funcionalidades e exemplos    https://www.quantmod.com/examples/data/

library(quantmod)
suppressMessages(require(PerformanceAnalytics))

############ Acessar o site do Yahoo Finance (https://finance.yahoo.com/), escolher uma a��o de interesse e seu c�digo. Por exemplo:
############ a a��o da Vale negociada na BM&F BOVESPA que tem o c�digo VALE3.SA. Aten��o para o caso de a��es negociadas em v�rias bolsas. Ao pesquisar pelo nome da empresa aparecer� a bolsa na qual ela est� sendo negociada e voc� deve escolher para a bolsa que quer coletar os dados.


# Coletar os dados da VALE3.SA do Yahoo Finance. Temos as seguintes op��es:
# - google: Google Finance
# - FRED: Federal Reserve Bank of St. Louis
# A op��o auto.assign define se os dados devem ser incorporados no R com o nome
# do symbol ou um nome espec�fico (auto.assign = FALSE). No nosso caso, optamos
# pelo nome vale.
vale = quantmod::getSymbols("VALE3.SA", src = "yahoo", auto.assign = FALSE)
# Coletar os dados para um per�odo espec�fico
vale = quantmod::getSymbols("VALE3.SA", src = "yahoo", auto.assign = FALSE, from = '2015-01-01', to = '2016-12-31')
# Coletar os dados de uma data espec�fica at� a �ltima observa��o dispon�vel sobre a a��o
vale = quantmod::getSymbols("VALE3.SA", src = "yahoo", auto.assign = FALSE, from = '2018-01-01')
# Coletar definido o tipo de dado que queremos no R
# - ts: s�rie temporal
# - zoo: objeto zoo 
# - xts: no formato xts
vale = quantmod::getSymbols("VALE3.SA", src = "yahoo", auto.assign = FALSE, from = '2017-01-01', return.class = 'xts')
# Formato da sa�da
knitr::kable(head(vale), align = "c")

## Open: O pre�o de abertura nas datas especificadas
## High: O pre�o da alta nas datas especificadas
## Low: O pre�o da baixa nas datas especificadas
## Close: O pre�o de fechamento nas datas especificadas
## Volume: O volume nas datas especificadas
## Adjusted: O pre�o de fechamento ajustado depois de aplicar distribui��es de dividendos ou divis�o da a��o.


# Calcular o log-retorno di�rio usando o log(p_t) - log(p_t-1). 
# Outra op��o � o retorno di�rio por meio da op��o method = "discrete"
daily_return = PerformanceAnalytics::Return.calculate(vale$VALE3.SA.Close, method = "log")
# Alterar o nome da coluna do objeto para VALE3.SA
colnames(daily_return)="VALE3.SA"
# Visualizar os dados usando o pacote dygraphs. Mais detalhes em
dygraphs::dygraph(daily_return, main = "Retorno Di�rio da VALE3.SA") %>% dyRangeSelector()





