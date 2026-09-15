extends Node2D
#Tipos de Variável

#Primitivos: String(str), Integer(int), Float(float), Boolean (bool)

#Complexos: Listas, dicionários, etc

#Expanda o código abaixo para declarar a idade e altura do usuário. Na função ready, imprima a ficha do usuário. Ex:
#Nome: {nome}
#Idade: {idade} anos
#Altura: {altura} metros


#DECLARAÇÃO DE VARIÁVEIS
var nome = "Michael" #String(str)

#EXECUTAR O CÓDIGO NO CARREGAMENTO
func _ready() -> void:
	#print("Seja bem vindo,"+nome)
	#
	#print("Seja bem vindo,",nome)
	
	#Método principal de impressão
	#%s %d %f
	print("Seja bem vindo, %s" % [nome])
	
	
