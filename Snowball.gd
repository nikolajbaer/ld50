extends RigidBody

signal grabbed

var water_y
var bob
var float_velocity
var floating
var BOB_X = 3 # controls intensity of bob, adjusted to scale
var BOB_FQ = 0.4 # higher makes bob slower
var grabbed
var camera
# https://github.com/christinoleo/godot-plugin-DragDrop3D/blob/master/addons/DragDrop3D/DragDropController.gd
var ray_length = 100
var last_mouse
var can_grab = false
var grab_point

func _ready():
	#BOB_X *= scale.x
	floating = false
	grabbed = false
	camera = get_tree().get_root().get_camera()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if grabbed:
		var mouse = get_viewport().get_mouse_position()

		# https://www.scratchapixel.com/lessons/3d-basic-rendering/minimal-ray-tracer-rendering-simple-shapes/ray-plane-and-ray-disk-intersection
		var n = Vector3(-1,0,0) # intersect plane 45 deg back towards the glacier
		var p0 = grab_point
		var l0 = camera.project_ray_origin(mouse)
		var l = camera.project_ray_normal(mouse).normalized()
		var denom = n.dot(l)
		if denom > 0.0001:
			var p0l0 = p0 - l0
			var t = p0l0.dot(n) / denom
			
			translation = l0 + t * l
			if translation.y < water_y:
				translation.y = water_y
			
	elif floating:
		translation += float_velocity * delta
		if bob < 10: # TODO make this a buoyant force instead..
			translation.y = -1 * (sin(BOB_X*bob)/BOB_X * BOB_FQ/bob) + water_y
			bob += delta

func start_float():
	float_velocity = linear_velocity * 0.5
	float_velocity.y = 0
	set_mode(RigidBody.MODE_KINEMATIC)
	bob = 0.01
	water_y = translation.y
	floating = true
	can_grab = true
	
func start_grab():
	grabbed = true
	floating = false
	grab_point = translation
	set_mode(RigidBody.MODE_KINEMATIC)
	emit_signal("grabbed")

func release_grab(vel):
	grabbed = false
	linear_velocity = vel
	set_mode(RigidBody.MODE_RIGID)

func _on_Snowball_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.is_pressed() and floating:
			start_grab()
