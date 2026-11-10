"""Generates scenes/arena.tscn (blockout test arena).

Run from the repo root: python3 tools/make_arena.py
Godot serializes Transform3D row by row: basis rows first, then the origin.
"""
import math

IDENTITY = (1, 0, 0, 0, 1, 0, 0, 0, 1)


def rot_x(deg):
    c, s = math.cos(math.radians(deg)), math.sin(math.radians(deg))
    return (1, 0, 0, 0, c, -s, 0, s, c)


def transform(pos, basis=IDENTITY):
    return "Transform3D(%s)" % ", ".join(f"{v:.4g}" for v in basis + tuple(pos))


# (name, size, position, material, basis)
BOXES = [
    ("Floor", (40, 1, 40), (0, -0.5, 0), "floor_material", IDENTITY),
    ("WallNorth", (40, 4, 1), (0, 2, -20.5), "wall_material", IDENTITY),
    ("WallSouth", (40, 4, 1), (0, 2, 20.5), "wall_material", IDENTITY),
    ("WallWest", (1, 4, 42), (-20.5, 2, 0), "wall_material", IDENTITY),
    ("WallEast", (1, 4, 42), (20.5, 2, 0), "wall_material", IDENTITY),
    ("CoverA", (2, 1, 2), (-4, 0.5, 4), "block_material", IDENTITY),
    ("CoverB", (4, 1.2, 1), (3, 0.6, 2), "block_material", IDENTITY),
    ("CoverC", (1, 1.2, 4), (-8, 0.6, -4), "block_material", IDENTITY),
    ("Pillar", (2, 5, 2), (0, 2.5, -6), "accent_material", IDENTITY),
    ("CrateStackLow", (2, 1, 2), (-12, 0.5, 8), "block_material", IDENTITY),
    ("CrateStackHigh", (2, 2, 2), (-12, 1, 10), "block_material", IDENTITY),
    ("Platform", (4, 2, 4), (8, 1, 1.2), "block_material", IDENTITY),
    # Rises toward -Z, from the floor up to the top of Platform.
    ("Ramp", (2.4, 0.3, 6), (8, 0.9, 6), "accent_material", rot_x(20)),
    ("PlatformFar", (6, 1.5, 3), (10, 0.75, -12), "block_material", IDENTITY),
]

# Where robots appear, near the walls.
ENEMY_SPAWNS = [
    (-16, 0.1, -16), (0, 0.1, -17), (16, 0.1, -16), (-17, 0.1, 0),
    (17, 0.1, 8), (-16, 0.1, 16), (16, 0.1, 16),
]

HEADER = """[gd_scene load_steps=12 format=3]

[ext_resource type="Shader" path="res://shaders/grid.gdshader" id="1_grid"]
[ext_resource type="Texture2D" path="res://assets/textures/floor_tiles.png" id="2_floor"]
[ext_resource type="Texture2D" path="res://assets/textures/panel_dark.png" id="3_dark"]
[ext_resource type="Texture2D" path="res://assets/textures/panel_light.png" id="4_light"]
[ext_resource type="Texture2D" path="res://assets/textures/stripes_emission.png" id="5_stripes"]
[ext_resource type="Script" path="res://scripts/arena.gd" id="6_arena"]

[sub_resource type="NavigationMesh" id="navigation_mesh"]
geometry_parsed_geometry_type = 1
agent_height = 1.75
agent_radius = 0.5

[sub_resource type="ShaderMaterial" id="floor_material"]
shader = ExtResource("1_grid")
shader_parameter/floor_texture = ExtResource("2_floor")

[sub_resource type="StandardMaterial3D" id="wall_material"]
albedo_texture = ExtResource("3_dark")
roughness = 0.8
uv1_scale = Vector3(0.5, 0.5, 0.5)
uv1_triplanar = true
uv1_world_triplanar = true

[sub_resource type="StandardMaterial3D" id="block_material"]
albedo_texture = ExtResource("4_light")
roughness = 0.6
uv1_scale = Vector3(0.5, 0.5, 0.5)
uv1_triplanar = true
uv1_world_triplanar = true

[sub_resource type="StandardMaterial3D" id="accent_material"]
albedo_color = Color(0.75, 0.45, 0.85, 1)
albedo_texture = ExtResource("3_dark")
emission_enabled = true
emission = Color(1, 0.24, 0.95, 1)
emission_energy_multiplier = 1.5
emission_operator = 1
emission_texture = ExtResource("5_stripes")
uv1_scale = Vector3(0.5, 0.5, 0.5)
uv1_triplanar = true
uv1_world_triplanar = true

[node name="Arena" type="NavigationRegion3D"]
navigation_mesh = SubResource("navigation_mesh")
script = ExtResource("6_arena")
"""

out = [HEADER]
for name, size, pos, material, basis in BOXES:
    out += [f'[node name="{name}" type="CSGBox3D" parent="."]',
            f"transform = {transform(pos, basis)}",
            "use_collision = true",
            "size = Vector3(%g, %g, %g)" % size,
            f'material = SubResource("{material}")', ""]
out += ['[node name="EnemySpawns" type="Node3D" parent="."]', ""]
for i, pos in enumerate(ENEMY_SPAWNS, 1):
    out += [f'[node name="Spawn{i}" type="Marker3D" parent="EnemySpawns" groups=["enemy_spawns"]]',
            f"transform = {transform(pos)}", ""]
open("scenes/arena.tscn", "w").write("\n".join(out))
