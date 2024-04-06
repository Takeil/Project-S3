extends Control

@export var control_ref : Control
@export var particleOccluder : LightOccluder2D
@export var particleEffects : Array[GPUParticles2D] = []
@export var vfx : Array[Node] = []

var effects : Array
var vEffects : Array

class Effect:
	var effect : GPUParticles2D
	var isOpen : bool
	
class VEffect:
	var effect : Node
	var isOpen : bool

@export var thunder_timer: Timer = Timer.new()
var random = RandomNumberGenerator.new()

var effect_list : Array

func _ready():
	for effect in particleEffects:
		var s = Effect.new()
		s.effect = effect
		s.isOpen = false
		effects.append(s)
		effect_list.append(effect.name)
	
	for effect in vfx:
		var s = VEffect.new()
		s.effect = effect
		s.isOpen = false
		vEffects.append(s)
		effect_list.append(effect.name)
	
	random.randomize()
	thunder_timer.connect("timeout", _on_thunder_timeout)

func _process(delta):
	_change_effects_size()

func _change_effects_size():	
	
	var points : PackedVector2Array = [Vector2(control_ref.size.x,10), Vector2(control_ref.size.x,-10), Vector2(-control_ref.size.x,-10), Vector2(-control_ref.size.x,10)]

	particleOccluder.occluder.polygon = points
	particleOccluder.position.y = control_ref.size.y
	
	for item in effects:
		var effect = item.effect
		
		if (effect.name.to_lower() == "rain" or effect.name.to_lower() == "snow" or item.effect.name.to_lower() == "leaf"):
			# Top center, fill x scale
			_change_transform_settings(effect,  Vector2(control_ref.size.x/200, 1), Vector2(control_ref.size.x/2, 0))
		
		if (effect.name.to_lower() == "fire"):
			# Bottom center, fill x scale
			_change_transform_settings(effect,  Vector2(control_ref.size.x/200, 1), Vector2(control_ref.size.x/2, control_ref.size.y))
		
		if (effect.name.to_lower() == "smoke"):
			# Center, fill scale
			_change_transform_settings(effect,  Vector2(control_ref.size.x/150, control_ref.size.y/150), Vector2(control_ref.size.x/2, control_ref.size.y/2))
		
		pass

func _change_transform_settings(node : Node, new_scale : Vector2, new_position : Vector2):
	node.scale = new_scale
	node.position = new_position

func open_particle(_name : String):
	for item in effects:
		var effect = item.effect
		var isOpen = item.isOpen
		
		if (effect.name.to_lower() == _name.to_lower()):
			if (isOpen):
				return
			
			item.isOpen = true
			var animation_controller = effect.get_child(0)
			animation_controller.play("open")
	
	for item in vEffects:
		var effect = item.effect
		var isOpen = item.isOpen
		
		if (effect.name.to_lower() == _name.to_lower()):
			if (isOpen):
				return
			
			item.isOpen = true
			var animation_controller = effect.get_child(0)
			animation_controller.play("play")
			
			if (effect.name.to_lower() == "thunder"):
				thunder_timer.wait_time = random.randi_range(30, 60)
				thunder_timer.start()

func close_particle(_name : String):
	for item in effects:
		var effect = item.effect
		var isOpen = item.isOpen
		
		if (effect.name.to_lower() == _name.to_lower()):
			if (isOpen):
				item.isOpen = false
				var animation_controller = effect.get_child(0)
				animation_controller.play("close")
	
	for item in vEffects:
		var effect = item.effect
		var isOpen = item.isOpen
		
		if (effect.name.to_lower() == "thunder"):
			if (isOpen):
				thunder_timer.stop()
	
func open_debug():
	print("OPEN PARTICLE!")
	open_particle("rain")

func close_debug():
	print("CLOSE PARTICLE!")
	close_particle("rain")

func _on_thunder_timeout():
	for item in vEffects:
		var effect = item.effect
		var isOpen = item.isOpen
		
		if (isOpen):
			if (effect.name.to_lower() == "thunder"):
				var animation_controller = effect.get_child(0)
				animation_controller.play("play")
