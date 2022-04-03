extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var scene = preload("res://Scenes/root.tscn")



# Called when the node enters the scene tree for the first time.
func _ready():
	$"Scene/Title card cam".set_current(true)
	$Scene/AnimationPlayer.play("berg-moving")


	
func _input(event):
	if event is InputEventKey:
		$Scene/Bloom.play("camera-effects")


func _on_Bloom_animation_finished(anim_name):
	get_tree().change_scene_to(scene)
