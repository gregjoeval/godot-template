## Tool script that forces compilation of ALL .gd and .tscn files in the project.
## Run via: godot --headless --path . --script res://scripts/tools/check_all_scripts.gd
## Uses _process() instead of _init() so autoloads are registered first.
extends SceneTree

var _has_run := false


func _process(_delta: float) -> bool:
	if _has_run:
		return false
	_has_run = true

	var gd_files := _collect_files("res://", ".gd")
	var tscn_files := _collect_files("res://", ".tscn")

	var total := gd_files.size() + tscn_files.size()
	print(
		(
			"check_all_scripts: loading %d files (%d .gd, %d .tscn)"
			% [
				total,
				gd_files.size(),
				tscn_files.size(),
			]
		)
	)

	for path: String in gd_files:
		ResourceLoader.load(path)

	for path: String in tscn_files:
		ResourceLoader.load(path)

	print("check_all_scripts: done")
	quit()
	return false


func _collect_files(base_dir: String, extension: String) -> Array[String]:
	var result: Array[String] = []
	var dirs: Array[String] = [base_dir]

	while dirs.size() > 0:
		var current: String = dirs[dirs.size() - 1]
		dirs.resize(dirs.size() - 1)
		var dir := DirAccess.open(current)
		if dir == null:
			continue

		dir.list_dir_begin()
		var entry := dir.get_next()
		while entry != "":
			var full_path := current.path_join(entry)
			if dir.current_is_dir():
				if not _is_excluded(entry):
					dirs.append(full_path)
			elif entry.ends_with(extension):
				result.append(full_path)
			entry = dir.get_next()
		dir.list_dir_end()

	return result


func _is_excluded(dir_name: String) -> bool:
	return dir_name == "addons" or dir_name == ".godot" or dir_name == ".claude"
