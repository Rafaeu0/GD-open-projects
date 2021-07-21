extends Node

# Variables&Components
onready var LacunaritySetter=$LacunaritySlider
onready var MapTexture=$MapTexture
onready var OceanLevelSetter=$OceanLevelSlider
onready var OctavesSetter=$OctavesSlider
onready var PersistenceSetter=$PersistenceSlider
onready var ResolutionSetter=$ResolutionSlider
onready var SeedSetter=$SeedEdit
onready var SeedLabel=$SeedLabel
onready var ScaleSetter=$ScaleSlider

var LandNoise:=OpenSimplexNoise.new()
var OceanNoise:=OpenSimplexNoise.new()
var LNV:float
var ONV:float
var OL:float

var Chars:='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ '



# little ready function herer
func _ready():
	randomize()
	Generate()


# Generate function
func Generate():
#	Prepating the map image
	var MapImage:=Image.new()
	MapImage.unlock()
	MapImage.create(ResolutionSetter.value,ResolutionSetter.value/2,false,Image.FORMAT_RGB8)
	MapImage.lock()


#	Setting values
	OL=OceanLevelSetter.value

	LandNoise.period=float(ResolutionSetter.value)/10*float(ScaleSetter.value)/100
	LandNoise.octaves=OctavesSetter.value
	LandNoise.persistence=PersistenceSetter.value
	LandNoise.lacunarity=LacunaritySetter.value

	OceanNoise.period=float(ResolutionSetter.value)/10*float(ScaleSetter.value)/100
	OceanNoise.octaves=OctavesSetter.value
	OceanNoise.persistence=PersistenceSetter.value+0.2
	OceanNoise.lacunarity=LacunaritySetter.value

	var HSeed:String
	if(SeedSetter.text!=""):HSeed=SeedSetter.text
	else:HSeed=GetSeed()
	LandNoise.seed=hash(HSeed)
	OceanNoise.seed=LandNoise.seed+69
	SeedLabel.text=HSeed


#	Generation loop
	for y in range(0,ResolutionSetter.value/2):
		for x in range(0,ResolutionSetter.value):

#			Setting abbreviations for the Noise values
			LNV=LandNoise.get_noise_2d(x,y)
			ONV=OceanNoise.get_noise_2d(x,y)


#			Land section
			if LNV>OL+0.4:
				MapImage.set_pixel(x,y,lerp(Color("004023"),Color("174a1b"),LNV*2-OL*2)*(2.4+float(randi()%25)/100))
			elif LNV>OL+0.07:
				MapImage.set_pixel(x,y,lerp(Color("004023"),Color("174a1b"),LNV*2-OL*2)
				*(0.8+float(randi()%25)/100+LNV*4-OL*4))
			elif LNV>OL+0.04:
				MapImage.set_pixel(x,y,lerp(Color("cca96e")*(0.8+float(randi()%4)/100+LNV*4-OL*4),
				lerp(Color("004023"),Color("174a1b"),LNV*2-OL*2)*(0.8+float(randi()%25)/100+LNV*4-OL*4),
				LNV*35-OL*35-1.4))
			elif LNV>OL:
				MapImage.set_pixel(x,y,Color("cca96e")*(0.8+float(randi()%4)/100+LNV*4-OL*4))

#			Ocean gen section
			elif LNV>OL-0.06:
				MapImage.set_pixel(x,y,Color("034063")+Color("105da2")
				*(0.85+float(randi()%4)/100+ONV/2+LNV*6.6-OL*6.6))
			elif LNV>OL-0.2:
				MapImage.set_pixel(x,y,Color("034063")+Color("105da2")
				*(0.6+float(randi()%4)/100+ONV/2+LNV*2.5-OL*2.5))
			else:
				MapImage.set_pixel(x,y,Color("034063")+Color("105da2")
				*(0.1+float(randi()%4)/100+ONV/2))

#	Setting the map texture
	MapTexture.texture.set("image",MapImage)



# Little function that generates random Strings for the seeds
func GetSeed()->String:
	var Seed:String
	for i in range(randi()%20+5):
		Seed+=Chars[randi()%len(Chars)]
	return Seed

