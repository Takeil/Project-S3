extends Control

@export var control_ref : Control
@export var particleOccluder : LightOccluder2D
@export var effects : Array[GPUParticles2D] = []

func _process(delta):
	_change_effects_size()

func _change_effects_size():	
	
	var points : PackedVector2Array = [Vector2(control_ref.size.x,10), Vector2(control_ref.size.x,-10), Vector2(-control_ref.size.x,-10), Vector2(-control_ref.size.x,10)]

	particleOccluder.occluder.polygon = points
	for effect in effects:
		
		if (effect.name == "Rain"):
			# Top center, fill x scale
			_change_effect_settings(effect,  Vector2(control_ref.size.x/200, 1), Vector2(control_ref.size.x/2, 0))
		
		if (effect.name == "Fire"):
			# Bottom center, fill x scale
			_change_effect_settings(effect,  Vector2(control_ref.size.x/200, 1), Vector2(control_ref.size.x/2, control_ref.size.y))
		
		if (effect.name == "Smoke"):
			# Center, fill scale
			_change_effect_settings(effect,  Vector2(control_ref.size.x/150, control_ref.size.y/150), Vector2(control_ref.size.x/2, control_ref.size.y/2))
		
		pass

func _change_effect_settings(effect : GPUParticles2D, new_scale : Vector2, new_position : Vector2):
	effect.scale = new_scale
	effect.position = new_position

func open_particle(_name : String):
	for effect in effects:
		if (effect.name == _name):
			var animation_controller = effect.get_child(0)
			animation_controller.play("open")

func close_particle(_name : String):
	for effect in effects:
		if (effect.name == _name):
			var animation_controller = effect.get_child(0)
			animation_controller.play("close")
	
func open_debug():
	print("OPEN PARTICLE!")
	open_particle("Rain")

func close_debug():
	print("CLOSE PARTICLE!")
	close_particle("Rain")

# dynamic changing of transform to fit effect
# enable / disable effects
# create / add at least 10 effects
