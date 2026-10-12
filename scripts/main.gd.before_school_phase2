extends Node3D

const ProgressStore = preload("res://scripts/progress_store.gd")

const REGION_CENTERS = {"Town":Vector3(-61,0,-32),"Homes":Vector3(60,0,-18),"Market":Vector3(0,0,-57),"Park":Vector3(-61,0,62),"Farm":Vector3(62,0,63),"Kitchen":Vector3(180,0,-65),"Workshop":Vector3(-180,0,-65),"Discovery":Vector3(180,0,65),"Wildlife":Vector3(-180,0,65),"Lifestyle":Vector3(0,0,180),"Tourist Quarter":Vector3(-440,0,-360),"History Museum":Vector3(-220,0,-360),"Work Hub":Vector3(0,0,-360),"Entertainment Park":Vector3(220,0,-360),"Cafe Street":Vector3(440,0,-360),"Shopping Avenue":Vector3(-440,0,360),"Fitness Square":Vector3(-220,0,360),"Podcast Plaza":Vector3(0,0,360),"Travel Terminal":Vector3(220,0,360),"City Services":Vector3(440,0,360)}
const ARRIVALS = {"Town":Vector3(-40,0,-10),"Homes":Vector3(45,0,14),"Market":Vector3(0,0,-29),"Park":Vector3(-42,0,38),"Farm":Vector3(42,0,38),"Kitchen":Vector3(180,0,-108),"Workshop":Vector3(-180,0,-108),"Discovery":Vector3(180,0,22),"Wildlife":Vector3(-180,0,22),"Lifestyle":Vector3(0,0,137),"Tourist Quarter":Vector3(-440,0,-282),"History Museum":Vector3(-220,0,-282),"Work Hub":Vector3(0,0,-282),"Entertainment Park":Vector3(220,0,-282),"Cafe Street":Vector3(440,0,-282),"Shopping Avenue":Vector3(-440,0,282),"Fitness Square":Vector3(-220,0,282),"Podcast Plaza":Vector3(0,0,282),"Travel Terminal":Vector3(220,0,282),"City Services":Vector3(440,0,282)}
const REGION_COLORS = {"Town":Color("e7c29a"),"Homes":Color("eebda2"),"Market":Color("edaa88"),"Park":Color("a3c99c"),"Farm":Color("d6d395"),"Kitchen":Color("edc08e"),"Workshop":Color("b8c1d2"),"Discovery":Color("a2ccd6"),"Wildlife":Color("b4d5a0"),"Lifestyle":Color("d9b7d0"),"Tourist Quarter":Color("97aa82"),"History Museum":Color("c0d4a4"),"Work Hub":Color("a1c9c7"),"Entertainment Park":Color("b1bd9d"),"Cafe Street":Color("c1ddd4"),"Shopping Avenue":Color("c1d4dc"),"Fitness Square":Color("d5b6a4"),"Podcast Plaza":Color("a5b2cf"),"Travel Terminal":Color("dac39e"),"City Services":Color("b8ccbe")}
const INK = Color("183c49")
const CREAM = Color("f5f0df")
const TEAL = Color("70d6bc")

var vocabulary: Array = []
var by_id: Dictionary = {}
var object_nodes: Dictionary = {}
var guardians: Dictionary = {}
var rescue_cells: Dictionary = {}
var learned: Dictionary = {}
var defeated: Array = []
var xp = 0
var options = {"volume":0.8,"direction":"ckb","sensitivity":0.003,"fullscreen":false,"music_volume":0.35,"podcast_volume":0.85,"hud_size":0.75,"map_size":0.8,"subtitle_size":0.85,"sorani_subtitles":false}
var player: Explorer
var ui: Control
var hud: Control
var screen: Control
var card: Control
var card_id = ""
var waypoint_id = ""
var focus_id = ""
var ring: MeshInstance3D
var focus_label: Label3D
var progress_label: Label
var region_label: Label
var prompt_label: Label
var hud_widgets: Array=[]
var minimap_widget:Control
var fuel_status: Label
var fuel_bar: ProgressBar
var quest_label: Label
var toast_label: Label
var toast_time = 0.0
var scan_time = 0.0
var autosave_time = 0.0
var session_started = false
var voice: AudioStreamPlayer
var sound: AudioStreamPlayer
var music: AudioStreamPlayer
var music_index = 0
var music_gain = 0.0
const MUSIC_TRACKS = ["res://assets/music/vaporware.mp3","res://assets/music/first_light_particles.wav","res://assets/music/lifewave.mp3","res://assets/music/another_august.mp3","res://assets/music/november_snow.mp3"]
var current_region = "Town"
var quiz: Dictionary = {}
var answer_buttons: Array = []
var quiz_feedback: Label
var quiz_title: Label
var quiz_prompt: Label
var quiz_next: Button
var list_box: VBoxContainer
var journal_search: LineEdit
var journal_region = "All"
var journal_only_learned = false
var test_mode = false
var self_test_failed=false
var save_path = "user://progress.json"
var english_font: Font
var sorani_font: Font
var region_counts: Dictionary = {}
var object_layout: Dictionary = {}
var original_layout: Dictionary = {}
var story: StoryMissions
var teacher_circle: TeacherCircle
var podcasts:PodcastPlaza
var walk_seats:Array=[]
var expansion:ExpansionWorld
var handling: ObjectHandling

func _ready() -> void:
	var startup_started = Time.get_ticks_msec()
	Engine.max_fps = 120
	var editor_layout = WorldEditorLayout.take_scene(self)
	if not OS.has_feature("editor"):
		save_path=OS.get_executable_path().get_base_dir().path_join("save/progress.json")
		DirAccess.make_dir_recursive_absolute(save_path.get_base_dir())
	test_mode="--self-test" in OS.get_cmdline_user_args()
	if test_mode:save_path="user://self_test_progress.json"
	var preview_mode=false
	for arg in OS.get_cmdline_user_args():
		if arg=="--benchmark":preview_mode=true;save_path="user://benchmark_progress.json"
		if arg.begins_with("--capture="):preview_mode=true;save_path="user://preview_progress.json"
	english_font=load("res://assets/NotoSans.ttf")
	sorani_font=load("res://assets/NotoSansArabic.ttf")
	var parsed=JSON.parse_string(FileAccess.get_file_as_string("res://data/vocabulary.json"))
	if not parsed is Array:
		push_error("Vocabulary cannot be loaded");get_tree().quit(1);return
	vocabulary=parsed
	for row in vocabulary:
		by_id[row.id]=row
		region_counts[row.region]=int(region_counts.get(row.region,0))+1
	story=StoryMissions.new(self)
	if not test_mode and not preview_mode:load_progress()
	if not WorldEditorLayout.bind_scene(self, editor_layout):
		if is_instance_valid(editor_layout): editor_layout.free()
		get_tree().quit(1)
		return
	for id in object_nodes:
		original_layout[id]=object_nodes[id].transform
		if object_layout.has(id):
			var placement=object_layout[id]
			if placement is Array and placement.size()==4 and absf(float(placement[0]))<580 and absf(float(placement[2]))<500 and float(placement[1])>=0 and float(placement[1])<25:
				object_nodes[id].position=Vector3(placement[0],placement[1],placement[2]);object_nodes[id].rotation.y=float(placement[3])
	player=Explorer.new();player.position=Vector3(0,0.5,16);add_child(player)
	player.sensitivity=float(options.sensitivity)
	voice=AudioStreamPlayer.new();add_child(voice)
	sound=AudioStreamPlayer.new();add_child(sound)
	music=AudioStreamPlayer.new();add_child(music)
	music.finished.connect(next_music)
	next_music()
	build_ui()
	teacher_circle=TeacherCircle.new();teacher_circle.world=self;add_child(teacher_circle)
	podcasts=PodcastPlaza.new();podcasts.world=self;add_child(podcasts)
	if not test_mode and not preview_mode:load_progress()
	build_highlight()
	handling=ObjectHandling.new(self)
	update_hud()
	show_title()
	if bool(options.fullscreen):DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	get_window().close_requested.connect(func():save_progress();get_tree().quit())
	if test_mode:
		print("PHASE 1 READY ms=", Time.get_ticks_msec()-startup_started)
		call_deferred("self_test")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):call_deferred("capture_view",arg.trim_prefix("--capture="))
		if arg=="--benchmark":call_deferred("benchmark")

func build_environment() -> void:
	var env=WorldEnvironment.new();var settings=Environment.new()
	settings.background_mode=Environment.BG_SKY
	var sky=Sky.new();var sky_material=ProceduralSkyMaterial.new()
	sky_material.sky_top_color=Color("6aadd2");sky_material.sky_horizon_color=Color("cce4dc")
	sky_material.ground_bottom_color=Color("80a878");sky_material.ground_horizon_color=Color("cce4dc")
	sky.sky_material=sky_material;settings.sky=sky
	settings.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color=Color("dcebe8");settings.ambient_light_energy=0.32
	settings.tonemap_mode=Environment.TONE_MAPPER_ACES;settings.tonemap_exposure=0.85
	settings.fog_enabled=true;settings.fog_light_color=Color("bddbd8");settings.fog_density=0.0018
	env.environment=settings;add_child(env)
	var sun=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-48,-28,0);sun.light_color=Color("fff0d4");sun.light_energy=0.85
	sun.shadow_enabled=true;sun.directional_shadow_max_distance=90;sun.directional_shadow_mode=DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS;add_child(sun)
	Engine.max_fps=120

func solid_box(p: Vector3, s: Vector3, color: Color, collision: bool = true) -> Node3D:
	var holder=Node3D.new();holder.position=p;add_child(holder)
	WorldProps.box(holder,Vector3.ZERO,s,color)
	if collision:
		var body=StaticBody3D.new();holder.add_child(body)
		var shape=CollisionShape3D.new();var box_shape=BoxShape3D.new();box_shape.size=s;shape.shape=box_shape;body.add_child(shape)
	return holder

func decoration(model: String, p: Vector3, target_size: float, rotation_y: float = 0) -> Node3D:
	var prop=WorldProps.make(model,target_size);prop.position=p;prop.rotation.y=rotation_y;add_child(prop)
	if model in ["furniture/chair","furniture/bench"]:walk_seats.append({"node":prop,"word":""})
	if (model.contains("tree") or model.begins_with("commercial/building")) and target_size>3:
		var dims: Vector3=prop.get_meta("dimensions")
		var obstruction=StaticBody3D.new();obstruction.collision_layer=4;obstruction.collision_mask=0;prop.add_child(obstruction)
		var shape=CollisionShape3D.new();var bounds=BoxShape3D.new();bounds.size=dims;shape.shape=bounds;shape.position.y=dims.y*.5;obstruction.add_child(shape)
	return prop

func signpost(text: String, point: Vector3, color: Color) -> void:
	solid_box(point+Vector3(0,1.2,0),Vector3(0.16,2.4,0.16),Color("9d815b"))
	solid_box(point+Vector3(0,2.5,0),Vector3(5,0.9,0.25),color,false)
	var label=Label3D.new();label.text=text;label.font=english_font;label.font_size=44;label.pixel_size=0.005
	label.position=point+Vector3(0,2.5,0.15);label.modulate=INK;label.no_depth_test=false;add_child(label)

func build_world() -> void:
	solid_box(Vector3(0,-0.3,0),Vector3(1180,0.6,1020),Color("65a66a"))
	# Roads form one surface: crossing segments meet without overlapping faces.
	for x in [-28,15]:
		solid_box(Vector3(x,.04,0),Vector3(10,.08,212),Color("657c80"),false)
		for side in [-1,1]:
			for interval in [Vector2(-106,-26.6),Vector2(-13.4,23.4),Vector2(36.6,106)]:
				solid_box(Vector3(x+side*6,.075,(interval.x+interval.y)*.5),Vector3(2,.15,interval.y-interval.x),Color("d6d5bd"))
		for z in range(-100,106,7):
			if absf(z+20)<6 or absf(z-30)<6:continue
			solid_box(Vector3(x,.10,z),Vector3(.14,.02,2.2),Color("f1e3b3"),false)
	for z in [-20,30]:
		for interval in [Vector2(-116.5,-33),Vector2(-23,10),Vector2(20,116.5)]:
			solid_box(Vector3((interval.x+interval.y)*.5,.04,z),Vector3(interval.y-interval.x,.08,9),Color("657c80"),false)
		for side in [-1,1]:
			for interval in [Vector2(-116.5,-35),Vector2(-21,8),Vector2(22,116.5)]:
				solid_box(Vector3((interval.x+interval.y)*.5,.075,z+side*5.6),Vector3(interval.y-interval.x,.15,2.2),Color("d6d5bd"))
		for x in range(-112,116,7):
			if absf(x+28)<6 or absf(x-15)<6:continue
			solid_box(Vector3(x,.10,z),Vector3(2.2,.02,.14),Color("f1e3b3"),false)
	for x in [-28,15]:
		for z in [-20,30]:
			for side in [-1,1]:
				for i in range(6):
					solid_box(Vector3(x-3+i*1.1,.105,z+side*7),Vector3(.6,.02,2.4),CREAM,false)
					solid_box(Vector3(x+side*7,.105,z-3+i*1.1),Vector3(2.4,.02,.6),CREAM,false)
	solid_box(Vector3(-2,0.05,10),Vector3(20,0.1,22),Color("e4d9b9"))
	decoration("furniture/bench",Vector3(9,0.12,12),2.8,PI/2)
	decoration("suburban/tree-large",Vector3(-9,0,1),5)
	signpost("WELCOME / KurdLingo",Vector3(-10,0,20),TEAL)
	for region in ARRIVALS:signpost(region.to_upper(),ARRIVALS[region]+Vector3(0,0,2.5),REGION_COLORS[region])
	# Habitable rooms: low walls preserve the third-person sightline.
	var rooms=[Vector3(38,0,-47),Vector3(65,0,-47),Vector3(92,0,-47),Vector3(38,0,-1),Vector3(70,0,-1)]
	for index in range(rooms.size()):
		var p=rooms[index]
		solid_box(p+Vector3(0,0.09,0),Vector3(23,0.18,22),[Color("ecdfc5"),Color("dde4dd"),Color("dfd0be")][index%3])
		solid_box(p+Vector3(0,1.1,-11),Vector3(23,2.2,0.3),Color("f0c6a6"))
		for side in [-1,1]:solid_box(p+Vector3(side*11.5,1.1,0),Vector3(0.3,2.2,22),Color("edcfb3"))
		for side in [-1,1]:solid_box(p+Vector3(side*8.5,1.1,11),Vector3(6,2.2,0.3),Color("edcfb3"))
		signpost(["LIVING ROOM","STUDY","BATH & KITCHEN","HOME ESSENTIALS","WORKSHOP"][index],p+Vector3(0,0,13),REGION_COLORS.Homes)
	# Marketplace: each stall is a real counter with a striped canopy.
	for index in range(13):
		var p=market_stall(index)
		solid_box(p+Vector3(0,0.72,0),Vector3(8.2,1.44,2.3),Color("bda47b"))
		for x in [-4,4]:solid_box(p+Vector3(x,1.8,-1),Vector3(0.12,3.6,0.12),Color("a3815c"))
		for stripe in range(8):solid_box(p+Vector3(-3.5+stripe,3.65,-0.1),Vector3(1,0.12,3.1),Color("ec9d81") if stripe%2==0 else CREAM,false)
	# Park grass stops before sidewalks; paths have separate, non-overlapping faces.
	solid_box(Vector3(-68,.004,65),Vector3(64,.012,54),Color("6baa65"),false)
	for interval in [Vector2(38,62),Vector2(66,92)]:
		solid_box(Vector3(-45,.04,(interval.x+interval.y)*.5),Vector3(4,.02,interval.y-interval.x),Color("dbcbac"),false)
	solid_box(Vector3(-68,.04,64),Vector3(64,.02,4),Color("dbcbac"),false)
	solid_box(Vector3(-35.5,.04,64),Vector3(1,.02,4),Color("dbcbac"),false)
	solid_box(Vector3(-45,.04,37.3),Vector3(4,.02,1.4),Color("dbcbac"),false)
	var water=WorldProps.cylinder(self,Vector3(-86,0.065,82),10,0.12,Color("69b9ca"));water.scale.z=0.7
	decoration("nature/bridge_wood",Vector3(-86,0.05,82),8)
	# Farm paddock and planted crop rows.
	solid_box(Vector3(63,0.018,70),Vector3(74,0.04,60),Color("b9bf84"),false)
	for z in range(49,95,7):
		solid_box(Vector3(87,0.07,z),Vector3(23,0.12,2.2),Color("967b55"),false)
		for x in range(77,99,3):decoration("nature/crop_carrot",Vector3(x,0.14,z),0.75)
	for x in range(30,110,5):decoration("suburban/fence-low",Vector3(x,0,101),5)
	# Distant skyline and woodland frame the map.
	for index in range(15):
		var letter=char(97+index%14)
		decoration("commercial/building-"+letter,Vector3(-110+index*15,0,-145),12+index%4*3)
	for index in range(70):
		var x=-112+float((index*37)%226)
		var z=104 if index%2==0 else -92
		decoration("nature/tree_pineTallA",Vector3(x,0,z),5+index%4)
	for index in range(18):
		var z=-92+index*11
		decoration("suburban/tree-large",Vector3(-116,0,z),6)
		decoration("suburban/tree-small",Vector3(116,0,z),5)
	for z in range(-87,100,17):
		decoration("custom/streetlight",Vector3(-35,0,z),4.6)
		decoration("custom/streetlight",Vector3(22,0,z),4.6)
	# Five annex neighborhoods preserve the original 500 object locations.
	for district in ["Kitchen","Workshop","Discovery","Wildlife","Lifestyle"]:
		var center=REGION_CENTERS[district]
		solid_box(center+Vector3(0,0.02,0),Vector3(88,0.04,90),REGION_COLORS[district],false)
		solid_box(center+Vector3(0,0.06,-4),Vector3(4,0.08,82),Color("ddd5ba"),false)
		var sign=Label3D.new();sign.font=english_font;sign.text=district.to_upper();sign.font_size=80;sign.pixel_size=0.008;sign.position=center+Vector3(0,5,-43);add_child(sign)
		for side in [-1,1]:
			for k in range(9):decoration("nature/tree_oak",center+Vector3(side*45,0,-36+k*9),4)
		if district=="Lifestyle":solid_box(Vector3(0,.04,85.8),Vector3(8,.08,98.4),Color("ddd5ba"),false)

	# Connected approaches: north routes turn outside the skyline; south routes are direct.
	for side in [-1,1]:
		var start_x=22.0 if side>0 else -35.0
		var bend_x=side*128.0
		var end_x=side*178.0
		var outer_x=bend_x+side*1.5
		solid_box(Vector3((start_x+outer_x)*.5,.04,-28),Vector3(absf(outer_x-start_x),.08,3),Color("c9b997"),false)
		solid_box(Vector3(bend_x,.04,-68),Vector3(3,.08,77),Color("c9b997"),false)
		var inner_x=bend_x-side*1.5
		solid_box(Vector3((inner_x+end_x)*.5,.04,-108),Vector3(absf(end_x-inner_x),.08,3),Color("c9b997"),false)
		solid_box(Vector3((start_x+end_x)*.5,.04,22),Vector3(absf(end_x-start_x),.08,3),Color("c9b997"),false)
	build_connected_roads()
	Neighborhoods.new(self).build()
	expansion=ExpansionWorld.new(self);expansion.build()
	# Place each distinct word in its own physical location.
	var counters={}
	for row in vocabulary:
		var index=int(counters.get(row.region,0));counters[row.region]=index+1
		var p=word_position(row,index,rooms)
		add_word(row,p)
	for region in ARRIVALS:
		var p=ARRIVALS[region]+Vector3(5,0,-4)
		var robot=WorldProps.make("custom/robot",2.0);robot.position=p;add_child(robot)
		robot.set_meta("region",region)
		guardians[region]=robot
		if region in defeated:robot.scale=Vector3.ONE*0.75
		var label=Label3D.new();label.font=english_font;label.text="REBOOTED" if region in defeated else "WORD GUARDIAN"
		label.position.y=2.4;label.font_size=32;label.pixel_size=0.006;label.billboard=BaseMaterial3D.BILLBOARD_ENABLED
		label.modulate=TEAL if region in defeated else Color("ffe0a8");robot.add_child(label)
		var neighbor=WorldProps.make("custom/human",1.9);neighbor.position=p+Vector3(3,0,0);add_child(neighbor)
		var cell=Node3D.new();cell.position=neighbor.position;add_child(cell);rescue_cells[region]=cell
		for x in [-0.8,0.8]:
			for z in [-0.8,0.8]:
				var beam=WorldProps.cylinder(cell,Vector3(x,1.2,z),0.035,2.4,Color("efca79"));beam.material_override=WorldProps.material(Color("efca79"),true)
		for y in [0.1,2.4]:
			WorldProps.box(cell,Vector3(0,y,0),Vector3(1.7,0.06,1.7),Color("819792"))
		cell.visible=not region in defeated

func market_stall(index: int) -> Vector3:
	return Vector3(-9+float(index%3)*17,0,-43-float(index/3)*13)

func word_position(row: Dictionary, index: int, rooms: Array) -> Vector3:
	if row.get("expansion",false):return expansion.word_position(row,index)
	if row.id=="fountain":return Vector3(0,0.11,6)
	if row.id=="bench":return Vector3(-8,0.12,12)
	if row.id=="tree":return Vector3(9,0,1)
	match row.region:
		"Homes":
			var room=int(index/14);var k=index%14
			var p=rooms[room]+Vector3(-8+(k%4)*5.1,0.2,-7+int(k/4)*5)
			if row.id=="chair":p.y=.2
			if row.size<0.85:
				solid_box(p+Vector3(0,0.52,0),Vector3(1.5,1.04,1.5),Color("c5b08a"))
				p.y=1.26
			return p
		"Market":return market_stall(int(index/6))+Vector3(-3.4+(index%6)*1.35,1.45,0)
		"Town":
			if index<5:return Vector3(-99+index*14,0,-74)
			return Vector3(-99+(index-5)%5*14,0,-54+int((index-5)/5)*15)
		"Park":
			var p=Vector3(-99+index%6*10,0,40+int(index/6)*14)
			if row.size<1.6:
				solid_box(p+Vector3(0,0.45,0),Vector3(1.4,0.9,1.4),Color("d2c9a8"));p.y=0.91
			return p
		"Farm":
			var p=Vector3(34+index%5*9,0,46+int(index/5)*11)
			if row.size<1.1:
				solid_box(p+Vector3(0,0.45,0),Vector3(1.4,0.9,1.4),Color("bea878"));p.y=0.91
			return p
	var center: Vector3=REGION_CENTERS[row.region]
	var point=center+Vector3(-35+(index%8)*10,0,-31+int(index/8)*10)
	if row.region!="Wildlife":point.y=.97
	return point

func add_word(row: Dictionary, point: Vector3) -> void:
	var prop=WorldProps.make(row.model,float(row.size));prop.position=point;add_child(prop)
	prop.set_meta("word_id",row.id);object_nodes[row.id]=prop
	if row.id in ["chair","school_chair","bench","gallery_bench"]:walk_seats.append({"node":prop,"word":row.id})
	var dimensions: Vector3=prop.get_meta("dimensions",Vector3.ONE)
	if row.id in ["hospital","school","shop"]:AccurateProps.building_identity(prop,row.id,dimensions)
	var body=StaticBody3D.new();body.collision_layer=3;body.collision_mask=1;body.set_meta("word_id",row.id);prop.add_child(body)
	var shape=CollisionShape3D.new();var collision=BoxShape3D.new()
	collision.size=Vector3(maxf(dimensions.x,0.35),maxf(dimensions.y,0.25),maxf(dimensions.z,0.35))
	shape.shape=collision;shape.position.y=dimensions.y*0.5;body.add_child(shape)
	# Context labels distinguish civic buildings that share a modular architecture.
	if row.id in ["school","hospital","shop"]:
		var label=Label3D.new();label.font=english_font;label.text=row.en.to_upper();label.font_size=50;label.pixel_size=0.015
		label.position=Vector3(0,dimensions.y*0.55,dimensions.z*0.5+0.08);label.modulate=INK;prop.add_child(label)

func build_highlight() -> void:
	ring=MeshInstance3D.new();var mesh=TorusMesh.new();mesh.inner_radius=0.55;mesh.outer_radius=0.63;mesh.rings=32;mesh.ring_segments=8
	ring.mesh=mesh;ring.material_override=WorldProps.material(TEAL,true);ring.visible=false;add_child(ring)
	focus_label=Label3D.new();focus_label.font=english_font;focus_label.font_size=36;focus_label.pixel_size=0.006
	focus_label.billboard=BaseMaterial3D.BILLBOARD_ENABLED;focus_label.modulate=CREAM;focus_label.outline_modulate=INK;focus_label.outline_size=8
	focus_label.visible=false;add_child(focus_label)

func make_style(color: Color, radius: int = 18, border: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var s=StyleBoxFlat.new();s.bg_color=color
	s.set_corner_radius_all(radius);s.set_content_margin_all(18)
	if border.a>0:s.border_color=border;s.set_border_width_all(1)
	return s

func label(text: String, font_size: int = 20, color: Color = INK, sorani: bool = false) -> Label:
	var n=Label.new();n.text=text;n.add_theme_font_override("font",sorani_font if sorani else english_font)
	n.add_theme_font_size_override("font_size",font_size);n.add_theme_color_override("font_color",color)
	return n

func button(text: String, action: Callable, primary: bool = false) -> Button:
	var b=Button.new();b.text=text;b.custom_minimum_size=Vector2(0,46);b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	b.add_theme_font_override("font",english_font);b.add_theme_font_size_override("font_size",17)
	b.add_theme_color_override("font_color",INK)
	b.add_theme_color_override("font_hover_color",INK)
	b.add_theme_stylebox_override("normal",make_style(TEAL if primary else Color("e9e5d7"),10))
	b.add_theme_stylebox_override("hover",make_style(Color("91e3ca") if primary else Color("dadfcf"),10))
	b.add_theme_stylebox_override("pressed",make_style(Color("60bda6"),10))
	b.add_theme_stylebox_override("focus",make_style(Color.TRANSPARENT,10,Color("c98b52")))
	b.pressed.connect(action);return b

func panel(parent: Control, p: Vector2, s: Vector2, color: Color = CREAM) -> PanelContainer:
	var n=PanelContainer.new();n.position=p;n.size=s;n.add_theme_stylebox_override("panel",make_style(color));parent.add_child(n);return n

func vbox(parent: Control, separation: int = 10) -> VBoxContainer:
	var n=VBoxContainer.new();n.add_theme_constant_override("separation",separation);parent.add_child(n);return n

func hbox(parent: Control, separation: int = 10) -> HBoxContainer:
	var n=HBoxContainer.new();n.add_theme_constant_override("separation",separation);parent.add_child(n);return n

func build_ui() -> void:
	var layer=CanvasLayer.new();add_child(layer)
	ui=Control.new();ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);ui.mouse_filter=Control.MOUSE_FILTER_IGNORE;layer.add_child(ui)
	var theme=Theme.new();theme.default_font=english_font;theme.default_font_size=18
	for control_type in ["CheckButton","OptionButton","LineEdit"]:
		theme.set_color("font_color",control_type,INK)
		theme.set_color("font_hover_color",control_type,INK)
		theme.set_color("font_pressed_color",control_type,INK)
	theme.set_color("font_placeholder_color","LineEdit",Color("63827d"))
	theme.set_stylebox("normal","LineEdit",make_style(Color("e2e4d6"),10))
	theme.set_stylebox("focus","LineEdit",make_style(Color("e2e4d6"),10,TEAL))
	theme.set_stylebox("normal","OptionButton",make_style(Color("e2e4d6"),10))
	ui.theme=theme
	hud=Control.new();hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);hud.mouse_filter=Control.MOUSE_FILTER_IGNORE;ui.add_child(hud)
	var identity=panel(hud,Vector2(24,22),Vector2(335,122),Color("f5f0dff0"))
	var iv=vbox(identity,3)
	iv.add_child(label("KurdLingo",20,INK))
	region_label=label("Arrival square",14,Color("63827d"));iv.add_child(region_label)
	progress_label=label("0 / 1000 discovered",17);iv.add_child(progress_label)
	var top=HBoxContainer.new();top.anchor_left=1;top.anchor_right=1;top.offset_left=-940;top.offset_top=24;top.offset_right=-24;top.offset_bottom=70;top.add_theme_constant_override("separation",8);hud.add_child(top)
	top.add_child(button("Story [T]",func():story.menu()))
	top.add_child(button("Podcasts [P]",func():podcasts.menu()))
	top.add_child(button("Ride [F]",ride_action))
	top.add_child(button("Journal  [J]",show_journal))
	top.add_child(button("Map  [M]",show_map))
	top.add_child(button("Practice  [Q]",func():start_quiz("", ""),true))
	top.add_child(button("Settings",show_settings))
	for b in top.get_children():
		b.custom_minimum_size.y=36;b.add_theme_font_size_override("font_size",15)
		for state in ["normal","hover","pressed"]:
			var style=b.get_theme_stylebox(state).duplicate();style.set_content_margin_all(9);b.add_theme_stylebox_override(state,style)
	var quest=panel(hud,Vector2(24,158),Vector2(335,114),Color("193e49e8"));var qv=vbox(quest,5)
	qv.add_child(label("FIELD MISSION",12,TEAL));quest_label=label("",15,CREAM);quest_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;quest_label.custom_minimum_size.x=285;qv.add_child(quest_label)
	var mini=panel(hud,Vector2(24,0),Vector2(220,223),Color("193e49e8"));mini.anchor_top=1;mini.anchor_bottom=1;mini.offset_top=-247;mini.offset_bottom=-24
	minimap_widget=mini
	var mv=vbox(mini,5);mv.add_child(label("NEIGHBORHOOD MAP",11,TEAL))
	var map=load("res://scripts/map.gd").new();map.game=self;map.custom_minimum_size=Vector2(182,165);mv.add_child(map)
	var controls=panel(hud,Vector2(0,0),Vector2(710,58),Color("193e49e8"));controls.anchor_left=0.5;controls.anchor_right=0.5;controls.anchor_top=1;controls.anchor_bottom=1
	controls.offset_left=-350;controls.offset_right=350;controls.offset_top=-83;controls.offset_bottom=-25
	prompt_label=label("WASD Move  ·  Shift Run  ·  Space Jetpack  ·  F Scooter  ·  P Podcasts",14,CREAM);prompt_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;controls.add_child(prompt_label)
	var energy=panel(hud,Vector2.ZERO,Vector2(190,94),Color("193e49e8"));energy.anchor_left=1;energy.anchor_right=1;energy.anchor_top=1;energy.anchor_bottom=1
	energy.offset_left=-214;energy.offset_right=-24;energy.offset_top=-118;energy.offset_bottom=-24
	var ev=vbox(energy,6);ev.add_child(label("JETPACK FUEL",11,TEAL));fuel_bar=ProgressBar.new();fuel_bar.max_value=Explorer.MAX_FUEL;fuel_bar.value=Explorer.MAX_FUEL;fuel_bar.show_percentage=false;fuel_bar.custom_minimum_size.y=12
	fuel_bar.add_theme_stylebox_override("background",make_style(Color("32565c"),6));fuel_bar.add_theme_stylebox_override("fill",make_style(TEAL,6));ev.add_child(fuel_bar);fuel_status=label("37 s · Ready",12,TEAL);ev.add_child(fuel_status)
	toast_label=label("",18,CREAM);toast_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;toast_label.anchor_left=0.5;toast_label.anchor_right=0.5;toast_label.offset_left=-400;toast_label.offset_right=400;toast_label.offset_top=112
	hud_widgets=[identity,top,quest,mini,controls,energy]
	apply_hud_size()
	call_deferred("apply_hud_size")
	toast_label.add_theme_color_override("font_outline_color",INK);toast_label.add_theme_constant_override("outline_size",7);hud.add_child(toast_label)

func clear_screen() -> void:
	if is_instance_valid(screen):ui.remove_child(screen);screen.queue_free()
	screen=null
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	player.enabled=session_started

func overlay() -> Control:
	if handling!=null:handling.cancel()
	clear_screen()
	if is_instance_valid(card):card.hide()
	screen=Control.new();screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);ui.add_child(screen)
	var shade=ColorRect.new();shade.color=Color("0b23336e");shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);screen.add_child(shade)
	player.enabled=false
	return screen

func centered_panel(s: Vector2) -> PanelContainer:
	var result=panel(screen,Vector2.ZERO,s)
	result.anchor_left=0.5;result.anchor_right=0.5;result.anchor_top=0.5;result.anchor_bottom=0.5
	result.offset_left=-s.x/2;result.offset_top=-s.y/2;result.offset_right=s.x/2;result.offset_bottom=s.y/2
	return result

func show_title() -> void:
	overlay();hud.hide()
	player.teleport(Vector3(0,0.5,18));player.yaw=-0.25;player.pitch=0.28;player.distance=10
	var p=panel(screen,Vector2(0,0),Vector2(490,620));p.anchor_left=1;p.anchor_right=1;p.anchor_top=0.5;p.anchor_bottom=0.5;p.offset_left=-540;p.offset_right=-50;p.offset_top=-310;p.offset_bottom=310
	var v=vbox(p,15)
	v.add_child(label("A LANGUAGE ADVENTURE",13,Color("68847e")))
	v.add_child(label("KurdLingo",58))
	v.add_child(label("کوردلینگۆ",36,INK,true))
	var sub=label("Meet a new world.\nLearn its words.",24);v.add_child(sub)
	var desc=label("Explore ten colorful neighborhoods. Discover objects in English and Sorani Kurdish. Use your new words to reboot rogue robots and rescue your neighbors.",17,Color("65817d"));desc.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;desc.custom_minimum_size.x=420;v.add_child(desc)
	v.add_child(label("1,000 WORDS   /   20 DISTRICTS   /   OFFLINE AUDIO",12,Color("68847e")))
	v.add_child(button("Continue adventure" if learned.size()>0 else "Begin adventure",begin_game,true))
	var row=hbox(v);row.add_child(button("How to play",show_help));row.add_child(button("Credits",show_credits));row.add_child(button("Quit",func():save_progress();get_tree().quit()))
	v.add_child(label("English + کوردیی سۆرانی  ·  Alpha 0.8",13,Color("68847e"),true))

func begin_game() -> void:
	session_started=true;clear_screen();hud.show();player.enabled=true
	toast("Explore nearby objects. Press E or click to learn a word.")
	update_hud()

func show_help() -> void:
	overlay();var p=centered_panel(Vector2(760,690));var v=vbox(p,16)
	v.add_child(label("Your first expedition",30))
	v.add_child(label("WASD / arrow keys     Walk\nShift                           Run / scooter boost\nF                                  Ride / fold your scooter\nP                                  Choose a podcast\nHold Space                 Rise with your jetpack\nRight mouse + drag    Turn the camera\nMouse wheel               Zoom\nE / left click                 Inspect a nearby object\nLeft click + drag          Pick up a small object\nRelease / Esc               Place / cancel placement\nJ / M / Q / T                Journal / map / practice / story\nE at the flag teacher    Choose 17 narrated stories\nE by a listening chair or podcast sofa   Sit / stand\nR                                  Replay the current word\nEsc                               Close a panel / pause",19))
	var t=label("Discover objects to fill your journal. Each district has a rogue robot holding a neighbor captive: discover 8 local words, then answer three vocabulary questions to reboot it and free the neighbor. Correct answers build mastery; harder words return for review.",18,Color("5b7d78"));t.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;t.custom_minimum_size.x=680;v.add_child(t)
	v.add_child(button("Back",func():clear_screen() if session_started else show_title(),true))

func toast(text: String) -> void:
	toast_label.text=text;toast_time=4.5

func _physics_process(_delta: float) -> void:
	if handling!=null:handling.update()

func _process(delta: float) -> void:
	if player==null:return
	var music_target=float(options.music_volume)*(0.15 if voice.playing or (teacher_circle.narrator.playing and not teacher_circle.paused) or (podcasts!=null and podcasts.playing and not podcasts.paused) else 1.0)
	music_gain=move_toward(music_gain,music_target,delta*0.65)
	music.volume_db=linear_to_db(maxf(music_gain,0.00001))
	music.stream_paused=float(options.music_volume)<=0.0
	fuel_bar.value=player.fuel
	fuel_status.text=str(int(ceil(player.fuel/Explorer.FUEL_DRAIN)))+" s · "+("Flying" if player.flying else "Charging" if player.fuel<Explorer.MAX_FUEL else "Ready")
	fuel_status.modulate=Color("ffd18a") if player.fuel<60 else Color.WHITE
	scan_time+=delta;autosave_time+=delta
	if toast_time>0:
		toast_time-=delta
		if toast_time<=0:toast_label.text=""
	if autosave_time>15 and session_started:save_progress();autosave_time=0
	if scan_time>0.14 and session_started:
		scan_time=0;scan_focus();update_hud()
	if ring.visible:ring.rotation.y+=delta*0.4
	if waypoint_id!="" and object_nodes.has(waypoint_id) and screen==null and teacher_circle.nearby()=="":
		var distance=player.position.distance_to(object_nodes[waypoint_id].position)
		prompt_label.text="Waypoint: "+by_id[waypoint_id].en+"  ·  "+str(int(distance))+" m   |   E inspect   ·   M map"

func _unhandled_input(event: InputEvent) -> void:
	if handling!=null and handling.handle(event):get_viewport().set_input_as_handled();return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_ESCAPE:
			if screen!=null:
				if not quiz.is_empty():quiz={}
				if session_started:clear_screen()
				else:show_title()
			elif is_instance_valid(card) and card.visible:card.hide();card_id=""
			else:show_pause()
			get_viewport().set_input_as_handled();return
		if screen!=null or not session_started:return
		match event.keycode:
			KEY_E:interact()
			KEY_T:story.menu()
			KEY_P:podcasts.menu()
			KEY_F:ride_action()
			KEY_J:show_journal()
			KEY_M:show_map()
			KEY_Q:start_quiz("", "")
			KEY_R:
				if card_id!="":play_word(card_id,str(options.direction))

func distance_to_object(id: String) -> float:
	var obj=object_nodes[id]
	var dims: Vector3=obj.get_meta("dimensions",Vector3.ONE)
	var p=player.position-obj.position
	# Surface distance makes large buildings inspectable at their door.
	var dx=maxf(absf(p.x)-dims.x*0.5,0);var dz=maxf(absf(p.z)-dims.z*0.5,0)
	return Vector2(dx,dz).length()

func scan_focus() -> void:
	var closest=5.5;var found=""
	for id in object_nodes:
		var d=distance_to_object(id)
		if d<closest:closest=d;found=id
	for region in guardians:
		var d=player.position.distance_to(guardians[region].position)
		if d<closest:closest=d;found="guardian:"+region
	if teacher_circle.nearby()!="":found=""
	focus_id=found
	ring.visible=found!="" and screen==null
	focus_label.visible=ring.visible
	if found!="":
		var obj=guardians[found.trim_prefix("guardian:")] if found.begins_with("guardian:") else object_nodes[found]
		var dims: Vector3=obj.get_meta("dimensions",Vector3.ONE*2)
		ring.position=obj.position+Vector3(0,0.075,0);ring.scale=Vector3.ONE*clampf(maxf(dims.x,dims.z)*0.75,0.6,2.5)
		focus_label.position=obj.position+Vector3(0,dims.y+0.65,0)
		focus_label.text="E  ·  Word guardian" if found.begins_with("guardian:") else "E  ·  "+by_id[found].en
		prompt_label.text="E Inspect  ·  Hover to point  ·  Left-drag objects  ·  Right-drag Look"
	else:prompt_label.text="WASD Move  ·  Shift Run  ·  Space Jetpack  ·  F Scooter  ·  P Podcasts"
	if teacher_circle.nearby()!="":prompt_label.text="E · "+("Talk to the teacher" if teacher_circle.nearby()=="teacher" else "Stand up" if player.seated else "Sit and listen")
	var nearest=1e9
	for region in REGION_CENTERS:
		var d=player.position.distance_to(REGION_CENTERS[region])
		if d<nearest:nearest=d;current_region=region
	if absf(player.position.x)<16 and player.position.z>-20 and player.position.z<30:current_region="Town"

func interact() -> void:
	if podcasts.interact():return
	if teacher_circle.interact():return
	if focus_id=="":toast("Move closer to an object, then press E.");return
	if focus_id.begins_with("guardian:"):start_quiz(focus_id.trim_prefix("guardian:"),"")
	else:inspect_word(focus_id)

func ride_action()->void:
	if podcasts.listener_seated:podcasts.stand()
	elif player.seated:teacher_circle.stand()
	if player.toggle_ride():toast("Scooter · WASD steer · Shift boost · F dismount · Space jetpack" if player.riding else "Scooter folded · Walking")
	else:toast("Land on the ground to unfold your scooter.")

func discover(id: String) -> bool:
	if learned.has(id):return false
	learned[id]={"correct":0,"wrong":0,"due":0,"seen":int(Time.get_unix_time_from_system())}
	xp+=10
	return true

func inspect_word(id: String) -> void:
	if player.riding:player.riding=false
	var first=discover(id)
	if is_instance_valid(card):ui.remove_child(card);card.queue_free()
	card_id=id;var row=by_id[id]
	card=panel(ui,Vector2.ZERO,Vector2(750,280));card.anchor_left=0.5;card.anchor_right=0.5;card.anchor_top=1;card.anchor_bottom=1
	card.offset_left=-375;card.offset_right=375;card.offset_top=-375;card.offset_bottom=-95
	var v=vbox(card,9)
	var header=hbox(v)
	var status=label(row.region.to_upper()+"  /  "+("NEW DISCOVERY  +10 XP" if first else "DISCOVERED"),12,Color("68847e"));status.size_flags_horizontal=Control.SIZE_EXPAND_FILL;header.add_child(status)
	var close=button("×",func():card.hide();card_id="");close.custom_minimum_size=Vector2(35,30);header.add_child(close)
	var words=hbox(v,30)
	var en=label(row.en,30);en.size_flags_horizontal=Control.SIZE_EXPAND_FILL;words.add_child(en)
	var ckb=label(row.ckb,36,INK,true);ckb.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT;ckb.size_flags_horizontal=Control.SIZE_EXPAND_FILL;words.add_child(ckb)
	var actions=hbox(v,10)
	actions.add_child(button("Hear Sorani",func():play_word(id,"ckb"),true))
	actions.add_child(button("Hear English",func():play_word(id,"en")))
	actions.add_child(button("Practice this word",func():start_quiz("",id)))
	actions.add_child(button("Flag voice",func():flag_voice(id)))
	if row.has("example_en"):
		v.add_child(label(row.example_en,16))
		v.add_child(label(row.example_ckb,18,INK,true))
	var correct=int(learned[id].correct)
	v.add_child(label("Mastery: "+str(mini(correct,5))+" / 5 correct reviews",13,Color("68847e")))
	play_word(id,str(options.direction));update_hud();save_progress()
	if waypoint_id==id:waypoint_id=""
	if story!=null:story.on_inspect(id)

func play_word(id: String, language: String) -> void:
	# Native-speaker recordings can replace any word without rebuilding the game.
	var recording_root=OS.get_executable_path().get_base_dir() if not OS.has_feature("editor") else ProjectSettings.globalize_path("res://")
	var replacement=recording_root.path_join("recordings").path_join(language).path_join(id+".wav")
	if FileAccess.file_exists(replacement):
		var recording=AudioStreamWAV.load_from_file(replacement)
		if recording!=null:
			voice.stream=recording;voice.volume_db=linear_to_db(float(options.volume));voice.play();return
	var path="res://assets/audio/"+language+"/"+id+".wav"
	if ResourceLoader.exists(path):
		voice.stream=load(path);voice.volume_db=linear_to_db(float(options.volume));voice.play()
	else:toast("Pronunciation recording is missing for this word.")

func region_discovered(region: String) -> int:
	var result=0
	for id in learned:
		if by_id.has(id) and by_id[id].region==region:result+=1
	return result

func update_hud() -> void:
	if progress_label==null:return
	progress_label.text=str(learned.size())+" / "+str(vocabulary.size())+" discovered   ·   "+str(xp)+" XP"
	region_label.text=current_region+"  ·  "+str(defeated.size())+" / 20 neighbors rescued"
	var local=region_discovered(current_region)
	if current_region in defeated:quest_label.text=current_region+" guardian rebooted.\nKeep exploring: "+str(local)+" / "+str(region_counts[current_region])+" words."
	elif local<8:quest_label.text="Discover "+str(8-local)+" more words in "+current_region+" to challenge its guardian."
	else:quest_label.text="Guardian ready! Find the robot by the "+current_region+" sign and press E."

	if story!=null and not story.active_chapter().is_empty():
		var chapter=story.active_chapter()
		quest_label.text="Story: "+chapter.title+"\nFind the "+by_id[chapter.target].en+" · Press E · Step "+str(int(story.state.step)+1)+" / 3"

func show_pause() -> void:
	overlay();var p=centered_panel(Vector2(440,360));var v=vbox(p,14)
	v.add_child(label("Expedition paused",28))
	v.add_child(button("Resume",clear_screen,true));v.add_child(button("How to play",show_help));v.add_child(button("Settings",show_settings));v.add_child(button("Save and quit",func():save_progress();get_tree().quit()))

func show_settings() -> void:
	overlay();var p=centered_panel(Vector2(650,720));var outer=vbox(p,8);var scroll=ScrollContainer.new();scroll.custom_minimum_size=Vector2(590,600);outer.add_child(scroll);var v=vbox(scroll,12);v.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	v.add_child(label("Make yourself at home",28))
	v.add_child(label("Language to practice",16,Color("63827d")))
	var direction=OptionButton.new();direction.custom_minimum_size.y=42;direction.add_item("Sorani Kurdish — English prompts");direction.add_item("English — Sorani prompts");direction.selected=0 if options.direction=="ckb" else 1
	direction.item_selected.connect(func(index):options.direction="ckb" if index==0 else "en";save_progress());v.add_child(direction)
	v.add_child(label("Pronunciation volume",16,Color("63827d")))
	var volume=HSlider.new();volume.min_value=0;volume.max_value=1;volume.step=0.05;volume.value=float(options.volume);volume.custom_minimum_size.y=30
	volume.value_changed.connect(func(value):options.volume=value;voice.volume_db=linear_to_db(value));v.add_child(volume)
	v.add_child(label("Podcast volume (0 = mute)",16,Color("63827d")))
	var podcast_volume=HSlider.new();podcast_volume.min_value=0;podcast_volume.max_value=1;podcast_volume.step=.01;podcast_volume.value=float(options.get("podcast_volume",.85));podcast_volume.custom_minimum_size.y=30
	podcast_volume.value_changed.connect(func(value):options.podcast_volume=value;save_progress());v.add_child(podcast_volume)
	v.add_child(label("Cozy music volume (0 = mute)",16,Color("63827d")))
	var music_volume=HSlider.new();music_volume.min_value=0;music_volume.max_value=1;music_volume.step=0.01;music_volume.value=float(options.music_volume);music_volume.custom_minimum_size.y=30
	music_volume.value_changed.connect(func(value):options.music_volume=value;save_progress());v.add_child(music_volume)
	v.add_child(label("Continuous piano & ambient playlist · fades under speech",13,Color("63827d")))
	v.add_child(label("Camera sensitivity",16,Color("63827d")))
	var sensitivity=HSlider.new();sensitivity.min_value=0.001;sensitivity.max_value=0.008;sensitivity.step=0.0005;sensitivity.value=player.sensitivity;sensitivity.custom_minimum_size.y=30
	sensitivity.value_changed.connect(func(value):options.sensitivity=value;player.sensitivity=value);v.add_child(sensitivity)
	var fullscreen=CheckButton.new();fullscreen.text="Fullscreen";fullscreen.button_pressed=bool(options.fullscreen)
	fullscreen.toggled.connect(func(value):options.fullscreen=value;DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if value else DisplayServer.WINDOW_MODE_WINDOWED));v.add_child(fullscreen)
	for setting in [["hud_size","On-screen controls size",.6,1.0],["map_size","Minimap size",.5,1.2],["subtitle_size","Subtitle size",.65,1.1]]:
		v.add_child(label(setting[1],16,Color("63827d")))
		var slider=HSlider.new();slider.min_value=setting[2];slider.max_value=setting[3];slider.step=.05;slider.value=float(options[setting[0]]);slider.custom_minimum_size=Vector2(550,24)
		var key:String=setting[0];slider.value_changed.connect(func(value):options[key]=value;apply_hud_size();save_progress());v.add_child(slider)
	var bilingual=CheckButton.new();bilingual.text="Show Sorani subtitle alongside English";bilingual.button_pressed=bool(options.sorani_subtitles);bilingual.toggled.connect(func(value):options.sorani_subtitles=value;save_progress());v.add_child(bilingual)
	v.add_child(button("Reset moved objects",reset_object_layout))
	v.add_child(button("Credits & language notes",show_credits))
	v.add_child(button("Done",func():save_progress();clear_screen() if session_started else show_title(),true))

func show_credits() -> void:
	overlay();var p=centered_panel(Vector2(850,640));var v=vbox(p,14)
	v.add_child(label("Made for your language journey",28))
	var text=label("KurdLingo — Alpha 0.8\nAn original game inspired by Earthlingo’s exploration and vocabulary gameplay. This project does not contain Earthlingo’s code, character, maps, music, or artwork.\n\n3D models: Kenney (CC0). Engine: Godot (MIT).\nFonts: Noto Sans and Noto Sans Arabic (SIL OFL).\nSorani voice: native-speaker F5-TTS audiobook model, Mohammadamini, Shamsi & Tahon (2026), CC BY-NC-ND 4.0; noncommercial use.\nEnglish voices: Piper LJ Speech and Lessac high. Music: The Cynic Project and Yoiyami (CC0).\n\nLanguage notes: Sorani entries are draft translations awaiting fluent-speaker review. Neural pronunciation is synthesized, not human-recorded. Some objects use simplified original models.\n\nAll 1,000 entries have English and Sorani audio. Your progress stays on this PC; the game works offline.",18,Color("56736e"));text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;text.custom_minimum_size.x=780;v.add_child(text)
	v.add_child(button("Back",func():clear_screen() if session_started else show_title(),true))

func show_map() -> void:
	overlay();var p=centered_panel(Vector2(1080,700));var v=vbox(p,14)
	var header=hbox(v);var title=label("Your world, one word at a time",28);title.size_flags_horizontal=Control.SIZE_EXPAND_FILL;header.add_child(title);header.add_child(button("Close",clear_screen))
	var body=hbox(v,24)
	var map=load("res://scripts/map.gd").new();map.game=self;map.large=true;map.custom_minimum_size=Vector2(670,540);body.add_child(map)
	var travel_scroll=ScrollContainer.new();travel_scroll.custom_minimum_size=Vector2(315,540);body.add_child(travel_scroll)
	var side=vbox(travel_scroll,8);side.custom_minimum_size.x=290
	side.add_child(label("FAST TRAVEL",12,Color("63827d")))
	side.add_child(button("Flag teacher · 17 stories",func():player.teleport(TeacherCircle.POSITION+Vector3(0,0,3));clear_screen();toast("Press E to choose a teacher story."),true))
	for region in REGION_CENTERS:
		var r=str(region)
		side.add_child(button(r+"  ·  "+str(region_discovered(r))+" / "+str(region_counts[r]),func():player.teleport(ARRIVALS[r]);clear_screen();toast("Welcome to "+r+".")))
	var note=label("White dot: you\nMint dots: discovered objects\nGold ring: your journal waypoint\n\nEvery district is open from the start.",15,Color("63827d"));note.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;side.add_child(note)

func show_journal() -> void:
	overlay();var p=centered_panel(Vector2(1070,750));var v=vbox(p,12)
	var top=hbox(v);var title=label("Field journal",30);title.size_flags_horizontal=Control.SIZE_EXPAND_FILL;top.add_child(title);top.add_child(label(str(learned.size())+" / 1000 discovered",17));top.add_child(button("Close",clear_screen))
	var filters=hbox(v)
	journal_search=LineEdit.new();journal_search.placeholder_text="Search English or Sorani…";journal_search.custom_minimum_size=Vector2(440,46);journal_search.add_theme_font_override("font",sorani_font);filters.add_child(journal_search)
	journal_search.text_changed.connect(func(_text):refresh_journal())
	var regions=OptionButton.new();regions.custom_minimum_size=Vector2(160,46);regions.add_item("All districts")
	var names=["All"]+REGION_CENTERS.keys()
	for name in names.slice(1):regions.add_item(name)
	regions.item_selected.connect(func(index):journal_region=names[index];refresh_journal());filters.add_child(regions)
	var only=CheckButton.new();only.text="Discovered only";only.toggled.connect(func(value):journal_only_learned=value;refresh_journal());filters.add_child(only)
	journal_region="All";journal_only_learned=false
	v.add_child(label("Find an object to discover it. Use Locate to mark its position on your map.",14,Color("63827d")))
	var scroll=ScrollContainer.new();scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;scroll.custom_minimum_size.y=540;v.add_child(scroll)
	list_box=VBoxContainer.new();list_box.size_flags_horizontal=Control.SIZE_EXPAND_FILL;list_box.add_theme_constant_override("separation",7);scroll.add_child(list_box)
	refresh_journal()

func refresh_journal() -> void:
	for child in list_box.get_children():list_box.remove_child(child);child.queue_free()
	var search=journal_search.text.strip_edges().to_lower()
	for row in vocabulary:
		if journal_region!="All" and row.region!=journal_region:continue
		if journal_only_learned and not learned.has(row.id):continue
		if search!="" and not search in str(row.en).to_lower() and not search in str(row.ckb):continue
		var id=str(row.id)
		var item=PanelContainer.new();item.add_theme_stylebox_override("panel",make_style(Color("e9e8db"),10));list_box.add_child(item)
		var h=hbox(item,14)
		var en=label(row.en,18);en.custom_minimum_size.x=190;h.add_child(en)
		var ckb=label(row.ckb,22,INK,true);ckb.custom_minimum_size.x=240;ckb.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT;h.add_child(ckb)
		var status=label(str(mini(int(learned[id].correct),5))+" / 5" if learned.has(id) else "Undiscovered",13,Color("64857c"));status.custom_minimum_size.x=110;h.add_child(status)
		h.add_child(button("Locate",func():waypoint_id=id;clear_screen();toast("Waypoint set: "+by_id[id].en)))
		if learned.has(id):h.add_child(button("Listen",func():play_word(id,str(options.direction))))

func start_quiz(region: String, fixed_id: String) -> void:
	var pool: Array=[]
	for id in learned:
		if region=="" or by_id[id].region==region:pool.append(id)
	if region!="" and region in defeated:toast("This guardian is already rebooted. Try Practice for more reviews.");return
	if region!="" and pool.size()<8:toast("Discover 8 words in "+region+" first. "+str(pool.size())+" / 8 found.");return
	if pool.is_empty():toast("Discover a few objects before you start practicing.");return
	quiz={"region":region,"pool":pool,"fixed":fixed_id,"correct":0,"wrong":0,"asked":0,"target":"","answered":false,"used":[]}
	overlay();var p=centered_panel(Vector2(790,610));var v=vbox(p,14)
	quiz_title=label("",17,Color("63827d"));v.add_child(quiz_title)
	quiz_prompt=label("",35);quiz_prompt.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;quiz_prompt.custom_minimum_size.y=65;v.add_child(quiz_prompt)
	var subtitle=label("Choose the matching word",16,Color("63827d"));subtitle.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;v.add_child(subtitle)
	answer_buttons=[]
	for index in range(4):
		var b=button("",func():answer_quiz(index));b.custom_minimum_size.y=61;v.add_child(b);answer_buttons.append(b)
	quiz_feedback=label("",17);quiz_feedback.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;quiz_feedback.custom_minimum_size.y=32;v.add_child(quiz_feedback)
	var bottom=hbox(v,12);bottom.add_child(button("Listen again",func():play_word(quiz.target,"en" if options.direction=="ckb" else "ckb")))
	quiz_next=button("Next",next_question,true);quiz_next.size_flags_horizontal=Control.SIZE_EXPAND_FILL;bottom.add_child(quiz_next);bottom.add_child(button("Leave",func():quiz={};clear_screen();save_progress()))
	next_question()

func next_question() -> void:
	if quiz.is_empty():return
	if quiz.region!="" and (int(quiz.correct)>=3 or int(quiz.wrong)>=3):finish_quiz();return
	if quiz.region=="" and int(quiz.asked)>=10:finish_quiz();return
	var pool: Array=quiz.pool.duplicate()
	pool.shuffle()
	# Due words and words with mistakes take priority, then recently unseen items.
	pool.sort_custom(func(a,b):return float(learned[a].due)+int(learned[a].correct)*60<int(learned[b].due)+int(learned[b].correct)*60)
	var id=str(pool[0])
	for candidate in pool:
		if not candidate in quiz.used:id=str(candidate);break
	if quiz.fixed!="" and quiz.asked==0:id=str(quiz.fixed)
	quiz.target=id;quiz.used.append(id);quiz.answered=false;quiz.asked+=1
	var target=by_id[id]
	var choices=[id]
	var distractors: Array=vocabulary.duplicate();distractors.shuffle()
	for row in distractors:
		if choices.size()==4:break
		if row.id!=id and row.region==target.region and row.ckb!=target.ckb:choices.append(row.id)
	for row in distractors:
		if choices.size()==4:break
		if not row.id in choices and row.ckb!=target.ckb:choices.append(row.id)
	choices.shuffle();quiz.choices=choices
	var question_language="en" if options.direction=="ckb" else "ckb"
	quiz_prompt.text=target[question_language];quiz_prompt.add_theme_font_override("font",sorani_font if question_language=="ckb" else english_font)
	for index in range(4):
		var b=answer_buttons[index];b.text=by_id[choices[index]][options.direction];b.disabled=false
		b.add_theme_font_override("font",sorani_font if options.direction=="ckb" else english_font)
		b.add_theme_font_size_override("font_size",25 if options.direction=="ckb" else 21)
		b.add_theme_stylebox_override("normal",make_style(Color("e9e5d7"),10))
	quiz_feedback.text="";quiz_next.disabled=true
	quiz_title.text=(quiz.region+" guardian  ·  "+str(quiz.correct)+" / 3 correct  ·  "+str(3-int(quiz.wrong))+" hearts") if quiz.region!="" else "MEMORY PRACTICE  ·  "+str(quiz.asked)+" / 10"
	play_word(id,question_language)

func apply_review(id: String, correct: bool) -> void:
	var stats=learned[id]
	if correct:
		stats.correct=int(stats.correct)+1
		stats.due=int(Time.get_unix_time_from_system())+int(pow(2,mini(int(stats.correct),5))*60)
		xp+=15
	else:
		stats.wrong=int(stats.wrong)+1;stats.due=0
	learned[id]=stats

func answer_quiz(index: int) -> void:
	if quiz.is_empty() or bool(quiz.answered):return
	quiz.answered=true
	var chosen=str(quiz.choices[index]);var id=str(quiz.target);var correct=chosen==id
	apply_review(id,correct)
	if correct:quiz.correct+=1;quiz_feedback.text="Correct!  +15 XP";chime(true)
	else:quiz.wrong+=1;quiz_feedback.text="Keep practicing: "+by_id[id].en+" = "+by_id[id].ckb;chime(false)
	quiz_feedback.add_theme_font_override("font",sorani_font)
	for i in range(4):
		answer_buttons[i].disabled=true
		var color=TEAL if quiz.choices[i]==id else Color("ecd0c1") if i==index and not correct else Color("e9e5d7")
		answer_buttons[i].add_theme_stylebox_override("disabled",make_style(color,10))
		answer_buttons[i].add_theme_color_override("font_disabled_color",INK)
	quiz_next.disabled=false;play_word(id,str(options.direction));save_progress()

func finish_quiz() -> void:
	var success=quiz.region!="" and int(quiz.correct)>=3
	var region=str(quiz.region);var correct=int(quiz.correct);var wrong=int(quiz.wrong)
	if success:
		defeated.append(region);xp+=100
		rescue_cells[region].visible=false
		var robot=guardians[region];robot.scale=Vector3.ONE*0.75
		for child in robot.get_children():
			if child is Label3D:child.text="REBOOTED";child.modulate=TEAL
	quiz={};save_progress();overlay()
	var p=centered_panel(Vector2(620,370));var v=vbox(p,18)
	v.add_child(label("Guardian rebooted!" if success else "Practice complete" if region=="" else "Try again soon",32))
	var description=label("You freed your "+region+" neighbor! "+str(defeated.size())+" / 20 rescued. +100 XP" if success else str(correct)+" correct answers  ·  "+str(wrong)+" to review",21);description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;description.custom_minimum_size.x=550;v.add_child(description)
	v.add_child(label("Explore, listen, and come back for another review.",17,Color("63827d")))
	v.add_child(button("Back to the world",clear_screen,true))

func chime(correct: bool) -> void:
	var stream=AudioStreamWAV.new();stream.format=AudioStreamWAV.FORMAT_16_BITS;stream.mix_rate=22050
	var data=PackedByteArray();var duration=0.24 if correct else 0.17
	for i in range(int(22050*duration)):
		var t=float(i)/22050;var frequency=660.0 if correct else 220.0
		var value=int(sin(t*TAU*frequency)*7000*(1-t/duration))
		data.append(value & 255);data.append((value >> 8) & 255)
	stream.data=data;sound.stream=stream;sound.volume_db=linear_to_db(float(options.volume)*0.45);sound.play()

func save_progress() -> void:
	if test_mode and save_path=="user://progress.json":return
	var state={"version":3,"story_state":story.state if story!=null else {},"object_layout":object_layout,"learned":learned,"defeated":defeated,"xp":xp,"options":options}
	state["podcasts_completed"]=podcasts.completed if podcasts!=null else {}
	ProgressStore.write(save_path, state)

func load_progress() -> void:
	var state = ProgressStore.read(save_path)
	if state.is_empty(): return
	if state.get("learned") is Dictionary:
		for id in state.learned:
			if by_id.has(id) and state.learned[id] is Dictionary:learned[id]=state.learned[id]
	if state.get("defeated") is Array:
		defeated=state.defeated.filter(func(region):return REGION_CENTERS.has(region))
	if story!=null and state.get("story_state") is Dictionary:
		story.state.merge(state.story_state,true)
		story.state.step=clampi(int(story.state.step),0,2)
	if state.get("object_layout") is Dictionary:object_layout=state.object_layout
	xp=int(state.get("xp",0))
	if state.get("options") is Dictionary:options.merge(state.options,true)
	if podcasts!=null and state.get("podcasts_completed") is Dictionary:podcasts.completed=state.podcasts_completed

func verify_test(condition:bool,message:String="Check failed")->void:
	if not condition:
		self_test_failed=true;push_error("SELF TEST FAILURE: "+message);get_tree().quit(1)

func self_test() -> void:
	await get_tree().process_frame
	verify_test(has_node("KurdistanFlag"),"Large Kurdish flag must exist")
	verify_test(handling!=null and player.arm!=null and player.left_arm!=null,"Both gesture arms must exist")
	var apple_original: Transform3D=object_nodes.apple.transform
	handling.start("apple");verify_test(player.carrying,"Pickup must start the carrying pose");verify_test(handling.body_for("apple").collision_layer==0,"Held object must not collide with player")
	handling.candidate=Vector3(5,.13,15);handling.valid_drop=true;handling.drop()
	verify_test(not player.carrying,"Drop must end the carrying pose")
	verify_test(object_layout.has("apple") and object_nodes.apple.position.is_equal_approx(Vector3(5,.13,15)),"Drop must place and save object")
	handling.start("apple");object_nodes.apple.position=Vector3(7,4,14);handling.valid_drop=false;handling.drop()
	verify_test(object_nodes.apple.position.is_equal_approx(Vector3(5,.13,15)),"Invalid drop must restore last placement")
	handling.start("apple");object_nodes.apple.position=Vector3(3,4,14);handling.cancel()
	verify_test(object_nodes.apple.position.is_equal_approx(Vector3(5,.13,15)) and handling.body_for("apple").collision_layer==3,"Cancel must restore collision and transform")
	save_progress();object_layout={};load_progress();verify_test(object_layout.has("apple"),"Object arrangement must persist")
	object_nodes.apple.transform=apple_original;object_layout={};learned={};defeated=[];xp=0
	verify_test(vocabulary.size()==1000,"Expected 1000 vocabulary entries")
	verify_test(by_id.size()==1000 and object_nodes.size()==1000,"Every unique word must have a 3D object")
	verify_test(guardians.size()==20,"Every district must have a guardian")
	verify_test(rescue_cells.size()==20)
	for id in object_nodes:
		var obj=object_nodes[id]
		verify_test(obj.get_meta("dimensions").length()>0.01,"Object has no visible geometry: "+id)
		verify_test(absf(obj.position.x)<580 and absf(obj.position.z)<500,"Object outside player bounds: "+id)
	for track in MUSIC_TRACKS:verify_test(ResourceLoader.exists(track),"Missing music track")
	verify_test(float(options.music_volume)==0.35)
	options.music_volume=0.61
	for row in vocabulary:
		verify_test(not str(row.en).is_empty() and not str(row.ckb).is_empty())
		for language in ["en","ckb"]:verify_test(ResourceLoader.exists("res://assets/audio/"+language+"/"+row.id+".wav"),"Missing audio "+row.id)
	music_gain=0.61;play_word("apple","ckb");_process(0.2)
	verify_test(music_gain<0.61,"Music must duck while a word is playing")
	options.music_volume=0.0;_process(0.2);verify_test(music.stream_paused,"Zero music volume must mute music")
	options.music_volume=0.61;_process(0.2);verify_test(not music.stream_paused,"Music must resume after unmuting")
	verify_test(discover("apple"));verify_test(not discover("apple"),"Duplicate discoveries must not award XP")
	verify_test(xp==10);apply_review("apple",true);verify_test(xp==25 and learned.apple.correct==1)
	apply_review("apple",false);verify_test(learned.apple.wrong==1 and learned.apple.due==0)
	for row in vocabulary:
		if row.region=="Market":discover(row.id)
	session_started=true;start_quiz("Market","")
	for round_index in range(3):
		verify_test(quiz.choices.size()==4)
		var unique={}
		for choice in quiz.choices:unique[by_id[choice].ckb]=true
		verify_test(unique.size()==4,"Quiz choices must have distinct translations")
		answer_quiz(quiz.choices.find(quiz.target));await get_tree().create_timer(0.08).timeout;next_question();await get_tree().create_timer(0.08).timeout
	verify_test("Market" in defeated,"Three correct answers must reboot guardian")
	verify_test(not rescue_cells.Market.visible,"Reboot must release neighbor")
	save_progress();var expected_xp=xp;learned={};defeated=[];xp=0;load_progress()
	verify_test(is_equal_approx(float(options.music_volume),0.61),"Music volume must persist")
	verify_test(xp==expected_xp and "Market" in defeated and learned.has("apple"),"Save/load roundtrip")
	options.direction="en";start_quiz("","");verify_test(quiz.choices.size()==4)
	answer_quiz((quiz.choices.find(quiz.target)+1)%4);verify_test(quiz.wrong==1,"Wrong English answer must be counted")
	quiz={};clear_screen()
	verify_test(story.chapters.size()==10)
	var sentence_ids={}
	for chapter in story.chapters:
		verify_test(by_id.has(chapter.target) and by_id[chapter.target].region==chapter.region)
		verify_test(chapter.steps.size()==3)
		for sentence in chapter.steps:
			verify_test(not sentence_ids.has(sentence.id));sentence_ids[sentence.id]=true
			verify_test(ResourceLoader.exists("res://assets/audio/story/"+sentence.id+".wav"))
	verify_test(sentence_ids.size()==30)
	story.state={"active":"","step":0,"completed":[]};var story_xp=xp
	story.start("market");story.question()
	story.answer(false,story.active_chapter().steps[0],[],story.feedback.get_parent())
	verify_test(story.state.step==0 and xp==story_xp,"Wrong sentences must allow retry without rewards")
	for i in range(3):
		story.question();story.answer(true,story.active_chapter().steps[i],[],story.feedback.get_parent())
	verify_test("market" in story.state.completed and story.state.active=="" and xp==story_xp+90)
	story.start("market");story.question();story.answer(true,story.active_chapter().steps[0],[],story.feedback.get_parent())
	verify_test(xp==story_xp+90,"Replay must not duplicate rewards")
	save_progress();story.state={"active":"","step":0,"completed":[]};load_progress()
	verify_test(story.state.active=="market" and story.state.step==1 and "market" in story.state.completed,"Story checkpoint must persist")
	clear_screen()
	verify_test(teacher_circle.tales.size()==17 and teacher_circle.pupils.size()==20 and teacher_circle.seats.size()==3 and walk_seats.size()>=40)
	for i in range(teacher_circle.pupils.size()):
		var pupil:Node3D=teacher_circle.pupils[i];var chair:Node3D=teacher_circle.pupil_chairs[i]
		var target=(TeacherCircle.POSITION-pupil.position).normalized()
		verify_test((-pupil.basis.z).normalized().dot(target)>.99,"Children must face the teacher")
		verify_test(is_equal_approx(pupil.rotation.y,chair.rotation.y),"Chair and child facing must match")
	var tale_ids={}
	for tale in teacher_circle.tales:
		verify_test(tale.segments.size()==8)
		for segment in tale.segments:
			verify_test(not tale_ids.has(segment.id));tale_ids[segment.id]=true
			verify_test(not str(segment.en).is_empty() and not str(segment.ckb).is_empty())
			for language in ["ckb","en"]:verify_test(ResourceLoader.exists("res://assets/audio/teacher/"+language+"/"+segment.id+".wav"))
	teacher_circle.language="ckb";teacher_circle.play("newroz")
	verify_test(teacher_circle.listening and teacher_circle.narrator.playing and teacher_circle.english_subtitle.text==teacher_circle.active.segments[0].en)
	teacher_circle.toggle_pause();verify_test(teacher_circle.paused and teacher_circle.narrator.stream_paused)
	teacher_circle.toggle_pause();verify_test(not teacher_circle.paused and not teacher_circle.narrator.stream_paused)
	player.teleport(teacher_circle.seats[0]);teacher_circle.interact()
	verify_test(player.seated and teacher_circle.listening,"Sitting must keep the story playing")
	var sitting_position=player.position;await get_tree().create_timer(.08).timeout
	verify_test(player.position.is_equal_approx(sitting_position),"Seated character must stay in the chair")
	teacher_circle.stand();verify_test(not player.seated and teacher_circle.narrator.playing)
	player.teleport(Vector3(150,0,50));verify_test(teacher_circle.listening and teacher_circle.narrator.playing,"Walking away must keep narration")
	teacher_circle.next_segment();verify_test(teacher_circle.segment_index==1 and teacher_circle.english_subtitle.text==teacher_circle.active.segments[1].en)
	teacher_circle.language="en";teacher_circle.play("citadel");verify_test(teacher_circle.narrated_language=="en")
	verify_test("/en/" in teacher_circle.narrator.stream.resource_path)
	for i in range(8):teacher_circle.next_segment()
	verify_test(teacher_circle.active.is_empty() and not teacher_circle.listening and not teacher_circle.subtitle_panel.visible,"Completed narration must clear the caption")
	options.hud_size=.65;options.map_size=.6;options.subtitle_size=.75;options.sorani_subtitles=true
	save_progress();options.hud_size=1.0;load_progress()
	verify_test(is_equal_approx(float(options.hud_size),.65) and options.sorani_subtitles,"Display preferences must persist")
	teacher_circle.stop();verify_test(not teacher_circle.listening and not teacher_circle.narrator.playing)
	verify_test(Explorer.MAX_FUEL/Explorer.FUEL_DRAIN>=37,"Jetpack must provide more flight time")
	clear_screen()
	verify_test(WorldEditorLayout.flower_instances(self)>1500,"The expanded world must contain small flower borders")
	for district in ExpansionWorld.DISTRICTS:
		verify_test(region_counts[district]==50,"New districts must contain exactly 50 entries")
		var origin:Vector3=ARRIVALS[district]
		var ray=PhysicsRayQueryParameters3D.create(origin+Vector3(0,3,0),origin-Vector3(0,3,0),1,[player.get_rid()])
		verify_test(not get_world_3d().direct_space_state.intersect_ray(ray).is_empty(),"Arrival must have walkable ground")
		for row in vocabulary:
			if row.region==district:discover(row.id)
		start_quiz(district,"")
		for round_index in range(3):
			verify_test(quiz.choices.size()==4 and by_id[quiz.target].region==district)
			answer_quiz(quiz.choices.find(quiz.target));next_question()
		verify_test(district in defeated and not rescue_cells[district].visible,"New guardian must release its neighbor")
		clear_screen()
	for entry in walk_seats:
		var dims:Vector3=entry.node.get_meta("dimensions",Vector3(1,1.34,1))
		verify_test(dims.y<1.4,"Walking seats must stay smaller than the player")
	var named_bench:Node3D=object_nodes.bench
	verify_test(named_bench.get_meta("dimensions").x<=1.71)
	player.teleport(named_bench.global_position);teacher_circle.interact()
	verify_test(player.seated,"Named bench must support sitting")
	teacher_circle.stand()
	var empty_chair=walk_seats[0].node
	player.teleport(empty_chair.global_position);teacher_circle.stop();teacher_circle.interact()
	verify_test(player.seated and screen==null,"Ordinary chairs must seat the player without opening the story menu")
	verify_test(is_equal_approx(player.visual.rotation.y,empty_chair.rotation.y),"Player must face the chair's front")
	await get_tree().create_timer(.1).timeout
	verify_test(player.position.is_equal_approx(empty_chair.global_position+Vector3(0,.42,0)),"Seated pose must stay on its seat")
	teacher_circle.interact();verify_test(not player.seated,"E must stand from an ordinary chair")
	save_progress();learned={};defeated=[];load_progress()
	verify_test(learned.has("daily_passport") and "Tourist Quarter" in defeated,"New vocabulary and guardians must save alongside earlier progress")
	clear_screen()
	for audio_player in [music,voice,sound]:
		audio_player.stop();audio_player.stream=null
	await get_tree().create_timer(0.5).timeout
	await get_tree().process_frame
	await get_tree().process_frame
	var daily_checks_passed=await test_daily_features()
	if not daily_checks_passed:
		get_tree().quit(1);return
	print("SELF TEST PASS: 1000 objects/2000 word recordings, 20 districts, drag/drop/reset, progress, quizzes, guardians, story missions, teacher/20 pupils/17 stories/272 clips, jetpack; scooter movement/dismount; 10 long podcasts/280 recordings/captions/pause/replay/sofa/walk/teacher exclusivity.")
	get_tree().quit()

func test_daily_features()->bool:
	verify_test(podcasts.episodes.size()==10 and podcasts.booths.size()==10 and podcasts.voices.size()==20)
	for episode in podcasts.episodes:
		verify_test(episode.segments.size()==28 and float(episode.duration)>360,"Podcast must be a long conversation")
		for segment in episode.segments:
			verify_test(ResourceLoader.exists("res://assets/audio/podcasts/"+segment.id+".wav"),"Podcast recording missing: "+segment.id)
			verify_test(not segment.ckb.is_empty() and segment.captions.size()>0,"Sorani captions missing")
	begin_game();player.teleport(podcasts.booths[0].seat)
	for frame in range(50):await get_tree().physics_frame
	podcasts.completed={};test_mode=false;podcasts._process(.5);test_mode=true
	verify_test(podcasts.playing and podcasts.booth_index==0,"Approaching a studio must start its episode")
	verify_test(podcasts.interact() and player.seated and podcasts.listener_seated and podcasts.playing,"Sofa must seat the listener and play")
	podcasts.toggle_pause();verify_test(podcasts.paused and podcasts.narrator.stream_paused)
	podcasts.toggle_pause();verify_test(not podcasts.paused)
	podcasts.stand();verify_test(not player.seated and podcasts.playing,"Standing must preserve listening")
	player.position+=Vector3(0,0,10);podcasts._process(.02);verify_test(podcasts.playing,"Walking around must preserve playback")
	var original_podcast_volume=options.podcast_volume;options.podcast_volume=0;podcasts._process(.02);verify_test(podcasts.narrator.volume_db<=-90,"Podcast mute must silence audio");options.podcast_volume=original_podcast_volume
	podcasts.next_segment();verify_test(podcasts.segment_index==1)
	podcasts.segment_index=27;podcasts.next_segment();verify_test(not podcasts.playing and podcasts.completed.has(podcasts.episodes[0].id))
	podcasts.play_segment();verify_test(podcasts.playing and podcasts.segment_index==27,"Replay after completion must be safe")
	teacher_circle.play("newroz");verify_test(not podcasts.playing,"Teacher and podcast must not overlap");teacher_circle.stop()
	player.teleport(Vector3(300,0,270));clear_screen()
	for frame in range(50):await get_tree().physics_frame
	verify_test(player.toggle_ride() and player.riding,"Scooter must mount on the ground")
	var key=InputEventKey.new();key.keycode=KEY_W;key.physical_keycode=KEY_W;key.pressed=true;Input.parse_input_event(key)
	for frame in range(50):await get_tree().physics_frame
	verify_test(Vector2(player.velocity.x,player.velocity.z).length()>20,"Scooter must travel faster than running")
	var boost=InputEventKey.new();boost.keycode=KEY_SHIFT;boost.physical_keycode=KEY_SHIFT;boost.pressed=true;Input.parse_input_event(boost)
	for frame in range(25):await get_tree().physics_frame
	verify_test(Vector2(player.velocity.x,player.velocity.z).length()>30,"Scooter boost must increase speed")
	boost.pressed=false;Input.parse_input_event(boost);key.pressed=false;Input.parse_input_event(key);verify_test(player.toggle_ride() and not player.riding,"Scooter must dismount")
	podcasts.stop();player.velocity=Vector3.ZERO
	return not self_test_failed

func capture_view(path: String) -> void:
	await get_tree().process_frame
	if "credits" in path:
		show_credits()
	elif "settings" in path:
		show_settings()
	elif "word" in path:
		begin_game();player.teleport(Vector3(-12,0,-38.5));player.yaw=-0.1;player.pitch=0.38;player.distance=8
		inspect_word("apple")
	elif "models" in path:
		begin_game();player.teleport(Vector3(-2,0,9));player.pitch=.5;player.distance=14
		var sample_ids=["scissors","bucket","telephone","barn","microscope","sandal","trumpet","pliers","toothpaste","rice","globe","butterfly"]
		for i in range(sample_ids.size()):
			var model=WorldProps.make(by_id[sample_ids[i]].model,1.7);model.position=Vector3(-8+(i%4)*4,0,-4-int(i/4)*5);add_child(model)
			var text=Label3D.new();text.text=by_id[sample_ids[i]].en;text.font=english_font;text.position=model.position+Vector3(0,2.2,0);text.font_size=26;text.pixel_size=.008;text.billboard=BaseMaterial3D.BILLBOARD_ENABLED;add_child(text)
	elif "bench-fix" in path:
		begin_game();var bench=object_nodes.bench;player.teleport(bench.global_position+Vector3(0,0,2));player.yaw=.3;player.pitch=.27;player.distance=5
	elif "walk-seat" in path:
		begin_game();var entry=walk_seats[0];player.teleport(entry.node.global_position);teacher_circle.interact();player.yaw=.4;player.pitch=.25;player.distance=6
	elif "podcast-seat" in path:
		begin_game();player.teleport(podcasts.booths[2].seat);podcasts.interact();player.yaw=.2;player.pitch=.27;player.distance=6
	elif "podcast" in path:
		begin_game();player.teleport(podcasts.booths[2].position+Vector3(0,0,6));podcasts.play(2);player.yaw=.15;player.pitch=.3;player.distance=8
	elif "scooter" in path:
		begin_game();player.teleport(Vector3(1,0,15));player.yaw=PI+.3;player.pitch=.26;player.distance=6
		for frame in range(60):await get_tree().physics_frame
		player.toggle_ride()
	elif "expansion-" in path:
		begin_game();var region="Tourist Quarter"
		for item in ExpansionWorld.DISTRICTS:
			if item.to_lower().replace(" ","-") in path:region=item
		player.teleport(REGION_CENTERS[region]+Vector3(36,0,16));player.yaw=-.8;player.pitch=.3;player.distance=8
	elif "teacher-seat" in path:
		begin_game();teacher_circle.play("newroz");player.teleport(teacher_circle.seats[0]);teacher_circle.interact();player.yaw=.1;player.pitch=.25;player.distance=8
	elif "teacher-menu" in path:
		begin_game();teacher_circle.menu()
	elif "teacher" in path:
		begin_game();player.teleport(Vector3(5,0,18));player.yaw=0.25;player.pitch=.25;player.distance=10
		teacher_circle.play("newroz")
	elif "sentence" in path:
		begin_game();story.state.active="market";story.state.step=0;story.question()
	elif "story" in path:
		begin_game();story.menu()
	elif "animal" in path:
		begin_game();var animal: Node3D=object_nodes.giraffe;player.teleport(animal.position+Vector3(0,0,6));player.pitch=.26;player.distance=9
	elif "gesture" in path:
		begin_game();player.teleport(Vector3(-10,0,-37));player.yaw=.2;player.pitch=.25;player.distance=7
		await get_tree().physics_frame
		await get_tree().physics_frame
		var obj: Node3D=object_nodes.apple
		var mouse=player.camera.unproject_position(obj.global_position+Vector3.UP*.2)
		var press=InputEventMouseButton.new();press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=mouse;Input.parse_input_event(press)
		handling.start("apple")
		handling.preview_hold=true
		var motion=InputEventMouseMotion.new();motion.position=player.camera.unproject_position(Vector3(-7,0,-35));motion.relative=Vector2(20,10);motion.button_mask=MOUSE_BUTTON_MASK_LEFT;Input.parse_input_event(motion)
	elif "street" in path:
		begin_game();player.teleport(Vector3(-28,0,78));player.yaw=PI;player.pitch=.4;player.distance=12
	elif "flag" in path:
		begin_game();player.teleport(Vector3(0,0,25));player.pitch=.1;player.distance=15
	elif "kitchen" in path:
		begin_game();player.teleport(Vector3(180,0,-94));player.pitch=.4;player.distance=12
	elif "workshop" in path:
		begin_game();player.teleport(Vector3(-180,0,-94));player.pitch=.4;player.distance=12
	elif "lifestyle" in path:
		begin_game();player.teleport(Vector3(0,0,145));player.pitch=.4;player.distance=12
	elif "wildlife" in path:
		begin_game();player.teleport(Vector3(-184,0,40));player.yaw=0.15;player.pitch=0.40;player.distance=11
	elif "discovery" in path:
		begin_game();player.teleport(Vector3(155,0,57));player.yaw=0.3;player.pitch=0.4;player.distance=10
	elif "home" in path:
		begin_game();player.teleport(Vector3(36,0,-39));player.yaw=0.4;player.pitch=0.45;player.distance=11
	elif "map" in path:begin_game();show_map()
	elif "journal" in path:begin_game();show_journal()
	elif "quiz" in path:
		begin_game()
		for row in vocabulary:
			if row.region=="Market":discover(row.id)
		start_quiz("Market","")
	for frame in range(12):await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
	print("Captured "+path)
	get_tree().quit()

func next_music() -> void:
	music.stream=load(MUSIC_TRACKS[music_index%MUSIC_TRACKS.size()])
	music_index+=1
	music.play()

func _exit_tree() -> void:
	for audio_player in [music,voice,sound]:
		if is_instance_valid(audio_player):
			audio_player.stop()
			audio_player.stream=null

func benchmark() -> void:
	begin_game()
	for region in ["Town","Tourist Quarter","History Museum","Work Hub","Podcast Plaza","City Services"]:
		player.teleport(ARRIVALS[region]+Vector3(0,0,18));player.distance=11;player.pitch=0.4
		for frame in range(120):await get_tree().process_frame
		print("BENCHMARK ",region," fps=",Performance.get_monitor(Performance.TIME_FPS)," objects=",object_nodes.size()," draw_calls=",Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)," video_memory_mb=",Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)/1048576.0)
	get_tree().quit()

func flag_voice(id: String) -> void:
	var report_path=save_path.get_base_dir().path_join("pronunciation-reports.json")
	var reports={}
	if FileAccess.file_exists(report_path):
		var previous=JSON.parse_string(FileAccess.get_file_as_string(report_path))
		if previous is Dictionary:reports=previous
	reports[id]={"english":by_id[id].en,"sorani":by_id[id].ckb,"reported":int(Time.get_unix_time_from_system())}
	var file=FileAccess.open(report_path,FileAccess.WRITE)
	if file!=null:
		file.store_string(JSON.stringify(reports,"  "));file.close();toast("Marked "+by_id[id].ckb+" for pronunciation review. Saved on this PC.")

func reset_object_layout() -> void:
	if handling!=null:handling.cancel()
	for id in original_layout:object_nodes[id].transform=original_layout[id]
	object_layout={};save_progress();toast("Moved objects restored. Your learned words are unchanged.")

func build_connected_roads() -> void:
	# An outer ring joins both town boulevards, district approaches, and the south greenway.
	var asphalt=Color("657c80")
	for side in [-1,1]:
		solid_box(Vector3(side*128,.045,5),Vector3(8,.09,238),asphalt,true)
		for z in range(-112,124,8):solid_box(Vector3(side*128,.108,z),Vector3(.13,.018,2.5),CREAM,false)
	for z in [-118,128]:
		solid_box(Vector3(0,.045,z),Vector3(248,.09,8),asphalt,true)
		for x in range(-116,124,8):solid_box(Vector3(x,.108,z),Vector3(2.5,.018,.13),CREAM,false)
	for x in [-28,15]:
		for span in [Vector2(-114,-106),Vector2(106,124)]:solid_box(Vector3(x,.04,(span.x+span.y)*.5),Vector3(10,.08,span.y-span.x),asphalt,true)
	# Every ring corner and both boulevard junctions have a continuous paved surface.
	for side in [-1,1]:
		for z in [-118,128]:solid_box(Vector3(side*128,.045,z),Vector3(8,.09,8),asphalt,true)
	# Driveways leave the ring for the four outer sections, ending before the exhibits.
	for side in [-1,1]:
		for z in [-108,22]:
			solid_box(Vector3(side*155,.045,z),Vector3(46,.09,6),asphalt,true)
			for x in range(136,176,8):solid_box(Vector3(side*x,.108,z),Vector3(2.5,.018,.13),CREAM,false)
	# Lifestyle arrival joins the south road through a short driveway.
	solid_box(Vector3(0,.045,133.5),Vector3(8,.09,3),asphalt,true)
	for x in [-28,15]:
		for i in range(6):solid_box(Vector3(x-3+i*1.1,.12,122),Vector3(.55,.018,2),CREAM,false)



func apply_hud_size()->void:
	for widget in hud_widgets:
		var factor=float(options.hud_size)*(float(options.map_size) if widget==minimap_widget else 1.0)
		widget.pivot_offset=Vector2(widget.size.x if widget.anchor_left==1 else widget.size.x*.5 if widget.anchor_left==.5 else 0,widget.size.y if widget.anchor_top==1 else 0)
		widget.scale=Vector2.ONE*factor
