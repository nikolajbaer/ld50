extends Spatial

onready var sea_level_label = $HUD/VBoxContainer/HBoxContainer/SeaLevel
var Snowball = preload("res://Scenes/Snowball.tscn")

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
var game_on = false
var glacier_start

const GLACIER_SPEED = 0.1

const INEVITABLE_LEVEL = 100 # Total Submersion

onready var tween = $Tween

func _ready():
	rate = 3.0
	t = 0
	flow_vel = 0
	flow_vec = $Scene/Glacier/CollisionShape.global_transform.basis.z.normalized()
	release_z = $Scene/Glacier/DropPoint.global_transform.origin.z # plane which when crossed snow falls back off the glacier
	restored_snow = []
	melt_level = 0
	start_sea_level = $Scene/Ocean.global_transform.origin.y
	# TODO change for start game button
	game_on = true

func _process(delta):
	if not game_on: return
	
	if t > rate:
		t = 0
		var b = Snowball.instance()
		b.translation = $Scene/Glacier/Spawn.global_transform.origin
		b.translation.x += rand_range(-5,5)
		b.scale *= rand_range(0.85,1.75)
		b.rotation.x = rand_range(-1,1)
		b.rotation.z = rand_range(-1,1)
		b.linear_velocity = Vector3(0,0,rand_range(1,3))
		b.connect("grabbed",self,"_snowball_grabbed",[b])
		b.add_to_group("snowballs")
		add_child(b)
		rate *= rand_range(0.95,1.0)
	else:
		t += delta
	flow_vel += delta * GLOBAL_WARMING
	
	var water_level = start_sea_level + melt_level * MELT_SPEED
	var water_change = water_level - $Scene/Ocean.translation.y
	$Scene/Ocean.translation.y = water_level # TODO Tween
	
	for snow in get_tree().get_nodes_in_group("snowballs"):
		if snow.is_stuck() and snow.global_transform.origin.z > release_z:
			snow.release_from_ice()
		elif snow.is_floating():
			snow.water_y += water_change	 # TODO Tween

	$Scene/Glacier.translation.z += GLACIER_SPEED * delta

	if melt_level > INEVITABLE_LEVEL:
		game_over()

func _on_Ocean_body_entered(body):
	if body.get_mode() == RigidBody.MODE_RIGID:
		#print("starting float")
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
		
func game_over():
	game_on = false
	$HUD/GameOverLabel.visible = true
