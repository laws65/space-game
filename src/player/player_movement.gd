extends Node


var acceleration_speed := 300
var deceleration_speed := 180
var friction := 0.01
var steer_strength := 2.5
var velocity_cutoff := 5
var velocity_rotate_weight := 0.05
var max_speed := 800.0

export var player_path: NodePath
onready var player := get_node(player_path) as Player


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	if not player.is_physics_processing():
		return

	if Game.building_menu_up:
		return

	var input_direction := Input.get_axis("decelerate", "accelerate")
	#if input_direction > 0:
		#if not "assets/sounds/thruster.ogg" in $SoundManager2D.queue:
		#	$SoundManager2D.play("assets/sounds/thruster.ogg")
	add_acceleration(input_direction)
	apply_friction(input_direction)

	steer()

	player.velocity += player.acceleration * delta
	player.velocity = player.move_and_slide(player.velocity)
	player.acceleration = Vector2.ZERO

	cap_speed()


func cap_speed() -> void:
	if player.velocity.length_squared() > pow(max_speed, 2):
		player.velocity = player.velocity.normalized() * max_speed


func steer() -> void:
	var steer_direction := Input.get_axis("turn_left", "turn_right")
	var steer: float = deg2rad(steer_direction * steer_strength)
	player.rotation += steer

	var rotated_velocity := player.velocity.rotated(steer)
	player.velocity = lerp(player.velocity, rotated_velocity, velocity_rotate_weight)


func add_acceleration(input_direction: float) -> void:
	if input_direction > 0.0:
		player.acceleration += player.transform.x * acceleration_speed
	elif input_direction < 0.0:
		player.acceleration -= player.transform.x * deceleration_speed


func apply_friction(input_direction: float) -> void:
	if input_direction == 0:
		player.acceleration -= lerp(player.velocity, Vector2.ZERO, friction)


func _on_Player_module_added(module) -> void:
	if not is_instance_valid(module):
		return
	if module is SpeedModule:
		module.apply(self)


func _on_Player_module_removed(module) -> void:
	if not is_instance_valid(module):
		return
	if module is SpeedModule:
		module.remove(self)
