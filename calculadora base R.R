# Contsruindo uam calculador apenas com as fun��es do base R

print("Escolhas poss�veis")
print("1. Adi��o")
print('2. Subtra��o')
print("3. Divis�o")
print('4. Multiplica��o')

escolha <- as.integer(readline(prompt = "Escolha sua opera��o: "))

num1 <- as.double(readline(prompt = "Digite o primeiro n�mero: "))
num2 <- as.double(readline(prompt = "Digite o segundo n�mero: "))

resultado <- switch(escolha, (num1+num2), (num1-num2),
                    (num1/num2), (num1*num2))

print(paste("o resultado �: ", resultado))
