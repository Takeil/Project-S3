extends Control

@export var control_ref : Control
@export var effects : Array[GPUParticles2D] = []

func _process(delta):
	_on_size_change()

func _on_size_change():
	for effect in effects:
		# center, fill screen
		#_change_effect_settings(effect, control_ref.size, Vector2(control_ref.size.x/2, control_ref.size.y/2))
		
		# center, keep x scale
		#_change_effect_settings(effect, Vector2(effect.transform.get_scale().x, control_ref.size.y), Vector2(control_ref.size.x, control_ref.size.y))
		
		# center, keep y scale
		#_change_effect_settings(effect, Vector2(control_ref.size.x, effect.transform.get_scale().y), Vector2(control_ref.size.x, control_ref.size.y))
		
		_change_effect_settings(effect,  Vector2(control_ref.size.x/200, 1), Vector2(control_ref.size.x/2, 0))
		pass

func _change_effect_settings(effect : GPUParticles2D, new_scale : Vector2, new_position : Vector2):
	effect.scale = new_scale
	effect.position = new_position

func open_particle(index : int):
	var animation_controller = effects[index].get_child(0)
	animation_controller.play("open")

func close_particle(index : int):
	var animation_controller = effects[index].get_child(0)
	animation_controller.play("close")
	
func open_debug():
	print("OPEN PARTICLE!")
	open_particle(0)

func close_debug():
	print("CLOSE PARTICLE!")
	close_particle(0)

# dynamic changing of transform to fit effect
# enable / disable effects
# create / add at least 10 effects
