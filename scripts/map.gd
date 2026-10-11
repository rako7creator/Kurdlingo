extends Control

var game: Node3D
var large = false
const REGIONS = {"Town":Vector2(-63,-34),"Homes":Vector2(60,-20),"Market":Vector2(0,-57),"Park":Vector2(-62,61),"Farm":Vector2(62,63)}
const COLORS = {"Town":Color("dbad77"),"Homes":Color("e7bd9c"),"Market":Color("dd8f78"),"Park":Color("8dbc8f"),"Farm":Color("c7c37d")}

var redraw_elapsed=0.0
func _process(delta: float) -> void:
	redraw_elapsed+=delta
	if redraw_elapsed>.12:redraw_elapsed=0;queue_redraw()

func project_point(p: Vector2) -> Vector2:
	return (p+Vector2(590,510))/Vector2(1180,1020)*size

func _draw() -> void:
	draw_style_box(_background(),Rect2(Vector2.ZERO,size))
	for region in game.REGION_CENTERS:
		var p=project_point(Vector2(game.REGION_CENTERS[region].x,game.REGION_CENTERS[region].z))
		draw_circle(p,(17 if large else 5),game.REGION_COLORS[region])
		if large:
			var offsets={"Town":Vector2(-50,-17),"Market":Vector2(-20,-38),"Homes":Vector2(15,-13),"Park":Vector2(-40,25),"Farm":Vector2(12,25),"Lifestyle":Vector2(-24,34),"Kitchen":Vector2(-20,-25),"Workshop":Vector2(-32,-25),"Discovery":Vector2(18,12),"Wildlife":Vector2(-42,20)}
			if offsets.has(region):
				var dest=p+offsets[region];draw_line(p,dest+Vector2(8,-4),Color("90b5af"),1);draw_string(ThemeDB.fallback_font,dest,region,HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("ecf1df"))
			else:
				var parts=region.split(" ") if region.length()>13 else [region]
				for i in range(parts.size()):
					var text:String=parts[i];var width=ThemeDB.fallback_font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,12).x
					draw_string(ThemeDB.fallback_font,p+Vector2(-width*.5,-28+i*12),text,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("ecf1df"))
	for x in [-28,15]:
		draw_line(project_point(Vector2(x,-118)),project_point(Vector2(x,128)),Color("59777b"),8 if large else 3)
	for z in [-20,30]:
		draw_line(project_point(Vector2(-115,z)),project_point(Vector2(115,z)),Color("59777b"),8 if large else 3)
	for x in [-128,128]:
		draw_line(project_point(Vector2(x,-118)),project_point(Vector2(x,128)),Color("59777b"),6 if large else 2)
	for z in [-118,128]:
		draw_line(project_point(Vector2(-128,z)),project_point(Vector2(128,z)),Color("59777b"),6 if large else 2)
	for side in [-1,1]:
		for z in [-108,22]:draw_line(project_point(Vector2(side*128,z)),project_point(Vector2(side*180,z)),Color("59777b"),5 if large else 2)
	draw_line(project_point(Vector2(0,128)),project_point(Vector2(0,137)),Color("59777b"),5 if large else 2)
	for z in [-270,270]:draw_line(project_point(Vector2(-540,z)),project_point(Vector2(540,z)),Color("59777b"),3 if large else 1)
	for x in [-540,-128,128,540]:draw_line(project_point(Vector2(x,-270)),project_point(Vector2(x,270)),Color("59777b"),3 if large else 1)
	for district in ExpansionWorld.DISTRICTS:
		var center:Vector3=game.REGION_CENTERS[district];draw_line(project_point(Vector2(center.x,center.z)),project_point(Vector2(center.x,-270 if center.z<0 else 270)),Color("b2b69c"),3 if large else 1)
	var teacher_point=project_point(Vector2(-5,1));draw_circle(teacher_point,5 if large else 2,Color("ffce78"))
	if large:draw_string(ThemeDB.fallback_font,teacher_point+Vector2(10,-3),"Teacher",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("ffce78"))
	if game==null:return
	for id in game.object_nodes:
		var obj=game.object_nodes[id]
		var p=project_point(Vector2(obj.position.x,obj.position.z))
		var discovered=game.learned.has(id)
		if not large and not discovered and obj.position.distance_squared_to(game.player.position)>5625:continue
		draw_circle(p,2.2 if large else 0.8,Color("9ae0bf") if discovered else Color("759995"))
	if game.waypoint_id!="" and game.object_nodes.has(game.waypoint_id):
		var obj=game.object_nodes[game.waypoint_id]
		var p=project_point(Vector2(obj.position.x,obj.position.z))
		draw_arc(p,7,0,TAU,20,Color("ffce78"),2)
	var p=project_point(Vector2(game.player.position.x,game.player.position.z))
	draw_circle(p,6 if large else 4,Color("f6f3df"))
	draw_arc(p,10 if large else 7,0,TAU,20,Color("69d6bd"),2)

func _background() -> StyleBoxFlat:
	var s=StyleBoxFlat.new();s.bg_color=Color("244b53");s.corner_radius_top_left=15;s.corner_radius_top_right=15;s.corner_radius_bottom_left=15;s.corner_radius_bottom_right=15
	return s
