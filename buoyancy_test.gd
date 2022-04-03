extends Spatial

var Snowball = preload("res://Scenes/SnowballB.tscn")
var Splash = preload("res://Splash.tscn")
var t
const rate = 5
var current_snowball

func _ready():
	t=0
	add_snowball()

func add_snowball():
	var b = Snowball.instance()
	b.translation = $Spawn.global_transform.origin
	b.translation.x += rand_range(-5,5)
	b.scale *= rand_range(0.85,1.75)
	b.rotation.x = rand_range(-1,1)
	b.rotation.z = rand_range(-1,1)
	b.linear_velocity = Vector3(0,0,rand_range(1,3))
	b.connect("grabbed",self,"_snowball_grabbed",[b])
	b.add_to_group("snowballs")
	add_child(b)

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if not event.is_pressed() and current_snowball:
			current_snowball.release_grab()
			current_snowball = null

func _physics_process(delta):
	t += delta
	for b in get_tree().get_nodes_in_group("snowballs"):
		if b.global_transform.origin.y <= 0:
			b.melt(delta)

func _snowball_grabbed(snowball):
	current_snowball = snowball

func splash(location):
	var s = Splash.instance()
	s.translation = location
	add_child(s)

func _on_Ocean_body_entered(body):
	#body.melt(0.1)
	splash(body.global_transform.origin)
