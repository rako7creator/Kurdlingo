class_name PodcastPlaza
extends Node3D

var world:Node3D
var episodes:Array=[]
var booths:Array=[]
var narrator:AudioStreamPlayer
var panel:PanelContainer
var title_label:Label
var caption_label:Label
var english_label:Label
var time_label:Label
var pause_button:Button
var active:Dictionary={}
var segment_index=0
var booth_index=-1
var caption_index=-1
var paused=false
var playing=false
var listener_seated=false
var auto_allowed=true
var completed:Dictionary={}
var elapsed=0.0
var scan_elapsed=0.0
var end_message_time=0.0
var manual_selection=false
var voices:Array=[]

func _ready()->void:
	episodes=JSON.parse_string(FileAccess.get_file_as_string("res://data/podcasts.json"))
	narrator=AudioStreamPlayer.new();add_child(narrator);narrator.finished.connect(next_segment)
	build_studios();build_captions()

func prop(key:String,p:Vector3,size:float,angle:float=0)->Node3D:
	var node=world.decoration(key,p,size,angle);return node

func build_studios()->void:
	var centre:Vector3=world.REGION_CENTERS["Podcast Plaza"]
	for index in range(10):
		var p=centre+Vector3(-44+(index%5)*22,0,-46+int(index/5)*26)
		var color=[Color("8eb6a3"),Color("c99e8c"),Color("aaa0bc"),Color("92acba")][index%4]
		world.solid_box(p+Vector3(0,.04,0),Vector3(10,.08,15),Color("ddcfb2"),false)
		world.solid_box(p+Vector3(0,1.5,-3),Vector3(10,3,.15),color)
		for x in [-4.8,4.8]:world.solid_box(p+Vector3(x,1.5,-1),Vector3(.12,3,4),color)
		# Open front and high canopy preserve the camera view and the walking routes.
		world.solid_box(p+Vector3(0,3.15,-1),Vector3(10.4,.12,4.6),color.darkened(.12),false)
		for x in [-3.7,-2.4,2.4,3.7]:prop("daily/acoustic_panel",p+Vector3(x,.4,-2.8),1.1)
		prop("daily/diffuser",p+Vector3(0,1,-2.85),1.3)
		var desk=prop("furniture/tableCoffee",p+Vector3(0,0,-.2),2.0)
		for side in [-1,1]:
			prop("furniture/loungeChair",p+Vector3(side*1.1,0,-1.3),1.25)
			var host=TeacherCircle.person(false,index+side+1);host.position=p+Vector3(side*1.1,-.23,-1.3);add_child(host);voices.append(host)
			host.rotation.y=PI
			for part in host.get_children():
				if part is Node3D and part.position.y<.6:part.visible=false
			# Seated bent legs, rather than standing legs passing through the chair.
			for leg_side in [-1,1]:
				WorldProps.line(host,Vector3(leg_side*.16,.72,-.03),Vector3(leg_side*.16,.72,-.33),.065,Color("344451"))
				WorldProps.line(host,Vector3(leg_side*.16,.72,-.33),Vector3(leg_side*.16,.28,-.33),.055,Color("344451"))
			prop("daily/studio_microphone",p+Vector3(side*.6,.62,-.25),.32)
			var arm=prop("daily/boom_arm",p+Vector3(side*.8,.57,.15),.58);arm.rotation.y=PI if side<0 else 0
			prop("daily/studio_headphones",p+Vector3(side*1.1,1.1,-1.3),.4)
		prop("daily/mixing_desk",p+Vector3(0,.62,.25),.65)
		prop("daily/on_air",p+Vector3(0,2.7,-2.87),.8,PI)
		prop("daily/video_camera",p+Vector3(3.5,1.3,2.2),.45,PI);prop("daily/softbox",p+Vector3(-3.7,0,1.5),1.8,PI)
		var sofa=prop("furniture/loungeSofa",p+Vector3(0,0,4.2),2.45,PI)
		var sofa_pos=sofa.global_position+Vector3(0,0,.08)
		prop("furniture/rugRounded",p+Vector3(0,.04,3.1),3.4)
		prop("furniture/tableCoffeeRound" if ResourceLoader.exists("res://assets/furniture/tableCoffeeRound.glb") else "furniture/tableCoffee",p+Vector3(0,0,2.35),1.1)
		prop("furniture/pottedPlant",p+Vector3(4,0,4),1.2)
		var poster=Label3D.new();poster.font=world.english_font;poster.text=str(index+1)+" · "+episodes[index].title;poster.font_size=40;poster.pixel_size=.006;poster.position=p+Vector3(0,2.1,-2.88);poster.modulate=Color("f5f0df");add_child(poster)
		booths.append({"position":p,"sofa":sofa,"seat":sofa_pos,"episode":episodes[index].id})

func build_captions()->void:
	panel=world.panel(world.ui,Vector2.ZERO,Vector2(720,0));panel.anchor_left=.5;panel.anchor_right=.5;panel.anchor_top=1;panel.anchor_bottom=1
	panel.offset_left=-360;panel.offset_right=360;panel.offset_top=-280;panel.offset_bottom=-100
	var layout=world.vbox(panel,5);title_label=world.label("",15,Color("638b7d"));layout.add_child(title_label)
	caption_label=world.label("",20,world.INK,true);caption_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;caption_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT;caption_label.custom_minimum_size=Vector2(670,45);layout.add_child(caption_label)
	english_label=world.label("",15);english_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;english_label.custom_minimum_size=Vector2(670,30);layout.add_child(english_label)
	var controls=world.hbox(layout,6)
	pause_button=world.button("Pause",toggle_pause);controls.add_child(pause_button)
	controls.add_child(world.button("Replay part",func():play_segment()))
	controls.add_child(world.button("Episodes",menu));controls.add_child(world.button("Stop",func():stop();auto_allowed=false))
	controls.add_child(world.button("Stand up",stand));time_label=world.label("",12);controls.add_child(time_label)
	for button_node in controls.get_children():
		if button_node is Button:world.teacher_circle.compact(button_node)
	panel.hide()

func near_booth(radius:float=7.5)->int:
	var closest=radius;var found=-1
	for index in range(booths.size()):
		var dist=world.player.position.distance_to(booths[index].position+Vector3(0,0,3))
		if dist<closest:closest=dist;found=index
	return found

func near_sofa()->int:
	for index in range(booths.size()):
		if world.player.position.distance_to(booths[index].seat)<2:return index
	return -1

func interact()->bool:
	if listener_seated:stand();return true
	var sofa=near_sofa()
	if sofa>=0:
		world.player.riding=false;world.player.position=booths[sofa].seat+Vector3(0,.42,0);world.player.velocity=Vector3.ZERO;world.player.seated=true;world.player.visual.rotation.y=0;listener_seated=true
		if booth_index!=sofa or not playing:play(sofa)
		world.toast("Podcast sofa · E to stand. Your episode keeps playing.");return true
	var index=near_booth()
	if index>=0:menu();return true
	return false

func stand()->void:
	if not listener_seated:return
	listener_seated=false;world.player.seated=false;world.player.position+=Vector3(1.5,.15,0);world.player.velocity=Vector3.ZERO

func menu()->void:
	world.overlay();var box=world.centered_panel(Vector2(780,690));var layout=world.vbox(box,12)
	layout.add_child(world.label("KurdLingo Podcast Plaza",29));layout.add_child(world.label("English conversations · Sorani subtitles · Two voices",16))
	var scroll=ScrollContainer.new();scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;layout.add_child(scroll);var list=VBoxContainer.new();list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(list)
	for index in range(episodes.size()):
		var episode=episodes[index];var choice=index
		var minutes=int(ceil(float(episode.get("duration",600))/60))
		var btn=world.button(str(index+1)+". "+episode.title+" · "+str(minutes)+" min\n"+episode.ckb_title,func():manual_selection=true;play(choice))
		btn.add_theme_font_override("font",world.sorani_font);list.add_child(btn)
	layout.add_child(world.button("Return to walking / listening",world.clear_screen))

func play(index:int)->void:
	world.teacher_circle.stop();world.voice.stop();world.clear_screen();booth_index=index;active=episodes[index];segment_index=0;playing=true;paused=false;caption_index=-1;elapsed=0;auto_allowed=true;end_message_time=0;panel.show();pause_button.text="Pause";play_segment()

func play_segment()->void:
	if active.is_empty():return
	segment_index=clampi(segment_index,0,active.segments.size()-1);playing=true;end_message_time=0;panel.show()
	caption_index=-1;paused=false;narrator.stream_paused=false;pause_button.text="Pause"
	var segment=active.segments[segment_index];narrator.stream=load("res://assets/audio/podcasts/"+segment.id+".wav");narrator.play();update_caption()

func update_caption()->void:
	if active.is_empty():return
	var segment=active.segments[segment_index];var captions=segment.get("captions",[{"en":segment.en,"ckb":segment.ckb,"start":0}]);var position=narrator.get_playback_position();var current=0
	for index in range(captions.size()):
		if float(captions[index].start)<=position:current=index
	if current==caption_index:return
	caption_index=current;caption_label.text=captions[current].ckb;english_label.text=captions[current].en
	title_label.text=active.title+" · "+("Host" if segment.speaker=="host" else "Guest")

func next_segment()->void:
	if not playing:return
	elapsed+=float(active.segments[segment_index].get("duration",0));segment_index+=1
	if segment_index>=active.segments.size():
		world.save_progress.call_deferred()
		completed[active.id]=true;playing=false;caption_label.text="ئەڵقەکە تەواو بوو. دەتوانیت ئەڵقەیەکی دیکە هەڵبژێریت.";english_label.text="Episode complete · Choose another studio or another episode.";end_message_time=7;return
	play_segment()

func toggle_pause()->void:
	if not playing:return
	paused=not paused;narrator.stream_paused=paused;pause_button.text="Resume" if paused else "Pause"

func stop()->void:
	playing=false;paused=false;narrator.stop();narrator.stream_paused=false;active={};panel.hide();booth_index=-1;manual_selection=false

func _process(delta:float)->void:
	if world.player==null or not world.session_started:return
	var subtitle_scale=clampf(float(world.options.get("subtitle_size",.8)),.65,1.1)
	panel.scale=Vector2.ONE*subtitle_scale;panel.offset_left=-360*subtitle_scale;panel.offset_right=panel.offset_left+720
	scan_elapsed+=delta
	if playing:
		update_caption();var radius=world.player.position.distance_to(world.REGION_CENTERS["Podcast Plaza"])
		var gain=float(world.options.get("podcast_volume",.85))*float(world.options.volume)
		if world.voice.playing:gain*=.2
		if not manual_selection and booth_index>=0:gain*=clampf(1-world.player.position.distance_to(booths[booth_index].position)/100,.12,1)
		narrator.volume_db=linear_to_db(maxf(gain,.00001))
		var seconds=elapsed+narrator.get_playback_position();time_label.text=str(int(seconds/60))+":"+str(int(seconds)%60).pad_zeros(2)
		if not manual_selection and radius>125:stop();auto_allowed=true
	if end_message_time>0:end_message_time-=delta;if end_message_time<=0:panel.hide()
	if scan_elapsed>.4:
		scan_elapsed=0;var index=near_booth()
		if index<0:auto_allowed=true
		if index>=0 and auto_allowed and not playing and not world.test_mode and not completed.has(episodes[index].id) and world.screen==null:
			manual_selection=false;play(index)

func _exit_tree()->void:
	if is_instance_valid(narrator):narrator.stop();narrator.stream=null
