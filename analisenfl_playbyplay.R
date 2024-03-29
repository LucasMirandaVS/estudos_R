## Analise play-by-play dos times da nfl
## O script original vem de um artigo dispon�vel aqui: https://www.r-bloggers.com/2017/10/nfl-series/
## Eu mudei o ano de an�lise pra obter resultados diferentes e colocar outras ferramentas de an�lise

## Primeiro baixei os pacotes
## Esse primeiro eu precisei baixar no github do cara pq n�o tinha no CRAN

library(tidyverse)
library(ggplot2)
library (readr)
library(ggridges)
library(ggjoy)


## Infelizmente a NFL trocou seus servidores e agor n�ao disponibiliza mais esses dados sem autoriza��o.
## Felizmente achei um reposit�rio no github com os dados da temporada regular de 2019. vou trabalhar com eles

urlfile = 'https://raw.githubusercontent.com/ryurko/nflscrapR-data/master/play_by_play_data/regular_season/reg_pbp_2019.csv'
df2019  = read_csv(url(urlfile))

## Pegando todos os jogadores com pelo menos 200 rushes durante a temporada

min_rush_cnt <- 200
rush_cnt <- df2019 %>% filter(play_type == 'run') %>%
  group_by(rusher_player_name) %>% 
  summarise(rush_cnt = n(),
            total_yards = sum(yards_gained),
            mean_yards = round(mean(yards_gained), 2)) %>%
  filter(rush_cnt >= min_rush_cnt) %>%
  arrange(desc(rush_cnt))

# Aqui ja deu pra ver quais s�o os melhores Running Backs da liga em termos de jardas por rush

## Pegando todos os dados de rush dispon�veis

rushing_stats <- df2019 %>%
  filter(play_type == 'run' & rusher_player_name %in% rush_cnt$rusher_player_name & yards_gained <=50) %>%
  filter(down!=4 & !is.na(down)) %>%
  filter(!is.na(run_location))

## Agora vou come�ar a visualizar os dados:
## Comparando a distribui��o de rushes entre o grupo dos melhores

ggplot(rushing_stats, aes(x = yards_gained, y = rusher_player_name, fill= rusher_player_name)) +
  geom_joy(scale = 3) +
  theme_joy() +
  scale_fill_manual(values=rep(c('gray', 'lightblue'), length(rushing_stats$rusher_player_name)/2)) +
  scale_y_discrete(expand = c(0.01, 0)) +
  scale_x_continuous(expand = c(0, 0)) +
  theme(legend.position="none") +
  labs(x="Jardas obtidas por play" ,y="")

# De forma geral, todos tem um desempenho similar. Com destaque pro Gurley, que tem uma distribui��o mais arrojada
# ganha mais jardas pro seu time

# Comparando quandos os rushers s�o usados

usage_stats <- df2019 %>% 
  filter(!is.na(down) & rusher_player_name %in% rush_cnt$rusher_player_name & qtr!=5) %>%
  group_by(rusher_player_name, down, qtr) %>%
  summarise(cnt = n()) %>%
  mutate(quarter_end = paste("Q", qtr, "- Down: ", down, sep=""))

## Agora usando um heatmap pra ver a frequencia com que os running backs s�o usados 
## durante downs espec�fiocs ou quarters
## Pacotes pra visualizar o heatmap
devtools::install_github("talgalili/d3heatmap")
library(d3heatmap)
library(maditr)

## fazendo um pivot dataframe

usage <- usage_stats %>%  dcast(rusher_player_name ~ quarter_end, value.var = "cnt")

## limpando os dados

row.names(usage) <- usage$rusher_player_name
usage <- usage %>% 
  select(-rusher_player_name)
usage[is.na(usage)] <- 0

## normalizando os dados

usage_norm <- t(apply(usage, 1, function(x) x/sum(x)))

## Plotando heatmap de propor��es de rushes nas diferentes posi��es no campo e brechas

p <- d3heatmap(usage_norm,
               colors="Blues",
               Colv=FALSE,
               show_grid=3)

## Salvando em um doc html
install.packages('htmlwidgets')
library(htmlwidgets)

saveWidget(p, file="rusher_usage_down_quarter.html")
# s� conferir o diret�rio antes de rodar essa fun��o. Mas d� pra ver que os running backs s�o usados majoritariamente no primeiro down

## Agora � poss�vel comparar a distribui��o de rushes por downs
## Plotando as posi��es de rush dos melhores running backs

ggplot(data=rushing_stats, aes(x=run_location, y=yards_gained, color=run_location)) +
  geom_jitter(position=position_jitter(0.2)) +
  stat_summary(fun.data=mean_sdl, mult=1, 
               geom="pointrange", color="black") +
  scale_color_brewer(palette="Dark2") + theme_minimal() +
  facet_wrap(~rusher_player_name)

# Deu pra ver que no geral eles correm das mesmas posi��es, mas alguns tem mais corridas mais adiante no campo