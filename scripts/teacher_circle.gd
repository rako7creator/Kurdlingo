class_name TeacherCircle
extends Node3D

var world: Node3D
var tales: Array=[]
var teacher: Node3D
var pupils: Array=[]
var seats: Array[Vector3]=[]
var pupil_chairs: Array[Node3D]=[]
var listening_chairs: Array[Node3D]=[]
var narrator: AudioStreamPlayer
var subtitle_panel: PanelContainer
var english_subtitle: Label
var sorani_subtitle: Label
var status: Label
var pause_button: Button
var active: Dictionary={}
var language="ckb"
var narrated_language="ckb"
var segment_index=0
var listening=false
var paused=false
var gesture_time=0.0
var book: Node3D
const POSITION=Vector3(-5,0,1)

func _ready() -> void:
	tales=JSON.parse_string(FileAccess.get_file_as_string("res://data/teacher_stories.json"))
	narrator=AudioStreamPlayer.new();add_child(narrator);narrator.finished.connect(next_segment)
	build_circle();build_subtitles()

static func person(child: bool,index: int=0) -> Node3D:
	var n=Node3D.new();var skin=[Color("cfa581"),Color("b68564"),Color("e2bd98")][index%3]
	var cloth=[Color("749bab"),Color("c88470"),Color("ad99bb"),Color("a8b775"),Color("e1b365")][index%5]
	var dark=Color("344451");var y=.72 if child else 1.08
	WorldProps.sphere(n,Vector3(0,y+.61,0),Vector3(.47,.55,.44),skin)
	WorldProps.sphere(n,Vector3(0,y+.82,.025),Vector3(.49,.24,.46),Color("554337"))
	if not child:
		WorldProps.sphere(n,Vector3(0,y+.57,.19),Vector3(.52,.6,.26),Color("554337"))
	WorldProps.box(n,Vector3(0,y,0),Vector3(.54,.65,.32),cloth)
	WorldProps.box(n,Vector3(0,y+.27,-.18),Vector3(.25,.08,.03),Color("e6d8bf"))
	for side in [-1,1]:
		WorldProps.sphere(n,Vector3(side*.095,y+.65,-.216),Vector3(.05,.045,.02),dark)
		WorldProps.sphere(n,Vector3(side*.31,y-.04,-.13),Vector3(.17,.52,.18),cloth)
		WorldProps.sphere(n,Vector3(side*.31,y-.3,-.18),Vector3(.14,.14,.14),skin)
		if child:
			WorldProps.line(n,Vector3(side*.16,.49,0),Vector3(side*.16,.49,-.38),.09,dark)
			WorldProps.line(n,Vector3(side*.16,.49,-.38),Vector3(side*.16,.06,-.38),.07,dark)
		else:WorldProps.box(n,Vector3(side*.15,.43,0),Vector3(.21,.75,.23),dark)
		WorldProps.sphere(n,Vector3(side*.16,.07,-.38 if child else -.09),Vector3(.22,.13,.37),dark)
	WorldProps.line(n,Vector3(-.075,y+.49,-.22),Vector3(.075,y+.49,-.22),.012,Color("985949"))
	if child:n.scale=Vector3.ONE*.86
	return n

func build_circle() -> void:
	world.solid_box(Vector3(-5,.018,14),Vector3(19,.025,22),Color("d8c9a9"),false)
	for i in range(4):
		world.solid_box(Vector3(-5,.035,7+i*4.5),Vector3(16,.008,.12),Color("b9a27d"),false)
	teacher=person(false);teacher.position=POSITION;teacher.rotation.y=PI;add_child(teacher)
	book=Node3D.new();book.position=Vector3(0,1.05,-.4);book.rotation.x=-.35;teacher.add_child(book)
	for side in [-1,1]:
		var cover=WorldProps.box(book,Vector3(side*.18,0,0),Vector3(.36,.055,.46),Color("8c5e48"));cover.rotation.z=side*.14
		var page=WorldProps.box(book,Vector3(side*.17,.043,0),Vector3(.32,.025,.41),Color("f3ead2"));page.rotation.z=side*.14
		for i in range(5):WorldProps.box(book,Vector3(side*.17,.061,-.13+i*.055),Vector3(.25,.003,.007),Color("9a8b70"))
		WorldProps.line(teacher,Vector3(side*.3,1.08,-.04),Vector3(side*.31,1.06,-.44),.085,Color("cfa581"))
	world.signpost("THE STORY CIRCLE · PRESS E",Vector3(-13,0,2),Color("d6bc84"))
	for row in range(4):
		for col in range(5):
			var p=Vector3(-11+col*3,0,9+row*3.6)
			var facing=seat_yaw(p)
			var chair=classroom_chair(false);chair.position=p;chair.rotation.y=facing;add_child(chair);pupil_chairs.append(chair)
			var pupil=person(true,row*5+col);pupil.position=p+Vector3(0,.04,0);pupil.rotation.y=facing;add_child(pupil);pupils.append(pupil)
	for z in [11,16,21]:
		var p=Vector3(5,0,z);seats.append(p)
		var chair=classroom_chair(true);chair.position=p;chair.rotation.y=seat_yaw(p);add_child(chair);listening_chairs.append(chair)
	# Move the original named bench out of the children's rows.
	if world.object_nodes.has("bench"):world.object_nodes.bench.position=Vector3(-11,0,25);world.original_layout.bench=world.object_nodes.bench.transform

func build_subtitles() -> void:
	subtitle_panel=PanelContainer.new();world.ui.add_child(subtitle_panel)
	subtitle_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	subtitle_panel.anchor_left=.27;subtitle_panel.anchor_right=.73
	subtitle_panel.offset_left=0;subtitle_panel.offset_right=0;subtitle_panel.offset_top=-210;subtitle_panel.offset_bottom=-88
	subtitle_panel.add_theme_stylebox_override("panel",world.make_style(Color("244b53dd"),12))
	var v=world.vbox(subtitle_panel,7);status=world.label("",14,world.TEAL);v.add_child(status)
	english_subtitle=world.label("",18,world.CREAM);english_subtitle.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;v.add_child(english_subtitle)
	sorani_subtitle=world.label("",16,world.CREAM,true);sorani_subtitle.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;v.add_child(sorani_subtitle)
	var controls=HBoxContainer.new();v.add_child(controls)
	pause_button=world.button("Ⅱ",toggle_pause);pause_button.tooltip_text="Pause / resume narration";pause_button.custom_minimum_size.y=32;compact(pause_button);controls.add_child(pause_button)
	for entry in [["≡",menu],["■",stop],["↑",stand]]:
		var b=world.button(entry[0],entry[1]);b.custom_minimum_size.y=32;compact(b);b.tooltip_text="Stories" if entry[0]=="≡" else "Stop narration" if entry[0]=="■" else "Stand up";controls.add_child(b)
	subtitle_panel.hide()

func _process(delta: float) -> void:
	subtitle_panel.visible=not active.is_empty() and world.screen==null
	if world.hud_widgets.size()>4:world.hud_widgets[4].visible=active.is_empty()
	sorani_subtitle.visible=bool(world.options.sorani_subtitles)
	var factor=float(world.options.subtitle_size);subtitle_panel.pivot_offset=Vector2(subtitle_panel.size.x*.5,subtitle_panel.size.y);subtitle_panel.scale=Vector2.ONE*factor
	gesture_time+=delta
	teacher.rotation.y=PI+sin(gesture_time*.35)*.07
	book.rotation.x=-.35+sin(gesture_time*1.4)*.025
	for i in range(pupils.size()):pupils[i].rotation.x=sin(gesture_time*.8+i)*.016
	narrator.volume_db=linear_to_db(maxf(.00001,float(world.options.volume)))
	if listening:status.text=active.title+" · "+("Sorani" if narrated_language=="ckb" else "English")+" · "+str(segment_index+1)+" / "+str(active.segments.size())+(" · Paused" if paused else " · Walk or sit and listen")

func nearby() -> String:
	if world.player.seated:return "seat"
	if world.player.position.distance_to(POSITION)<4.5:return "teacher"
	for p in seats:
		if world.player.position.distance_to(p)<2:return "seat"
	for entry in world.walk_seats:
		if world.player.position.distance_to(entry.node.global_position)<1.65:return "seat"
	return ""

func interact() -> bool:
	var kind=nearby()
	if kind=="teacher":menu();return true
	if kind=="seat":
		if world.player.seated:stand();return true
		var closest=seats[0]
		for p in seats:
			if world.player.position.distance_to(p)<world.player.position.distance_to(closest):closest=p
		var yaw=seat_yaw(closest);var word="";var circle=true
		for entry in world.walk_seats:
			var p:Vector3=entry.node.global_position
			if world.player.position.distance_to(p)<world.player.position.distance_to(closest):closest=p;yaw=entry.node.rotation.y;word=entry.word;circle=false
		if word!="":world.discover(word);world.update_hud();world.save_progress()
		world.player.position=closest+Vector3(0,.42,0);world.player.velocity=Vector3.ZERO;world.player.seated=true
		world.player.visual.rotation.y=yaw;world.toast("Seated · E to stand. Choose a story or keep listening." if circle else "Seated · E to stand.")
		if not listening and circle:menu()
		return true
	return false

func stand() -> void:
	if not world.player.seated:return
	world.player.seated=false;world.player.position+=Vector3(-1.2,.15,0);world.player.velocity=Vector3.ZERO
	world.toast("Standing · Your story keeps playing.")

func menu() -> void:
	world.overlay();var p=world.centered_panel(Vector2(910,770));var v=world.vbox(p,8)
	v.add_child(world.label("Mamosta's story circle",29));v.add_child(world.label("17 original stories set in Kurdistan · Choose a voice, then a story",17))
	var h=HBoxContainer.new();v.add_child(h)
	for lang in ["ckb","en"]:
		h.add_child(world.button(("✓ " if language==lang else "")+("Sorani Kurdish" if lang=="ckb" else "English"),func():language=lang;menu(),language==lang))
	var scroll=ScrollContainer.new();scroll.custom_minimum_size=Vector2(0,490);v.add_child(scroll);var list=world.vbox(scroll,7);list.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	for tale in tales:
		var choice=world.button(tale.title+" · "+tale.ckb_title,func():play(tale.id));choice.add_theme_font_override("font",world.sorani_font);list.add_child(choice)
	v.add_child(world.button("Return to walking / listening",world.clear_screen))

func play(id: String) -> void:
	if world.podcasts!=null:world.podcasts.stop()
	for tale in tales:
		if tale.id==id:active=tale;break
	if active.is_empty():return
	world.clear_screen();narrated_language=language;narrator.stream_paused=false;segment_index=0;paused=false;listening=true;pause_button.text="Ⅱ";subtitle_panel.show();play_segment()

func play_segment() -> void:
	var segment=active.segments[segment_index]
	english_subtitle.text=segment.en;sorani_subtitle.text=segment.ckb
	var path="res://assets/audio/teacher/"+narrated_language+"/"+segment.id+".wav"
	if ResourceLoader.exists(path):narrator.stream=load(path);narrator.play()
	else:world.toast("Narration recording unavailable.");stop()

func next_segment() -> void:
	if not listening:return
	segment_index+=1
	if segment_index>=active.segments.size():
		world.toast("Story complete · Visit the teacher for another story.");stop();return
	play_segment()

func toggle_pause() -> void:
	if not listening:return
	paused=not paused;narrator.stream_paused=paused;pause_button.text="▶" if paused else "Ⅱ"

func stop() -> void:
	active={};listening=false;paused=false;narrator.stop();narrator.stream_paused=false;subtitle_panel.hide()

func _exit_tree() -> void:
	if is_instance_valid(narrator):narrator.stop();narrator.stream=null

func compact(b:Button)->void:
	b.add_theme_font_size_override("font_size",14)
	for state in ["normal","hover","pressed","focus"]:
		var style=b.get_theme_stylebox(state).duplicate();style.set_content_margin_all(7);b.add_theme_stylebox_override(state,style)

static func seat_yaw(p:Vector3)->float:
	var direction=POSITION-p
	return atan2(-direction.x,-direction.z)

static func classroom_chair(adult:bool)->Node3D:
	# Front is local -Z, matching both seated characters. Explicit dimensions avoid imported-chair pivots.
	var n=Node3D.new();var height=.65 if adult else .38
	var width=.94 if adult else .64;var depth=1.05 if adult else .6
	var back_z=.72 if adult else .28
	var wood=Color("ba9165");var cushion=Color("8ba59b")
	WorldProps.box(n,Vector3(0,height-.035,0),Vector3(width,.07,depth),wood)
	WorldProps.box(n,Vector3(0,height+.005,0),Vector3(width*.9,.015,depth*.88),cushion)
	for side in [-1,1]:
		for z in [-depth*.38,depth*.38]:
			WorldProps.box(n,Vector3(side*(width*.42),(height-.07)*.5,z),Vector3(.07,height-.07,.07),wood)
		WorldProps.box(n,Vector3(side*width*.42,height+.4,back_z),Vector3(.07,.85,.07),wood)
		WorldProps.box(n,Vector3(side*width*.42,.18,0),Vector3(.045,.045,depth*.8),wood)
	for y in [height+.25,height+.58]:
		WorldProps.box(n,Vector3(0,y,back_z),Vector3(width,.16,.065),wood)
	AccurateProps.merge_shapes(n)
	return n
