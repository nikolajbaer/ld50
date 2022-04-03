extends RigidBody

var water_level
const g = -9.8 # acceleration of graviy

const DRAG_COEFFICIENT = 250 # https://en.wikipedia.org/wiki/Drag_coefficient of sphere

const BF = 0.8

const MELT_RATE = 0.05 # melt 5% every second

var grab_point

var camera
var state
enum {FREE,GRABBED,STUCK}
var flow_velocity

const MAX_GRAB_VEL = 10
var grab_vel
var melt_amount

signal grabbed

func _ready():
	water_level = 0
	mass = 1000 # TODO scale to 
	camera = get_tree().get_root().get_camera()
	state = FREE
	melt_amount = 0
	set_process(true)

func _process(delta):
	if state == GRABBED:			
		var mouse = get_viewport().get_mouse_position()

		# https://www.scratchapixel.com/lessons/3d-basic-rendering/minimal-ray-tracer-rendering-simple-shapes/ray-plane-and-ray-disk-intersection
		var n = Vector3(-1,0,0) # Y/Z plane
		var p0 = grab_point
		var l0 = camera.project_ray_origin(mouse)
		var l = camera.project_ray_normal(mouse).normalized()
		var denom = n.dot(l)
		var oldtranslation = translation
		if abs(denom) > 0.0001:
			var p0l0 = p0 - l0
			var t = p0l0.dot(n) / denom			
			translation = l0 + t * l
			if translation.y < water_level:
				translation.y = water_level
			translation.z = clamp(translation.z,-30,grab_point.z+20)
		grab_vel = translation - oldtranslation
		var gv = grab_vel.length()/delta
		if gv > MAX_GRAB_VEL:
			gv = MAX_GRAB_VEL
		grab_vel = grab_vel.normalized() * gv
	elif state == STUCK:
		translation += flow_velocity * delta
	
func _physics_process(delta):
	if get_mode() == RigidBody.MODE_KINEMATIC: return
	
	var pos = global_transform.origin
	var buoyant_force = Vector3()
	var drag_force = Vector3()
	var radius = scale.x
	if pos.y - radius < water_level: # if we are in the water
		var h = water_level - ( pos.y - radius ) # distance underwater
		var a = radius
		if h < radius: # if we are less than 1/2way under water
			a = sqrt(pow(radius,2) - pow(radius-h,2)) # radius at water line
		var displacement = clamp(h,0,radius*2)
		var drag = -1 * linear_velocity.length() * DRAG_COEFFICIENT * (PI * pow(a,2))
		buoyant_force = Vector3(0,weight * displacement * BF,0) * delta
		drag_force = linear_velocity.normalized() * drag * delta
	apply_impulse(Vector3.ZERO,buoyant_force + drag_force)
	
	if melt_amount > 0:
		#scale = scale * melt_amount
		#mass = mass * melt_amount
		melt_amount = 0

func stick_to_ice(flow_vel):
	set_mode(RigidBody.MODE_KINEMATIC)
	flow_velocity = flow_vel
	state = STUCK

func release_from_ice():
	set_mode(RigidBody.MODE_RIGID)
	linear_velocity = flow_velocity
	state = FREE

func start_grab():
	state = GRABBED
	grab_point = translation
	grab_vel = Vector3()
	set_mode(RigidBody.MODE_KINEMATIC)
	emit_signal("grabbed")
	#set_collision_layer_bit(0,false)
	#set_collision_layer_bit(1,false)

func release_grab():
	state = FREE
	set_mode(RigidBody.MODE_RIGID)
	#set_collision_layer_bit(0,true)
	#set_collision_layer_bit(1,true)
	linear_velocity = grab_vel

func splash():
	$Particles.emitting = true

func is_stuck():
	return state == STUCK

func is_free():
	return state == FREE

func is_grabbed():
	return state == GRABBED

func _on_SnowballB_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.is_pressed() and state == FREE:
			start_grab()

func melt(delta):
	var x = delta * MELT_RATE
	melt_amount = 1-x
	var radius = scale.x
	var v0 = 4/3.0 * PI * pow(radius,3)
	var v1 = 4/3.0 * PI * pow(radius * (1-x),3)
	return v0 - v1 # change in volume after this melting 
	
