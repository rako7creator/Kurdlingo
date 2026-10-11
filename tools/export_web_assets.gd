extends SceneTree

class Snapshot extends "res://scripts/main.gd":
	func _ready() -> void:
		english_font=load("res://assets/NotoSans.ttf")
		sorani_font=load("res://assets/NotoSansArabic.ttf")
		vocabulary=JSON.parse_string(FileAccess.get_file_as_string("res://data/vocabulary.json"))
		for row in vocabulary:by_id[row.id]=row
		build_world()

var target=OS.get_environment("KURDLINGO_WEB_ASSETS")
func _init()->void:
	if target.is_empty():target=ProjectSettings.globalize_path("res://../KurdLingo-Web/assets")
func _initialize() -> void:call_deferred("export_world")

func export_node(node: Node3D,path: String) -> void:
	var document=GLTFDocument.new();var state=GLTFState.new()
	var err=document.append_from_scene(node,state)
	assert(err==OK,"Cannot encode "+path)
	err=document.write_to_filesystem(state,path)
	assert(err==OK,"Cannot export "+path)

func gather_meshes(original: Node3D,holder: Node3D,transform: Transform3D = Transform3D.IDENTITY) -> void:
	var combined=transform*original.transform
	if original is MeshInstance3D:
		var mesh=MeshInstance3D.new();mesh.mesh=original.mesh;mesh.transform=combined;mesh.material_override=original.material_override
		if original.name=="KurdistanFlag":
			var flag_mat=StandardMaterial3D.new();flag_mat.albedo_texture=load("res://assets/kurdistan_flag.svg");flag_mat.cull_mode=BaseMaterial3D.CULL_DISABLED;mesh.material_override=flag_mat
		for i in range(original.mesh.get_surface_count()):
			if original.get_surface_override_material(i):mesh.set_surface_override_material(i,original.get_surface_override_material(i))
		holder.add_child(mesh)
	for child in original.get_children():
		if child is Node3D:gather_meshes(child,holder,combined)

func export_world() -> void:
	DirAccess.make_dir_recursive_absolute(target+"/models")
	var game=Snapshot.new();root.add_child(game)
	var circle=TeacherCircle.new();circle.world=game;circle.build_circle()
	var teacher_copy=Node3D.new();gather_meshes(circle,teacher_copy);export_node(teacher_copy,target+"/teacher.glb");teacher_copy.free();circle.free()
	var rows=[]
	for row in game.vocabulary:
		var prop=game.object_nodes[row.id]
		var item=row.duplicate();item["position"]=[prop.position.x,prop.position.y,prop.position.z]
		var dim: Vector3=prop.get_meta("dimensions");item["dimensions"]=[dim.x,dim.y,dim.z]
		rows.append(item)
		var copy=Node3D.new();var saved=prop.position;prop.position=Vector3.ZERO;gather_meshes(prop,copy);prop.position=saved
		export_node(copy,target+"/models/"+row.id+".glb");copy.free()
	var file=FileAccess.open(target+"/vocabulary.json",FileAccess.WRITE);file.store_string(JSON.stringify(rows));file.close()
	var alien=WorldProps.alien();export_node(alien,target+"/alien.glb");alien.free()
	for kind in ["robot","human"]:
		var visual=WorldProps.make("custom/"+kind,2.0);export_node(visual,target+"/"+kind+".glb");visual.free()
	# Context scenery divided into chunks; learning objects stream separately.
	var exclusions={}
	for node in game.object_nodes.values():exclusions[node]=true
	for node in game.guardians.values():exclusions[node]=true
	for node in game.rescue_cells.values():exclusions[node]=true
	var chunks={}
	for child in game.get_children():
		if not child is Node3D or exclusions.has(child) or child is Label3D:continue
		if child.get_child_count()==0 and not child is MeshInstance3D:continue
		var point=child.position;var key=str(int(floor((point.x+250)/100)))+"_"+str(int(floor((point.z+240)/100)))
		if not chunks.has(key):chunks[key]=Node3D.new()
		gather_meshes(child,chunks[key])
	var scenery=[]
	for key in chunks:
		if chunks[key].get_child_count()==0:continue
		var name="scenery_"+key+".glb";export_node(chunks[key],target+"/"+name);chunks[key].free();scenery.append(name)
	file=FileAccess.open(target+"/scenery.json",FileAccess.WRITE);file.store_string(JSON.stringify(scenery));file.close()
	print("MOBILE EXPORT PASS: ",rows.size()," models, ",scenery.size()," scenery chunks.")
	game.free();quit()
