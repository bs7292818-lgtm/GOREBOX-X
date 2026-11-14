extends CharacterBody3D

var speed := 5.0
var jump_velocity := 6.5
var look_sensitivity := 0.003
var camera_pivot: Node3D
var camera: Camera3D
var touch_actions := {}
var yaw := 0.0
var pitch := -0.18
var knife_cooldown := 0.0

func _ready():
	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.38
	shape.height = 1.8
	col.shape = shape
	col.position.y = 0.9
	add_child(col)
	var body := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.38
	capsule.height = 1.8
	body.mesh = capsule
	body.position.y = 0.9
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.45, 0.48, 0.5)
	body.material_override = mat
	add_child(body)
	camera_pivot = Node3D.new()
	camera_pivot.position.y = 1.45
	add_child(camera_pivot)
	camera = Camera3D.new()
	camera.position = Vector3(0, 1.0, 5.2)
	camera.rotation.x = -0.15
	camera.current = true
	camera_pivot.add_child(camera)

func _unhandled_input(event):
	if event is InputEventScreenDrag and event.position.x > get_viewport().size.x * 0.42:
		_rotate_view(event.relative)
	elif event is InputEventMouseMotion:
		_rotate_view(event.relative)

func _rotate_view(delta: Vector2):
	yaw -= delta.x * look_sensitivity
	pitch = clamp(pitch - delta.y * look_sensitivity, -0.8, 0.35)
	rotation.y = yaw
	camera_pivot.rotation.x = pitch

func set_touch_action(action: String, pressed: bool):
	touch_actions[action] = pressed

func _physics_process(delta):
	knife_cooldown = maxf(0.0, knife_cooldown - delta)
	var x := float(touch_actions.get("right", false)) - float(touch_actions.get("left", false))
	var z := float(touch_actions.get("back", false)) - float(touch_actions.get("forward", false))
	var dir := (transform.basis * Vector3(x, 0, z)).normalized()
	if dir.length() > 0.01:
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta * 5)
		velocity.z = move_toward(velocity.z, 0, speed * delta * 5)
	if not is_on_floor():
		velocity.y -= 18.0 * delta
	elif touch_actions.get("jump", false):
		velocity.y = jump_velocity
	move_and_slide()

func attack():
	if knife_cooldown > 0:
		return
	knife_cooldown = 0.45
	var from := camera.global_position
	var to := from + -camera.global_transform.basis.z * 2.3
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit and hit.collider.has_method("take_hit"):
		hit.collider.take_hit((hit.position - global_position).normalized() * 7.0)
