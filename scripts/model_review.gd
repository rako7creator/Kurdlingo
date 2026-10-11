extends SceneTree

var rows:Array=[]
var region_index=0
var regions:Array=[]
var gallery:Control
var mode="audit"
var output=""
var audit:Array=[]

func _initialize()->void:
	rows=JSON.parse_string(FileAccess.get_file_as_string("res://data/vocabulary.json"))
	for row in rows:
		if row.get("expansion",false) and row.region not in regions:regions.append(row.region)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--sheets="):mode="sheets";output=arg.trim_prefix("--sheets=")
	call_deferred("run")

func run()->void:
	for row in rows:
		if not row.get("expansion",false):continue
		var model=WorldProps.make(row.model,float(row.size));var dims:Vector3=model.get_meta("dimensions");assert(dims.length()>.1,"Empty object "+row.id)
		audit.append({"id":row.id,"en":row.en,"region":row.region,"model":row.model,"dimensions":[dims.x,dims.y,dims.z]});model.free()
	assert(audit.size()==500)
	var file=FileAccess.open("res://data/daily-model-audit.json",FileAccess.WRITE);file.store_string(JSON.stringify(audit,"  "));file.close()
	print("MODEL AUDIT: ",audit.size()," nonempty subject models; ",DailyProps.made.size()," specific shape families.")
	if mode=="audit":quit();return
	DirAccess.make_dir_recursive_absolute(output);root.size=Vector2i(2000,1250);root.content_scale_size=Vector2i(2000,1250)
	for region in regions:
		await sheet(region)
	quit()

func sheet(region:String)->void:
	gallery=Control.new();root.add_child(gallery)
	var back=ColorRect.new();back.color=Color("ede7d8");back.size=Vector2(2000,1250);gallery.add_child(back)
	var title=Label.new();title.text="KurdLingo · "+region+" · Actual 3D models";title.position=Vector2(25,10);title.add_theme_color_override("font_color",Color("25424a"));title.add_theme_font_size_override("font_size",28);gallery.add_child(title)
	var index=0
	for row in rows:
		if row.region!=region:continue
		var x=(index%10)*200;var y=58+int(index/10)*235
		var container=SubViewportContainer.new();container.position=Vector2(x,y);container.size=Vector2(195,195);gallery.add_child(container)
		var viewport=SubViewport.new();viewport.size=Vector2i(195,195);viewport.own_world_3d=true;viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS;viewport.msaa_3d=Viewport.MSAA_2X;container.add_child(viewport)
		var scene=Node3D.new();viewport.add_child(scene)
		var env=WorldEnvironment.new();var settings=Environment.new();settings.background_mode=Environment.BG_COLOR;settings.background_color=Color("e4dfd1");settings.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;settings.ambient_light_color=Color("ffffff");settings.ambient_light_energy=.35;env.environment=settings;scene.add_child(env)
		var light=DirectionalLight3D.new();light.rotation_degrees=Vector3(-45,-35,0);light.light_energy=1.0;scene.add_child(light)
		var obj=WorldProps.make(row.model,2.1);scene.add_child(obj);var dims:Vector3=obj.get_meta("dimensions")
		WorldProps.box(scene,Vector3(0,-.045,0),Vector3(3,.08,3),Color("d8c9b0"))
		var camera=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=3.1;camera.position=Vector3(-3,2.5,-4);scene.add_child(camera);camera.look_at(Vector3(0,dims.y*.45,0));camera.current=true
		var label=Label.new();label.text=row.en;label.position=Vector2(x+3,y+196);label.size=Vector2(195,35);label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.add_theme_font_size_override("font_size",15);label.add_theme_color_override("font_color",Color("25424a"));label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;gallery.add_child(label)
		index+=1
	await process_frame;await process_frame;await create_timer(1.5).timeout
	var filename=output.path_join(region.to_lower().replace(" ","-")+".png");root.get_texture().get_image().save_png(filename);print("SHEET ",filename)
	root.remove_child(gallery);gallery.queue_free();await process_frame

