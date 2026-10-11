class_name ObjectHandling
extends RefCounted

var world: Node3D
var held_id=""
var pressed_id=""
var press_at=Vector2.ZERO
var original=Transform3D.IDENTITY
var candidate=Vector3.ZERO
var valid_drop=false
var marker: MeshInstance3D
var carry_glow: MeshInstance3D
var tether: MeshInstance3D
var preview_hold = false

func _init(owner_node: Node3D) -> void:
	world=owner_node
	marker=MeshInstance3D.new();var mesh=TorusMesh.new();mesh.inner_radius=.55;mesh.outer_radius=.63;marker.mesh=mesh;world.add_child(marker);marker.visible=false
	carry_glow=MeshInstance3D.new();var orbit=TorusMesh.new();orbit.inner_radius=.45;orbit.outer_radius=.48;carry_glow.mesh=orbit;carry_glow.material_override=WorldProps.material(Color("f6d58d"),true);world.add_child(carry_glow);carry_glow.visible=false
	tether=WorldProps.cylinder(world,Vector3.ZERO,.013,1,Color("92e5c9"));tether.material_override=WorldProps.material(Color("92e5c9"),true);tether.visible=false

func body_for(id: String) -> StaticBody3D:
	for node in world.object_nodes[id].get_children():
		if node is StaticBody3D:return node
	return null

func pick(mouse: Vector2) -> String:
	var camera: Camera3D=world.player.camera
	var from=camera.project_ray_origin(mouse)
	var query=PhysicsRayQueryParameters3D.create(from,from+camera.project_ray_normal(mouse)*120,3,[world.player.get_rid()])
	var hit=world.get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty() and hit.collider.has_meta("word_id"):
		var id=str(hit.collider.get_meta("word_id"))
		if world.distance_to_object(id)<9:return id
	return ""

func handle(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE and held_id!="":cancel();return true
	if world.screen!=null or not world.session_started:return false
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		if event.pressed:
			pressed_id=pick(event.position);press_at=event.position
			if pressed_id!="":world.player.point_target=world.object_nodes[pressed_id].global_position+Vector3.UP*.5;world.player.pointing=true
		else:
			if held_id!="":drop()
			elif pressed_id!="":world.inspect_word(pressed_id)
			pressed_id=""
		return true
	if event is InputEventMouseMotion and pressed_id!="" and held_id=="" and event.position.distance_to(press_at)>7:
		var obj: Node3D=world.object_nodes[pressed_id]
		var dims: Vector3=obj.get_meta("dimensions")
		if maxf(dims.x,maxf(dims.y,dims.z))>3.5 or world.by_id[pressed_id].size>3:
			world.toast("This large object is anchored. Click to inspect it.");return true
		start(pressed_id)
		return true
	return held_id!="" and event is InputEventMouseMotion

func start(id: String) -> void:
	held_id=id;original=world.object_nodes[id].transform;candidate=original.origin
	world.player.carrying=true
	var body=body_for(id);world.player.carry_rid=body.get_rid();body.collision_layer=0
	if is_instance_valid(world.card):world.card.hide()
	world.toast("Drag onto a clear floor or countertop. Release to place. Esc cancels.")

func update() -> void:
	if held_id=="":
		world.player.carrying=false;carry_glow.visible=false;tether.visible=false
		world.player.pointing=false
		if world.screen==null and world.session_started:
			var id=pick(world.get_viewport().get_mouse_position())
			if id!="":
				world.player.point_target=world.object_nodes[id].global_position+Vector3.UP*.6;world.player.pointing=true
		return
	if world.screen!=null:cancel();return
	# GUI buttons can consume mouse-up; still release a drag safely next frame.
	if not preview_hold and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):drop();pressed_id="";return
	var obj: Node3D=world.object_nodes[held_id]
	var camera: Camera3D=world.player.camera
	var mouse=world.get_viewport().get_mouse_position();var from=camera.project_ray_origin(mouse)
	var excluded: Array[RID]=[world.player.get_rid(),body_for(held_id).get_rid()]
	var ray=PhysicsRayQueryParameters3D.create(from,from+camera.project_ray_normal(mouse)*100,1,excluded)
	var hit=world.get_world_3d().direct_space_state.intersect_ray(ray)
	valid_drop=false
	if not hit.is_empty():
		candidate=hit.position+Vector3.UP*.035
		if hit.normal.y>.75 and candidate.distance_to(world.player.position)<10 and absf(candidate.x)<580 and absf(candidate.z)<500:
			var dims: Vector3=obj.get_meta("dimensions")
			var query=PhysicsShapeQueryParameters3D.new();var shape=BoxShape3D.new();shape.size=Vector3(maxf(.28,dims.x-.04),maxf(.2,dims.y-.04),maxf(.28,dims.z-.04));query.shape=shape
			query.transform=Transform3D(obj.basis,candidate+Vector3.UP*(dims.y*.5));query.collision_mask=1;query.exclude=excluded
			valid_drop=world.get_world_3d().direct_space_state.intersect_shape(query,1).is_empty()
		obj.position=candidate+Vector3.UP*.12
	marker.visible=true;marker.position=candidate+Vector3.UP*.02;marker.material_override=WorldProps.material(Color("76d9a5") if valid_drop else Color("e98c7b"),true)
	world.player.point_target=obj.global_position+Vector3.UP*.4;world.player.pointing=true
	carry_glow.visible=true;carry_glow.position=obj.global_position+Vector3.UP*.2
	carry_glow.rotation=Vector3(.3,Time.get_ticks_msec()*.0015,.25)
	var dims: Vector3=obj.get_meta("dimensions")
	carry_glow.scale=Vector3.ONE*clampf(maxf(dims.x,dims.z)*1.25,.6,3.8)
	var start=world.player.arm.global_position;var end=world.player.point_target;var direction=end-start
	tether.visible=direction.length()>.1
	if tether.visible:
		tether.position=(start+end)*.5;tether.scale.y=direction.length()
		if absf(direction.normalized().dot(Vector3.UP))<.999:tether.quaternion=Quaternion(Vector3.UP,direction.normalized())
	world.prompt_label.text="Release to place" if valid_drop else "Move to a clear nearby surface · Esc cancel"

func drop() -> void:
	var obj: Node3D=world.object_nodes[held_id]
	if valid_drop:
		obj.position=candidate;world.object_layout[held_id]=[candidate.x,candidate.y,candidate.z,obj.rotation.y];world.save_progress();world.toast("Placed "+world.by_id[held_id].en)
	else:obj.transform=original;world.toast("No clear placement here. Object returned safely.")
	body_for(held_id).collision_layer=3;held_id="";marker.visible=false;carry_glow.visible=false;tether.visible=false;world.player.carry_rid=RID();world.player.carrying=false

func cancel() -> void:
	if held_id!="":world.object_nodes[held_id].transform=original;body_for(held_id).collision_layer=3
	held_id="";pressed_id="";marker.visible=false;carry_glow.visible=false;tether.visible=false;world.player.carry_rid=RID();world.player.pointing=false;world.player.carrying=false
