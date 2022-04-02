extends Spatial

onready var sea_level_label = $HUD/HBoxContainer/SeaLevel
var Rock = preload("res://Snowball.tscn")

var rate
var t
var current_snowball
var flow_vec
var flow_vel # current flow velocity
var release_z
const GLOBAL_WARMING = 0.01# Rate at which ice flow increases (relative to delta seconds)
var restored_snow
var melt_level 
var start_sea_level
const MELT_SPEED = 0.1 # effect of iceberg count on sea level rise 

func _ready():
	rate = 3.0
	t = 0
	flow_vel = 0
	flow_vec = $Glacier/CollisionShape.global_transform.basis.z.normalized()
	release_z = $Glacier/DropPoint.global_transform.origin.z # plane which when crossed snow falls back off the glacier
	restored_snow = []
	melt_level = 0
	start_sea_level = $Ocean.global_transform.origin.y

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
		b.add_to_group("snowballs")
		add_child(b)
		rate *= rand_range(0.95,1.0)
	else:
		t += delta
	flow_vel += delta * GLOBAL_WARMING
	
	for snow in get_tree().get_nodes_in_group("snowballs"):
		if snow.is_stuck() and snow.global_transform.origin.z > release_z:
			snow.release_from_ice()
	$Ocean.translation.y = start_sea_level + melt_level * MELT_SPEED
	
func _on_Ocean_body_entered(body):
	if body.get_mode() == RigidBody.MODE_RIGID:
		body.start_float()
		melt_level += 1
		sea_level_label.text = "%s" % melt_level

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if not event.is_pressed() and current_snowball:
			current_snowball.release_grab(Vector3())
			current_snowball = null

func _snowball_grabbed(snowball):
	current_snowball = snowball

func _on_Glacier_body_entered(body):
	if body.get_mode() == RigidBody.MODE_RIGID:
		body.stick_to_ice(flow_vec * flow_vel)
		
func _on_Ocean_body_exited(body):
	if body.is_grabbed():
		melt_level -= 1	
