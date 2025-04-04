extends HBoxContainer


var display_health := 3.0
var target_health := 3.0
var health := 3.0
var max_health := 3.0

func _ready() -> void:
	Game.health_display = self
	# warning-ignore:narrowing_conversion
	set_max_health(max_health)
	SignalBus.connect("player_health_changed", self, "_on_Player_health_changed")


func _process(_delta: float) -> void:
	update_health_display()


func update_health_display() -> void:
	var health_bars_amount := get_child_count()

	for i in health_bars_amount:
		var health_bar := get_child(i)
		var health_damage := 1.0 - clamp(target_health - i, 0, 1)
		var health_fill = clamp(display_health - i, 0, 1)

		health_bar.material.set_shader_param("health_damage", health_damage)
		health_bar.material.set_shader_param("health_fill", health_fill)


func take_damage(amount: float) -> void:
	health -= amount
	get_tree().create_tween().tween_property(self, "target_health", health, 0.05)
	yield(get_tree().create_timer(0.4), "timeout")
	get_tree().create_tween().tween_property(self, "display_health", target_health, 0.4)


func _on_Player_health_changed(new_health: float, old_health: float) -> void:
	var difference = new_health - old_health
	# health goes down
	#if difference < 0:
	take_damage(-difference)


func set_max_health(num: int) -> void:
	if get_child_count() == num:
		return

	while get_child_count() > num:
		var c := get_child(0)
		c.queue_free()
		remove_child(c)

	while get_child_count() < num:
		var instance = load("res://src/ui/health/health_cell.tscn").instance()
		add_child(instance)

	yield(get_tree(), "idle_frame")
	update_health_display()
