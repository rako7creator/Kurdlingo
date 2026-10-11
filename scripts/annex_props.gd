class_name AnnexProps
extends RefCounted

const DARK = Color("334554")
const WOOD = Color("b88b5d")
const METAL = Color("a5b8bf")
const CREAM = Color("f4e4bd")

static func b(n: Node3D,p: Vector3,size: Vector3,col: Color = METAL) -> void:WorldProps.box(n,p,size,col)
static func s(n: Node3D,p: Vector3,size: Vector3,col: Color = CREAM) -> void:WorldProps.sphere(n,p,size,col)
static func c(n: Node3D,p: Vector3,r: float,h: float,col: Color = METAL,top: float = -1.0) -> void:WorldProps.cylinder(n,p,r,h,col,top)
static func l(n: Node3D,a: Vector3,z: Vector3,r: float,col: Color = METAL) -> void:WorldProps.line(n,a,z,r,col)
static func ring(n: Node3D,p: Vector3,r: float,col: Color = METAL) -> MeshInstance3D:
	var mesh=TorusMesh.new();mesh.inner_radius=r*0.72;mesh.outer_radius=r;mesh.rings=20;mesh.ring_segments=10
	var part=MeshInstance3D.new();part.mesh=mesh;part.position=p;part.material_override=WorldProps.material(col);n.add_child(part);return part

static func make(k: String) -> Node3D:
	var n=Node3D.new()
	var col=Color.from_hsv(float(absi(k.hash())%90)/90.0,0.36,0.85)
	if k in ["sugar","flour","lentils","beans","peas"]:
		c(n,Vector3(0,0.12,0),0.5,0.16,WOOD,0.58)
		for i in range(24):s(n,Vector3(sin(i*2.4)*0.4,0.25+(i%3)*0.035,cos(i*2.4)*0.4),Vector3(0.13,0.1,0.13),Color("eee3bf") if k in ["sugar","flour"] else Color("7baf6b") if k=="peas" else Color("bc9468"))
	elif k in ["walnut","almond","pistachio","fig","date_fruit","pomegranate","peach","apricot","plum"]:
		var colors={"walnut":"aa8255","almond":"c6a26d","pistachio":"a5b871","fig":"946589","date_fruit":"93664a","pomegranate":"c65556","peach":"edac88","apricot":"efb660","plum":"83669d"}
		s(n,Vector3(0,0.35,0),Vector3(0.6,0.68,0.6),Color(colors[k]));l(n,Vector3(0,0.6,0),Vector3(0.05,0.78,0),0.03,WOOD)
		if k=="walnut":
			for i in range(5):l(n,Vector3(-0.15+i*0.07,0.25,0.28),Vector3(-0.15+i*0.07,0.55,0.22),0.013,WOOD)
	elif k in ["rabbit","goat","donkey","pig","duck","goose","rooster","chick","pigeon","owl","eagle","parrot","penguin","flamingo","swan","peacock","fox","wolf","lion","tiger","leopard","elephant","giraffe","zebra","camel","deer","monkey","kangaroo","panda","hedgehog","squirrel","mouse","bat","frog","snake","lizard","crocodile","turtle","snail","ant","ladybird","spider","scorpion","crab","lobster","octopus","jellyfish","starfish","seahorse","shark","dolphin","whale","seal","nest","beehive"]:
		n.add_child(AnimalModels.make(k))
	elif k in ["shirt","t_shirt","trousers","shorts","skirt","dress","jacket","coat","sweater","scarf","hat","cap","sock","shoe","boot","sandal","slipper","belt","glove","glasses","sunglasses","watch","ring","necklace","bracelet","wallet","handbag","suitcase","hanger","hairbrush","hair_dryer","razor","perfume","lipstick","combination_lock","life_jacket","swimming_goggles"]:
		clothing(n,k,col)
	elif k in ["piano","guitar","violin","drum","flute","trumpet","accordion","microphone","headphones","music_stand","skateboard","scooter","roller_skate","tennis_racket","badminton_racket","baseball_bat","basketball_hoop","football_goal","bowling_pin","surfboard"]:
		leisure(n,k,col)
	else:equipment(n,k,col)
	assert(n.get_child_count()>0,"Missing recognizable model: "+k)
	return n

static func animal(n: Node3D,k: String) -> void:
	var colors={"pig":"e8a0a2","fox":"d39355","lion":"cfb477","tiger":"d6a059","leopard":"d2b074","elephant":"9aa9b5","giraffe":"d3b36e","zebra":"eee9d9","panda":"eee9d9","frog":"84b36b","crocodile":"809e72","flamingo":"df9fac","parrot":"70aa7b","penguin":"36424e","whale":"779bac","shark":"8aabb6","dolphin":"94b5bb"}
	var col=Color(colors.get(k,"bcab8d"))
	if k in ["nest","beehive"]:
		for i in range(6):ring(n,Vector3(0,0.12+i*0.095,0),0.6-abs(i-2)*0.07,WOOD)
		if k=="nest":
			for i in range(3):s(n,Vector3(-0.2+i*0.2,0.27,0),Vector3(0.18,0.26,0.18),CREAM)
		else:s(n,Vector3(0,0.25,0.45),Vector3(0.13,0.12,0.02),DARK)
		return
	if k in ["shark","dolphin","whale","seal","seahorse"]:
		s(n,Vector3(0,0.5,0),Vector3(1.7,0.65,0.6),col)
		for side in [-1,1]:s(n,Vector3(-0.9,0.5,side*0.25),Vector3(0.3,0.15,0.7),col)
		l(n,Vector3(0,0.7,0),Vector3(-0.1,1.1,0),0.1,col)
		s(n,Vector3(0.6,0.62,0.28),Vector3(0.06,0.06,0.06),DARK)
		if k=="dolphin":s(n,Vector3(0.88,0.51,0),Vector3(0.4,0.16,0.23),col)
		if k=="shark":c(n,Vector3(0,0.88,0),0.19,0.4,col,0)
		if k=="seahorse":ring(n,Vector3(-0.7,0.35,0),0.3,col).rotation.x=PI/2
		return
	if k in ["octopus","jellyfish","starfish","crab","lobster","ant","ladybird","spider","scorpion","snail","snake","lizard","crocodile","turtle","frog","bat"]:
		if k=="snake":
			for i in range(18):s(n,Vector3(-0.8+i*0.1,0.18,sin(i*0.6)*0.25),Vector3(0.17,0.17,0.17),Color("88a36a"))
		else:
			s(n,Vector3(0,0.4,0),Vector3(0.9,0.55,0.7),col)
			var count=8 if k in ["octopus","spider"] else 6 if k in ["ant","ladybird","scorpion","crab","lobster"] else 5 if k=="starfish" else 4
			for i in range(count):
				var a=float(i)/count*TAU
				l(n,Vector3(cos(a)*0.3,0.35,sin(a)*0.3),Vector3(cos(a)*0.85,0.08,sin(a)*0.85),0.06 if k!="starfish" else 0.15,col)
			if k in ["snail","turtle"]:
				s(n,Vector3(0,0.6,0),Vector3(0.7,0.65,0.7),Color("9b865d"));ring(n,Vector3(0,0.83,0),0.25,WOOD)
			if k in ["lobster","crab","scorpion"]:
				for side in [-1,1]:
					l(n,Vector3(0.25,0.4,side*0.25),Vector3(0.9,0.4,side*0.55),0.07,col);ring(n,Vector3(0.95,0.4,side*0.55),0.16,col).rotation.x=PI/2
			if k in ["crocodile","lizard"]:
				s(n,Vector3(0.7,0.4,0),Vector3(0.8,0.2,0.3),col);l(n,Vector3(-0.4,0.4,0),Vector3(-1.2,0.12,0),0.12,col)
			if k=="bat":
				for side in [-1,1]:s(n,Vector3(0,0.5,side*0.6),Vector3(0.7,0.05,0.9),DARK)
			if k=="ladybird":
				s(n,Vector3(0,0.5,0),Vector3(0.75,0.4,0.65),Color("cf6e6c"))
				for i in range(6):s(n,Vector3(sin(i)*0.27,0.66,cos(i)*0.22),Vector3(0.1,0.04,0.1),DARK)
		for side in [-1,1]:s(n,Vector3(0.4,0.55,side*0.15),Vector3(0.08,0.08,0.08),DARK)
		return
	var birds=["duck","goose","rooster","chick","pigeon","owl","eagle","parrot","penguin","flamingo","swan","peacock"]
	var avian=k in birds
	var tall=k in ["giraffe","flamingo"]
	var h=1.5 if tall else 0.45 if k in ["rabbit","chick","mouse","hedgehog"] else 0.7
	s(n,Vector3(0,h,0),Vector3(0.65 if k in ["penguin","owl","kangaroo"] else 1.0,1.0 if k in ["penguin","owl","kangaroo"] else 0.65,0.62),col)
	for side in [-1,1]:
		for x in ([0.0] if avian else [-0.32,0.32]):l(n,Vector3(x,h-0.2,side*0.23),Vector3(x,0.1,side*0.23),0.055,col)
	var head_y=h+0.8 if tall else h+0.3
	l(n,Vector3(0.35,h,0),Vector3(0.45,head_y,0),0.14,col)
	s(n,Vector3(0.5,head_y,0),Vector3(0.44,0.45,0.4),col)
	for side in [-1,1]:
		s(n,Vector3(0.65,head_y+0.05,side*0.15),Vector3(0.07,0.07,0.07),DARK)
		if avian:
			s(n,Vector3(-0.05,h,side*0.3),Vector3(0.65,0.35,0.1),col)
		else:
			s(n,Vector3(0.4,head_y+0.25,side*0.19),Vector3(0.11,0.5 if k in ["rabbit","donkey"] else 0.2,0.15),col)
	if avian:
		l(n,Vector3(0.65,head_y,0),Vector3(0.96,head_y-0.03,0),0.07,Color("d8b15e"))
		if k=="rooster":s(n,Vector3(0.5,head_y+0.25,0),Vector3(0.2,0.18,0.07),Color("c96763"))
		if k=="peacock":
			for i in range(9):l(n,Vector3(-0.5,h,0),Vector3(-0.7,h+sin(i*PI/8)*0.9,-0.8+i*0.2),0.06,Color("568b8d"))
	else:l(n,Vector3(-0.45,h,0),Vector3(-0.9,h-0.15,0),0.06,col)
	if k in ["goat","deer","giraffe"]:
		for side in [-1,1]:l(n,Vector3(0.45,head_y+0.16,side*0.12),Vector3(0.28,head_y+0.6,side*0.22),0.04,WOOD)
	if k=="elephant":
		l(n,Vector3(0.7,head_y,0),Vector3(0.95,head_y-0.55,0),0.1,col)
		for side in [-1,1]:s(n,Vector3(0.38,head_y,side*0.35),Vector3(0.4,0.7,0.1),col)
	if k=="lion":s(n,Vector3(0.4,head_y,0),Vector3(0.65,0.7,0.65),WOOD);s(n,Vector3(0.65,head_y,0),Vector3(0.35,0.4,0.4),col)
	if k=="camel":
		for x in [-0.25,0.18]:s(n,Vector3(x,h+0.32,0),Vector3(0.36,0.42,0.4),col)
	if k=="squirrel":s(n,Vector3(-0.5,h+0.15,0),Vector3(0.38,0.9,0.4),col)
	if k=="kangaroo":l(n,Vector3(-0.2,h-0.1,0),Vector3(-0.95,0.08,0),0.14,col);s(n,Vector3(0.3,h,0),Vector3(0.3,0.4,0.6),WOOD)
	if k=="hedgehog":
		for i in range(24):l(n,Vector3(-0.4+(i%6)*0.14,h+0.22,-0.2+int(i/6)*0.13),Vector3(-0.45+(i%6)*0.14,h+0.42,-0.2+int(i/6)*0.13),0.022,WOOD)
	if k in ["penguin","owl"]:s(n,Vector3(0.1,h,0.3),Vector3(0.4,0.7,0.09),CREAM)
	if k=="pig":s(n,Vector3(0.72,head_y-0.04,0),Vector3(0.18,0.22,0.25),Color("cf898e"));ring(n,Vector3(-0.61,h,0),0.1,col).rotation.z=PI/2
	if k in ["tiger","zebra","giraffe","leopard","panda"]:
		for i in range(6):
			for side in [-1,1]:b(n,Vector3(-0.36+i*0.14,h,side*0.3),Vector3(0.06,0.38,0.025),WOOD if k in ["giraffe","leopard"] else DARK)

static func clothing(n: Node3D,k: String,col: Color) -> void:
	if k in ["shirt","t_shirt","jacket","coat","sweater","dress","life_jacket"]:
		b(n,Vector3(0,0.75,0),Vector3(0.7,0.95,0.22),col)
		for side in [-1,1]:l(n,Vector3(side*0.3,1.15,0),Vector3(side*0.68,0.6 if k!="t_shirt" else 0.9,0),0.13,col)
		c(n,Vector3(0,1.25,0),0.13,0.05,CREAM)
		if k in ["coat","dress"]:c(n,Vector3(0,0.25,0),0.45,0.5,col,0.3)
		if k in ["shirt","jacket","coat"]:
			for i in range(4):s(n,Vector3(0,0.55+i*0.18,0.13),Vector3(0.035,0.035,0.035),CREAM)
	elif k in ["trousers","shorts"]:
		b(n,Vector3(0,1,0),Vector3(0.65,0.35,0.25),col)
		for side in [-1,1]:b(n,Vector3(side*0.18,0.48 if k=="trousers" else 0.75,0),Vector3(0.28,0.85 if k=="trousers" else 0.35,0.25),col)
	elif k=="skirt":c(n,Vector3(0,0.4,0),0.55,0.8,col,0.3)
	elif k in ["hat","cap"]:
		c(n,Vector3(0,0.06,0),0.55,0.1,col);s(n,Vector3(0,0.16,0),Vector3(0.7,0.45,0.7),col)
		if k=="cap":b(n,Vector3(0,0.1,0.45),Vector3(0.6,0.05,0.5),col)
	elif k in ["shoe","boot","sandal","slipper","sock"]:
		b(n,Vector3(0,0.06,0.1),Vector3(0.35,0.12,0.75),DARK);s(n,Vector3(0,0.2,0.18),Vector3(0.36,0.35,0.62),col)
		if k in ["boot","sock"]:c(n,Vector3(0,0.55,-0.1),0.18,0.7,col)
		if k=="sandal":b(n,Vector3(0,0.23,0.32),Vector3(0.38,0.04,0.1),WOOD)
	elif k in ["glasses","sunglasses","swimming_goggles"]:
		for side in [-1,1]:
			ring(n,Vector3(side*0.25,0.3,0),0.23,DARK).rotation.x=PI/2;l(n,Vector3(side*0.47,0.3,0),Vector3(side*0.47,0.3,-0.5),0.025,DARK)
			if k!="glasses":s(n,Vector3(side*0.25,0.3,0),Vector3(0.35,0.32,0.035),Color("6a9eae"))
		l(n,Vector3(-0.1,0.3,0),Vector3(0.1,0.3,0),0.025,DARK)
	elif k in ["ring","bracelet","necklace","belt","watch","scarf"]:
		ring(n,Vector3(0,0.22,0),0.48,col)
		if k=="watch":b(n,Vector3(0,0.27,0.4),Vector3(0.3,0.1,0.3),CREAM);l(n,Vector3(0,0.33,0.4),Vector3(0.08,0.33,0.43),0.01,DARK)
		if k in ["necklace","ring"]:s(n,Vector3(0,0.32,0.45),Vector3(0.16,0.2,0.16),Color("75b6b2"))
		if k=="scarf":b(n,Vector3(0.3,0.1,0.6),Vector3(0.25,0.08,0.8),col)
	elif k=="glove":
		b(n,Vector3(0,0.35,0),Vector3(0.38,0.5,0.13),col)
		for i in range(4):l(n,Vector3(-0.15+i*0.1,0.5,0),Vector3(-0.15+i*0.1,0.95-abs(i-1)*0.07,0),0.045,col)
		l(n,Vector3(-0.15,0.4,0),Vector3(-0.4,0.65,0),0.055,col)
	elif k=="hanger":
		l(n,Vector3(-0.55,0.2,0),Vector3(0,0.5,0),0.025,WOOD);l(n,Vector3(0,0.5,0),Vector3(0.55,0.2,0),0.025,WOOD);l(n,Vector3(-0.55,0.2,0),Vector3(0.55,0.2,0),0.025,WOOD);ring(n,Vector3(0,0.66,0),0.13,METAL).rotation.x=PI/2
	elif k in ["handbag","suitcase","wallet"]:
		b(n,Vector3(0,0.4,0),Vector3(0.85,0.75,0.3),col);ring(n,Vector3(0,0.87,0),0.2,WOOD).rotation.x=PI/2
		if k=="suitcase":
			for side in [-1,1]:s(n,Vector3(side*0.32,0.05,0),Vector3(0.12,0.12,0.12),DARK)
	elif k in ["perfume","lipstick"]:
		c(n,Vector3(0,0.3,0),0.18,0.55,col);c(n,Vector3(0,0.68,0),0.1,0.25,DARK if k=="perfume" else Color("d9677d"))
	elif k=="hairbrush":
		b(n,Vector3(0,0.2,0),Vector3(0.35,0.16,0.6),WOOD);l(n,Vector3(0,0.2,0.25),Vector3(0,0.2,0.8),0.08,WOOD)
		for i in range(18):l(n,Vector3(-0.1+(i%3)*0.1,0.25,-0.2+int(i/3)*0.08),Vector3(-0.1+(i%3)*0.1,0.4,-0.2+int(i/3)*0.08),0.012,DARK)
	elif k=="hair_dryer":l(n,Vector3(-0.3,0.7,0),Vector3(0.35,0.7,0),0.18,col);l(n,Vector3(0.1,0.65,0),Vector3(0.2,0.15,0),0.1,col)
	elif k=="razor":l(n,Vector3(0,0.05,0),Vector3(0,0.7,0),0.06,col);b(n,Vector3(0,0.73,0),Vector3(0.4,0.08,0.15),METAL)
	elif k=="combination_lock":b(n,Vector3(0,0.3,0),Vector3(0.4,0.4,0.16),DARK);ring(n,Vector3(0,0.6,0),0.2).rotation.x=PI/2;ring(n,Vector3(0,0.3,0.1),0.13).rotation.x=PI/2

static func leisure(n: Node3D,k: String,col: Color) -> void:
	if k in ["guitar","violin"]:
		s(n,Vector3(0,0.4,0),Vector3(0.65,0.75,0.16),WOOD);s(n,Vector3(0,0.7,0),Vector3(0.45,0.45,0.16),WOOD);b(n,Vector3(0,1.1,0),Vector3(0.13,0.75,0.08),WOOD)
		s(n,Vector3(0,0.55,0.09),Vector3(0.17,0.17,0.02),DARK)
		for i in range(6):l(n,Vector3(-0.04+i*0.016,0.3,0.1),Vector3(-0.04+i*0.016,1.4,0.1),0.003,METAL)
	elif k=="piano":
		b(n,Vector3(0,0.75,0),Vector3(1.6,0.9,0.6),DARK)
		for i in range(18):b(n,Vector3(-0.73+i*0.085,0.65,0.45),Vector3(0.078,0.05,0.3),CREAM)
		for side in [-1,1]:b(n,Vector3(side*0.65,0.3,0),Vector3(0.1,0.6,0.5),DARK)
	elif k=="accordion":
		b(n,Vector3(0,0.5,0),Vector3(1,0.7,0.35),col)
		for i in range(12):b(n,Vector3(-0.32+i*0.05,0.5,0.2),Vector3(0.018,0.68,0.04),DARK)
		for i in range(8):b(n,Vector3(0.42,0.2+i*0.08,0.23),Vector3(0.16,0.065,0.06),CREAM)
	elif k in ["flute","trumpet"]:
		l(n,Vector3(-0.6,0.3,0),Vector3(0.6,0.3,0),0.06 if k=="flute" else 0.1,METAL)
		for i in range(6):s(n,Vector3(-0.3+i*0.12,0.36,0),Vector3(0.04,0.015,0.04),DARK)
		if k=="trumpet":ring(n,Vector3(0.65,0.3,0),0.25,Color("d7bd74")).rotation.z=PI/2
	elif k in ["drum","bowling_pin","baseball_bat","microphone"]:
		if k=="drum":c(n,Vector3(0,0.4,0),0.45,0.7,col);c(n,Vector3(0,0.76,0),0.46,0.03,CREAM)
		elif k=="baseball_bat":l(n,Vector3(0,0.1,0),Vector3(0,1.3,0),0.06,WOOD);c(n,Vector3(0,1,0),0.13,0.7,WOOD)
		elif k=="bowling_pin":s(n,Vector3(0,0.35,0),Vector3(0.4,0.6,0.4));c(n,Vector3(0,0.7,0),0.08,0.35,CREAM);s(n,Vector3(0,0.92,0),Vector3(0.22,0.22,0.22));c(n,Vector3(0,0.8,0),0.09,0.04,col)
		else:c(n,Vector3(0,0.35,0),0.06,0.65,DARK);s(n,Vector3(0,0.75,0),Vector3(0.22,0.28,0.22),METAL)
	elif k=="headphones":ring(n,Vector3(0,0.5,0),0.45,DARK).rotation.x=PI/2; b(n,Vector3(-0.4,0.35,0),Vector3(0.2,0.35,0.2),col);b(n,Vector3(0.4,0.35,0),Vector3(0.2,0.35,0.2),col)
	elif k in ["music_stand","football_goal","basketball_hoop"]:
		if k=="football_goal":
			for side in [-1,1]:l(n,Vector3(side,0,0),Vector3(side,1.2,0),0.04,CREAM)
			l(n,Vector3(-1,1.2,0),Vector3(1,1.2,0),0.04,CREAM)
			for i in range(11):l(n,Vector3(-1+i*0.2,1.2,0),Vector3(-1+i*0.2,0,-0.6),0.008,CREAM)
		else:
			l(n,Vector3(0,0,0),Vector3(0,1.7,0),0.05,DARK)
			b(n,Vector3(0,1.6,0),Vector3(0.9,0.55,0.08),CREAM if k=="basketball_hoop" else DARK)
			if k=="basketball_hoop":ring(n,Vector3(0,1.4,0.35),0.32,col)
			else:
				for side in [-1,1]:l(n,Vector3(0,0.15,0),Vector3(side*0.4,0,0.3),0.03,DARK)
	elif k in ["tennis_racket","badminton_racket"]:
		l(n,Vector3(0,0,0),Vector3(0,0.6,0),0.05,WOOD);ring(n,Vector3(0,0.93,0),0.4,col).rotation.x=PI/2
		for i in range(7):l(n,Vector3(-0.27+i*0.09,0.67,0),Vector3(-0.27+i*0.09,1.2,0),0.006,CREAM);l(n,Vector3(-0.28,0.68+i*0.085,0),Vector3(0.28,0.68+i*0.085,0),0.006,CREAM)
	elif k in ["skateboard","scooter","roller_skate","surfboard"]:
		s(n,Vector3(0,0.18,0),Vector3(0.45,0.08,1.2),col)
		if k=="surfboard":s(n,Vector3(0,0.17,-0.3),Vector3(0.38,0.08,1.6),col)
		else:
			for side in [-1,1]:
				for z in [-0.4,0.4]:s(n,Vector3(side*0.23,0.08,z),Vector3(0.13,0.13,0.13),DARK)
			if k=="scooter":l(n,Vector3(0,0.2,-0.5),Vector3(0,1.3,-0.5),0.04,METAL);l(n,Vector3(-0.3,1.3,-0.5),Vector3(0.3,1.3,-0.5),0.04,DARK)
			if k=="roller_skate":s(n,Vector3(0,0.37,0),Vector3(0.38,0.38,0.7),WOOD)

static func equipment(n: Node3D,k: String,col: Color) -> void:
	match k:
		"screwdriver","chisel","file_tool","drill_bit","needle","pipette","chalk":
			l(n,Vector3(0,0.02,0),Vector3(0,0.95,0),0.022 if k in ["needle","pipette"] else 0.045,METAL)
			if k in ["screwdriver","chisel","file_tool"]:c(n,Vector3(0,0.78,0),0.1,0.45,col)
			if k=="needle":ring(n,Vector3(0,0.9,0),0.04).rotation.x=PI/2
		"wrench","pliers","clamp","vise":
			b(n,Vector3(0,0.4,0),Vector3(0.1,0.7,0.1),METAL)
			for side in [-1,1]:l(n,Vector3(0,0.68,0),Vector3(side*0.18,0.88,0),0.07,METAL)
			if k=="pliers":
				for side in [-1,1]:l(n,Vector3(0,0.5,0),Vector3(side*0.2,0.08,0),0.07,col)
			if k in ["clamp","vise"]:b(n,Vector3(0,0.18,0),Vector3(0.55,0.25,0.4),col);l(n,Vector3(-0.4,0.2,0),Vector3(0.4,0.2,0),0.035)
		"screw","nail","bolt":
			c(n,Vector3(0,0.38,0),0.05,0.7);c(n,Vector3(0,0.75,0),0.15,0.06)
			if k!="nail":
				for i in range(10):ring(n,Vector3(0,0.1+i*0.05,0),0.085)
		"nut","washer_ring","gear":
			ring(n,Vector3(0,0.15,0),0.4)
			if k=="gear":
				for i in range(14):b(n,Vector3(sin(i*TAU/14)*0.4,0.15,cos(i*TAU/14)*0.4),Vector3(0.12,0.12,0.12))
			if k=="nut":c(n,Vector3(0,0.15,0),0.35,0.22);c(n,Vector3(0,0.27,0),0.15,0.005,DARK)
		"spring","chain","hose","electric_cable","thread":
			for i in range(12):
				if k=="chain":ring(n,Vector3(0,0.1+i*0.07,0),0.13).rotation.x=PI/2 if i%2==0 else 0
				elif k=="spring":ring(n,Vector3(0,0.05+i*0.06,0),0.3)
				else:ring(n,Vector3(0,0.1+i*0.012,0),0.46,col)
			if k=="thread":c(n,Vector3(0,0.2,0),0.2,0.4,WOOD)
		"padlock":b(n,Vector3(0,0.25,0),Vector3(0.4,0.4,0.2),col);ring(n,Vector3(0,0.58,0),0.22).rotation.x=PI/2
		"anvil":b(n,Vector3(0,0.1,0),Vector3(0.8,0.2,0.5),DARK);b(n,Vector3(0,0.35,0),Vector3(0.35,0.4,0.3),DARK);b(n,Vector3(0,0.57,0),Vector3(0.9,0.18,0.4),METAL);l(n,Vector3(0.35,0.57,0),Vector3(0.85,0.57,0),0.08)
		"sandpaper","ruler","spirit_level","measuring_tape","protractor":
			if k=="protractor":ring(n,Vector3(0,0.06,0),0.5,col)
			elif k=="measuring_tape":b(n,Vector3(-0.25,0.2,0),Vector3(0.4,0.4,0.2),col);b(n,Vector3(0.3,0.07,0),Vector3(0.8,0.04,0.15),CREAM)
			else:b(n,Vector3(0,0.05,0),Vector3(1,0.08,0.3),WOOD if k=="sandpaper" else col)
			if k!="sandpaper":
				for i in range(12):b(n,Vector3(-0.43+i*0.075,0.1,0.07),Vector3(0.01,0.006,0.09),DARK)
		"drill":b(n,Vector3(0,0.6,0),Vector3(0.6,0.3,0.22),col);b(n,Vector3(0.12,0.32,0),Vector3(0.16,0.55,0.2),col);l(n,Vector3(-0.25,0.6,0),Vector3(-0.65,0.6,0),0.03)
		"paintbrush","paint_roller","broom","mop","razor":
			l(n,Vector3(0,0.1,0),Vector3(0,1,0),0.035,WOOD)
			if k=="paint_roller":l(n,Vector3(-0.25,1,0),Vector3(0.25,1,0),0.13,col)
			else:b(n,Vector3(0,1,0),Vector3(0.45,0.25,0.16),CREAM if k=="mop" else WOOD)
		"paint_tin","battery","light_bulb","flashlight","lantern","perfume":
			c(n,Vector3(0,0.35,0),0.25 if k in ["paint_tin","lantern"] else 0.12,0.65,col)
			if k=="light_bulb":s(n,Vector3(0,0.6,0),Vector3(0.4,0.5,0.4),CREAM)
			if k=="flashlight":c(n,Vector3(0,0.68,0),0.22,0.2,DARK);c(n,Vector3(0,0.79,0),0.18,0.01,CREAM)
			if k=="lantern":ring(n,Vector3(0,0.85,0),0.2).rotation.x=PI/2;s(n,Vector3(0,0.45,0),Vector3(0.3,0.45,0.3),CREAM)
		"palette":s(n,Vector3(0,0.05,0),Vector3(0.9,0.08,0.7),WOOD);for i in range(6):s(n,Vector3(sin(i)*0.3,0.1,cos(i)*0.25),Vector3(0.15,0.03,0.15),Color.from_hsv(i/6.0,0.6,0.8))
		"plug","socket":
			b(n,Vector3(0,0.2,0),Vector3(0.4,0.35,0.16),CREAM)
			for side in [-1,1]:
				if k=="plug":l(n,Vector3(side*0.1,0.2,0.1),Vector3(side*0.1,0.2,0.35),0.03)
				else:s(n,Vector3(side*0.1,0.2,0.1),Vector3(0.05,0.05,0.03),DARK)
		"solar_panel":
			b(n,Vector3(0,0.2,0),Vector3(1.2,0.1,0.9),Color("577b9c"))
			for i in range(5):b(n,Vector3(-0.5+i*0.25,0.26,0),Vector3(0.012,0.01,0.86),METAL)
			for i in range(4):b(n,Vector3(0,0.26,-0.4+i*0.26),Vector3(1.18,0.01,0.012),METAL)
		"wind_turbine":
			l(n,Vector3.ZERO,Vector3(0,2.3,0),0.08,CREAM)
			for i in range(3):l(n,Vector3(0,2.3,0),Vector3(sin(i*TAU/3),2.3+cos(i*TAU/3),0),0.07,CREAM)
		"pipe","valve","faucet","funnel":
			c(n,Vector3(0,0.4,0),0.1,0.8)
			if k=="funnel":c(n,Vector3(0,0.7,0),0.12,0.5,col,0.5)
			else:l(n,Vector3(0,0.75,0),Vector3(0.4,0.75,0),0.1)
			if k=="valve":ring(n,Vector3(0,0.9,0),0.25,col)
		"sponge","dustpan","eraser","pencil_sharpener","stamp":
			b(n,Vector3(0,0.13,0),Vector3(0.6,0.25,0.4),col)
			if k=="dustpan":l(n,Vector3(0,0.2,-0.2),Vector3(0,0.65,-0.4),0.05,col)
			if k=="stamp":c(n,Vector3(0,0.4,0),0.1,0.35,WOOD)
			if k=="pencil_sharpener":s(n,Vector3(0,0.13,0.21),Vector3(0.15,0.15,0.01),DARK)
		"vacuum_cleaner":s(n,Vector3(0,0.25,0),Vector3(0.7,0.5,1),col);l(n,Vector3(0,0.35,0.4),Vector3(0,1,0.8),0.045);b(n,Vector3(0,0.04,0.85),Vector3(0.55,0.08,0.2),DARK)
		"sewing_machine":b(n,Vector3(0,0.1,0),Vector3(1,0.15,0.5),CREAM);b(n,Vector3(0.3,0.5,0),Vector3(0.25,0.75,0.3),CREAM);b(n,Vector3(-0.05,0.8,0),Vector3(0.9,0.25,0.3),CREAM);l(n,Vector3(-0.35,0.75,0),Vector3(-0.35,0.2,0),0.015)
		"button":c(n,Vector3(0,0.05,0),0.3,0.08,col);for i in range(4):s(n,Vector3(-0.07+(i%2)*0.14,0.1,-0.07+int(i/2)*0.14),Vector3(0.05,0.01,0.05),DARK)
		"zipper":b(n,Vector3(0,0.02,0),Vector3(0.2,0.04,1),col);for i in range(15):b(n,Vector3(-0.03+(i%2)*0.06,0.06,-0.45+i*0.06),Vector3(0.09,0.05,0.04))
		"safety_pin","paperclip":ring(n,Vector3(0,0.12,0),0.4).scale=Vector3(0.45,1,1.3);l(n,Vector3(0.15,0.12,-0.35),Vector3(0.15,0.12,0.4),0.02)
		"helmet":s(n,Vector3(0,0.3,0),Vector3(0.75,0.5,0.7),col);c(n,Vector3(0,0.12,0),0.43,0.06,col)
		"safety_goggles":clothing(n,"swimming_goggles",col)
		"workbench":b(n,Vector3(0,0.85,0),Vector3(1.6,0.13,0.75),WOOD);for side in [-1,1]:for z in [-0.3,0.3]:b(n,Vector3(side*0.65,0.42,z),Vector3(0.1,0.84,0.1),WOOD)
		"globe","planet","moon","atom_model":
			s(n,Vector3(0,0.65,0),Vector3(0.9,0.9,0.9),Color("76abc0") if k=="globe" else col)
			if k=="globe":
				for i in range(10):s(n,Vector3(sin(i*2.3)*0.37,0.65+cos(i*2.3)*0.28,0.3),Vector3(0.22,0.15,0.07),Color("92b37d"))
				c(n,Vector3(0,0.06,0),0.35,0.1,WOOD)
			if k in ["planet","atom_model"]:ring(n,Vector3(0,0.65,0),0.65,METAL).rotation.z=0.3
			if k=="atom_model":
				for i in range(3):
					ring(n,Vector3(0,0.65,0),0.7,METAL).rotation=Vector3(i*PI/3,0,i*PI/3)
					s(n,Vector3(sin(i*TAU/3)*0.7,0.65,cos(i*TAU/3)*0.7),Vector3(0.14,0.14,0.14),Color("d59585"))
		"map","calendar","envelope","postcard","clipboard","folder","canvas","blackboard":
			b(n,Vector3(0,0.55,0),Vector3(0.9,1,0.04),DARK if k=="blackboard" else CREAM)
			if k=="map":for i in range(5):l(n,Vector3(-0.35,0.15+i*0.16,0.03),Vector3(0.3,0.3+i*0.13,0.03),0.01,Color("6ba58b"))
			elif k=="envelope":l(n,Vector3(-0.45,1,0.03),Vector3(0,0.5,0.03),0.01,WOOD);l(n,Vector3(0.45,1,0.03),Vector3(0,0.5,0.03),0.01,WOOD)
			else:for i in range(5):b(n,Vector3(0,0.25+i*0.14,0.028),Vector3(0.6,0.012,0.005),CREAM if k=="blackboard" else WOOD)
		"compass","stopwatch","scale","calculator":
			if k=="calculator":
				b(n,Vector3(0,0.12,0),Vector3(0.45,0.2,0.7),DARK);b(n,Vector3(0,0.225,-0.2),Vector3(0.35,0.01,0.16),Color("9fb9a4"))
				for i in range(12):b(n,Vector3(-0.12+(i%3)*0.12,0.23,-0.03+int(i/3)*0.08),Vector3(0.08,0.03,0.05),CREAM)
			else:c(n,Vector3(0,0.12,0),0.4,0.2,METAL);c(n,Vector3(0,0.23,0),0.34,0.01,CREAM);l(n,Vector3(0,0.25,0),Vector3(0.2,0.25,-0.23),0.02,DARK)
		"telescope","microscope","magnifying_glass","camera","tripod","binoculars":
			if k=="camera":b(n,Vector3(0,0.4,0),Vector3(0.8,0.5,0.25),DARK);s(n,Vector3(0,0.4,0.2),Vector3(0.35,0.35,0.2),Color("739ab0"))
			elif k=="magnifying_glass":ring(n,Vector3(0,0.65,0),0.35).rotation.x=PI/2;l(n,Vector3(0,0.02,0),Vector3(0,0.38,0),0.06,WOOD)
			elif k=="binoculars":for side in [-1,1]:l(n,Vector3(side*0.24,0.3,-0.3),Vector3(side*0.24,0.3,0.3),0.17,DARK)
			else:
				for i in range(3):l(n,Vector3(0,0.8,0),Vector3(sin(i*TAU/3)*0.45,0,cos(i*TAU/3)*0.45),0.025)
				if k!="tripod":l(n,Vector3(-0.3,0.85,0),Vector3(0.4,1.05,0),0.14,DARK)
				if k=="microscope":b(n,Vector3(0,0.45,0),Vector3(0.5,0.04,0.4),DARK)
		"rocket","spaceship","satellite","astronaut":
			if k=="astronaut":n.add_child(WorldProps.custom("human"));s(n,Vector3(0,1.65,0),Vector3(0.7,0.7,0.7),CREAM);s(n,Vector3(0,1.65,0.3),Vector3(0.45,0.4,0.1),Color("8bafb8"))
			elif k=="satellite":c(n,Vector3(0,0.5,0),0.25,0.6);for side in [-1,1]:b(n,Vector3(side*0.65,0.5,0),Vector3(0.8,0.05,0.65),Color("5b7f9e"))
			else:
				c(n,Vector3(0,0.85,0),0.27,1.5,CREAM);c(n,Vector3(0,1.8,0),0.27,0.45,col,0)
				for side in [-1,1]:b(n,Vector3(side*0.34,0.3,0),Vector3(0.28,0.5,0.15),col)
				s(n,Vector3(0,1.1,0.25),Vector3(0.2,0.2,0.05),Color("6b9fae"))
		"star","meteorite","crystal","fossil","shell","prism":
			if k=="star":for i in range(5):l(n,Vector3(0,0.45,0),Vector3(sin(i*TAU/5)*0.6,0.45+cos(i*TAU/5)*0.6,0),0.14,Color("e7cc86"))
			elif k in ["crystal","prism"]:
				var mesh=CylinderMesh.new();mesh.radial_segments=3 if k=="prism" else 6;mesh.bottom_radius=0.4;mesh.top_radius=0.4 if k=="prism" else 0;mesh.height=0.9
				var piece=MeshInstance3D.new();piece.mesh=mesh;piece.position.y=0.45;piece.material_override=WorldProps.material(Color("94bfc5"));n.add_child(piece)
			elif k=="shell":for i in range(7):l(n,Vector3(0,0.1,0),Vector3(sin(-PI/2+i*PI/6)*0.5,0.13,cos(-PI/2+i*PI/6)*0.6),0.1,CREAM)
			else:s(n,Vector3(0,0.22,0),Vector3(1,0.5,0.8),WOOD);ring(n,Vector3(0,0.47,0),0.25,CREAM) if k=="fossil" else s(n,Vector3(0.2,0.4,0.2),Vector3(0.2,0.15,0.2),DARK)
		"thermometer":b(n,Vector3(0,0.55,0),Vector3(0.2,1.1,0.08),CREAM);l(n,Vector3(0,0.08,0.05),Vector3(0,0.9,0.05),0.02,Color("d87777"));s(n,Vector3(0,0.08,0.05),Vector3(0.1,0.1,0.1),Color("d87777"))
		"hourglass":
			for y in [0.05,0.95]:c(n,Vector3(0,y,0),0.35,0.08,WOOD)
			c(n,Vector3(0,0.27,0),0.3,0.42,CREAM,0.03);c(n,Vector3(0,0.71,0),0.03,0.42,Color("a6c7c9"),0.3)
		"magnet":
			for side in [-1,1]:b(n,Vector3(side*0.25,0.4,0),Vector3(0.18,0.7,0.18),Color("c87070") if side==1 else Color("729bbe"))
			b(n,Vector3(0,0.1,0),Vector3(0.5,0.18,0.18),DARK)
		"test_tube","beaker","flask":
			c(n,Vector3(0,0.35,0),0.09 if k=="test_tube" else 0.3,0.7,Color("a5c9ce"))
			if k=="flask":s(n,Vector3(0,0.3,0),Vector3(0.7,0.6,0.7),Color("8cb6c3"));c(n,Vector3(0,0.7,0),0.1,0.4,Color("a5c9ce"))
		"dna_model":for i in range(12):l(n,Vector3(sin(i*0.6)*0.25,i*0.1,cos(i*0.6)*0.25),Vector3(-sin(i*0.6)*0.25,i*0.1,-cos(i*0.6)*0.25),0.035,col);s(n,Vector3(sin(i*0.6)*0.25,i*0.1,cos(i*0.6)*0.25),Vector3(0.1,0.1,0.1),col)
		"abacus":
			for side in [-1,1]:b(n,Vector3(side*0.5,0.5,0),Vector3(0.05,1,0.1),WOOD)
			for i in range(5):
				l(n,Vector3(-0.5,0.13+i*0.18,0),Vector3(0.5,0.13+i*0.18,0),0.01)
				for j in range(6):s(n,Vector3(-0.35+j*0.13,0.13+i*0.18,0),Vector3(0.1,0.12,0.12),col)
		"backpack","lunchbox":b(n,Vector3(0,0.45,0),Vector3(0.65,0.85,0.3),col);b(n,Vector3(0,0.25,0.2),Vector3(0.45,0.3,0.12),WOOD);ring(n,Vector3(0,0.95,0),0.16).rotation.x=PI/2
		"stapler":b(n,Vector3(0,0.05,0),Vector3(0.22,0.08,0.65),DARK);b(n,Vector3(0,0.2,0),Vector3(0.22,0.13,0.65),col)
		"paint_easel":
			for side in [-1,1]:l(n,Vector3(side*0.5,0,0),Vector3(0,1.6,0),0.035,WOOD)
			l(n,Vector3(0,1.5,0),Vector3(0,0,-0.5),0.035,WOOD);b(n,Vector3(0,0.9,0),Vector3(0.85,0.65,0.05),CREAM)
		"sculpture":c(n,Vector3(0,0.15,0),0.4,0.3);s(n,Vector3(0,0.65,0),Vector3(0.6,0.8,0.4));s(n,Vector3(0,1.2,0),Vector3(0.35,0.4,0.35))
		"trophy":c(n,Vector3(0,0.06,0),0.3,0.12,WOOD);c(n,Vector3(0,0.4,0),0.06,0.7);c(n,Vector3(0,0.85,0),0.13,0.4,Color("d5ba75"),0.4);for side in [-1,1]:ring(n,Vector3(side*0.3,0.87,0),0.2,Color("d5ba75")).rotation.x=PI/2
		"medal":c(n,Vector3(0,0.08,0),0.28,0.05,Color("d5ba75"));b(n,Vector3(0,0.04,-0.55),Vector3(0.22,0.02,0.8),col)
		"flag":l(n,Vector3.ZERO,Vector3(0,1.5,0),0.025);b(n,Vector3(0.4,1.15,0),Vector3(0.8,0.55,0.02),col)
		"chessboard":
			for i in range(64):b(n,Vector3(-0.44+(i%8)*0.125,0.04,-0.44+int(i/8)*0.125),Vector3(0.125,0.08,0.125),CREAM if (i%8+int(i/8))%2==0 else DARK)
		"die":
			b(n,Vector3(0,0.25,0),Vector3(0.5,0.5,0.5),CREAM)
			for i in range(5):s(n,Vector3(-0.15+(i%2)*0.3,0.12+int(i/2)*0.12,0.255),Vector3(0.055,0.055,0.015),DARK)
		_:push_error("Unimplemented object: "+k)
