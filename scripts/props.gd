class_name WorldProps
extends RefCounted

static var materials: Dictionary = {}
static var bounds_cache: Dictionary = {}

static func material(color: Color, glow: bool = false) -> StandardMaterial3D:
	var key = str(color) + str(glow)
	if materials.has(key): return materials[key]
	var m = StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.8
	if glow:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = 1.3
	materials[key] = m
	return m

static func box(parent: Node3D, p: Vector3, s: Vector3, c: Color) -> MeshInstance3D:
	var n = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = s
	n.mesh = mesh
	n.position = p
	n.material_override = material(c)
	parent.add_child(n)
	return n

static func sphere(parent: Node3D, p: Vector3, s: Vector3, c: Color) -> MeshInstance3D:
	var n = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 16
	mesh.rings = 8
	n.mesh = mesh
	n.position = p
	n.scale = s
	n.material_override = material(c)
	parent.add_child(n)
	return n

static func cylinder(parent: Node3D, p: Vector3, radius: float, height: float, c: Color, top: float = -1.0) -> MeshInstance3D:
	var n = MeshInstance3D.new()
	var mesh = CylinderMesh.new()
	mesh.bottom_radius = radius
	mesh.top_radius = radius if top < 0 else top
	mesh.height = height
	mesh.radial_segments = 12
	n.mesh = mesh
	n.position = p
	n.material_override = material(c)
	parent.add_child(n)
	return n

static func line(parent: Node3D, a: Vector3, b: Vector3, thickness: float, color: Color) -> MeshInstance3D:
	var n = cylinder(parent,(a+b)*0.5,thickness,a.distance_to(b),color)
	var direction = (b-a).normalized()
	if abs(direction.dot(Vector3.UP)) < 0.999:
		n.quaternion = Quaternion(Vector3.UP,direction)
	return n

static func bounds(node: Node3D, trans: Transform3D = Transform3D.IDENTITY) -> AABB:
	var result = AABB()
	var initialized = false
	for child in node.get_children():
		if not child is Node3D: continue
		var transform = trans * child.transform
		var b = AABB()
		if child is MeshInstance3D:
			b = transform * child.get_aabb()
		else:
			b = bounds(child,transform)
		if b.size.length() > 0.0001:
			result = b if not initialized else result.merge(b)
			initialized = true
	return result

static func make(model: String, target_size: float) -> Node3D:
	if model=="furniture/chair" or model.begins_with("expansion/chair/"):target_size=1.34
	if model=="furniture/bench" or model.begins_with("expansion/bench/"):target_size=1.55
	var holder = Node3D.new()
	var visual: Node3D
	if model.begins_with("daily/"):
		visual=DailyProps.make(model.get_slice("/",1),model.get_slice("/",2))
	elif model.begins_with("expansion/"):
		visual = ExpansionProps.make(model.get_slice("/",1),model.get_slice("/",2))
	elif model=="furniture/bench":
		visual = TeacherCircle.classroom_chair(true)
		# Scale the children so the bounds include the width before normalization.
		for part in visual.get_children():
			if part is Node3D:part.scale.x*=1.8
	elif model=="furniture/chair":
		visual = TeacherCircle.classroom_chair(true)
	elif model.begins_with("accurate/"):
		visual = AccurateProps.make(model.get_slice("/",1))
	elif model.begins_with("new/"):
		visual = AnnexProps.make(model.get_slice("/",1))
	elif model.begins_with("custom/"):
		visual = custom(model.get_slice("/",1))
	else:
		var resource = load("res://assets/" + model + ".glb")
		visual = resource.instantiate() if resource is PackedScene else custom("box")
	if model.begins_with("daily/") or model.begins_with("expansion/") or model.begins_with("accurate/") or model.begins_with("custom/") or model.begins_with("new/"):
		AccurateProps.merge_shapes(visual)
	if model.begins_with("commercial/") or model.begins_with("suburban/building"):
		var colors=[Color("b2d1c6"),Color("e6b697"),Color("a8c8d4"),Color("d8be9b"),Color("c6b5ca")]
		tint(visual,colors[absi(model.hash())%colors.size()])
	var b: AABB
	if bounds_cache.has(model): b = bounds_cache[model]
	else:
		b = bounds(visual)
		bounds_cache[model] = b
	var longest = maxf(b.size.x,maxf(b.size.y,b.size.z))
	var factor = target_size / maxf(longest,0.1)
	visual.scale *= factor
	visual.position = -Vector3(b.get_center().x,b.position.y,b.get_center().z) * factor
	if model in ["furniture/chair","furniture/bench"] or model.begins_with("expansion/chair/") or model.begins_with("expansion/bench/"):visual.position.x=0;visual.position.z=0
	holder.add_child(visual)
	holder.set_meta("dimensions",b.size * factor)
	set_draw_distance(holder,220.0 if target_size>6 else 135.0)
	return holder

static func tint(node: Node3D, color: Color) -> void:
	if node is MeshInstance3D:
		for i in range(node.mesh.get_surface_count()):
			var original=node.get_active_material(i)
			if original is StandardMaterial3D:
				var m=original.duplicate();m.albedo_color=color;node.set_surface_override_material(i,m)
	for child in node.get_children():
		if child is Node3D:tint(child,color)

static func alien() -> Node3D:
	var n = Node3D.new()
	var mint = Color("69d6bd")
	var dark = Color("173a50")
	var gold = Color("ffcd78")
	sphere(n,Vector3(0,1.2,0),Vector3(0.92,0.94,0.86),mint)
	sphere(n,Vector3(0,1.28,-0.34),Vector3(0.75,0.48,0.2),dark)
	for x in [-0.2,0.2]:
		sphere(n,Vector3(x,1.32,-0.44),Vector3(0.17,0.24,0.1),Color("fff9e8"))
		sphere(n,Vector3(x,1.32,-0.48),Vector3(0.07,0.13,0.06),dark)
	cylinder(n,Vector3(0,1.81,0),0.045,0.38,dark)
	sphere(n,Vector3(0,2.01,0),Vector3.ONE*0.17,gold)
	sphere(n,Vector3(0,0.63,0),Vector3(0.75,0.8,0.68),dark)
	box(n,Vector3(0,0.7,-0.32),Vector3(0.35,0.25,0.07),gold)
	for x in [-0.48,0.48]:
		var resting_arm=sphere(n,Vector3(x,0.68,0),Vector3(0.22,0.55,0.23),mint)
		resting_arm.name="ArmRestLeft" if x<0 else "ArmRestRight"
	for x in [-0.22,0.22]:
		var leg=sphere(n,Vector3(x,0.16,-0.06),Vector3(0.3,0.3,0.48),dark);leg.name="StandingLeg"+str(x)
		cylinder(n,Vector3(x,0.69,0.43),0.14,0.6,Color("c6dce1"))
		var flame = cylinder(n,Vector3(x,0.18,0.43),0.10,0.6,Color("79e6ec"),0.03)
		flame.name = "Flame" + str(x)
		flame.material_override = material(Color("79e6ec"),true)
		flame.visible = false
	return n

static func custom(kind: String) -> Node3D:
	var n = Node3D.new()
	var wood = Color("b58258")
	var dark = Color("344e59")
	var metal = Color("cadde1")
	var green = Color("66ad72")
	var orange = Color("efb766")
	match kind:
		"human":
			sphere(n,Vector3(0,1.65,0),Vector3(0.5,0.58,0.46),Color("dab491"))
			sphere(n,Vector3(0,1.85,0.02),Vector3(0.52,0.26,0.5),Color("6b5148"))
			box(n,Vector3(0,1.02,0),Vector3(0.6,0.7,0.36),Color("cc927f"))
			for x in [-0.39,0.39]:box(n,Vector3(x,0.96,0),Vector3(0.18,0.65,0.22),Color("dab491"))
			for x in [-0.18,0.18]:box(n,Vector3(x,0.4,0),Vector3(0.23,0.7,0.27),dark)
			for x in [-0.11,0.11]:sphere(n,Vector3(x,1.69,-0.23),Vector3.ONE*0.05,dark)
		"robot":
			box(n,Vector3(0,1.2,0),Vector3(0.9,0.8,0.7),Color("70869c"))
			box(n,Vector3(0,1.85,0),Vector3(0.9,0.55,0.7),metal)
			box(n,Vector3(0,1.85,-0.36),Vector3(0.7,0.15,0.07),Color("e47572"))
			for x in [-0.57,0.57]:box(n,Vector3(x,1.15,0),Vector3(0.22,0.65,0.25),dark)
			for x in [-0.28,0.28]:box(n,Vector3(x,0.4,0),Vector3(0.32,0.7,0.4),dark)
		"blanket","towel","paper","notebook","soap","comb","phone","toothpaste":
			var color = Color("e9b2a1") if kind in ["blanket","towel"] else Color("f2e4bc")
			if kind=="phone":color=dark
			box(n,Vector3(0,0.055,0),Vector3(0.65,0.11,1),color)
			if kind=="notebook":box(n,Vector3(-0.30,0.12,0),Vector3(0.07,0.06,1),Color("65babd"))
			if kind=="phone":box(n,Vector3(0,0.12,0),Vector3(0.52,0.015,0.78),Color("79cbd2"))
			if kind=="comb":
				for i in range(10):box(n,Vector3(-0.34,0.08,-0.45+i*0.1),Vector3(0.3,0.08,0.04),dark)
		"pen","pencil","toothbrush":
			cylinder(n,Vector3(0,0.55,0),0.035,1,orange)
			if kind=="toothbrush":box(n,Vector3(0,1.03,0),Vector3(0.14,0.25,0.07),metal)
			else:cylinder(n,Vector3(0,1.08,0),0.04,0.18,dark,0)
		"key","scissors":
			var ring = TorusMesh.new();ring.inner_radius=0.12;ring.outer_radius=0.2
			var m = MeshInstance3D.new();m.mesh=ring;m.material_override=material(orange);m.position.y=0.2;n.add_child(m)
			box(n,Vector3(0,0.12,0.35),Vector3(0.06,0.07,0.55),orange)
			box(n,Vector3(0.09,0.12,0.57),Vector3(0.2,0.07,0.08),orange)
			if kind=="scissors":line(n,Vector3(-0.15,0.12,0),Vector3(0.22,0.12,0.7),0.035,metal)
		"clock":
			var face=cylinder(n,Vector3(0,0.5,0),0.5,0.08,Color("fff5db"));face.rotation.x=PI/2
			line(n,Vector3(0,0.5,-0.06),Vector3(0,0.83,-0.06),0.025,dark)
			line(n,Vector3(0,0.5,-0.07),Vector3(0.22,0.5,-0.07),0.025,dark)
		"umbrella","tent","kite":
			if kind=="umbrella":
				cylinder(n,Vector3(0,0.75,0),0.025,1.5,dark)
				cylinder(n,Vector3(0,1.45,0),0.8,0.45,Color("e97e6b"),0)
			elif kind=="tent":
				cylinder(n,Vector3(0,0.65,0),1,1.3,Color("e1ad67"),0)
				box(n,Vector3(0,0.37,-0.75),Vector3(0.5,0.75,0.1),dark)
			else:
				var panel=box(n,Vector3(0,1,0),Vector3(0.9,0.9,0.08),Color("ea9279"));panel.rotation.z=PI/4
				line(n,Vector3(0,0.5,0),Vector3(0,0,0),0.025,dark)
		"streetlight","trafficlight","sign","postbox","gate":
			cylinder(n,Vector3(0,1.5,0),0.09,3,dark)
			if kind=="streetlight":
				box(n,Vector3(0.35,3,0),Vector3(0.9,0.14,0.3),dark)
				sphere(n,Vector3(0.65,2.92,0),Vector3(0.3,0.13,0.25),Color("ffdf9c"))
			elif kind=="trafficlight":
				box(n,Vector3(0,2.5,0),Vector3(0.45,1.1,0.35),dark)
				for i in range(3):sphere(n,Vector3(0,2.16+i*0.32,-0.2),Vector3.ONE*0.2,[green,orange,Color("e16c67")][i])
			elif kind=="postbox":box(n,Vector3(0,1.9,0),Vector3(0.9,0.75,0.7),Color("cf7566"))
			else:box(n,Vector3(0,2.6,0),Vector3(1.5,0.9,0.15),Color("72b5ba"))
		"road","sidewalk","sand","soil","pond","river":
			var c = dark
			if kind in ["sand","soil"]:c=Color("d1b58b") if kind=="sand" else wood
			if kind in ["pond","river"]:c=Color("66b9cb")
			box(n,Vector3(0,0.06,0),Vector3(2,0.12,3),c)
			if kind=="road":box(n,Vector3(0,0.13,0),Vector3(0.09,0.02,1.8),Color("fff2bc"))
		"bridge":
			box(n,Vector3(0,0.4,0),Vector3(1.5,0.16,3),wood)
			for x in [-0.7,0.7]:
				box(n,Vector3(x,0.9,0),Vector3(0.1,0.12,3),wood)
				for z in [-1.3,0,1.3]:box(n,Vector3(x,0.55,z),Vector3(0.1,1,0.1),wood)
		"fountain":
			cylinder(n,Vector3(0,0.25,0),1.4,0.5,metal)
			cylinder(n,Vector3(0,0.51,0),1.2,0.035,Color("72c4d4"))
			cylinder(n,Vector3(0,1.05,0),0.2,1.2,metal)
			cylinder(n,Vector3(0,1.6,0),0.65,0.12,metal)
		"bicycle":
			for x in [-0.6,0.6]:
				var wheel=cylinder(n,Vector3(x,0.42,0),0.4,0.07,dark);wheel.rotation.x=PI/2
			line(n,Vector3(-0.6,0.42,0),Vector3(0,0.9,0),0.04,Color("da8c73"))
			line(n,Vector3(0,0.9,0),Vector3(0.6,0.42,0),0.04,Color("da8c73"))
			line(n,Vector3(-0.6,0.42,0),Vector3(0.6,0.42,0),0.04,Color("da8c73"))
			box(n,Vector3(0,0.94,0),Vector3(0.4,0.12,0.24),dark)
		"ball","sun","potato","cloud","cucumber":
			var c = orange
			if kind=="potato":c=Color("b5946b")
			if kind=="cucumber":c=green
			if kind=="cloud":c=Color("f3f2de")
			sphere(n,Vector3(0,0.5,0),Vector3(1,1,1.0 if kind!="cucumber" else 2),c)
			if kind=="cloud":
				for x in [-0.6,0.6]:sphere(n,Vector3(x,0.4,0),Vector3(1,0.9,0.9),c)
		"mountain":cylinder(n,Vector3(0,1,0),1.6,2.0,Color("93a29b"),0)
		"leaf":
			var s=sphere(n,Vector3(0,0.12,0),Vector3(0.55,0.08,1),green);s.rotation.y=0.4
			line(n,Vector3(0,0.17,-0.35),Vector3(0,0.17,0.4),0.015,orange)
		"bird","butterfly","bee":
			sphere(n,Vector3(0,0.45,0),Vector3(0.3,0.3,0.6),orange)
			for x in [-0.35,0.35]:sphere(n,Vector3(x,0.5,0),Vector3(0.6,0.07,0.4),metal if kind=="bee" else Color("c8a7cb"))
			sphere(n,Vector3(0,0.6,-0.25),Vector3.ONE*0.22,dark)
		"campfire":
			for i in range(6):
				var angle=i*TAU/6;sphere(n,Vector3(cos(angle)*0.6,0.14,sin(angle)*0.6),Vector3(0.3,0.22,0.3),metal)
			cylinder(n,Vector3(0,0.6,0),0.35,1,orange,0)
		"wheat":
			for i in range(7):
				var x=sin(i*2)*0.3;var z=cos(i*2)*0.3
				cylinder(n,Vector3(x,0.5,z),0.02,1,orange)
				for y in [0.7,0.85,1.0]:sphere(n,Vector3(x,y,z),Vector3(0.13,0.22,0.12),Color("e8cb76"))
		"hay":box(n,Vector3(0,0.45,0),Vector3(1.4,0.9,1),Color("d2b56e"))
		"bucket","wateringcan","basket":
			cylinder(n,Vector3(0,0.35,0),0.35,0.65,wood if kind=="basket" else Color("67a9b6"),0.43)
			line(n,Vector3(-0.35,0.7,0),Vector3(0,1.05,0),0.025,dark)
			line(n,Vector3(0,1.05,0),Vector3(0.35,0.7,0),0.025,dark)
			if kind=="wateringcan":line(n,Vector3(0.35,0.3,0),Vector3(0.8,0.6,0),0.075,metal)
		"ladder":
			for x in [-0.3,0.3]:box(n,Vector3(x,1.25,0),Vector3(0.09,2.5,0.12),wood)
			for i in range(7):box(n,Vector3(0,0.2+i*0.32,0),Vector3(0.6,0.08,0.12),wood)
		"shovel","rake","hammer","saw","axe":
			cylinder(n,Vector3(0,0.55,0),0.04,1.1,wood)
			if kind=="shovel":box(n,Vector3(0,0.08,0),Vector3(0.45,0.5,0.05),metal)
			elif kind=="rake":
				box(n,Vector3(0,1.1,0),Vector3(0.8,0.07,0.07),metal)
				for x in range(8):box(n,Vector3(-0.35+x*0.1,1.0,0),Vector3(0.04,0.25,0.04),metal)
			else:box(n,Vector3(0.12,1.05,0),Vector3(0.55,0.3,0.08),metal)
		"rope":
			for i in range(3):
				var t=TorusMesh.new();t.inner_radius=0.3;t.outer_radius=0.36
				var v=MeshInstance3D.new();v.mesh=t;v.position.y=0.1+i*0.09;v.material_override=material(wood);n.add_child(v)
		"wheelbarrow":
			box(n,Vector3(0,0.6,0),Vector3(0.8,0.4,1),Color("69a58c"))
			for x in [-0.3,0.3]:line(n,Vector3(x,0.5,-0.4),Vector3(x,0.9,1.1),0.04,dark)
			var wheel=cylinder(n,Vector3(0,0.25,-0.6),0.25,0.16,dark);wheel.rotation.z=PI/2
		"cow","sheep","horse","cat","dog":
			n.add_child(AnimalModels.make(kind))
		_:
			box(n,Vector3(0,0.4,0),Vector3(0.8,0.8,0.8),wood)
	return n

static func set_draw_distance(node:Node3D,distance:float)->void:
	if node is GeometryInstance3D:
		node.visibility_range_end=distance;node.visibility_range_end_margin=8
	for child in node.get_children():
		if child is Node3D:set_draw_distance(child,distance)

