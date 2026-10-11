class_name Citizens
extends Node3D
var world:Node3D
var walkers:Array=[]
var elapsed=0.0
func _ready()->void:
	# Routes follow the unobstructed sidewalks and the school's central corridors.
	var routes=[
		[Vector3(19.5,0,-75),Vector3(19.5,0,-32)],
		[Vector3(-35,0,40),Vector3(-35,0,95)],
		[Vector3(40,0,36),Vector3(100,0,36)],
		[Vector3(-75,0,-26),Vector3(-42,0,-26)],
		[Vector3(24,0,48),Vector3(65,0,48)]]
	for i in range(routes.size()):spawn(routes[i],false,i)
	for i in range(6):
		var z=-10 if i%2==0 else 10
		spawn([SchoolWorld.CENTER+Vector3(-32,.1,z),SchoolWorld.CENTER+Vector3(32,.1,z)],true,i+5)
	for i in range(3):spawn([SchoolWorld.CENTER+Vector3(-1.3+i*1.3,.1,-29),SchoolWorld.CENTER+Vector3(-1.3+i*1.3,.1,48)],false,i+11)
	for side in [-1,1]:spawn([SchoolWorld.CENTER+Vector3(side*8,0,37),SchoolWorld.CENTER+Vector3(side*8,0,59)],true,14+side)
func spawn(points:Array,child:bool,index:int)->void:
	var body=CharacterBody3D.new();body.collision_layer=8;body.collision_mask=1;body.position=points[index%points.size()]+Vector3(0,.25,0);add_child(body)
	var shape=CollisionShape3D.new();var capsule=CapsuleShape3D.new();capsule.height=1.25 if child else 1.75;capsule.radius=.22;shape.shape=capsule;shape.position.y=capsule.height*.5;body.add_child(shape)
	var person=TeacherCircle.person(false,index);if child:person.scale=Vector3.ONE*.74
	body.add_child(person)
	# Replace straight static legs with hips that swing during each footstep.
	for piece in person.get_children():
		if piece is Node3D and piece.position.y<.65:piece.hide()
	var legs=[]
	for side in [-1,1]:
		var leg=Node3D.new();leg.position=Vector3(side*.15,.82,0);person.add_child(leg);legs.append(leg)
		WorldProps.line(leg,Vector3.ZERO,Vector3(0,-.7,0),.08,Color("344451"));WorldProps.sphere(leg,Vector3(0,-.75,-.08),Vector3(.2,.13,.32),Color("344451"))
	if child:
		var bag=WorldProps.make("school/backpack",.42);bag.position=Vector3(0,.65,.19);bag.rotation.y=PI;person.add_child(bag)
	walkers.append({"body":body,"person":person,"legs":legs,"points":points,"next":(index+1)%points.size(),"speed":.8+(index%4)*.16,"wait":index*.15,"phase":index})
func _physics_process(delta:float)->void:
	elapsed+=delta
	for walker in walkers:
		var body:CharacterBody3D=walker.body;var person:Node3D=walker.person
		var target:Vector3=walker.points[walker.next];var diff=target-body.position;diff.y=0
		if diff.length()<.4:
			walker.next=(walker.next+1)%walker.points.size();walker.wait=1.3+float(walker.phase%3)*.4
		walker.wait=maxf(0,walker.wait-delta)
		var moving=walker.wait<=0
		if world.player!=null and body.position.distance_to(world.player.position)<1.15:moving=false
		var direction=diff.normalized() if moving else Vector3.ZERO
		body.velocity.x=direction.x*walker.speed;body.velocity.z=direction.z*walker.speed
		if not body.is_on_floor():body.velocity.y-=18*delta
		else:body.velocity.y=0
		body.move_and_slide()
		if moving:person.rotation.y=lerp_angle(person.rotation.y,atan2(-direction.x,-direction.z),delta*5)
		for i in range(2):walker.legs[i].rotation.x=sin(elapsed*5+walker.phase+i*PI)*.42 if moving else 0
