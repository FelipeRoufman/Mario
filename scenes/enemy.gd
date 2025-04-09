extends Area2D

class_name Enemy

signal points_scored(points:int)
const points_label_scene = preload("res://scenes/points_label.tscn")

@export var horizontal_speed = 20
@export var vertical_speed = 100

@onready var ray_cast_2d = $RayCast2D as RayCast2D
@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D
@onready var left_wall_ray = $LeftWallRay as RayCast2D
@onready var right_wall_ray = $RightWallRay as RayCast2D
var is_alive = true

func _process(delta: float) -> void:
	if !is_alive: return
	
	position.x -= horizontal_speed * delta
	
	handle_movement_collisions()

func handle_movement_collisions():
	
	if not ray_cast_2d.is_colliding():
		reverse_direction()
		return
	
	if moving_left() and left_wall_ray.is_colliding():
		reverse_direction()
	elif moving_right() and right_wall_ray.is_colliding():
		reverse_direction()

func moving_left() -> bool:
	return horizontal_speed > 0

func moving_right() -> bool:
	return horizontal_speed < 0

func reverse_direction():
	horizontal_speed *= -1
	animated_sprite_2d.flip_h = not animated_sprite_2d.flip_h
	position.y += 1 

func die():
	is_alive = false
	horizontal_speed = 0
	vertical_speed = 0
	animated_sprite_2d.play("dead")
	
func die_from_hit():
	is_alive = false
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	rotation_degrees = 180
	horizontal_speed = 0
	vertical_speed = 0

	var die_tween = get_tree().create_tween()
	die_tween.tween_property(self, "position", position + Vector2(0, -25), .2)
	die_tween.chain().tween_property(self, "position", position + Vector2(0, 500), 4)
	
	var points_label = points_label_scene.instantiate()
	points_label.position = self.position + Vector2(-20, -20)
	get_tree().root.add_child(points_label)
	points_scored.emit(100)
