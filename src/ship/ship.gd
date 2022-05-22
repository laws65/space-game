extends KinematicBody2D
class_name Ship


export var team: int = 0

signal inventory_updated(array, slot, item)
signal module_added(module)
signal module_removed(module)
signal health_changed(new_health, old_health)


var velocity: Vector2
var acceleration: Vector2

var gun_slot := [null]
var modules: Array
var storage: Array

var modules_amount: int = 6
var storage_size: int = 16

var health := 3.0


func _ready() -> void:
	modules.resize(modules_amount)
	storage.resize(storage_size)


func set_gun_item(gun_item: Item) -> void:
	var gun: Gun
	if is_instance_valid(gun_item):
		gun = gun_item.get_scene()
	set_gun(gun)


func set_gun(new_gun: Gun) -> void:
	var old_gun := get_gun()
	if is_instance_valid(old_gun):
		remove_child(old_gun)

	if is_instance_valid(new_gun):
		new_gun.set_ship(self)
		add_child(new_gun)

	gun_slot = [new_gun]


func has_gun() -> bool:
	return is_instance_valid(get_gun())


func get_gun() -> Gun:
	return gun_slot[0]


func find_empty_slot_in_array(array: Array) -> int:
	for i in array.size():
		var item := array[i] as Item
		if not is_instance_valid(item):
			return i
	return -1


func set_module(module_item: Item, index: int) -> void:
	if index >= modules_amount:
		return

	var old_module_item := modules[index] as Item
	if is_instance_valid(old_module_item):
		var old_module := old_module_item.get_scene() as Module
		if is_instance_valid(old_module):
			emit_signal("module_removed", old_module)

	modules[index] = module_item

	var module: Module = module_item.get_scene()
	if is_instance_valid(module):
		emit_signal("module_added", module)


func remove_module(module_item: Item) -> void:
	if not is_instance_valid(module_item):
		return

	if module_item in modules:
		var index := modules.find(module_item)
		modules[index] = null

	var module: Module = module_item.get_scene()
	if is_instance_valid(module):
		emit_signal("module_removed", module)


func add_to_inventory(array: Array, slot: int, item: Item) -> void:
	assert(slot >= 0, "Invalid index for item")
	assert(slot < array.size(), "Invalid index for item")

	if array == modules:
		#var old_module := modules[slot] as Item
		#if is_instance_valid(old_module):
			#remove_module(old_module)
		if is_instance_valid(item):
			set_module(item, slot)
	elif array == storage:
		storage[slot] = item
	elif array == gun_slot:
		set_gun_item(item)

	emit_signal("inventory_updated", array, slot, item)


func quick_add_to_inventory(item: Item) -> bool:
	if not is_instance_valid(item):
		return false

	# if resource
	if item.type & 4 > 0:
		Game.add_unobtainium(item.level)
		return true

	var target_array: Array
	var target_index: int

	# if doesn't have gun and is gun equip it
	if item.type & 2 > 0 and not has_gun():
		target_array = gun_slot
		target_index = 0

	# if is module attempt to add it
	elif item.type & 1 > 0:
		var modules_index := find_empty_slot_in_array(modules)
		if modules_index >= 0:
			target_array = modules
			target_index = modules_index

	# if has room in storage add it
	else:
		var storage_index := find_empty_slot_in_array(storage)
		if storage_index >= 0:
			target_array = storage
			target_index = storage_index

	if target_array:
		add_to_inventory(target_array, target_index, item)
		return true
	return false


func hit(_hitter: Node2D, damage: float) -> void:
	take_damage(damage)


func take_damage(damage: float) -> void:
	var old_health := health
	health -= damage
	emit_signal("health_changed", health, old_health)
