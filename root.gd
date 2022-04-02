extends Spatial

var Rock = preload("res://Snowball.tscn")

var rate
var t
var current_snowball

func _ready():
	rate = 3.0
	t = 0

func _process(delta):
	if t > rate:
		t = 0
		var b = Rock.instance()
		b.translation = $Spawn.translation
		b.translation.x += rand_range(-5,5)
		b.scale *= rand_range(0.5,1.5)
		b.rotation.x = rand_range(-1,1)
		b.rotation.z = rand_range(-1,1)
		b.connect("grabbed",self,"_snowball_grabbed",[b])
		add_child(b)
		rate *= rand_range(0.95,1.0)
	else:
		t += delta

func _on_Area_body_entered(body):
	if body.get_mode() == RigidBody.MODE_RIGID:
		body.start_float()	

func _snowball_grabbed(snowball):
	current_snowball = snowball

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if not event.is_pressed() and current_snowball:
			current_snowball.release_grab(Vector3())
			current_snowball = null
