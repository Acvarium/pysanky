extends Node

var score = 0
var show_help_screen = true
var muted = false
onready var main_node = get_tree().get_root().get_node("Main")

func toggle_mute():
	muted = !muted
	save_game()


var SAVE_PATH = "user://pysanky.save"


func _ready():
	load_game()
	if main_node:
		main_node.update_mute_button()


func save_game():
	var save_dict = {}
	save_dict["muted"] = muted
		
	var save_file = File.new()
	save_file.open(SAVE_PATH, File.WRITE) 
	
	save_file.store_line(to_json(save_dict))
	save_file.close()


func load_game():
	var save_file = File.new()
	if !save_file.file_exists(SAVE_PATH):
		return null
	save_file.open(SAVE_PATH, File.READ)
	var data = {}
	data = parse_json(save_file.get_as_text())
	if "muted" in data.keys():
		var a = data["muted"]
		muted = data["muted"] == true
	return data
