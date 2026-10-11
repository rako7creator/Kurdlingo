class_name Neighborhoods
extends RefCounted

var world: Node3D
var wood=Color("a46c48")
var cream=Color("f4e5c9")
var teal=Color("638c83")

func _init(owner_node: Node3D) -> void:
	world=owner_node

func box(p: Vector3,s: Vector3,c: Color,collision: bool=true) -> Node3D:
	return world.solid_box(p,s,c,collision)

func prop(model: String,p: Vector3,size: float,angle: float=0) -> Node3D:
	return world.decoration(model,p,size,angle)

func title(text: String,p: Vector3) -> void:
	var sign=Label3D.new();sign.text=text;sign.font=world.english_font;sign.font_size=54;sign.pixel_size=0.014;sign.position=p;sign.modulate=cream;sign.outline_modulate=Color("304c48");sign.outline_size=10;world.add_child(sign)

func build() -> void:
	flag()
	kitchen(world.REGION_CENTERS.Kitchen)
	workshop(world.REGION_CENTERS.Workshop)
	discovery(world.REGION_CENTERS.Discovery)
	wildlife(world.REGION_CENTERS.Wildlife)
	lifestyle(world.REGION_CENTERS.Lifestyle)
	old_districts()
	mountains()

func room_frame(c: Vector3,color: Color) -> void:
	# Open ceiling and broad door gaps keep a third-person camera comfortable.
	box(c+Vector3(0,2.3,-43),Vector3(84,4.6,.45),color)
	for side in [-1,1]:
		for z in [-32,-8,16,36]:
			box(c+Vector3(side*42,1.1,z),Vector3(.45,2.2,13),color)
			box(c+Vector3(side*42,5.5,z),Vector3(.5,8.8,.5),wood)
		box(c+Vector3(side*42,9.6,0),Vector3(.55,.55,86),wood,false)
	box(c+Vector3(0,9.6,-43),Vector3(84,.55,.55),wood,false)
	for x in [-30,-10,10,30]:
		box(c+Vector3(x,3.0,-42.7),Vector3(12,2,.1),Color("b9d8d7"),false)
		box(c+Vector3(x,1.85,-42.4),Vector3(13,.15,.6),cream,false)

func kitchen(c: Vector3) -> void:
	room_frame(c,Color("e4ba8c"))
	for ix in range(14):
		for iz in range(14):
			box(c+Vector3(-39+ix*6,.069,-39+iz*6),Vector3(5.96,.015,5.96),cream if (ix+iz)%2==0 else Color("d3c7a7"),false)
	title("THE KITCHEN GARDEN · COOK / BAKE / SHARE",c+Vector3(0,6.7,-42.5))
	for row in range(8):
		var z=-31+row*10
		# Eight long kitchen islands replace isolated museum pedestals.
		for side in [-1,1]:
			box(c+Vector3(side*20,0.43,z),Vector3(33,.86,3.2),Color("839d86") if row%2==0 else wood)
			box(c+Vector3(side*20,.91,z),Vector3(34,.1,3.6),Color("f2e9d8"))
			for k in range(6):
				box(c+Vector3(side*20-14+k*5.5,.47,z+1.62),Vector3(5.0,.67,.05),Color("b5c1a2"),false)
				box(c+Vector3(side*20-14+k*5.5,.63,z+1.7),Vector3(.9,.08,.09),Color("bfaa78"),false)
			box(c+Vector3(side*20,.08,z+3.8),Vector3(31,.05,2),Color("ca9d78"),false)
	for x in [-32,-16,16,32]:
		prop("furniture/kitchenCabinet",c+Vector3(x,0,-39),3)
		prop("nature/plant_bush",c+Vector3(x,0,42),2.6)
		WorldProps.line(world,c+Vector3(x,9.6,-20),c+Vector3(x,6,-20),.04,wood)
		var lamp=WorldProps.sphere(world,c+Vector3(x,6,-20),Vector3(1.3,.6,1.3),Color("ffdc9b"));lamp.material_override=WorldProps.material(Color("f1c683"),true)
	for side in [-1,1]:
		for z in [-25,-5,15,35]:
			prop("furniture/kitchenCabinet",c+Vector3(side*39,0,z),2.4,side*PI/2)
			box(c+Vector3(side*41,4.1,z),Vector3(1.6,1.4,5),Color("8b9e86"),false)
			box(c+Vector3(side*40.1,4.1,z),Vector3(.08,1.05,4.6),cream,false)
		prop("furniture/table",c+Vector3(side*29,0,44),4)
		for dx in [-2,2]:prop("furniture/chair",c+Vector3(side*29+dx,0,44),1.9,PI/2*signf(dx))

func workshop(c: Vector3) -> void:
	room_frame(c,Color("8b9c9c"));title("THE MAKER'S YARD · BUILD / REPAIR / INVENT",c+Vector3(0,6.8,-42))
	for row in range(8):
		var z=-31+row*10
		for x in [-30,-10,10,30]:
			box(c+Vector3(x,.88,z),Vector3(11,.12,3.4),wood)
			for dx in [-4.5,4.5]:box(c+Vector3(x+dx,.43,z),Vector3(.18,.86,2.8),teal)
			box(c+Vector3(x,.08,z+3.6),Vector3(8,.04,1.3),Color("d7b654"),false)
	for x in [-31,-12,12,31]:
		box(c+Vector3(x,2.4,-42.5),Vector3(12,3.4,.2),wood,false)
		for k in range(7):
			WorldProps.line(world,c+Vector3(x-5+k*1.7,2,-42.2),c+Vector3(x-5+k*1.7,3.4,-42.2),.07,Color("bcc9c5"))
		for y in [1.5,3.5]:box(c+Vector3(x,y,-39),Vector3(11,.15,2.4),Color("738782"))
	box(c+Vector3(0,9,0),Vector3(80,.7,.8),Color("d8ad58"),false)
	WorldProps.line(world,c+Vector3(0,9,0),c+Vector3(0,6.6,0),.08,Color("425958"))
	prop("furniture/trashcan",c+Vector3(-39,0,39),2)
	prop("cars/sedan",c+Vector3(30,0,43),6)

func discovery(c: Vector3) -> void:
	room_frame(c,Color("afcdd1"));title("DISCOVERY HALL · EARTH / SPACE / SCIENCE",c+Vector3(0,6.6,-42))
	for z in [-26,-6,14,34]:box(c+Vector3(0,.09,z),Vector3(78,.06,2.6),Color("446b77"),false)
	for x in [-20,20]:box(c+Vector3(x,.1,0),Vector3(2.6,.06,80),Color("446b77"),false)
	for row in range(8):
		for column in range(8):
			var p=c+Vector3(-35+column*10,0,-31+row*10)
			WorldProps.cylinder(world,p+Vector3(0,.43,0),1.6,.86,Color("7fabb1"))
			WorldProps.cylinder(world,p+Vector3(0,.88,0),1.8,.06,cream)
	for side in [-1,1]:
		for z in [-30,-10,10,30]:
			box(c+Vector3(side*40,3.5,z),Vector3(.2,6,12),Color("507f94"),false)
			for k in range(10):WorldProps.sphere(world,c+Vector3(side*39.8,1.4+(k%4)*1.1,z-5+(k*7%11)),Vector3.ONE*.13,Color("ffe2a2"))
	var globe=WorldProps.sphere(world,c+Vector3(0,4.7,-39),Vector3.ONE*5,Color("6babc2"))
	WorldProps.sphere(world,c+Vector3(-.9,4.6,-41.3),Vector3(2.1,2.8,.4),Color("83b178"))
	var orbit=MeshInstance3D.new();var torus=TorusMesh.new();torus.inner_radius=3;torus.outer_radius=3.13;orbit.mesh=torus;orbit.position=c+Vector3(0,4.7,-39);orbit.rotation_degrees=Vector3(28,0,12);orbit.material_override=WorldProps.material(Color("ead098"));world.add_child(orbit)
	globe.set_meta("display","planetarium")

func wildlife(c: Vector3) -> void:
	title("WILDLIFE TRAIL · WOODLAND / WATER / MEADOW",c+Vector3(0,4,-43))
	for row in range(7):box(c+Vector3(0,.07,-26+row*10),Vector3(80,.06,2),Color("bcac83"),false)
	for column in [-40,0,40]:box(c+Vector3(column,.075,0),Vector3(2.7,.06,80),Color("bcac83"),false)
	for i in range(35):
		var p=c+Vector3(-40+(i%7)*12,0,-36+int(i/7)*18)
		if absf(p.x-c.x)<4:continue
		prop("nature/tree_pineTallA" if i%3==0 else "nature/tree_oak",p,5.5+(i%3))
		prop("nature/plant_bush",p+Vector3(2,0,2),1.4)
		prop("nature/rock_largeA",p+Vector3(-2,0,1),1.8)
	# A shallow pond and solid boardwalk are outside the animal learning trail.
	var pond=WorldProps.cylinder(world,c+Vector3(28,.09,43),9,.1,Color("62b6c1"));pond.scale.z=.55
	box(c+Vector3(28,.3,43),Vector3(3,.45,13),wood)
	for side in [-1,1]:
		for z in [-5,0,5]:box(c+Vector3(28+side*1.6,1.1,43+z),Vector3(.1,1.4,.1),wood)
		box(c+Vector3(28+side*1.6,1.7,43),Vector3(.12,.12,12),wood,false)
	for x in [-30,-10,10]:
		prop("furniture/bench",c+Vector3(x,0,42),3)
		prop("nature/rock_largeA",c+Vector3(x,0,-43),3.8)
	for i in range(16):
		WorldProps.sphere(world,c+Vector3(-39+i*5,.22,44),Vector3(.35,.4,.35),Color("e9c47b") if i%2==0 else Color("c78ca3"))

func lifestyle(c: Vector3) -> void:
	room_frame(c,Color("d3b8ae"));title("LIFESTYLE QUARTER · DRESS / CREATE / PLAY",c+Vector3(0,6.6,-42))
	for row in range(8):
		for column in range(8):
			var p=c+Vector3(-35+column*10,0,-31+row*10)
			box(p+Vector3(0,.44,0),Vector3(3.2,.88,2.6),Color("b9927b") if row<3 else Color("95a5a0"))
	for z in [-26,-6,14,34]:box(c+Vector3(0,.075,z),Vector3(78,.06,2.5),Color("dfc59b"),false)
	for x in [-31,-12,12,31]:
		box(c+Vector3(x,2,-39),Vector3(11,4,.25),Color("8d9f9a"))
		for y in [1.3,2.5,3.7]:box(c+Vector3(x,y,-38.4),Vector3(11,.14,1.2),cream,false)
	box(c+Vector3(-26,.07,44),Vector3(25,.04,11),Color("718e79"),false)
	for side in [-1,1]:box(c+Vector3(-26+side*12,.1,44),Vector3(.1,.03,11),cream,false)
	box(c+Vector3(-26,.1,44),Vector3(.1,.03,11),cream,false)
	prop("furniture/loungeSofa",c+Vector3(28,0,43),5)
	prop("furniture/tableCoffee",c+Vector3(28,0,39),3)
	for x in [-38,0,38]:prop("suburban/tree-small",c+Vector3(x,0,45),5)

func old_districts() -> void:
	# More context for the already furnished original five districts.
	for x in [-92,-72,-52]:
		box(Vector3(x,.08,-5),Vector3(10,.1,8),Color("d8c9aa"),false)
		prop("furniture/bench",Vector3(x,0,-3),3)
		prop("suburban/tree-small",Vector3(x+5,0,-5),4.5)
	for z in [-50,-32,-12,8]:
		box(Vector3(-108,.35,z),Vector3(4,.7,3),Color("bf9b72"))
		prop("nature/plant_bush",Vector3(-108,.7,z),3)
	for i in range(13):
		var p=world.market_stall(i)
		box(p+Vector3(0,1.08,1.18),Vector3(8,.18,.05),Color("e9ce93"),false)
		for k in [-3,3]:prop("nature/plant_bush",p+Vector3(k,0,-3),1.7)
	for p in [Vector3(38,0,-47),Vector3(65,0,-47),Vector3(92,0,-47),Vector3(38,0,-1),Vector3(70,0,-1)]:
		box(p+Vector3(0,.2,0),Vector3(18,.035,16),Color("d4a785"),false)
		prop("nature/plant_bush",p+Vector3(9,0,8),1.7)
		box(p+Vector3(0,1.65,-10.8),Vector3(6,1.5,.1),Color("bdd3cc"),false)
		box(p+Vector3(0,1.65,-10.65),Vector3(.15,1.6,.12),wood,false)
	for z in [38,56,74,92]:
		prop("furniture/bench",Vector3(-44,0,z),3,PI/2)
		for x in [-42,-47]:WorldProps.sphere(world,Vector3(x,.25,z+4),Vector3.ONE*.35,Color("e5af94"))
	# The park's visual bridge now has a walkable deck, with a safe ramp.
	box(Vector3(-86,.28,82),Vector3(8,.3,2.7),wood)
	for side in [-1,1]:box(Vector3(-86+side*4.5,.14,82),Vector3(1.2,.28,2.7),wood)
	box(Vector3(106,1.75,72),Vector3(.3,3.5,38),Color("b17759"))
	box(Vector3(94,1.75,91),Vector3(24,3.5,.3),Color("b17759"))
	box(Vector3(94,4,91),Vector3(25,.5,3),Color("79594c"),false)
	for x in [83,93,103]:prop("nature/plant_bush",Vector3(x,0,99),2)

func mountains() -> void:
	for i in range(12):
		var p=Vector3(-240+i*44,-1,-228)
		WorldProps.cylinder(world,p+Vector3(0,16,0),27,34,Color("859d92") if i%2==0 else Color("748c82"),0)
		WorldProps.cylinder(world,p+Vector3(0,29.5,0),8,9,Color("e0e4d7"),0)

func flag() -> void:
	box(Vector3(-8,.3,-8),Vector3(5,.6,5),Color("d6c19c"))
	WorldProps.cylinder(world,Vector3(-8,10,-8),.15,20,Color("c5d5d2"))
	WorldProps.sphere(world,Vector3(-8,20.15,-8),Vector3.ONE*.45,Color("edc858"))
	var cloth=MeshInstance3D.new();var mesh=PlaneMesh.new();mesh.size=Vector2(18,9);mesh.orientation=PlaneMesh.FACE_Z;mesh.subdivide_width=48;mesh.subdivide_depth=24;cloth.mesh=mesh;cloth.position=Vector3(1,15,-8)
	var shader=Shader.new();shader.code="shader_type spatial; render_mode cull_disabled; uniform sampler2D flag_texture : source_color; void vertex(){VERTEX.z+=sin(UV.x*9.0-TIME*1.8)*UV.x*0.55+sin(UV.x*18.0+UV.y*5.0-TIME*2.5)*UV.x*0.18;} void fragment(){ALBEDO=texture(flag_texture,UV).rgb;ROUGHNESS=0.85;}"
	var material=ShaderMaterial.new();material.shader=shader;material.set_shader_parameter("flag_texture",load("res://assets/kurdistan_flag.svg"));cloth.material_override=material;cloth.name="KurdistanFlag";world.add_child(cloth)
	world.signpost("KURDISTAN · WELCOME",Vector3(-13,0,-8),Color("f0d375"))
