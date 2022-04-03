extends Particles

var life = 0

func _ready():
	emitting = true
	life = 0
	
func _process(delta):
	life += delta
	if life > lifetime:
		# remove myself after particles are over
		queue_free()
