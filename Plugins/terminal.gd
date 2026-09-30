extends CanvasLayer
## Terminal da turma: um console de texto dentro da janela do jogo.
##
## Instalação (uma vez por projeto):
##   1. Copie este arquivo para res://terminal/terminal.gd
##   2. Projeto › Configurações do Projeto › Globais › Autoload
##   3. Caminho: res://terminal/terminal.gd · Nome: Terminal · Adicionar
##
## Terminal.escrever() funciona como o print(): recebe vários valores
## separados por vírgula, junta tudo sem espaço e pula uma linha.
##
##   Terminal.escrever("Vida: ", vida, "/", vida_max)
##   var nome: String = await Terminal.perguntar("Seu nome: ")
##   var idade: int = await Terminal.perguntar_int("Sua idade: ")
##   var altura: float = await Terminal.perguntar_float("Altura (m): ")
##   var salvar: bool = await Terminal.confirmar("Salvar?")
##   var opcao: int = await Terminal.menu("MENU", ["Jogar", "Sair"])
##
## Toda função que pergunta precisa de await ("espere a resposta").
## O terminal só aparece nas cenas que o usam.
## Requer Godot 4.5 ou mais nova (funções com "...").

signal _linha_enviada(texto: String)

## Aumente para letras maiores. Em telas Retina o valor é dobrado sozinho.
const TAMANHO_FONTE := 22
const COR_FUNDO := Color("#1d2229")
const COR_TEXTO := Color("#cdcfd2")
const COR_PERGUNTA := "#66e6ff"
const COR_RESPOSTA := "#ffeda1"
const COR_ERRO := "#ff7085"
const COR_DISCRETA := "#939aa5"

var _saida: RichTextLabel
var _entrada: LineEdit
var _escala: float = 1.0


func _ready() -> void:
	layer = 100
	visible = false
	# No Mac com tela Retina, a Godot desenha em pixels físicos:
	# sem isso, as letras ficariam com metade do tamanho.
	_escala = maxf(1.0, DisplayServer.screen_get_scale())
	_montar_tela()


# --- Funções para os alunos ---------------------------------------------

## Funciona como print(): Terminal.escrever("Vida: ", vida)
## Aceita cores como print_rich(): "[color=yellow]Cuidado![/color]"
## Também repete o texto no painel Saída.
func escrever(...partes: Array) -> void:
	var texto := _juntar(partes)
	visible = true
	_saida.append_text(texto + "\n")
	print_rich(texto)


## Escreve uma mensagem de erro em vermelho.
func erro(...partes: Array) -> void:
	escrever("[color=", COR_ERRO, "]", _juntar(partes), "[/color]")


## Mostra a pergunta e espera o usuário digitar e teclar Enter.
## Devolve sempre um texto (String).
func perguntar(...partes: Array) -> String:
	return await _perguntar_texto(_juntar(partes))


## Pergunta até receber um número inteiro válido.
func perguntar_int(...partes: Array) -> int:
	var pergunta := _juntar(partes)
	var resposta: String = await _perguntar_texto(pergunta)
	while not resposta.is_valid_int():
		erro("Digite um número inteiro. Exemplo: 42")
		resposta = await _perguntar_texto(pergunta)
	return resposta.to_int()


## Pergunta até receber um número válido. Aceita vírgula ou ponto.
func perguntar_float(...partes: Array) -> float:
	var pergunta := _juntar(partes)
	var resposta: String = await _perguntar_texto(pergunta)
	resposta = resposta.replace(",", ".")
	while not resposta.is_valid_float():
		erro("Digite um número. Exemplo: 3.5")
		resposta = await _perguntar_texto(pergunta)
		resposta = resposta.replace(",", ".")
	return resposta.to_float()


## Pergunta sim ou não. Devolve true para "s" e false para "n".
func confirmar(...partes: Array) -> bool:
	var pergunta := _juntar(partes) + " (s/n)"
	var resposta: String = await _perguntar_texto(pergunta)
	resposta = resposta.to_lower()
	while resposta != "s" and resposta != "n":
		erro("Responda s ou n.")
		resposta = await _perguntar_texto(pergunta)
		resposta = resposta.to_lower()
	return resposta == "s"


## Mostra as opções numeradas e devolve o número escolhido (1, 2, 3...).
func menu(titulo: String, opcoes: Array) -> int:
	escrever()
	escrever("[b]", titulo, "[/b]")
	for i in opcoes.size():
		escrever("  ", i + 1, ") ", opcoes[i])
	var escolha: int = await perguntar_int("Escolha uma opção: ")
	while escolha < 1 or escolha > opcoes.size():
		erro("Opção inválida: digite um número de 1 a ", opcoes.size(), ".")
		escolha = await perguntar_int("Escolha uma opção: ")
	return escolha


## Espera o usuário teclar Enter.
func pausar(mensagem: String = "Tecle Enter para continuar...") -> void:
	await _perguntar_texto("[color=" + COR_DISCRETA + "]" + mensagem + "[/color]")


## Apaga tudo o que está escrito no terminal.
func limpar() -> void:
	_saida.clear()


## Mostra uma mensagem final e desliga a caixa de digitação.
func encerrar(mensagem: String = "Fim do programa.") -> void:
	escrever()
	escrever("[color=", COR_DISCRETA, "]", mensagem, "[/color]")
	_entrada.editable = false
	_entrada.placeholder_text = ""


# --- Funcionamento interno ------------------------------------------------

func _perguntar_texto(pergunta: String) -> String:
	visible = true
	if not pergunta.ends_with(" "):
		pergunta += " "
	_saida.append_text("[color=" + COR_PERGUNTA + "]" + pergunta + "[/color]")
	_entrada.editable = true
	_entrada.grab_focus()
	var resposta: String = await _linha_enviada
	_entrada.editable = false
	_saida.append_text("[color=" + COR_RESPOSTA + "]" + _escapar(resposta) + "[/color]\n")
	print_rich(pergunta, _escapar(resposta))
	return resposta


func _ao_enviar(texto: String) -> void:
	if not _entrada.editable:
		return
	_entrada.clear()
	_linha_enviada.emit(texto.strip_edges())


func _juntar(partes: Array) -> String:
	var texto := ""
	for parte in partes:
		texto += str(parte)
	return texto


func _escapar(texto: String) -> String:
	return texto.replace("[", "[lb]")


func _montar_tela() -> void:
	var tamanho := roundi(TAMANHO_FONTE * _escala)
	var margem := roundi(24 * _escala)

	var fonte := SystemFont.new()
	fonte.font_names = PackedStringArray(["SF Mono", "Menlo", "Monaco", "Consolas", "DejaVu Sans Mono", "monospace"])
	var fonte_negrito := SystemFont.new()
	fonte_negrito.font_names = fonte.font_names
	fonte_negrito.font_weight = 700

	var fundo := PanelContainer.new()
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = COR_FUNDO
	estilo.set_content_margin_all(margem)
	fundo.add_theme_stylebox_override("panel", estilo)
	add_child(fundo)

	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", roundi(12 * _escala))
	fundo.add_child(coluna)

	_saida = RichTextLabel.new()
	_saida.bbcode_enabled = true
	_saida.scroll_following = true
	_saida.selection_enabled = true
	_saida.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_saida.add_theme_font_override("normal_font", fonte)
	_saida.add_theme_font_override("bold_font", fonte_negrito)
	_saida.add_theme_font_size_override("normal_font_size", tamanho)
	_saida.add_theme_font_size_override("bold_font_size", tamanho)
	_saida.add_theme_color_override("default_color", COR_TEXTO)
	coluna.add_child(_saida)

	_entrada = LineEdit.new()
	_entrada.placeholder_text = "Digite aqui e tecle Enter"
	_entrada.editable = false
	_entrada.add_theme_font_override("font", fonte)
	_entrada.add_theme_font_size_override("font_size", tamanho)
	_entrada.text_submitted.connect(_ao_enviar)
	coluna.add_child(_entrada)
