extends Node2D

signal hovered
signal hovered_off

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# all cards must be a child of Cardmanager or this will error
	get_parent().connect_card_signals(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
