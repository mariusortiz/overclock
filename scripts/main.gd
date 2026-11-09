extends Node3D
## Step 1 test scene: proves the 3D pipeline runs on the phone.

@onready var core: MeshInstance3D = $Core
@onready var camera: Camera3D = $Camera3D
@onready var fps_label: Label = $UI/FpsLabel


func _ready() -> void:
	camera.look_at(Vector3(0, 1, 0))


func _process(delta: float) -> void:
	core.rotate_y(delta * 1.2)
	core.rotate_x(delta * 0.7)
	fps_label.text = "%d FPS" % Engine.get_frames_per_second()
