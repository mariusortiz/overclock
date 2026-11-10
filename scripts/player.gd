class_name Player
extends CharacterBody3D
## Third-person shooter character: always faces the camera direction.
## Yaw rotates the whole body, pitch only tilts the camera arm.

@export var move_speed := 6.0
@export var acceleration := 40.0
@export var jump_velocity := 5.5
@export var mouse_sensitivity := 0.0025
@export var touch_sensitivity := 0.006
@export var min_pitch_deg := -60.0
@export var max_pitch_deg := 35.0

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _spring_arm: SpringArm3D = $CameraPivot/SpringArm3D


func _ready() -> void:
	_spring_arm.add_excluded_object(get_rid())
	_spring_arm.rotation.x = deg_to_rad(-15.0)


## Rotates the view. `relative` is a screen-space drag in pixels.
func look(relative: Vector2, sensitivity: float) -> void:
	rotate_y(-relative.x * sensitivity)
	var pitch := _spring_arm.rotation.x - relative.y * sensitivity
	_spring_arm.rotation.x = clampf(pitch, deg_to_rad(min_pitch_deg), deg_to_rad(max_pitch_deg))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		look(event.relative, mouse_sensitivity)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var target := transform.basis * Vector3(input.x, 0.0, input.y) * move_speed
	velocity.x = move_toward(velocity.x, target.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target.z, acceleration * delta)

	move_and_slide()
