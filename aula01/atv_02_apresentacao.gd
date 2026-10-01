extends Node2D

var nome = "Tarik"
var idade = 30
var cidade = "Fortaleza"
var vida = 42
var jogo = "Path of Exile"
var fase = 10


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Olá! Eu sou %s." % nome)
	print("%s %d %s" % [nome, idade, cidade])
	prints(nome,idade,cidade)
	print("Fase %03d | Vida %d%%" % [fase, vida])
	Terminal.escrever("Jogo favorito: [color=brown]%s[/color]" % jogo)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _exit_tree() -> void:
	print("TESTE")
