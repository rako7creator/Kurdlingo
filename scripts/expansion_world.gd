class_name ExpansionWorld
extends RefCounted
var world:Node3D
const DISTRICTS=["Tourist Quarter","History Museum","Work Hub","Entertainment Park","Cafe Street","Shopping Avenue","Fitness Square","Podcast Plaza","Travel Terminal","City Services"]
var flower_count=0
func _init(owner_node:Node3D)->void:world=owner_node
func prop(model:String,p:Vector3,size:float,angle:float=0)->Node3D:return world.decoration(model,p,size,angle)
func build()->void:
	for index in range(DISTRICTS.size()):build_district(DISTRICTS[index],index)
	for region in ["Town","Homes","Park","Kitchen","Workshop","Discovery","Lifestyle"]:flowers(world.REGION_CENTERS[region],region,90,37)
func pavilion(c:Vector3,color:Color,w:float=14)->void:
	world.solid_box(c+Vector3(0,.1,0),Vector3(w,.2,7),Color("ddd0b0"),false)
	for x in [-w*.48,w*.48]:
		for z in [-3,3]:world.solid_box(c+Vector3(x,2,z),Vector3(.2,4,.2),color,false)
	world.solid_box(c+Vector3(0,4.1,0),Vector3(w+.8,.2,7.8),color,false)
func build_district(region:String,index:int)->void:
	var c:Vector3=world.REGION_CENTERS[region];var color:Color=world.REGION_COLORS[region]
	world.solid_box(c+Vector3(0,.012,0),Vector3(150,.024,166),Color("98b889") if region not in ["Podcast Plaza","Travel Terminal","History Museum"] else Color("c7c1ae"),false)
	world.solid_box(c+Vector3(0,.05,0),Vector3(5,.06,158),Color("e4dbc2"),false)
	for z in [-57,53]:world.solid_box(c+Vector3(0,.05,z),Vector3(146,.06,4),Color("e4dbc2"),false)
	var direction=1 if c.z<0 else -1
	world.solid_box(c+Vector3(0,.05,direction*88),Vector3(5,.06,18),Color("e4dbc2"),false)
	world.signpost(region.to_upper(),c+Vector3(-5,0,direction*77),color)
	for side in [-1,1]:
		for j in range(8):prop("nature/tree_oak",c+Vector3(side*70,0,-70+j*20),4.5+j%3)
		for z in [-58,50]:prop("furniture/bench",c+Vector3(side*12,0,z),1.55,side*PI/2)
		for z in [-30,25]:prop("custom/streetlight",c+Vector3(side*44,0,z),4)
		for z in [-42,-5,35]:prop("furniture/pottedPlant",c+Vector3(side*43,0,z),1.1)
		pavilion(c+Vector3(side*49,0,-7),color,10)
	flowers(c,region,420,73)
	match region:
		"Tourist Quarter":
			for side in [-1,1]:
				prop("suburban/building-type-a",c+Vector3(side*45,0,55),14);world.signpost("HOTEL" if side<0 else "VISITOR CENTRE",c+Vector3(side*43,0,45),color)
				prop("daily/parasol",c+Vector3(side*43,0,-5),4);prop("furniture/loungeChairRelax",c+Vector3(side*43,0,0),1.5)
			prop("watercraft/boat-sail-a",c+Vector3(62,0,-62),8);world.solid_box(c+Vector3(62,.015,-62),Vector3(25,.025,20),Color("83c6cf"),false)
		"History Museum":
			for x in [-30,-15,15,30]:prop("daily/column",c+Vector3(x,0,-70),5)
			prop("daily/arch",c+Vector3(0,0,-70),7);prop("daily/citadel",c+Vector3(-62,0,58),10);prop("daily/loom",c+Vector3(60,0,58),3)
			for side in [-1,1]:prop("daily/statue",c+Vector3(side*46,0,0),2.8);prop("daily/display_case",c+Vector3(side*45,0,17),3)
		"Work Hub":
			for side in [-1,1]:
				prop("commercial/building-a",c+Vector3(side*45,0,60),15)
				for z in [-30,0,28]:prop("furniture/desk",c+Vector3(side*44,0,z),2.3);prop("furniture/computerScreen",c+Vector3(side*44,1.3,z+.3),.7);prop("furniture/chairDesk",c+Vector3(side*44,0,z-1),1.3)
			prop("daily/whiteboard",c+Vector3(0,0,60),2.5)
		"Entertainment Park":
			prop("daily/stage",c+Vector3(0,0,66),13);prop("daily/curtain",c+Vector3(0,.7,73),9);prop("daily/drum_kit",c+Vector3(-3,1,67),2.6);prop("daily/digital_piano",c+Vector3(3,1,67),2)
			for side in [-1,1]:prop("daily/arcade",c+Vector3(side*45,0,12),2.5);prop("daily/pool_table",c+Vector3(side*45,0,-20),3)
		"Cafe Street":
			for side in [-1,1]:
				world.signpost("CAFE" if side<0 else "BAKERY",c+Vector3(side*45,0,48),color)
				for z in [-25,0,25]:prop("furniture/tableRound",c+Vector3(side*44,0,z),1.5);prop("daily/parasol",c+Vector3(side*44,0,z),3.6);prop("furniture/chair",c+Vector3(side*42,0,z),1.34,side*PI/2)
				prop("suburban/building-type-a",c+Vector3(side*45,0,66),11);prop("daily/espresso_machine",c+Vector3(side*45,.9,58),1);prop("furniture/kitchenBar",c+Vector3(side*45,0,58),3)
		"Shopping Avenue":
			for side in [-1,1]:
				for z in [-27,0,27]:prop("daily/clothes_rail",c+Vector3(side*45,0,z),2.5);prop("daily/mannequin",c+Vector3(side*49,0,z),1.9)
				prop("daily/kiosk",c+Vector3(side*45,0,60),9);world.signpost("BOOKS" if side<0 else "CLOTHES",c+Vector3(side*42,0,48),color)
		"Fitness Square":
			for side in [-1,1]:
				prop("daily/pullup_bar",c+Vector3(side*45,0,-25),3);prop("daily/rowing_machine",c+Vector3(side*45,0,0),2.2);prop("daily/exercise_bike",c+Vector3(side*45,0,25),1.8)
			world.solid_box(c+Vector3(0,.035,64),Vector3(70,.035,14),Color("bfa593"),false)
			for z in [59,63,67,71]:world.solid_box(c+Vector3(0,.06,z),Vector3(70,.015,.1),Color("eee7d4"),false)
		"Travel Terminal":
			prop("trains/railroad-straight",c+Vector3(-60,0,0),24,PI/2);prop("trains/train-locomotive-passenger-a",c+Vector3(-60,.1,0),12,PI/2)
			prop("daily/bus_shelter",c+Vector3(62,0,2),6);prop("daily/bus",c+Vector3(62,0,-25),6);prop("daily/electric_scooter",c+Vector3(0,0,62),1.7)
		"City Services":
			for side in [-1,1]:prop("commercial/building-b",c+Vector3(side*45,0,55),13);world.signpost("POST OFFICE" if side<0 else "COMMUNITY SERVICES",c+Vector3(side*43,0,44),color)
			for side in [-1,1]:prop("daily/recycling_bin",c+Vector3(side*45,0,-20),1.2);prop("daily/atm",c+Vector3(side*45,0,4),1.8)
		"Podcast Plaza":
			for side in [-1,1]:prop("nature/tree_oak",c+Vector3(side*49,0,60),7);prop("furniture/loungeSofa",c+Vector3(side*45,0,35),2.4,side*PI/2)
func word_position(row:Dictionary,index:int)->Vector3:
	var c:Vector3=world.REGION_CENTERS[row.region]
	var column=index%10;var x=(-5-(4-column)*7) if column<5 else (5+(column-5)*7)
	var z=-26+int(index/10)*11
	if row.region=="Podcast Plaza":z=28+int(index/10)*8
	var p=c+Vector3(x,0,z)
	if float(row.size)<1.2:
		world.solid_box(p+Vector3(0,.39,0),Vector3(1.15,.78,.95),world.REGION_COLORS[row.region].lightened(.15),false);p.y=.8
	return p

func flowers(c:Vector3,region:String,count:int,radius:float)->void:
	# Hardware instancing keeps thousands of petals inexpensive on the RTX 3070.
	var petals=[];var stems=[];var hues=[];var random=RandomNumberGenerator.new();random.seed=absi(region.hash())
	for i in range(count):
		var x=random.randf_range(-radius,radius);var z=random.randf_range(-radius,radius)
		if radius>40:
			if i%3==0:x=(5.4+random.randf_range(0,2.2))*(-1 if i%2==0 else 1);z=random.randf_range(-49,45)
			elif i%3==1:z=(-62 if i%2==0 else 58)+random.randf_range(-.9,.9);x=random.randf_range(-72,72)
		if absf(x)<5 or absf(z+57)<3 or absf(z-53)<3:continue
		if radius>40 and absf(x)>10 and absf(x)<68 and z>-50 and z<45:continue
		var p=c+Vector3(x,0,z);var height=random.randf_range(.18,.33)
		if absf(p.z-270)<7 or absf(p.z+270)<7:continue
		if absf(p.x)<130 and (absf(p.x+28)<8 or absf(p.x-15)<8 or absf(p.z+20)<7 or absf(p.z-30)<7):continue
		if i%3==1 and radius>40:p.y=.14
		stems.append(Transform3D(Basis.IDENTITY.scaled(Vector3(.025,height,.025)),p+Vector3(0,height*.5,0)))
		var col=[Color("db8c9e"),Color("e7c66d"),Color("ad91c3"),Color("f0e6d1")][i%4]
		for j in range(5):petals.append(Transform3D(Basis.IDENTITY.scaled(Vector3(.15,.05,.15)),p+Vector3(cos(j*TAU/5)*.085,height,sin(j*TAU/5)*.085)));hues.append(col)
		flower_count+=1
	for entry in [[stems,Color("56845b")],[petals,Color("ead3aa") if region!="Flower Garden" else Color("dfa6bb")]]:
		var inst=MultiMeshInstance3D.new();var mm=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.use_colors=true;var mesh=SphereMesh.new();mesh.radius=.5;mesh.height=1;mesh.radial_segments=8;mesh.rings=4;mm.mesh=mesh;mm.instance_count=entry[0].size()
		var is_petal=entry[0]==petals
		for i in range(entry[0].size()):mm.set_instance_transform(i,entry[0][i]);mm.set_instance_color(i,hues[i] if is_petal else Color("56845b"))
		inst.multimesh=mm;var mat=StandardMaterial3D.new();mat.vertex_color_use_as_albedo=true;mat.roughness=.9;inst.material_override=mat;world.add_child(inst)

