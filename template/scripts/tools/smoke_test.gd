extends SceneTree
## Smoke test: loads the main scene, runs ~120 frames, then quits.
## Errors in autoload _ready() or scene loading will cause Godot to emit
## SCRIPT ERROR: on stderr or crash with non-zero exit.
## Uses run/main_scene from project.godot so this works without modification.

var _frame_count := 0
const MAX_FRAMES := 120


func _initialize() -> void:
	var main_scene_path: String = ProjectSettings.get_setting(
		"application/run/main_scene", ""
	)
	if main_scene_path.is_empty():
		print("SMOKE TEST FAIL: run/main_scene not set in project.godot")
		quit(1)
		return

	var scene: PackedScene = load(main_scene_path)
	if scene == null:
		print("SMOKE TEST FAIL: could not load %s" % main_scene_path)
		quit(1)
		return
	var instance: Node = scene.instantiate()
	root.add_child(instance)


func _process(_delta: float) -> bool:
	_frame_count += 1
	if _frame_count >= MAX_FRAMES:
		print("SMOKE TEST PASS: %d frames completed" % _frame_count)
		quit(0)
		return true
	return false
