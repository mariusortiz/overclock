class_name Dances
## The dances, and the poses of the jump and the run, as PoseLayer targets.
## A dance is a loop of poses, one per beat, with an up-and-down bounce and
## an optional spin of the whole body; "snap" jumps from pose to pose (robot)
## instead of easing between them. The first six are everyone's; those with
## "shop" are sold in the shop (by their "id").

const BEAT := 0.42  # seconds

const JUMP := {
	"UpperArm.L": Vector3(-35, 0, 55), "UpperArm.R": Vector3(-35, 0, -55),
	"LowerArm.L": Vector3(-30, 0, 0), "LowerArm.R": Vector3(-30, 0, 0),
	"UpperLeg.L": Vector3(-45, 0, 0), "UpperLeg.R": Vector3(-20, 0, 0),
	"LowerLeg.L": Vector3(70, 0, 0), "LowerLeg.R": Vector3(50, 0, 0),
	"Torso": Vector3(10, 0, 0),
}
const RUN := {"Torso": Vector3(10, 0, 0), "Head": Vector3(-6, 0, 0)}

static var LIST: Array[Dictionary] = [
	{
		"name": "ROBOT", "snap": true, "bounce": 0.0, "spin": 0.0,
		"poses": [
			PoseLayer.symmetric({"UpperArm": Vector3(-80, 0, 15), "LowerArm": Vector3(0, 0, 0)}, {"Torso": Vector3(0, 25, 0)}),
			PoseLayer.symmetric({"UpperArm": Vector3(-80, 0, 15), "LowerArm": Vector3(-80, 0, 0)}, {"Torso": Vector3(0, 25, 0), "Head": Vector3(0, -20, 0)}),
			PoseLayer.symmetric({"UpperArm": Vector3(-80, 0, 15), "LowerArm": Vector3(0, 0, 0)}, {"Torso": Vector3(0, -25, 0)}),
			PoseLayer.symmetric({"UpperArm": Vector3(-80, 0, 15), "LowerArm": Vector3(-80, 0, 0)}, {"Torso": Vector3(0, -25, 0), "Head": Vector3(0, 20, 0)}),
		],
	},
	{
		"name": "DISCO", "snap": false, "bounce": 0.06, "spin": 0.0,
		"poses": [
			{"UpperArm.R": Vector3(0, 0, -150), "UpperArm.L": Vector3(-20, 0, 30), "LowerArm.L": Vector3(-90, 0, 0), "Hips": Vector3(0, 0, 8)},
			{"UpperArm.R": Vector3(-30, 0, -20), "UpperArm.L": Vector3(-20, 0, 30), "LowerArm.L": Vector3(-90, 0, 0), "Hips": Vector3(0, 0, -8)},
		],
	},
	{
		"name": "VAGUE", "snap": false, "bounce": 0.04, "spin": 0.0,
		"poses": [
			PoseLayer.symmetric({"UpperArm": Vector3(0, 0, 80), "LowerArm": Vector3(0, 0, 30)}, {"Torso": Vector3(0, 0, 12)}),
			PoseLayer.symmetric({"UpperArm": Vector3(0, 0, 70), "LowerArm": Vector3(0, 0, -30)}, {"Torso": Vector3(0, 0, -12)}),
		],
	},
	{
		"name": "BRAS EN L'AIR", "snap": false, "bounce": 0.12, "spin": 0.0,
		"poses": [
			PoseLayer.symmetric({"UpperArm": Vector3(0, 0, 165)}, {"Head": Vector3(-15, 0, 0)}),
			PoseLayer.symmetric({"UpperArm": Vector3(0, 0, 130), "LowerArm": Vector3(0, 0, 40)}, {"Head": Vector3(10, 0, 0)}),
		],
	},
	{
		"name": "PAS CHASSÉ", "snap": false, "bounce": 0.05, "spin": 0.0,
		"poses": [
			{"UpperLeg.L": Vector3(-35, 0, 0), "LowerLeg.L": Vector3(30, 0, 0), "UpperArm.L": Vector3(30, 0, 20),
					"UpperArm.R": Vector3(-30, 0, -20), "Torso": Vector3(0, 10, 0)},
			{"UpperLeg.R": Vector3(-35, 0, 0), "LowerLeg.R": Vector3(30, 0, 0), "UpperArm.R": Vector3(30, 0, -20),
					"UpperArm.L": Vector3(-30, 0, 20), "Torso": Vector3(0, -10, 0)},
		],
	},
	{
		# Plays the model's own victory animation, with hops and a spin.
		"name": "FÊTE", "snap": false, "bounce": 0.15, "spin": 1.6, "animation": &"victory",
		"poses": [{}, {}],
	},
	# Sold in the shop.
	{
		# A hand on the forehead for the loser, the head shaking.
		"id": "dance_loser", "shop": true, "name": "LOSER", "snap": false, "bounce": 0.03, "spin": 0.0,
		"poses": [
			{"UpperArm.R": Vector3(-95, 0, 10), "LowerArm.R": Vector3(-120, 0, 0), "UpperArm.L": Vector3(-10, 0, 25),
					"Head": Vector3(10, 0, 10), "Hips": Vector3(0, 0, 6), "Torso": Vector3(0, 12, 0)},
			{"UpperArm.R": Vector3(-95, 0, 10), "LowerArm.R": Vector3(-120, 0, 0), "UpperArm.L": Vector3(-10, 0, 25),
					"Head": Vector3(10, 0, -10), "Hips": Vector3(0, 0, -6), "Torso": Vector3(0, -12, 0)},
		],
	},
	{
		# Easy does it: palms down, a slow sway of the hips.
		"id": "dance_easy", "shop": true, "name": "TOUT DOUX", "snap": false, "bounce": 0.02, "spin": 0.0,
		"poses": [
			PoseLayer.symmetric({"UpperArm": Vector3(-45, 0, 25), "LowerArm": Vector3(-35, 0, 0)}, {"Hips": Vector3(0, 0, 12), "Torso": Vector3(0, 0, -6), "Head": Vector3(-8, 0, 0)}),
			PoseLayer.symmetric({"UpperArm": Vector3(-25, 0, 25), "LowerArm": Vector3(-5, 0, 0)}, {"Hips": Vector3(0, 0, -12), "Torso": Vector3(0, 0, 6), "Head": Vector3(-8, 0, 0)}),
		],
	},
	{
		"id": "dance_dab", "shop": true, "name": "DAB", "snap": true, "bounce": 0.0, "spin": 0.0,
		"poses": [
			{"UpperArm.L": Vector3(0, 0, 130), "UpperArm.R": Vector3(-70, 0, 40), "LowerArm.R": Vector3(-110, 0, 0),
					"Head": Vector3(35, 0, -20), "Torso": Vector3(10, 0, -8)},
			{"UpperArm.R": Vector3(0, 0, -130), "UpperArm.L": Vector3(-70, 0, -40), "LowerArm.L": Vector3(-110, 0, 0),
					"Head": Vector3(35, 0, 20), "Torso": Vector3(10, 0, 8)},
		],
	},
	{
		# Elbows flapping, head pecking.
		"id": "dance_chicken", "shop": true, "name": "POULET", "snap": false, "bounce": 0.08, "spin": 0.0,
		"poses": [
			PoseLayer.symmetric({"UpperArm": Vector3(0, 0, 50), "LowerArm": Vector3(0, 0, -150)}, {"Head": Vector3(25, 0, 0), "Torso": Vector3(15, 0, 0)}),
			PoseLayer.symmetric({"UpperArm": Vector3(0, 0, 15), "LowerArm": Vector3(0, 0, -150)}, {"Head": Vector3(-10, 0, 0), "Torso": Vector3(5, 0, 0)}),
		],
	},
	{
		# Arms turning like windmill sails, one after the other.
		"id": "dance_windmill", "shop": true, "name": "MOULINET", "snap": false, "bounce": 0.04, "spin": 0.5,
		"poses": [
			{"UpperArm.R": Vector3(0, 0, -170), "UpperArm.L": Vector3(0, 0, 10)},
			{"UpperArm.R": Vector3(0, 0, -90), "UpperArm.L": Vector3(0, 0, 90)},
			{"UpperArm.R": Vector3(0, 0, -10), "UpperArm.L": Vector3(0, 0, 170)},
			{"UpperArm.R": Vector3(0, 0, -90), "UpperArm.L": Vector3(0, 0, 90)},
		],
	},
	{
		# A spin on one leg, arms out.
		"id": "dance_spin", "shop": true, "name": "TOUPIE", "snap": false, "bounce": 0.0, "spin": 4.0,
		"poses": [
			PoseLayer.symmetric({"UpperArm": Vector3(0, 0, 90)}, {"UpperLeg.L": Vector3(-60, 0, 0), "LowerLeg.L": Vector3(90, 0, 0)}),
			PoseLayer.symmetric({"UpperArm": Vector3(0, 0, 100), "LowerArm": Vector3(0, 0, 20)}, {"UpperLeg.L": Vector3(-50, 0, 0), "LowerLeg.L": Vector3(80, 0, 0)}),
		],
	},
]


## Indices in LIST of the dances the player can dance: everyone's, and those
## bought in the shop.
static func available() -> Array[int]:
	var indices: Array[int] = []
	for index in LIST.size():
		if not LIST[index].get("shop", false) or Wallet.owns(LIST[index].id):
			indices.append(index)
	return indices


## The pose of `dance` at `time` seconds into it.
static func pose_at(dance: Dictionary, time: float) -> Dictionary:
	var poses: Array = dance.poses
	var beat := time / BEAT
	var index := floori(beat) % poses.size()
	var next := (index + 1) % poses.size()
	if dance.snap:
		return poses[index]
	var t := smoothstep(0.0, 1.0, beat - floorf(beat))
	return PoseLayer.blend(poses[index], poses[next], t)


## Height of the bounce at `time`, in meters: one hop per beat.
static func bounce_at(dance: Dictionary, time: float) -> float:
	return dance.bounce * absf(sin(PI * time / BEAT))


## The dance with this "id" (the shop's), or {}.
static func find(id: String) -> Dictionary:
	for dance in LIST:
		if dance.get("id", "") == id:
			return dance
	return {}
