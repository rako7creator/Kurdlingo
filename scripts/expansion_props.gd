class_name ExpansionProps
extends RefCounted

const W=Color("a97c50")
const M=Color("bac9cc")
const D=Color("344854")
const G=Color("789663")
const C=Color("f2e7cb")
const B=Color("72b9c8")
static var used_forms:Dictionary={}

static func box(n:Node3D,p:Vector3,s:Vector3,c:Color=C)->void:WorldProps.box(n,p,s,c)
static func ball(n:Node3D,p:Vector3,s:Vector3,c:Color=C)->void:WorldProps.sphere(n,p,s,c)
static func rod(n:Node3D,a:Vector3,b:Vector3,r:float=.035,c:Color=M)->void:WorldProps.line(n,a,b,r,c)
static func cyl(n:Node3D,p:Vector3,r:float,h:float,c:Color=M)->void:WorldProps.cylinder(n,p,r,h,c)
static func ring(n:Node3D,p:Vector3,r:float,c:Color=M)->void:AnnexProps.ring(n,p,r,c)
static func label(n:Node3D,text:String,p:Vector3)->void:AccurateProps.tag(n,text,p,.0025)

static func make(form:String,id:String)->Node3D:
	used_forms[form]=true
	var n=Node3D.new();var color=Color.from_hsv(float(absi(id.hash())%100)/100,.38,.78)
	var exact={"book":"book","folder":"folder","map":"map","pen":"pen","brush":"paintbrush","bottle":"water","compass":"compass","axe":"axe","clock":"clock","clothing":"shirt","vest":"life_jacket","boots":"boot","bag":"backpack","gloves":"glove","cap":"cap","tree":"tree","bird":"pigeon","goat":"goat","marmot":"squirrel","dolphin":"dolphin","walrus":"seal","dugong":"seal","manatee":"seal","squid":"octopus","eel":"snake","helmet":"hat","trowel":"shovel","bench":"bench","basket":"basket","goggles":"swimming_goggles"}
	if form=="chair":n.free();return TeacherCircle.classroom_chair(true)
	if id=="sleeping_bag":
		ball(n,Vector3(0,.17,0),Vector3(.75,.35,1.8),G);ring(n,Vector3(0,.25,-.65),.24,D);return n
	if form in ["cloth","poncho","curtain"]:
		if form=="poncho":n.add_child(AccurateProps.make("coat"));WorldProps.tint(n,col_or_rain(id));return n
		if form=="curtain" or id=="tapestry":
			for i in range(12):box(n,Vector3(-.6+i*.11,.65,sin(i)*.025),Vector3(.115,1.3,.05),color.darkened((i%2)*.05))
		else:AccurateProps.cloth(n,Vector3(0,.035,0),Vector3(1.2,.06,.9),color)
		return n
	if form=="tree":
		n.add_child(WorldProps.make("nature/tree_pineTallA" if id=="juniper" else "nature/tree_oak",2.5))
		if id in ["walnut_tree","mulberry_tree"]:
			for i in range(8):ball(n,Vector3(cos(i)*.5,1.2+sin(i)*.3,sin(i)*.5),Vector3.ONE*.07,W if id=="walnut_tree" else Color("935a7d"))
		return n
	if form=="bench":n.free();return WorldProps.make("furniture/bench",1.8)
	if form in exact:
		var key:String=exact[form]
		if key in AccurateProps.KEYS:n.add_child(AccurateProps.make(key))
		elif key in ["tree","bench","shovel"]:n.add_child(WorldProps.custom(key))
		else:n.add_child(AnnexProps.make(key))
		if form=="helmet":ball(n,Vector3(0,.45,0),Vector3(.9,.55,.9),G)
		if form=="walrus":
			for x in [-.12,.12]:rod(n,Vector3(.5,.3,x),Vector3(.5,-.15,x),.035,C)
		if form=="squid":ball(n,Vector3(0,.6,0),Vector3(.5,1.0,.35),color)
		if form=="gloves" and id in ["medical_gloves","space_gloves"]:WorldProps.tint(n,C)
		if form=="clothing" and id in ["uniform","white_coat","scrubs","space_suit"]:WorldProps.tint(n,G if id=="uniform" else B if id=="scrubs" else C)
		if form=="goat" and id=="ibex":
			for z in [-.18,.18]:rod(n,Vector3(.65,1,z),Vector3(.1,1.75,z),.065,W)
		return n
	match form:
		"buoy":
			ball(n,Vector3(0,.25,0),Vector3(.75,.5,.75),Color("dd8d69"));cyl(n,Vector3(0,.7,0),.07,.8,M);ring(n,Vector3(0,1.1,0),.1,M)
		"person":
			n.add_child(TeacherCircle.person(false,absi(id.hash())%5))
			if id in ["soldier","officer","commander"]:
				ball(n,Vector3(0,1.96,0),Vector3(.55,.2,.49),G);box(n,Vector3(0,1.15,-.18),Vector3(.48,.55,.025),G)
			elif id in ["doctor","nurse","dentist","pharmacist","paramedic"]:
				box(n,Vector3(0,1.07,-.18),Vector3(.45,.65,.03),C);medical_cross(n,Vector3(.12,1.3,-.205),.15)
			elif id in ["baker","pastry_chef"]:
				cyl(n,Vector3(0,2,0),.28,.32,C);box(n,Vector3(0,1,-.19),Vector3(.4,.6,.03),C)
		"truck","armored","tank","bus","minibus","van","pickup","laddertruck","garbage","sweeper","snowplow","forklift","excavator","bulldozer","roller","mixertruck","tow","tanker","car","rickshaw","rover":vehicle(n,form,id)
		"locomotive","carriage","wagon","tram","metro","monorail","funicular","cablecar":
			vehicle(n,"bus",id);box(n,Vector3(0,.08,0),Vector3(2.6,.08,1.3),M)
			if form=="locomotive":cyl(n,Vector3(.4,1.4,0),.12,.4,D)
			if form=="cablecar":rod(n,Vector3(0,1.4,0),Vector3(0,2.3,0),.05);box(n,Vector3(0,2.3,0),Vector3(1,.07,.4),D)
		"jet","plane","helicopter","shuttle":
			ball(n,Vector3(0,.55,0),Vector3(2.4,.55,.6),M);ball(n,Vector3(.7,.7,0),Vector3(.6,.35,.55),B)
			box(n,Vector3(-.7,.75,0),Vector3(.4,.5,.07),D)
			if form=="helicopter":
				box(n,Vector3(0,1.1,0),Vector3(2.5,.035,.09),D);box(n,Vector3(0,1.1,0),Vector3(.09,.035,2.2),D)
				for z in [-.4,.4]:rod(n,Vector3(-.6,.06,z),Vector3(.7,.06,z),.04,D)
			else:box(n,Vector3(-.1,.5,0),Vector3(.45,.07,2.4),color)
		"boat","sailboat","ferry","ship","kayak","canoe":
			ball(n,Vector3(0,.24,0),Vector3(2.8,.55,.85),color);box(n,Vector3(0,.41,0),Vector3(1.6,.09,.64),W)
			if form=="sailboat":
				rod(n,Vector3(0,.45,0),Vector3(0,2.2,0),.04,W);var sail=WorldProps.box(n,Vector3(.4,1.4,0),Vector3(.8,1.3,.025),C);sail.rotation.z=-.15
			elif form in ["ferry","ship"]:
				box(n,Vector3(.2,.8,0),Vector3(1.4,.6,.6),C);box(n,Vector3(.35,.87,-.32),Vector3(.6,.25,.025),B)
				if form=="ship":
					for i in range(3):box(n,Vector3(-.8+i*.45,.65,0),Vector3(.4,.35,.58),color.darkened(i*.08))
		"building","room","cabin","station","harbor","booth","shelter":building(n,form,id,color)
		"tower","lighthouse":
			cyl(n,Vector3(0,1.2,0),.45,2.4,C);cyl(n,Vector3(0,1.2,0),.46,.3,color);box(n,Vector3(0,2.4,0),Vector3(1,.15,1),W)
			if form=="lighthouse":cyl(n,Vector3(0,2.68,0),.32,.45,B);WorldProps.cylinder(n,Vector3(0,3,0),.55,.3,D,0)
			else:box(n,Vector3(0,2.8,0),Vector3(.9,.6,.9),G)
		"tent","greenhouse","dome":
			if form=="dome":ball(n,Vector3(0,.3,0),Vector3(2.5,2,2.5),M);box(n,Vector3(.0,.65,-1),Vector3(.4,1,.5),D)
			else:
				for side in [-1,1]:
					var roof=WorldProps.box(n,Vector3(side*.48,.9,0),Vector3(1.3,.08,1.8),B if form=="greenhouse" else G);roof.rotation.z=-side*.7
					if form=="greenhouse":
						box(n,Vector3(side*.88,.3,0),Vector3(.035,.6,1.8),B)
						for z in [-.85,-.3,.3,.85]:rod(n,Vector3(side*.88,0,z),Vector3(side*.88,.65,z),.018,C);rod(n,Vector3(side*.88,.65,z),Vector3(0,1.3,z),.018,C)
				box(n,Vector3(0,.35,.85),Vector3(1.6,.7,.035),B if form=="greenhouse" else G)
				for side in [-1,1]:box(n,Vector3(side*.88,.3,0),Vector3(.05,.6,1.8),B if form=="greenhouse" else G)
				if form=="tent":box(n,Vector3(0,.38,-.83),Vector3(.45,.76,.035),D)
		"mirror":box(n,Vector3(0,.6,0),Vector3(.7,1.2,.06),M);box(n,Vector3(0,.6,-.04),Vector3(.6,1.1,.01),B)
		"bell":WorldProps.cylinder(n,Vector3(0,.4,0),.4,.6,Color("c9ad68"),.15);ring(n,Vector3(0,.73,0),.08,M)
		"flower","bud","petal","pollen","stem","root","seedling","fern","moss","ivy","hedge","flowerbed","seaweed":plant(n,form,id,color)
		"arch","pergola","gate","airlock":
			for x in [-.8,.8]:box(n,Vector3(x,1.15,0),Vector3(.13,2.3,.13),W)
			box(n,Vector3(0,2.3,0),Vector3(1.9,.13,.2),W)
			if form=="pergola":
				for z in range(5):box(n,Vector3(0,2.35,-.8+z*.4),Vector3(2,.08,.09),W)
			if form=="gate":
				for i in range(8):box(n,Vector3(-.7+i*.2,1,0),Vector3(.07,1.65,.07),M)
		"birdbath","feeder","well":
			cyl(n,Vector3(0,.4,0),.17,.8,W);cyl(n,Vector3(0,.83,0),.6,.13,C);cyl(n,Vector3(0,.9,0),.47,.018,B)
			if form=="well":ring(n,Vector3(0,.88,0),.65,W);rod(n,Vector3(-.6,1,0),Vector3(-.6,1.8,0));rod(n,Vector3(.6,1,0),Vector3(.6,1.8,0));box(n,Vector3(0,1.8,0),Vector3(1.6,.1,1.2),W)
		"honeycomb","insecthotel":
			box(n,Vector3(0,.4,0),Vector3(1,.8,.2),W)
			for i in range(12):ring(n,Vector3(-.36+i%4*.24,.16+int(i/4)*.24,-.15),.105,Color("e8bb63"))
		"caterpillar":
			for i in range(6):ball(n,Vector3(-.6+i*.23,.18,0),Vector3(.3,.3,.3),G)
			for z in [-.09,.09]:ball(n,Vector3(.66,.25,z),Vector3.ONE*.05,D)
		"dragonfly":
			rod(n,Vector3(-.5,.2,0),Vector3(.4,.2,0),.05,B)
			for side in [-1,1]:
				for x in [-.12,.14]:ball(n,Vector3(x,.24,side*.3),Vector3(.18,.035,.65),C)
		"rock","stone","cliff","mountain","valley","ravine","cave","crater","asteroid","meteor","footprint","clay":terrain(n,form,color)
		"waterfall","spring","stream","glacier":
			terrain(n,"cliff",Color("7b9290"));box(n,Vector3(0,.7,-.26),Vector3(.4,1.4,.1),B);ball(n,Vector3(0,.04,-.6),Vector3(1.5,.06,.7),B)
		"crystal","stalactite","stalagmite","icicle":
			for i in range(4):
				var tip=WorldProps.cylinder(n,Vector3(-.3+i*.2,.35+i*.08,0),.16,.7+i*.16,color if form=="crystal" else C,0);tip.rotation.z=(i-2)*.15
		"snowflake":
			for i in range(6):rod(n,Vector3.ZERO,Vector3(cos(i*TAU/6),.01,sin(i*TAU/6))*.5,.015,C)
		"bridge","pier","platform","track","crossing","stage":
			for i in range(12):box(n,Vector3(-1.1+i*.2,.16,0),Vector3(.18,.1,1),W)
			for z in [-.52,.52]:rod(n,Vector3(-1.2,.55,z),Vector3(1.2,.55,z),.035,M)
			if form in ["track","crossing"]:
				for z in [-.32,.32]:box(n,Vector3(0,.24,z),Vector3(2.5,.05,.04),M)
		"watermill":building(n,"cabin",id,W);var wheel=AnnexProps.ring(n,Vector3(1,.7,0),.7,W);wheel.rotation.x=PI/2
		"dentist","seat":
			cyl(n,Vector3(0,.2,0),.2,.4,M);box(n,Vector3(0,.5,0),Vector3(.6,.12,.65),B);var back=WorldProps.box(n,Vector3(0,.8,.38),Vector3(.6,.65,.12),B);back.rotation.x=-.4;box(n,Vector3(0,.37,-.5),Vector3(.5,.09,.55),B)
		"bed":
			box(n,Vector3(0,.48,0),Vector3(.8,.12,1.8),M);box(n,Vector3(0,.57,0),Vector3(.76,.12,1.7),C);box(n,Vector3(0,.66,.6),Vector3(.6,.15,.3),B)
			for x in [-.3,.3]:
				for z in [-.7,.7]:rod(n,Vector3(x,.05,z),Vector3(x,.5,z),.045,M)
		"wheelchair","trolley","cart","walker","crutch":
			box(n,Vector3(0,.6,0),Vector3(.8,.1,.8),M)
			for x in [-.45,.45]:
				rod(n,Vector3(x,0,0),Vector3(x,1,0),.035,M)
				var wh=AnnexProps.ring(n,Vector3(x,.3,0),.3,D);wh.rotation.z=PI/2
			if form=="wheelchair":box(n,Vector3(0,.92,.38),Vector3(.75,.65,.08),B)
		"desk","console","kitchen","plinth","potter","loom":
			box(n,Vector3(0,.7,0),Vector3(1.4,.12,.8),W)
			for x in [-.58,.58]:
				for z in [-.3,.3]:rod(n,Vector3(x,.05,z),Vector3(x,.7,z),.045,W)
			if form=="console":box(n,Vector3(0,.94,0),Vector3(.9,.4,.2),D);box(n,Vector3(0,.95,-.11),Vector3(.75,.3,.02),B)
			if form=="potter":cyl(n,Vector3(0,.82,0),.42,.04,M);cyl(n,Vector3(0,.95,0),.14,.2,W)
			if form=="loom":
				for i in range(15):rod(n,Vector3(-.5+i*.07,.75,0),Vector3(-.5+i*.07,1.7,0),.006,C)
				box(n,Vector3(0,1.7,0),Vector3(1.25,.06,.1),W)
		"bookshelf","rack":
			for x in [-.6,.6]:box(n,Vector3(x,1,0),Vector3(.08,2,.45),W)
			for y in [.2,.7,1.2,1.8]:box(n,Vector3(0,y,0),Vector3(1.2,.07,.45),W)
			if form=="bookshelf":
				for i in range(14):box(n,Vector3(-.5+i%7*.16,.44+int(i/7)*.5,0),Vector3(.1,.4,.3),color.darkened((i%3)*.1))
		"board","screen","chart","painting","mosaic","glass","frame","curtain","solar","panel","map","cloth","poncho":
			box(n,Vector3(0,.7,0),Vector3(1.25,1.35,.065),W);box(n,Vector3(0,.7,-.043),Vector3(1.12,1.22,.02),B if form in ["screen","panel","solar"] else C)
			for i in range(9):box(n,Vector3(-.43+i%3*.4,.3+int(i/3)*.4,-.059),Vector3(.23,.23,.01),color.darkened((i%3)*.13))
			if form in ["chart","board"]:label(n,id.replace("_"," ").to_upper(),Vector3(0,1.2,-.065))
		"easel":
			for x in [-.5,.5]:rod(n,Vector3(x,0,0),Vector3(x*.3,1.6,0),.045,W)
			rod(n,Vector3(0,1.4,0),Vector3(0,0,.6),.04,W);box(n,Vector3(0,1,-.03),Vector3(.9,.8,.07),C)
		"tankwater","barrel","container","jar","vase","jug","cylinder","oxygen","yeast","sugar","cotton","gauze","bowl","custard","oil","packet","crate","compost","kit","case","trap","bin":container(n,form,id,color)
		"monitor","calculator","projector","camera","tablet","usb","printer","scanner","machine","meter","charger","generator","radio","xray","spectroscope","gravity","defibrillator","cooler","dashboard":device(n,form,id,color)
		"dish","radar","antenna","lamp","stand","robotarm","stethoscope","gyroscope","sprinkler":
			cyl(n,Vector3(0,.06,0),.3,.12,D);rod(n,Vector3(0,.1,0),Vector3(0,1.2,0),.04,M)
			if form in ["dish","radar"]:
				ball(n,Vector3(0,1.3,0),Vector3(1,.12,1),C);rod(n,Vector3(0,1.3,0),Vector3(0,1.7,0),.025,D)
			elif form=="lamp":ball(n,Vector3(0,1.2,0),Vector3(.3,.4,.3),Color("f5cf79"))
			elif form=="robotarm":rod(n,Vector3(0,1.1,0),Vector3(.65,1.5,0),.07,M);rod(n,Vector3(.65,1.5,0),Vector3(.9,1,0),.055,M)
			elif form=="stethoscope":
				ring(n,Vector3(0,.8,0),.3,D);rod(n,Vector3(0,.5,0),Vector3(.3,.1,0),.03,D);cyl(n,Vector3(.3,.1,0),.1,.04,M)
			elif form=="gyroscope":
				for i in range(3):var rim=AnnexProps.ring(n,Vector3(0,.8,0),.4,M);rim.rotation=Vector3(i*.6,i*.5,0)
			else:rod(n,Vector3(-.3,1.1,0),Vector3(.3,1.1,0),.025,M)
		"engine","booster","capsule","probe","launch":
			cyl(n,Vector3(0,.7,0),.3,1.4,C);WorldProps.cylinder(n,Vector3(0,1.6,0),.3,.4,M,0)
			for i in range(3):box(n,Vector3(cos(i*TAU/3)*.27,.18,sin(i*TAU/3)*.27),Vector3(.16,.35,.3),color)
		"planet","galaxy","nebula","comet":
			var colors={"mercury":"a59c8c","venus":"d6b777","earth":"5c95bb","mars":"be6d52","jupiter":"d4b28d","saturn":"dbbe8c","uranus":"8bd1d3","neptune":"557cd0","pluto":"a39484"};var col=Color(colors.get(id,"b698ce"))
			ball(n,Vector3(0,.6,0),Vector3.ONE,col)
			if id=="saturn" or form=="galaxy":ring(n,Vector3(0,.6,0),.9,C)
			if id=="earth":
				for i in range(5):ball(n,Vector3(cos(i)*.38,.5+sin(i)*.3,-.3),Vector3(.25,.18,.1),G)
			if form=="comet":rod(n,Vector3(.4,.6,0),Vector3(1.4,.95,0),.09,B)
		"fish","narwhal","ray","swordfish","tuna","salmon","shrimp","pelican","shell","oyster","barnacle","urchin","anemone","coral","pearl":sea_creature(n,form,id,color)
		"loaf","bread","flatbread","pita","naan","pastry","pretzel","bagel","brioche","roll","donut","scone","macaron","cake","tart","pie","baklava","kunafa","cookie","brownie","meringue","candy","chips":food(n,form,color)
		"oven","kiln","mixer","stove":
			box(n,Vector3(0,.6,0),Vector3(1.15,1.2,.9),C);box(n,Vector3(0,.6,-.46),Vector3(.9,.65,.03),D);box(n,Vector3(0,1.03,-.49),Vector3(.7,.07,.045),M)
			if form=="mixer":ball(n,Vector3(0,.6,-.6),Vector3(.6,.45,.6),M);rod(n,Vector3(0,1,-.5),Vector3(0,.6,-.5),.05,M)
		"tire","wheel","ring","lifering","reel","hoop","yarn","beads","spindle","tube","rope","wire","net","harness","belt","bandage","anchor","hook","clip":round_tool(n,form,color)
		"rifle","oar","rod","stick","needle","crampon","shears","hammer","syringe","inhaler","tooth","heart","lungs","skeleton","mask","hearing","oximeter","sieve","tray","tin","palette","triangle","blocks","tag","card","badge","medal","bookmark","passport","tape","chalk","punch","bust","statue","carving","origami","puppet","parachute","sandbag","obstacle","shield","flare","wood","nest","fire","blister","blisterpack","piping","scraper","cutter","pen","bollard","barrier","escalator","motorcycle","scooter","tricycle","unicycle":small_object(n,form,id,color)
		_:
			push_error("Expansion form is missing: "+form+" / "+id)
			return null
	return n

static func medical_cross(n:Node3D,p:Vector3,size:float)->void:
	box(n,p,Vector3(size,size*.3,.018),Color("bf6960"));box(n,p,Vector3(size*.3,size,.018),Color("bf6960"))

static func col_or_rain(_id:String)->Color:return Color("d0aa62")

static func vehicle(n:Node3D,f:String,id:String)->void:
	var col=G if id in ["army_truck","tank","armored_vehicle"] else Color.from_hsv(float(absi(id.hash())%100)/100,.4,.72)
	box(n,Vector3(0,.5,0),Vector3(2.3,.45,1),col)
	box(n,Vector3(.55,.99,0),Vector3(.85,.6,.95),col);box(n,Vector3(.98,1.05,0),Vector3(.025,.35,.74),B)
	for x in [-.75,.75]:
		for z in [-.55,.55]:
			var tire=WorldProps.cylinder(n,Vector3(x,.28,z),.28,.18,D);tire.rotation.x=PI/2
	if f in ["tank","armored"]:
		for z in [-.5,.5]:box(n,Vector3(0,.24,z),Vector3(2.5,.4,.3),D)
		box(n,Vector3(-.15,.94,0),Vector3(.8,.4,.7),G)
		if f=="tank":rod(n,Vector3(0,1.05,0),Vector3(1.65,1.05,0),.07,G)
	elif f in ["bus","minibus","van","garbage","sweeper"]:
		box(n,Vector3(-.35,1,0),Vector3(1.6,.6,.95),col)
		for x in [-.8,-.35,.1]:box(n,Vector3(x,1.08,-.49),Vector3(.3,.3,.02),B)
	elif f in ["tanker","mixertruck"]:
		var drum=WorldProps.cylinder(n,Vector3(-.45,1,0),.45,1.5,M);drum.rotation.z=PI/2
	elif f=="laddertruck":
		for z in [-.16,.16]:rod(n,Vector3(-1,1.4,z),Vector3(1,1.4,z),.035,M)
		for i in range(9):rod(n,Vector3(-1+i*.25,1.4,-.16),Vector3(-1+i*.25,1.4,.16),.025,M)
	elif f in ["bulldozer","snowplow"]:box(n,Vector3(1.3,.35,0),Vector3(.12,.6,1.6),M)
	elif f in ["forklift","excavator","tow"]:
		rod(n,Vector3(.6,.7,0),Vector3(1.1,1.9,0),.085,col);rod(n,Vector3(1.1,1.9,0),Vector3(1.7,.7,0),.065,col);box(n,Vector3(1.7,.6,0),Vector3(.4,.4,.6),D)
	elif f=="roller":var roll=WorldProps.cylinder(n,Vector3(1,.3,0),.35,1.2,M);roll.rotation.x=PI/2
	if f=="rover":rod(n,Vector3(0,1.3,0),Vector3(0,1.9,0));box(n,Vector3(0,1.9,0),Vector3(.5,.2,.2),D)

static func building(n:Node3D,f:String,id:String,col:Color)->void:
	box(n,Vector3(0,.7,0),Vector3(2,1.4,1.6),col);box(n,Vector3(0,1.5,0),Vector3(2.3,.16,1.9),W)
	box(n,Vector3(0,.4,-.81),Vector3(.4,.8,.02),W)
	for x in [-.65,.65]:box(n,Vector3(x,.95,-.82),Vector3(.43,.4,.025),B)
	if "hospital" in id:medical_cross(n,Vector3(0,1.25,-.84),.35)
	label(n,id.replace("_"," ").to_upper(),Vector3(0,1.6,-.98))

static func plant(n:Node3D,f:String,id:String,col:Color)->void:
	if f in ["moss","hedge","flowerbed"]:
		for i in range(8):ball(n,Vector3(-.6+i%4*.4,.12+int(i/4)*.12,0),Vector3(.45,.3,.6),G)
	else:
		rod(n,Vector3.ZERO,Vector3(0,.8,0),.025,G)
		for side in [-1,1]:ball(n,Vector3(side*.17,.4,0),Vector3(.35,.1,.17),G)
	if f in ["flower","bud","petal","pollen","flowerbed"]:
		var palette={"tulip":"e88082","daffodil":"edcd65","lavender":"a18bc2","jasmine":"eee5d5","violet":"9a72bd","poppy":"d56b67","bluebell":"779ecb","snowdrop":"f1eee6","marigold":"eba25a"};var petal_col=Color(palette.get(id,col.to_html()))
		for i in range(6):
			var upright=id in ["tulip","snowdrop","bluebell","orchid"]
			ball(n,Vector3(cos(i*TAU/6)*.16,.8,sin(i*TAU/6)*.16),Vector3(.16,.28,.16) if upright else Vector3(.24,.075,.24),petal_col)
		if id in ["lavender","hyacinth"]:
			for i in range(6):ball(n,Vector3(0,.84+i*.065,0),Vector3(.13,.1,.13),petal_col)
		ball(n,Vector3(0,.83,0),Vector3.ONE*.16,Color("e5bd65"))
	if f in ["root","fern","ivy","seaweed"]:
		for i in range(7):rod(n,Vector3(0,i*.12,0),Vector3(sin(i*2)*.3,i*.12+.12,cos(i)*.15),.018,G)

static func terrain(n:Node3D,f:String,col:Color)->void:
	for i in range(5):
		var rock=WorldProps.sphere(n,Vector3(-.6+i*.3,.2+(.7 if f in ["mountain","cliff","cave"] else .12)*sin(i+.3),0),Vector3(.75,.65,.8),col.darkened((i%3)*.08));rock.rotation.y=i
	if f in ["cave","crater"]:ball(n,Vector3(0,.2,-.35),Vector3(.6,.6,.03),D)
	if f=="footprint":
		for i in range(3):ball(n,Vector3(-.18+i*.18,.35,-.35),Vector3(.12,.03,.3),D)

static func container(n:Node3D,f:String,id:String,col:Color)->void:
	if f in ["crate","compost","kit","case","packet","trap","bin"]:
		box(n,Vector3(0,.35,0),Vector3(.9,.7,.6),W if f in ["crate","compost"] else col)
		box(n,Vector3(0,.72,0),Vector3(.96,.05,.65),D)
		if f=="kit":medical_cross(n,Vector3(0,.35,-.31),.35)
		else:label(n,id.replace("_"," ").to_upper(),Vector3(0,.4,-.32))
	else:
		cyl(n,Vector3(0,.38,0),.3,.76,col);cyl(n,Vector3(0,.8,0),.31,.045,M)
		if f in ["bowl","custard","jug"]:cyl(n,Vector3(0,.82,0),.24,.01,C)
		if f=="jug":ring(n,Vector3(.32,.47,0),.17,M)
		if f=="vase":cyl(n,Vector3(0,.9,0),.15,.3,col)

static func device(n:Node3D,f:String,id:String,col:Color)->void:
	box(n,Vector3(0,.35,0),Vector3(1,.7,.6),col)
	box(n,Vector3(0,.47,-.31),Vector3(.73,.35,.025),D);box(n,Vector3(0,.48,-.33),Vector3(.58,.2,.01),B)
	for i in range(5):ball(n,Vector3(-.32+i*.16,.15,-.32),Vector3.ONE*.065,C)
	if f in ["camera","projector","spectroscope"]:
		var lens=WorldProps.cylinder(n,Vector3(0,.4,-.45),.16,.25,D);lens.rotation.x=PI/2
	if f=="xray":rod(n,Vector3(.65,0,0),Vector3(.65,1.5,0));box(n,Vector3(.4,1.4,0),Vector3(.5,.25,.3),M)
	label(n,id.replace("_"," ").to_upper(),Vector3(0,.68,-.34))

static func sea_creature(n:Node3D,f:String,id:String,col:Color)->void:
	if f in ["shell","oyster","barnacle","pearl"]:
		ball(n,Vector3(0,.2,0),Vector3(.8,.4,.7),C)
		if f!="pearl":
			for i in range(7):rod(n,Vector3(0,.25,.35),Vector3(-.35+i*.12,.3,-.25),.012,W)
	elif f in ["coral","anemone","urchin"]:
		ball(n,Vector3(0,.2,0),Vector3(.45,.4,.45),col)
		for i in range(12):rod(n,Vector3(0,.2,0),Vector3(cos(i)*.4,.5+sin(i)*.2,sin(i)*.4),.035,col)
	else:
		ball(n,Vector3(0,.35,0),Vector3(1.2,.45,.4),col);ball(n,Vector3(.45,.4,-.16),Vector3.ONE*.065,D)
		for side in [-1,1]:ball(n,Vector3(-.65,.35,side*.15),Vector3(.4,.05,.36),col)
		if f=="ray":ball(n,Vector3(0,.32,0),Vector3(.8,.06,1.6),col)
		if f in ["narwhal","swordfish"]:rod(n,Vector3(.55,.35,0),Vector3(1.3,.35,0),.025,C)
		if f=="pelican":n.add_child(AnimalModels.make("bird"));box(n,Vector3(.8,.7,0),Vector3(.5,.1,.13),Color("e4b869"))
		if f=="shrimp":
			for i in range(6):rod(n,Vector3(-.4+i*.16,.2,0),Vector3(-.4+i*.16,.05,.2),.013,col)

static func food(n:Node3D,f:String,col:Color)->void:
	var bread=Color("ce9e65")
	if f in ["bagel","donut","pretzel"]:ring(n,Vector3(0,.16,0),.45,bread)
	elif f in ["cake","tart","pie","macaron"]:
		cyl(n,Vector3(0,.2,0),.5,.4,bread);cyl(n,Vector3(0,.42,0),.5,.035,col)
		for i in range(6):ball(n,Vector3(cos(i)*.3,.47,sin(i)*.3),Vector3.ONE*.13,Color("bd7770"))
	elif f in ["baklava","kunafa","brownie","chips","cookie"]:
		for i in range(6):box(n,Vector3(-.3+i%3*.3,.1,-.2+int(i/3)*.35),Vector3(.25,.15,.27),bread if f!="brownie" else W)
	else:
		ball(n,Vector3(0,.2,0),Vector3(1,.4 if f not in ["flatbread","pita","naan"] else .08,.65),bread)
		for i in range(4):rod(n,Vector3(-.3+i*.2,.35,-.16),Vector3(-.2+i*.2,.35,.16),.013,C)

static func round_tool(n:Node3D,f:String,col:Color)->void:
	ring(n,Vector3(0,.45,0),.4,D if f=="tire" else col)
	if f in ["rope","wire","net","harness"]:
		for i in range(6):ring(n,Vector3(0,.1+i*.06,0),.45,col)
		if f=="net":
			for i in range(8):rod(n,Vector3(-.4+i*.12,0,-.4),Vector3(-.4+i*.12,0,.4),.009,C)
	if f in ["anchor","hook"]:
		rod(n,Vector3(0,.1,0),Vector3(0,1,0),.04,M)
		for side in [-1,1]:rod(n,Vector3(0,.1,0),Vector3(side*.4,.3,0),.045,M)
	if f in ["wheel","reel"]:
		for i in range(6):rod(n,Vector3(0,.45,0),Vector3(cos(i)*.4,.45,sin(i)*.4),.025,W)

static func small_object(n:Node3D,f:String,id:String,col:Color)->void:
	match f:
		"rifle":box(n,Vector3(-.25,.2,0),Vector3(.75,.15,.12),W);rod(n,Vector3(0,.2,0),Vector3(.9,.2,0),.025,D);box(n,Vector3(-.15,.05,0),Vector3(.12,.3,.08),D)
		"motorcycle","scooter","tricycle","unicycle":
			for x in [-.5,.5]:var wh=AnnexProps.ring(n,Vector3(x,.3,0),.3,D);wh.rotation.x=PI/2
			rod(n,Vector3(-.5,.3,0),Vector3(.3,.7,0),.045,col);rod(n,Vector3(.5,.3,0),Vector3(.5,1.1,0),.04,M);rod(n,Vector3(.5,1.1,-.2),Vector3(.5,1.1,.2),.025,D)
			box(n,Vector3(-.25,.75,0),Vector3(.5,.1,.25),D)
		"tooth":ball(n,Vector3(0,.5,0),Vector3(.65,.65,.5),C);rod(n,Vector3(-.17,.3,0),Vector3(-.1,0,0),.08,C);rod(n,Vector3(.17,.3,0),Vector3(.1,0,0),.08,C)
		"heart","lungs","bust","statue","puppet":
			ball(n,Vector3(-.15,.6,0),Vector3(.45,.6,.3),col);ball(n,Vector3(.15,.6,0),Vector3(.45,.6,.3),col)
			if f in ["bust","statue","puppet"]:n.add_child(TeacherCircle.person(false,2))
		"skeleton":
			ball(n,Vector3(0,1.3,0),Vector3(.35,.4,.32),C);rod(n,Vector3(0,.4,0),Vector3(0,1.1,0),.025,C)
			for side in [-1,1]:rod(n,Vector3(0,.9,0),Vector3(side*.4,.5,0),.022,C);rod(n,Vector3(0,.4,0),Vector3(side*.2,0,0),.03,C)
			for i in range(5):rod(n,Vector3(-.18,.65+i*.08,0),Vector3(.18,.65+i*.08,0),.017,C)
		"parachute":
			ball(n,Vector3(0,1.3,0),Vector3(1.5,.5,1.5),col)
			for x in [-.5,.5]:rod(n,Vector3(x,1.2,0),Vector3(0,.1,0),.01,C)
		"fire","wood","nest":
			for i in range(6):rod(n,Vector3(cos(i)*.5,.07,sin(i)*.5),Vector3(-cos(i)*.5,.07,-sin(i)*.5),.06,W)
			if f=="fire":WorldProps.cylinder(n,Vector3(0,.3,0),.25,.6,Color("e9ab64"),0)
		"blocks","mosaic":
			for i in range(6):box(n,Vector3(-.3+i%3*.3,.1,-.15+int(i/3)*.3),Vector3(.25,.2,.25),col.darkened(i*.04));label(n,str(i+1),Vector3(-.3+i%3*.3,.12,-.29+int(i/3)*.3))
		"tray","tin","palette","sieve":
			box(n,Vector3(0,.08,0),Vector3(1,.1,.7),M)
			for z in [-.35,.35]:box(n,Vector3(0,.17,z),Vector3(1,.15,.03),M)
			if f=="palette":
				for i in range(6):ball(n,Vector3(-.3+i%3*.3,.15,-.2+int(i/3)*.4),Vector3(.17,.02,.17),Color.from_hsv(i/6.0,.5,.8))
		"obstacle","barrier","escalator":
			for i in range(6):box(n,Vector3(0,.1+i*.12,-.5+i*.2),Vector3(1,.15,.25),M)
		"sandbag":ball(n,Vector3(0,.2,0),Vector3(1,.4,.55),W)
		"shield","mask":ball(n,Vector3(0,.5,0),Vector3(.7,1,.12),M);box(n,Vector3(0,.55,-.07),Vector3(.3,.04,.01),D)
		"origami":
			ball(n,Vector3(0,.22,0),Vector3(.3,.15,.15),C);rod(n,Vector3(.1,.23,0),Vector3(.35,.6,0),.025,C)
			for side in [-1,1]:var wing=WorldProps.box(n,Vector3(0,.3,side*.25),Vector3(.45,.018,.55),C);wing.rotation.x=side*.45
		"medal","badge","tag","card","bookmark","passport","oximeter","hearing","carving","blister","tape","punch","inhaler":
			box(n,Vector3(0,.25,0),Vector3(.6,.5,.07),col);label(n,id.replace("_"," ").to_upper(),Vector3(0,.3,-.04))
			if f=="blister":
				for i in range(6):ball(n,Vector3(-.2+i%3*.2,.15+int(i/3)*.2,-.06),Vector3(.12,.12,.03),C)
		"oar","rod","stick","needle","pen","chalk","syringe","flare","bollard":
			rod(n,Vector3(0,0,0),Vector3(0,1,0),.035,M);box(n,Vector3(0,.12,0),Vector3(.12,.25,.08),W)
			if f=="oar":ball(n,Vector3(0,.85,0),Vector3(.22,.45,.045),W)
			if f=="syringe":cyl(n,Vector3(0,.6,0),.07,.4,B)
		"hammer","shears","triangle","scraper","cutter","crampon","piping":
			rod(n,Vector3(-.3,.05,0),Vector3(.3,.6,0),.035,M);rod(n,Vector3(.3,.05,0),Vector3(-.3,.6,0),.035,M)
			if f=="hammer":box(n,Vector3(0,.6,0),Vector3(.5,.14,.14),M)
		_:
			push_error("Small expansion form is missing: "+f)
