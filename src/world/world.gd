extends Node2D

var asteroid = load("res://src/asteroid/asteroid.tscn")

func _ready() -> void:
	randomize()

	$Camera2D.target = $Player

	$CanvasLayer/UI/Inventory.set_ship($Player)

	for _i in 20:
		var asteroid_instance = asteroid.instance()
		asteroid_instance.position = Vector2(
			rand_range(100, 3000),
			rand_range(100, 2000)
		)
		add_child(asteroid_instance)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test_reload"):
		get_tree().reload_current_scene()


func create_ground_item(item: Item) -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	var screen_centre := get_viewport_rect().size/2
	var throw_velocity := (mouse_pos - screen_centre) * 2.41

	var ground_item_instance = load("res://src/ground_item/ground_item.tscn").instance()
	ground_item_instance.item_representing = item
	ground_item_instance.global_position = $Camera2D.global_position
	ground_item_instance.velocity = throw_velocity
	add_child(ground_item_instance)
