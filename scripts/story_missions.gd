class_name StoryMissions
extends RefCounted

var world: Node3D
var chapters: Array=[]
var state={"active":"","step":0,"completed":[]}
var feedback: Label
var answered=false

func _init(owner_node: Node3D) -> void:
	world=owner_node
	chapters=JSON.parse_string(FileAccess.get_file_as_string("res://data/story.json"))

func active_chapter() -> Dictionary:
	for chapter in chapters:
		if chapter.id==state.active:return chapter
	return {}

func menu() -> void:
	world.overlay();var p=world.centered_panel(Vector2(860,770));var v=world.vbox(p,10)
	v.add_child(world.label("The Kurdish Festival",30))
	v.add_child(world.label("10 story chapters · 30 full-sentence challenges · "+str(state.completed.size())+" completed",15))
	var sub=world.label("Help your neighbors prepare a language festival. Follow a chapter's object marker, inspect it, and practise whole sentences in both directions.",17);sub.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;sub.custom_minimum_size.x=790;v.add_child(sub)
	var scroll=ScrollContainer.new();scroll.custom_minimum_size=Vector2(0,475);v.add_child(scroll);var list=world.vbox(scroll,8);list.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	for chapter in chapters:
		var prefix="✓ " if chapter.id in state.completed else ""
		var b=world.button(prefix+chapter.region+" — "+chapter.title,func():start(chapter.id));list.add_child(b)
	if not active_chapter().is_empty():v.add_child(world.button("Return to current mission",func():world.clear_screen();world.waypoint_id=active_chapter().target,true))
	v.add_child(world.button("Back",world.clear_screen))

func start(id: String) -> void:
	state.active=id;state.step=0
	var chapter=active_chapter();world.clear_screen();world.player.teleport(world.ARRIVALS[chapter.region]);world.waypoint_id=chapter.target
	world.toast(chapter.intro+" Find the "+world.by_id[chapter.target].en+" and press E.");world.save_progress()

func on_inspect(id: String) -> void:
	var chapter=active_chapter()
	if chapter.is_empty() or chapter.target!=id:return
	question()

func question() -> void:
	var chapter=active_chapter()
	if chapter.is_empty():return
	world.overlay();var p=world.centered_panel(Vector2(950,760));var v=world.vbox(p,15);answered=false
	var index=clampi(int(state.step),0,2);var step: Dictionary=chapter.steps[index]
	v.add_child(world.label(chapter.title+" · "+str(index+1)+" / 3",28))
	var narrative=world.label(chapter.intro,16,Color("63827d"));narrative.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;narrative.custom_minimum_size.x=860;v.add_child(narrative)
	var reverse=index%2==1
	v.add_child(world.label("Choose the complete English translation." if reverse else "Choose the complete Sorani translation.",18))
	var prompt=world.label(step.ckb if reverse else step.en,27,world.INK,reverse);prompt.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;prompt.custom_minimum_size.x=850;v.add_child(prompt)
	v.add_child(world.button("Listen to the Sorani sentence",func():speak(step.id)))
	var choices: Array=[step]
	var alternatives: Array=[]
	for candidate in chapter.steps:
		if candidate.id!=step.id:alternatives.append(candidate)
	choices.append_array(alternatives);choices.shuffle()
	var buttons: Array=[]
	for choice in choices:
		var b=world.button(choice.en if reverse else choice.ckb,func():answer(choice.id==step.id,step,buttons,v));b.add_theme_font_override("font",world.english_font if reverse else world.sorani_font);b.add_theme_font_size_override("font_size",21);b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;b.custom_minimum_size.y=66;v.add_child(b);buttons.append(b)
	feedback=world.label("",17);v.add_child(feedback)
	v.add_child(world.button("Back to exploring",world.clear_screen))

func answer(correct: bool,step: Dictionary,buttons: Array,container: VBoxContainer) -> void:
	if answered:return
	if not correct:feedback.text="Try again. Listen and compare the complete sentence.";speak(step.id);return
	answered=true
	for b in buttons:b.disabled=true
	feedback.text=step.en+"\n"+step.ckb;feedback.add_theme_font_override("font",world.sorani_font);feedback.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	if not state.has("rewarded"):state.rewarded=[]
	if not step.id in state.rewarded and not state.active in state.completed:
		world.xp+=30;state.rewarded.append(step.id)
	speak(step.id);state.step+=1
	if int(state.step)>=3:
		if not state.active in state.completed:state.completed.append(state.active)
		state.active="";state.step=0;world.waypoint_id=""
		container.add_child(world.button("Chapter complete! Choose another mission",menu,true))
	else:container.add_child(world.button("Continue the story",question,true))
	world.save_progress();world.update_hud()

func speak(id: String) -> void:
	var path="res://assets/audio/story/"+id+".wav"
	if ResourceLoader.exists(path):world.voice.stream=load(path);world.voice.volume_db=linear_to_db(float(world.options.volume));world.voice.play()
	else:world.toast("Sentence recording is unavailable.")
