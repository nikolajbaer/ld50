extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var scene = preload("res://Scenes/root.tscn")



# Called when the node enters the scene tree for the first time.
func _ready():
	$"Scene/Title card cam".set_current(true)


	
func _input(event):
	if event is InputEventKey:
		print("starting!!")
		get_tree().change_scene_to(scene)

