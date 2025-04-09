extends CharacterBody2D

class_name Player

signal points_scored(points:int)

enum PlayerMode{small, big, shooting}
var player_mode = PlayerMode.small
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
const points_label_scene = preload("res://scenes/points_label.tscn")
var is_dead = false

@onready var animated_sprite_2d = $AnimatedSprite2D as PlayerAnimatedSprite
@onready var area_collision_shape_2d = $Area2D/AreaCollisionShape2D
@onready var body_collision_shape_2d = $BodyCollisionShape2D
@onready var area_2d = $Area2D

@export_group("Locomotion")
@export var run_speed_damping = 0.5
@export var speed = 100
@export var jump_velocity = -350

@export_group("Stomping Enemies")
@export var min_stomp_degree = 10
@export var max_stomp_degree = 170
@export var stomp_y_velocity = -150

func _physics_process(delta):

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

	var direction = Input.get_axis("left", "right")

	if direction:
		velocity.x = direction * speed 
	else:
		velocity.x = 0
	animated_sprite_2d.trigger_animation(velocity, direction, player_mode)
	move_and_slide ()

func _on_area_2d_area_entered(area):
	if area is Enemy:
		handle_enemy_collision(area)

func handle_enemy_collision(enemy: Enemy) :
	if enemy == null:
		return
	if is_instance_of(enemy, Koopa) and (enemy as Koopa).in_a_shell:
		(enemy as Koopa). on_stomp(global_position)
	else:
		var angle_of_collision = rad_to_deg(position.angle_to_point(enemy.position))
		
		if angle_of_collision > min_stomp_degree && angle_of_collision < max_stomp_degree:
			enemy.die()
			on_enemy_stomped ()
			spawn_points_label(enemy)
		else:
			die()

func on_enemy_stomped () :
	velocity.y = stomp_y_velocity

func spawn_points_label(enemy):
	var points_label = points_label_scene.instantiate()
	points_label.position = enemy.position + Vector2(-20, -20)
	get_tree().root.add_child(points_label)
	points_scored.emit(100)
func die():
	if player_mode == PlayerMode.small:
		is_dead = true
		animated_sprite_2d.play("small_death")
		set_physics_process(false)
		var death_tween = get_tree().create_tween()
		death_tween.tween_property(self,"position", position + Vector2(0, -45), .5)
		death_tween.chain().tween_property(self,"position", position + Vector2(0,500), 1)
		death_tween.tween_callback(func (): get_tree().reload_current_scene())
		
