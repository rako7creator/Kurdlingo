extends RefCounted

# Keep the previous valid save until the staged write is complete.
static func write(path: String, state: Dictionary) -> bool:
	var directory_error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	if directory_error != OK:
		push_warning("Could not create save directory: " + error_string(directory_error))
		return false
	var staged = path + ".tmp"
	var file = FileAccess.open(staged, FileAccess.WRITE)
	if file == null:
		push_warning("Could not open staged save: " + error_string(FileAccess.get_open_error()))
		return false
	file.store_string(JSON.stringify(state))
	file.flush()
	var write_error = file.get_error()
	file.close()
	if write_error != OK or read_dictionary(staged).is_empty():
		push_warning("Staged save could not be verified; existing progress retained.")
		return false
	if not read_dictionary(path).is_empty():
		var backup_error = DirAccess.copy_absolute(ProjectSettings.globalize_path(path), ProjectSettings.globalize_path(path + ".bak"))
		if backup_error != OK:
			push_warning("Could not back up progress; existing save retained: " + error_string(backup_error))
			return false
	var rename_error = DirAccess.rename_absolute(ProjectSettings.globalize_path(staged), ProjectSettings.globalize_path(path))
	if rename_error != OK:
		push_warning("Could not replace progress; existing save and staged data retained: " + error_string(rename_error))
		return false
	return true

static func read_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path): return {}
	var parser = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK or not parser.data is Dictionary: return {}
	return parser.data

static func read(path: String) -> Dictionary:
	var state = read_dictionary(path)
	if not state.is_empty(): return state
	state = read_dictionary(path + ".bak")
	if not state.is_empty(): push_warning("Recovered progress from the previous valid save backup.")
	elif FileAccess.file_exists(path): push_warning("Progress and backup are invalid; existing files retained.")
	return state
