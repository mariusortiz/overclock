class_name Dances
## The dances, and the poses of the jump and the run, as PoseLayer targets.
## A dance is a loop of poses, one per beat, with an up-and-down bounce and
## an optional spin of the whole body; "snap" jumps from pose to pose (robot)
## instead of easing between them.

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
]


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
