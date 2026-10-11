class_name DailyProps
extends RefCounted

const WOOD=Color("b68d61")
const DARK=Color("30434b")
const METAL=Color("bccace")
const CREAM=Color("f1e5cf")
const TEAL=Color("79b5a3")
const RED=Color("bd7770")
const BLUE=Color("719bad")
static var made:Dictionary={}
static func b(n:Node3D,p:Vector3,s:Vector3,c:Color=CREAM)->MeshInstance3D:return WorldProps.box(n,p,s,c)
static func s(n:Node3D,p:Vector3,v:Vector3,c:Color=CREAM)->MeshInstance3D:return WorldProps.sphere(n,p,v,c)
static func c(n:Node3D,p:Vector3,r:float,h:float,col:Color=METAL,top:float=-1)->MeshInstance3D:return WorldProps.cylinder(n,p,r,h,col,top)
static func l(n:Node3D,a:Vector3,z:Vector3,r:float=.02,col:Color=METAL)->void:WorldProps.line(n,a,z,r,col)
static func ring(n:Node3D,p:Vector3,r:float,col:Color=METAL)->MeshInstance3D:return AnnexProps.ring(n,p,r,col)
static func curve(n:Node3D,pts:Array,r:float=.02,col:Color=METAL)->void:AccurateProps.curve(n,pts,r,col)
static func label(n:Node3D,t:String,p:Vector3,size:float=.002)->void:
	var text_node=AccurateProps.tag(n,t,p,size);text_node.rotation.y=PI
static func component(n:Node3D,key:String,scale_factor:float=1,p:Vector3=Vector3.ZERO)->Node3D:
	var part=WorldProps.make(key,scale_factor);part.position=p;n.add_child(part);return part
static func feet(n:Node3D,width:float,depth:float,height:float,col:Color=WOOD)->void:
	for x in [-width*.4,width*.4]:
		for z in [-depth*.4,depth*.4]:b(n,Vector3(x,height*.5,z),Vector3(.06,height,.06),col)
static func paper(n:Node3D,id:String,kind:String)->void:
	var upright=kind in ["poster","plaque","chart","timeline","menu","timetable","sheet_music","waveform","audio_meter","departure_board","queue_display"]
	var col=CREAM if kind not in ["passport","binder","keycard","card"] else BLUE
	var width=.62;var height=.86
	if kind in ["card","keycard","boarding_pass","ticket","cue_card","banknote","badge","luggage_tag","label","price_tag","barcode","number_plate"]:width=.8;height=.36
	b(n,Vector3(0,height*.5,0),Vector3(width,height,.015),col)
	if kind in ["passport","binder","brochure","script","notes","manuscript"]:
		b(n,Vector3(0,height*.5,.025),Vector3(width*.94,height*.94,.045),CREAM);b(n,Vector3(-width*.48,height*.5,.02),Vector3(.045,height,.07),col)
	if kind=="passport":label(n,"PASSPORT",Vector3(0,.65,-.015));ring(n,Vector3(0,.35,-.03),.13,METAL).rotation.x=PI/2
	elif kind in ["barcode","boarding_pass","ticket","label"]:
		for i in range(20):b(n,Vector3(-.3+i*.03,.1,-.012),Vector3(.012+(i%3)*.006,.12,.008),DARK)
	elif kind in ["waveform","audio_meter"]:
		b(n,Vector3(0,.43,-.02),Vector3(.6,.8,.015),DARK)
		for i in range(18):b(n,Vector3(-.26+i*.03,.43,-.032),Vector3(.016,.08+absf(sin(i*.9))*.5,.008),TEAL)
	elif kind in ["chart","timeline","planner","timetable"]:
		for j in range(5):b(n,Vector3(0,.18+j*.12,-.012),Vector3(.54,.007,.01),BLUE)
		for i in range(5):b(n,Vector3(-.24+i*.12,.43,-.012),Vector3(.006,.66,.01),BLUE)
	else:
		for j in range(6):b(n,Vector3(0,.15+j*height*.1,-.012),Vector3(width*(.65 if j%2 else .8),.008,.006),BLUE)
	if kind in ["badge","luggage_tag"]:curve(n,[Vector3(-.1,height,0),Vector3(-.15,height+.4,0),Vector3(.15,height+.4,0),Vector3(.1,height,0)],.012,TEAL)
	if upright:feet(n,width,.28,.18);b(n,Vector3(0,.015,0),Vector3(width,.03,.28),WOOD)
	if id!="":label(n,id.trim_prefix("daily_").replace("_"," ").to_upper(),Vector3(0,height*.85,-.014),.0008)
	if kind in ["departure_board","queue_display"]:label(n,"DEPARTURES" if kind=="departure_board" else "NEXT 042",Vector3(0,height*.8,-.02),.0015)

static func make(kind:String,id:String="")->Node3D:
	var n=Node3D.new();made[kind]=true
	if kind in ["passport","boarding_pass","keycard","brochure","document","ticket","plaque","chart","timeline","manuscript","invoice","card","badge","luggage_tag","planner","banknote","label","price_tag","barcode","number_plate","menu","receipt","script","notes","cue_card","poster","sheet_music","timetable","waveform","audio_meter","departure_board","queue_display","binder","sticky_notes"]:
		paper(n,id,kind);return n
	match kind:
		"person","mannequin","statue","bust":person(n,id,kind)
		"studio_microphone","dynamic_microphone","condenser_microphone","usb_microphone","mic_stand","boom_arm","pop_filter","shock_mount","windscreen","headphone_stand","studio_headphones","headset","audio_guide","audio_interface","mixing_desk","fader","gain_knob","xlr_cable","audio_jack","recorder","acoustic_panel","bass_trap","diffuser","studio_monitor","speaker_stand","on_air","record_button","mute_button","teleprompter","timer","workstation","ring_light","softbox","studio_door","cable_clip":studio(n,kind)
		"bus","minibus","motorcycle","electric_scooter","street_sweeper":vehicle(n,kind)
		"pottery","jug","inkpot","kettle","teapot","oil_lamp","flask","tube","pump_bottle","spray","detergent","sports_bottle","shaker","sparkling_water","mineral_water":vessel(n,kind,id)
		"latte","cappuccino","espresso","iced_coffee","hot_chocolate","lemonade","smoothie","orange_juice","takeaway_cup","cup_sleeve","coffee_beans","coffee_filter","french_press","dripper","fruit_salad","yogurt","granola","oatmeal","toast","omelette","scrambled_eggs","bagel","pretzel","cinnamon_roll","brownie","fruit_tart","baklava","popcorn":food(n,kind)
		"dumbbell","barbell","weight_plate","kettlebell","resistance_band","skipping_rope","exercise_bike","treadmill","rowing_machine","weight_bench","pullup_bar","foam_roller","yoga_mat","yoga_block","wrist_monitor","whistle","cone","agility_ladder","hurdle","cleats","shin_guards","boxing_gloves","punching_bag","boxing_ring","shuttlecock","sports_net","cricket_bat","wickets","bike_helmet","knee_pads","swim_cap","lifeguard_chair":fitness(n,kind)
		"luggage_trolley","shopping_trolley","shopping_basket","suitcase","dry_bag","medical_bag","tote_bag","duffel","gift_bag","gift_box","parcel","chest","toolbox":bag(n,kind)
		"screen","curtain","stage","electric_guitar","drum_kit","cymbal","digital_piano","synthesizer","amplifier","controller","console","arcade","vr_headset","board_game","playing_cards","dominoes","puzzle","dartboard","darts","pool_table","cue","pingpong","paddle","foosball","bowling_ball","karaoke","dance_floor","disco_ball","puppet","puppet_stage","theatre_mask","clapperboard","film_reel","video_camera":entertainment(n,kind)
		_:misc(n,kind,id)
	return n

static func person(n:Node3D,id:String,kind:String)->void:
	var skin=Color("ccaa8b");var shirt=[TEAL,BLUE,WOOD,RED][absi(id.hash())%4]
	if "firefighter" in id:shirt=Color("d5ab60")
	elif "police" in id:shirt=BLUE.darkened(.35)
	elif "paramedic" in id:shirt=CREAM
	elif "waiter" in id or "barista" in id:shirt=CREAM
	if kind in ["statue","bust","mannequin"]:skin=METAL;shirt=METAL
	var upper=Node3D.new();n.add_child(upper)
	s(upper,Vector3(0,1.55,0),Vector3(.35,.43,.33),skin)
	s(upper,Vector3(0,1.72,.03),Vector3(.38,.14,.34),DARK if kind=="person" else METAL)
	b(upper,Vector3(0,1.09,0),Vector3(.43,.62,.27),shirt)
	for side in [-1,1]:
		l(upper,Vector3(side*.25,1.34,0),Vector3(side*.3,.89,-.04),.06,shirt);s(upper,Vector3(side*.3,.86,-.04),Vector3(.11,.15,.1),skin)
		if kind!="bust":l(n,Vector3(side*.12,.78,0),Vector3(side*.12,.13,0),.07,DARK if kind=="person" else METAL);s(n,Vector3(side*.12,.07,-.08),Vector3(.2,.13,.3),DARK if kind=="person" else METAL)
		if kind=="person":s(upper,Vector3(side*.08,1.58,-.167),Vector3(.03,.035,.02),DARK)
	if kind=="bust":upper.position.y=-.7;b(n,Vector3(0,.06,0),Vector3(.5,.12,.4),CREAM)
	elif kind=="person":
		b(upper,Vector3(.13,1.25,-.15),Vector3(.09,.12,.015),CREAM)
		if ["guide","host","interviewer","producer"].any(func(word):return word in id):component(n,"accurate/clipboard",.34,Vector3(-.3,.84,-.12))
		elif "mechanic" in id or "plumber" in id:component(n,"accurate/wrench",.36,Vector3(-.3,.8,-.1))
		elif "firefighter" in id:component(n,"new/helmet",.43,Vector3(0,1.77,0))
		elif "barista" in id or "waiter" in id:b(n,Vector3(0,.98,-.15),Vector3(.35,.6,.025),WOOD)

static func microphone(n:Node3D,p:Vector3=Vector3.ZERO,stand:bool=true)->void:
	var mic=Node3D.new();mic.position=p;n.add_child(mic)
	c(mic,Vector3(0,.68,0),.07,.28,DARK);s(mic,Vector3(0,.84,0),Vector3(.17,.15,.17),METAL)
	for i in range(5):ring(mic,Vector3(0,.78+i*.02,0),.077,DARK)
	if stand:c(mic,Vector3(0,.018,0),.17,.036,DARK);l(mic,Vector3(0,.04,0),Vector3(0,.54,0),.02,METAL)
	curve(mic,[Vector3(0,.55,.03),Vector3(.12,.1,.08),Vector3(.3,.01,.2)],.009,DARK)

static func headphones(n:Node3D,p:Vector3=Vector3.ZERO)->void:
	curve(n,[p+Vector3(-.24,.2,0),p+Vector3(-.25,.58,0),p+Vector3(-.13,.74,0),p+Vector3(.13,.74,0),p+Vector3(.25,.58,0),p+Vector3(.24,.2,0)],.035,DARK)
	for x in [-.24,.24]:s(n,p+Vector3(x,.28,0),Vector3(.12,.3,.2),DARK);s(n,p+Vector3(x*.8,.28,0),Vector3(.035,.23,.15),WOOD)

static func studio(n:Node3D,k:String)->void:
	if k=="timer":
		b(n,Vector3(0,.2,0),Vector3(.6,.4,.16),DARK);label(n,"00:00",Vector3(0,.2,-.085),.002);return
	match k:
		"studio_microphone","dynamic_microphone","condenser_microphone","usb_microphone","mic_stand":
			microphone(n)
			if k=="condenser_microphone":ring(n,Vector3(0,.6,0),.13,METAL)
			if k=="mic_stand":for z in range(3):l(n,Vector3(0,.1,0),Vector3(cos(z*TAU/3)*.35,0,sin(z*TAU/3)*.35),.025,DARK)
		"boom_arm":
			b(n,Vector3(0,.02,0),Vector3(.12,.04,.1),DARK)
			for z in [-.03,.03]:l(n,Vector3(0,0,z),Vector3(.15,.6,z),.016,DARK);l(n,Vector3(.15,.6,z),Vector3(.6,.82,z),.016,DARK)
			for p in [Vector3.ZERO,Vector3(.15,.6,0),Vector3(.6,.82,0)]:s(n,p,Vector3.ONE*.07,METAL)
		"pop_filter":ring(n,Vector3(0,.55,0),.18,DARK).rotation.x=PI/2;var disk=c(n,Vector3(0,.55,0),.155,.006,DARK);disk.rotation.x=PI/2;curve(n,[Vector3(0,.36,0),Vector3(-.14,.25,0),Vector3(-.14,0,0)],.014,DARK)
		"shock_mount":ring(n,Vector3(0,.15,0),.22,METAL);ring(n,Vector3(0,.15,0),.12,DARK);for i in range(8):l(n,Vector3(cos(i)*.22,.15,sin(i)*.22),Vector3(-cos(i)*.12,.2,-sin(i)*.12),.006,DARK)
		"windscreen":s(n,Vector3(0,.2,0),Vector3(.28,.4,.28),DARK)
		"studio_headphones","headset","audio_guide":headphones(n);if k=="headset":curve(n,[Vector3(-.25,.24,0),Vector3(-.2,.12,-.15),Vector3(-.04,.12,-.2)],.014,DARK)
		"headphone_stand":c(n,Vector3(0,.02,0),.2,.04,DARK);l(n,Vector3(0,.04,0),Vector3(0,.7,0),.028,METAL);b(n,Vector3(0,.72,0),Vector3(.38,.07,.09),WOOD)
		"audio_interface","mixing_desk","recorder","timer":
			var desk=k=="mixing_desk";b(n,Vector3(0,.12,0),Vector3(1.2 if desk else .55,.24,.8 if desk else .35),DARK)
			for i in range(8 if desk else 3):
				var x=-.5+i*.14 if desk else -.17+i*.17
				b(n,Vector3(x,.246,0),Vector3(.014,.01,.36 if desk else .1),METAL);b(n,Vector3(x,.26,-.05+(i%3)*.04),Vector3(.055,.04,.07),CREAM);c(n,Vector3(x,.265,-.26 if desk else -.12),.025,.025,TEAL)
			for i in range(3):c(n,Vector3(-.12+i*.12,.1,-.405 if desk else -.18),.026,.012,METAL).rotation.x=PI/2
		"fader":b(n,Vector3(0,.01,0),Vector3(.18,.02,.65),DARK);b(n,Vector3(0,.025,0),Vector3(.012,.01,.52),METAL);b(n,Vector3(0,.055,-.1),Vector3(.12,.04,.07),CREAM)
		"gain_knob":c(n,Vector3(0,.08,0),.15,.16,DARK);b(n,Vector3(0,.165,-.06),Vector3(.018,.009,.12),CREAM)
		"xlr_cable":coil(n,.35);b(n,Vector3(.45,.07,0),Vector3(.18,.09,.09),DARK);for x in [-.03,0,.03]:l(n,Vector3(.55,.07,x),Vector3(.62,.07,x),.009,METAL)
		"audio_jack":l(n,Vector3(-.3,.1,0),Vector3(.3,.1,0),.035,METAL);l(n,Vector3(-.3,.1,0),Vector3(-.65,.1,0),.06,DARK);for x in [.12,.2]:c(n,Vector3(x,.1,0),.036,.025,DARK).rotation.z=PI/2
		"acoustic_panel","bass_trap":
			b(n,Vector3(0,.55,0),Vector3(.65,1.1,.18 if k=="acoustic_panel" else .5),TEAL)
			for i in range(8):b(n,Vector3(-.28+i*.08,.55,-.11 if k=="acoustic_panel" else -.27),Vector3(.035,1,.08),DARK)
		"diffuser":for x in range(8):for y in range(8):b(n,Vector3(x*.1,y*.1,.05),Vector3(.085,.085,.07+((x*y+x)%5)*.05),WOOD)
		"studio_monitor":b(n,Vector3(0,.45,0),Vector3(.5,.9,.42),DARK);for part in [[.32,.16],[.68,.075]]:c(n,Vector3(0,part[0],-.218),part[1],.025,METAL).rotation.x=PI/2;c(n,Vector3(0,part[0],-.235),part[1]*.7,.012,DARK).rotation.x=PI/2
		"speaker_stand":b(n,Vector3(0,.02,0),Vector3(.6,.04,.6),DARK);l(n,Vector3(0,.04,0),Vector3(0,1.15,0),.045,METAL);b(n,Vector3(0,1.18,0),Vector3(.4,.05,.36),DARK)
		"on_air":b(n,Vector3(0,.15,0),Vector3(.8,.3,.12),DARK);label(n,"ON AIR",Vector3(0,.15,-.065),.003);b(n,Vector3(0,.29,-.07),Vector3(.7,.015,.015),RED)
		"record_button","mute_button":c(n,Vector3(0,.06,0),.15,.12,RED if k=="record_button" else TEAL);c(n,Vector3(0,.125,0),.1,.01,DARK)
		"teleprompter":tripod(n);var glass=b(n,Vector3(0,.9,0),Vector3(.7,.45,.025),BLUE);glass.rotation.x=-.6;b(n,Vector3(0,.65,0),Vector3(.6,.03,.4),DARK)
		"workstation":component(n,"furniture/desk",1.6);component(n,"furniture/computerScreen",.7,Vector3(0,.95,.18));component(n,"furniture/computerKeyboard",.5,Vector3(0,.85,-.15));component(n,"daily/studio_monitor",.45,Vector3(.6,.85,.1))
		"ring_light":tripod(n);ring(n,Vector3(0,1,0),.4,CREAM).rotation.x=PI/2
		"softbox":tripod(n);b(n,Vector3(0,1,0),Vector3(.65,.65,.18),DARK);b(n,Vector3(0,1,-.1),Vector3(.6,.6,.01),CREAM)
		"studio_door":b(n,Vector3(0,1,0),Vector3(.85,2,.12),WOOD);b(n,Vector3(0,1.45,-.07),Vector3(.5,.5,.015),BLUE);s(n,Vector3(.32,.95,-.1),Vector3.ONE*.07,METAL)
		"cable_clip":curve(n,[Vector3(-.1,.02,0),Vector3(-.13,.18,0),Vector3(.13,.18,0),Vector3(.1,.02,0)],.025,DARK)

static func tripod(n:Node3D)->void:
	l(n,Vector3(0,.25,0),Vector3(0,.9,0),.025,METAL)
	for i in range(3):l(n,Vector3(0,.35,0),Vector3(cos(i*TAU/3)*.35,0,sin(i*TAU/3)*.35),.025,DARK)
static func coil(n:Node3D,r:float=.3)->void:
	for i in range(3):ring(n,Vector3(0,.025+i*.025,0),r-i*.025,DARK)

static func vehicle(n:Node3D,k:String)->void:
	if k in ["electric_scooter","motorcycle"]:
		var bike=k=="motorcycle"
		for z in [-.65,.65]:c(n,Vector3(0,.23,z),.23,.12,DARK).rotation.z=PI/2;ring(n,Vector3(.07,.23,z),.15,METAL).rotation.z=PI/2
		b(n,Vector3(0,.25,0),Vector3(.28,.08,1.05),DARK);l(n,Vector3(0,.25,-.65),Vector3(0,1.16,-.5),.035,TEAL);l(n,Vector3(-.3,1.16,-.5),Vector3(.3,1.16,-.5),.03,DARK)
		if bike:s(n,Vector3(0,.55,-.08),Vector3(.38,.4,.65),RED);b(n,Vector3(0,.68,.32),Vector3(.32,.08,.5),DARK);l(n,Vector3(0,.45,.48),Vector3(0,.25,.65),.04,METAL)
		return
	var bus=k!="street_sweeper";var length=3.5 if k=="bus" else 2.6
	b(n,Vector3(0,.8,0),Vector3(1.2,1.2,length),TEAL if bus else Color("d9ba6e"))
	for side in [-1,1]:
		for z in [-length*.34,length*.34]:c(n,Vector3(side*.6,.28,z),.28,.13,DARK).rotation.z=PI/2;c(n,Vector3(side*.68,.28,z),.14,.025,METAL).rotation.z=PI/2
		for j in range(5 if k=="bus" else 3):b(n,Vector3(side*.605,1.04,-length*.34+j*(length*.16 if k=="bus" else length*.28)),Vector3(.025,.38,.42),BLUE)
		b(n,Vector3(side*.62,.55,-length*.3),Vector3(.025,.7,.36),DARK)
	b(n,Vector3(0,1.04,-length*.505),Vector3(1,.45,.02),BLUE)
	for side in [-1,1]:s(n,Vector3(side*.4,.55,-length*.52),Vector3(.14,.12,.025),CREAM);s(n,Vector3(side*.4,.55,length*.52),Vector3(.12,.16,.025),RED)
	if not bus:
		for side in [-1,1]:c(n,Vector3(side*.62,.12,-length*.35),.28,.12,DARK);for i in range(8):l(n,Vector3(side*.62,.1,-length*.35),Vector3(side*.62+cos(i)*.3,.02,-length*.35+sin(i)*.3),.012,METAL)

static func vessel(n:Node3D,k:String,id:String)->void:
	if k in ["tube","spray","pump_bottle","detergent","sports_bottle","shaker","flask","sparkling_water","mineral_water"]:
		var r=.18;var height=.65;var col=BLUE if k in ["flask","sports_bottle","shaker","detergent"] else CREAM
		if k=="tube":b(n,Vector3(0,.3,0),Vector3(.27,.6,.1),CREAM);c(n,Vector3(0,.02,0),.08,.08,DARK);return
		c(n,Vector3(0,.3,0),r,.6,col);s(n,Vector3(0,.6,0),Vector3(.36,.14,.36),col);c(n,Vector3(0,.68,0),.08,.09,DARK)
		if k in ["spray","pump_bottle"]:l(n,Vector3(0,.75,0),Vector3(.2,.75,0),.025,DARK)
		if k=="detergent":curve(n,[Vector3(.16,.58,0),Vector3(.32,.58,0),Vector3(.32,.32,0),Vector3(.16,.32,0)],.035,BLUE)
		if k in ["flask","shaker"]:ring(n,Vector3(0,.2,0),.185,METAL)
		return
	var col=WOOD if k in ["pottery","oil_lamp"] or "clay" in id else METAL if k=="kettle" else CREAM
	AccurateProps.lathe(n,[Vector2(0,0),Vector2(.23,.02),Vector2(.34,.18),Vector2(.3,.48),Vector2(.15,.65),Vector2(.16,.72),Vector2(.12,.72),Vector2(.12,.66)],col)
	if k in ["jug","kettle","teapot","oil_lamp"]:curve(n,[Vector3(.28,.45,0),Vector3(.52,.48,0),Vector3(.54,.2,0),Vector3(.3,.18,0)],.035,col)
	if k in ["teapot","kettle","oil_lamp"]:curve(n,[Vector3(-.25,.25,0),Vector3(-.45,.42,0),Vector3(-.62,.53,0)],.055,col);c(n,Vector3(0,.72,0),.16,.045,col);s(n,Vector3(0,.77,0),Vector3.ONE*.075,DARK)
	if k=="jug":b(n,Vector3(-.16,.69,0),Vector3(.13,.04,.08),col)
	if k=="inkpot":for child in n.get_children():if child is Node3D:child.scale=Vector3(1,.45,1)

static func food(n:Node3D,k:String)->void:
	if k=="cup_sleeve":
		AccurateProps.lathe(n,[Vector2(.13,.08),Vector2(.16,.24),Vector2(.148,.24),Vector2(.118,.08)],WOOD);return
	if k in ["latte","cappuccino","espresso","hot_chocolate","takeaway_cup","cup_sleeve"]:
		AccurateProps.lathe(n,[Vector2(0,0),Vector2(.12,.01),Vector2(.17,.35),Vector2(.15,.35),Vector2(.11,.05)],WOOD if k in ["takeaway_cup","cup_sleeve"] else CREAM)
		c(n,Vector3(0,.31,0),.14,.015,Color("765342"));if k=="cappuccino" or k=="latte":s(n,Vector3(0,.325,0),Vector3(.23,.014,.23),CREAM)
		if k not in ["takeaway_cup","cup_sleeve"]:curve(n,[Vector3(.15,.27,0),Vector3(.28,.28,0),Vector3(.28,.08,0),Vector3(.12,.08,0)],.024,CREAM)
		else:ring(n,Vector3(0,.2,0),.158,WOOD.darkened(.2));c(n,Vector3(0,.36,0),.17,.025,DARK)
	elif k in ["iced_coffee","lemonade","smoothie","orange_juice"]:
		var col=Color("b88658") if k=="iced_coffee" else Color("e4c871") if k=="lemonade" else Color("d5948e") if k=="smoothie" else Color("e8ad63")
		c(n,Vector3(0,.25,0),.16,.5,col);ring(n,Vector3(0,.5,0),.17,METAL);l(n,Vector3(.05,.3,0),Vector3(.1,.72,0),.014,CREAM)
		if k=="iced_coffee":for i in range(4):b(n,Vector3(cos(i)*.07,.45,sin(i)*.07),Vector3.ONE*.08,BLUE)
	elif k=="french_press":
		c(n,Vector3(0,.3,0),.18,.6,BLUE);ring(n,Vector3(0,.04,0),.19,METAL);c(n,Vector3(0,.61,0),.19,.025,METAL);l(n,Vector3(0,.61,0),Vector3(0,.8,0),.02,METAL);s(n,Vector3(0,.82,0),Vector3.ONE*.08,DARK);curve(n,[Vector3(.17,.5,0),Vector3(.32,.5,0),Vector3(.32,.12,0),Vector3(.17,.12,0)],.03,DARK)
	elif k in ["coffee_filter","dripper"]:
		AccurateProps.lathe(n,[Vector2(.025,0),Vector2(.23,.3),Vector2(.22,.3),Vector2(.02,.025)],CREAM)
		if k=="dripper":ring(n,Vector3(0,.02,0),.13,CREAM);curve(n,[Vector3(.2,.25,0),Vector3(.35,.25,0),Vector3(.35,.1,0),Vector3(.1,.1,0)],.022,CREAM)
	elif k=="coffee_beans":for i in range(20):var p=Vector3(cos(i*2)*.2,.04+i%3*.025,sin(i*2)*.2);s(n,p,Vector3(.08,.06,.05),Color("74533c"));l(n,p+Vector3(-.025,.025,0),p+Vector3(.025,.025,0),.003,DARK)
	elif k in ["fruit_salad","yogurt","granola","oatmeal","omelette","scrambled_eggs","toast","fruit_tart","baklava","brownie"]:
		component(n,"food/bowl" if k in ["fruit_salad","yogurt","granola","oatmeal"] else "food/plate",.6)
		if k in ["yogurt","oatmeal"]:c(n,Vector3(0,.13,0),.21,.06,CREAM)
		elif k=="toast":b(n,Vector3(0,.12,0),Vector3(.4,.04,.42),WOOD);b(n,Vector3(0,.145,0),Vector3(.33,.014,.34),Color("d9b786"))
		elif k=="omelette":s(n,Vector3(0,.12,0),Vector3(.5,.06,.32),Color("e6c377"))
		elif k=="brownie":b(n,Vector3(0,.14,0),Vector3(.36,.12,.36),Color("70513e"))
		elif k=="baklava":for i in range(4):var piece=b(n,Vector3(-.1+(i%2)*.2,.13,-.1+int(i/2)*.2),Vector3(.17,.12,.17),Color("d5b076"));piece.rotation.y=.3
		elif k=="fruit_tart":c(n,Vector3(0,.13,0),.23,.11,WOOD);c(n,Vector3(0,.19,0),.21,.035,CREAM);for i in range(8):s(n,Vector3(cos(i)*.15,.23,sin(i)*.15),Vector3(.075,.08,.06),RED if i%2 else TEAL)
		else:for i in range(22):s(n,Vector3(cos(i*2)*.19,.13+(i%4)*.018,sin(i*2)*.19),Vector3.ONE*(.045 if k=="granola" else .075),RED if k=="fruit_salad" and i%2 else Color("dfc187"))
	elif k in ["bagel","pretzel","cinnamon_roll"]:
		if k=="bagel":ring(n,Vector3(0,.08,0),.25,Color("cd9962"));for i in range(20):s(n,Vector3(cos(i)*.21,.13,sin(i)*.21),Vector3(.012,.01,.025),CREAM)
		elif k=="pretzel":curve(n,[Vector3(-.22,.07,-.14),Vector3(-.25,.07,.12),Vector3(-.08,.07,.22),Vector3(.15,.07,-.18),Vector3(.25,.07,-.13),Vector3(.25,.07,.13),Vector3(.08,.07,.22),Vector3(-.15,.07,-.18)],.055,WOOD)
		else:
			c(n,Vector3(0,.07,0),.25,.14,WOOD)
			var pts=[]
			for i in range(60):pts.append(Vector3(cos(i*.3)*i*.0038,.15,sin(i*.3)*i*.0038))
			curve(n,pts,.012,CREAM)
	elif k=="popcorn":c(n,Vector3(0,.2,0),.17,.4,RED,.25);for i in range(25):s(n,Vector3(cos(i)*.18,.4+(i%4)*.028,sin(i)*.18),Vector3.ONE*.08,CREAM)

static func bag(n:Node3D,k:String)->void:
	if k in ["luggage_trolley","shopping_trolley"]:
		b(n,Vector3(0,.24,0),Vector3(.7,.06,.9),METAL)
		for x in [-.3,.3]:
			for z in [-.35,.35]:c(n,Vector3(x,.1,z),.1,.08,DARK).rotation.z=PI/2
			l(n,Vector3(x,.25,.4),Vector3(x,1.2,.4),.028,METAL)
		l(n,Vector3(-.3,1.2,.4),Vector3(.3,1.2,.4),.035,TEAL)
		if k=="shopping_trolley":
			for i in range(9):l(n,Vector3(-.3+i*.075,.4,-.35),Vector3(-.3+i*.075,.9,-.35),.01,METAL);l(n,Vector3(-.3+i*.075,.4,.35),Vector3(-.3+i*.075,.9,.35),.01,METAL)
			for side in [-1,1]:for j in range(7):l(n,Vector3(side*.3,.4,-.35+j*.115),Vector3(side*.3,.9,-.35+j*.115),.01,METAL)
			for y in [.4,.65,.9]:curve(n,[Vector3(-.3,y,-.35),Vector3(.3,y,-.35),Vector3(.3,y,.35),Vector3(-.3,y,.35),Vector3(-.3,y,-.35)],.015,METAL)
		else:curve(n,[Vector3(-.3,1.2,.4),Vector3(-.3,1.4,0),Vector3(.3,1.4,0),Vector3(.3,1.2,.4)],.03,METAL)
		return
	var col=WOOD if k in ["parcel","chest","gift_box"] else TEAL
	b(n,Vector3(0,.35,0),Vector3(.75,.7,.35),col)
	curve(n,[Vector3(-.16,.71,0),Vector3(-.16,.87,0),Vector3(.16,.87,0),Vector3(.16,.71,0)],.025,DARK)
	if k=="suitcase":
		for x in [-.28,.28]:c(n,Vector3(x,.03,0),.065,.07,DARK).rotation.z=PI/2;l(n,Vector3(x,.5,.1),Vector3(x,1,.1),.016,METAL)
		l(n,Vector3(-.28,1,.1),Vector3(.28,1,.1),.025,DARK)
	elif k in ["gift_box","parcel","chest"]:b(n,Vector3(0,.35,-.18),Vector3(.06,.7,.015),CREAM);b(n,Vector3(0,.35,0),Vector3(.75,.04,.37),CREAM)
	elif k=="medical_bag":ExpansionProps.medical_cross(n,Vector3(0,.36,-.19),.22)
	elif k=="shopping_basket":for i in range(6):b(n,Vector3(-.3+i*.12,.35,-.18),Vector3(.045,.5,.025),DARK)
	elif k=="duffel":s(n,Vector3(0,.35,0),Vector3(.95,.5,.5),TEAL)
	elif k=="dry_bag":c(n,Vector3(0,.4,0),.25,.8,TEAL);b(n,Vector3(0,.82,0),Vector3(.55,.045,.05),DARK)

static func fitness(n:Node3D,k:String)->void:
	match k:
		"dumbbell","barbell":
			var half=.65 if k=="barbell" else .25
			l(n,Vector3(-half-.1,.16,0),Vector3(half+.1,.16,0),.025,METAL)
			for x in [-half,half]:c(n,Vector3(x,.16,0),.2 if k=="barbell" else .15,.08,DARK).rotation.z=PI/2
		"weight_plate":c(n,Vector3(0,.04,0),.3,.08,DARK);ring(n,Vector3(0,.085,0),.05,METAL)
		"kettlebell":s(n,Vector3(0,.21,0),Vector3(.4,.4,.4),DARK);ring(n,Vector3(0,.47,0),.16,DARK).rotation.x=PI/2
		"resistance_band","skipping_rope","yoga_strap":coil(n);for x in [-.4,.4]:l(n,Vector3(x,0,0),Vector3(x+.2,0,0),.04,TEAL)
		"exercise_bike":
			l(n,Vector3(-.6,.05,0),Vector3(.6,.05,0),.045,DARK);l(n,Vector3(-.2,.1,0),Vector3(-.3,.75,0),.04,METAL);b(n,Vector3(-.3,.8,0),Vector3(.35,.07,.25),DARK);l(n,Vector3(.45,.1,0),Vector3(.4,1,0),.04,METAL);l(n,Vector3(.4,1,-.25),Vector3(.4,1,.25),.03,DARK);c(n,Vector3(.1,.3,0),.27,.16,TEAL).rotation.x=PI/2;l(n,Vector3(0,.3,-.15),Vector3(-.15,.2,-.15),.02,DARK);b(n,Vector3(-.15,.2,-.2),Vector3(.14,.04,.12),DARK)
		"treadmill","rowing_machine":
			b(n,Vector3(0,.08,0),Vector3(.8,.16,1.6),DARK);b(n,Vector3(0,.18,0),Vector3(.6,.03,1.3),TEAL)
			if k=="treadmill":
				for x in [-.36,.36]:l(n,Vector3(x,.2,-.6),Vector3(x,1,-.65),.035,METAL);l(n,Vector3(x,1,-.65),Vector3(x,.85,-.1),.03,DARK)
				b(n,Vector3(0,1,-.65),Vector3(.65,.25,.1),DARK);b(n,Vector3(0,1,-.71),Vector3(.35,.13,.015),BLUE)
			else:c(n,Vector3(0,.42,-.5),.32,.4,DARK).rotation.z=PI/2;b(n,Vector3(0,.35,.35),Vector3(.5,.09,.35),WOOD);l(n,Vector3(-.3,.55,-.45),Vector3(.3,.55,-.45),.035,METAL)
		"weight_bench":b(n,Vector3(0,.48,0),Vector3(.45,.1,1.5),TEAL);feet(n,.5,1.4,.43,METAL)
		"pullup_bar","hurdle","sports_net","boxing_ring":
			var h=1.5 if k in ["pullup_bar","sports_net"] else .65;var w=1.7
			for x in [-w*.5,w*.5]:l(n,Vector3(x,0,0),Vector3(x,h,0),.035,METAL);b(n,Vector3(x,.02,0),Vector3(.4,.04,.4),DARK)
			l(n,Vector3(-w*.5,h,0),Vector3(w*.5,h,0),.03,METAL)
			if k=="sports_net":
				for i in range(12):l(n,Vector3(-.85+i*.15,h,0),Vector3(-.85+i*.15,.45,0),.008,CREAM)
				for y in [.45,.65,.85,1.05,1.25]:l(n,Vector3(-.85,y,0),Vector3(.85,y,0),.008,CREAM)
			elif k=="boxing_ring":
				b(n,Vector3(0,.05,0),Vector3(2,.1,2),TEAL)
				for y in [.25,.5,.75]:curve(n,[Vector3(-.85,y,-.85),Vector3(.85,y,-.85),Vector3(.85,y,.85),Vector3(-.85,y,.85),Vector3(-.85,y,-.85)],.018,RED)
		"foam_roller":c(n,Vector3(0,.15,0),.15,.7,TEAL).rotation.z=PI/2;for i in range(6):ring(n,Vector3(-.28+i*.11,.15,0),.155,DARK).rotation.z=PI/2
		"yoga_mat":b(n,Vector3(0,.015,0),Vector3(.65,.03,1.6),TEAL);c(n,Vector3(0,.08,.8),.075,.65,TEAL).rotation.z=PI/2
		"yoga_block":b(n,Vector3(0,.12,0),Vector3(.4,.24,.25),TEAL)
		"wrist_monitor":ring(n,Vector3(0,.07,0),.2,DARK);b(n,Vector3(0,.12,-.18),Vector3(.24,.08,.2),BLUE);b(n,Vector3(0,.17,-.18),Vector3(.17,.008,.14),DARK)
		"whistle":c(n,Vector3(0,.12,0),.12,.13,METAL).rotation.x=PI/2;b(n,Vector3(.15,.12,0),Vector3(.2,.06,.08),METAL);ring(n,Vector3(-.14,.12,0),.06,METAL).rotation.x=PI/2
		"cone":c(n,Vector3(0,.25,0),.2,.5,RED,0);b(n,Vector3(0,.015,0),Vector3(.48,.03,.48),DARK)
		"agility_ladder":for x in [-.3,.3]:l(n,Vector3(x,0,-.9),Vector3(x,0,.9),.02,RED);for j in range(8):l(n,Vector3(-.3,.02,-.9+j*.25),Vector3(.3,.02,-.9+j*.25),.015,CREAM)
		"cleats":component(n,"accurate/shoe",.65);for x in [-.15,.15]:for z in [-.2,0,.2]:c(n,Vector3(x,.02,z),.018,.045,DARK)
		"shin_guards","knee_pads":for x in [-.2,.2]:s(n,Vector3(x,.23,0),Vector3(.28,.45,.12),BLUE);b(n,Vector3(x,.23,.07),Vector3(.32,.05,.03),DARK)
		"boxing_gloves":for x in [-.24,.24]:s(n,Vector3(x,.25,0),Vector3(.35,.38,.35),RED);b(n,Vector3(x,.07,.04),Vector3(.26,.13,.26),DARK);s(n,Vector3(x*.65,.18,-.1),Vector3(.1,.2,.13),RED)
		"punching_bag":c(n,Vector3(0,.65,0),.28,1.1,RED);for i in range(4):l(n,Vector3(cos(i)*.2,1.2,sin(i)*.2),Vector3(0,1.6,0),.015,METAL)
		"shuttlecock":s(n,Vector3(0,.05,0),Vector3.ONE*.13,CREAM);for i in range(12):l(n,Vector3(cos(i)*.05,.1,sin(i)*.05),Vector3(cos(i)*.2,.5,sin(i)*.2),.008,CREAM);ring(n,Vector3(0,.5,0),.2,CREAM)
		"cricket_bat":b(n,Vector3(0,.35,0),Vector3(.18,.6,.05),WOOD);l(n,Vector3(0,.65,0),Vector3(0,1,0),.025,DARK)
		"wickets":for x in [-.18,0,.18]:l(n,Vector3(x,0,0),Vector3(x,.9,0),.025,WOOD);l(n,Vector3(-.2,.93,0),Vector3(.2,.93,0),.015,WOOD)
		"bike_helmet","swim_cap":s(n,Vector3(0,.17,0),Vector3(.6,.34,.48),TEAL);if k=="bike_helmet":for x in [-.15,0,.15]:b(n,Vector3(x,.31,0),Vector3(.045,.016,.24),DARK)
		"lifeguard_chair":component(n,"furniture/chair",1.34,Vector3(0,.75,0));feet(n,.8,.8,.8,WOOD);for j in range(5):l(n,Vector3(-.32,j*.16,-.5),Vector3(.32,j*.16,-.5),.02,WOOD)

static func entertainment(n:Node3D,k:String)->void:
	match k:
		"screen":b(n,Vector3(0,1,0),Vector3(2,1.15,.1),DARK);b(n,Vector3(0,1,-.055),Vector3(1.88,1.02,.01),CREAM);feet(n,1.8,.5,.55,METAL)
		"curtain":for i in range(12):b(n,Vector3(-.55+i*.1,.7,0),Vector3(.09,1.4,.08+(i%2)*.05),RED);l(n,Vector3(-.65,1.42,0),Vector3(.65,1.42,0),.025,METAL)
		"stage","dance_floor":b(n,Vector3(0,.12,0),Vector3(2.2,.24,1.8),WOOD);for i in range(10):b(n,Vector3(-1+i*.22,.245,0),Vector3(.012,.006,1.7),DARK)
		"electric_guitar":s(n,Vector3(0,.28,0),Vector3(.47,.55,.1),RED);s(n,Vector3(.12,.5,0),Vector3(.25,.25,.1),RED);b(n,Vector3(0,.8,0),Vector3(.08,.7,.045),WOOD);b(n,Vector3(0,1.2,0),Vector3(.12,.18,.05),WOOD);for x in [-.025,-.015,-.005,.005,.015,.025]:l(n,Vector3(x,.1,-.06),Vector3(x,1.26,-.03),.0015,METAL);for y in [.2,.3]:b(n,Vector3(0,y,-.06),Vector3(.2,.04,.02),DARK)
		"drum_kit":
			c(n,Vector3(0,.3,0),.3,.45,RED).rotation.x=PI/2
			for x in [-.4,.4]:c(n,Vector3(x,.65,0),.18,.3,RED);c(n,Vector3(x,.805,0),.18,.01,CREAM);l(n,Vector3(x,0,0),Vector3(x,.5,0),.025,METAL);c(n,Vector3(x,.95,.35),.3,.025,Color("c3ab70"));l(n,Vector3(x,0,.35),Vector3(x,.95,.35),.02,METAL)
		"cymbal":c(n,Vector3(0,.05,0),.35,.025,Color("c3ab70"));s(n,Vector3(0,.06,0),Vector3(.12,.06,.12),Color("c3ab70"))
		"digital_piano","synthesizer":b(n,Vector3(0,.12,0),Vector3(1.2,.24,.4),DARK);for i in range(22):b(n,Vector3(-.55+i*.05,.25,-.1),Vector3(.046,.02,.18),CREAM);if i%7 not in [2,6]:b(n,Vector3(-.525+i*.05,.27,-.05),Vector3(.025,.03,.1),DARK)
		"amplifier","karaoke":b(n,Vector3(0,.4,0),Vector3(.7,.8,.35),DARK);b(n,Vector3(0,.35,-.18),Vector3(.6,.55,.012),WOOD);for i in range(5):c(n,Vector3(-.24+i*.12,.7,-.19),.022,.015,METAL).rotation.x=PI/2
		"controller":s(n,Vector3(0,.1,0),Vector3(.6,.15,.35),DARK);for x in [-.2,.2]:s(n,Vector3(x,.06,.15),Vector3(.17,.16,.3),DARK);s(n,Vector3(x,.18,0),Vector3.ONE*.07,TEAL);b(n,Vector3(-.18,.18,-.07),Vector3(.13,.02,.04),METAL);b(n,Vector3(-.18,.18,-.07),Vector3(.04,.02,.13),METAL)
		"console":b(n,Vector3(0,.09,0),Vector3(.55,.18,.45),DARK);b(n,Vector3(0,.13,-.23),Vector3(.4,.01,.01),TEAL)
		"arcade":b(n,Vector3(0,.7,0),Vector3(.75,1.4,.6),RED);b(n,Vector3(0,.93,-.32),Vector3(.62,.48,.04),DARK);b(n,Vector3(0,.93,-.345),Vector3(.54,.37,.008),BLUE);b(n,Vector3(0,.63,-.44),Vector3(.75,.09,.3),DARK);l(n,Vector3(-.15,.68,-.42),Vector3(-.15,.8,-.42),.017,METAL);s(n,Vector3(-.15,.82,-.42),Vector3.ONE*.07,RED);for x in [.05,.15,.25]:c(n,Vector3(x,.695,-.42),.025,.015,TEAL)
		"vr_headset":b(n,Vector3(0,.2,0),Vector3(.5,.28,.26),DARK);curve(n,[Vector3(-.25,.2,0),Vector3(-.25,.2,.32),Vector3(.25,.2,.32),Vector3(.25,.2,0)],.03,DARK);for x in [-.1,.1]:s(n,Vector3(x,.2,.145),Vector3(.14,.14,.02),BLUE)
		"board_game","playing_cards","dominoes","puzzle":
			b(n,Vector3(0,.015,0),Vector3(.8,.03,.6),TEAL if k!="dominoes" else WOOD)
			for i in range(12):
				var x=-.3+(i%4)*.2;var z=-.2+int(i/4)*.2
				b(n,Vector3(x,.04,z),Vector3(.13,.025,.16),CREAM)
				if k in ["dominoes","playing_cards"]:for j in range(1+i%5):s(n,Vector3(x-.04+(j%2)*.08,.058,z-.05+int(j/2)*.05),Vector3(.015,.004,.015),DARK)
				else:b(n,Vector3(x,.058,z),Vector3(.05,.005,.06),RED if i%2 else BLUE)
		"dartboard":c(n,Vector3(0,.4,0),.4,.04,DARK).rotation.x=PI/2;for r in [.36,.25,.13]:ring(n,Vector3(0,.4,-.025),r,RED if r==.25 else CREAM).rotation.x=PI/2;for i in range(20):l(n,Vector3(0,.4,-.03),Vector3(cos(i*TAU/20)*.38,.4+sin(i*TAU/20)*.38,-.03),.004,METAL)
		"darts":for x in [-.12,0,.12]:l(n,Vector3(x,.03,-.25),Vector3(x,.03,.25),.012,METAL);b(n,Vector3(x,.03,.2),Vector3(.08,.005,.1),RED)
		"pool_table","pingpong","foosball":
			b(n,Vector3(0,.7,0),Vector3(1.1,.16,1.7),WOOD);b(n,Vector3(0,.79,0),Vector3(.95,.015,1.55),TEAL);feet(n,1,1.6,.62)
			if k=="pool_table":for x in [-.48,.48]:for z in [-.73,0,.73]:c(n,Vector3(x,.8,z),.06,.01,DARK);for i in range(6):s(n,Vector3(-.12+(i%3)*.1,.83,-.4+int(i/3)*.1),Vector3.ONE*.08,RED if i%2 else CREAM)
			elif k=="pingpong":for x in range(13):l(n,Vector3(-.5+x*.08,.8,0),Vector3(-.5+x*.08,1,0),.005,CREAM);l(n,Vector3(-.5,1,0),Vector3(.5,1,0),.008,DARK)
			else:for z in [-.6,-.2,.2,.6]:l(n,Vector3(-.75,.88,z),Vector3(.75,.88,z),.018,METAL);for x in [-.3,0,.3]:s(n,Vector3(x,.9,z),Vector3(.08,.18,.08),RED if z<0 else BLUE)
		"cue":l(n,Vector3(-.7,.02,0),Vector3(.7,.02,0),.014,WOOD)
		"paddle":s(n,Vector3(0,.06,0),Vector3(.3,.06,.35),RED);b(n,Vector3(0,.06,.28),Vector3(.07,.05,.23),WOOD)
		"bowling_ball":s(n,Vector3(0,.2,0),Vector3.ONE*.4,BLUE);for x in [-.07,.07]:s(n,Vector3(x,.35,-.1),Vector3.ONE*.04,DARK);s(n,Vector3(0,.31,-.16),Vector3.ONE*.04,DARK)
		"disco_ball":s(n,Vector3(0,.3,0),Vector3.ONE*.6,METAL);for i in range(10):ring(n,Vector3(0,.04+i*.055,0),sqrt(maxf(0,.09-pow(.26-i*.055,2))),DARK)
		"puppet":person(n,"puppet","person");for i in [-1,0,1]:l(n,Vector3(i*.25,1.3,0),Vector3(i*.25,2.1,0),.004,CREAM);l(n,Vector3(-.4,2.1,0),Vector3(.4,2.1,0),.025,WOOD)
		"puppet_stage":b(n,Vector3(0,.25,0),Vector3(1.2,.5,.3),WOOD);for x in [-.57,.57]:b(n,Vector3(x,.85,0),Vector3(.08,1.2,.3),WOOD);b(n,Vector3(0,1.4,0),Vector3(1.2,.1,.3),WOOD);for curtain_x in [-.45,.45]:b(n,Vector3(curtain_x,1,0),Vector3(.2,.7,.04),RED)
		"theatre_mask":s(n,Vector3(0,.3,0),Vector3(.45,.6,.08),CREAM);for x in [-.1,.1]:s(n,Vector3(x,.37,-.045),Vector3(.09,.04,.025),DARK);curve(n,[Vector3(-.13,.2,-.05),Vector3(0,.15,-.065),Vector3(.13,.2,-.05)],.015,RED)
		"clapperboard":b(n,Vector3(0,.2,0),Vector3(.65,.4,.035),DARK);var top=b(n,Vector3(.02,.47,0),Vector3(.65,.08,.04),CREAM);top.rotation.z=.2;for j in range(5):var stripe=b(n,Vector3(-.25+j*.13,.47,0),Vector3(.07,.08,.044),DARK);stripe.rotation.z=-.3
		"film_reel":c(n,Vector3(0,.035,0),.3,.07,METAL);for i in range(6):c(n,Vector3(cos(i)*.17,.075,sin(i)*.17),.065,.012,DARK);c(n,Vector3(0,.075,0),.04,.02,DARK)
		"video_camera":b(n,Vector3(0,.25,0),Vector3(.4,.25,.5),DARK);c(n,Vector3(0,.25,-.35),.12,.3,METAL).rotation.x=PI/2;c(n,Vector3(0,.25,-.51),.1,.012,BLUE).rotation.x=PI/2;curve(n,[Vector3(-.15,.4,0),Vector3(-.15,.5,0),Vector3(.15,.5,0),Vector3(.15,.4,0)],.022,DARK)

static func misc(n:Node3D,k:String,id:String)->void:
	match k:
		"travel_pillow":
			var points=[]
			for i in range(25):var angle=.4+i*(TAU-.8)/24;points.append(Vector3(sin(angle)*.26,.1,-cos(angle)*.26))
			curve(n,points,.075,TEAL)
		"sleep_mask":s(n,Vector3(0,.15,0),Vector3(.5,.25,.08),TEAL);curve(n,[Vector3(-.25,.15,0),Vector3(-.25,.15,.2),Vector3(.25,.15,.2),Vector3(.25,.15,0)],.015,DARK)
		"earplugs":for x in [-.1,.1]:c(n,Vector3(x,.1,0),.045,.2,Color("d9af87"),.025)
		"adapter","powerbank","usb","hard_drive","router","power_strip":electronics(n,k)
		"lens":c(n,Vector3(0,.18,0),.16,.36,DARK);for y in [.05,.15,.25]:ring(n,Vector3(0,y,0),.165,METAL);c(n,Vector3(0,.365,0),.14,.012,BLUE)
		"selfie_stick":l(n,Vector3(0,0,0),Vector3(0,.8,0),.02,METAL);b(n,Vector3(0,.88,0),Vector3(.3,.18,.045),DARK)
		"magnet":b(n,Vector3(0,.15,0),Vector3(.35,.3,.04),TEAL);b(n,Vector3(0,.15,-.026),Vector3(.3,.2,.01),WOOD);label(n,"KURDISTAN",Vector3(0,.15,-.04),.00075)
		"rack":
			feet(n,.75,.5,.1);for x in [-.4,.4]:b(n,Vector3(x,.6,0),Vector3(.035,1.2,.06),METAL)
			for y in [.3,.65,1.0]:
				l(n,Vector3(-.4,y,0),Vector3(.4,y,0),.02,METAL)
				for x in [-.26,0,.26]:b(n,Vector3(x,y+.12,0),Vector3(.21,.22,.015),CREAM);b(n,Vector3(x,y+.15,-.012),Vector3(.16,.1,.006),BLUE)
		"shelf","document_tray","desk_organizer","noticeboard","whiteboard","filing_cabinet","locker","parcel_locker","medical_cabinet","safe","display_case","display_fridge":storage(n,k)
		"sports_ball":
			s(n,Vector3(0,.22,0),Vector3.ONE*.44,Color("c4cd6a") if "tennis" in id else TEAL if "medicine" in id else CREAM)
			if "tennis" in id:
				for side in [-1,1]:curve(n,[Vector3(side*.13,.07,-.11),Vector3(side*.2,.18,-.08),Vector3(side*.2,.28,.05),Vector3(side*.13,.39,.1)],.005,CREAM)
			elif "volleyball" in id:
				for angle in [0,PI/3,-PI/3]:var seam=ring(n,Vector3(0,.22,0),.221,TEAL);seam.rotation=Vector3(PI/2,angle,0)
		"bell":c(n,Vector3(0,.04,0),.24,.08,DARK);s(n,Vector3(0,.14,0),Vector3(.4,.2,.4),METAL);c(n,Vector3(0,.26,0),.04,.08,DARK)
		"door_hanger":b(n,Vector3(0,.3,0),Vector3(.2,.6,.015),CREAM);ring(n,Vector3(0,.62,0),.08,CREAM).rotation.x=PI/2;label(n,"PLEASE",Vector3(0,.4,-.01),.0009)
		"parasol":
			l(n,Vector3(0,0,0),Vector3(0,1.8,0),.025,WOOD)
			for i in range(8):
				var tri=SurfaceTool.new();tri.begin(Mesh.PRIMITIVE_TRIANGLES)
				for vertex in [Vector3(0,1.8,0),Vector3(cos(i*TAU/8)*.9,1.5,sin(i*TAU/8)*.9),Vector3(cos((i+1)*TAU/8)*.9,1.5,sin((i+1)*TAU/8)*.9)]:tri.add_vertex(vertex)
				tri.generate_normals();var mesh=MeshInstance3D.new();mesh.mesh=tri.commit();var mat=WorldProps.material(TEAL if i%2 else CREAM).duplicate();mat.cull_mode=BaseMaterial3D.CULL_DISABLED;mesh.material_override=mat;n.add_child(mesh)
		"spotlight":tripod(n);c(n,Vector3(0,1,0),.2,.4,DARK).rotation.x=PI/2;c(n,Vector3(0,1,-.21),.17,.02,CREAM).rotation.x=PI/2
		"fins":for x in [-.18,.18]:s(n,Vector3(x,.07,0),Vector3(.3,.08,.75),TEAL);ring(n,Vector3(x,.12,.23),.08,DARK)
		"snorkel":curve(n,[Vector3(-.12,.05,0),Vector3(0,.05,0),Vector3(.07,.16,0),Vector3(.07,.65,0),Vector3(.04,.73,0)],.025,TEAL);b(n,Vector3(-.14,.05,0),Vector3(.08,.07,.06),DARK)
		"walking_stick":l(n,Vector3(0,0,0),Vector3(0,.9,0),.02,WOOD);curve(n,[Vector3(0,.9,0),Vector3(.1,1,0),Vector3(.22,.9,0)],.025,WOOD)
		"poncho","vest","hi_vis","hoodie","polo","swimsuit","pajamas","costume","beanie","cloth":clothing(n,k)
		"kiosk","recording_booth","photo_booth","changing_room","bus_shelter","bus_stop","metal_detector","lift","checkin_counter","counter":architecture(n,k)
		"binocular_stand":l(n,Vector3(0,0,0),Vector3(0,1,0),.035,METAL);component(n,"new/binoculars",.5,Vector3(0,1,0));c(n,Vector3(0,.02,0),.3,.04,DARK)
		"railing","bike_rack","clothes_rail","safety_barrier":rails(n,k)
		"sign","wayfinding","exit_sign","wet_floor_sign":signage(n,k,id)
		"clay_tablet":b(n,Vector3(0,.24,0),Vector3(.55,.48,.08),WOOD);for j in range(7):for i in range(9):l(n,Vector3(-.24+i*.058,.04+j*.057,-.045),Vector3(-.215+i*.058,.055+j*.057,-.045),.003,DARK)
		"scroll":b(n,Vector3(0,.025,0),Vector3(.65,.01,.75),CREAM);for z in [-.4,.4]:c(n,Vector3(0,.045,z),.055,.72,CREAM).rotation.z=PI/2;for j in range(6):b(n,Vector3(0,.033,-.23+j*.09),Vector3(.4,.003,.008),WOOD)
		"quill":l(n,Vector3(0,0,0),Vector3(.15,.8,0),.01,WOOD);for i in range(12):l(n,Vector3(.05+i*.006,.27+i*.04,0),Vector3(.12+i*.015,.36+i*.04,0),.015,CREAM)
		"wax_seal":c(n,Vector3(0,.018,0),.13,.035,RED);ring(n,Vector3(0,.04,0),.085,WOOD)
		"seal_stamp":c(n,Vector3(0,.025,0),.13,.05,METAL);s(n,Vector3(0,.23,0),Vector3(.15,.4,.15),WOOD)
		"sundial":c(n,Vector3(0,.02,0),.35,.04,METAL);l(n,Vector3(0,.05,0),Vector3(0,.3,-.25),.015,DARK);for i in range(12):l(n,Vector3(cos(i)*.25,.046,sin(i)*.25),Vector3(cos(i)*.32,.046,sin(i)*.32),.004,DARK)
		"astrolabe":ring(n,Vector3(0,.35,0),.35,Color("c7af77")).rotation.x=PI/2;ring(n,Vector3(0,.35,0),.28,METAL).rotation.x=PI/2;for i in range(8):l(n,Vector3(0,.35,0),Vector3(cos(i)*.33,.35+sin(i)*.33,0),.007,METAL);ring(n,Vector3(0,.76,0),.07,METAL).rotation.x=PI/2
		"coin","coin_collection","coin_tray":
			if k!="coin":b(n,Vector3(0,.015,0),Vector3(.7,.03,.5),WOOD)
			for i in range(1 if k=="coin" else 8):var p=Vector3(-.22+(i%4)*.15,.035,int(i/4)*.18-.09);c(n,p,.065,.015,METAL if "silver" in id else Color("bb9e66"));ring(n,p+Vector3(0,.01,0),.05,DARK)
		"portrait":b(n,Vector3(0,.45,0),Vector3(.7,.9,.05),WOOD);b(n,Vector3(0,.45,-.03),Vector3(.6,.8,.012),CREAM);s(n,Vector3(0,.56,-.04),Vector3(.17,.21,.015),WOOD);b(n,Vector3(0,.28,-.04),Vector3(.25,.25,.015),BLUE)
		"mosaic":for i in range(10):for j in range(10):b(n,Vector3(-.4+i*.085,.015,-.4+j*.085),Vector3(.08,.03,.08),TEAL if (i+j)%3 else RED)
		"relief":b(n,Vector3(0,.4,0),Vector3(.8,.8,.08),WOOD);s(n,Vector3(0,.5,-.08),Vector3(.23,.3,.08),CREAM);b(n,Vector3(0,.24,-.08),Vector3(.4,.22,.06),CREAM)
		"column","capital","arch","castle","citadel","watermill","loom","spinning_wheel":heritage(n,k)
		"shredder","printer","scanner","copier","paper_cutter","hole_punch","binder_clip","webcam","monitor_stand","fan","water_cooler","espresso_machine","grinder","cash_register","barcode_scanner","card_reader","ticket_machine","parking_meter","charger","fuel_pump","atm","conveyor","moving_walkway","escalator","turnstile":machine(n,k)
		"lanyard","strap","ribbon","wristband","seat_belt":curve(n,[Vector3(-.2,.03,-.3),Vector3(-.28,.03,.18),Vector3(0,.03,.4),Vector3(.28,.03,.18),Vector3(.2,.03,-.3)],.025,TEAL);b(n,Vector3(0,.04,.4),Vector3(.13,.04,.09),DARK)
		"pick":s(n,Vector3(0,.025,0),Vector3(.2,.05,.25),RED)
		"festival_wristband":ring(n,Vector3(0,.025,0),.2,TEAL)
		"straw":l(n,Vector3(0,.01,0),Vector3(0,.6,0),.014,CREAM);l(n,Vector3(0,.6,0),Vector3(.12,.66,0),.014,CREAM)
		"napkin","wrapping_paper","bubble_wrap":b(n,Vector3(0,.01,0),Vector3(.7,.02,.7),CREAM);if k=="bubble_wrap":for i in range(8):for j in range(8):s(n,Vector3(-.28+i*.08,.03,-.28+j*.08),Vector3(.06,.025,.06),METAL)
		"napkin_holder":b(n,Vector3(0,.02,0),Vector3(.4,.04,.25),METAL);for x in [-.16,.16]:b(n,Vector3(x,.15,0),Vector3(.025,.26,.25),METAL);b(n,Vector3(0,.2,0),Vector3(.2,.35,.2),CREAM)
		"packet","tea_bag","envelope":b(n,Vector3(0,.2,0),Vector3(.3,.4,.018),CREAM);if k=="tea_bag":l(n,Vector3(0,.4,0),Vector3(.1,.7,0),.004,WOOD);b(n,Vector3(.1,.72,0),Vector3(.1,.1,.01),TEAL)
		"strainer":ring(n,Vector3(0,.08,0),.2,METAL);for i in range(7):l(n,Vector3(-.17+i*.055,.07,-.14),Vector3(-.17+i*.055,.07,.14),.004,METAL);l(n,Vector3(.2,.08,0),Vector3(.55,.08,0),.018,METAL)
		"tongs":l(n,Vector3(-.13,.03,0),Vector3(0,.03,.5),.025,METAL);l(n,Vector3(.13,.03,0),Vector3(0,.03,.5),.025,METAL);for x in [-.13,.13]:s(n,Vector3(x,.03,-.04),Vector3(.1,.04,.13),METAL)
		"cake_stand":c(n,Vector3(0,.04,0),.18,.08,CREAM);l(n,Vector3(0,.08,0),Vector3(0,.3,0),.045,CREAM);c(n,Vector3(0,.32,0),.35,.025,CREAM)
		"tape":ring(n,Vector3(0,.07,0),.2,WOOD);ring(n,Vector3(0,.11,0),.2,WOOD)
		"divider":b(n,Vector3(0,.03,0),Vector3(.6,.06,.06),TEAL)
		"crossing":for i in range(6):b(n,Vector3(-.8+i*.32,.006,0),Vector3(.18,.012,1.4),CREAM)
		"crossing_button":b(n,Vector3(0,.17,0),Vector3(.2,.34,.12),DARK);c(n,Vector3(0,.17,-.07),.055,.025,TEAL).rotation.x=PI/2
		"barrier","bollard":
			if k=="bollard":c(n,Vector3(0,.4,0),.1,.8,DARK);ring(n,Vector3(0,.7,0),.105,CREAM)
			else:b(n,Vector3(-.7,.45,0),Vector3(.22,.9,.25),DARK);b(n,Vector3(.1,.8,0),Vector3(1.6,.06,.06),CREAM);for x in range(6):b(n,Vector3(-.6+x*.25,.8,-.036),Vector3(.1,.06,.015),RED)
		"car_seat","child_seat":component(n,"furniture/loungeChair",1.1 if k=="car_seat" else .7);if k=="child_seat":for x in [-.17,.17]:l(n,Vector3(x,.7,-.1),Vector3(0,.3,-.25),.015,DARK)
		"steering_wheel":ring(n,Vector3(0,.1,0),.3,DARK);for i in range(3):l(n,Vector3(0,.1,0),Vector3(cos(i*TAU/3)*.3,.1,sin(i*TAU/3)*.3),.025,DARK);c(n,Vector3(0,.1,0),.09,.06,DARK)
		"dashboard":b(n,Vector3(0,.2,0),Vector3(.9,.4,.2),DARK);for x in [-.2,.2]:c(n,Vector3(x,.24,-.11),.11,.012,METAL).rotation.x=PI/2;l(n,Vector3(x,.24,-.13),Vector3(x+.04,.3,-.13),.008,RED)
		"rearview_mirror":b(n,Vector3(0,.2,0),Vector3(.6,.18,.04),DARK);b(n,Vector3(0,.2,-.025),Vector3(.54,.13,.01),METAL);l(n,Vector3(0,.2,.03),Vector3(0,.4,.15),.025,DARK)
		"wiper":l(n,Vector3(-.3,.03,0),Vector3(.1,.03,.08),.015,METAL);b(n,Vector3(.2,.03,0),Vector3(.6,.025,.025),DARK)
		"headlight","brake_light":s(n,Vector3(0,.13,0),Vector3(.55,.26,.12),DARK);s(n,Vector3(0,.13,-.05),Vector3(.48,.2,.05),CREAM if k=="headlight" else RED)
		"car_jack":curve(n,[Vector3(0,0,0),Vector3(-.25,.25,0),Vector3(0,.5,0),Vector3(.25,.25,0),Vector3(0,0,0)],.03,METAL);l(n,Vector3(-.3,.25,0),Vector3(.3,.25,0),.012,DARK);b(n,Vector3(0,.015,0),Vector3(.4,.03,.2),DARK)
		"jumper_cables":coil(n);for x in [-.45,.45]:b(n,Vector3(x,.05,0),Vector3(.2,.06,.08),RED if x<0 else DARK);l(n,Vector3(x-.1,.05,0),Vector3(x-.17,.05,0),.02,METAL)
		"keyfob":s(n,Vector3(0,.08,0),Vector3(.2,.1,.35),DARK);for z in [-.1,0,.1]:b(n,Vector3(0,.13,z),Vector3(.08,.015,.055),METAL);ring(n,Vector3(0,.05,.22),.06,METAL)
		"recycling_bin":b(n,Vector3(0,.4,0),Vector3(.5,.8,.5),TEAL if "glass" not in id else BLUE);b(n,Vector3(0,.82,0),Vector3(.55,.06,.55),DARK);b(n,Vector3(0,.7,-.26),Vector3(.28,.12,.015),DARK);label(n,"RECYCLE",Vector3(0,.4,-.26),.0015)
		"litter_picker":l(n,Vector3(0,0,0),Vector3(0,.8,0),.014,METAL);for x in [-.08,.08]:l(n,Vector3(0,0,0),Vector3(x,-.1,0),.02,DARK);b(n,Vector3(.03,.75,0),Vector3(.1,.14,.035),DARK)
		"extinguisher","hydrant","hose_reel","smoke_alarm","stretcher","wheelchair","crutches","walker","socket_wrench","utility_knife","wire_stripper","breaker","meter":service(n,k)
		_:push_error("Missing specific daily model: "+k)

static func storage(n:Node3D,k:String)->void:
	if k in ["document_tray","desk_organizer"]:
		b(n,Vector3(0,.02,0),Vector3(.65,.04,.45),METAL);for x in [-.31,.31]:b(n,Vector3(x,.08,0),Vector3(.025,.16,.45),METAL)
		if k=="desk_organizer":for x in [-.2,0,.2]:b(n,Vector3(x,.18,.08),Vector3(.16,.36,.16),WOOD);component(n,"accurate/pen",.3,Vector3(.2,.3,.08))
		return
	if k in ["noticeboard","whiteboard"]:b(n,Vector3(0,.65,0),Vector3(1.15,.85,.07),WOOD);b(n,Vector3(0,.65,-.045),Vector3(1.04,.74,.015),CREAM if k=="whiteboard" else WOOD.darkened(.15));feet(n,1,.5,.25,METAL);for i in range(4):b(n,Vector3(-.3+i*.2,.65,-.06),Vector3(.15,.18,.01),TEAL if k=="noticeboard" else DARK);return
	var open=k in ["rack","shelf","display_case","display_fridge"]
	if open:
		feet(n,.9,.5,.1);for x in [-.45,.45]:b(n,Vector3(x,.6,0),Vector3(.06,1.2,.5),WOOD)
		for y in [.1,.5,.9,1.2]:b(n,Vector3(0,y,0),Vector3(.9,.055,.5),WOOD)
		if k in ["display_case","display_fridge"]:
			for x in [-.43,.43]:for z in [-.23,.23]:l(n,Vector3(x,.1,z),Vector3(x,1.2,z),.018,METAL)
			var glass=WorldProps.material(Color(.55,.75,.77,.2)).duplicate();glass.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
			var panel=b(n,Vector3(0,.65,-.24),Vector3(.85,1.1,.01),BLUE);panel.material_override=glass
		else:
			for j in range(6):b(n,Vector3(-.35+j*.13,.72,.05),Vector3(.06,.35,.2),TEAL if j%2 else RED)
	else:
		b(n,Vector3(0,.6,0),Vector3(.75,1.2,.5),TEAL if k=="medical_cabinet" else WOOD)
		for i in range(4 if k in ["filing_cabinet","parcel_locker"] else 1):
			var h=.27 if k in ["filing_cabinet","parcel_locker"] else 1.05;var y=.16+i*.29 if h<.5 else .6
			b(n,Vector3(0,y,-.26),Vector3(.68,h,.025),METAL if k=="safe" else CREAM);l(n,Vector3(-.1,y,-.3),Vector3(.1,y,-.3),.012,DARK)
		if k=="safe":ring(n,Vector3(0,.75,-.3),.14,DARK).rotation.x=PI/2
		elif k=="medical_cabinet":ExpansionProps.medical_cross(n,Vector3(0,.85,-.29),.22)

static func clothing(n:Node3D,k:String)->void:
	if k=="swimsuit":
		b(n,Vector3(0,.42,0),Vector3(.35,.42,.075),TEAL);b(n,Vector3(0,.16,0),Vector3(.16,.16,.075),TEAL)
		for side in [-1,1]:l(n,Vector3(side*.13,.63,0),Vector3(side*.13,.8,0),.025,TEAL)
		return
	if k=="poncho":
		AccurateProps.lathe(n,[Vector2(.55,.05),Vector2(.23,.7),Vector2(.09,.78),Vector2(.07,.78),Vector2(.21,.68),Vector2(.52,.05)],BLUE).scale.z=.22
		s(n,Vector3(0,.8,.02),Vector3(.23,.22,.19),BLUE);return
	if k=="beanie":s(n,Vector3(0,.22,0),Vector3(.5,.44,.5),TEAL);ring(n,Vector3(0,.06,0),.25,DARK);s(n,Vector3(0,.45,0),Vector3.ONE*.1,CREAM);return
	if k=="cloth":b(n,Vector3(0,.012,0),Vector3(.8,.025,.6),CREAM);for i in range(8):b(n,Vector3(-.35+i*.1,.027,0),Vector3(.024,.008,.55),RED if i%2 else TEAL);return
	var torso=component(n,"accurate/shirt" if k in ["polo","hoodie","pajamas","costume","hi_vis"] else "accurate/life_jacket" if k=="vest" else "accurate/dress" if k=="swimsuit" else "accurate/coat",.85)
	WorldProps.tint(torso,Color("dfb953") if k=="hi_vis" else TEAL if k!="costume" else RED)
	if k=="hoodie":s(n,Vector3(0,.84,0),Vector3(.3,.27,.24),TEAL);b(n,Vector3(0,.38,-.15),Vector3(.25,.12,.018),TEAL.darkened(.15))
	elif k=="hi_vis":for y in [.3,.5]:b(n,Vector3(0,y,-.16),Vector3(.45,.025,.015),CREAM)
	elif k=="pajamas":component(n,"accurate/trousers",.8,Vector3(0,-.6,0))
	elif k=="poncho":b(n,Vector3(0,.3,0),Vector3(.8,.65,.04),BLUE)

static func architecture(n:Node3D,k:String)->void:
	if k in ["counter","checkin_counter"]:b(n,Vector3(0,.5,0),Vector3(1.6,1,.65),WOOD);b(n,Vector3(0,1.02,0),Vector3(1.7,.06,.75),CREAM);if k=="checkin_counter":component(n,"furniture/computerScreen",.5,Vector3(.35,1.05,.12));return
	var w=1.6;var height=1.9;var depth=.9
	if k in ["recording_booth","bus_shelter"]:w=2.4;depth=1.6
	b(n,Vector3(0,.025,0),Vector3(w,.05,depth),WOOD)
	for x in [-w*.5,w*.5]:b(n,Vector3(x,height*.5,0),Vector3(.08,height,depth),TEAL)
	b(n,Vector3(0,height,0),Vector3(w+.12,.12,depth+.1),WOOD)
	if k not in ["metal_detector","bus_stop"]:b(n,Vector3(0,height*.5,depth*.5),Vector3(w,height,.08),DARK if k=="recording_booth" else BLUE)
	if k=="kiosk":b(n,Vector3(0,.5,0),Vector3(w,1,depth),WOOD);label(n,"INFORMATION",Vector3(0,1.6,-depth*.51),.002)
	elif k in ["changing_room","photo_booth"]:b(n,Vector3(0,1,-depth*.51),Vector3(w*.75,1.6,.04),RED)
	elif k=="bus_shelter":component(n,"furniture/bench",1.55,Vector3(0,0,.2))
	elif k=="lift":for x in [-.4,.4]:b(n,Vector3(x,.95,-depth*.5),Vector3(.77,1.85,.025),METAL);b(n,Vector3(w*.45,.9,-depth*.51),Vector3(.07,.15,.03),DARK)
	elif k=="metal_detector":b(n,Vector3(0,height,-depth*.52),Vector3(.6,.1,.02),DARK)

static func rails(n:Node3D,k:String)->void:
	if k=="bike_rack":for i in range(5):curve(n,[Vector3(-.6+i*.3,0,-.2),Vector3(-.6+i*.3,.55,-.2),Vector3(-.6+i*.3,.55,.2),Vector3(-.6+i*.3,0,.2)],.025,METAL)
	else:
		for x in [-.6,.6]:l(n,Vector3(x,0,0),Vector3(x,1,0),.025,METAL);b(n,Vector3(x,.025,0),Vector3(.2,.05,.5),DARK)
		l(n,Vector3(-.6,1,0),Vector3(.6,1,0),.025,METAL)
		if k!="clothes_rail":for i in range(8):l(n,Vector3(-.55+i*.16,0,0),Vector3(-.55+i*.16,.95,0),.016,METAL)
		else:for i in range(3):component(n,"accurate/shirt",.35,Vector3(-.35+i*.35,.45,0))

static func signage(n:Node3D,k:String,id:String)->void:
	if k=="wet_floor_sign":
		for z in [-.15,.15]:var panel=b(n,Vector3(0,.35,z),Vector3(.45,.7,.035),Color("dfbc67"));panel.rotation.x=.3 if z<0 else -.3
		label(n,"CAUTION",Vector3(0,.4,-.27),.0015);return
	l(n,Vector3(0,0,0),Vector3(0,.8,0),.025,METAL);b(n,Vector3(0,.82,0),Vector3(.85,.4,.05),TEAL if k=="exit_sign" else BLUE);label(n,"EXIT →" if k=="exit_sign" else "← CITY  |  PARK →" if k=="wayfinding" else id.trim_prefix("daily_").replace("_"," ").to_upper(),Vector3(0,.82,-.03),.0013)

static func heritage(n:Node3D,k:String)->void:
	match k:
		"capital":
			c(n,Vector3(0,.08,0),.17,.16,CREAM);b(n,Vector3(0,.21,0),Vector3(.5,.1,.5),CREAM)
			for x in [-.18,.18]:ring(n,Vector3(x,.17,-.22),.075,CREAM).rotation.x=PI/2
		"column":c(n,Vector3(0,.04,0),.25,.08,CREAM);c(n,Vector3(0,.65,0),.17,1.2,CREAM);b(n,Vector3(0,1.3,0),Vector3(.5,.1,.5),CREAM);for i in range(12):l(n,Vector3(cos(i)*.17,.15,sin(i)*.17),Vector3(cos(i)*.17,1.2,sin(i)*.17),.01,WOOD)
		"arch":
			for x in [-.5,.5]:b(n,Vector3(x,.45,0),Vector3(.2,.9,.3),CREAM)
			for i in range(9):var stone=b(n,Vector3(cos(i*PI/8)*.5,.9+sin(i*PI/8)*.5,0),Vector3(.22,.22,.3),CREAM);stone.rotation.z=i*PI/8
		"castle","citadel":
			b(n,Vector3(0,.4,0),Vector3(1.4,.8,1.1),WOOD)
			for x in [-.65,.65]:for z in [-.5,.5]:c(n,Vector3(x,.65,z),.2,1.3,CREAM);for i in range(6):b(n,Vector3(x+cos(i)*.15,1.3,z+sin(i)*.15),Vector3(.1,.13,.1),CREAM)
			b(n,Vector3(0,.25,-.56),Vector3(.25,.5,.025),DARK);for i in range(8):b(n,Vector3(-.6+i*.17,.86,-.5),Vector3(.08,.12,.16),CREAM)
		"watermill":
			component(n,"suburban/building-type-a",1.4);ring(n,Vector3(.8,.45,0),.45,WOOD).rotation.z=PI/2
			for i in range(10):l(n,Vector3(.8,.45,0),Vector3(.8,.45+cos(i)*.45,sin(i)*.45),.025,WOOD);b(n,Vector3(.8,.45+cos(i)*.45,sin(i)*.45),Vector3(.3,.07,.09),WOOD)
		"loom":
			for x in [-.5,.5]:b(n,Vector3(x,.6,0),Vector3(.07,1.2,.07),WOOD)
			for y in [.1,1.2]:l(n,Vector3(-.5,y,0),Vector3(.5,y,0),.035,WOOD)
			for i in range(20):l(n,Vector3(-.45+i*.048,.15,0),Vector3(-.45+i*.048,1.15,0),.003,CREAM)
			for j in range(10):l(n,Vector3(-.48,.2+j*.04,-.01),Vector3(.48,.2+j*.04,-.01),.006,RED if j%2 else TEAL)
		"spinning_wheel":ring(n,Vector3(0,.5,0),.45,WOOD).rotation.x=PI/2;for i in range(10):l(n,Vector3(0,.5,0),Vector3(cos(i)*.45,.5+sin(i)*.45,0),.017,WOOD);feet(n,.8,.5,.35);l(n,Vector3(.4,.5,0),Vector3(.7,.75,0),.025,WOOD)

static func electronics(n:Node3D,k:String)->void:
	b(n,Vector3(0,.06,0),Vector3(.5,.12,.3),DARK)
	if k=="power_strip":for x in [-.18,0,.18]:ring(n,Vector3(x,.13,0),.045,CREAM);coil(n,.2)
	elif k=="router":for x in [-.17,.17]:l(n,Vector3(x,.08,.12),Vector3(x,.45,.17),.013,DARK)
	elif k=="adapter":for x in [-.07,.07]:l(n,Vector3(x,.12,0),Vector3(x,.26,0),.013,METAL)
	elif k=="usb":b(n,Vector3(0,.06,-.22),Vector3(.3,.1,.16),METAL);for x in [-.07,.07]:b(n,Vector3(x,.11,-.24),Vector3(.04,.007,.05),DARK)
	else:for i in range(4):s(n,Vector3(-.12+i*.08,.125,0),Vector3.ONE*.012,TEAL)

static func machine(n:Node3D,k:String)->void:
	match k:
		"printer","copier","scanner","shredder":
			var h=.8 if k=="copier" else .15 if k=="scanner" else .35
			b(n,Vector3(0,h*.5,0),Vector3(.75,h,.6),CREAM);b(n,Vector3(0,h+.025,0),Vector3(.7,.05,.55),DARK);b(n,Vector3(0,h*.45,-.31),Vector3(.55,.045,.015),DARK)
			if k=="shredder":b(n,Vector3(0,h+.07,0),Vector3(.4,.1,.01),CREAM)
			elif k!="scanner":b(n,Vector3(0,h*.45,-.4),Vector3(.4,.015,.25),CREAM)
			b(n,Vector3(.25,h+.055,-.2),Vector3(.12,.01,.08),BLUE)
		"paper_cutter":b(n,Vector3(0,.03,0),Vector3(.65,.06,.5),TEAL);l(n,Vector3(.28,.07,-.25),Vector3(.28,.45,.25),.02,DARK);for i in range(5):b(n,Vector3(-.2+i*.1,.064,0),Vector3(.004,.002,.45),CREAM)
		"hole_punch":b(n,Vector3(0,.025,0),Vector3(.4,.05,.2),DARK);var lever=b(n,Vector3(0,.14,0),Vector3(.4,.08,.2),METAL);lever.rotation.x=.2;for x in [-.1,.1]:c(n,Vector3(x,.075,0),.02,.1,METAL)
		"binder_clip":b(n,Vector3(0,.1,0),Vector3(.24,.2,.12),DARK);for z in [-.07,.07]:curve(n,[Vector3(-.09,.13,z),Vector3(-.09,.4,z),Vector3(.09,.4,z),Vector3(.09,.13,z)],.008,METAL)
		"webcam":b(n,Vector3(0,.13,0),Vector3(.35,.18,.13),DARK);c(n,Vector3(0,.13,-.075),.055,.015,BLUE).rotation.x=PI/2;b(n,Vector3(0,.04,0),Vector3(.2,.03,.2),DARK)
		"monitor_stand":b(n,Vector3(0,.04,0),Vector3(.5,.08,.35),METAL);l(n,Vector3(0,.04,0),Vector3(0,.5,.1),.03,METAL);b(n,Vector3(0,.5,.1),Vector3(.25,.3,.035),DARK)
		"fan":
			c(n,Vector3(0,.02,0),.24,.04,CREAM);l(n,Vector3(0,.04,0),Vector3(0,.5,0),.025,METAL);ring(n,Vector3(0,.7,0),.3,METAL).rotation.x=PI/2
			for i in range(12):l(n,Vector3(0,.7,-.03),Vector3(cos(i)*.29,.7+sin(i)*.29,-.03),.005,METAL)
			for i in range(3):var blade=s(n,Vector3(cos(i*TAU/3)*.14,.7+sin(i*TAU/3)*.14,0),Vector3(.3,.1,.025),TEAL);blade.rotation.z=i*TAU/3
		"water_cooler":b(n,Vector3(0,.4,0),Vector3(.45,.8,.4),CREAM);c(n,Vector3(0,1,0),.2,.4,BLUE);for x in [-.09,.09]:l(n,Vector3(x,.64,-.21),Vector3(x,.6,-.3),.02,RED if x<0 else BLUE);b(n,Vector3(0,.35,-.24),Vector3(.3,.06,.16),DARK)
		"espresso_machine":b(n,Vector3(0,.3,0),Vector3(.7,.6,.4),METAL);b(n,Vector3(0,.04,-.2),Vector3(.7,.08,.35),DARK);for x in [-.16,.16]:l(n,Vector3(x,.35,-.23),Vector3(x,.35,-.42),.025,DARK);c(n,Vector3(x,.33,-.25),.06,.04,METAL);component(n,"food/cup",.18,Vector3(x,.08,-.25));c(n,Vector3(0,.5,-.21),.07,.015,CREAM).rotation.x=PI/2
		"grinder":b(n,Vector3(0,.18,0),Vector3(.35,.36,.3),DARK);c(n,Vector3(0,.5,0),.2,.28,BLUE,.16);c(n,Vector3(0,.65,0),.21,.025,DARK);b(n,Vector3(0,.2,-.2),Vector3(.12,.08,.15),METAL)
		"cash_register","card_reader","barcode_scanner":
			if k=="cash_register":b(n,Vector3(0,.07,0),Vector3(.6,.14,.5),DARK);b(n,Vector3(0,.24,.05),Vector3(.4,.22,.25),CREAM);for i in range(12):b(n,Vector3(-.12+(i%4)*.08,.36,-.03+int(i/4)*.07),Vector3(.06,.01,.05),DARK);b(n,Vector3(0,.39,.15),Vector3(.35,.1,.02),BLUE)
			elif k=="barcode_scanner":l(n,Vector3(0,0,0),Vector3(.1,.25,0),.055,DARK);b(n,Vector3(.08,.3,0),Vector3(.25,.12,.15),DARK);b(n,Vector3(.08,.3,-.08),Vector3(.18,.06,.01),RED)
			else:b(n,Vector3(0,.08,0),Vector3(.25,.16,.4),DARK);b(n,Vector3(0,.165,.08),Vector3(.2,.015,.13),BLUE);for i in range(9):b(n,Vector3(-.065+(i%3)*.065,.17,-.12+int(i/3)*.05),Vector3(.04,.015,.03),CREAM)
		"ticket_machine","parking_meter","charger","fuel_pump","atm":
			b(n,Vector3(0,.55,0),Vector3(.55,1.1,.4),TEAL);b(n,Vector3(0,.8,-.21),Vector3(.38,.25,.015),DARK);b(n,Vector3(0,.55,-.21),Vector3(.28,.03,.015),METAL)
			if k in ["charger","fuel_pump"]:curve(n,[Vector3(.28,.9,0),Vector3(.55,.65,0),Vector3(.55,.1,0),Vector3(.3,.3,0)],.025,DARK);b(n,Vector3(.32,.35,0),Vector3(.1,.22,.04),DARK)
			elif k=="parking_meter":l(n,Vector3(0,0,0),Vector3(0,.6,0),.05,METAL)
			else:for i in range(9):b(n,Vector3(-.07+(i%3)*.07,.7-int(i/3)*.06,-.22),Vector3(.045,.025,.015),CREAM)
		"conveyor","moving_walkway","escalator":
			b(n,Vector3(0,.2,0),Vector3(1,.4,2),DARK)
			for i in range(12):b(n,Vector3(0,.42+(i*.055 if k=="escalator" else 0),-.9+i*.16),Vector3(.8,.045,.12),METAL)
			for x in [-.5,.5]:l(n,Vector3(x,.5,-1),Vector3(x,1.1 if k=="escalator" else .5,1),.035,DARK)
		"turnstile":b(n,Vector3(0,.4,0),Vector3(.35,.8,.3),METAL);for i in range(3):l(n,Vector3(.2,.6,0),Vector3(.2,.6+cos(i*TAU/3)*.35,sin(i*TAU/3)*.35),.025,METAL)

static func service(n:Node3D,k:String)->void:
	match k:
		"extinguisher":c(n,Vector3(0,.35,0),.14,.7,RED);l(n,Vector3(-.1,.76,0),Vector3(.1,.76,0),.02,DARK);curve(n,[Vector3(.08,.7,0),Vector3(.25,.6,0),Vector3(.25,.2,0)],.022,DARK);b(n,Vector3(0,.35,-.145),Vector3(.15,.2,.015),CREAM)
		"hydrant":c(n,Vector3(0,.38,0),.18,.76,RED);s(n,Vector3(0,.78,0),Vector3(.36,.15,.36),RED);l(n,Vector3(-.3,.4,0),Vector3(.3,.4,0),.075,RED)
		"hose_reel":ring(n,Vector3(0,.32,0),.32,RED).rotation.x=PI/2;for i in range(4):ring(n,Vector3(0,.32,-.02-i*.03),.22,DARK).rotation.x=PI/2
		"smoke_alarm":c(n,Vector3(0,.04,0),.25,.08,CREAM);for i in range(12):b(n,Vector3(cos(i)*.18,.085,sin(i)*.18),Vector3(.03,.008,.06),DARK)
		"stretcher":b(n,Vector3(0,.5,0),Vector3(.65,.08,1.7),TEAL);feet(n,.7,1.5,.45,METAL);for x in [-.3,.3]:for z in [-.6,.6]:c(n,Vector3(x,.06,z),.065,.05,DARK).rotation.z=PI/2;for rail_x in [-.4,.4]:l(n,Vector3(rail_x,.5,-1),Vector3(rail_x,.5,1),.025,METAL)
		"wheelchair":
			b(n,Vector3(0,.5,0),Vector3(.55,.07,.5),TEAL);b(n,Vector3(0,.8,.23),Vector3(.55,.6,.05),TEAL)
			for x in [-.35,.35]:c(n,Vector3(x,.3,.1),.3,.045,DARK).rotation.z=PI/2;ring(n,Vector3(x*1.05,.3,.1),.27,METAL).rotation.z=PI/2;c(n,Vector3(x,.075,-.35),.075,.04,DARK).rotation.z=PI/2;l(n,Vector3(x,.1,-.3),Vector3(x,.9,.23),.025,METAL);l(n,Vector3(x,.6,-.15),Vector3(x,.7,-.15),.02,METAL);b(n,Vector3(x,.71,-.1),Vector3(.07,.04,.4),DARK)
		"crutches","walker":
			for x in [-.3,.3]:curve(n,[Vector3(x-.08,0,0),Vector3(x-.08,.9,0),Vector3(x+.08,.9,0),Vector3(x+.08,0,.2 if k=="walker" else 0)],.02,METAL);l(n,Vector3(x-.1,.5,0),Vector3(x+.1,.5,0),.025,DARK)
			if k=="walker":l(n,Vector3(-.3,.75,0),Vector3(.3,.75,0),.025,METAL)
		"socket_wrench":l(n,Vector3(-.3,.05,0),Vector3(.3,.05,0),.025,METAL);c(n,Vector3(.3,.07,0),.075,.1,METAL);ring(n,Vector3(.3,.13,0),.045,DARK)
		"utility_knife":b(n,Vector3(0,.06,0),Vector3(.4,.12,.08),TEAL);b(n,Vector3(.3,.06,0),Vector3(.25,.07,.018),METAL);b(n,Vector3(0,.125,0),Vector3(.1,.025,.03),DARK)
		"wire_stripper":for side in [-1,1]:l(n,Vector3(side*.15,.02,-.2),Vector3(0,.02,.1),.025,RED);l(n,Vector3(0,.02,.1),Vector3(side*.08,.02,.3),.018,METAL)
		"breaker","meter":
			b(n,Vector3(0,.3,0),Vector3(.35,.6,.2),CREAM)
			if k=="meter":c(n,Vector3(0,.4,-.11),.1,.01,BLUE).rotation.x=PI/2;label(n,"01234",Vector3(0,.23,-.11),.001)
			else:b(n,Vector3(0,.3,-.13),Vector3(.1,.15,.08),DARK)





