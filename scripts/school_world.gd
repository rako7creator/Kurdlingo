class_name SchoolWorld
extends Node3D
var world:Node3D
const CENTER=Vector3(365,0,65)
const ROOMS={"Library":Vector3(-30,0,-23),"English classroom":Vector3(-11,0,-23),"Science laboratory":Vector3(11,0,-23),"Computer laboratory":Vector3(30,0,-23),"Administration":Vector3(-30,0,23),"Teachers room":Vector3(-11,0,23),"Art and music":Vector3(11,0,23),"Cafeteria and wellbeing":Vector3(30,0,23)}
const COLORS=[Color("86aa98"),Color("8eaeba"),Color("86b6b3"),Color("9ba6be"),Color("c6a780"),Color("b8a4a2"),Color("c29a79"),Color("aabc91")]
var roof:Node3D
var room_doors:Array[Vector3]=[]
var ceilings:Array=[]
var inside=false
var architecture:Node3D
var surfaces:Dictionary={}
func surface(kind:String)->StandardMaterial3D:
	if surfaces.has(kind):return surfaces[kind]
	var mat=StandardMaterial3D.new();mat.albedo_texture=load("res://assets/school/textures/"+kind+"_diff.jpg")
	mat.normal_enabled=true;mat.normal_texture=load("res://assets/school/textures/"+kind+"_nor_gl.jpg");mat.normal_scale=.55
	mat.roughness_texture=load("res://assets/school/textures/"+kind+"_rough.jpg");mat.roughness=.85
	mat.uv1_triplanar=true;mat.uv1_world_triplanar=true;mat.uv1_scale=Vector3.ONE*(.45 if kind=="stone" else .7);surfaces[kind]=mat;return mat
func _ready()->void:build()
func box(p:Vector3,s:Vector3,col:Color,collision:bool=true)->Node3D:
	var item=world.solid_box(CENTER+p,s,col,collision);world.remove_child(item);architecture.add_child(item)
	var kind=""
	if col==Color("e0c9a4") or col==Color("dbc298"):kind="stone"
	elif col==Color("aa8560"):kind="wood"
	elif s.y<.15 and s.x>7 and s.z>7 and p.y<.2:kind="tiles"
	if kind!="" and ResourceLoader.exists("res://assets/school/textures/"+kind+"_diff.jpg"):item.get_child(0).material_override=surface(kind)
	return item
func prop(model:String,p:Vector3,size:float,angle:float=0)->Node3D:return world.decoration(model,CENTER+p,size,angle)
func text(value:String,p:Vector3,scale_factor:float=.012,color:Color=Color("294e58"),angle:float=0)->void:
	var label=Label3D.new();label.text=value;label.font=world.english_font;label.position=CENTER+p;label.font_size=42;label.pixel_size=scale_factor;label.modulate=color;label.rotation.y=angle;add_child(label)
func pane(p:Vector3,width:float=2.6)->void:
	box(p+Vector3(0,-.77,0),Vector3(width+.2,.12,.3),Color("c6ae87"))
	box(p+Vector3(0,.77,0),Vector3(width+.2,.12,.3),Color("c6ae87"))
	for x in [-width*.5,0,width*.5]:box(p+Vector3(x,0,0),Vector3(.07,1.55,.22),Color("446671"))
	box(p,Vector3(width,1.5,.05),Color("b2d7d8b0"),false)
	box(p,Vector3(width,.055,.2),Color("446671"))
func mural(p:Vector3,width:float,angle:float)->void:
	var painting=MeshInstance3D.new();var plane=QuadMesh.new();plane.size=Vector2(width,width/2.8);painting.mesh=plane
	var mat=StandardMaterial3D.new();mat.albedo_texture=load("res://assets/school/mural.svg");mat.roughness=1;mat.cull_mode=BaseMaterial3D.CULL_DISABLED;painting.material_override=mat
	painting.position=CENTER+p;painting.rotation.y=angle;add_child(painting)
func build()->void:
	architecture=Node3D.new();add_child(architecture)
	# The entire school has a level, accessible floor: no invisible entrance step.
	box(Vector3(0,.04,0),Vector3(86,.08,72),Color("e0d4be"))
	box(Vector3(0,.09,0),Vector3(78,.02,20),Color("ecdfc7"),false)
	box(Vector3(0,.09,0),Vector3(7,.02,68),Color("ead5b2"),false)
	for z in range(-31,34,3):
		for x in [-3.3,3.3]:box(Vector3(x,.105,z),Vector3(.09,.01,1.6),Color("a9bfb6"),false)
	# Stone facade with window openings, masonry courses and projecting cornices.
	for z in [-33,33]:
		for side in [-1,1]:
			box(Vector3(side*23,2.15,z),Vector3(40,4.3,.35),Color("e0c9a4"))
			for j in range(8):
				var wx=side*(7+j*4.5);pane(Vector3(wx,2.3,z+sign(z)*.21),2.8)
				# Panes overlay recessed darker reveals; wall remains a solid outside boundary.
				box(Vector3(wx,2.3,z+sign(z)*.19),Vector3(3,1.7,.06),Color("668c95"),false)
				pane(Vector3(wx,2.3,z+sign(z)*.24),2.8)
		box(Vector3(0,3.65,z),Vector3(6,1.3,.35),Color("e0c9a4"))
		for x in [-3.2,3.2]:box(Vector3(x,1.5,z),Vector3(.22,3,.45),Color("446671"))
		box(Vector3(0,3,z),Vector3(6.7,.16,.5),Color("446671"))
		# Double doors stand open along the jambs, leaving a six metre entrance.
		for x in [-2.8,2.8]:
			box(Vector3(x,1.4,z+1),Vector3(.08,2.8,1.8),Color("446671"));box(Vector3(x,1.6,z+1),Vector3(.09,1.7,1.2),Color("8cb5b9"),false)
	for x in [-42,42]:
		box(Vector3(x,2.15,0),Vector3(.35,4.3,66),Color("e0c9a4"))
		for z in range(-30,34,6):
			box(Vector3(x,2.3,z),Vector3(.4,1.65,3.9),Color("8db5bc"),false)
			for wz in [-2,0,2]:box(Vector3(x+sign(x)*.05,2.3,z+wz),Vector3(.45,1.75,.09),Color("446671"),false)
	for z in [-33.22,33.22]:
		for y in [.3,.55,1.05,3.55,4.15]:box(Vector3(0,y,z),Vector3(84,.055,.12),Color("bca988"),false)
		for x in range(-41,43,3):
			box(Vector3(x,1.78,z),Vector3(.035,.4,.08),Color("bca988"),false)
		for y in [.16,4.35]:box(Vector3(0,y,z),Vector3(85,.18,.65),Color("bca988"),false)
	var ri=0
	for room in ROOMS:
		var p:Vector3=ROOMS[room];var col:Color=COLORS[ri];ri+=1
		box(p+Vector3(0,.1,0),Vector3(17.8,.025,19.2),col.lightened(.45),false)
		box(p+Vector3(0,4.05,0),Vector3(18.2,.1,19.2),Color("eee5d5"))
		# Corridor doorway is physically open, with a lintel above the character.
		var inner=p.z-sign(p.z)*9.4
		for x in [-5,5]:box(Vector3(p.x+x,2,inner),Vector3(7.6,4,.18),Color("ece3d1"))
		box(Vector3(p.x,3.5,inner),Vector3(2.4,1,.18),Color("ece3d1"))
		for x in [-1.25,1.25]:box(Vector3(p.x+x,1.5,inner),Vector3(.1,3,.26),col)
		box(Vector3(p.x,3,inner),Vector3(2.65,.12,.28),col)
		var door=CENTER+Vector3(p.x,.1,inner);room_doors.append(door)
		text(room.to_upper(),Vector3(p.x,3.34,inner-sign(p.z)*.13),.004,Color("314f58"),PI if p.z>0 else 0)
		for x in [-9.2,9.2]:box(p+Vector3(x,2,0),Vector3(.18,4,19),Color("ece3d1"))
		# Wainscoting, skirting and a wash of each classroom's color.
		for x in [-9.05,9.05]:
			box(p+Vector3(x,.55,0),Vector3(.035,1.0,18.6),col,false)
			box(p+Vector3(x,1.1,0),Vector3(.065,.08,18.6),Color("bca988"),false)
		for side in [-1,1]:
			box(p+Vector3(side*5,.48,0),Vector3(2.7,.8,13),Color("e2d3b8"))
			box(p+Vector3(side*5,.92,0),Vector3(2.85,.08,13.1),Color("aa8560"))
			for drawer in range(5):box(p+Vector3(side*3.64,.5,-5+drawer*2.5),Vector3(.02,.045,.34),Color("546772"),false)
		# Extra workstations make a furnished room instead of isolated pedestals.
		for z in [-4,0,4]:
			if room not in ["Administration","Library","Cafeteria and wellbeing"]:
				for x in [-1.7,1.7]:
					var desk=prop("school/desk",p+Vector3(x,.1,z),1.25)
					var chair=prop("furniture/chair",p+Vector3(x,.1,z+1),1.05)
					var cd:Vector3=desk.get_meta("dimensions");box(p+Vector3(x,.1+cd.y*.5,z),cd,Color.TRANSPARENT,true).get_child(0).free()
					if room=="Computer laboratory":prop("school/computer",p+Vector3(x,.88,z),.65);prop("furniture/computerKeyboard",p+Vector3(x,.87,z-.23),.37)
					if room=="English classroom" and z==0:
						var pupil=TeacherCircle.person(true,ri+int(x));pupil.position=CENTER+p+Vector3(x,.15,z+1);add_child(pupil)
			else:prop("furniture/loungeChair",p+Vector3(-1.6,.1,z),1.2,PI/2);prop("furniture/tableCoffee",p+Vector3(0,.1,z),1.3)
		prop("furniture/pottedPlant",p+Vector3(7.7,.1,-7.3),1.4)
		prop("furniture/trashcan",p+Vector3(-7.7,.1,-7.3),.65)
		for x in [-5,5]:
			var lamp=OmniLight3D.new();lamp.position=CENTER+p+Vector3(x,3.4,0);lamp.omni_range=14;lamp.light_energy=1.65;lamp.light_color=Color("fff2df");add_child(lamp)
			box(p+Vector3(x,3.78,0),Vector3(1.3,.07,.5),Color("fff2d7"),false)
		# Subject mural on each end wall: books, sun, waves and hills in warm colors.
		for j in range(6):
			box(p+Vector3(-7+j*2.5,2.8,sign(p.z)*9.15),Vector3(1.9,.6+sin(j)*.25,.02),COLORS[(ri+j)%8],false)
		text("IDEAS GROW HERE",p+Vector3(0,2.25,sign(p.z)*9.12),.004,Color("496366"),PI if p.z<0 else 0)
		for x in [-5.5,5.5]:pane(p+Vector3(x,2.5,sign(p.z)*9.12),2.7)
		prop("school/clock",p+Vector3(-7.7,2.3,sign(p.z)*9.05),.5,PI if p.z<0 else 0)
		prop("school/art_frame",p+Vector3(6.2,1.5,sign(p.z)*9.05),1.15,PI if p.z<0 else 0)
		mural(p+Vector3(-8.92,2.45,3),3.7,PI/2)
		if room=="Library":
			for z in [-5,5]:
				for side in [-1,1]:prop("furniture/bookcaseOpen",p+Vector3(side*8,.1,z),1.8,side*PI/2)
			prop("furniture/rugRounded",p+Vector3(0,.13,0),4.0)
		if room=="Art and music":
			prop("school/easel",p+Vector3(-1.7,.1,-7),1.65);prop("furniture/speaker",p+Vector3(1.9,.1,-7),.7)
	# A central tree garden, mosaics, library seating and a display of student work.
	for x in [-22,22]:
		box(Vector3(x,.16,0),Vector3(5.8,.24,5.8),Color("bcaa8c"));box(Vector3(x,.3,0),Vector3(5.45,.02,5.45),Color("6f956f"),false)
		prop("nature/tree_oak",Vector3(x,.3,0),4.0)
		for side in [-1,1]:prop("furniture/bench",Vector3(x,.1,side*4.5),1.55,PI if side>0 else 0)
	for x in [-35,35]:prop("daily/mosaic",Vector3(x,.11,0),2.4)
	mural(Vector3(-41.75,2.45,0),10,PI/2);mural(Vector3(41.75,2.45,0),10,-PI/2)
	# The atrium retains a visible skylight when walking beneath it.
	box(Vector3(0,4.4,0),Vector3(84,.12,26),Color("b4cec4"))
	box(Vector3(0,4.4,0),Vector3(3.6,.12,65),Color("ece2d0"))
	for x in range(-40,43,4):box(Vector3(x,4.31,0),Vector3(.12,.15,26),Color("53736f"),false)
	text("ACADEMY",Vector3(0,4.8,36.7),.007,Color("294f59"))
	text("LEARNING · CURIOSITY · KINDNESS",Vector3(0,4.1,36),.005,Color("294f59"))
	# A clock-tower portal gives the academy a recognizable civic silhouette.
	box(Vector3(0,6.25,33),Vector3(8,3.5,7),Color("dbc298"),false)
	for x in [-4.2,4.2]:box(Vector3(x,6.25,36.6),Vector3(.45,3.7,.4),Color("b9a17f"),false)
	box(Vector3(0,8.15,33),Vector3(9,.25,8),Color("507d7a"),false)
	for side in [-1,1]:
		var beam=box(Vector3(side*2.1,9.05,33),Vector3(5,.15,8),Color("507d7a"),false);beam.rotation.z=-side*.38
		WorldProps.line(architecture,CENTER+Vector3(side*3.4,8.3,36.7),CENTER+Vector3(0,10.0,36.7),.08,Color("c4b18e"))
	prop("school/clock",Vector3(0,6.5,36.6),1.65,PI)
	text("KURDLINGO",Vector3(0,5.4,36.65),.01,Color("294f59"))
	# Facade medallions and alternating stone ribs frame every classroom window.
	for side in [-1,1]:
		for i in range(7):
			var x=side*(10+i*4.5)
			box(Vector3(x,2.15,33.3),Vector3(.15,4.1,.15),Color("b6a180"),false)
			WorldProps.sphere(architecture,CENTER+Vector3(x,3.8,33.5),Vector3(.34,.34,.08),COLORS[i%8])
	# Deep entrance portico with fluted columns and an extended garden promenade.
	for x in [-7,7]:
		for z in [35,41]:
			box(Vector3(x,.22,z),Vector3(.85,.3,.85),Color("cbb998"));box(Vector3(x,2.15,z),Vector3(.44,3.8,.44),Color("e7d6b8"));box(Vector3(x,4.1,z),Vector3(.8,.18,.8),Color("cbb998"))
	box(Vector3(0,4.34,38),Vector3(17,.28,9),Color("496a6f"),false)
	box(Vector3(0,.05,49),Vector3(10,.1,32),Color("dac7a5"))
	for side in [-1,1]:
		for j in range(8):
			var p=Vector3(side*(12+j%2*6),0,38+j*3.6)
			box(p+Vector3(0,.2,0),Vector3(3,.4,2),Color("bda785"));box(p+Vector3(0,.41,0),Vector3(2.8,.02,1.8),Color("688b61"),false)
			for k in range(7):prop("school/flower",p+Vector3(-1+k*.32,.42,sin(k)*.4),.25)
		for z in [43,54]:prop("furniture/bench",Vector3(side*8,.1,z),1.55,side*PI/2)
		for z in [39,53]:prop("nature/tree_oak",Vector3(side*24,0,z),5.2)
	for side in [-1,1]:
		for j in range(7):
			var p=Vector3(side*31,0,35+j*3.2)
			prop("nature/rock_largeA",p,1.1) if ResourceLoader.exists("res://assets/nature/rock_largeA.glb") else prop("furniture/pottedPlant",p,1.1)
			for k in range(5):prop("school/flower",p+Vector3(-.8+k*.35,0,.8),.35)
	# Road links from the Discovery approach to the school and the outer ring.
	box(Vector3(-62.5,.04,-43),Vector3(249,.08,6),Color("657c80"))
	box(Vector3(119.5,.04,-43),Vector3(103,.08,6),Color("657c80"))
	box(Vector3(65,.04,-43),Vector3(6,.08,6),Color("657c80"))
	box(Vector3(65,.04,9),Vector3(6,.08,98),Color("657c80"))
	box(Vector3(65,.04,61),Vector3(6,.08,6),Color("657c80"))
	box(Vector3(33.5,.04,61),Vector3(57,.08,6),Color("657c80"))
	for x in range(-179,167,8):
		if absf(x-65)>4:box(Vector3(x,.1,-43),Vector3(2,.02,.12),Color("efe4c7"),false)
	# Green copper roofs and a glass lantern conceal themselves only while inside.
	roof=Node3D.new();add_child(roof)
	for p in [Vector3(-23,4.5,-23),Vector3(23,4.5,-23),Vector3(-23,4.5,23),Vector3(23,4.5,23)]:
		for side in [-1,1]:
			var plane=WorldProps.box(roof,CENTER+p+Vector3(0,.95,side*5.4),Vector3(40,.15,11.5),Color("507d7a"));plane.rotation.x=side*.17
			for x in range(-19,21,2):
				var rib=WorldProps.box(roof,CENTER+p+Vector3(x,1.07,side*5.4),Vector3(.045,.06,11.5),Color("83a599"));rib.rotation.x=side*.17
		WorldProps.box(roof,CENTER+p+Vector3(0,1.95,0),Vector3(40,.2,.4),Color("416c6b"))
	WorldProps.box(roof,CENTER+Vector3(0,5,0),Vector3(84,.1,23),Color("b7d5cc80"))
	for x in range(-40,43,4):WorldProps.box(roof,CENTER+Vector3(x,5.05,0),Vector3(.1,.1,23),Color("47696c"))
	AccurateProps.merge_shapes(roof)
	AccurateProps.merge_shapes(architecture)
func contains_point(p:Vector3)->bool:return absf(p.x-CENTER.x)<43 and absf(p.z-CENTER.z)<36 and p.y<5
func _process(_delta:float)->void:
	if world.player==null:return
	inside=contains_point(world.player.position);roof.visible=not inside
func word_position(row:Dictionary)->Vector3:
	var slot=int(row.school_slot);var room:String=row.school_room
	if room=="Central hall":
		return CENTER+Vector3(-15+(slot%6)*6,.11,(-8 if slot<6 else 8))
	var p:Vector3=ROOMS[room]
	# Large furniture occupies a clear bay; smaller items sit on working counters.
	if float(row.size)>1.0:
		var large_index=0
		for earlier in world.vocabulary:
			if earlier.get("school_room","")==room and int(earlier.school_slot)<slot and float(earlier.size)>1:large_index+=1
		return CENTER+p+Vector3(-7.7 if large_index%2==0 else 7.7,.11,-5+int(large_index/2)*3.3)
	return CENTER+p+Vector3(-5 if slot%2==0 else 5,.97,-5.5+int(slot/2)*1.7)
func place_word(row:Dictionary,node:Node3D)->void:
	var room:String=row.school_room
	if room=="Central hall":
		var p=node.position-CENTER
		if row.id in ["school_wall_clock","school_school_map","school_emergency_exit_sign","school_school_bell","school_coat_hook"]:
			node.position.y=2.3;node.position.z=CENTER.z+(-13.4 if p.z<0 else 13.4);node.rotation.y=PI if p.z<0 else 0
		else:
			if float(row.size)<.8:box(p+Vector3(0,.42,0),Vector3(1,.84,.7),Color("c3a581"));node.position.y=.95
	elif row.model in ["school/whiteboard","school/screen","school/noticeboard","school/timetable","school/art_frame"]:
		var p:Vector3=ROOMS[room];node.position=CENTER+p+Vector3(0,1.4,sign(p.z)*8.8);node.rotation.y=PI if p.z<0 else 0
	elif float(row.size)>1:node.rotation.y=PI/2 if node.position.x<CENTER.x+ROOMS[room].x else -PI/2
	if row.model in ["school/book","school/notebook","school/atlas","school/register","school/document","daily/planner","daily/binder"]:
		var cover=Label3D.new();cover.text=row.en.to_upper();cover.font=world.english_font;cover.font_size=24;cover.pixel_size=.0007;cover.modulate=Color("314b58");cover.outline_size=0
		cover.position=Vector3(0,float(node.get_meta("dimensions").y)+.002,0);cover.rotation.x=-PI/2;node.add_child(cover)
