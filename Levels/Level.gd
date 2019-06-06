extends Node2D

onready var player_spawn : Position2D = $PlayerSpawn

enum states { initializing, running, paused, resetting }

var state = states.initializing
export var starting_cutscene : String
onready var npc_scene = preload("res://NPCs/Enemies/NPC.tscn")
onready var npc_container = $NPCs

export var randomize_npcs : bool = true
export var randomize_background : bool = true
export var outside : bool = true

func _ready():
	state = states.running
	spawn_player()
	if starting_cutscene != null and starting_cutscene.length() > 0:
		Game.main.load_cutscene(starting_cutscene)


	#moved spawn_background_objects to background scenes

	if randomize_npcs:
		spawn_citizens(25)
		spawn_ghosts(2)
		spawn_sinners(2)


#warning-ignore:unused_argument
func _process(delta):
	update()


func spawn_citizens(number):
	#warning-ignore:unused_local_variable
	for i in range(number):
		var npc = spawn_npc()
		npc.character_type = npc.character_types.citizen
		npc.initial_attitude = npc.attitudes.ignore
		npc.scanned_attitude = npc.attitudes.ignore
		npc.set_key_drop_probability()




func spawn_ghosts(number):
	for i in range(number):
		var npc = spawn_npc()
		npc.character_type = npc.character_types.ghost
		npc.initial_attitude = npc.attitudes.ignore
		npc.scanned_attitude = npc.attitudes.fight
		npc.set_key_drop_probability()

func spawn_sinners(number):
	for i in range(number):
		var npc = spawn_npc()
		npc.character_type = npc.character_types.sinner
		npc.initial_attitude = npc.attitudes.fight
		npc.scanned_attitude = npc.attitudes.fight
		npc.set_key_drop_probability()

func spawn_npc():
	var new_npc = npc_scene.instance()
	npc_container.add_child(new_npc)
	new_npc.start(Vector2(rand_range(-1500, 1500), rand_range(-400, -40)))
	return new_npc

func spawn_player():
	assert is_instance_valid(player_spawn)
	var player_scene = preload("res://Player/Player.tscn")
	var new_player = player_scene.instance()
	new_player.set_global_position(player_spawn.get_global_position())
	add_child(new_player)

func _on_ResetArea_body_entered(body):
	if body == Game.player:
		state = states.resetting
		update()
		Game.main.reset_level()

func spawn_key(new_position):
	var key_scene = preload("res://Collectibles/Key.tscn")
	var new_key = key_scene.instance()
	if has_node("Collectibles"):
		$Collectibles.call_deferred("add_child", new_key)
	else:
		var new_node = Node2D.new()
		new_node.set_name("Collectibles")
		add_child(new_node)
		$Collectibles.add_child(new_key)
	new_key.start(new_position)

func stop_music():
	if has_node("BGMusic"):
		$BGMusic.stop()
