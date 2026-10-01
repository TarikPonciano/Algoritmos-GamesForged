extends Node2D

#Declaração de Variáveis
var nome = "Tarik"

func _ready() -> void:
	Terminal.escrever("Olá meu nome é [b]%s[/b]." % nome)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
