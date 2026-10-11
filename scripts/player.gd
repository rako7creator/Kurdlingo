class_name Explorer
extends CharacterBody3D

var camera: Camera3D
var visual: Node3D
var yaw = 0.0
var pitch = 0.32
var distance = 8.0
const MAX_FUEL=300.0
const FUEL_DRAIN=8.0
var sitting_legs:Node3D
var seated=false
var fuel = MAX_FUEL
var enabled = false
var sensitivity = 0.003
var flying = false
var point_target = Vector3.ZERO
var pointing = false
var arm: Node3D
var carry_rid = RID()
var left_arm: Node3D
var carrying = false
var gesture_blend = 0.0
var riding=false
var boost_energy=100.0
var boosting=false
var boost_recharging=false
var jump_was_down=false
var boost_trail:GPUParticles3D
var ride_visual:Node3D

func toggle_ride()->bool:
	if seated or not enabled:return false
	if not riding and not is_on_floor():return false
	riding=not riding
	return true

func _ready() -> void:
	collision_layer=1
	collision_mask=1
	var shape=CollisionShape3D.new()
	var capsule=CapsuleShape3D.new();capsule.radius=0.38;capsule.height=1.65
	shape.shape=capsule;shape.position.y=0.83;add_child(shape)
	visual=WorldProps.alien();add_child(visual)
	ride_visual=DailyProps.make("electric_scooter");ride_visual.position.y=-.22;visual.add_child(ride_visual);ride_visual.visible=false
	boost_trail=GPUParticles3D.new();boost_trail.amount=28;boost_trail.lifetime=.4;boost_trail.position=Vector3(0,.12,.8);boost_trail.emitting=false;visual.add_child(boost_trail)
	var trail_mesh=SphereMesh.new();trail_mesh.radius=.035;trail_mesh.height=.07;trail_mesh.material=WorldProps.material(Color("7ff5d7"),true);boost_trail.draw_pass_1=trail_mesh
	var trail_material=ParticleProcessMaterial.new();trail_material.direction=Vector3(0,0,1);trail_material.spread=14;trail_material.initial_velocity_min=3;trail_material.initial_velocity_max=6;trail_material.gravity=Vector3(0,.3,0);boost_trail.process_material=trail_material
	arm=Node3D.new();arm.position=Vector3(.43,1.02,-.08);visual.add_child(arm)
	WorldProps.sphere(arm,Vector3(0,0,-.26),Vector3(.19,.2,.62),Color("69d6bd"))
	WorldProps.sphere(arm,Vector3(0,0,-.62),Vector3(.23,.22,.25),Color("69d6bd"))
	WorldProps.sphere(arm,Vector3(0,.02,-.8),Vector3(.08,.09,.23),Color("b5f2da"))
	arm.visible=false
	left_arm=Node3D.new();left_arm.position=Vector3(-.43,1.02,-.08);visual.add_child(left_arm)
	WorldProps.sphere(left_arm,Vector3(0,0,-.26),Vector3(.19,.2,.62),Color("69d6bd"))
	WorldProps.sphere(left_arm,Vector3(0,0,-.62),Vector3(.24,.22,.25),Color("b5f2da"))
	left_arm.visible=false
	sitting_legs=Node3D.new();visual.add_child(sitting_legs);sitting_legs.visible=false
	for side in [-1,1]:
		WorldProps.line(sitting_legs,Vector3(side*.22,.32,-.08),Vector3(side*.22,.32,-.42),.09,Color("173a50"))
		WorldProps.line(sitting_legs,Vector3(side*.22,.32,-.42),Vector3(side*.22,-.27,-.42),.075,Color("173a50"))
		WorldProps.sphere(sitting_legs,Vector3(side*.22,-.31,-.48),Vector3(.25,.15,.35),Color("173a50"))
	floor_snap_length=.4
	camera=Camera3D.new();camera.fov=65;camera.near=0.1;camera.far=500
	get_parent().add_child(camera);camera.current=true

func _unhandled_input(event: InputEvent) -> void:
	if not enabled:return
	if event is InputEventMouseButton:
		if event.button_index==MOUSE_BUTTON_RIGHT:
			Input.mouse_mode=Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE
		if event.pressed and event.button_index==MOUSE_BUTTON_WHEEL_UP:distance=clampf(distance-0.6,3.5,15)
		if event.pressed and event.button_index==MOUSE_BUTTON_WHEEL_DOWN:distance=clampf(distance+0.6,3.5,15)
	if event is InputEventMouseMotion and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
		yaw-=event.relative.x*sensitivity
		pitch=clampf(pitch+event.relative.y*sensitivity,-0.12,0.95)

func _physics_process(delta: float) -> void:
	var move=Vector3.ZERO
	if enabled and not seated:
		var input_x=float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))-float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT))
		var input_z=float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))
		move=Vector3(input_x,0,input_z).rotated(Vector3.UP,yaw).normalized()
	var speed=11.0 if enabled and Input.is_physical_key_pressed(KEY_SHIFT) else 6.5
	if boost_energy<=.5:boost_recharging=true
	elif boost_energy>=25:boost_recharging=false
	boosting=not boost_recharging and enabled and riding and move.length()>.1 and Input.is_physical_key_pressed(KEY_SHIFT) and boost_energy>0
	boost_energy=clampf(boost_energy+(-18 if boosting else 12)*delta,0,100)
	if riding:speed=39.0 if boosting else 24.0
	if seated:riding=false
	var jump_down=enabled and Input.is_physical_key_pressed(KEY_SPACE)
	if riding and jump_down and not jump_was_down and is_on_floor():velocity.y=7.2
	jump_was_down=jump_down
	velocity.x=move_toward(velocity.x,move.x*speed,35*delta)
	velocity.z=move_toward(velocity.z,move.z*speed,35*delta)
	flying=enabled and not seated and not riding and Input.is_physical_key_pressed(KEY_SPACE) and fuel>0.8
	if flying:
		velocity.y=move_toward(velocity.y,5.5,20*delta)
		fuel=maxf(0,fuel-FUEL_DRAIN*delta)
	else:
		if seated:velocity=Vector3.ZERO
		elif not is_on_floor():velocity.y-=18*delta
		elif velocity.y<0:velocity.y=0
		fuel=minf(MAX_FUEL,fuel+(45 if is_on_floor() or seated else 6)*delta)
	if position.y>60:velocity.y=minf(velocity.y,-1)
	# Step over the town's 15 cm curbs rather than snagging on each sidewalk.
	if enabled and is_on_floor() and move.length()>.1:
		var excluded: Array[RID]=[get_rid()]
		var low=PhysicsRayQueryParameters3D.create(global_position+Vector3(0,.08,0),global_position+Vector3(0,.08,0)+move*.65,1,excluded)
		var high=PhysicsRayQueryParameters3D.create(global_position+Vector3(0,.36,0),global_position+Vector3(0,.36,0)+move*.65,1,excluded)
		if not get_world_3d().direct_space_state.intersect_ray(low).is_empty() and get_world_3d().direct_space_state.intersect_ray(high).is_empty():
			if not test_move(global_transform.translated(Vector3(0,.3,0)),move*.15):position.y+=.3
	if not seated:move_and_slide()
	position.x=clampf(position.x,-584,584)
	position.z=clampf(position.z,-504,504)
	if position.y < -10:position=Vector3(0,2,15);velocity=Vector3.ZERO
	if move.length()>0.1:
		visual.rotation.y=lerp_angle(visual.rotation.y,atan2(-move.x,-move.z),delta*12)
		visual.position.y=.22 if riding else sin(Time.get_ticks_msec()*0.015)*0.05 if is_on_floor() else 0
	elif riding:visual.position.y=.22
	else:visual.position.y=0
	ride_visual.visible=riding
	boost_trail.emitting=boosting
	sitting_legs.visible=seated
	for child in visual.get_children():
		if child.name.begins_with("StandingLeg"):child.visible=not seated
		if child.name.begins_with("Flame"):child.visible=flying
	gesture_blend=move_toward(gesture_blend,1.0 if (pointing or riding) and enabled else 0.0,delta*5)
	arm.visible=gesture_blend>.03;left_arm.visible=(carrying or riding) and enabled
	if arm.visible:
		var gesture_target=visual.to_global(Vector3(.28,.65,-.75)) if riding else point_target
		var aim=gesture_target-arm.global_position
		if aim.length()>.1 and absf(aim.normalized().dot(Vector3.UP))<.98:
			var desired_basis=visual.global_basis.inverse()*arm.global_transform.looking_at(gesture_target,Vector3.UP).basis
			arm.quaternion=arm.quaternion.slerp(desired_basis.get_rotation_quaternion(),clampf(delta*10,0,1))
		arm.scale=Vector3.ONE*maxf(.05,gesture_blend)
		if move.length()<.1 and not riding:
			var facing=point_target-global_position
			visual.rotation.y=lerp_angle(visual.rotation.y,atan2(-facing.x,-facing.z),clampf(delta*5,0,1))
		if left_arm.visible:left_arm.quaternion=left_arm.quaternion.slerp(arm.quaternion,clampf(delta*8,0,1))
	visual.rotation.x=lerpf(visual.rotation.x,-.10 if carrying else 0.0,clampf(delta*6,0,1))
	for child in visual.get_children():
		if child.name=="ArmRestRight":child.visible=not arm.visible
		if child.name=="ArmRestLeft":child.visible=not left_arm.visible
	var pivot=global_position+Vector3(0,1.5,0)
	var desired=pivot+Vector3(sin(yaw)*cos(pitch),sin(pitch),cos(yaw)*cos(pitch))*distance
	# A sphere protects the near clip plane at corners where a thin ray misses.
	var query=PhysicsShapeQueryParameters3D.new();var camera_shape=SphereShape3D.new();camera_shape.radius=.28
	query.shape=camera_shape;query.transform=Transform3D(Basis.IDENTITY,pivot);query.motion=desired-pivot;query.collision_mask=5
	query.exclude=[get_rid()]
	if carry_rid.is_valid():query.exclude.append(carry_rid)
	var fraction=get_world_3d().direct_space_state.cast_motion(query)
	if fraction.size()>0 and fraction[0]<1:desired=pivot+(desired-pivot)*maxf(.02,fraction[0]-.02)
	camera.fov=lerpf(camera.fov,74.0 if boosting else 65.0,delta*3)
	camera.global_position=desired
	camera.look_at(pivot)

func teleport(point: Vector3) -> void:
	position=point+Vector3(0,0.5,0)
	velocity=Vector3.ZERO
	yaw=0
	seated=false
	riding=false
	fuel=MAX_FUEL
