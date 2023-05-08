extends Sprite2D

@export var bullet_amount := 1
@export var automatic     := true
@export var bullet_speed  := 800.0
@export var firerate      := 8
@export var spread        := 5
@export var recoil        := 15.0
@export var damping       := 0.0
@export var lifetime      := 10.0
@export var speed_random  := 0.0
@export var projectile_scene : PackedScene

@export var shake_strength := 2

var can_shoot = false
@onready var world  := get_parent().get_parent().get_parent()
@onready var player := get_parent().get_parent()
@onready var anchor := get_parent()
@onready var cursor := get_parent().get_parent().get_node("UI/cursor")

func _ready():
	$reload_timer.wait_time = 1.0 / firerate

func _process(delta):
	
	anchor.rotation = (get_global_mouse_position() - anchor.global_position).angle()
	
	if abs(get_shoot_angle()) > PI * 0.5:
		anchor.scale.y = -1
	else:
		anchor.scale.y = 1
	
	anchor.show_behind_parent = get_shoot_angle() < 0
	
	if should_shoot():
		shoot()

func should_shoot():
	return (
		(Input.is_action_pressed("lclick") and automatic and can_shoot) or
		(Input.is_action_just_pressed("lclick") and can_shoot)
	)

func get_shoot_angle():
	return anchor.rotation

func shoot():
	can_shoot = false
	
	var barrel_end = $barrel_end.global_position
	
	# animation
	$AnimationPlayer.play("shoot")
	player.camera.shake(shake_strength, 8, 0.1, rad_to_deg(get_shoot_angle()))
	cursor.animate()
	VfxManager.play_vfx("gun_shoot", barrel_end, get_shoot_angle())
	
	# shooting
	for i in bullet_amount:
		var projectile = projectile_scene.instantiate()
		
		projectile.global_position = barrel_end
		projectile.velocity = Vector2(bullet_speed, .0).rotated(get_shoot_angle())
		projectile.velocity = projectile.velocity.rotated(deg_to_rad(randf_range(-spread * 0.5, spread * 0.5)))
		projectile.velocity *= randf_range(1.0 - speed_random, 1.0 + speed_random)
		projectile.damping  = damping
		projectile.lifetime = lifetime
		
		world.add_child(projectile)
	
	player.knockback -= Vector2(recoil, 0).rotated(get_shoot_angle())
	
	$reload_timer.start()


func reload():
	can_shoot = true
