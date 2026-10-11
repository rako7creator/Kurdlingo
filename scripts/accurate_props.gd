class_name AccurateProps
extends RefCounted
const WOOD=Color("a9794e")
const DARK=Color("303b42")
const METAL=Color("b7c2c5")
const CREAM=Color("f0e6d0")
const BLUE=Color("628da1")
const GREEN=Color("688b55")
const RED=Color("b96554")
const KEYS=["globe","map","barn","bird","butterfly","bee","branch","bear","door","drawer","book","telephone","blanket","towel","soap","toothpaste","toothbrush","pen","pencil","notebook","paper","scissors","key","clock","gate","bicycle","potato","cucumber","sun","ball","tent","basket","bucket","watering_can","hammer","saw","axe","wheelbarrow","rice","chicken","water","sugar","flour","lentils","beans","peas","walnut","almond","pistachio","fig","date_fruit","pomegranate","peach","apricot","plum","wrench","pliers","clamp","vise","anvil","screwdriver","chisel","file_tool","drill_bit","nut","screw","bolt","nail","washer_ring","spring","hose","electric_cable","thread","spirit_level","protractor","paintbrush","broom","mop","dustpan","vacuum_cleaner","pipe","faucet","funnel","battery","light_bulb","beaker","test_tube","flask","pipette","microscope","telescope","moon","planet","atom_model","compass","stopwatch","scale","calendar","postcard","clipboard","folder","canvas","blackboard","backpack","lunchbox","shirt","t_shirt","jacket","coat","sweater","dress","life_jacket","skirt","trousers","shorts","sandal","slipper","sock","shoe","boot","hat","cap","belt","scarf","watch","wallet","combination_lock","flute","trumpet","violin","accordion","scooter","surfboard","basketball_hoop","football_goal","flag"]

static func b(n:Node3D,p:Vector3,size:Vector3,col:Color=METAL)->MeshInstance3D:return WorldProps.box(n,p,size,col)
static func s(n:Node3D,p:Vector3,size:Vector3,col:Color=CREAM)->MeshInstance3D:return WorldProps.sphere(n,p,size,col)
static func l(n:Node3D,a:Vector3,z:Vector3,r:float,col:Color=METAL)->MeshInstance3D:return WorldProps.line(n,a,z,r,col)
static func c(n:Node3D,p:Vector3,r:float,h:float,col:Color=METAL,top:float=-1)->MeshInstance3D:return WorldProps.cylinder(n,p,r,h,col,top)
static func ring(n:Node3D,p:Vector3,r:float,col:Color=METAL)->MeshInstance3D:return AnnexProps.ring(n,p,r,col)
static func curve(n:Node3D,points:Array,r:float,col:Color)->void:
	for i in range(points.size()-1):l(n,points[i],points[i+1],r,col)
static func lathe(n:Node3D,profile:Array,col:Color)->Node3D:
	var mesh=SurfaceTool.new();mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
	for j in range(profile.size()-1):
		for i in range(32):
			var a=i*TAU/32;var z=(i+1)*TAU/32
			var p=profile[j];var q=profile[j+1]
			var v=[Vector3(sin(a)*p.x,p.y,cos(a)*p.x),Vector3(sin(z)*p.x,p.y,cos(z)*p.x),Vector3(sin(a)*q.x,q.y,cos(a)*q.x),Vector3(sin(z)*q.x,q.y,cos(z)*q.x)]
			for k in [0,2,1,1,2,3]:
				mesh.set_uv(Vector2(float(i)/32,float(j)/maxi(1,profile.size()-1)))
				mesh.add_vertex(v[k])
	mesh.generate_normals();var part=MeshInstance3D.new();part.mesh=mesh.commit();part.material_override=WorldProps.material(col);n.add_child(part);return part
static func tag(n:Node3D,text:String,p:Vector3,size:float=.0035)->Label3D:
	var t=Label3D.new();t.text=text;t.position=p;t.font=load("res://assets/NotoSans.ttf");t.font_size=32;t.pixel_size=size;t.modulate=CREAM;t.outline_size=0;n.add_child(t);return t
static func cloth(n:Node3D,p:Vector3,size:Vector3,col:Color)->void:
	b(n,p,size,col)
	for i in range(6):b(n,p+Vector3(-size.x*.4+i*size.x*.16,size.y*.51,0),Vector3(.008,.002,size.z*.92),Color(col,.8).darkened(.08))

static func make(k:String)->Node3D:
	var n=Node3D.new();var col=Color.from_hsv(float(absi(k.hash())%100)/100,.28,.7)
	match k:
		"globe":
			var globe=WorldProps.sphere(n,Vector3(0,.65,0),Vector3.ONE*.9,BLUE)
			var mat=StandardMaterial3D.new();mat.albedo_texture=load("res://assets/teaching_world_map.svg");mat.roughness=.75;globe.material_override=mat
			ring(n,Vector3(0,.65,0),.49,METAL).rotation.x=PI/2;c(n,Vector3(0,.07,0),.3,.1,WOOD);l(n,Vector3(0,.12,0),Vector3(0,.25,0),.055,METAL)
		"map":
			b(n,Vector3(0,.43,0),Vector3(1.2,.7,.045),WOOD)
			var plane=PlaneMesh.new();plane.orientation=PlaneMesh.FACE_Z;plane.size=Vector2(1.13,.565)
			var m=MeshInstance3D.new();m.mesh=plane;m.position=Vector3(0,.43,-.03);m.rotation.y=PI;var mat=StandardMaterial3D.new();mat.albedo_texture=load("res://assets/teaching_world_map.svg");m.material_override=mat;n.add_child(m)
		"barn":
			b(n,Vector3(0,.6,0),Vector3(1.7,1.2,1.3),RED)
			for side in [-1,1]:b(n,Vector3(side*.5,1.31,0),Vector3(1.15,.09,1.45),DARK).rotation.z=side*-.46
			for side in [-1,1]:
				b(n,Vector3(side*.28,.5,-.66),Vector3(.52,.94,.04),WOOD)
				l(n,Vector3(side*.04,.1,-.69),Vector3(side*.51,.9,-.69),.025,CREAM)
			l(n,Vector3(-.56,.04,-.7),Vector3(-.56,1.04,-.7),.03,CREAM);l(n,Vector3(.56,.04,-.7),Vector3(.56,1.04,-.7),.03,CREAM);l(n,Vector3(-.56,1.04,-.7),Vector3(.56,1.04,-.7),.03,CREAM)
		"bird":
			n.free();return AnimalModels.make("bird")
		"butterfly","bee":
			s(n,Vector3(0,.3,0),Vector3(.13,.17,.55),DARK)
			for side in [-1,1]:
				for z in [-.12,.15]:
					s(n,Vector3(side*.22,.35,z),Vector3(.4,.018,.28),Color("d1a068") if k=="butterfly" else Color("c4d5d3"))
					if k=="butterfly":s(n,Vector3(side*.3,.364,z),Vector3(.13,.01,.09),RED)
				l(n,Vector3(side*.045,.34,-.2),Vector3(side*.1,.48,-.35),.007,DARK)
			if k=="bee":
				for z in [-.1,.04,.18]:s(n,Vector3(0,.3,z),Vector3(.15,.18,.06),Color("d8b950"))
		"bear":
			n.free();return AnimalModels.make("bear")
		"branch":
			curve(n,[Vector3(-.6,.12,0),Vector3(-.2,.2,.03),Vector3(.25,.28,-.06),Vector3(.75,.38,0)],.055,WOOD)
			l(n,Vector3(.1,.26,0),Vector3(.35,.5,.18),.025,WOOD);l(n,Vector3(-.2,.2,.03),Vector3(-.35,.45,-.15),.023,WOOD)
		"door":
			b(n,Vector3(0,1,0),Vector3(.9,2,.075),WOOD)
			for y in [.5,1.35]:b(n,Vector3(0,y,-.05),Vector3(.68,.6,.018),WOOD.darkened(.12))
			l(n,Vector3(.32,1,-.07),Vector3(.18,1,-.07),.025,Color("ceba80"))
			for y in [.2,1,1.8]:c(n,Vector3(-.43,y,0),.023,.09,METAL)
		"drawer":
			b(n,Vector3(0,.04,0),Vector3(1,.08,.72),WOOD)
			for x in [-.47,.47]:b(n,Vector3(x,.18,0),Vector3(.06,.3,.72),WOOD)
			for z in [-.34,.34]:b(n,Vector3(0,.18,z),Vector3(1,.3,.06),WOOD)
			l(n,Vector3(-.18,.2,-.41),Vector3(.18,.2,-.41),.024,METAL)
		"book","notebook":
			for y in [.035,.17]:b(n,Vector3(0,y,0),Vector3(.65,.035,.88),BLUE)
			b(n,Vector3(0,.1,0),Vector3(.6,.1,.83),CREAM);b(n,Vector3(-.315,.1,0),Vector3(.04,.15,.88),BLUE)
			for i in range(5):b(n,Vector3(.305,.065+i*.018,0),Vector3(.003,.002,.8),Color("b9b2a0"))
			if k=="notebook":for i in range(8):ring(n,Vector3(-.32,.13,-.35+i*.1),.04,METAL).rotation.z=PI/2
		"telephone":
			b(n,Vector3(0,.15,0),Vector3(.8,.23,.65),CREAM)
			for i in range(12):b(n,Vector3(-.15+(i%3)*.15,.28,-.08+int(i/3)*.1),Vector3(.1,.03,.065),DARK)
			l(n,Vector3(-.34,.4,-.2),Vector3(.34,.4,-.2),.07,DARK)
			for side in [-1,1]:s(n,Vector3(side*.32,.33,-.2),Vector3(.2,.14,.25),DARK)
			for i in range(12):ring(n,Vector3(.43,.1,.18+i*.04),.045,DARK).rotation.x=PI/2
		"blanket","towel":
			cloth(n,Vector3(0,.04,0),Vector3(.85,.07,1.15),BLUE if k=="blanket" else CREAM)
			cloth(n,Vector3(0,.09,.17),Vector3(.85,.05,.82),BLUE if k=="blanket" else CREAM)
			for z in [-.53,.53]:b(n,Vector3(0,.078,z),Vector3(.82,.005,.04),BLUE.darkened(.2))
		"paper":
			b(n,Vector3(0,.012,0),Vector3(.71,.009,1),CREAM)
			for i in range(8):b(n,Vector3(-.02,.018,-.37+i*.09),Vector3(.55,.002,.008),BLUE.lightened(.3))
		"soap":
			s(n,Vector3(0,.09,0),Vector3(.62,.17,.38),Color("e2d6bd"));s(n,Vector3(0,.18,0),Vector3(.32,.009,.16),Color("cec1a8"))
		"toothpaste":
			var tube=c(n,Vector3(0,.3,0),.095,.5,CREAM,.065);tube.rotation.z=.15
			c(n,Vector3(-.045,.62,0),.05,.12,BLUE);b(n,Vector3(.04,.04,0),Vector3(.21,.035,.04),BLUE)
			b(n,Vector3(0,.33,-.087),Vector3(.12,.24,.015),BLUE)
		"toothbrush":
			l(n,Vector3(0,.04,0),Vector3(0,.72,0),.035,BLUE);b(n,Vector3(0,.86,0),Vector3(.11,.23,.07),BLUE)
			for i in range(10):l(n,Vector3(-.03+(i%2)*.06,.79+int(i/2)*.035,-.025),Vector3(-.03+(i%2)*.06,.79+int(i/2)*.035,-.1),.012,CREAM)
		"pen","pencil":
			c(n,Vector3(0,.5,0),.028,.9,Color("d4ad59") if k=="pencil" else BLUE)
			c(n,Vector3(0,.985,0),.028,.075,WOOD,0);c(n,Vector3(0,1.025,0),.011,.024,DARK,0)
			if k=="pencil":c(n,Vector3(0,.035,0),.031,.065,Color("dca0a0"))
			else:l(n,Vector3(.035,.05,0),Vector3(.035,.27,0),.01,METAL)
		"scissors":
			for side in [-1,1]:
				ring(n,Vector3(side*.15,.08,-.26),.125,BLUE).scale=Vector3(.85,1,1.15)
				l(n,Vector3(side*.13,.08,-.14),Vector3(-side*.045,.08,.12),.027,METAL)
				var blade=b(n,Vector3(-side*.085,.075,.36),Vector3(.07,.032,.55),METAL);blade.rotation.y=-side*.22
			c(n,Vector3(0,.105,.1),.036,.03,DARK)
		"key":
			ring(n,Vector3(0,.04,-.2),.17,Color("c7ae75"));b(n,Vector3(0,.04,.18),Vector3(.065,.07,.58),Color("c7ae75"))
			for z in [.3,.44]:b(n,Vector3(.075,.04,z),Vector3(.18,.07,.055),Color("c7ae75"))
		"clock":
			c(n,Vector3(0,.55,0),.53,.09,WOOD).rotation.x=PI/2;c(n,Vector3(0,.55,-.06),.48,.01,CREAM).rotation.x=PI/2
			for i in range(12):s(n,Vector3(sin(i*TAU/12)*.4,.55+cos(i*TAU/12)*.4,-.075),Vector3(.03,.03,.008),DARK)
			l(n,Vector3(0,.55,-.09),Vector3(0,.88,-.09),.012,DARK);l(n,Vector3(0,.55,-.095),Vector3(.22,.52,-.095),.017,DARK)
		"gate":
			for x in [-1,1]:b(n,Vector3(x,.65,0),Vector3(.12,1.3,.12),WOOD)
			for y in [.3,1]:b(n,Vector3(0,y,0),Vector3(2,.08,.08),WOOD)
			for i in range(9):b(n,Vector3(-.85+i*.21,.65,0),Vector3(.08,1.1,.055),WOOD)
		"bicycle":
			for x in [-.7,.7]:
				ring(n,Vector3(x,.48,0),.44,DARK).rotation.x=PI/2
				for i in range(12):l(n,Vector3(x,.48,0),Vector3(x+sin(i*TAU/12)*.4,.48+cos(i*TAU/12)*.4,0),.009,METAL)
			var pts=[Vector3(-.7,.48,0),Vector3(-.12,1.05,0),Vector3(.14,.46,0),Vector3(-.7,.48,0),Vector3(.42,.96,0),Vector3(.14,.46,0),Vector3(.7,.48,0),Vector3(.42,.96,0)];curve(n,pts,.025,RED)
			b(n,Vector3(-.12,1.12,0),Vector3(.3,.07,.19),DARK);l(n,Vector3(.42,.95,0),Vector3(.42,1.16,0),.025,METAL);l(n,Vector3(.42,1.16,-.2),Vector3(.42,1.16,.2),.025,DARK)
			ring(n,Vector3(.14,.46,0),.11,METAL).rotation.x=PI/2
		"potato","cucumber":
			s(n,Vector3(0,.21,0),Vector3(.85,.42,.5) if k=="potato" else Vector3(.33,.28,1.1),Color("b59769") if k=="potato" else GREEN.darkened(.1))
			for i in range(12):s(n,Vector3(sin(i*2.4)*(.32 if k=="potato" else .1),.36,cos(i*2.4)*(.17 if k=="potato" else .45)),Vector3.ONE*.018,WOOD if k=="potato" else GREEN)
		"sun":
			s(n,Vector3(0,.65,0),Vector3.ONE*.8,Color("edc768"))
			for i in range(16):l(n,Vector3(sin(i*TAU/16)*.49,.65+cos(i*TAU/16)*.49,0),Vector3(sin(i*TAU/16)*.65,.65+cos(i*TAU/16)*.65,0),.012,Color("edc768"))
		"ball":
			s(n,Vector3(0,.4,0),Vector3.ONE*.8,CREAM)
			for i in range(10):s(n,Vector3(sin(i*2.4)*.31,.4+cos(i*2.4)*.25,.2),Vector3(.15,.15,.05),DARK)
		"tent":
			var st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
			var a=Vector3(-.7,0,-.85);var z=Vector3(.7,0,-.85);var top=Vector3(0,1.1,-.85);var a2=a+Vector3(0,0,1.7);var z2=z+Vector3(0,0,1.7);var t2=top+Vector3(0,0,1.7)
			for v in [a,a2,top,a2,t2,top,top,t2,z,t2,z2,z,a2,z2,t2]:st.add_vertex(v)
			st.generate_normals();var m=MeshInstance3D.new();m.mesh=st.commit();m.material_override=WorldProps.material(BLUE);n.add_child(m)
			b(n,Vector3(0,.018,0),Vector3(1.4,.025,1.7),DARK)
			for side in [-1,1]:l(n,Vector3(side*.7,0,-.85),top,.018,METAL)
		"basket","bucket","watering_can":
			lathe(n,[Vector2(0,0),Vector2(.3,0),Vector2(.42,.65),Vector2(.38,.65),Vector2(.27,.07),Vector2(0,.07)],WOOD if k=="basket" else BLUE)
			var points=[]
			for i in range(17):points.append(Vector3(cos(i*PI/16)*.42,.65+sin(i*PI/16)*.37,0))
			curve(n,points,.023,WOOD if k=="basket" else METAL)
			if k=="basket":
				for y in range(1,7):ring(n,Vector3(0,y*.09,0),.3+y*.015,WOOD.darkened(.16))
			if k=="watering_can":l(n,Vector3(.32,.2,0),Vector3(.82,.55,0),.045,BLUE);s(n,Vector3(.82,.55,0),Vector3(.09,.2,.2),METAL)
		"hammer","axe","saw":
			if k=="saw":
				b(n,Vector3(0,.12,0),Vector3(1,.03,.25),METAL)
				for i in range(15):c(n,Vector3(-.46+i*.066,.12,.15),.033,.035,METAL,0).rotation.x=PI/2
				ring(n,Vector3(.64,.12,0),.18,WOOD).scale=Vector3(.8,1,1.2)
			else:
				l(n,Vector3(0,.05,0),Vector3(.02,1.02,0),.04,WOOD)
				if k=="hammer":
					b(n,Vector3(.05,1,0),Vector3(.44,.15,.14),METAL);curve(n,[Vector3(-.18,1,0),Vector3(-.26,1.05,0),Vector3(-.3,.9,0)],.035,METAL)
				else:lathe(n,[Vector2(0,.85),Vector2(.3,.85),Vector2(.38,1.1),Vector2(.1,1.1),Vector2(0,.85)],METAL).scale=Vector3(1,1,.25)
		"wheelbarrow":
			lathe(n,[Vector2(.05,.4),Vector2(.35,.4),Vector2(.5,.8),Vector2(.46,.8),Vector2(.31,.45),Vector2(.05,.45)],GREEN).scale=Vector3(1,1,1.4)
			for side in [-1,1]:l(n,Vector3(side*.3,.4,-.6),Vector3(side*.3,.7,1),.032,METAL);l(n,Vector3(side*.3,.4,.3),Vector3(side*.3,.02,.4),.035,METAL)
			c(n,Vector3(0,.23,-.68),.22,.12,DARK).rotation.z=PI/2
		"rice","sugar","flour","lentils","beans","peas":
			lathe(n,[Vector2(0,0),Vector2(.25,0),Vector2(.5,.25),Vector2(.47,.28),Vector2(.2,.045),Vector2(0,.045)],CREAM)
			if k in ["sugar","flour"]:
				s(n,Vector3(0,.2,0),Vector3(.75,.25,.75),Color("e9e2d0"))
				b(n,Vector3(.67,.38,0),Vector3(.38,.75,.2),CREAM);tag(n,k.to_upper(),Vector3(.67,.44,.105),.0025)
			else:
				for i in range(60):s(n,Vector3(sin(i*2.4)*.34,.13+(i%4)*.025,cos(i*2.4)*.34),Vector3(.035,.025,.09) if k=="rice" else Vector3(.11,.05,.09) if k=="lentils" else Vector3(.075,.075,.075) if k=="peas" else Vector3(.13,.065,.08),CREAM if k=="rice" else GREEN if k=="peas" else Color("aa7650"))
		"water":
			lathe(n,[Vector2(0,0),Vector2(.21,0),Vector2(.27,.7),Vector2(.245,.7),Vector2(.18,.045),Vector2(0,.045)],Color("b3d1d0"))
			c(n,Vector3(0,.4,0),.235,.01,Color("7eafb8"))
		"chicken":
			s(n,Vector3(0,.22,0),Vector3(.9,.45,.55),Color("d7aa82"))
			for side in [-1,1]:s(n,Vector3(.25,.15,side*.28),Vector3(.4,.23,.2),Color("d7aa82"));l(n,Vector3(.4,.15,side*.28),Vector3(.56,.16,side*.28),.04,CREAM)
		"walnut","almond","pistachio","fig","date_fruit","pomegranate","peach","apricot","plum":fruit(n,k)
		"wrench","pliers","clamp","vise","anvil","screwdriver","chisel","file_tool","drill_bit","nut","screw","bolt","nail","washer_ring","spring","hose","electric_cable","thread","spirit_level","protractor","paintbrush","broom","mop","dustpan","vacuum_cleaner","pipe","faucet","funnel","battery","light_bulb":tools(n,k,col)
		"beaker","test_tube","flask","pipette","microscope","telescope","moon","planet","atom_model","compass","stopwatch","scale","calendar","postcard","clipboard","folder","canvas","blackboard","backpack","lunchbox":discovery(n,k,col)
		"shirt","t_shirt","jacket","coat","sweater","dress","life_jacket","skirt","trousers","shorts","sandal","slipper","sock","shoe","boot","hat","cap","belt","scarf","watch","wallet","combination_lock","flute","trumpet","violin","accordion","scooter","surfboard","basketball_hoop","football_goal","flag":lifestyle(n,k,col)
		_:push_error("No accurate model for "+k)
	return n

static func fruit(n:Node3D,k:String)->void:
	var colors={"walnut":"9b754d","almond":"b68e63","pistachio":"d3c294","fig":"735370","date_fruit":"74462f","pomegranate":"b44e45","peach":"dfa381","apricot":"e8a450","plum":"654c74"}
	var size=Vector3(.35,.52,.27) if k=="almond" else Vector3(.33,.23,.7) if k=="date_fruit" else Vector3(.48,.32,.28) if k=="pistachio" else Vector3(.65,.62,.63)
	s(n,Vector3(0,size.y*.5,0),size,Color(colors[k]))
	if k=="pistachio":s(n,Vector3(0,.19,0),Vector3(.35,.07,.14),GREEN)
	if k in ["peach","apricot","plum"]:curve(n,[Vector3(0,.1,-.25),Vector3(0,.3,-.32),Vector3(0,.5,-.22)],.008,Color(colors[k]).darkened(.18))
	if k=="walnut":
		for i in range(7):curve(n,[Vector3(-.23+i*.07,.12,-.17),Vector3(-.23+i*.07,.3,-.3),Vector3(-.23+i*.07,.48,-.18)],.013,WOOD.darkened(.2))
	if k in ["date_fruit","almond"]:
		for i in range(5):l(n,Vector3(-.1+i*.05,.2,-.25),Vector3(-.1+i*.05,.23,.25),.005,WOOD.darkened(.3))
	if k=="pomegranate":
		for i in range(6):c(n,Vector3(sin(i*TAU/6)*.045,.7,cos(i*TAU/6)*.045),.035,.14,Color(colors[k]),0)
	elif k not in ["walnut","almond","pistachio","date_fruit"]:
		l(n,Vector3(0,.55,0),Vector3(.04,.7,0),.018,WOOD);s(n,Vector3(.12,.63,0),Vector3(.2,.025,.1),GREEN)

static func tools(n:Node3D,k:String,col:Color)->void:
	match k:
		"wrench":
			b(n,Vector3(0,.4,0),Vector3(.11,.65,.055),METAL)
			for y in [.08,.78]:
				curve(n,[Vector3(-.18,y+.12,0),Vector3(-.18,y-.02,0),Vector3(0,y-.12,0),Vector3(.18,y-.02,0),Vector3(.18,y+.12,0)],.035,METAL)
		"pliers":
			for side in [-1,1]:
				curve(n,[Vector3(side*.18,.03,0),Vector3(side*.13,.35,0),Vector3(-side*.075,.6,0),Vector3(-side*.09,.8,0)],.045,RED)
				l(n,Vector3(-side*.075,.6,0),Vector3(-side*.09,.8,0),.035,METAL)
			c(n,Vector3(0,.49,0),.045,.07,METAL).rotation.x=PI/2
		"clamp":
			curve(n,[Vector3(.22,.85,0),Vector3(-.22,.85,0),Vector3(-.22,.1,0),Vector3(.22,.1,0)],.07,RED)
			l(n,Vector3(.22,.02,0),Vector3(.22,.68,0),.026,METAL);l(n,Vector3(.02,.07,0),Vector3(.42,.07,0),.018,METAL)
			c(n,Vector3(.22,.67,0),.09,.035,METAL)
		"vise":
			b(n,Vector3(0,.08,0),Vector3(.7,.15,.5),BLUE);b(n,Vector3(0,.28,0),Vector3(.35,.3,.35),BLUE)
			for x in [-.23,.23]:b(n,Vector3(x,.49,0),Vector3(.16,.3,.5),BLUE);b(n,Vector3(x,.66,0),Vector3(.16,.045,.52),METAL)
			l(n,Vector3(-.55,.3,0),Vector3(.55,.3,0),.035,METAL);l(n,Vector3(.5,.1,0),Vector3(.5,.5,0),.025,METAL)
		"anvil":
			b(n,Vector3(0,.08,0),Vector3(.8,.16,.5),DARK);b(n,Vector3(0,.32,0),Vector3(.32,.4,.3),DARK);b(n,Vector3(0,.56,0),Vector3(.75,.14,.4),METAL)
			c(n,Vector3(.6,.56,0),.16,.55,METAL,0).rotation.z=-PI/2
		"screwdriver","chisel","file_tool","drill_bit":
			c(n,Vector3(0,.25,0),.08,.45,BLUE if k=="screwdriver" else WOOD)
			if k=="screwdriver":l(n,Vector3(0,.46,0),Vector3(0,.9,0),.023,METAL);b(n,Vector3(0,.93,0),Vector3(.09,.09,.014),METAL)
			elif k=="chisel":b(n,Vector3(0,.73,0),Vector3(.09,.52,.03),METAL)
			elif k=="file_tool":
				b(n,Vector3(0,.73,0),Vector3(.11,.52,.035),METAL)
				for i in range(18):l(n,Vector3(-.045,.5+i*.026,-.02),Vector3(.045,.51+i*.026,-.02),.003,DARK)
			else:
				c(n,Vector3(0,.52,0),.04,1,METAL)
				for side in [-1,1]:
					var pts=[]
					for i in range(26):pts.append(Vector3(sin(i*.45+side*PI)*.045,.3+i*.024,cos(i*.45+side*PI)*.045))
					curve(n,pts,.009,DARK)
		"nut","washer_ring":
			lathe(n,[Vector2(.13,0),Vector2(.3,0),Vector2(.3,.24 if k=="nut" else .045),Vector2(.13,.24 if k=="nut" else .045),Vector2(.13,0)],METAL)
			if k=="nut":
				for i in range(6):b(n,Vector3(sin(i*TAU/6)*.255,.12,cos(i*TAU/6)*.255),Vector3(.25,.24,.035),METAL).rotation.y=i*TAU/6
		"screw","bolt","nail":
			c(n,Vector3(0,.38,0),.04,.68,METAL);c(n,Vector3(0,.745,0),.11,.05,METAL)
			if k=="screw":b(n,Vector3(0,.774,0),Vector3(.14,.003,.014),DARK);b(n,Vector3(0,.774,0),Vector3(.014,.003,.14),DARK);c(n,Vector3(0,.02,0),0,.08,METAL,.04)
			if k!="nail":
				var points=[]
				for i in range(80):points.append(Vector3(sin(i*.8)*.048,.08+i*.006,cos(i*.8)*.048))
				curve(n,points,.007,METAL.darkened(.2))
		"spring":
			var pts=[]
			for i in range(200):pts.append(Vector3(sin(i*.3)*.2,.04+i*.004,cos(i*.3)*.2))
			curve(n,pts,.025,METAL)
		"hose","electric_cable","thread":
			var points=[]
			for i in range(100):points.append(Vector3(sin(i*.2)*(.35+i*.001),.05+i*.001,cos(i*.2)*(.35+i*.001)))
			curve(n,points,.027 if k=="hose" else .016,GREEN if k=="hose" else DARK if k=="electric_cable" else CREAM)
			if k=="electric_cable":b(n,Vector3(.45,.1,0),Vector3(.13,.13,.2),DARK);for side in [-1,1]:l(n,Vector3(.45+side*.035,.1,-.1),Vector3(.45+side*.035,.1,-.2),.008,METAL)
			if k=="thread":c(n,Vector3(0,.15,0),.12,.25,WOOD)
		"spirit_level":
			b(n,Vector3(0,.1,0),Vector3(1.2,.2,.16),Color("d7b254"));b(n,Vector3(0,.21,0),Vector3(.22,.018,.11),GREEN.lightened(.4));s(n,Vector3(0,.222,0),Vector3(.055,.008,.055),CREAM)
			for x in [-.47,.47]:b(n,Vector3(x,.1,-.09),Vector3(.1,.08,.02),GREEN.lightened(.4))
		"protractor":
			var pts=[]
			for i in range(33):pts.append(Vector3(cos(i*PI/32)*.5,.03,sin(i*PI/32)*.5))
			curve(n,pts,.025,BLUE);l(n,Vector3(-.5,.03,0),Vector3(.5,.03,0),.022,BLUE)
			for i in range(19):l(n,Vector3(cos(i*PI/18)*.42,.03,sin(i*PI/18)*.42),Vector3(cos(i*PI/18)*.5,.03,sin(i*PI/18)*.5),.006,DARK)
		"paintbrush","broom","mop":
			l(n,Vector3(0,.12,0),Vector3(0,1.1,0),.027,WOOD)
			if k=="paintbrush":
				b(n,Vector3(0,1.1,0),Vector3(.16,.12,.08),METAL)
				for i in range(12):l(n,Vector3(-.07+i*.013,1.16,0),Vector3(-.07+i*.013,1.38,0),.007,CREAM)
			elif k=="broom":
				b(n,Vector3(0,.12,0),Vector3(.5,.1,.15),WOOD)
				for i in range(18):l(n,Vector3(-.22+i*.026,.1,0),Vector3(-.24+i*.028,.015,0),.012,Color("b19a69"))
			else:for i in range(20):l(n,Vector3(sin(i)*.05,.12,cos(i)*.05),Vector3(sin(i)*.23,.01,cos(i)*.23),.012,CREAM)
		"dustpan":
			b(n,Vector3(0,.02,0),Vector3(.65,.03,.5),BLUE)
			for x in [-.31,.31]:b(n,Vector3(x,.08,0),Vector3(.025,.15,.5),BLUE)
			b(n,Vector3(0,.08,.24),Vector3(.65,.15,.025),BLUE);l(n,Vector3(0,.07,.25),Vector3(0,.12,.75),.045,BLUE)
		"vacuum_cleaner":
			s(n,Vector3(0,.25,0),Vector3(.6,.4,.85),BLUE)
			for side in [-1,1]:c(n,Vector3(side*.31,.16,.2),.14,.08,DARK).rotation.z=PI/2
			curve(n,[Vector3(0,.3,-.38),Vector3(0,.65,-.65),Vector3(0,.8,-.9),Vector3(0,.58,-1.05)],.032,DARK)
			l(n,Vector3(0,.58,-1.05),Vector3(0,.1,-1.2),.025,METAL);b(n,Vector3(0,.06,-1.2),Vector3(.45,.08,.18),DARK)
		"pipe":
			lathe(n,[Vector2(.14,0),Vector2(.19,0),Vector2(.19,1),Vector2(.14,1),Vector2(.14,0)],METAL)
		"faucet":
			c(n,Vector3(0,.12,0),.17,.06,METAL);curve(n,[Vector3(0,.12,0),Vector3(0,.7,0),Vector3(.16,.85,0),Vector3(.36,.8,0),Vector3(.4,.6,0)],.055,METAL)
			l(n,Vector3(-.14,.2,0),Vector3(-.3,.38,0),.025,METAL)
		"funnel":lathe(n,[Vector2(.055,0),Vector2(.055,.3),Vector2(.36,.75),Vector2(.34,.75),Vector2(.035,.3),Vector2(.035,0)],METAL)
		"battery":
			c(n,Vector3(0,.4,0),.15,.75,DARK);c(n,Vector3(0,.77,0),.15,.1,Color("b69a5f"));c(n,Vector3(0,.84,0),.045,.045,METAL);tag(n,"+",Vector3(0,.65,.152),.002)
		"light_bulb":
			c(n,Vector3(0,.15,0),.12,.26,METAL);s(n,Vector3(0,.48,0),Vector3(.43,.48,.43),CREAM)
			for i in range(5):ring(n,Vector3(0,.04+i*.045,0),.12,METAL.darkened(.15))

static func discovery(n:Node3D,k:String,col:Color)->void:
	match k:
		"beaker","test_tube","flask","pipette":
			var glass=Color("a1c3c8")
			if k=="flask":lathe(n,[Vector2(0,0),Vector2(.24,0),Vector2(.34,.25),Vector2(.12,.65),Vector2(.09,.95),Vector2(.06,.95),Vector2(.08,.64),Vector2(.3,.25),Vector2(.2,.04),Vector2(0,.04)],glass)
			elif k=="pipette":c(n,Vector3(0,.4,0),.019,.7,glass);s(n,Vector3(0,.85,0),Vector3(.09,.18,.09),RED)
			else:lathe(n,[Vector2(0,0),Vector2(.09 if k=="test_tube" else .26,0),Vector2(.1 if k=="test_tube" else .3,.75),Vector2(.075 if k=="test_tube" else .27,.75),Vector2(.065 if k=="test_tube" else .23,.06),Vector2(0,.06)],glass)
			if k!="pipette":
				for i in range(5):b(n,Vector3(.01,.17+i*.1,-.105 if k=="test_tube" else -.31),Vector3(.06,.006,.006),CREAM)
		"microscope":
			b(n,Vector3(0,.06,0),Vector3(.65,.12,.45),CREAM)
			curve(n,[Vector3(.2,.12,0),Vector3(.2,.7,0),Vector3(.03,.94,0),Vector3(-.23,.97,0)],.065,CREAM)
			b(n,Vector3(-.12,.38,0),Vector3(.4,.045,.3),DARK)
			l(n,Vector3(-.24,.72,0),Vector3(-.34,1.15,0),.06,DARK)
			for side in [-1,1]:c(n,Vector3(.22,.58,side*.14),.08,.035,DARK).rotation.x=PI/2
			s(n,Vector3(-.13,.2,0),Vector3(.15,.045,.15),METAL)
		"telescope":
			for i in range(3):l(n,Vector3(0,.7,0),Vector3(sin(i*TAU/3)*.4,0,cos(i*TAU/3)*.4),.025,METAL)
			l(n,Vector3(-.46,.75,0),Vector3(.48,1.02,0),.1,CREAM);l(n,Vector3(-.55,.72,0),Vector3(-.42,.76,0),.045,DARK);s(n,Vector3(.48,1.02,0),Vector3(.012,.18,.18),BLUE)
		"moon":
			s(n,Vector3(0,.5,0),Vector3.ONE,Color("b7b9b4"))
			for i in range(12):s(n,Vector3(sin(i*2.4)*.32,.5+cos(i*2.4)*.32,.31),Vector3(.1,.1,.017),Color("939a98"))
		"planet":s(n,Vector3(0,.5,0),Vector3.ONE,Color("c3aa82"));ring(n,Vector3(0,.5,0),.8,Color("cabba2")).rotation.z=.3
		"atom_model":
			for i in range(8):s(n,Vector3(sin(i*2.4)*.1,.6+cos(i*2.4)*.1,sin(i)*.1),Vector3.ONE*.14,RED if i%2==0 else BLUE)
			for i in range(3):ring(n,Vector3(0,.6,0),.5,METAL).rotation=Vector3(i*PI/3,0,i*PI/3);s(n,Vector3(sin(i)*.5,.6,cos(i)*.5),Vector3.ONE*.07,Color("d1b261"))
		"compass","stopwatch":
			c(n,Vector3(0,.07,0),.4,.12,METAL);c(n,Vector3(0,.139,0),.35,.008,CREAM)
			for i in range(12):l(n,Vector3(sin(i*TAU/12)*.29,.15,cos(i*TAU/12)*.29),Vector3(sin(i*TAU/12)*.33,.15,cos(i*TAU/12)*.33),.005,DARK)
			l(n,Vector3(0,.155,0),Vector3(.13,.155,-.23),.016,RED);l(n,Vector3(0,.155,0),Vector3(-.13,.155,.23),.016,DARK)
			if k=="stopwatch":c(n,Vector3(0,.07,-.48),.07,.09,METAL).rotation.x=PI/2
		"scale":
			b(n,Vector3(0,.05,0),Vector3(.85,.1,.6),CREAM);b(n,Vector3(0,.113,0),Vector3(.7,.012,.44),METAL)
			b(n,Vector3(0,.121,-.17),Vector3(.2,.005,.09),BLUE);tag(n,"0.0",Vector3(0,.14,-.17),.0018).rotation_degrees.x=-90
		"calendar":
			b(n,Vector3(0,.6,0),Vector3(.9,1.2,.03),CREAM);b(n,Vector3(0,1.11,-.02),Vector3(.9,.16,.015),RED)
			for i in range(35):b(n,Vector3(-.36+(i%7)*.12,.19+int(i/7)*.17,-.023),Vector3(.055,.048,.005),DARK)
			for x in [-.3,.3]:ring(n,Vector3(x,1.23,0),.045,METAL).rotation.x=PI/2
		"postcard","canvas","blackboard":
			b(n,Vector3(0,.45,0),Vector3(1,.75,.05),WOOD)
			b(n,Vector3(0,.45,-.033),Vector3(.9,.65,.009),DARK if k=="blackboard" else CREAM)
			if k=="blackboard":tag(n,"A B C\n1 + 2 = 3",Vector3(0,.46,-.043),.004)
			else:
				s(n,Vector3(.25,.6,-.04),Vector3(.16,.16,.006),Color("d9bb61"));b(n,Vector3(0,.28,-.04),Vector3(.84,.22,.006),GREEN);c(n,Vector3(-.16,.4,-.045),.19,.35,BLUE,0).rotation.x=PI/2
		"clipboard":
			b(n,Vector3(0,.5,0),Vector3(.7,1,.035),WOOD);b(n,Vector3(0,.49,-.024),Vector3(.6,.83,.009),CREAM);b(n,Vector3(0,.97,-.025),Vector3(.3,.13,.045),METAL)
			for i in range(6):b(n,Vector3(0,.2+i*.1,-.031),Vector3(.45,.006,.003),DARK)
		"folder":
			b(n,Vector3(0,.025,0),Vector3(.9,.04,.7),Color("c9ac70"));b(n,Vector3(-.28,.03,-.39),Vector3(.34,.035,.13),Color("c9ac70"));b(n,Vector3(0,.052,0),Vector3(.8,.006,.6),CREAM)
		"backpack":
			s(n,Vector3(0,.45,0),Vector3(.7,.9,.3),BLUE);b(n,Vector3(0,.27,-.21),Vector3(.5,.32,.12),BLUE.darkened(.13));l(n,Vector3(-.2,.44,-.28),Vector3(.2,.44,-.28),.008,METAL)
			for side in [-1,1]:curve(n,[Vector3(side*.2,.76,.14),Vector3(side*.28,.45,.28),Vector3(side*.2,.15,.14)],.026,DARK)
			ring(n,Vector3(0,.91,0),.13,DARK).rotation.x=PI/2
		"lunchbox":
			b(n,Vector3(0,.2,0),Vector3(.8,.35,.4),BLUE);b(n,Vector3(0,.39,0),Vector3(.82,.06,.42),BLUE.lightened(.2));ring(n,Vector3(0,.47,0),.12,DARK).rotation.x=PI/2
			for x in [-.24,.24]:b(n,Vector3(x,.31,-.215),Vector3(.07,.1,.02),METAL)

static func lifestyle(n:Node3D,k:String,col:Color)->void:
	match k:
		"shirt","t_shirt","jacket","coat","sweater","dress","life_jacket":
			var length=1.1 if k in ["coat","dress"] else .74
			lathe(n,[Vector2(.35,.15),Vector2(.3,.15+length),Vector2(.16,.3+length),Vector2(.13,.3+length),Vector2(.25,.15+length),Vector2(.3,.15)],col).scale=Vector3(1,1,.43)
			for side in [-1,1]:
				l(n,Vector3(side*.28,.12+length,0),Vector3(side*(.49 if k in ["t_shirt","life_jacket"] else .59),length*(.65 if k in ["t_shirt","life_jacket"] else .25),0),.09,col)
				if k in ["shirt","jacket","coat"]:b(n,Vector3(side*.09,.15+length,-.14),Vector3(.1,.1,.012),CREAM).rotation.z=side*.45
			if k in ["shirt","jacket","coat"]:
				for i in range(5):s(n,Vector3(0,.3+i*length*.15,-.15),Vector3.ONE*.025,CREAM)
			if k in ["jacket","coat"]:
				for side in [-1,1]:b(n,Vector3(side*.18,.35,-.155),Vector3(.16,.15,.025),col.darkened(.12))
			if k=="life_jacket":
				for side in [-1,1]:b(n,Vector3(side*.18,.54,-.19),Vector3(.24,.64,.17),Color("d69943"))
				for y in [.37,.65]:b(n,Vector3(0,y,-.285),Vector3(.6,.045,.015),DARK)
			if k=="sweater":
				for i in range(8):b(n,Vector3(0,.22+i*.065,-.155),Vector3(.52,.009,.006),col.lightened(.12))
		"skirt":lathe(n,[Vector2(.48,0),Vector2(.28,.75),Vector2(.25,.75),Vector2(.45,0)],col)
		"trousers","shorts":
			var length=.95 if k=="trousers" else .45
			b(n,Vector3(0,length,0),Vector3(.55,.22,.24),col)
			for side in [-1,1]:
				lathe(n,[Vector2(.12,0),Vector2(.14,length),Vector2(.12,length),Vector2(.1,0)],col).position.x=side*.145
				b(n,Vector3(side*.15,length-.08,-.133),Vector3(.14,.17,.015),col.darkened(.1))
			b(n,Vector3(0,length+.075,-.13),Vector3(.06,.03,.015),METAL)
		"sandal","slipper","sock","shoe","boot":
			s(n,Vector3(0,.045,.13),Vector3(.37,.075,.78),DARK)
			if k=="sandal":
				for z in [.1,.32]:curve(n,[Vector3(-.17,.08,z),Vector3(-.1,.22,z),Vector3(.1,.22,z),Vector3(.17,.08,z)],.025,WOOD)
				curve(n,[Vector3(-.16,.1,-.13),Vector3(0,.32,-.2),Vector3(.16,.1,-.13)],.026,WOOD)
			elif k=="sock":
				s(n,Vector3(0,.12,.12),Vector3(.33,.22,.62),CREAM);lathe(n,[Vector2(.13,.13),Vector2(.13,.65),Vector2(.1,.65),Vector2(.1,.13)],CREAM)
			else:
				s(n,Vector3(0,.17,.12),Vector3(.34,.27,.62),col)
				if k=="slipper":b(n,Vector3(0,.245,-.16),Vector3(.24,.012,.24),DARK)
				elif k=="boot":lathe(n,[Vector2(.16,.14),Vector2(.16,.72),Vector2(.13,.72),Vector2(.13,.14)],WOOD)
				else:for i in range(5):l(n,Vector3(-.1,.29,-.12+i*.055),Vector3(.1,.29,-.1+i*.055),.008,CREAM)
		"hat","cap":
			if k=="hat":lathe(n,[Vector2(0,0),Vector2(.55,0),Vector2(.55,.035),Vector2(.32,.05),Vector2(.32,.4),Vector2(.28,.45),Vector2(0,.45)],WOOD)
			else:
				s(n,Vector3(0,.19,0),Vector3(.66,.38,.64),BLUE);s(n,Vector3(0,.04,-.37),Vector3(.55,.06,.44),BLUE)
		"belt":
			lathe(n,[Vector2(.4,0),Vector2(.44,0),Vector2(.44,.08),Vector2(.4,.08),Vector2(.4,0)],WOOD);b(n,Vector3(0,.04,-.45),Vector3(.17,.12,.035),METAL);b(n,Vector3(0,.04,-.47),Vector3(.1,.07,.007),DARK)
		"scarf":
			cloth(n,Vector3(0,.04,0),Vector3(.3,.05,1.5),RED)
			for side in [-1,1]:for i in range(9):l(n,Vector3(-.12+i*.03,.04,side*.74),Vector3(-.12+i*.03,.04,side*.83),.008,RED)
		"watch":
			b(n,Vector3(0,.05,0),Vector3(.24,.06,1),WOOD);c(n,Vector3(0,.11,0),.21,.09,METAL);c(n,Vector3(0,.162,0),.18,.01,CREAM)
			l(n,Vector3(0,.18,0),Vector3(0,.18,-.13),.006,DARK);l(n,Vector3(0,.18,0),Vector3(.1,.18,.03),.008,DARK)
		"wallet":
			b(n,Vector3(0,.08,0),Vector3(.6,.12,.4),WOOD.darkened(.15));b(n,Vector3(0,.15,0),Vector3(.56,.02,.36),WOOD)
			for i in range(3):b(n,Vector3(.12,.165+i*.007,0),Vector3(.24,.005,.15),[CREAM,BLUE,RED][i])
		"combination_lock":
			b(n,Vector3(0,.25,0),Vector3(.46,.4,.17),METAL);ring(n,Vector3(0,.57,0),.17,METAL).rotation.x=PI/2
			for i in range(3):c(n,Vector3(-.14+i*.14,.25,-.105),.055,.04,DARK).rotation.x=PI/2;tag(n,str(i+1),Vector3(-.14+i*.14,.25,-.132),.0015)
		"flute":
			l(n,Vector3(-.6,.1,0),Vector3(.6,.1,0),.027,METAL)
			for i in range(8):s(n,Vector3(-.36+i*.09,.13,0),Vector3(.025,.008,.025),DARK)
		"trumpet":
			curve(n,[Vector3(-.5,.4,0),Vector3(.4,.4,0),Vector3(.5,.2,0),Vector3(-.25,.2,0),Vector3(-.35,.1,0),Vector3(.35,.1,0)],.032,Color("c4ab68"))
			lathe(n,[Vector2(.03,0),Vector2(.1,.2),Vector2(.22,.35),Vector2(.19,.35),Vector2(.065,.2),Vector2(.015,0)],Color("c4ab68")).rotation.z=-PI/2
			for i in range(3):l(n,Vector3(-.1+i*.13,.2,0),Vector3(-.1+i*.13,.53,0),.022,METAL)
		"violin":
			for y in [.25,.52]:s(n,Vector3(0,y,0),Vector3(.42,.34,.11),WOOD)
			l(n,Vector3(0,.6,0),Vector3(0,1.12,0),.035,WOOD);b(n,Vector3(0,.6,-.068),Vector3(.07,.55,.025),DARK)
			for i in range(4):l(n,Vector3(-.025+i*.017,.2,-.07),Vector3(-.025+i*.017,1.1,-.07),.002,METAL)
			for side in [-1,1]:curve(n,[Vector3(side*.1,.28,-.063),Vector3(side*.12,.38,-.063),Vector3(side*.08,.47,-.063)],.01,DARK)
			l(n,Vector3(.43,.1,0),Vector3(.43,1.05,0),.008,WOOD)
		"accordion":
			b(n,Vector3(0,.45,0),Vector3(.65,.7,.3),RED)
			for i in range(12):b(n,Vector3(-.28+i*.05,.45,-.18),Vector3(.016,.69,.08),DARK)
			for side in [-1,1]:b(n,Vector3(side*.43,.45,0),Vector3(.23,.75,.4),DARK)
			for i in range(10):b(n,Vector3(.43,.13+i*.064,-.215),Vector3(.2,.059,.025),CREAM)
		"scooter":
			b(n,Vector3(0,.15,0),Vector3(.2,.07,.9),METAL)
			for z in [-.43,.43]:c(n,Vector3(0,.12,z),.12,.075,DARK).rotation.z=PI/2
			l(n,Vector3(0,.15,-.43),Vector3(0,1.15,-.5),.025,METAL);l(n,Vector3(-.28,1.15,-.5),Vector3(.28,1.15,-.5),.025,DARK)
		"surfboard":
			s(n,Vector3(0,.05,0),Vector3(.52,.09,1.8),BLUE);b(n,Vector3(0,.105,0),Vector3(.035,.006,1.6),CREAM);b(n,Vector3(0,.16,.59),Vector3(.025,.22,.18),DARK)
		"basketball_hoop":
			l(n,Vector3.ZERO,Vector3(0,1.7,0),.045,METAL);b(n,Vector3(0,1.5,0),Vector3(1.1,.75,.06),CREAM)
			b(n,Vector3(0,1.43,-.04),Vector3(.4,.3,.012),BLUE);ring(n,Vector3(0,1.2,-.36),.28,RED)
			for i in range(12):l(n,Vector3(sin(i*TAU/12)*.25,1.2,-.36+cos(i*TAU/12)*.25),Vector3(sin(i*TAU/12)*.16,.87,-.36+cos(i*TAU/12)*.16),.005,CREAM)
		"football_goal":
			curve(n,[Vector3(-.8,0,0),Vector3(-.8,1.1,0),Vector3(.8,1.1,0),Vector3(.8,0,0)],.035,CREAM)
			for i in range(12):l(n,Vector3(-.8+i*.145,1.1,0),Vector3(-.8+i*.145,0,.55),.005,CREAM)
			for i in range(9):l(n,Vector3(-.8,i*.12,.55-i*.06),Vector3(.8,i*.12,.55-i*.06),.005,CREAM)
		"flag":
			l(n,Vector3.ZERO,Vector3(0,1.5,0),.022,METAL)
			var mesh=PlaneMesh.new();mesh.orientation=PlaneMesh.FACE_Z;mesh.size=Vector2(.8,.5)
			var flag=MeshInstance3D.new();flag.mesh=mesh;flag.position=Vector3(.4,1.17,0)
			var mat=StandardMaterial3D.new();mat.albedo_texture=load("res://assets/kurdistan_flag.svg");mat.cull_mode=BaseMaterial3D.CULL_DISABLED;flag.material_override=mat;n.add_child(flag)

static func merge_shapes(root:Node3D)->void:
	var groups={};var nodes=[];collect(root,Transform3D.IDENTITY,groups,nodes)
	for group in groups.values():
		var node=MeshInstance3D.new();node.mesh=group.builder.commit();node.material_override=group.material;root.add_child(node)
	for node in nodes:node.get_parent().remove_child(node);node.free()
static func collect(root:Node3D,transform:Transform3D,groups:Dictionary,nodes:Array)->void:
	for child in root.get_children():
		if not child is Node3D:continue
		var trans=transform*child.transform
		if child is MeshInstance3D and child.mesh!=null:
			var mat=child.material_override
			if mat==null:continue
			for surface in range(child.mesh.get_surface_count()):
				# Generated pottery and imported primitives can have different vertex layouts.
				# Separate layouts so batching never drops a vessel or clothing body.
				var vertex_format=str(child.mesh.surface_get_format(surface)) if child.mesh is ArrayMesh else "primitive"
				var key=str(mat.get_instance_id())+":"+vertex_format
				if not groups.has(key):
					var builder=SurfaceTool.new();builder.begin(Mesh.PRIMITIVE_TRIANGLES);groups[key]={"builder":builder,"material":mat}
				groups[key].builder.append_from(child.mesh,surface,trans)
			nodes.append(child)
		else:collect(child,trans,groups,nodes)

static func building_identity(n:Node3D,k:String,dims:Vector3)->void:
	var p=Vector3(0,dims.y*.68,-dims.z*.5-.025)
	b(n,p,Vector3(dims.x*.6,dims.y*.12,.055),BLUE if k=="school" else CREAM if k=="hospital" else RED)
	var title=tag(n,k.to_upper(),p+Vector3(0,0,-.045),dims.x*.0005);title.rotation.y=PI;title.modulate=DARK if k=="hospital" else CREAM
	if k=="hospital":
		var cpos=Vector3(dims.x*.32,dims.y*.87,-dims.z*.5-.05)
		b(n,cpos,Vector3(dims.x*.1,dims.y*.03,.055),RED);b(n,cpos,Vector3(dims.x*.03,dims.y*.1,.055),RED)
	if k=="shop":
		var awning=b(n,Vector3(0,dims.y*.33,-dims.z*.5-.32),Vector3(dims.x*.8,.08,.7),CREAM)
		for i in range(8):b(n,awning.position+Vector3(-dims.x*.35+i*dims.x*.1,-.06,-.26),Vector3(dims.x*.08,.16,.16),RED)
