class_name WorldEditorLayout
extends RefCounted

# Traversal IDs come from the deterministic world builder, independent of names.
static func spatial_nodes(root: Node) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for child in root.get_children():
		if child is Node3D:
			result.append(child)
		result.append_array(spatial_nodes(child))
	return result

static func read_edits(root: Node) -> Dictionary:
	var edits: Dictionary = {}
	var layout = root.get_node_or_null("EditableWorld")
	if layout == null:
		return edits
	for node in spatial_nodes(layout):
		if node.has_meta("layout_index") and node.has_meta("original_transform"):
			if not node.transform.is_equal_approx(node.get_meta("original_transform")):
				edits[int(node.get_meta("layout_index"))] = {"transform": node.transform, "original": node.get_meta("original_transform"), "class": node.get_class(), "word_id": node.get_meta("word_id", "")}
	root.remove_child(layout)
	layout.free()
	return edits

static func apply_edits(root: Node, edits: Dictionary) -> void:
	var nodes = spatial_nodes(root)
	for index in edits:
		if index >= 0 and index < nodes.size():
			var edit = edits[index]
			var node = nodes[index]
			if node.get_class() == edit['class'] and node.get_meta('word_id', '') == edit.word_id and node.transform.is_equal_approx(edit.original):
				node.transform = edit.transform
			else:
				push_warning('World builder changed; regenerate editor preview before applying layout edit ' + str(index))
