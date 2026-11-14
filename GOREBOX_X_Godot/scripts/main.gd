extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const DUMMY_SCRIPT = preload("res://scripts/dummy.gd")
var player
var hp := 100
var hp_label: Label

func _ready():
	_build_world()
	_build_player()
	_build_hud()
	spawn_dummy(Vector3(0, 0, -5))

func _mat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 1.0
	return m

func _box(parent: Node3D, name: String, pos: Vector3, size: Vector3, color: Color):
	var body := StaticBody3D.new()
	body.name = name
	body.position = pos
	parent.add_child(body)
	var mesh := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mesh.mesh = bm
	mesh.material_override = _mat(color)
	body.add_child(mesh)
	var shape := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	shape.shape = bs
	body.add_child(shape)

func _build_world():
	_box(self, "TileFloor", Vector3(0, -0.25, 0), Vector3(36, 0.5, 36), Color(0.48, 0.5, 0.52))
	for x in range(-8, 9):
		for z in range(-8, 9):
			if (x + z) % 2 == 0:
				var tile := MeshInstance3D.new()
				var mesh := BoxMesh.new()
				mesh.size = Vector3(1.95, 0.015, 1.95)
				tile.mesh = mesh
				tile.position = Vector3(x * 2, 0.01, z * 2)
				tile.material_override = _mat(Color(0.54, 0.56, 0.58))
				add_child(tile)
	_box(self, "BackWall", Vector3(0, 3, -17), Vector3(36, 6, 0.7), Color(0.42, 0.44, 0.46))
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -25, 0)
	light.light_energy = 0.8
	add_child(light)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	e.sky = Sky.new()
	e.sky.sky_material = ProceduralSkyMaterial.new()
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.7, 0.75, 0.8)
	e.ambient_light_energy = 0.6
	env.environment = e
	add_child(env)

func _build_player():
	player = CharacterBody3D.new()
	player.name = "Player"
	player.set_script(PLAYER_SCRIPT)
	player.position = Vector3(0, 1.1, 3)
	add_child(player)

func _build_hud():
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)
	hp_label = Label.new()
	hp_label.text = "HP: 100"
	hp_label.position = Vector2(24, 20)
	hp_label.add_theme_font_size_override("font_size", 28)
	root.add_child(hp_label)
	var title := Label.new()
	title.text = "GOREBOX X"
	title.position = Vector2(24, 58)
	root.add_child(title)
	_add_button(root, "JUMP", Vector2(-190, -170), Vector2(150, 65), "jump")
	_add_button(root, "KNIFE", Vector2(-190, -90), Vector2(150, 65), "attack")
	_add_button(root, "SPAWN", Vector2(-360, -90), Vector2(150, 65), "spawn")
	_add_button(root, "▲", Vector2(35, -190), Vector2(75, 65), "forward")
	_add_button(root, "▼", Vector2(35, -55), Vector2(75, 65), "back")
	_add_button(root, "◀", Vector2(-45, -120), Vector2(75, 65), "left")
	_add_button(root, "▶", Vector2(115, -120), Vector2(75, 65), "right")

func _add_button(root: Control, caption: String, offset: Vector2, size: Vector2, action: String):
	var b := Button.new()
	b.text = caption
	b.custom_minimum_size = size
	b.anchor_left = 1.0
	b.anchor_right = 1.0
	b.anchor_top = 1.0
	b.anchor_bottom = 1.0
	b.offset_left = offset.x
	b.offset_right = offset.x + size.x
	b.offset_top = offset.y
	b.offset_bottom = offset.y + size.y
	b.modulate = Color(1, 1, 1, 0.72)
	root.add_child(b)
	b.button_down.connect(func(): _action(action, true))
	b.button_up.connect(func(): _action(action, false))

func _action(action: String, pressed: bool):
	if action == "spawn" and pressed:
		spawn_dummy(player.global_position + -player.global_transform.basis.z * 5.0)
	elif action == "attack" and pressed:
		player.attack()
	else:
		player.set_touch_action(action, pressed)

func spawn_dummy(pos: Vector3):
	var d := CharacterBody3D.new()
	d.set_script(DUMMY_SCRIPT)
	d.position = pos
	add_child(d)
