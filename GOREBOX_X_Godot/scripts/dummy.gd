extends CharacterBody3D

var health := 100
var knocked := false
var fall_timer := 0.0

func _ready():
	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.38
	shape.height = 1.7
	col.shape = shape
	col.position.y = 0.85
	add_child(col)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.48, 0.5, 0.52)
	var torso := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.7, 0.85, 0.35)
	torso.mesh = mesh
	torso.position.y = 1.05
	torso.material_override = mat
	add_child(torso)
	var head := MeshInstance3D.new()
	var hm := BoxMesh.new()
	hm.size = Vector3(0.48, 0.48, 0.48)
	head.mesh = hm
	head.position.y = 1.75
	head.material_override = mat
	add_child(head)
	for side in [-1.0, 1.0]:
		_add_limb(Vector3(side * 0.48, 1.05, 0), Vector3(0.18, 0.75, 0.18), mat)
		_add_limb(Vector3(side * 0.2, 0.35, 0), Vector3(0.22, 0.7, 0.22), mat)

func _add_limb(pos: Vector3, size: Vector3, mat: Material):
	var limb := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	limb.mesh = bm
	limb.position = pos
	limb.material_override = mat
	add_child(limb)

func take_hit(impulse: Vector3):
	health -= 35
	velocity += impulse + Vector3.UP * 2.2
	knocked = true
	fall_timer = 0.8
	if health <= 0:
		queue_free()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= 18.0 * delta
	elif not knocked:
		velocity.x = move_toward(velocity.x, 0, delta * 4)
		velocity.z = move_toward(velocity.z, 0, delta * 4)
	move_and_slide()
	if knocked:
		fall_timer -= delta
		if fall_timer <= 0:
			knocked = false
