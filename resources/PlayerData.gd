extends Resource
class_name PlayerData

@export var chosen_character: String
@export var energy: int
@export var health: int
@export var level: String
@export var character_sprite: Texture2D
@export var actions: Array[String] 
#will hold the 5 actions the player can make in the attack phase
#at some point ill make it a dictionary holding all of the abilities


#we can make 2 resources inheirited from this for the different characters
#or more if we create more than 2 characters. those two resources individually
#will hold specific player data
