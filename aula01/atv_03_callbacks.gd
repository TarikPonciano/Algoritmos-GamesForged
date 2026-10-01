extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Rodou o _ready")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print("Rodou o _process")
	set_process(false)

func _init() -> void:
	print("Rodoiu o _init")
	
func _enter_tree() -> void:
	print("Rodou o _enter_tree")
	
func _exit_tree() -> void:
	print("Rodou o _exit_tree")
