extends Area2D

var team: int


var speed = 150
var damage = 0.5

var shooter: Ship

func _ready() -> void:
	$Tween.interpolate_property(self, "speed", speed, speed*10, 1.0, Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween.interpolate_property(self, "scale", Vector2(0.8, 0.8), Vector2.ONE, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	$Tween.start()
	$Fired.emitting = true


func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta

	for body in get_overlapping_bodies():
		if (body is Asteroid
		or  body is Ship and team != body.team):
			if is_instance_valid(shooter):
				body.hit(self, damage * shooter.damage_multiplier)
			$AnimationPlayer.play("impact")


func get_clip_poly() -> Polygon2D:
	return $AsteroidClipArea as Polygon2D
